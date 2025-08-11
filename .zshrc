###############################################################################
# zshrc-macos — Lean & Fast Zsh for macOS
# Author: Pierpaolo Pattitoni (@piercoder)
# License: MIT
###############################################################################

# Enable on-demand profiling when launched with ZPROF=1
[[ -n $ZPROF ]] && zmodload zsh/zprof

#------------------------- Environment & Options -----------------------------#
# Enable UTF-8 combining chars if terminal uses UTF-8
if [[ ${LC_CTYPE:-$LANG} == *UTF-8* ]]; then
  setopt combining_chars
fi

# Safety & convenience shell options
setopt noclobber               # prevent accidental overwrite with >
setopt interactive_comments    # allow # comments in interactive mode
set -o pipefail                 # fail pipeline if any command fails
setopt magicequalsubst          # expand ~ and vars in VAR=~/path
setopt auto_pushd pushd_ignore_dups pushd_silent

# History configuration
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=5000
SAVEHIST=2000
setopt inc_append_history
setopt inc_append_history_time
setopt extended_history
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt hist_verify
setopt hist_save_no_dups
setopt hist_find_no_dups
# [[ -f $HISTFILE ]] && chmod 600 "$HISTFILE"  # run once to secure history file

setopt no_beep
setopt extended_glob

# Load Apple's per-terminal defaults
[[ -r "/etc/zshrc_$TERM_PROGRAM" ]] && source "/etc/zshrc_$TERM_PROGRAM"

# Avoid duplicate path entries
typeset -U path fpath

#------------------------------ Completion -----------------------------------#
# Add Homebrew completions before compinit
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
[[ -d /usr/local/share/zsh/site-functions   ]] && fpath=(/usr/local/share/zsh/site-functions   $fpath)

autoload -Uz compinit
zmodload zsh/complist

: ${XDG_CACHE_HOME:=$HOME/Library/Caches}
ZCOMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${ZCOMPDUMP:h}"

# Load completions using cache only if valid
compinit -C -d "$ZCOMPDUMP"

# Completion styles
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/cached-completions"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=** r:|=**'
zstyle ':completion:*' completer _extensions _complete _approximate

# Keep completions after sudo
zstyle ':completion:*:sudo:*' command-path \
  /opt/homebrew/sbin /opt/homebrew/bin /usr/local/sbin /usr/local/bin \
  /usr/sbin /usr/bin /sbin /bin

# Show dotfiles in completion
_comp_options+=(globdots)

#-------------------------- Key bindings (terminfo) ---------------------------#
bindkey -e  # Emacs keymap

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

# Disable Ctrl-S / Ctrl-Q terminal freeze
[[ -t 1 ]] && stty -ixon 2>/dev/null

#-------------------------------- Prompt --------------------------------------#
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  PROMPT="%B%F{yellow}[%f%F{cyan}%~%f%F{yellow}]%f%F{red}▶%f%b "
  RPROMPT="%B%F{yellow}[%f%F{cyan}%*%f%F{yellow}]%f%b"
fi

# Report execution time for slow commands
export REPORTTIME=5
export TIMEFMT=$'%J\t%*E real\t%U user\t%S sys'

#------------------------------- Aliases --------------------------------------#
if [[ -o interactive ]]; then
  alias rm='rm -I'
  alias mv='mv -i'
  alias cp='cp -i'
  alias sudo='sudo '
fi

# Directory listing aliases
if command -v eza &>/dev/null; then
  alias ll='eza -alhg --icons'
  alias la='eza -A'
  alias l='eza -1'
else
  alias ll='ls -alhG'
  alias la='ls -A'
  alias l='ls -1G'
fi

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias cd-='cd -'
alias d='dirs -v'

# Re-run last command with sudo
alias please='sudo $(fc -ln -1)'

# Use bat instead of cat if available
command -v bat &>/dev/null && alias cat='bat'

# Git & brew shortcuts
gitup() { git add -A && git commit -m "Update: $(date +'%F %T')" && git push; }
alias brewup='brew update && brew upgrade && brew autoremove && brew cleanup && brew doctor'
alias reload='source ~/.zshrc'
alias pip='python3 -m pip'
alias pip3='python3 -m pip'

