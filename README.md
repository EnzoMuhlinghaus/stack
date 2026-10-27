# stack

Agent skills for a setup where [Claude Code](https://claude.com/claude-code)
orchestrates, [Orca](https://github.com/stablyai/orca) runs worktrees and
workers, and [pi](https://github.com/earendil-works/pi) is a cheap worker on
other providers' models. Forked from
[t3dotgg/tstack](https://github.com/t3dotgg/tstack), which targets Claude Code,
Codex, and T3 Code.

## Skills

| Skill | Say | What it does |
|---|---|---|
| `full-send` | "full send" | Takes a change to a merged PR with nobody watching: proves it, reviews it, files it, babysits it, merges it. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for you to merge. |
| `council` | "council" | Gets review from the models you name, in parallel, and loops until they agree. |
| `loop-review` | "loop review" | Reviews a change with one model from another family, in a loop until both agents agree. |
| `file-pr` | "file a PR" | Files a short PR in the repo's own format, leading with the problem. |
| `takeover` | "take over" | Finishes someone else's PR, branch, or agent thread, and keeps their credit. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots, and fixes the real findings. |
| `modernize` | "modernize" | Rebases an old PR onto a replacement branch and decides if it should still exist. |
| `leaving-pr-comments` | (automatic) | Formats comments that an agent posts on your behalf. |

Some skills call others. Install the ones they need too:

- `full-send` uses `loop-review`, `file-pr`, and `babysit-pr`.
- `full-stop` uses `full-send`.
- `takeover` uses `modernize`, `file-pr`, `babysit-pr`, and `leaving-pr-comments`.
- `file-pr`, `babysit-pr`, and `modernize` use `leaving-pr-comments`.

No skill force-pushes. Only `full-send` merges.

## Install

```bash
git clone https://github.com/EnzoMuhlinghaus/stack
ln -s "$PWD"/stack/skills/* ~/.claude/skills/
```

These skills are for the orchestrating agent. pi workers get self-contained
task specs instead. If a worker needs a skill, load it for that launch with
`pi --skill <path>`.

## Requirements

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`).
- `python3` for `babysit-pr`'s `pr-wait` script.
- `pi` with access to the reviewer models, for `loop-review` and `council`.

## Make them yours

Personal settings go in your `CLAUDE.md` or `AGENTS.md`, so you can update the
skills without losing them:

```markdown
Loop reviewer: opencode-go/gpt-6-luna
Council: claude-opus, opencode-go/glm-5.3, opencode-go/kimi-k3.1-pro
```

Each repo's instructions name its review bots, which `babysit-pr` passes to
`pr-wait`:

```markdown
Review bots: gating `my-review-bot`, advisory `coderabbit`
```

## License

[MIT](LICENSE). Original work by Theo Browne in
[t3dotgg/tstack](https://github.com/t3dotgg/tstack).
