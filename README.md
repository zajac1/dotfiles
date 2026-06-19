dotfiles
========

Personal macOS dotfiles: zsh + zim, starship prompt, Ghostty terminal, Neovim,
and Claude Code — all themed from a single source via **tinty**.

This file is the map. It's written to be useful to both me and any AI agent
working in here: what's configured, where it lives, and how to change it.
For how an agent should *behave* in this repo, see [`AGENTS.md`](AGENTS.md)
(symlinked to `~/.claude/CLAUDE.md` by `setup.sh`).

## Layout

| Path | What it is |
| --- | --- |
| `.zshrc`, `.config/.zimrc` | Shell config + zim module list |
| `.config/starship.toml` | Prompt (uses the tinty `tinted` palette) |
| `.config/ghostty/config` | Terminal; theme is tinty-managed |
| `.config/ghostty/themes/tinted` | Generated Ghostty theme (do not hand-edit) |
| `.config/tinted-theming/` | tinty config, generated palette, apply hook |
| `nvim/` | Neovim config (lazy.nvim); colors via `tinted-nvim`. `~/.config/nvim` symlinks here |
| `claude/` | Claude Code: slash commands + statusline script |
| `AGENTS.md` | Engineering rules → `~/.claude/CLAUDE.md` |
| `Brewfile` | All Homebrew packages, casks, fonts |
| `.gitconfig`, `.delta_themes.gitconfig`, `.lazygit_config.yml` | Git tooling |
| `setup.sh` | Bootstrap: git identity + SSH key, symlinks all tracked configs, registers MCP servers |
| `.env.example` | Template for `~/.env` machine-local secrets (copy + fill in) |
| `.macos` | macOS `defaults` tweaks |

> Note: `setup.sh` now symlinks every tracked config into place (shell, git,
> Ghostty, starship, tinty, Neovim, Claude) — see the `link` list in the
> script. It assumes a fresh machine: back up any existing real configs at
> those paths first, since they're replaced with symlinks.
> `.config/ghostty/ghostty-shaders/`, `backups/`, and `~/.env` are intentionally
> untracked.

## Fresh machine

For the full step-by-step (agent-followable) bootstrap with verifications and a
capabilities recap, see [`BOOTSTRAP.md`](BOOTSTRAP.md). Quick version:

```sh
brew bundle --file=~/dotfiles/Brewfile   # tools, casks, fonts
~/dotfiles/setup.sh                       # git/ssh, all config symlinks, MCP servers
cp ~/dotfiles/.env.example ~/.env         # then fill in the real secret values
tinty install                             # clone the tinted-shell template (required before apply)
tinty apply base24-catppuccin-mocha       # generate all theme files
```

`setup.sh` symlinks everything tracked, so there's no manual linking left.
Launch `nvim` once to let lazy.nvim install plugins. Per-context git identity
for `~/projects/` (work) goes in `~/.ssh/prof.conf` — set that up separately;
`setup.sh` only writes the global identity to `~/.ssh/priv.conf`.

## Theming (tinty)

One scheme drives every app. The active scheme is **`base24-catppuccin-mocha`**.

How it flows:

1. `tinty apply <scheme>` resolves the scheme's colors and runs the
   `tinted-shell` hook, which sources the colors and calls
   `.config/tinted-theming/hooks/apply.sh`.
2. `apply.sh` regenerates three consumer-specific files from the `base00`–`base17`
   palette:
   - `.config/ghostty/themes/tinted` — Ghostty `palette = …` theme file
   - the `[palettes.tinted]` block inside `.config/starship.toml` (rewritten
     between `# === BEGIN/END TINTED PALETTE ===` markers)
   - `.config/tinted-theming/palette.sh` — `PAL_BASE*` shell vars consumed by
     the Claude statusline
3. Neovim reads the current scheme from
   `~/.local/share/tinted-theming/tinty/current_scheme` and `tinted-nvim`
   live-reloads it.

### Change the theme

```sh
tinty list                       # available schemes
tinty apply base16-gruvbox-dark-medium
```

After applying:
- **Neovim** updates live (no restart).
- **Ghostty** needs a restart (it reads the theme file at launch).
- **Shells** pick up the regenerated starship palette and statusline colors on
  the next prompt draw — starship re-reads its config each prompt and the
  statusline sources `palette.sh` on every render.

`apply.sh` handles both base16 and base24 schemes — for base16 schemes it maps
the missing base24 bright slots (`base10`–`base17`) back to their base16
equivalents, so switching to a base16 scheme still produces complete output.

## Shell (zsh)

Framework is **zim** (`.config/.zimrc`), with modules: `input`,
`zsh-syntax-highlighting`, `zsh-autosuggestions`, and `zsh-z` (directory jump).
Prompt is **starship**. Machine-local secrets/vars load from `~/.env` (untracked)
at the top of `.zshrc`.

