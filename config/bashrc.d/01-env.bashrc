export BASH_SILENCE_DEPRECATION_WARNING=1

# Color man pages.
export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_se=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_ue=$(tput sgr0)
export LESS_TERMCAP_us=$(tput bold; tput setaf 2)

export CLICOLOR=1
export TERM=xterm-256color
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=
export HOMEBREW_NO_ANALYTICS=1

export EDITOR="$(command -v vim)"

export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

if [ ! -d "$(go env GOROOT)" ]; then
	export GOROOT="${HOME}/go"
fi
export GOPATH="${HOME}/gopath"
export GOBIN="${GOPATH}/bin"
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export PSQLRC="${XDG_CONFIG_HOME}/pg/psqlrc"
export PSQL_HISTORY="${XDG_CACHE_HOME}/pg/psql_history"
export PGPASSFILE="${XDG_CONFIG_HOME}/pg/pgpass"
export PGSERVICEFILE="${XDG_CONFIG_HOME}/pg/pg_service.conf"
export PARALLEL_HOME="${XDG_CONFIG_HOME}/parallel"
export SQLITE_HISTORY="${XDG_DATA_HOME}/sqlite_history"
export NODE_REPL_HISTORY="${XDG_DATA_HOME}/node_repl_history"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export LESSKEY="${XDG_CONFIG_HOME}/less/lesskey"
export LESSHISTFILE="${XDG_CACHE_HOME}/less/history"
export MINISIGN_CONFIG_DIR="${XDG_DATA_HOME}/minisign"
