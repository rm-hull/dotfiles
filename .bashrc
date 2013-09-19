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
 
# enable coloured man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
 
# define some colours
GREY=$'\033[1;30m'
RED=$'\033[1;31m'
GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[1;34m'
MAGENTA=$'\033[1;35m'
CYAN=$'\033[1;36m'
WHITE=$'\033[1;37m'
NONE=$'\033[m'

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

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
     PS1='\[\e]0;\u@\h: \w\a\]\n\[\e[0;32m\]\u@\h \[\e[m\]\[\e[33m\]\w\[\e[0m\]\[\e[m\]\[\e[0;36m\] $(isgitrepo 2>&1 > /dev/null && git symbolic-ref HEAD | sed s%refs/heads/%%)\[\e[m\]\r\n\$ '
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi



export GDK_NATIVE_WINDOWS=1

export JAVA_HOME="/usr/lib/jvm/latest"
export JAVA_OPTS="-server -XX:+UseCompressedOops -XX:+AggressiveOpts -XX:+DoEscapeAnalysis"
#export JAVA_OPTS="-server -XX:+UseCompressedOops -XX:+AggressiveOpts -XX:+DoEscapeAnalysis -Xms128m -Xmx2048m -XX:MaxPermSize=256m -Dorg.jboss.resolver.warning=true -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000 -Djava.net.preferIPv4Stack=true"

export ANT_HOME="/usr/lib/java/apache-ant-1.8.2"
export MVN_HOME="/usr/lib/java/apache-maven-3.0.5"
export GROOVY_HOME="/usr/lib/java/groovy-2.0.0"
export GRAILS_HOME="/usr/lib/java/grails-1.3.7"
export JBOSS_HOME="/usr/lib/java/jboss-5.1.0.GA"
export TYPESAFE_HOME="/usr/lib/java/typesafe-stack"
export AKKA_HOME="/usr/lib/java/typesafe-stack"
export ANDROID_SDK_HOME="/usr/lib/java/android-sdk-linux"
export SMLNJ_HOME="/usr/local/sml-110.75"

PATH="$PATH:~/bin"
PATH="$PATH:$MVN_HOME/bin:$ANT_HOME/bin:$JAVA_HOME/bin"
PATH="$PATH:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools"
PATH="$PATH:$GROOVY_HOME/bin:$GRAILS_HOME/bin:$TYPESAFE_HOME/bin" 
PATH="$PATH:/usr/lib/java/eclipse"
PATH="$PATH:/usr/share/perforce/p4v-2010.1.256349/bin"
PATH="$PATH:$SMLNJ_HOME/bin"
PATH="$PATH:/usr/local/fritzing/latest"
export PATH

isgitrepo()
{
if git rev-parse  --git-dir 2>&1 > /dev/null ; then
  return 0
else
  return 1
fi
}

export PS1='\[\e]0;\u@\h: \w\a\]\n\[\e[0;32m\]\u@\h \[\e[m\]\[\e[33m\]\w\[\e[0m\]\[\e[m\]\[\e[0;36m\] $(isgitrepo 2>&1 > /dev/null && git symbolic-ref HEAD | sed s%refs/heads/%%)\[\e[m\]\r\n\$ '
export EDITOR='gvim -f'

export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh

uname -snrvm
