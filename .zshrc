#======================================================================#
#    __     ___  __      __   __   __   ___  __
#   |__) | |__  |__)    /  ` /  \ |  \ |__  |__)
#   |    | |___ |  \    \__, \__/ |__/ |___ |  \
#
#   My optimized .zshrc file for macOS with enhanced functions and aliases
#======================================================================#

#----------------------------------------------------------------------#
# Environment Settings and Initial Configurations
#----------------------------------------------------------------------#

if [[ "$(locale LC_CTYPE)" == "UTF-8" ]]; then
    setopt COMBINING_CHARS
fi

disable log

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=5000
SAVEHIST=2000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt BEEP

autoload -Uz compinit
compinit -C
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

if [[ -r ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR} ]]; then
    source ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR}
else
    typeset -g -A key
    for k in {F1..F12} kbs kich1 kdch1 khome kend kpp knp kcuu1 kcub1 kcud1 kcuf1; do
        [[ -n "$terminfo[$k]" ]] && key[$k]=$terminfo[$k]
    done
fi

[[ -n ${key[Delete]} ]]   && bindkey "${key[Delete]}" delete-char
[[ -n ${key[Home]} ]]     && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[End]} ]]      && bindkey "${key[End]}" end-of-line
[[ -n ${key[Up]} ]]       && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Down]} ]]     && bindkey "${key[Down]}" down-line-or-search

[ -r "/etc/zshrc_$TERM_PROGRAM" ] && source "/etc/zshrc_$TERM_PROGRAM"

#----------------------------------------------------------------------#
# Prompt and Appearance
#----------------------------------------------------------------------#

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    PROMPT="%B%F{yellow}[%f%F{cyan}%~%f%F{yellow}]%f%F{red}▶%f%b "
    RPROMPT="%B%F{yellow}[%f%F{cyan}%*%f%F{yellow}]%f%b"
fi

if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#----------------------------------------------------------------------#
# Aliases
#----------------------------------------------------------------------#

if command -v eza &> /dev/null; then
    alias ll='eza -alhg --icons'
else
    alias ll='ls -alh'
fi

alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias cd-='cd -'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias cat='bat' # use bat if installed, otherwise cat
command -v bat &>/dev/null || alias bat='cat'

alias gitup='git add . && git commit -m "Update: $(date)" && git push'
alias brewup='brew update && brew upgrade && brew autoremove && brew cleanup && brew doctor'
alias cleanup='sudo periodic daily weekly monthly'
alias reboot='sudo reboot'
alias shutdown='sudo shutdown -h now'
alias reload='source ~/.zshrc'

alias localip="ipconfig getifaddr en0"
alias publicip="curl ifconfig.me"
alias netinfo="ifconfig -a"
alias sysmon='top -l 1 | grep -E "^CPU|^PhysMem"'

alias psx='ps aux | grep'
alias htop='htop || top'

#----------------------------------------------------------------------#
# Functions
#----------------------------------------------------------------------#

f() { find . -name "$1"; }
hgrep() { history | grep "$1"; }
clast() { fc -ln -1 | pbcopy; }
note() {
    echo "$(date): $1" >> ~/notes.txt
    echo "Note added!"
}
openports() { sudo lsof -i -P -n | grep LISTEN; }
timer() {
    local T=$1
    echo "Timer set for $T seconds."
    sleep $T && echo "Time's up!"
}
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "Cannot extract $1" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
notify() {
    "$@" && osascript -e 'display notification "Command completed!" with title "ZSH"'
}

# Fuzzy finder for files and history (requires fzf)
if command -v fzf &> /dev/null; then
    fhistory() { print -z "$(history | fzf)"; }
    fcd() { cd "$(find . -type d | fzf)"; }
fi

#----------------------------------------------------------------------#
# Path and Environment Variables
#----------------------------------------------------------------------#

export PNPM_HOME="$HOME/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# zoxide (jump between directories)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# direnv (project-specific environment)
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

#----------------------------------------------------------------------#
# Utility and Performance Settings
#----------------------------------------------------------------------#

setopt EXTENDED_GLOB

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git cvs svn

#----------------------------------------------------------------------#
# Plugins and Additional Configurations
#----------------------------------------------------------------------#

if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi