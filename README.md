dotfiles
========

## Claude Code

Slash commands live in `claude/commands/` and are linked into place via:

```sh
ln -s ~/dotfiles/claude/commands ~/.claude/commands
```

### External skill dependencies

Several commands read from skills installed outside this repo. On a fresh machine, install them at the paths below or the commands will fail at runtime.

| Command | Required skill | Install path | Source |
| --- | --- | --- | --- |
| `composition-patterns` | `vercel-composition-patterns` | `~/.agents/skills/vercel-composition-patterns/` | `npx skills add vercel-labs/agent-skills` (MIT) |
| `react-best-practices` | `vercel-react-best-practices` | `~/.agents/skills/vercel-react-best-practices/` | `npx skills add vercel-labs/agent-skills` (MIT) |
| `design-review` | `emil-design-engineering` | `~/.config/opencode/skills/emil-design-engineering/` | Paid — purchase separately |

The `web-design-review` command fetches Vercel's web interface guidelines at runtime; no local install needed.
