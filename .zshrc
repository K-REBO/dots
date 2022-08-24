HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

autoload -U compinit promptinit
compinit
promptinit; prompt gentoo
zstyle ':completion::complete:*' use-cache 1



## complettion

source ~/.config/dots/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source ~/.config/dots/zsh/zsh-syntax-highlighting.sh
source ~/.config/dots/zsh/complettions/*

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[globbing]='none'



bindkey -e
bindkey "^U" backward-kill-line

alias less="less -R"
alias xcopy="xsel --clipboard --input"
alias xpaste="xsel --clipboard --output"


alias ls="exa"
alias l="ls"
alias l1="exa -1"
alias la="exa -a"
alias ll="exa -l -h -@ -m --time-style=iso"
alias lla="exa -lh@ma --time-style=iso"
alias lal="exa -lh@ma --time-style=iso"
alias z="zoxide"
alias dust="dust -r"
alias br="broot"


alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias .......="cd ../../../../.."



eval "$(zoxide init zsh)"
eval "$(mcfly init zsh)"
eval "$(gh completion -s zsh)"



export RUSTC_WRAPPER=(which sccache)


fortune | cowsay -f ghostbusters
figlet  Ghost Busters!



eval "$(starship init zsh)"
