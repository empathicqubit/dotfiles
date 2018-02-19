#! /bin/bash
function git {
    if [ "$1" == "push" ] ; then
        git log @{upstream}..
    fi

    local CAPTURE=

    # This causes git to behave differently, so we only do it when we need it.
    if [ ! -z "$CAPTURE" ] ; then
        local GITOUT="$(mktemp)"
        local GITERR="$(mktemp)"

        command git "$@" > >(tee "$GITOUT") 2> >(tee "$GITERR" >&2)

        rm "$GITOUT"
        rm "$GITERR"
    else
        command git "$@"
    fi

}
