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
setopt pipefail                # fail pipeline if any command fails (zsh-native form)
setopt magicequalsubst         # expand ~ and vars in VAR=~/path
setopt auto_pushd pushd_ignore_dups pushd_silent
setopt prompt_subst            # allow substitutions in PROMPT / RPROMPT
setopt RM_STAR_WAIT            # prompt safeguard for `rm *`

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
setopt share_history           # share history across sessions
[[ -f $HISTFILE ]] || { umask 077; : >| "$HISTFILE"; }
chmod 600 "$HISTFILE" 2>/dev/null

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

autoload -Uz compinit compaudit
zmodload zsh/complist

: ${XDG_CACHE_HOME:=$HOME/Library/Caches}
ZCOMPDIR="$XDG_CACHE_HOME/zsh"
mkdir -p "$ZCOMPDIR" "$XDG_CACHE_HOME/zsh/cached-completions"
ZCOMPDUMP="$ZCOMPDIR/zcompdump-${ZSH_VERSION}-${HOST}"

# Weekly compaudit + cached compinit (safe perms fix)
(){
  local tsfile="$ZCOMPDIR/.compaudit.timestamp"
  local now=$(date +%s)
  local last=0
  [[ -e $tsfile ]] && last=$(stat -f %m "$tsfile" 2>/dev/null || echo 0)
  if (( now - last >= 604800 )); then
    local d
    for d in ${(f)"$(compaudit 2>/dev/null)"}; do
      [[ -O $d ]] || continue
      [[ -d $d ]] && chmod g-w,o-w "$d" 2>/dev/null
      [[ -f $d ]] && chmod go-w    "$d" 2>/dev/null
    done
    : >| "$tsfile"
  fi
  compinit -C -d "$ZCOMPDUMP"
  chmod 600 "$ZCOMPDUMP" 2>/dev/null
}

# Completion styles
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/cached-completions"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
# Use LS_COLORS/LSCOLORS if available
if [[ -n $LS_COLORS ]]; then
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
elif [[ -n $LSCOLORS ]]; then
  zstyle ':completion:*' list-colors ${(s.:.)LSCOLORS}
fi
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=** r:|=**'
zstyle ':completion:*' rehash yes
zstyle ':completion:*' completer _extensions _complete _ignored _approximate
zstyle ':completion:*:approximate:*' max-errors '2'
zstyle ':completion:*:sudo:*' command-path \
  /opt/homebrew/sbin /opt/homebrew/bin /usr/local/sbin /usr/local/bin \
  /usr/sbin /usr/bin /sbin /bin ~/.local/bin

# Show dotfiles in completion
_comp_options+=(globdots)

#-------------------------- Key bindings (terminfo) ---------------------------#
bindkey -e
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
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

[[ -t 1 ]] && stty -ixon 2>/dev/null

#-------------------------------- Prompt --------------------------------------#
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  PROMPT='%B%F{yellow}[%f%F{cyan}%~%f%F{yellow}]%f%(?.. %F{red}✗%?%f) %F{red}▶%f%b '
  RPROMPT="%F{8}%D{%F %T}%f"
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

alias ..='cd ..'
alias ...='cd ../..'
alias cd-='cd -'
alias d='dirs -v'

please() {
  local last; last=$(fc -ln -1) || return
  [[ -z $last ]] && return
  print -z -- $([[ $last == sudo\ * ]] && echo "$last" || echo "sudo $last")
}

if [[ -o interactive ]] && command -v bat &>/dev/null; then
  alias cat='bat'
fi

gitup() {
  git rev-parse --is-inside-work-tree &>/dev/null || { echo "Not in a git repo"; return 1; }
  git add -A && git commit -m "Update: $(date +'%F %T')" && git push
}
alias brewup='brew update && brew upgrade && brew autoremove && brew cleanup && { brew doctor || true; }'
alias reload='source ${ZDOTDIR:-$HOME}/.zshrc'

if [[ -z ${VIRTUAL_ENV:-} ]]; then
  alias pip='python3 -m pip'
  alias pip3='python3 -m pip'
fi
if [[ -z ${VIRTUAL_ENV:-} ]]; then
  command -v pipx &>/dev/null && export PIPX_DEFAULT_PYTHON="$(command -v python3)"
  if command -v uv &>/dev/null; then
    alias pip='uv pip'
    alias pip3='uv pip'
    export UV_PYTHON="$(command -v python3)"
    alias pipp='python3 -m pip'
    alias pip.py='python3 -m pip'
  fi
fi

