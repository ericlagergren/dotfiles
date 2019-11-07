alias sudo='sudo -E '
alias git='gpg --card-status &>/dev/null ; git '

alias rgi='rg -i '
alias rgg='rg --type=go '
alias rgig='rgg -i '
alias rgc='rg --type=c '
alias rgic='rgc -i '
alias ag='rgi '

alias ls='ls -G'
alias h?='history | grep -i '

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'

alias pong="ping 8.8.8.8 -c 4"

alias gprof='go tool pprof -http :9999 '
alias gtrace='go tool trace '
