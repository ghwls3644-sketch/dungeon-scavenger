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

## Validation

- Preserve the recorded SHA-256 hashes of frozen source documents.
- Validate active Markdown relative links and run `git diff --check` before committing.
- Run any ticket-specific checks documented in the relevant Project or Design file.
- Do not commit when validation fails or when unrelated working-tree changes are present.

## Git and GitHub

- At the start of a ticket, fetch `origin/main` and confirm the local branch has not diverged. Never discard remote or user changes.
- After a ticket is complete and validated, show the user a concise change and validation summary before committing.
- Ask whether to commit and push. Do not commit or push until the user explicitly approves the reviewed result.
- If the user requests revisions, apply them, validate again, and present the updated result for approval.
- After approval, create one focused commit for the ticket and push it to `origin/main` in the same workflow.
- Never force-push, rewrite published history, or bypass branch protection unless the user explicitly authorizes that exact operation.
- If a push is rejected or the remote changed, stop and reconcile safely instead of forcing the update.
- Report the commit hash, push result, validation performed, and next ticket in the completion message.
