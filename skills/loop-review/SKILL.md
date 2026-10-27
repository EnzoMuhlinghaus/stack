---
name: loop-review
description: Use when the user says "loop review", or when another skill asks for a review loop.
---

# loop-review

This is a workflow for making your code changes more correct before (or
sometimes after) filing a pull request. tl;dr - have one reviewer from another
model family review your code in a loop until you both agree.

Make the most minimal possible changes to appease the reviewer. Be careful
of scope creep and don't be scared to push back.

## Reviewer

The user's instructions (`CLAUDE.md`, `AGENTS.md`) name the reviewer model,
for example `Loop reviewer: opencode-go/gpt-6-luna`. Use the one the user
names in the request first, then that setting. If neither names one, ask. Do
not pick a model yourself, and do not substitute when the named one fails.

Prefer a model from a different family than the one doing the work: the point
is a second set of blind spots.

## Budget

- Default: 3 rounds total. Round 1 is full. Later rounds check only
  changed code and open findings.
- Extend to 5 only for security, permissions, auth, data loss, or
  state/concurrency, while a blocker or should stays open with evidence. Or when
  the user asks.
- Stop early if a round returns only nits. Declined nits and comment,
  doc, or format-only fixes need no new round.
- One reviewer only. The reviewer must not start subagents or reviewers.
- Keep a ledger: id, severity, outcome, usage if returned. Never guess it.

## 1. Scope

Run `git status --short`. Do not stash, discard, or include unrelated
changes. Limit review to the change paths if they separate cleanly.
Otherwise stop and ask.

Find the base after `git fetch origin`:

- PR: `gh pr view <n> --json baseRefName,headRefOid`. Check out the branch
  only if clean. Confirm `HEAD` is the PR head, or ahead only by this
  change. Base: `git merge-base HEAD origin/<baseRefName>`.
- Local: `git merge-base HEAD origin/<default-branch>`. No remote: a base
  the user names, or `HEAD` for uncommitted changes only.

The change is base to working tree in those paths, with untracked files.
Use one diff command all rounds. State intent and out-of-scope in 1-2
sentences. Run covering checks. Do not send code this change breaks. Note
missing or pre-failing checks in the brief.

## 2. Start the reviewer

Save the diff to a file outside the worktree
(`git diff <base> [-- <paths>] > <tmp>/review.diff`, plus untracked files):
the reviewer gets read-only tools and no shell, so it cannot change your files.

For a pi model, run each round as one background command (in Claude Code,
`run_in_background`), so you wake when it finishes and spend nothing while it
runs. Its output is the review. A fixed session id keeps the reviewer's
context from one round to the next:

```bash
pi -p --model <provider/id> --thinking high --tools read,grep,find,ls \
  --session-id loop-review-<short-sha>-<timestamp> "<brief>" </dev/null
```

A session id takes only letters, digits, `-`, `_`, and `.`, so never put a
branch name with `/` in it. Close stdin (`</dev/null`): a background `pi -p`
can otherwise end without output.

Do not run the reviewer as a supervised Orca worker: Orca workers report with
the `orca` CLI, which a reviewer without a shell cannot run, so the wait never
ends.

For a Claude reviewer, use a Claude Code subagent with that model instead.

Do not edit scoped files while review runs. Wait for the result. Do not
poll or start a second reviewer. Timeout, error, or no reply is not
approval. After each round, confirm with `git status --short` that the
reviewer changed nothing.

Round 1 brief (the reviewer gets no history):

```
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <abs path> Base: <sha> Intent: <intent> Out of scope: <scope> Checks: <results>
See: <tmp>/review.diff (the full change), then read the changed files.
Read surrounding code. Find bugs, broken callers, mismatch with intent.
Skip style unless it hides a bug. Hold to the smallest change. Flag code,
tests, or guards the intent does not need. Other paths, rare cases, small
perf, extra compat: nits.
blocker = intended case wrong. should = real bug callers will hit, in intent. nit = rest.
Reply:
VERDICT: APPROVE or CHANGES
S1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion> (stable ids)
Time box: 15 minutes. If you cannot read the diff, reply BLOCKED and why.
```

## 3. Answer findings

Check each finding and severity yourself. Another path, rare case, or
small cost is a nit, whatever label it came with.

- Agree: smallest fix. Prefer delete or narrow over new lock, cache,
  helper, or option. Fix the case that happened. Add one focused test
  that fails without the fix, if intent needs it.
- Disagree: say why, with evidence (file:line, test, output).
- Out of scope or nit: decline in one line. List as follow-up.

Update the ledger. Re-run checks and `git diff --shortstat <base>`. If
review grew the diff, cut first. Do not agree just to end the loop.

## 4. Next round

Start one only if budget remains and a blocker or should is open, behavior code
changed, or approval does not cover the current behavior diff. Run the next
`pi -p` with the same `--session-id`, so the reviewer keeps its context. Send the ledger (`fixed:` / `disagree:` / `declined:` + evidence), the
same base diff, and the change since last round, each saved to a file. Tell the reviewer: open ids and
changed code only. Mark each old id `resolved` or `still open: <reason>`.

## 5. Stop and ship

Agreed: APPROVE on the current behavior diff, no blocker or should open,
no concern of your own. Stuck: an item stays disputed after two replies,
or budget ends. Show both sides in 2-3 lines each. The user decides.
Budget end is not approval.

Do not push during the loop. Push after agreement only if the user asked
to push, ship, or update the PR. If you push to a PR, add above the model
blurb:

`Reviewed with loop-review: <N> rounds with <model>. Verdict: approved`.

Add `on <effort>` only if verified.

Report: rounds, model, what the reviewer changed, diff size before/after, fixed
and declined findings with reasons, usage if exposed (else say not), pushed or
not.
