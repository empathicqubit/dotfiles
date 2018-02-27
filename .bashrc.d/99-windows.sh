#! /bin/bash
function __main() {
    local GARBAGE
    # Placeholder for WSL, etc.
}

function docker-machine-env-windows() {
    eval $(docker-machine.exe env --shell bash "$@" | sed -e 's@\\@/@g' -e 's@"\([a-zA-Z]\):/@"/mnt/\L\1/@g')
}

function fixcodepage() {
    cmd.exe /c "chcp 850 && $* && chcp 65001 || chcp 65001"
}

__main
unset -f __main;
