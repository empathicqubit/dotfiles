#! /bin/bash
export PATH="$PATH:$HOME/script:$HOME/.vim/plugged/github"

for gempath in $HOME/.gem/ruby/*/bin ; do
    export PATH="$PATH:$gempath"
done
