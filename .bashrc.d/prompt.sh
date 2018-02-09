#! /bin/bash

function prompt_command {
    local GARBAGE=""
    #Placeholder
}

function __main {
    local CURDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

    PROMPT_COMMAND="prompt_command"
}

__main
unset -f __main
