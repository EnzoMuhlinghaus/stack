---
name: file-pr
description: File a concise pull request. Use when the user asks to file, open, or create a PR.
---

# File PR

Repository rules come first. If the repo's `AGENTS.md`, `CLAUDE.md`, or PR
template sets a PR format (linked issues such as `Closes #N`, required
sections, screenshots), follow it exactly. Use the advice below only for what
the repo leaves open, never as a competing template.

Before filing, check whether a PR for this branch already exists. Review the
diff locally against the base branch (usually `origin/main`) to make sure its
contents match the goal.

PR titles usually become commit messages, so follow the repository's title
conventions. Look at recently merged PRs and Git history for examples. Prefer a
concise, human-readable title that explains why the change matters:

BAD

> ❌ perf(server): negotiate permessage-deflate on the websocket

GOOD

> ✅ perf(server): cut websocket frame size by 70%+ with gzipping

Open the description with a simple explanation of the problem based on the
user's original prompt, then briefly explain the solution. Do not lead with an
implementation inventory:

BAD

> ❌ Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Deleted buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD

> ✅ My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

Embed screenshots, do not link them. In a private repo, use
`![alt](https://github.com/<owner>/<repo>/blob/<sha>/<path>?raw=true)`. For
frontend changes, include each changed state in Light and Dark when the app
has both.

Lay screenshots out as Markdown tables for side-by-side review: one row per
state (bold row label), one column per compared variant (Light | Dark, or
Before | After), and one table per viewport. In image cells, use
`<img src="https://github.com/<owner>/<repo>/blob/<sha>/<path>?raw=true" width="<n>" alt="<state>, <variant>">`
so each pair renders at the same size. Use one width per table: about 240-260 for phone captures,
400-460 for desktop. Put an en dash (–) in an empty cell. Put short context
sentences under the table, not between images. For example:

```markdown
| State | Light | Dark |
| --- | --- | --- |
| **Home** | <img src="..." width="250" alt="Home, light"> | <img src="..." width="250" alt="Home, dark"> |
| **Empty list** | <img src="..." width="250" alt="Empty list, light"> | – |
```

Never use the em-dash character in the title or description.

End the description with the public model name and harness that made the
changes, for example `Created with <model> in <harness>.` Include subagent
models that wrote part of the change. Use the model name the harness reports.
If model identity is unavailable, name the harness without guessing a model.

Before submission, check the title, description, quotes, and attachments for
secrets and private details.

Open a real PR rather than a draft so review bots run. If `gh pr create` fails
because the GraphQL rate limit is used up, open it through REST with
`gh api repos/<owner>/<repo>/pulls -f title=... -f head=... -f base=... -F body=@<file>`. If the user also asked
to babysit it, continue with the `babysit-pr` skill.

Do not post a follow-up PR comment unless it serves the user's request. When a
comment is needed, use the `leaving-pr-comments` skill.
