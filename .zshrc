# Load environment variables
if [ -f ~/.env ]; then
    source ~/.env
fi


alias vim=nvim
alias rm=trash
alias cat="bat --theme=\$(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alF --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias l='eza -F --icons --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'
alias ps='procs'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias editshellconfig='vim ~/.zshrc'
alias edittermconfig='vim ~/.config/ghostty/config'
alias link-package='~/zelda.sh link'
alias unlink-package='~/zelda.sh unlink'
alias link-status='~/zelda.sh status'

export LANG=en_US.UTF-8


set -o vi


ZIM_HOME=~/.zim
ZIM_CONFIG_FILE=~/.config/.zimrc
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

eval "$(tinty init)" >/dev/null 2>&1
eval "$(starship init zsh)"
source <(fzf --zsh)
eval "$(command fnm env --use-on-cd --log-level quiet)" &> /dev/null
alias nvm=fnm
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init zsh)"
alias zcli='cd ~/projects/desktop-app/apps/cli'
alias zclient='cd ~/projects/desktop-app/apps/client'

cc() {
  if [ ! -d ".devcontainer" ]; then
    echo "Error: No .devcontainer/ directory found in $(pwd)" >&2
    return 1
  fi
  echo "Starting devcontainer..."
  devcontainer up --workspace-folder . && \
  devcontainer exec --workspace-folder . zsh -ic "claude --dangerously-skip-permissions"
}
