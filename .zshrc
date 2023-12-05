#======================================================================#
#	 __     ___  __      __   __   __   ___  __
#	|__) | |__  |__)    /  ` /  \ |  \ |__  |__)
#	|    | |___ |  \    \__, \__/ |__/ |___ |  \
#
#	My .zshrc file for MacOs
#======================================================================#



#----------------------------------------------------------------------#
# Default stuff
#----------------------------------------------------------------------#
# Correctly display UTF-8 with combining characters.
if [[ "$(locale LC_CTYPE)" == "UTF-8" ]]; then
    setopt COMBINING_CHARS
fi

# Disable the log builtin, so we don't conflict with /usr/bin/log
disable log

# Save command history
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=2000
SAVEHIST=1000

# Beep on error
setopt BEEP

# Use keycodes (generated via zkbd) if present, otherwise fallback on
# values from terminfo
if [[ -r ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR} ]] ; then
    source ${ZDOTDIR:-$HOME}/.zkbd/${TERM}-${VENDOR}
else
    typeset -g -A key

    [[ -n "$terminfo[kf1]" ]] && key[F1]=$terminfo[kf1]
    [[ -n "$terminfo[kf2]" ]] && key[F2]=$terminfo[kf2]
    [[ -n "$terminfo[kf3]" ]] && key[F3]=$terminfo[kf3]
    [[ -n "$terminfo[kf4]" ]] && key[F4]=$terminfo[kf4]
    [[ -n "$terminfo[kf5]" ]] && key[F5]=$terminfo[kf5]
    [[ -n "$terminfo[kf6]" ]] && key[F6]=$terminfo[kf6]
    [[ -n "$terminfo[kf7]" ]] && key[F7]=$terminfo[kf7]
    [[ -n "$terminfo[kf8]" ]] && key[F8]=$terminfo[kf8]
    [[ -n "$terminfo[kf9]" ]] && key[F9]=$terminfo[kf9]
    [[ -n "$terminfo[kf10]" ]] && key[F10]=$terminfo[kf10]
    [[ -n "$terminfo[kf11]" ]] && key[F11]=$terminfo[kf11]
    [[ -n "$terminfo[kf12]" ]] && key[F12]=$terminfo[kf12]
    [[ -n "$terminfo[kf13]" ]] && key[F13]=$terminfo[kf13]
    [[ -n "$terminfo[kf14]" ]] && key[F14]=$terminfo[kf14]
    [[ -n "$terminfo[kf15]" ]] && key[F15]=$terminfo[kf15]
    [[ -n "$terminfo[kf16]" ]] && key[F16]=$terminfo[kf16]
    [[ -n "$terminfo[kf17]" ]] && key[F17]=$terminfo[kf17]
    [[ -n "$terminfo[kf18]" ]] && key[F18]=$terminfo[kf18]
    [[ -n "$terminfo[kf19]" ]] && key[F19]=$terminfo[kf19]
    [[ -n "$terminfo[kf20]" ]] && key[F20]=$terminfo[kf20]
    [[ -n "$terminfo[kbs]" ]] && key[Backspace]=$terminfo[kbs]
    [[ -n "$terminfo[kich1]" ]] && key[Insert]=$terminfo[kich1]
    [[ -n "$terminfo[kdch1]" ]] && key[Delete]=$terminfo[kdch1]
    [[ -n "$terminfo[khome]" ]] && key[Home]=$terminfo[khome]
    [[ -n "$terminfo[kend]" ]] && key[End]=$terminfo[kend]
    [[ -n "$terminfo[kpp]" ]] && key[PageUp]=$terminfo[kpp]
    [[ -n "$terminfo[knp]" ]] && key[PageDown]=$terminfo[knp]
    [[ -n "$terminfo[kcuu1]" ]] && key[Up]=$terminfo[kcuu1]
    [[ -n "$terminfo[kcub1]" ]] && key[Left]=$terminfo[kcub1]
    [[ -n "$terminfo[kcud1]" ]] && key[Down]=$terminfo[kcud1]
    [[ -n "$terminfo[kcuf1]" ]] && key[Right]=$terminfo[kcuf1]
fi

# Default key bindings
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search

# Useful support for interacting with Terminal.app or other terminal programs
[ -r "/etc/zshrc_$TERM_PROGRAM" ] && . "/etc/zshrc_$TERM_PROGRAM"
#----------------------------------------------------------------------#



#----------------------------------------------------------------------#
# Auto completion
#----------------------------------------------------------------------#
zstyle ':completion:*' menu select

zstyle ':completion::complete:*' gain-privileges 1
#----------------------------------------------------------------------#



#----------------------------------------------------------------------#
# My prompt
#----------------------------------------------------------------------#
# Default prompt
#PS1="%n@%m %1~ %# "

PROMPT="%B%F{yellow}[%f%F{cyan}%~%f%F{yellow}]%f%F{red}▶%f%b "
RPROMPT="%B%F{yellow}[%f%F{cyan}%*%f%F{yellow}]%f%b"
#----------------------------------------------------------------------#



#----------------------------------------------------------------------#
# Aliases
#----------------------------------------------------------------------#
alias ll='eza -alhg --icons'

alias myip="curl http://ipecho.net/plain; echo"

alias gitup='git add . && git commit -m "Update: $(date)" && git push'

alias brewup='brew update && brew upgrade && brew doctor && brew cleanup'

alias cleanup='sudo periodic daily weekly monthly'

alias reboot='sudo reboot'
alias shutdown='sudo shutdown -h now'

alias monitorcpumem='sudo htop'
alias monitornet='sudo jnettop'
alias monitordisk='sudo ncdu /'
#----------------------------------------------------------------------#



#----------------------------------------------------------------------#
# Functions
#----------------------------------------------------------------------#
function hunt {
    find / -iname "*$1*" 2>/dev/null
}
#----------------------------------------------------------------------#



#----------------------------------------------------------------------#
# Load the prompt theme system
#----------------------------------------------------------------------#
autoload -Uz compinit
compinit

# First you need to install zsh-syntax-highlighting:
# brew install zsh-syntax-highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#----------------------------------------------------------------------#



#----------------------------------------------------------------------#
# pnpm 
#----------------------------------------------------------------------#
export PNPM_HOME="/Users/pier/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
#----------------------------------------------------------------------#



#----------------------------------------------------------------------#
# starship prompt
#----------------------------------------------------------------------#
eval "$(starship init zsh)"
#----------------------------------------------------------------------#


