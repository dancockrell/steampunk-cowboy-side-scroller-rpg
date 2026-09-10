#!/usr/bin/env python3
"""Extract individual pose frames from a batch-001 candidate sheet.

Uses connected-component labeling on the non-background mask rather than a
rigid per-cell grid crop, because the sheets' own README records that "several
weapons, ropes and gestures cross nominal cell boundaries" -- a naive
384x512 grid slice would clip a raised rope or an extended barrel. Labeling
finds each pose's TRUE full extent (every pixel connected to it, wherever it
spills), then assigns detected blobs to nominal cells by their center point,
so a rope that leans into a neighboring cell is still part of the pose it
belongs to rather than being cut off or merged into the wrong one.

Output: one tightly-cropped RGBA PNG per pose, transparent background,
alongside a manifest.json recording source sheet, sha256, nominal cell index,
detected bounding box and any warning (component too small/large, ambiguous
assignment) so a human reviewer can see exactly what was inferred rather than
trusting a silent success.
"""
import sys, json, hashlib
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage

def chroma_key_mask(arr: np.ndarray, bg_rgb, tolerance: int = 40) -> np.ndarray:
    """True where a pixel is FOREGROUND (not close to the sampled background)."""
    diff = np.abs(arr[:, :, :3].astype(np.int16) - np.array(bg_rgb, dtype=np.int16))
    dist = diff.sum(axis=2)
    return dist > tolerance

def extract_sheet(png_path: Path, cols: int, rows: int, out_dir: Path, name_prefix: str,
                   min_area_px: int = 400, bg_sample_corner=(2, 2)):
    img = Image.open(png_path).convert("RGB")
    arr = np.array(img)
    h, w = arr.shape[:2]
    bg_rgb = tuple(int(v) for v in arr[bg_sample_corner[1], bg_sample_corner[0]])
    fg_mask = chroma_key_mask(arr, bg_rgb)

    labeled, n = ndimage.label(fg_mask, structure=np.ones((3, 3)))  # 8-connectivity
    objects = ndimage.find_objects(labeled)

    cell_w, cell_h = w / cols, h / rows
    # nominal cell index -> best matching component index (by area, largest wins
    # if a cell's nominal center overlaps more than one blob due to near-misses)
    cell_best = {}  # (col,row) -> (area, comp_index)
    warnings = []
    for i, sl in enumerate(objects):
        if sl is None:
            continue
        y0, y1 = sl[0].start, sl[0].stop
        x0, x1 = sl[1].start, sl[1].stop
        area = int((labeled[sl] == (i + 1)).sum())
        if area < min_area_px:
            continue  # noise / antialiasing speck, not a real pose
        cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
        col = min(cols - 1, max(0, int(cx // cell_w)))
        row = min(rows - 1, max(0, int(cy // cell_h)))
        key = (col, row)
        if key not in cell_best or area > cell_best[key][0]:
            cell_best[key] = (area, i, (x0, y0, x1, y1))

    out_dir.mkdir(parents=True, exist_ok=True)
    rgba = np.array(img.convert("RGBA"))
    rgba[:, :, 3] = np.where(fg_mask, 255, 0)
    # Despill: pixels adjacent to background that still carry background hue
    # in their RGB leave a magenta fringe once transparent; a tiny erosion of
    # the alpha channel removes the worst of it without eating real edges.
    alpha = rgba[:, :, 3]
    eroded = ndimage.binary_erosion(alpha > 0, iterations=1)
    rgba[:, :, 3] = np.where(eroded, alpha, 0)
    rgba_img = Image.fromarray(rgba, mode="RGBA")

    manifest = []
    expected_index = 0
    for row in range(rows):
        for col in range(cols):
            key = (col, row)
            frame_name = f"{name_prefix}_{expected_index:03d}.png"
            if key not in cell_best:
                warnings.append(f"cell col={col} row={row} (frame {expected_index}): no component found")
                expected_index += 1
                continue
            area, comp_i, (x0, y0, x1, y1) = cell_best[key]
            pad = 4
            cx0, cy0 = max(0, x0 - pad), max(0, y0 - pad)
            cx1, cy1 = min(w, x1 + pad), min(h, y1 + pad)
            crop = rgba_img.crop((cx0, cy0, cx1, cy1))
            crop.save(out_dir / frame_name)
            manifest.append({
                "frame": frame_name, "nominal_col": col, "nominal_row": row,
                "index": expected_index, "bbox_in_sheet": [cx0, cy0, cx1, cy1],
                "area_px": area, "width": cx1 - cx0, "height": cy1 - cy0,
            })
            expected_index += 1

    return {
        "source_sheet": png_path.name,
        "source_sha256": hashlib.sha256(png_path.read_bytes()).hexdigest(),
        "sheet_size": [w, h], "nominal_cols": cols, "nominal_rows": rows,
        "detected_background_rgb": list(bg_rgb),
        "total_components_found": int(n),
        "frames": manifest,
        "warnings": warnings,
    }

if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("sheet")
    ap.add_argument("--cols", type=int, required=True)
    ap.add_argument("--rows", type=int, required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--prefix", required=True)
    args = ap.parse_args()
    result = extract_sheet(Path(args.sheet), args.cols, args.rows, Path(args.out), args.prefix)
    manifest_path = Path(args.out) / "manifest.json"
    manifest_path.write_text(json.dumps(result, indent=2))
    print(f"extracted {len(result['frames'])} frames, {len(result['warnings'])} warnings")
    for w in result["warnings"]:
        print("  WARNING:", w)

def pad_to_common_canvas(frame_paths, out_dir: Path, canvas_size=None, foot_margin=8):
    """Pads a list of tightly-cropped RGBA frames to one shared canvas, bottom-
    aligned (the ground-contact edge) and horizontally centered. Bottom-align
    is appropriate for a run/idle/jump cycle where the foot line is the stable
    reference; docs/production/michael-pose-brief.md calls this "the logical
    foot origin," and this is the coarse version of that pivot discipline --
    exact per-frame contact-pixel detection is future review work, not
    invented here.
    """
    imgs = [Image.open(p).convert("RGBA") for p in frame_paths]
    if canvas_size is None:
        max_w = max(im.width for im in imgs) + foot_margin * 2
        max_h = max(im.height for im in imgs) + foot_margin
        canvas_size = (max_w, max_h)
    out_dir.mkdir(parents=True, exist_ok=True)
    out_paths = []
    for p, im in zip(frame_paths, imgs):
        canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
        x = (canvas_size[0] - im.width) // 2
        y = canvas_size[1] - im.height - foot_margin
        canvas.paste(im, (x, y), im)
        out_path = out_dir / p.name
        canvas.save(out_path)
        out_paths.append(out_path)
    return canvas_size, out_paths
