#! /bin/bash
direnv() {
    if [ "$1" == "allow" ] || [ "$1" == "check" ] ; then
        cat "$2/.envrc"
        echo
        echo 'If you really want to allow the above file, use `direnv really`'

        return
    fi

    if [ "$1" == "really" ] ; then
        shift
        command direnv allow "$@"

        return
    fi

    command direnv "$@"
}

__main() {
    alias dea='direnv allow'
    alias der='direnv really'

    local DIRENV
    # The things I do to avoid forking... :/
    mapfile DIRENV < <(direnv hook bash)
    eval "${DIRENV[@]}"
}

__main
unset -f __main
