export GPG_TTY=$(tty)

gpg-connect-agent /bye
gpg-connect-agent updatestartuptty /bye > /dev/null

function restart_gpg {
	# Point the SSH_AUTH_SOCK to the one handled by gpg-agent
	if [ -S "$(gpgconf --list-dirs agent-ssh-socket)" ]; then
		export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
	else
		echo "$(gpgconf --list-dirs agent-ssh-socket) doesn't exist. Is gpg-agent running?"
	fi
}
restart_gpg
