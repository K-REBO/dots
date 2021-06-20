# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [ $UID -eq 0 ]; then
    PS1="\[\033[31m\]\u@\h\[\033[00m\]:\[\033[01m\]\w\[\033[00m\]\\$ "
else
    PS1="\[\033[36m\]\u@\h\[\033[00m\]:\[\033[01m\]\w\[\033[00m\]\\$ "
fi




if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# alias
alias ls=ls --color=auto


# Put your fun stuff here.
source "$HOME/.cargo/env"
export PATH="$PATH:$HOME/.local/bin"

source /home/bido/.config/broot/launcher/bash/br

# Wasmer
export WASMER_DIR="/home/bido/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"
export XAUTHORITY=~/.Xauthority

export PATH="$HOME/.deno/bin:$PATH"

# source <(silver init)

fish
