if [ -x /usr/libexec/path_helper ]; then
    eval `/usr/libexec/path_helper -s`
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Correct small errors in directory names passed to cd.
shopt -s cdspell
# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize
# Check that hashed commands still exist before running them
shopt -s checkhash
# Put multi-line commands into one history entry
shopt -s cmdhist
# Include filenames with leading dots in pattern matching
shopt -s dotglob
# Extended pattern matching.
shopt -s extglob
# Append history to $HISTFILE instead of overwriting it
shopt -s histappend
# If history expansion fails, reload the command to try again
shopt -s histreedit
# Load history expansion result as the next command, don't run them directly
shopt -s histverify
# Don't assume a word with a @ in it is a hostname
shopt -u hostcomplete
# Don't change newlines to semicolons in history
shopt -s lithist
# Don't try to tell me when my mail is read
shopt -u mailwarn
# Don't complete a Tab press on an empty line with every possible command
shopt -s no_empty_cmd_completion
# Use programmable completion, if available
shopt -s progcomp
# Warn when shifting nonexistent values off an array.
shopt -s shift_verbose
# Don't search $PATH to find files for the `source` builtin
shopt -u sourcepath

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"

export PATH="${PATH}:/sbin"
export PATH="${PATH}:/usr/local/sbin"
export PATH="${PATH}:${HOME}/bin"
export PATH="${PATH}:${HOME}/.local/bin"
export PATH="${PATH}:/usr/local/go/bin"
export PATH="${PATH}:${GOBIN}"

export HISTFILE="${XDG_CACHE_HOME}/.bash_history"
if [ ! -z "${ITERM_SESSION_ID}" ]; then
	HISTFILE="${HISTFILE}_${ITERM_SESSION_ID%:*}"
fi
export HISTCONTROL=ignoredups:ignorespace
export HISTFILESIZE=100000
export HISTSIZE=100000
