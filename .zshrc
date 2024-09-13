#======================================================================#
#   __     ___  __      __   __   __   ___  __
#   |__) | |__  |__)    /  ` /  \ |  \ |__  |__)
#   |    | |___ |  \    \__, \__/ |__/ |___ |  \
#
#   My optimized .zshrc file for MacOS with enhanced functions and aliases
#======================================================================#


#----------------------------------------------------------------------#
# Environment Settings and Initial Configurations
#----------------------------------------------------------------------#

# Ensure UTF-8 is correctly displayed
if [[ "$(locale LC_CTYPE)" == "UTF-8" ]]; then
    setopt COMBINING_CHARS
fi

# Disable conflicting log builtin
disable log

# Command history settings
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=5000
SAVEHIST=2000
setopt INC_APPEND_HISTORY       # Immediately append to history file
setopt SHARE_HISTORY            # Share command history across terminals
setopt HIST_IGNORE_DUPS         # Don't store duplicate commands
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks

# Beep on error
setopt BEEP

# Better autocomplete settings
autoload -Uz compinit
compinit -C                    # Speed up autocomplete caching

# Terminal key bindings
if [[ -r ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR} ]]; then
    source ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR}
else
    typeset -g -A key

    # Extract keybindings from terminfo
    for k in {F1..F12} kbs kich1 kdch1 khome kend kpp knp kcuu1 kcub1 kcud1 kcuf1; do
        [[ -n "$terminfo[$k]" ]] && key[$k]=$terminfo[$k]
    done
fi

# Key bindings for navigation
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search

# Autocomplete settings
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

# Source terminal-specific configurations
[ -r "/etc/zshrc_$TERM_PROGRAM" ] && source "/etc/zshrc_$TERM_PROGRAM"

#----------------------------------------------------------------------#
# Prompt and Appearance
#----------------------------------------------------------------------#

# Default prompt using Starship if available
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    PROMPT="%B%F{yellow}[%f%F{cyan}%~%f%F{yellow}]%f%F{red}▶%f%b "
    RPROMPT="%B%F{yellow}[%f%F{cyan}%*%f%F{yellow}]%f%b"
fi

# Syntax highlighting (use lazy loading for better performance)
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#----------------------------------------------------------------------#
# Aliases
#----------------------------------------------------------------------#

# Check if eza exists, otherwise fallback to ls
if command -v eza &> /dev/null; then
    alias ll='eza -alhg --icons'
else
    alias ll='ls -alh'
fi

# System aliases
alias gitup='git add . && git commit -m "Update: $(date)" && git push'
alias brewup='brew update && brew upgrade && brew doctor && brew cleanup'
alias cleanup='sudo periodic daily weekly monthly'
alias reboot='sudo reboot'
alias shutdown='sudo shutdown -h now'
alias reload='source ~/.zshrc'

# Network aliases
alias localip="ipconfig getifaddr en0"
alias publicip="curl ifconfig.me"
alias netinfo="ifconfig -a"

# Sustem monitor aliases
alias sysmon=top -l 1 | grep -E "^CPU|^PhysMem"

#----------------------------------------------------------------------#
#  Functions
#----------------------------------------------------------------------#

# Find Files by Name
function f() {
    find . -name "$1"
}

# Search Command History
function hgrep() {
    history | grep "$1"
}

# Copy Last Command to Clipboard
function clast() {
    fc -ln -1 | pbcopy
}

# Quick Note Taking
function note() {
    echo "$(date): $1" >> ~/notes.txt
    echo "Note added!"
}

# Find Open Ports
function openports() {
    sudo lsof -i -P -n | grep LISTEN
}

# Timer Function
function timer() {
    local T=$1
    echo "Timer set for $T seconds."
    sleep $T && echo "Time's up!"
}

#----------------------------------------------------------------------#
# Path and Environment Variables
#----------------------------------------------------------------------#

# Add PNPM to PATH
export PNPM_HOME="/Users/pier/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

#----------------------------------------------------------------------#
# Utility and Performance Settings
#----------------------------------------------------------------------#

# Faster directory navigation with autojump
if command -v autojump &> /dev/null; then
    . $(brew --prefix autojump)/share/autojump/autojump.zsh
fi

# Enable globbing for better wildcard expansion
setopt EXTENDED_GLOB

# Faster startup by deferring the loading of some plugins
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git cvs svn

#----------------------------------------------------------------------#
# Plugins and Additional Configurations
#----------------------------------------------------------------------#

# Load auto-suggestions if available
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load the Starship prompt if installed
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi
