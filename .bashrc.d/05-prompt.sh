#! /bin/bash
__bashrc_prompt_timings=${__bashrc_prompt_timings:-0}

function tmux_set_title {
    if [ ! -z "$TMUX" ] ; then
        printf '\033]2;%s\033\\' "$1"
    fi
}


function middle_truncate {
    local max=$(($1))

    local mid
    local rem
    local left
    local right

    IFS= read -r str
    local len=${#str}

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
    local TRUNC_PWD
    local TRUNC_CMD

    IFS= read -r TRUNC_PWD < <(basename "$PWD")
    IFS= read -r TRUNC_PWD < <(middle_truncate 8 <<< "$TRUNC_PWD")
    IFS= read -r TRUNC_CMD < <(middle_truncate 12 <<< "$this_command")

    tmux_set_title "$TRUNC_PWD - $TRUNC_CMD"
}

add_preexec_function __preexec_tmux_title

function __precmd_ran_once {
    PROMPT_COMMAND_ONCE=1
}

add_precmd_function __precmd_ran_once

function __precmd_tmux_title {
    local TRUNC_PWD

    if [[ "$PWD" == "$HOME" ]] ; then
        tmux_set_title ""
    else
        IFS= read -r TRUNC_PWD < <(basename "$PWD")
        IFS= read -r TRUNC_PWD < <(middle_truncate 20 <<< "$TRUNC_PWD")

        tmux_set_title "$TRUNC_PWD"
    fi
}

add_precmd_function __precmd_tmux_title

PROMPT_HOOKS=()

function git_prompty {
    local OUTPUT
    local SOMETHING
    local UPSTREAM
    local FAILURE
    local STATUS
    local TMP

    IFS= read -r -d '' STATUS < <( git status --porcelain 2>/dev/null || echo 'FATAL')

    if [[ "$STATUS" =~ ^FATAL ]] ; then
        return
    fi

    IFS= read -r -d '' OUTPUT < <(grep -o '^..' <<< "$STATUS")

    echo -n "\[${GREEN}\][ git: "

    IFS= read -r UPSTREAM < <(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)
    if ((UPSTREAM > 0)) ; then
        echo -n "${PURPLE}ahead ${UPSTREAM} ${GREEN}| "
    fi

    if [[ "$OUTPUT" =~ "M" ]]; then
        SOMETHING=1
        echo -n "\[${YELLOW}\]~ "
    fi

    if [[ "$OUTPUT" =~ "R" ]] ; then
        SOMETHING=1
        echo -n "\[${YELLOW}\]> "
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
        ">"
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
