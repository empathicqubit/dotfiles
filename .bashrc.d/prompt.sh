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

tmux_set_title () {
    printf '\033]2;%s\033\\' "$1"
}

preexec () { 
    local this_command="$1"
    tmux_set_title "$(promptutil tmux-pathpart "pwd=$PWD" "cmd=$this_command")"
}

preexec_invoke_exec () {
    [ -z "$PROMPT_COMMAND_ONCE" ] && return
    [ -n "$COMP_LINE" ] && return  # do nothing if completing
    [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return # don't cause a preexec for $PROMPT_COMMAND
    local this_command=`HISTTIMEFORMAT= history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//"`;
    preexec "$this_command"
}
trap 'preexec_invoke_exec' DEBUG

function prompt_command {
    local GARBAGE=""
    PROMPT_COMMAND_ONCE=1

    if [ -z "$PROMPTUTIL_PID" ] || [ ! -d "/proc/$PROMPTUTIL_PID" ] ; then
        __start_promptutil
    fi 

    tmux_set_title "$(promptutil tmux-pathpart "pwd=$PWD" "cmd=bash")"

    walktoroot "$PWD" icanhazgitconfig

    local GIT_PROMPT
    IFS= read -r GIT_PROMPT < <(promptutil git-prompt "pwd=$PWD")

    export PS1='\u@\h:\w '"${GIT_PROMPT}\n\$ "
}

PROMPTUTIL_PORT=
PROMPTUTIL_PID=

function __start_promptutil {
    if [ ! -z "$PROMPTUTIL_PID" ] ; then
        __kill_promptutil
    fi

    PROMPTUTIL_PORT=$((RANDOM+1024))
    PROMPTUTIL_PORT="$PROMPTUTIL_PORT" promptutil.js &
    PROMPTUTIL_PID=$!
}

function __kill_promptutil {
    kill "$PROMPTUTIL_PID"
    PROMPTUTIL_PORT=
    PROMPTUTIL_PID=
}

function promptutil {
    local PATHNAME="$1"
    shift

    local DATA_ARGS=()
    for i in "$@" ; do
        DATA_ARGS+=('--data-urlencode' "$1")
        shift
    done

    curl -s -G 'http://localhost:'"$PROMPTUTIL_PORT"'/'"$PATHNAME" "${DATA_ARGS[@]}"
}

function __main {
    local CURDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

    __start_promptutil

    PROMPT_COMMAND="prompt_command"
}

__main
unset -f __main
