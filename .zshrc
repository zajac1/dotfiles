# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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

export LANG=en_US.UTF-8


set -o vi


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

ZIM_HOME=~/.zim
ZIM_CONFIG_FILE=~/.config/.zimrc
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
source <(fzf --zsh)
eval "$(command fnm env --use-on-cd)"
