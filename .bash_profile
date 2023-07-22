# /etc/skel/.bash_profile

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
if [[ -f ~/.bashrc ]] ; then
	. ~/.bashrc
fi
. "$HOME/.cargo/env"

export GOPATH=$HOME/.go
export PATH=$GOROOT/bin:$PATH

#export FLYCTL_INSTALL="/home/bido/.fly"
#export PATH=$FLYCTL_INSTALL/bin:$PATH