#------------------------------ Helper Commands -------------------------------#
localip() {
  local iface; iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
  [[ -n $iface ]] && ipconfig getifaddr "$iface" 2>/dev/null || ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null
}
publicip() { curl -fsS https://ifconfig.me || dig +short txt ch whoami.cloudflare @1.1.1.1; echo; }
alias netinfo='ifconfig -a'
alias sysmon='top -l 1 | grep -E "^CPU|^PhysMem"'
psx() { pgrep -lf -- "$@"; }
htop() { command -v htop &>/dev/null && command htop || top; }

f() { find . -type f -iname "${1:-*}" -not -path "*/.git/*"; }
hgrep() { [[ -n $1 ]] || { echo "usage: hgrep <pattern>"; return 1; }; fc -l 1 | grep -i -- "$1"; }
clast() { fc -ln -1 | pbcopy; }
note() { mkdir -p ~/Notes; printf '%s %s\n' "$(date +'%F %T')" "$*" >> ~/Notes/notes.txt && echo "Note added!"; }
openports() { sudo lsof -iTCP -sTCP:LISTEN -P -n; }
timer() { local T=${1:-0}; echo "Timer set for $T seconds."; ( sleep "$T" && osascript -e 'beep' && osascript -e 'display notification "Time'\''s up!" with title "Zsh"' ) & }

# Extract archives
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

# Run command and send macOS notification on completion
notify() {
  if "$@"; then
    osascript -e 'display notification "Command completed!" with title "Zsh"'
  else
    osascript -e 'display notification "Command failed." with title "Zsh"'
    return 1
  fi
}

#----------------------------- FZF helpers ------------------------------------#
if command -v fzf &>/dev/null; then
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height=80% --border"

  fhistory() {
    local sel; sel=$(fc -rl 1 | fzf) || return
    print -z -- "${sel##* }"
  }
  fcd() {
    local dir
    dir=$(find . -type d -not -path "*/.git/*" -maxdepth 6 2>/dev/null | fzf) || return
    cd -- "$dir"
  }
fi

#--------------------------- macOS convenience --------------------------------#
take() { mkdir -p -- "$1" && cd -- "$1"; }
cdf() {
  local d; d=$(osascript -e '
    tell app "Finder"
      if (count of windows) > 0 then
        POSIX path of (target of front window as alias)
      else
        POSIX path of (path to home folder as text)
      end if
    end tell' 2>/dev/null) || return
  cd -- "$d"
}
reveal() { open -R -- "${1:-.}"; }

#---------------------------- PATH & Environment ------------------------------#
[[ -d /opt/homebrew/bin  ]] && path=(/opt/homebrew/bin  $path)
[[ -d /opt/homebrew/sbin ]] && path=(/opt/homebrew/sbin $path)
[[ -d /usr/local/bin     ]] && path=(/usr/local/bin     $path)
[[ -d /usr/local/sbin    ]] && path=(/usr/local/sbin    $path)

export PNPM_HOME="$HOME/Library/pnpm"
[[ -d $PNPM_HOME ]] && path=($PNPM_HOME $path)

PY_USER_BASE=$(python3 -c 'import site,sys; sys.stdout.write(site.USER_BASE)' 2>/dev/null)
[[ -n $PY_USER_BASE && -d $PY_USER_BASE/bin ]] && path=($PY_USER_BASE/bin $path)

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"

#--------------------------- Plugins (interactive only) -----------------------#
if [[ -o interactive ]]; then
  [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#------------------------ Extra machine-specific ------------------------------#
[[ -x ~/dotfiles/infomac ]] && ~/dotfiles/infomac

#------------------------------ Optional: zcompile ----------------------------#
# autoload -Uz zrecompile
# zrecompile -p ${ZDOTDIR:-$HOME}/.zshrc 2>/dev/null

#------------------------------ Profiling output ------------------------------#
if [[ -n $ZPROF ]]; then
  zprof | tee "$HOME/.zsh.zprof.$(date +%s).txt"
fi