# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

EDITOR=vim
VISUAL=gvim
PAGER='less -i'

# append to the history file, don't overwrite it
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s histappend # Append to the Bash history file, rather than overwriting it
shopt -s extglob    # extended pattern matching features
shopt -s cdspell    # correct dir spelling errors on cd
shopt -s lithist    # save multi-line commands with newlines
shopt -s autocd     # if a command is a dir name, cd to it
shopt -s checkjobs  # print warning if jobs are running on shell exit
shopt -s dirspell   # correct dir spelling errors on completion
shopt -s globstar   # ** matches all files, dirs and subdirs
shopt -s cmdhist    # save multi-line commands in a single hist entry
shopt -s cdable_vars # if cd arg is not a dir, assume it is a var
shopt -s checkwinsize # check the window size after each command
shopt -s no_empty_cmd_completion # don't try to complete empty cmds

if [ -f ~/bin/sensible.bash ]; then
   source ~/bin/sensible.bash
fi

# enable coloured man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
 
# define some colours
GREY=$'\033[30m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
WHITE=$'\033[37m'
NONE=$'\033[m'
BRIGHT=$'\033[1m'
DIM=$'\033[1m'

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

[ -z "$TMUX" ] && export TERM=xterm-256color

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
    xterm-256color) color_prompt=yes;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

if [ -f ~/.homebrew ]; then
    . ~/.homebrew
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ $(uname) = "Darwin" ]; then
    source /usr/local/etc/bash_completion.d/git-completion.bash
fi

source ~/.bash-git-prompt/gitprompt.sh
TAB_TITLE="\[\e]0;\u@\h: \w\a\]"
GIT_PROMPT_THEME=Default
GIT_PROMPT_COMMAND_OK=""
GIT_PROMPT_COMMAND_FAIL="${BRIGHT}${RED}✘-_LAST_COMMAND_STATE_${NONE} "
GIT_PROMPT_START_USER="${TAB_TITLE}\n_LAST_COMMAND_INDICATOR_${GREEN}\u@\h:${NONE} ${YELLOW}\w${NONE}"
GIT_PROMPT_START_ROOT="${GIT_PROMPT_START_USER}"

export EDITOR='gvim -f'

export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh

export PATH=$PATH:/usr/local/sbin:~/bin

if [ $(uname) = "Darwin" ]; then
    archey
else
    uname -snrvm
fi
