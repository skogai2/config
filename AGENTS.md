---
permalink: config/agents
type: router
---

<routes>

- @SKOGAI.md 
- @.harness/context_summary.md - harness: decisions, patterns, gotchas (read at session start)

</routes>

## harness

This repo uses the vv-harness plugin.

- Feature tracking: `.harness/features.json`
- Context and decisions: `.harness/context_summary.md`
- Progress handoff: `.harness/claude-progress.txt`
- Build/test: `.harness/init.sh` (`smoke_test`, `focused_test <file>`, `full_test`)
- Quality gates: `.claude/hooks/` (TaskCompleted, scope, git identity, commit gate)

Git identity: Emil Skogsund <emil@skogsund.se>, pushing over HTTPS via
`gh` (account Skogix); there is no SSH key for github.com.

