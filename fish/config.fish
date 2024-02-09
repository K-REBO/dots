alias less="less -R"
alias xcopy="xsel --clipboard --input"
alias xpaste="xsel --clipboard --output"


alias ls="eza"
alias l="ls"
alias l1="eza -1"
alias la="eza -a"
alias ll="eza -l -h -@ -m --time-style=iso"
alias lla="eza -lh@ma --time-style=iso"
alias lal="eza -lh@ma --time-style=iso"
alias z="zoxide"
alias dust="dust -r"
# alias br="broot"



alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias .......="cd ../../../../.."


# https://github.com/soimort/translate-shell
alias trans "docker run -it soimort/translate-shell -shell"


zoxide init fish  | source
mcfly init fish | source
gh completion -s fish | source


# export RUSTC_WRAPPER=(which sccache)


bash ~/.config/dots/installedPackages/autoAdd.sh


starship init fish | source
