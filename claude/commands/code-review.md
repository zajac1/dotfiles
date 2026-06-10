---
name: code-review
description: Multi-agent code review with independent reviewers, debate, and consensus
argument-hint: "[range] [--staged] [-- paths]"
context: fork
disable-model-invocation: true
---

Load the skill file at `~/.claude/skills/code-review/SKILL.md` using the Read tool and follow its instructions exactly.

User arguments (range, --staged, -- paths): $ARGUMENTS

Parse these arguments as described in Stage 0.5 of the skill.
