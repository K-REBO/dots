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

alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."


zoxide init fish  | source
mcfly init fish | source
fortune | cowsay -f tux

starship init fish | source
