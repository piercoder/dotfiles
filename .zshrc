###############################################################################
# zshrc-macos — Lean & Fast Zsh for macOS
# Author: Pierpaolo Pattitoni (@piercoder) — refined for performance and safety
# License: MIT
###############################################################################

#------------------------- Environment & options ------------------------------#
# UTF-8 combining chars (only if terminal actually uses UTF-8)
[[ "$(locale LC_CTYPE)" == "UTF-8" ]] && setopt COMBINING_CHARS

# History: robust & low-noise
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=5000
SAVEHIST=2000
setopt INC_APPEND_HISTORY        # append immediately
setopt INC_APPEND_HISTORY_TIME   # include timestamps
setopt EXTENDED_HISTORY          # :start:elapsed;command
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_VERIFY
# setopt SHARE_HISTORY           # disable unless you truly want cross-shell mixing
setopt NO_BEEP
setopt EXTENDED_GLOB

# Apple’s per-terminal defaults (loads keymap & paths)
[ -r "/etc/zshrc_$TERM_PROGRAM" ] && source "/etc/zshrc_$TERM_PROGRAM"

#------------------------------ Completion -----------------------------------#
autoload -Uz compinit
zmodload zsh/complist
# Prefer safe init; run `compaudit` once to fix perms and you can drop `-i`
compinit -i
zstyle ':completion:*' menu select
# This is a risky style; remove to avoid root escalation prompts in completion
# zstyle ':completion::complete:*' gain-privileges 1

#-------------------------- Key bindings (terminfo) ---------------------------#
if [[ -r ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR} ]]; then
  source ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR}
else
  typeset -g -A key
  for k in {F1..F12} kbs kich1 kdch1 khome kend kpp knp kcuu1 kcub1 kcud1 kcuf1; do
    [[ -n "$terminfo[$k]" ]] && key[$k]=$terminfo[$k]
  done
fi
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[Home]}   ]] && bindkey "${key[Home]}"   beginning-of-line
[[ -n ${key[End]}    ]] && bindkey "${key[End]}"    end-of-line
[[ -n ${key[Up]}     ]] && bindkey "${key[Up]}"     up-line-or-search
[[ -n ${key[Down]}   ]] && bindkey "${key[Down]}"   down-line-or-search

#-------------------------------- Prompt -------------------------------------#
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  PROMPT="%B%F{yellow}[%f%F{cyan}%~%f%F{yellow}]%f%F{red}▶%f%b "
  RPROMPT="%B%F{yellow}[%f%F{cyan}%*%f%F{yellow}]%f%b"
fi

#------------------------------- Aliases -------------------------------------#
# Use interactive-guarded aliases (don’t affect scripts)
if [[ -o interactive ]]; then
  alias rm='rm -i'
  alias mv='mv -i'
  alias cp='cp -i'
fi

if command -v eza &>/dev/null; then
  alias ll='eza -alhg --icons'
else
  alias ll='ls -alh'
fi
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias cd-='cd -'

# Prefer bat if available without breaking cat
if command -v bat &>/dev/null; then
  alias cat='bat'
fi

alias gitup='git add . && git commit -m "Update: $(date)" && git push'
alias brewup='brew update && brew upgrade && brew autoremove && brew cleanup && brew doctor'
alias reload='source ~/.zshrc'

# Safer system helpers
localip() { ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null; }
publicip() { curl -fsS https://ifconfig.me; echo; }
alias netinfo='ifconfig -a'
alias sysmon='top -l 1 | grep -E "^CPU|^PhysMem"'
psx() { pgrep -af "$@"; }
htop() { command -v htop &>/dev/null && command htop || top; }

#------------------------------ Functions ------------------------------------#
f() { find . -type f -iname "${1:-*}" -not -path "*/.git/*"; }
hgrep() { fc -l 1 | grep -i -- "$1"; }
clast() { fc -ln -1 | pbcopy; }
note() { mkdir -p ~/Notes; printf '%s %s\n' "$(date +'%F %T')" "$*" >> ~/Notes/notes.txt && echo "Note added!"; }
openports() { sudo lsof -i -P -n | grep LISTEN; }
timer() { local T=${1:-0}; echo "Timer set for $T seconds."; sleep "$T" && echo "Time's up!"; }
extract() {
  local f=$1
  [[ -f $f ]] || { echo "'$f' is not a valid file"; return 1; }
  case $f in
    *.tar.bz2|*.tbz2) tar xjf "$f" ;;
    *.tar.gz|*.tgz)   tar xzf "$f" ;;
    *.tar.xz)         tar xJf "$f" ;;
    *.xz)             xz -d "$f" ;;
    *.bz2)            bunzip2 "$f" ;;
    *.gz)             gunzip "$f" ;;
    *.tar)            tar xf "$f" ;;
    *.zip)            unzip "$f" ;;
    *.7z)             command -v 7z &>/dev/null && 7z x "$f" || echo "7z not installed" ;;
    *.rar)            command -v unrar &>/dev/null && unrar x "$f" || echo "unrar not installed" ;;
    *.Z)              uncompress "$f" ;;
    *)                echo "Cannot extract $f" ;;
  esac
}
notify() {
  if "$@"; then
    osascript -e 'display notification "Command completed!" with title "Zsh"'
  else
    osascript -e 'display notification "Command failed." with title "Zsh"'
    return 1
  fi
}

# fzf helpers (if installed)
if command -v fzf &>/dev/null; then
  fhistory() { print -z -- "$(fc -rl 1 | fzf | sed 's/^[ 0-9]*\**[  ]*//')"; }
  fcd() { cd "$(find . -type d -not -path "*/.git/*" -maxdepth 6 2>/dev/null | fzf)"; }
fi

#---------------------------- PATH & env -------------------------------------#
# Homebrew paths
[[ -d /opt/homebrew/bin ]] && path=(/opt/homebrew/bin $path)
[[ -d /usr/local/bin   ]] && path=(/usr/local/bin $path)

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
[[ -d $PNPM_HOME ]] && path=($PNPM_HOME $path)

# Python user base (version-agnostic)
PY_USER_BASE=$(python3 -c 'import site,sys; sys.stdout.write(site.USER_BASE)' 2>/dev/null)
[[ -n $PY_USER_BASE && -d $PY_USER_BASE/bin ]] && path=($PY_USER_BASE/bin $path)

# zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
# direnv
command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"

#--------------------------- Plugins (order!) ---------------------------------#
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# zsh-syntax-highlighting should be the LAST thing sourced in .zshrc
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#------------------------ Extra machine-specific ------------------------------#
if [[ -x ~/dotfiles/infomac ]]; then
  ~/dotfiles/infomac
fi