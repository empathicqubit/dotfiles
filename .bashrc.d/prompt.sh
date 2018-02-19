#! /bin/bash

function prompt_command {
    local GARBAGE=""
    __posh_git_ps1 "\u@\h:\w " "\\\$ "
    #Placeholder
}

function __main {
    local CURDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

    PROMPT_COMMAND="prompt_command"
}

__main
unset -f __main
