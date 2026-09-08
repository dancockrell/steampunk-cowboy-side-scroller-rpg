# Action-sized generation and export handoff

## Commission brief

Every commission names one entity, one action or key pose, the approved reference IDs, identity invariants, intended camera, canvas/aspect ratio, background/alpha requirement, silhouette constraints, expected sockets and the specific question being tested. Missing identity inputs are recorded as missing; do not fill them with arbitrary traits.

Reusable prompt structure (fill all bracketed fields before use):

> Use [approved reference IDs/files] as identity and style authority. Produce one [adult character/entity] in [single pose/action], side-view facing [direction], with a fixed orthographic camera. Preserve [explicit observed costume/face/gear invariants]. Change only [pose/expression/action]. Target [source canvas] for eventual [runtime crop/scale]. Use [transparent/plain separable background] and preserve the full silhouette including [extremities]. Keep [tool socket/foot origin/scene seam] consistent. No extra characters, labels, montage, alternate costumes or camera motion.

For image-to-video, the start image contains one isolated character in one pose; a turnaround or contact sheet is a reference package, not the start frame. Generate a short single action/loop. Preserve raw output before extraction or cleanup. Record provider/model/version/settings and credit cost when available; never invent missing provider metadata.

## Export package

Each accepted action folder includes ordered lossless PNGs or an atlas plus source-frame mapping; metadata defined in data-contracts.md; a contact sheet; a preview loop; source lineage; review notes; and a concise implementation note. Filenames follow the existing pipeline convention. Export tools must fail on missing frames and preserve consistent dimensions and alpha.

The implementation note states: expected controller state, entry/exit poses, loop behavior, orientation/mirroring rule, pivot, sockets, per-frame durations, presentation markers, asset revision, known limitations and review status. Include how to reproduce the native preview. Claude/Grok must be able to integrate the pack without guessing what an unlabeled sheet contains.

## Review record template

- Asset/action ID and revision:
- Original reference IDs and source hashes:
- Tool/model/settings and prompt record:
- Source and export paths:
- Technical checks performed:
- Native-scale visual/motion evidence:
- Identity/continuity observations:
- In-engine timing and socket observations:
- Rights/provenance status:
- Decision: draft / review / admitted / rejected:
- Reviewer, date, unresolved exceptions and next action:

Technical readiness cannot promote an asset to visual approval automatically. Rejected material remains labeled in source storage; only admitted exports enter runtime assets. The first production batch has no admitted exports yet.
