# Contributing

Start with the smallest ready item in docs/TODO.md. Branch from current main into a task-owned checkout. The task plan gives dependencies, owned paths and completion evidence. Do not launch all future tasks without checking dependencies.

Use small commits for one coherent result: a contract, an asset family, a behavior plus meaningful tests, or an integration fix. Run `./tools/validate-foundation.ps1`; for implemented behavior add the relevant tests in tests/README.md and inspect native motion. A passing parser does not approve art.

PR descriptions state the problem, resulting behavior, validation performed and remaining gaps. Include evidence paths and exact engine version when engine work exists. Never store credentials, unlicensed references, generated caches, or unreviewed bulk art. Register admitted assets through docs/asset-policy.md.

Use TODO IDs in commits and PRs. Update the existing design when implementation reveals a conflict. Keep main coherent and do not claim remote publication until the remote commit matches. CI is intentionally not provisioned for this documentation-only foundation; add bounded meaningful automation when executable systems exist.
