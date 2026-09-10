import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from extract import extract_sheet, pad_to_common_canvas
import json

sheet = Path("art-source/candidates/batch-001/michael_run_right_v002.png")
raw_out = Path(sys.argv[1]) / "raw"
final_out = Path(sys.argv[1]) / "aligned"

result = extract_sheet(sheet, cols=4, rows=2, out_dir=raw_out, name_prefix="michael_run_right")
print(f"extracted {len(result['frames'])} frames, warnings={result['warnings']}")

frame_paths = [raw_out / f["frame"] for f in result["frames"]]
canvas_size, out_paths = pad_to_common_canvas(frame_paths, final_out)
print("canvas size:", canvas_size)
for p in out_paths:
    print(" ", p.name)

(Path(sys.argv[1]) / "extraction_manifest.json").write_text(json.dumps({
    "source_sheet": result["source_sheet"],
    "source_sha256": result["source_sha256"],
    "canvas_size": list(canvas_size),
    "alignment": "bottom-aligned, horizontally centered per-frame tight bbox",
    "frame_count": len(out_paths),
}, indent=2))
