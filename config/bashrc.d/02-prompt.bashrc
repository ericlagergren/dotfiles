function prompt {
	PS1=$("${HOME}/.local/bin/prompt" $? "${SHLVL}" "${SSH_TTY}")
}

PROMPT_DIRTRIM=3
export PROMPT_COMMAND=prompt
