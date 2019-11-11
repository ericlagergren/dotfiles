#[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/fzf.bash" ] && \
#	. "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/fzf.bash"

ITERM2_SQUELCH_MARK=1
[ -f "${XDG_CONFIG_HOME}/iTerm2/iterm2_shell_integration.bash" ] && \
	. "${XDG_CONFIG_HOME}/iTerm2/iterm2_shell_integration.bash"

eval "$(direnv hook bash)"
