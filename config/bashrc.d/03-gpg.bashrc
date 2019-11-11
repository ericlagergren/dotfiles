export GPG_TTY=$(tty)
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"

gpg-connect-agent /bye
gpg-connect-agent updatestartuptty /bye > /dev/null

function start_gpg {
	# Point the SSH_AUTH_SOCK to the one handled by gpg-agent
	if [ -S "$(gpgconf --list-dirs agent-ssh-socket)" ]; then
		export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
	else
		echo "$(gpgconf --list-dirs agent-ssh-socket) doesn't exist. Is gpg-agent running?"
	fi
}
start_gpg

function restart_gpg {
	pkill gpg ; gpg --card-status &> /dev/null
	start_gpg
}

