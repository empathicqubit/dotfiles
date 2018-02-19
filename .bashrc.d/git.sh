#! /bin/bash
function git {
    if [ "$1" == "push" ] ; then
        git log @{upstream}..
    fi

    local GITOUT="$(mktemp)"
    local GITERR="$(mktemp)"

    command git "$@" > >(tee "$GITOUT") 2> >(tee "$GITERR" >&2)

    rm "$GITOUT"
    rm "$GITERR"
}
