#! /bin/bash
# Random aliases without a home
function xo {
    if which open 2>&1 >/dev/null ; then
        open "$@"
    else
        xdg-open "$@"
    fi
}

function set_aws_profile {
    local PROFILES=$(grep '\[' "$HOME/.aws/credentials" | tr '[]' '  ')

    if [ -n "$1" ] ; then
        local COUNT=$(($1))
        local ACCOUNT
        while read ACCOUNT ; do
            ((COUNT--))
            if ((!COUNT)) ; then
                break
            fi
        done < <(echo "$PROFILES")

        export AWS_PROFILE="$ACCOUNT"
    else
        echo "AWS Profiles: "
        echo "$PROFILES" | nl

        echo "
Syntax: ${FUNCNAME[0]} <PROFILE NUMBER>
"
    fi
}

alias ...='cd ..'
function vim {
    which nvim 2>&1 >/dev/null && nvim "$@" || vim "$@"
}

alias rm='rm -i'
