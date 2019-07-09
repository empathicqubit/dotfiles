#! /bin/bash
export PATH="$PATH:$HOME/script:$HOME/.vim/plugged/github:$HOME/bin:$HOME/.local/bin:~/.pyenv/bin:$HOME/c64-devkit/bin"

function addpythonpath () {
    local PY3PATH
    local PYPATH

    if which python 2>&1 >/dev/null ; then
        PYPATH="$(python -c 'import sys ; print(sys.path)' | tr "'" '"' | jq -r ".[] | select(contains(\"$HOME\"))" | awk -F'/lib/' '{print $1}')/bin"
        PATH="$PATH:$PYPATH"
    fi

    if which python3 2>&1 >/dev/null ; then
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
