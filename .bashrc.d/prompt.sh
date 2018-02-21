#! /bin/bash

function icanhazgitconfig {
    local DIR="${@: -1}"
    if [ -f "$DIR/.gitconfig" ] ; then
        export GIT_CONFIG="$DIR/.gitconfig"

        true
    else
        false
    fi
}


function prompt_command {
    local GARBAGE=""
    __posh_git_ps1 "\u@\h:\w " "\\\$ "

    date

    walktoroot "$PWD" icanhazgitconfig
}

function __main {
    local CURDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

    PROMPT_COMMAND="prompt_command"
}

__main
unset -f __main
