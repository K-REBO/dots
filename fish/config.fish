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


function fish_greeting
	fortune | cowsay -f ghostbusters
	figlet  Ghost Busters!
	echo "🐟"
end

bash ~/.config/dots/installedPackages/autoAdd.sh


starship init fish | source
