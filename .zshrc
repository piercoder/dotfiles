###############################################################################
# zshrc-macos — Zsh for macOS
# Author: Pierpaolo Pattitoni (@piercoder)
###############################################################################

#############################################
# 0) GUARD & SPEED: interactive only + speedups
#############################################
# Only run interactively.
[[ -o interactive ]] || return

# Optional: quick profiling toggle (set ZPROF=1 to profile a session)
(( $+ZPROF )) && zmodload zsh/zprof

# Preload modules we use (slightly faster than autoload at first hit)
zmodload zsh/complist zsh/system zsh/datetime

# Use a versioned compdump for safer/faster completion caching
ZDOTDIR=${ZDOTDIR:-$HOME}
ZSH_COMPDUMP="$ZDOTDIR/.zcompdump-$ZSH_VERSION"

#############################################
# 1) BASICS: options, history, locale, editor
#############################################
setopt AUTO_CD EXTENDED_GLOB GLOB_DOTS NO_NOMATCH CORRECT INTERACTIVE_COMMENTS NOTIFY
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY INC_APPEND_HISTORY

HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=300000
SAVEHIST=300000
export HISTTIMEFORMAT="[%F %T] "

export LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8"
export EDITOR="nvim"; export VISUAL="$EDITOR"; export PAGER="less -R"

# Better less defaults (quit if one screen, preserve screen, raw color)
export LESS='-R -F -X'
export COLORTERM=truecolor

#############################################
# 2) HOMEBREW, PATHS, MANPATH
#############################################
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  BREW_PREFIX="/opt/homebrew"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
  BREW_PREFIX="/usr/local"
fi

