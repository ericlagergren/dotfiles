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
	"${GOPATH}/bin"
	"${GOPATH}/pkg"
	"${GOPATH}/mod"
	"${GOPATH}/src"
	"${XDG_CONFIG_HOME}"
	"${XDG_CACHE_HOME}"
	"${XDG_DATA_HOME}"
	"${XDG_CACHE_HOME}/vim/temp"
	"${XDG_CACHE_HOME}/vim/undo"
	"${XDG_CACHE_HOME}/vim/backup"
)

for path in "${paths[@]}"
do
	mkdir -p "${path}"
done

for path in "${cfg_root}/"*
do
	ln -vFfs "${path}" "${XDG_CONFIG_HOME}"
done

cat << 'EOF' > "${HOME}/.bashrc"
dir=
if [ ! -z "${XDG_CONFIG_HOME}" ]; then
	dir="${XDG_CONFIG_HOME}/bashrc.d"
else
	dir="${HOME}/.config/bashrc.d"
fi
for f in ${dir}/*.bashrc
do
	. "${f}"
done
EOF

if [ ! -f "${HOME}/.local/bin/prompt" ]; then
	pushd prompt
	make install && make clean
	popd
fi
