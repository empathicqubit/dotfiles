#! /bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function find {
    if which gfind &>/dev/null ; then
        gfind "$@"
    else
        command find "$@"
    fi
}

export PATH=$PATH:/opt/homebrew/bin

if [ -d "$SCRIPT_DIR/run.d" ] ; then
    while read FILE ; do
        . "$FILE"

    done < <( find "$SCRIPT_DIR/run.d/." -type f -executable | sort )
fi