# Helpers to keep PATH tidy (no dupes)
pathprepend() { [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$1:${PATH}"; }
pathappend()  { [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="${PATH}:$1"; }

# Prefer GNU tools if installed
if [[ -n "$BREW_PREFIX" ]]; then
  for pkg in coreutils grep gnu-sed gnu-tar; do
    pathprepend "$BREW_PREFIX/opt/$pkg/libexec/gnubin"
    [[ -d "$BREW_PREFIX/opt/$pkg/libexec/gnuman" ]] && MANPATH="$BREW_PREFIX/opt/$pkg/libexec/gnuman:$MANPATH"
  done
fi

# Common dev bins
for p in "$HOME/.local/bin" "$HOME/bin" "$HOME/.cargo/bin" "$HOME/go/bin" "$HOME/.dotnet/tools"; do
  pathprepend "$p"
done
export PATH MANPATH

#############################################
# 3) COMPLETION: cached, fuzzy, pretty
#############################################
autoload -Uz compinit
# -C skip function check (speed); -i ignore insecure dirs; -d specify dump file
compinit -C -i -d "$ZSH_COMPDUMP"

# Brew completions
if [[ -n "$BREW_PREFIX" && -d "$BREW_PREFIX/share/zsh-completions" ]]; then
  fpath=("$BREW_PREFIX/share/zsh-completions" $fpath)
fi

# Styles: menu selection, case-insensitive + separator‑smart matching, colors
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

#############################################
# 4) PROMPT: fast + async-ish Git status
#############################################
autoload -Uz colors; colors
setopt PROMPT_SUBST

# --- Async-ish Git: compute branch/status in background so prompt never blocks ---
# Use floats for time math to avoid "number truncated after 19 digits" warnings.
typeset -g __GIT_ASYNC __GIT_ASYNC_PTS
__GIT_ASYNC=""
__GIT_ASYNC_PTS=0.0

_git_status_async() {
  local -F now=$EPOCHREALTIME
  (( now - __GIT_ASYNC_PTS < 0.5 )) && return   # throttle to once per 0.5s
  __GIT_ASYNC_PTS=$now
  {
    local dir branch dirty
    dir=$(git rev-parse --git-dir 2>/dev/null) || { print -r -- "" >| "$ZDOTDIR/.git_async.$$"; exit 0; }
    branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    git diff --quiet --ignore-submodules HEAD 2>/dev/null; local changed=$?
    git diff --cached --quiet --ignore-submodules 2>/dev/null; local staged=$?
    dirty=""
    (( staged )) && dirty+="*"
    (( changed )) && dirty+="+"
    print -r -- "(${branch}${dirty})" >| "$ZDOTDIR/.git_async.$$"
  } &!
}

_git_status_read() {
  local f; f=("$ZDOTDIR"/.git_async.*(Nom[1]))
  [[ -n "$f" ]] && __GIT_ASYNC="$(<"$f")"
}

precmd_functions+=(_git_status_async _git_status_read)# --- Async-ish Git: compute branch/status in background so prompt never blocks ---
# Use floats for time math to avoid "number truncated after 19 digits" warnings.
typeset -g __GIT_ASYNC __GIT_ASYNC_PTS
__GIT_ASYNC=""
__GIT_ASYNC_PTS=0.0

_git_status_async() {
  local -F now=$EPOCHREALTIME
  (( now - __GIT_ASYNC_PTS < 0.5 )) && return   # throttle to once per 0.5s
  __GIT_ASYNC_PTS=$now
  {
    local dir branch dirty
    dir=$(git rev-parse --git-dir 2>/dev/null) || { print -r -- "" >| "$ZDOTDIR/.git_async.$$"; exit 0; }
    branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    git diff --quiet --ignore-submodules HEAD 2>/dev/null; local changed=$?
    git diff --cached --quiet --ignore-submodules 2>/dev/null; local staged=$?
    dirty=""
    (( staged )) && dirty+="*"
    (( changed )) && dirty+="+"
    print -r -- "(${branch}${dirty})" >| "$ZDOTDIR/.git_async.$$"
  } &!
}

_git_status_read() {
  local f; f=("$ZDOTDIR"/.git_async.*(Nom[1]))
  [[ -n "$f" ]] && __GIT_ASYNC="$(<"$f")"
}

precmd_functions+=(_git_status_async _git_status_read)

# Exit code + time on the right
prompt_exit_code() { [[ $RETVAL -ne 0 ]] && print -n "%F{red}✖ $RETVAL%f "; }
prompt_precmd() { RETVAL=$?; }
precmd_functions+=(prompt_precmd)

# Final prompts
PROMPT='%F{cyan}%n%f@%F{magenta}%m%f %F{yellow}%~%f %F{green}${__GIT_ASYNC}%f
%F{blue}❯%f '
RPROMPT='$(prompt_exit_code)%F{240}%*%f'

#############################################
# 5) KEYBINDINGS: macOS-friendly nav
#############################################
bindkey -e
bindkey "^[b" backward-word
bindkey "^[f" forward-word
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "$key[Up]"   up-line-or-beginning-search
bindkey "$key[Down]" down-line-or-beginning-search

#############################################
# 6) ALIASES: smart ls, safety, git
#############################################
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto'
  alias tree='eza -T'
elif command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias ll='lsd -lah'
  alias tree='lsd --tree'
else
  alias ls='ls -GF'
  alias ll='ls -lahGF'
  alias tree='find . -print | sed -e "s;[^/]*/;|____;g;s;____|; |;g"'
fi

alias cp='cp -i'; alias mv='mv -i'; alias rm='rm -i'
alias ..='cd ..'; alias ...='cd ../..'; alias ~='cd ~'
alias grep='grep --color=auto'; alias df='df -h'; alias du='du -h'
alias o='open'; alias c='clear'
# Git
alias gs='git status -sb'; alias ga='git add'
alias gc='git commit -v';  alias gcm='git commit -m'
alias gp='git push';       alias gpf='git push --force-with-lease'
alias gl='git log --oneline --graph --decorate'
alias gb='git branch -vv'; alias gco='git checkout'; alias gcb='git checkout -b'

#############################################
# 7) FUNCTIONS: daily work helpers
#############################################
mkcd() { mkdir -p "$1" && cd "$1"; }
serve() { python3 -m http.server "${1:-8000}"; }
extract() {
  [[ -f "$1" ]] || { echo "extract: '$1' is not a file"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;; *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;; *.tar) tar xf "$1" ;;
    *.bz2) bunzip2 "$1" ;; *.gz) gunzip "$1" ;; *.xz) unxz "$1" ;;
    *.zip) unzip "$1" ;; *.rar) unrar x "$1" ;; *.7z) 7z x "$1" ;;
    *) echo "extract: unknown archive format" ;;
  esac
}
myip() { curl -s https://ifconfig.me || curl -s https://api.ipify.org; echo; }
gitup() {
  # Check if we're inside a git repo
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "%F{red} Not in a Git repository%f"
    return 1
  fi

  local msg="Update: $(date +'%F %T')"

  echo "%F{yellow} Staging changes...%f"
  git add -A || return 1

  echo "%F{blue} Committing:%f %F{cyan}$msg%f"
  if ! git commit -m "$msg"; then
    echo "%F{magenta} Nothing to commit%f"
    return 1
  fi

  echo "%F{green} Pushing...%f"
  git push
}
#############################################
# 8) TOOLCHAINS: version managers (auto-detect)
#############################################
# asdf (unified)
if command -v asdf >/dev/null 2>&1; then
  # Try common locations (Homebrew or default)
  [[ -n "$BREW_PREFIX" && -s "$BREW_PREFIX/opt/asdf/libexec/asdf.sh" ]] && . "$BREW_PREFIX/opt/asdf/libexec/asdf.sh"
  [[ -s "$HOME/.asdf/asdf.sh" ]] && . "$HOME/.asdf/asdf.sh"
fi
# pyenv
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
  eval "$(pyenv init -)"
fi
# rbenv
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi
# Node: prefer nodenv; fallback to nvm
if command -v nodenv >/dev/null 2>&1; then
  eval "$(nodenv init -)"
elif [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  export NVM_DIR="$HOME/.nvm"
  . "$HOME/.nvm/nvm.sh"
fi

#############################################
# 9) macOS niceties: direnv, clipboard, color
#############################################
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
pbcopyf() { command pbcopy < "$1"; }

#############################################
# 10) OPTIONAL BOOSTS: fzf, zoxide, bat, ripgrep
#############################################
# fzf (keybindings + completion)
if command -v fzf >/dev/null 2>&1; then
  # Use Ripgrep for CTRL-T sources if available
  if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  # Homebrew install locations
  [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh"    ]] && source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
fi

# zoxide (smarter cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# bat as nicer pager if present (keeps less flags via --pager)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

#############################################
# 11) TMUX: auto-attach on login shells (optional)
#############################################
if command -v tmux >/dev/null 2>&1; then
  if [[ -z "$TMUX" && "$-:" == *i* && -o login ]]; then
    tmux attach -t main 2>/dev/null || tmux new -s main
  fi
fi

#############################################
# 12) PER-PROJECT HOOKS (SAFE): chpwd trigger
#############################################
# Run a project-local hook "./.shellrc" ONLY if trusted:
#   - owned by you
#   - NOT world-writable
#   - has a sibling file ".shellrc.trust" you created manually
# This avoids auto-sourcing arbitrary code.
_chpwd_project_hook() {
  local hook="./.shellrc" trust="./.shellrc.trust"
  [[ -f "$hook" && -f "$trust" ]] || return 0
  # ensure ownership and permissions
  [[ -O "$hook" && ! -w /dev/stdout ]] >/dev/null 2>&1
  if [[ $(stat -f '%Su' "$hook") == "$USER" ]] && [[ $(stat -f '%Mp%Lp' "$hook") != *2 ]]; then
    source "$hook"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _chpwd_project_hook
# Run once for initial directory
_chpwd_project_hook

#############################################
# 13) MACHINE-SPECIFIC OVERRIDES
#############################################
# Put any machine-only stuff in ~/.zshrc.local (ignored if absent).
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

#############################################
# 14) BYTE-COMPILE: speed up future shells
#############################################
# Compile this file once per change; ignore errors
if [[ "$ZDOTDIR/.zshrc.zwc" -ot "$ZDOTDIR/.zshrc" ]]; then
  zcompile -R -- "$ZDOTDIR/.zshrc.zwc" "$ZDOTDIR/.zshrc" 2>/dev/null || true
fi

#############################################
# 15) WRAP-UP: optional profile summary
#############################################
(( $+ZPROF )) && { echo; echo "===== zprof ====="; zprof; }

#############################################
# 16) ROOT PROMPT WARNING (with Git info)
#############################################
if [[ $EUID -eq 0 ]]; then
  PROMPT='%F{red}%n%f@%F{magenta}%m%f %F{yellow}%~%f %F{red}${__GIT_ASYNC}%f %# '
  RPROMPT='%F{red}⚠ ROOT ⚠%f'
fi