# Asset ownership and admission

No image files were recovered or generated during the initial foundation setup. The subsequent user-authorized production batch now contains [23 candidate PNG sheets](../art-source/candidates/batch-001/README.md), with exact prompts, hashes, dimensions and review notes. Runtime asset directories remain empty because extraction/alignment and final admission are pending. `assets/references/reference-register.json` still tracks the unavailable original chat renders honestly.

Codex primarily owns planning, identity continuity, sprite production and visual review. Claude/Grok receive admitted exports and integration contracts. Code acceptance and art acceptance are separate responsibilities.

Record each future asset's stable ID, source location, creator/tool/model if applicable, source hash, license/permission status, reference IDs, intended use, dimensions, export version and review evidence. Status progresses `draft` → `review` → `admitted` or `rejected`. Unknown rights or missing identity approval prevents runtime admission, while clearly labeled graybox geometry can support code prototyping.

Store editable Aseprite/Krita/PSD sources in art-source/, organized by entity or room. Keep an `.gdignore` there. Runtime PNG/OGG exports belong in assets/ only after review. Do not download third-party art merely to fill folders. Do not copy assets from other games without checking provenance and project fit.

No LFS dependency is installed in this text-only foundation. Before committing large binary packs, assess GitHub limits and storage, select LFS or a versioned external source archive, and record reproducible retrieval plus checksums. Never commit raw bulk video or model caches. Keep an admitted runtime pack restorable alongside its editable sources; external archives must not be the only undocumented copy.
