#! /bin/bash
tmux_set_title () {
    printf '\033]2;%s\033\\' "$1"
}
