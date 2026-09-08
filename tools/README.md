# Production tools

Run `./tools/validate-foundation.ps1` from PowerShell. It checks required deliverables, local Markdown links, JSON parsing, the reference-gap record and main-scene reference. It does not validate Godot import, runtime physics, asset licensing or visual quality.

Future tools should solve a demonstrated production need: frame normalization, manifest checking, atlas export or content validation. Preserve source frames and make outputs deterministic. Do not add a general-purpose tool framework in advance of asset work.
