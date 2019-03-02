if [ -x /usr/libexec/path_helper ]; then
    eval `/usr/libexec/path_helper -s`
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

export HISTFILE=~/.bash_sessions/.bash_history_${ITERM_SESSION_ID%:*}

######################################
### SET PATHS AND EDITORS AND SUCH ###
######################################

# homebrew
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_NO_ANALYTICS=1

# Go
export GOPATH="${HOME}/gopath"
export GOBIN="${GOPATH}/bin"
export GO111MODULE=on

# Editors and such.
export EDITOR="$(which vim)"
export TEX_PATH=/Library/TeX/texbin
export MYSQL_BIN=/usr/local/mysql/bin

# PATH
export PATH="${PATH}:/sbin"
export PATH="${PATH}:/usr/local/sbin"
export PATH="${PATH}:${HOME}/bin"
export PATH="${PATH}:/usr/local/go/bin"
export PATH="${PATH}:${GOBIN}"
export PATH="${PATH}:${TEX_PATH}"
export PATH="${PATH}:${MYSQL_BIN}"

##############
#### GPG #####
##############

export GPG_TTY=$(tty)

gpg-connect-agent /bye
gpg-connect-agent updatestartuptty /bye > /dev/null

# Point the SSH_AUTH_SOCK to the one handled by gpg-agent
if [ -S $(gpgconf --list-dirs agent-ssh-socket) ]; then
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
else
  echo "$(gpgconf --list-dirs agent-ssh-socket) doesn't exist. Is gpg-agent running?"
fi

###############
### COLORS ####
###############

export CLICOLOR=1
export TERM=xterm-256color
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

function prompt {
	PS1=$("${HOME}/dotfiles/ps1" $? "${SHLVL}", "${SSH_TTY}")
}

PROMPT_DIRTRIM=3
export PROMPT_COMMAND=prompt

# Colored man pages:
export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_se=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_ue=$(tput sgr0)
export LESS_TERMCAP_us=$(tput bold; tput setaf 2)

###################
### SET ALIASES ###
###################

alias keyon='osascript -e '\''tell application "yubiswitch" to KeyOn'\'''
alias keyoff='osascript -e '\''tell application "yubiswitch" to KeyOff'\'''

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
alias myip='curl -s icanhazip.com'
alias gerp='grep'
alias tial='tail'
alias gpom='git push origin master'
alias lsa='ls -a'
alias lsal='ls -al'
alias lsl='ls -l'
alias nents='ls -1 | wc -l | sed "s#[[:space:]]##g"'

#################
### FUNCTIONS ###
#################

# Performs ls -l on cd

function cd {
    dir="${@:-$HOME}"  # ~ isn't expanded when in quotes
    [[ -z "${dir}" ]] && dir=~
    if ! builtin cd "$dir"; then
		dir=$(compgen -d "${dir}" | head -1)
        if builtin cd "$dir"; then
            clear ; pwd ;ls -l
        fi
    else
        clear ; pwd ; ls -l
    fi
}

ed() { command ed -p\* "$@" ; }

###########################################
## This does something important I think ##
###########################################

shopt -s extglob

# check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

[ -f ~/.fzf.bash ] && source ~/.fzf.bash