#! /bin/bash
function git {
    if [ "$1" == "push" ] ; then
        git log @{upstream}..
    fi

    command git "$@"
}
