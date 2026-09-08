# Project authority

Read README.md, docs/decisions.md and the document for the assigned feature before editing. This is a documentation-first foundation. Implement gameplay only when the assigned task requests it; do not turn setup into a framework or full game.

- Preserve the approved written art direction. Original images are pending recovery, not implicitly replaced or approved.
- Keep simulation state separate from animation/VFX. Stable authored IDs own save and encounter truth.
- Every romanceable character is an explicitly adult woman. Mutual interest, consent and personal agendas remain part of the design.
- Keep work bounded to the first temple; unresolved numbers are tuning proposals, not user approvals.
- Small coherent commits. Do not modify another task's checkout/index. Future concurrent tasks use distinct branches/worktrees and the ownership table in docs/parallel-task-plan.md.
- Run tools/validate-foundation.ps1 for foundation changes and relevant gameplay checks once implemented. Report local, committed, pushed and validated states distinctly.
- Preserve native art sources, provenance and rejected status. Never call placeholders approved assets or a screenshot specification a render.
- Update existing authority docs when decisions change; avoid parallel conflicting designs.
