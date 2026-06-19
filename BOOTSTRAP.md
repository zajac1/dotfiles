# Bootstrap a fresh machine

Single source of truth for setting up this environment on a new macOS machine.
Written to be followed top-to-bottom by a human **or** an AI agent: each step has
a command and a way to verify it worked. Do the steps in order — later steps
depend on earlier ones.

> **Agent instructions:** Execute one step at a time. After each, run its
> **Verify** check and report the result before moving on. Stop and ask if a
> verify fails or a step needs a secret/credential you don't have. Do **not**
> run `setup.sh` on a machine that already has real (non-symlink) configs at the
> target paths without backing them up first — it replaces them with symlinks.

---

## Prerequisites

1. **Homebrew** — install if missing:
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   Verify: `brew --version`
2. **Clone the dotfiles** to `~/dotfiles`:
   ```sh
   git clone git@github.com:zajac1/dotfiles.git ~/dotfiles   # or https:// if no SSH yet
   ```
   Verify: `ls ~/dotfiles/setup.sh`

---

## Core setup

### 1. Packages, casks, fonts
```sh
brew bundle --file=~/dotfiles/Brewfile
```
Verify: `brew bundle check --file=~/dotfiles/Brewfile` (ignore "newer version
available" and untrusted-tap notices).

### 2. Run setup.sh
Prompts for git identity, generates an SSH key, symlinks every tracked config
into place, and registers the MCP servers.
```sh
~/dotfiles/setup.sh
```
What it does:
- Writes git identity to `~/.ssh/priv.conf` (kept out of the tracked `.gitconfig`).
- Generates an SSH key and copies the public key to your clipboard — **add it to
  GitHub** at https://github.com/settings/keys.
- Symlinks: `.zshrc`, `.gitconfig`, `.delta_themes.gitconfig`, `.lazygit_config.yml`,
  `.macos`, `.config/.zimrc`, `.config/starship.toml`, `.config/ghostty`,
  `.config/tinted-theming`, `nvim`, and the Claude `commands` / statusline / CLAUDE.md.
- Registers MCP servers at user scope (see step 5).

Verify: `ls -l ~/.zshrc ~/.config/nvim ~/.gitconfig` all show `->` symlinks into `~/dotfiles`.

### 3. Machine-local secrets
```sh
cp ~/dotfiles/.env.example ~/.env
# edit ~/.env and add whatever keys this machine needs (gitignored, never committed)
```
Verify: `source ~/.env` produces no error.

### 4. Theme (tinty)
```sh
tinty install                           # clone the tinted-shell template (required first)
tinty apply base24-catppuccin-mocha     # generate ghostty/starship/statusline theme files
```
Verify: `tinty list` works and `~/.config/ghostty/themes/tinted` exists.

### 5. Node (fnm)
```sh
fnm install --lts && fnm default lts-latest
```
Verify: `node --version` inside a new shell.

---

## Claude Code capabilities

### 6. Account integrations (no scripting needed)
Sign in to Claude Code (`claude` then `/login`). This brings the **claude.ai
integrations** (Atlassian, Slack, Notion, Linear, Asana, Google Drive/Calendar,
HubSpot, etc.) — they're tied to the account, not this repo. Re-auth each as
prompted.

### 7. Plugins (re-installed, not synced)
The skill/plugin set (superpowers, pr-review-toolkit, figma, playwright,
nordpass-* etc.) is **not** vendored in this repo — reinstall from their
marketplace inside Claude Code (`/plugin`). `settings.json`, `settings.local.json`,
and `~/.claude/skills` are likewise per-machine.

### 8. MCP servers
`setup.sh` registers four at user scope. Two are self-contained; two need
prerequisites installed first or they'll show "failed to connect":

| MCP | Self-contained? | Prerequisite |
|---|---|---|
| `context7` | ✅ npx | none |
| `chrome-devtools` | ✅ npx | a Chrome started with `--remote-debugging-port=9222` (override URL via `CHROME_BROWSER_URL`) |
| `codebase-memory-mcp` | ❌ | install the binary from `github.com/DeusData/codebase-memory-mcp` to `~/.local/bin/codebase-memory-mcp` |
| `conport` | ❌ | `uv` (in Brewfile) + the opencode conport setup: `~/.config/opencode/conport-wrapper.py` and the `~/.config/opencode/conport` data dir |

Verify: `claude mcp list` — `context7` should be ✔ Connected immediately; the
others connect once their prerequisites exist.

---

## What you now have (capabilities recap)

- **Shell**: zsh + zim (`zsh-syntax-highlighting`, `zsh-autosuggestions`, `zsh-z`),
  starship prompt, `~/.env` secrets, `set -o vi`.
- **Modern CLI replacements**: `eza` (ls), `bat` (cat), `procs` (ps), `trash` (rm),
  `zoxide` (smart cd), `fd`, `ripgrep`, `fzf`, `git-delta`, `lazygit`, `gh`,
  `git-filter-repo`, `gnupg`, `uv`/`uvx`, `ffmpeg`.
- **Editor**: Neovim (lazy.nvim, pinned via `lazy-lock.json`), Mason-managed LSPs
  (biome/oxlint/oxfmt), treesitter, tinty-themed live-reload, lazygit integration.
- **Terminal**: Ghostty (GohuFont Nerd Font, tinty theme, blur/opacity).
- **Theming**: one tinty scheme drives Ghostty, starship, the Claude statusline,
  and Neovim — switch with `tinty apply <scheme>`.
- **Node**: fnm with `--use-on-cd` auto-switching.
- **Git**: delta pager (side-by-side), per-context identity via `~/.ssh/{priv,prof}.conf`,
  `pull.rebase`, `push.autoSetupRemote`, osxkeychain credentials.
- **Claude Code**: global engineering instructions (`AGENTS.md` → `~/.claude/CLAUDE.md`),
  slash commands, powerline statusline, MCP servers (context7 + the others once
  their prereqs are in place), account integrations, and reinstalled plugins/skills.

---

## Known follow-ups

- `~/zelda.sh` (used by the `link-package` aliases) is **not** in this repo — it's
  obsolete since the monorepo move. See the ConPort TODO to relocate it to a
  personal repo, or drop the dead aliases from `.zshrc`.
- `nvim/.lazygit_config.yml` is a stray duplicate of the root `.lazygit_config.yml`
  (the nvim integration uses `~/.lazygit_config.yml`); safe to delete.
- Per-context **work** git identity (`~/.ssh/prof.conf`, applied under `~/projects/`)
  is not written by `setup.sh` — set it up manually.
