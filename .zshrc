###############################################################################
# zshrc-macos — Lean & Fast Zsh for macOS
# Author: Pierpaolo Pattitoni (@piercoder)
# License: MIT
###############################################################################

#------------------------- Environment & options ------------------------------#
# UTF-8 combining chars (only if terminal actually uses UTF-8)
if [[ ${LC_CTYPE:-$LANG} == *UTF-8* ]]; then
  setopt COMBINING_CHARS
fi

# Safer defaults / QoL
setopt PIPE_FAIL               # fail a pipeline if any command fails
setopt INTERACTIVE_COMMENTS    # allow # comments at prompt
setopt PROMPT_SP               # fix wide char spacing in prompt

# History: robust & low-noise
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=5000
SAVEHIST=2000
setopt INC_APPEND_HISTORY
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_VERIFY
setopt HIST_SAVE_NO_DUPS       # don't save duplicates
setopt HIST_FIND_NO_DUPS       # up/down search skips dup hits

setopt NO_BEEP
setopt EXTENDED_GLOB

# Apple per-terminal defaults (loads keymap & paths)
[[ -r "/etc/zshrc_$TERM_PROGRAM" ]] && source "/etc/zshrc_$TERM_PROGRAM"

# Deduplicate PATH/FPATH as we prepend things later
typeset -U path fpath

#------------------------------ Completion -----------------------------------#
# Homebrew's zsh completions must be on fpath BEFORE compinit
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
[[ -d /usr/local/share/zsh/site-functions   ]] && fpath=(/usr/local/share/zsh/site-functions   $fpath)

autoload -Uz compinit
zmodload zsh/complist

# Cache compinit and completion results for speed
: ${XDG_CACHE_HOME:=$HOME/Library/Caches}
ZCOMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${ZCOMPDUMP:h}"

# Prefer fixing perms (compaudit) once; avoid -i if your dirs are secure
compinit -d "$ZCOMPDUMP"

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/cached-completions"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
# subtle colors for completion listings (mac lscolors compatible)
zstyle ':completion:*' list-colors ''

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
if [[ -o interactive ]]; then
  alias rm='rm -I'    # prompt once if removing >3 files
  alias mv='mv -i'
  alias cp='cp -i'
fi

if command -v eza &>/dev/null; then
  alias ll='eza -alhg --icons'
  alias la='eza -A'
  alias l='eza -1'
else
  alias ll='ls -alhG' # -G for color on macOS
  alias la='ls -A'
  alias l='ls -1G'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias cd-='cd -'

# Prefer bat if available without breaking cat
command -v bat &>/dev/null && alias cat='bat'

gitup() { git add -A && git commit -m "Update: $(date +'%F %T')" && git push; }
alias brewup='brew update && brew upgrade && brew autoremove && brew cleanup && brew doctor'
alias reload='source ~/.zshrc'

# Safer system helpers
localip() { ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null; }
publicip() { curl -fsS https://ifconfig.me; echo; }
alias netinfo='ifconfig -a'
alias sysmon='top -l 1 | grep -E "^CPU|^PhysMem"'
psx() { pgrep -af -- "$@"; }
htop() { command -v htop &>/dev/null && command htop || top; }

#------------------------------ Functions ------------------------------------#
f() { find . -type f -iname "${1:-*}" -not -path "*/.git/*"; }
hgrep() { [[ -n $1 ]] || { echo "usage: hgrep <pattern>"; return 1; }; fc -l 1 | grep -i -- "$1"; }
clast() { fc -ln -1 | pbcopy; }
note() { mkdir -p ~/Notes; printf '%s %s\n' "$(date +'%F %T')" "$*" >> ~/Notes/notes.txt && echo "Note added!"; }
openports() { sudo lsof -iTCP -sTCP:LISTEN -P -n; }
timer() { local T=${1:-0}; echo "Timer set for $T seconds."; ( sleep "$T" && osascript -e 'display notification "Time'"'"'s up!" with title "Zsh"' ) & }

extract() {
  local f=$1
  [[ -f $f ]] || { echo "'$f' is not a valid file"; return 1; }
  case $f in
    *.tar.bz2|*.tbz2) tar xjf -- "$f" ;;
    *.tar.gz|*.tgz)   tar xzf -- "$f" ;;
    *.tar.xz)         tar xJf -- "$f" ;;
    *.xz)             xz -d -- "$f" ;;
    *.bz2)            bunzip2 -- "$f" ;;
    *.gz)             gunzip -- "$f" ;;
    *.tar)            tar xf -- "$f" ;;
    *.zip)            unzip -q -- "$f" ;;
    *.7z)             command -v 7z &>/dev/null && 7z x -- "$f" || echo "7z not installed" ;;
    *.rar)            command -v unrar &>/dev/null && unrar x -- "$f" || echo "unrar not installed" ;;
    *.Z)              uncompress -- "$f" ;;
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
  fhistory() {
    local sel; sel=$(fc -rl 1 | fzf) || return
    print -z -- "${sel##* }"
  }
  fcd() {
    local dir
    dir=$(find . -type d -not -path "*/.git/*" -maxdepth 6 2>/dev/null | fzf) || return
    cd -- "$dir"
  }
  # Optional: quiet default fzf noise
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height=80% --border"
fi

#---------------------------- PATH & env -------------------------------------#
# Homebrew paths
[[ -d /opt/homebrew/bin  ]] && path=(/opt/homebrew/bin  $path)
[[ -d /opt/homebrew/sbin ]] && path=(/opt/homebrew/sbin $path)
[[ -d /usr/local/bin     ]] && path=(/usr/local/bin     $path)
[[ -d /usr/local/sbin    ]] && path=(/usr/local/sbin    $path)

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
[[ -d $PNPM_HOME ]] && path=($PNPM_HOME $path)

# Python user base (version-agnostic)
PY_USER_BASE=$(python3 -c 'import site,sys; sys.stdout.write(site.USER_BASE)' 2>/dev/null)
[[ -n $PY_USER_BASE && -d $PY_USER_BASE/bin ]] && path=($PY_USER_BASE/bin $path)

# zoxide / direnv
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"

#--------------------------- Plugins (interactive) ----------------------------#
if [[ -o interactive ]]; then
  # zsh-autosuggestions
  [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

  # zsh-syntax-highlighting should be last
  [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#------------------------ Extra machine-specific ------------------------------#
[[ -x ~/dotfiles/infomac ]] && ~/dotfiles/infomac

#------------------------------ Optional: zcompile ----------------------------#
# (Uncomment to precompile at first start; re-run when this file changes)
# [[ -w $ZDOTDIR/.zshrc.zwc ]] || { autoload -Uz zrecompile && zrecompile -p ${ZDOTDIR:-$HOME}/.zshrc; }