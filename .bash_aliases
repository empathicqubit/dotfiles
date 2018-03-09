#! /bin/bash
function getmac {
    echo 00:$(head -c5 /dev/urandom | hexdump -e '"%02x"' | sed -r 's/(..)/\1:/g;s/:$//;')
}

__bashrc_debug_order=${__bashrc_debug_order:-0}

# This is here so we don't have to modify the distro provided bashrc.
if [ -d "$HOME/.bashrc.d" ] ; then
    while read FILE ; do
        if ((__bashrc_debug_order > 0)) ; then
            echo "$FILE"
        fi
        . "$FILE"

    # It's a bit stupid that I need to do this.
    done < <( find "$HOME/.bashrc.d/." -type f -executable | sort )
fi

# For secrets and commands we don't want to commit to git.
if [ -d "$HOME/.bashrc.local.d" ] ; then
    while read FILE ; do
        . "$FILE"

    done < <( find "$HOME/.bashrc.local.d/." -type f -executable | sort )
fi

alias 'xo=xdg-open'
alias 'rlbashrc=source $HOME/.bashrc'
alias 'hub=git-hub'

export EDITOR='vim'
