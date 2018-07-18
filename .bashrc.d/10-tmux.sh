#! /bin/bash

function tmux() {
    if [[ $# -eq 0 ]] ; then
        command tmux new-session \; new-window \; new-window \; new-window \; new-window \; new-window
    else
        command tmux "$@"
    fi
}
