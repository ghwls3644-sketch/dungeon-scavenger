# Dungeon Scavenger repository workflow

## Canonical context

- Start documentation work from `docs/README.md`.
- Treat `docs/GDD.md` as the current product and system overview.
- Track source migration in `docs/project/migration_manifest.md` and `docs/project/story_v1.5_inventory.md`.
- Do not edit files under `게임 기획 파일/` or `docs/archive/` unless the user explicitly requests an archival correction.
- Until the document migration is formally approved, new Story, Design, and Reference documents remain drafts and do not replace the frozen source.

## Task scope

- Work on one documented ticket at a time.
- Do not add features, lore, names, dates, identifiers, or decisions outside the ticket scope.
- Keep Story (why and what is true), Design (how it works), Reference (what it is called), and Project (decisions and status) responsibilities separate.
- Record new migration-time content changes in `docs/project/migration_changes.md` before applying them to canonical documents.

## Consistency-check reminders

- Read the checkpoint table in `docs/README.md` and `docs/project/migration_manifest.md` before starting the next ticket.
- When the current work reaches a recorded checkpoint, begin the user-facing status with `⛔ 정합성 검사할 때입니다`.
- Immediately explain in plain language which completed work, current rules, or next tasks must match, report the result, and do not start the next ticket until the user directs work to continue.
- Include `정합성 검사: 지금` or `정합성 검사: 아직 아님` in each ticket completion summary.
- When a completed ticket changes the current or next checkpoint, update both checkpoint tables in the same ticket.

## Validation

- Preserve the recorded SHA-256 hashes of frozen source documents.
- Validate active Markdown relative links and run `git diff --check` before committing.
- Run any ticket-specific checks documented in the relevant Project or Design file.
- Do not commit when validation fails or when unrelated working-tree changes are present.

## Git and GitHub

- At the start of a ticket, fetch `origin/main` and confirm the local branch has not diverged. Intentional, unpushed ticket commits may leave the local branch ahead of `origin/main`. Never discard remote or user changes.
- After a ticket is complete and validated, show the user a concise change and validation summary before committing.
- Ask whether to commit the reviewed ticket. Do not commit until the user explicitly approves the reviewed result.
- If the user requests revisions, apply them, validate again, and present the updated result for approval.
- After approval, create one focused commit for the ticket. A completed ticket must not remain mixed with the next ticket's working-tree changes.
- Do not push merely because one ticket is complete. Continue committing later approved tickets locally until the user declares that the current daily allocation or work batch is complete.
- Treat the end of a daily allocation or work batch as a user decision. Do not infer it from ticket count, elapsed time, inactivity, or wording that only approves a commit.
- Push the accumulated commits to `origin/main` only when the user explicitly says the current allocation or work batch is complete, or explicitly asks to push.
- Before pushing, fetch `origin/main` again and confirm the accumulated local commits can be published without discarding or overwriting remote changes.
- Never force-push, rewrite published history, or bypass branch protection unless the user explicitly authorizes that exact operation.
- If a push is rejected or the remote changed, stop and reconcile safely instead of forcing the update.
- After each ticket commit, report the commit hash, validation performed, local-ahead state, and next ticket. When a batch is pushed, also report the push result and remote synchronization state.
