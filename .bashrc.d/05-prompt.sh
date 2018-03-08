#! /bin/bash
function tmux_set_title {
    if [ ! -z "$TMUX" ] ; then
        printf '\033]2;%s\033\\' "$1"
    fi
}

function add_preexec_function {
    local func="$1"
    for each in "${preexec_functions[@]}" ; do
        [ "$each" = "$func" ] && return 1
    done

    preexec_functions+=("$func")

    return 0
}

function add_precmd_function {
    local func="$1"
    for each in "${precmd_functions[@]}" ; do
        [ "$each" = "$func" ] && return 1
    done

    precmd_functions+=("$func")

    return 0
}

function seconds_since_epoch {
    date '+%s'
}

function __preexec_tmux_title { 
    local this_command="$1"
    local title
    IFS= read -r title < <(promptutil tmux-pathpart "pwd=$PWD" "cmd=$this_command")
    tmux_set_title "$title"
}

add_preexec_function __preexec_tmux_title

PROMPTUTIL_PORT=
PROMPTUTIL_PID=

function __precmd_start_promptutil {
    if [ -z "$PROMPTUTIL_PID" ] || [ ! -d "/proc/$PROMPTUTIL_PID" ] ; then
        __start_promptutil
    fi 
}

add_precmd_function __precmd_start_promptutil

function __precmd_ran_once {
    PROMPT_COMMAND_ONCE=1
}

add_precmd_function __precmd_ran_once

function __precmd_tmux_title {
    local title
    IFS= read -r title < <(promptutil tmux-pathpart "pwd=$PWD" "cmd=bash")
    tmux_set_title "$title"
}

add_precmd_function __precmd_tmux_title

PROMPT_HOOKS=()

function __precmd_git_prompt {
    local GIT_PROMPT
    IFS= read -r GIT_PROMPT < <(promptutil git-prompt "pwd=$PWD")

    local RANDOM_CHARS=(
        # Mermaid
        $'\U0001f9dc\U0000200d\U00002640\U0000fe0f'
        # Female technologist
        $'\U0001f469\U0000200d\U0001f4bb'
    )

    local RANDOM_CHAR="${RANDOM_CHARS[RANDOM % ${#RANDOM_CHARS[@]}]}"

    local NEW_PROMPT='\u@\h:\w '"${GIT_PROMPT}\n\[${GREEN}\]${PROMPT_CHAR:-$RANDOM_CHAR}\[${COLORSOFF}\] "

    for each in "${PROMPT_HOOKS[@]}" ; do
        $each "$NEW_PROMPT"

        NEW_PROMPT="${PROMPT_HOOK_RESULT:-${NEW_PROMPT}}"
    done

    export PS1="$NEW_PROMPT"
}

add_precmd_function __precmd_git_prompt

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
}

__main
unset -f __main
