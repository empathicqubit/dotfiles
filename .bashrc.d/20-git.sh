#! /bin/bash
function git {

    if [ "$1" == "push" ] ; then
        git log @{upstream}..
    fi

    local CAPTURE=

    # This causes git to behave differently, so we only do it when we need it.
    if [ ! -z "$CAPTURE" ] ; then
        local GITOUT
        IFS= read -r GITOUT < <(mktemp)

        local GITERR
        IFS= read -r GITERR < <(mktemp)

        command git "$@" > >(tee "$GITOUT") 2> >(tee "$GITERR" >&2)

        rm "$GITOUT"
        rm "$GITERR"
    else
        local HASHES=
        local PULLSTATUS=
        if [ "$1" == "pull" ] ; then
            local SCRIPTTMP="$(mktemp)"
            local SCRIPTCOMMAND=("script" "--return" "-c" "git $*" "$SCRIPTTMP")
            if [ "$(type -t script)" == "file" ] ; then
                SCRIPTCOMMAND=("script" "-q" "$SCRIPTTMP" "git" "$@")
            fi

            "${SCRIPTCOMMAND[@]}"

            IFS= read -r HASHES < <(grep -i -o -E '[0-9a-f]{7}\.\.[0-9a-f]{7}' "$SCRIPTTMP")

            rm "$SCRIPTTMP"

            echo "HASHES $HASHES"

            if [ ! -z "$HASHES" ] ; then
                git diff "$HASHES"
            fi
        else
            command git "$@"
        fi
    fi
}

alias gO='git push'
alias gI='git pull'
alias gOoh='git push -u origin HEAD'
alias gC='git commit'
alias gCa='git commit -a'
alias gco='git checkout'
alias gcou='git checkout HEAD^'
alias ga='git add'
alias gad='git add .'
alias gap='git add -p'
alias gs='git stash'
alias gd='git diff'
alias gcob='git checkout -b'
alias gm='git merge'
alias gr='git reset'
alias gR='git reset --hard'
alias grb='git rebase'
alias gl='git log'
