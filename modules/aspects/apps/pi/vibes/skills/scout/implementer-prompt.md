# Scout Implementer Contract

Dispatch one fresh writing agent with the selected node and all required context in
the task itself.

The agent must:

- change only the selected node's product scope; the parent owns Neorg status and log edits;
- use `test-driven-development`, showing the focused RED failure before the minimal GREEN edit;
- use `systematic-debugging` for unexpected failures instead of guessing;
- run focused checks and the applicable full suite with pristine output;
- commit all product changes, leave the worktree clean, and self-review the exact base-to-HEAD range;
- ask for missing facts rather than inventing them.

The direct result contains: status (`DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, or
`NEEDS_CONTEXT`), base and head SHAs, commits, changed files, RED/GREEN evidence,
all checks run, self-review, discoveries, and concerns. Keep it concise; do not write
handoff artifacts into the repository.
