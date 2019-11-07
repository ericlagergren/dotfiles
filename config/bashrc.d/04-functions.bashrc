function tree_size {
	find -x . -type f -exec sh -c 'stat -f '%z' "${@}"' _ '{}' + | \
		LC_ALL=C awk -v pwd="${PWD}" '
		BEGIN{ sum=0; count=0; }
		{ sum+=$1; ++count; }
		END{ 
			if (count == 0) exit;
			printf ("directory: %s\n", pwd); 
			printf ("number of files: %d\n", count); 
			printf ("total size: %.f MiB\n", sum / (1024*1024))
			printf ("average file size: %.5f B\n", sum/count); 
			printf ("                 : %.5f kiB\n", (sum/count) / 1024); 
			printf ("                 : %.5f MiB\n", (sum/count) / (1024*1024)); 
		}
		'
}

function line {
	head -n+"${1}" < "${2}" | tail -1
}

# cd erforms ls -l on cd.
function cd {
    dir="${1:-$HOME}"  # ~ isn't expanded when in quotes
    [[ -z "${dir}" ]] && dir=~
    if ! builtin cd "${dir}"; then
		dir=$(compgen -d "${dir}" | head -1)
        if builtin cd "${dir}"; then
            clear ; pwd ; ls -l
        fi
    else
        clear ; pwd ; ls -l
    fi
}

function ed { command ed -p\* "$@" ; }

function last {
	find . -maxdepth 1 -type f -print0 | \
		xargs -0 stat -f "%m %N" | \
		sort -rn | \
		head -1 | \
		cut -f2- -d" "
}

function nents {
	shopt -s nullglob
	tmp=(*)
	echo ${#tmp[@]}
	shopt -u nullglob
}

function pathmunge {
	if ! echo "${PATH}"| /bin/grep -Eq "(^|:)$1($|:)" ; then
		if [ "$2" = "after" ] ; then
			PATH="${PATH}:${1}"
		else
			PATH="${1}:${PATH}"
		fi
	fi
}
