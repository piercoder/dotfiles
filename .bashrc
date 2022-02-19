#======================================================================#
#     mmmmm    "
#     #   "# mmm     mmm    m mm
#     #mmm#"   #    #"  #   #"  "
#     #        #    #""""   #
#     #      mm#mm  "#mm"   #
#
#     My .bashrc file
#======================================================================#

#----------------------------------------------------------------------#
# Definitions
#----------------------------------------------------------------------#
# Colors
RED='\033[01;31m'
BLUE='\033[01;34m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'
RESET='\033[00m'

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

#----------------------------------------------------------------------#
# Common stuff
#----------------------------------------------------------------------#
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Adjust the window size if needed
shopt -s checkwinsize

#----------------------------------------------------------------------#
# History management
#----------------------------------------------------------------------#
# Append to the history file, don't overwrite it
shopt -s histappend

# save multi-line commands in history as single line
shopt -s cmdhist

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth:erasedups

# History length
HISTSIZE=1000
HISTFILESIZE=2000

#----------------------------------------------------------------------#
# Prompt
#----------------------------------------------------------------------#
# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Force colored prompt, if the terminal has the capability
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# PS1
if [ "$color_prompt" = yes ]; then
    PS1="${debian_chroot:+($debian_chroot)}\[${YELLOW}\][\[${RESET}\]\[${BLUE}\]\w\[${RESET}\]\[${YELLOW}\]]\[${RESET}\]\[${GREEN}\]\$\[${RESET}\]\[${RED}\]>\[${RESET}\] "
else
    PS1='${debian_chroot:+($debian_chroot)}[\w]\$> '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

#----------------------------------------------------------------------#
# Path
#----------------------------------------------------------------------#
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

#----------------------------------------------------------------------#
# Programmable completion
#----------------------------------------------------------------------#
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#----------------------------------------------------------------------#
# Functions
#----------------------------------------------------------------------#
# Navigate n directory up
up () {
  local d=""
  local limit="$1"

  # Default to limit of 1
  if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
    limit=1
  fi

  for ((i=1;i<=limit;i++)); do
    d="../$d"
  done

  # perform cd. Show error if cd fails
  if ! cd "$d"; then
    echo "Couldn't go up $limit dirs.";
  fi
}

# Archive extraction
ex ()
{
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Clean removed package residual configuration files
cleanup ()
{
  sudo apt purge $(dpkg -l | grep "^rc" | awk '{print $2}')
  sudo apt autoremove
}

# Local and public IP
myip ()
{
  lIP="$(hostname -I | awk '{print $1}')"
  pIP="$(curl -s http://ipecho.net/plain)"

  echo -e "${RED}Local IP:${YELLOW} ${lIP}${RESET}"
  echo -e "${RED}Public IP:${YELLOW} ${pIP}${RESET}"
}

bak()
{
  for file in "$@"
  do
    cp -- "$file" "$file.$(date +%y%m%d%H%M%S).bak"
  done
}

#----------------------------------------------------------------------#
# Aliases
#----------------------------------------------------------------------#
# Check if an external file for aliases exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Other handy aliases
alias reboot='sudo reboot'

alias ll='ls -alh'

alias aptup='sudo apt update && sudo apt full-upgrade && sudo apt autoremove && flatpak update'

alias gitup='git add . && git commit -m "Update: $(date)" && git push'

#----------------------------------------------------------------------#
# Startup message
#----------------------------------------------------------------------#
#echo -e "Hi ${CYAN}${USER}${RESET}! I'm ${YELLOW}$(hostname)${RESET}. It's ${GREEN}$(date)${RESET}"
#echo ""

