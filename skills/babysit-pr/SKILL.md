---
name: babysit-pr
description: Monitor a pull request through review and CI. Use when the user asks to monitor, watch, or babysit a PR.
---

# Babysit PR

Many repos have AI review bots. They're helpful, even if they are not always
right.

## Review bots

The repo's instructions (`AGENTS.md`, `CLAUDE.md`) name its review bots and
say which ones gate readiness. Read them before you watch. If they name none,
pass every review bot you see on the PR as `--advisory-bot`: `pr-wait` cannot
recognize an unnamed bot, so its check would gate like CI.

## Waiting

Never write your own watcher, polling loop, or `sleep` loop. Use one `pr-wait`
per PR, from `scripts/` in this skill's directory (use its absolute path).
Every watcher on a GitHub account shares one rate limit.

```bash
pr-wait <pr> [--repo owner/name] [--until ready|green|any-change] \
  [--gating-bot NAME]... [--advisory-bot NAME]...
```

Pass each gating bot with `--gating-bot` and each advisory bot with
`--advisory-bot`. A name matches any login or check name that contains it.

It prints one line per real event. It exits 0 when the `--until` condition is
met or the PR merges, 1 when it needs you (a required check failed, conflicts,
unresolved threads, PR closed), and 2 on bad input.

- `ready` (default): required checks green, a gating bot reviewed the head
  (when one is named), and no unresolved threads. Use this to babysit.
- `green`: required checks only.
- `any-change`: exit on the first event.

In Claude Code, run it with the Monitor tool (`timeout_ms: 3600000`), so each
line wakes you. Without a monitor, run it as one background command. Never
start it with `&` inside a shell call: that leaves an orphan watcher.

Start it again after you push, after you handle an exit 1, and after a resume.
It remembers what it already reported, so nothing that arrived in between is
lost. If it says another pid already watches the PR, do not start a second one.
Kill the old one only if its events do not reach you.

Only the agent that owns the PR watches it. A delegated worker (a reviewer, an
Orca worker) never starts `pr-wait`.

When an event needs no action, end your turn without a message. Never post or
say "still waiting".

### A bot that stopped

Some bots review a limited number of rounds, then stop and ask for a human
(for example "human review needed"). They cannot be asked again. `pr-wait`
quotes the bot's headline in its "finished" event. When a gating bot says it
stopped, it will never review a newer head: watch with `--until green` from
then on, and list its open findings for the user in your report.

## GitHub rate limits

`gh pr create`, `gh pr view`, and `gh pr checks` use GraphQL. When GraphQL is
used up, the REST limit is separate and usually still has room. Use
`gh api repos/<owner>/<repo>/pulls/<n>` to read a PR, and
`gh api repos/<owner>/<repo>/commits/<sha>/check-runs` for checks.

## Reviews

Only act on checks and comments newer than the latest push. Distinguish
repository failures from infrastructure flakes.

A bot finding is a hypothesis. For each one:

1. Reproduce the mechanism against the source.
2. If there is a real gap, fix it, even when the bot's stated mechanism is
   wrong. Add a regression test and prove it fails without the fix: back up
   the fixed file with `cp`, restore the old code, run the test, then restore
   the backup. Never use `git checkout --` for this, because it discards
   uncommitted edits.
3. Reply in the finding's thread with the fix and the evidence, or with a
   written reason when you decline it.
4. Resolve the thread only after the reply is posted.

Use the `leaving-pr-comments` skill for every comment posted on the user's
behalf.

If the repo has `.macroscope/check-run-agents/*.md`, read those rules before you
reply to a Macroscope finding. Its findings cite them.

Embed screenshots in PR text, do not link them. In a private repo, use
`![alt](https://github.com/<owner>/<repo>/blob/<sha>/<path>?raw=true)`. After a
visual revision, post fresh screenshots and mark the old ones superseded.

Keep the PR at the size the user's goal needs. Review loops tend to grow a
PR one cheap-looking fix at a time. Fix real bugs in the intended case.
Decline the rest with a written reason, and list them as follow-ups:
unneeded tests, guards for edge cases that do not matter, extra integration
or compatibility, and small performance costs. Prefer the fix that deletes or
narrows code.

## Base branch and merging

Keep an eye on changes to `main`. `pr-wait` reports when new base commits touch
this PR's files, and when the PR becomes BEHIND or DIRTY. Never force-push. To
bring a branch up to date, rebase it onto a new branch, open a replacement PR
that links the old one, and close the old PR only with the user's permission.
If an overlapping PR makes this one obsolete, stop monitoring, report it to the
user, and ask before closing the PR.

If nothing has changed, stay quiet rather than posting filler comments. Stop
when `pr-wait` exits 0 and report that the PR is ready to merge. Never merge
unless the user granted it for this task, for example with `full-send`. Right
before a granted merge, run `git fetch` and check the PR again. Never merge
when it is BEHIND or DIRTY, or when base commits that landed after the last
green run touch this PR's files.