#------------------------------ Helper Commands -------------------------------#
localip() {
  local iface; iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
  [[ -n $iface ]] && ipconfig getifaddr "$iface" 2>/dev/null || ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null
}
publicip() { dig +short -4 txt ch whoami.cloudflare @1.1.1.1 | tr -d '"' || printf '\n'; }
alias netinfo='ifconfig -a'
alias sysmon='top -l 1 | grep -E "^CPU|^PhysMem"'
alias sysmonlive='top -l 0 -stats pid,command,cpu,mem -o cpu'
psx() { pgrep -lf "$@"; }
alias htop='command -v htop >/dev/null && command htop || top'

f() { find . -type f -iname "${1:-*}" -not -path "*/.git/*"; }
hgrep() { [[ -n $1 ]] || { echo "usage: hgrep <pattern>"; return 1; }; fc -l 1 | grep -i -- "$1"; }
clast() { fc -ln -1 | pbcopy; }
note() { mkdir -p ~/Notes; printf '%s %s\n' "$(date +'%F %T')" "$*" >> ~/Notes/notes.txt && echo "Note added!"; }
openports() { sudo lsof -iTCP -sTCP:LISTEN -P -n; }
timer() { local T=${1:-0}; echo "Timer set for $T seconds."; ( sleep "$T" && osascript -e 'beep' && osascript -e 'display notification "Time'\''s up!" with title "Zsh"' ) & }

extract() {
  local f=$1
  [[ -f $f ]] || { echo "'$f' is not a valid file"; return 1; }
  case $f in
    *.tar.bz2|*.tbz2) tar xjf "$f" ;;
    *.tar.gz|*.tgz)   tar xzf "$f" ;;
    *.tar.xz)         tar xJf "$f" ;;
    *.tar.zst)
      if tar --help 2>&1 | grep -q zstd; then
        tar --zstd -xf "$f"
      else
        command -v unzstd &>/dev/null && unzstd -c "$f" | tar xf - || \
          echo "Need tar with zstd or unzstd"
      fi
      ;;
    *.zst)            unzstd "$f" ;;
    *.xz)             xz -d "$f" ;;
    *.bz2)            bunzip2 "$f" ;;
    *.gz)             gunzip "$f" ;;
    *.tar)            tar xf "$f" ;;
    *.zip)            ditto -xk -- "$f" . ;;
    *.7z)             command -v 7z &>/dev/null && 7z x "$f" || echo "7z not installed" ;;
    *.rar)            command -v unrar &>/dev/null && unrar x "$f" || echo "unrar not installed" ;;
    *.Z)              uncompress "$f" ;;
    *)                echo "Cannot extract $f"; return 1 ;;
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

#----------------------------- FZF helpers ------------------------------------#
if command -v fzf &>/dev/null; then
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height=80% --border --info=inline --prompt='❯ ' --marker='*'"
  [[ -n $TMUX ]] && export FZF_TMUX=1

fhistory() {
  fc -rl 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | awk '!seen[$0]++' | fzf --tac | read -r sel || return
  print -z -- "$sel"
}
  fcd() {
    local dir
    dir=$(find . -name .git -prune -o -name node_modules -prune -o -type d -print 2>/dev/null | fzf) || return
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
reveal() { open -R -- "${1:A:-.}"; }
cpath() { printf %s "$PWD${1:+/$1}" | pbcopy; echo "Copied: $(pbpaste)"; }
odl() { local f=~/Downloads/*(Nom[-1]); [[ -n $f ]] && open -R "$f" || echo "No recent download"; }
alias o.='open .'

#---------------------------- PATH & Environment ------------------------------#
export PNPM_HOME="$HOME/Library/pnpm"

if [[ -z ${PY_USER_BASE:-} ]] && command -v python3 &>/dev/null; then
  PY_USER_BASE=$(python3 - <<'PY' 2>/dev/null
import site,sys; sys.stdout.write(site.USER_BASE)
PY
)
fi

path=(
  /opt/homebrew/bin /opt/homebrew/sbin
  /usr/local/bin /usr/local/sbin
  $path
)
[[ -n $PNPM_HOME && -d $PNPM_HOME ]] && path=($PNPM_HOME $path)
[[ -n $PY_USER_BASE && -d $PY_USER_BASE/bin ]] && path=($PY_USER_BASE/bin $path)

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"

#--------------------------- Plugins (interactive only) -----------------------#
if [[ -o interactive ]]; then
  ZSH_AUTOSUGGEST_USE_ASYNC=1
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50000

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