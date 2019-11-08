#!/usr/bin/env bash

set -xeuo pipefail

cfg_root="${PWD}/config"

# /etc/bashrc might break -u
set +u
. "${cfg_root}/bashrc.d/00-init.bashrc"
set -u

declare -a paths=(
	"${HOME}/.local/bin"
	"${HOME}/.local/lib"
	"${XDG_CONFIG_HOME}/npm"
	"${XDG_DATA_HOME}/gopath/pkg"
	"${XDG_DATA_HOME}/gopath/src"
	"${XDG_CACHE_HOME}/go/mod"
	"${XDG_CACHE_HOME}/vim/temp"
	"${XDG_CACHE_HOME}/vim/undo"
	"${XDG_CACHE_HOME}/vim/backup"
	"${XDG_CONFIG_HOME}"
	"${XDG_CACHE_HOME}"
	"${XDG_DATA_HOME}"
)

for path in "${paths[@]}"
do
	mkdir -p "${path}"
done

# Copy over our defaults.
for path in "${cfg_root}/"*
do
	if [[ $(basename "${path}") == ".DS_store" ]]; then
		continue
	fi
	ln -vFfs "${path}" "${XDG_CONFIG_HOME}"
done

# Link {.config,.cache} to XDG_{CONFIG,CACHE}_HOME just in case a program tries
# to use .config or .cache.
ln -vs "${XDG_CONFIG_HOME}" "${HOME}/.config" || true
ln -vs "${XDG_CACHE_HOME}" "${HOME}/.cache" || true

# Set up some symlinks for Go.
ln -vFfs "${XDG_DATA_HOME}/gopath" "${HOME}"
ln -vFfs "${XDG_CACHE_HOME}/go/mod" "${GOPATH}/pkg"
ln -vFfs "${HOME}/.local/bin" $(dirname "${GOBIN}")

cat << 'EOF' > "${HOME}/.bashrc"
dir=
if [ ! -z "${XDG_CONFIG_HOME}" ]; then
	dir="${XDG_CONFIG_HOME}/bashrc.d"
else
	dir="${HOME}/.config/bashrc.d"
fi
for f in "${dir}/"*.bashrc
do
	. "${f}"
done
EOF

if [ ! -f "${HOME}/.local/bin/prompt" ]; then
	pushd prompt
	make install && make clean
	popd
fi
