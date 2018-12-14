#! /bin/bash
# Random aliases without a home
function xo {
    if which open 2>&1 /dev/null ; then
        open "$@"
    else
        xdg-open "$@"
    fi
}
