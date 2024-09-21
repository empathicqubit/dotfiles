#! /bin/bash
export PATH="$PATH:$HOME/script:$HOME/.vim/plugged/github:$HOME/bin:$HOME/.local/bin:~/.pyenv/bin:$HOME/c64-devkit/bin:/usr/lib/goattracker:$HOME/.nix-profile/bin:$HOME/google-cloud-sdk/bin:$HOME/go/bin:$HOME/flutter/bin"

function addpythonpath () {
    local PY3PATH
    local PYPATH

    if which python &>/dev/null ; then
        PYPATH="$(python -c 'import sys ; print(sys.path)' | tr "'" '"' | jq -r ".[] | select(contains(\"$HOME\"))" | awk -F'/lib/' '{print $1}')/bin"
        PATH="$PATH:$PYPATH"
    fi

    if which python3 &>/dev/null ; then
        PY3PATH="$(python3 -c 'import sys ; print(sys.path)' | tr "'" '"' | jq -r ".[] | select(contains(\"$HOME\"))" | awk -F'/lib/' '{print $1}')/bin"
        PATH="$PATH:$PY3PATH"
    fi
}

addpythonpath

function addcondapath () {
    local each

    for each in "/usr/local/anaconda"*"/bin" ; do
        export PATH="$PATH:$each"
    done
}

addcondapath

for gempath in $HOME/.gem/ruby/*/bin ; do
    export PATH="$PATH:$gempath"
done

export HISTCONTROL=ignorespace:ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

if [ ! -z "$DISPLAY" ] ; then
    export TMOUT=                            # never time out if we're graphical
else
    export TMOUT=$((5*60))                   # use a less crazy timeout than the system default
fi
