#!/bin/bash
#
# Fresh-machine bootstrap. Assumes a clean macOS install — existing real
# configs at the target paths below should be backed up/removed first, since
# this replaces them with symlinks into the dotfiles repo.

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Git identity ----------------------------------------------------------
# Identity is kept OUT of the tracked .gitconfig (it's shared across machines).
# It lives in ~/.ssh/priv.conf, which the tracked .gitconfig includes globally.
read -p "Enter Git Author Name: " GIT_AUTHOR_NAME
read -p "Enter Git Author Email: " GIT_AUTHOR_EMAIL
read -p "Enter Git Username: " gitUsername

if [ -n "$GIT_AUTHOR_NAME" ] || [ -n "$GIT_AUTHOR_EMAIL" ]; then
    mkdir -p "$HOME/.ssh"
    cat > "$HOME/.ssh/priv.conf" <<EOF
[user]
	name = $GIT_AUTHOR_NAME
	email = $GIT_AUTHOR_EMAIL
EOF
    echo "Wrote git identity to ~/.ssh/priv.conf"
fi

# --- SSH key ---------------------------------------------------------------
if [ -n "$GIT_AUTHOR_EMAIL" ]; then
    echo "Generating SSH Key..."
    ssh-keygen -t rsa -C "$GIT_AUTHOR_EMAIL"
    eval "$(ssh-agent -s)"
    touch "$HOME/.ssh/config"
    echo "Host *" >> "$HOME/.ssh/config"
    echo " AddKeysToAgent yes" >> "$HOME/.ssh/config"
    echo " UseKeychain yes" >> "$HOME/.ssh/config"
    echo " IdentityFile ~/.ssh/id_rsa" >> "$HOME/.ssh/config"
    ssh-add --apple-use-keychain "$HOME/.ssh/id_rsa"
    if [ -n "$gitUsername" ] && [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        echo "Add this SSH Public Key on GitHub: https://github.com/settings/keys"
        echo "Copying SSH Public Key to Clipboard..."
        pbcopy < "$HOME/.ssh/id_rsa.pub"
    else
        echo "Cannot execute: pbcopy < $HOME/.ssh/id_rsa.pub"
        echo "Try to run this command manually"
    fi
else
    echo "No SSH Key configured due to missing Git User Email!"
fi

mkdir -p "$HOME/Desktop/Screenshots"

# --- Symlink tracked configs into place (idempotent on re-run) -------------
link() {
    mkdir -p "$(dirname "$2")"
    ln -sfn "$1" "$2"
}

link "$DOTFILES_DIR/.zshrc"                       "$HOME/.zshrc"
link "$DOTFILES_DIR/.gitconfig"                   "$HOME/.gitconfig"
link "$DOTFILES_DIR/.delta_themes.gitconfig"      "$HOME/.delta_themes.gitconfig"
link "$DOTFILES_DIR/.lazygit_config.yml"          "$HOME/.lazygit_config.yml"
link "$DOTFILES_DIR/.macos"                       "$HOME/.macos"
link "$DOTFILES_DIR/.config/.zimrc"               "$HOME/.config/.zimrc"
link "$DOTFILES_DIR/.config/starship.toml"        "$HOME/.config/starship.toml"
link "$DOTFILES_DIR/.config/ghostty"              "$HOME/.config/ghostty"
link "$DOTFILES_DIR/.config/tinted-theming"       "$HOME/.config/tinted-theming"
link "$DOTFILES_DIR/nvim"                         "$HOME/.config/nvim"
link "$DOTFILES_DIR/claude/commands"              "$HOME/.claude/commands"
link "$DOTFILES_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
link "$DOTFILES_DIR/AGENTS.md"                    "$HOME/.claude/CLAUDE.md"

# --- Claude Code MCP servers (user scope: available across all projects) ---
# context7 + chrome-devtools are self-contained (npx). conport and
# codebase-memory-mcp need prerequisites installed first — see BOOTSTRAP.md;
# they're registered here regardless and connect once their backends exist.
add_mcp() {
    local name="$1"; shift
    if claude mcp get "$name" >/dev/null 2>&1; then
        echo "MCP '$name' already configured (skipping)"
    else
        claude mcp add --scope user "$name" -- "$@" && echo "Added MCP '$name'"
    fi
}

if command -v claude >/dev/null 2>&1; then
    add_mcp context7 npx -y @upstash/context7-mcp
    add_mcp chrome-devtools npx -y chrome-devtools-mcp@0.24.0 \
        "--browser-url=${CHROME_BROWSER_URL:-http://127.0.0.1:9222}"
    # Prereq: github.com/DeusData/codebase-memory-mcp binary in ~/.local/bin
    add_mcp codebase-memory-mcp "$HOME/.local/bin/codebase-memory-mcp"
    # Prereq: uv (Brewfile) + ~/.config/opencode/conport-wrapper.py + data dir
    add_mcp conport uvx --from context-portal-mcp python \
        "$HOME/.config/opencode/conport-wrapper.py" --mode stdio \
        --log-level INFO --base-path "$HOME/.config/opencode/conport"
else
    echo "claude CLI not found — skipping MCP registration"
fi
