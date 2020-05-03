#! /bin/bash
__bashrc_prompt_timings=${__bashrc_prompt_timings:-0}

function tmux_set_title {
    if [ ! -z "$TMUX" ] ; then
        printf '\033]2;%s\033\\' "$1"
    fi
}

function middle_truncate {
    local str="$1"
    local max=$(($2))
    local len=${#str}

    local mid
    local rem
    local left
    local right

    if ((len <= max)) ; then
        echo -n "$str"
        return
    fi

    if ((max == 1)) ; then
        echo -n "${str:0:1}"$'\U00002026'
        return
    fi

    mid=$((len / 2))
    rem=$((len - max + 1))
    left=$((rem / 2))
    right=$((rem - left))

    echo "${str:0:$((mid - left))}"$'\U00002026'"${str:$((mid + right))}"
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
    for each in "${this_command[@]}" ; do
        echo "$each"
    done

    tmux_set_title "$(middle_truncate "$(basename "$PWD")" 8) - $(middle_truncate "$this_command" 12)"
}

add_preexec_function __preexec_tmux_title

function __precmd_ran_once {
    PROMPT_COMMAND_ONCE=1
}

add_precmd_function __precmd_ran_once

function __precmd_tmux_title {
    tmux_set_title "$(middle_truncate "$(basename "$PWD")" 20)"
}

add_precmd_function __precmd_tmux_title

PROMPT_HOOKS=()

function git_prompty {
    local OUTPUT
    local SOMETHING
    OUTPUT="$(git status --porcelain | grep -o '^..')"

    echo -n "\[${GREEN}\][ git: "

    if [[ "$OUTPUT" =~ "M" ]] ; then
        SOMETHING=1
        echo -n "\[${YELLOW}\]~ "
    fi

    if [[ "$OUTPUT" =~ "D" ]] ; then
        SOMETHING=1
        echo -n "\[${RED}\]- "
    fi

    if [[ "$OUTPUT" =~ "A" ]] ; then
        SOMETHING=1
        echo -n "\[${GREEN}\]+ "
    fi

    if ((!SOMETHING)) ; then
        echo -n "\[${CYAN}\]= "
    fi

    echo -n "\[${GREEN}\]] ${COLORSOFF}"
}

function __precmd_host_prompt {
    local RANDOM_CHARS=(
        # Grinning cat
        $'\U0001f63a'
    )

    local RANDOM_CHAR="${RANDOM_CHARS[RANDOM % ${#RANDOM_CHARS[@]}]}"

    local HOSTY="$(hostname)"

    if [ "$(type -t __host_alts)" == "function" ] ; then
        __host_alts "$HOSTY"
    fi

    local NEW_PROMPT='\u@'"$HOSTY"':\w '"$(git_prompty)\n\[${GREEN}\]${PROMPT_CHAR:-$RANDOM_CHAR}\[${COLORSOFF}\] "

    for each in "${PROMPT_HOOKS[@]}" ; do
        $each "$NEW_PROMPT"

        NEW_PROMPT="${PROMPT_HOOK_RESULT:-${NEW_PROMPT}}"
    done

    export PS1="$NEW_PROMPT"
}

add_precmd_function __precmd_host_prompt

function __precmd_debug_timings_end {
    set +x
    exec 2>&3 3>&-
}

if ((__bashrc_prompt_timings)) ; then
    add_precmd_function __precmd_debug_timings_end
fi

function __main {
    local CURDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
}

__main
unset -f __main
