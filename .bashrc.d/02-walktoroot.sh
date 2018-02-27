#! /bin/bash
function walktoroot {
    local DIR="$1"
    shift

    if [ "$DIR" = "/" ]; then
        return
    fi

    if ! "$@" "$DIR" ; then
        local PARENTDIR="$(dirname "$DIR")"
        walktoroot "$PARENTDIR" "$@"
    fi
}
