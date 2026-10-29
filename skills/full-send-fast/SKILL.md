---
name: full-send-fast
description: Trigger this if the user says 'full send fast'.
---

# Full Send Fast

Do the same work as `full-send`, through to a merged PR, with less ceremony.
Use it for small, low-risk changes where speed matters more than a second
opinion.

Read [full-send](../full-send/SKILL.md) and follow its workflow, testing
permission, merge gate, and rules for asking the user. An explicit "full send
fast" request authorizes that work, including the merge, without a separate
"full send" request. The overrides below take precedence.

## No loop review

Skip step 3 ("Get feedback"). Do not run `loop-review`. Review your own diff
once before you file the PR.

## Skip Sentinelle

Add the `no-sentinelle` label when you file the PR, so the Sentinelle review
bot skips it:

```bash
gh pr edit <pr> --add-label no-sentinelle
```

If the repo has no such label, create it with
`gh label create no-sentinelle`, then add it. When you babysit, do not pass
Sentinelle to `pr-wait` as a gating bot, and do not wait for it. Other review
bots still count as the repo's instructions say.

## Lighter proof

The checks the repo's CI runs (typecheck, lint, tests), observed green, are
enough proof for logic, config, and docs changes. Skip reproductions and
running the app for those.

UI and runtime behavior changes still need full-send's proof: run the app and
look at the change. Rules that require screenshots on frontend PRs still
apply.

If the repo has no CI checks that cover the change, use full-send's proof.

## Report

In the final message, also say that loop review was skipped, that the PR
carried `no-sentinelle`, and which proof you used.
