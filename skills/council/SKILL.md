---
name: council
description: Trigger this if the user says 'council'.
---

# Council

Bring in several delegates to help with the user's request, usually for review
or feedback. The user's instructions (`CLAUDE.md`, `AGENTS.md`) name the
council members, for example `Council: claude-opus, opencode-go/glm-5.3,
opencode-go/kimi-k3.1-pro`. Use those, at high reasoning effort. If none are
named, ask. If a named member is unavailable, report it instead of
substituting.

Run each pi member the way `loop-review` runs its reviewer: one background
`pi -p` per member, all in parallel, with read-only tools, a saved diff file,
and its own `--session-id`. Run a Claude member as a Claude Code subagent with
that model.

Give each delegate the request and relevant context. For review or feedback,
keep their work read-only. Collect their responses and summarize the useful
findings, disagreements, and recommended next steps.

For a code review, ask each delegate for a score out of 10.
Count each full review pass as one round.
A fresh review after fixes starts a new round. Reuse each member's session id for
its next round.

If the work ends in a pull request, put the results in the PR description.
Put this section before the model and harness line at the end:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Claude Opus | 7/10 | 9/10 |
| GLM | 8/10 | 10/10 |
| Kimi | 7/10 | 9/10 |
```

If a delegate gives no score, write `no score`. Do not invent one.
If the PR is open, edit the description. Do not post a comment for this.
If there is no PR, put the same results in the final reply only.

If you agree with their recommendations, make the changes and request a fresh
review after. Continue until all delegates are satisfied, for at most 3 rounds
unless the user asks for more. At the limit, show the open disagreements and
let the user decide.

Do not let repeated reviews result in scope creep. It is your job to fight to
keep scope limited.
