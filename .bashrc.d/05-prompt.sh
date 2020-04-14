#! /bin/bash
__bashrc_promt_timings=${__bashrc_prompt_timings:-0}

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

function __precmd_debug_timings {
    PS4='+ $EPOCHREALTIME\011 '
    exec 3>&2 2>/tmp/bashstart.$$.log
    set -x
}

if ((__bashrc_prompt_timings)) ; then
    add_precmd_function __precmd_debug_timings
fi

function __preexec_tmux_title { 
    local this_command="$1"
    local title
    local promptutil_tmuxPathpart
    IFS= read -r promptutil_tmuxPathpart < <(promptutil tmuxPathpart '"pwd":"'"$PWD"'","cmd":"'"$this_command"'"')
    tmux_set_title "$promptutil_tmuxPathpart"
}

add_preexec_function __preexec_tmux_title

PROMPTUTIL=
PROMPTUTIL_PID=

function __precmd_start_promptutil {
    kill -0 "$PROMPTUTIL_PID" 2>&1 >/dev/null
    if (($?)) ; then
        __start_promptutil
    fi 
}

add_precmd_function __precmd_start_promptutil

function __precmd_ran_once {
    PROMPT_COMMAND_ONCE=1
}

add_precmd_function __precmd_ran_once

function __precmd_tmux_title {
    local promptutil_tmuxPathpart
    IFS= read -r promptutil_tmuxPathpart < <(promptutil tmuxPathpart '"cmd":"bash","pwd":"'"$PWD"'"')
    tmux_set_title "$promptutil_tmuxPathpart"
}

add_precmd_function __precmd_tmux_title

PROMPT_HOOKS=()

function __precmd_git_prompt {
    local promptutil_gitPrompt
    local promptutil_emojiWord
    IFS= read -r promptutil_gitPrompt < <(promptutil gitPrompt '"pwd":"'"$PWD"'"')

    local RANDOM_CHARS=(
        # Grinning cat
        $'\U0001f63a'
    )

    local RANDOM_CHAR="${RANDOM_CHARS[RANDOM % ${#RANDOM_CHARS[@]}]}"

    local HOSTY="$(hostname)"

    IFS= read -r promptutil_emojiWord < <(promptutil emojiWord '"word":"'"$HOSTY"'"')

    if [ ! -z "$promptutil_emojiWord" ] ; then
        HOSTY="$promptutil_emojiWord"
    fi

    local NEW_PROMPT='\u@'"$HOSTY"':\w '"${promptutil_gitPrompt}\n\[${GREEN}\]${PROMPT_CHAR:-$RANDOM_CHAR}\[${COLORSOFF}\] "

    for each in "${PROMPT_HOOKS[@]}" ; do
        $each "$NEW_PROMPT"

        NEW_PROMPT="${PROMPT_HOOK_RESULT:-${NEW_PROMPT}}"
    done

    export PS1="$NEW_PROMPT"
}

add_precmd_function __precmd_git_prompt

function __start_promptutil {
    if [ ! -z "$PROMPTUTIL_PID" ] && kill -0 "$PROMPTUTIL_PID" 2>&1 >/dev/null ; then
        return
    fi

    if ! which node 2>&1 >/dev/null ; then
        echo 'Please install node'
        return
    fi

    coproc PROMPTUTIL { promptutil.js --color=always ; }
}

function __precmd_debug_timings_end {
    set +x
    exec 2>&3 3>&-
}

if ((__bashrc_prompt_timings)) ; then
    add_precmd_function __precmd_debug_timings_end
fi

function promptutil {
    local COMMAND="$1"
    local PARAMS="$2"
    local JSON
    local RESULT
    IFS= read -r JSON <<JSON
{ "command": "$COMMAND", ${PARAMS:-\"noparams\"\: true} }
JSON
    
    echo "$JSON" >&${PROMPTUTIL[1]}
    read -r RESULT <&${PROMPTUTIL[0]}
    echo -n -e "$RESULT"
}

function __main {
    local CURDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

    __start_promptutil
}

__main
unset -f __main