Core CLI replacements (installed via Brewfile):

| Command | Replaces | Tool |
| --- | --- | --- |
| `ls`, `ll`, `la`, `l` | `ls` | `eza` (icons, dirs-first) |
| `cat` | `cat` | `bat` (theme follows macOS light/dark) |
| `ps` | `ps` | `procs` |
| `rm` | `rm` | `trash` (moves to Trash, not unlink) |
| `vim` | `vim` | `nvim` |

Other tooling on the `$PATH` / initialized in `.zshrc`: `fd`, `ripgrep` (`rg`),
`fzf`, `zoxide` (`z`), `git-delta`, `lazygit`, `stylua`, `tree-sitter`.
`~/.local/bin` is prepended to `$PATH`.

### Aliases & functions

| Alias | Does |
| --- | --- |
| `..` / `...` / `....` / `.....` | Up N directories |
| `editshellconfig` / `edittermconfig` | Edit `.zshrc` / Ghostty config in nvim |
| `link-package` / `unlink-package` / `link-status` | `~/zelda.sh` package linking |
| `zcli` / `zclient` | Jump to `desktop-app/apps/cli` / `apps/client` |
| `nvm` | Alias to `fnm` |

`cc()` — inside a repo with a `.devcontainer/`, brings the devcontainer up and
execs Claude Code inside it (`devcontainer up` + `devcontainer exec … claude
--dangerously-skip-permissions`). Errors out if no `.devcontainer/` is present.

## Node (fnm)

Node is managed by **fnm** (Fast Node Manager), initialized in `.zshrc` with
`--use-on-cd`: entering a directory with a `.node-version` or `.nvmrc` auto-switches
to that version. `nvm` is aliased to `fnm` out of muscle memory.

```sh
fnm install 22        # install a version
fnm use 22            # switch in the current shell
fnm default 22        # set the global default
echo "22" > .node-version   # pin a project (auto-switches on cd)
```

## Terminal (Ghostty)

`GohuFont 14 Nerd Font` @ size 20, 75% background opacity with blur, P3 colorspace,
starts maximized and restores window state. Theme is tinty-managed (see above).
A vendored shader collection lives at `.config/ghostty/ghostty-shaders/`
(gitignored, its own repo) — enable one via the commented `custom-shader=` lines
in the config.

## Editor (Neovim)

lazy.nvim-managed. Colors come from `tinted-theming/tinted-nvim`, which follows
the current tinty scheme and live-reloads; the config transparentizes background
groups to let Ghostty's opacity show through. Treesitter runs on its `main`
branch with an expanded parser set and treesitter-based folding
(`foldlevelstart=99`, so files open unfolded).

## Git

`delta` is the pager and diff filter (side-by-side, line numbers, `colibri`
feature). `pull.rebase=true`, `push.autoSetupRemote=true`, `diff3` conflict style.
SSH/identity configs are split via conditional includes: `~/.ssh/priv.conf`
globally and `~/.ssh/prof.conf` for repos under `~/projects/`. `.lazygit_config.yml`
configures lazygit *as launched from Neovim* (the `kdheepak/lazygit.nvim` plugin
points at `~/.lazygit_config.yml`); terminal `lazygit` runs on its own defaults.

## Claude Code

Slash commands live in `claude/commands/`. `setup.sh` symlinks them to
`~/.claude/commands`, plus `claude/statusline-command.sh` → `~/.claude/` and
`AGENTS.md` → `~/.claude/CLAUDE.md`. It also registers MCP servers at user scope
(e.g. `context7` via `claude mcp add`), so they're available across all projects.

The **statusline** (`claude/statusline-command.sh`) is a powerline-style bar
showing cwd, git branch, model, context-window usage, and the 5h/weekly rate-limit
windows — each as percent remaining plus a superscript countdown to rollover
(whole hours, `<1h` under an hour). Its colors are sourced from the tinty
`palette.sh`, with a hardcoded Catppuccin fallback.

### External skill dependencies

Several commands read from skills installed outside this repo. On a fresh machine, install them at the paths below or the commands will fail at runtime.

| Command | Required skill | Install path | Source |
| --- | --- | --- | --- |
| `composition-patterns` | `vercel-composition-patterns` | `~/.agents/skills/vercel-composition-patterns/` | `npx skills add vercel-labs/agent-skills` (MIT) |
| `react-best-practices` | `vercel-react-best-practices` | `~/.agents/skills/vercel-react-best-practices/` | `npx skills add vercel-labs/agent-skills` (MIT) |
| `design-review` | `emil-design-engineering` | `~/.config/opencode/skills/emil-design-engineering/` | Paid — purchase separately |

The `web-design-review` command fetches Vercel's web interface guidelines at runtime; no local install needed.
