#! /bin/bash
direnv() {
    if [ "$1" == "allow" ] || [ "$1" == "check" ] ; then
        cat "$2/.envrc"
        echo
        echo -e "${YELLOW}If you really want to allow the above file, use \`direnv really\`${COLORSOFF}"

        return
    fi

    if [ "$1" == "really" ] ; then
        shift
        command direnv allow "$@"

        return
    fi

    command direnv "$@"
}

__precmd_direnv_hook() {
    which direnv 2>&1 >/dev/null || return
    IFS= read -r DIRENV < <(direnv export bash)
    eval "$DIRENV"
}

__main() {
    alias dea='direnv allow'
    alias der='direnv really'

    local DIRENV

    add_precmd_function __precmd_direnv_hook
}

__main
unset -f __main
