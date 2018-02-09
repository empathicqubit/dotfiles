#! /bin/bash
function getmac {
    echo 00:$(head -c5 /dev/urandom | hexdump -e '"%02x"' | sed -r 's/(..)/\1:/g;s/:$//;')
}

if [ -d "$HOME/.bashrc.d" ] ; then
    while read FILE ; do
        . "$FILE"

    # It's a bit stupid that I need to do this.
    done < <( find "$HOME/.bashrc.d/." -type f -executable )
fi

alias 'xo=xdg-open'
alias 'rlbashrc=source $HOME/.bashrc'

export EDITOR='vim'
