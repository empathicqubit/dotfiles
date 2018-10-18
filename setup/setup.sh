#! /bin/bash

which gls 2>/dev/null
IS_BREW=$((!$?))

IS_DARWIN=$((0))
IS_LINUX=$((0))
IS_WINDOWS=$((0))
case "$OSTYPE" in
    linux-gnu) IS_LINUX=$((1)) ;;
    darwin*) IS_DARWIN=$((1)) ;;
    *) IS_WINDOWS=$((1)) ;;
esac

setuplink () {
    local SRCPATH="$1"
    local DEST="$2"

    if [ -f "$DEST" ] ; then
       mv -v "$DEST" "$DEST.bak" || echo "$DEST already exists."
    fi

    if [ ! -e "$DEST" ] ; then
        local MDIR
        if ((IS_WINDOWS)) ; then
            echo "$DEST -> $SRCPATH"
            if [ -d "$each" ] ; then
                MDIR="/d"
            else
                MDIR=""
            fi
            # Also, screw any version of Windows other than 10.
            powershell.exe -Command New-Item -ItemType SymbolicLink -Path "$(cygpath -w "$DEST")" -Value "$(cygpath -w "$SRCPATH")"
        else
            ln -v -s "$SRCPATH" "$DEST"
        fi
    fi
}

setuplinks () {
    local SRC="$1"
    local DESTBASE="$2"

    local SRCPATH
    find "$SRC" -maxdepth 1 -not -iname setup -not -iname .. -not -iname . -not -iname .git -not -iname .config -not -iname xfce4 -not -iname '.tern-*' | while read SRCPATH ; do
        local DEST="$DESTBASE/$(basename "$SRCPATH")"
        setuplink "$SRCPATH" "$DEST"
    done
}

ADDG=
((IS_BREW)) && ADDG="g"

CURDIR="$(dirname $(${ADDG}readlink -f "$0"))"
CACHEDIR="$HOME/.cache/dotfiles"

which pacman 2>&1 >/dev/null 
IS_PACMAN=$((!$?))
which apt 2>&1 >/dev/null
IS_SUPERCOW=$((!IS_BREW && !$?))

mkdir -p "$CACHEDIR"

# This will probably get annoying...
setuplinks "$CURDIR/.." "$HOME"

# We don't want to include this whole folder because lots of apps live here. Need some control...
setuplinks "$CURDIR/../.config" "$HOME/.config"
setuplinks "$CURDIR/../.config/xfce4" "$HOME/.config/xfce4"

setuplink "$CURDIR/../.vim" "$HOME/vimfiles"

mkdir "$HOME/.bashrc.local.d"

if ((IS_WINDOWS)) ; then
    # Git Bash: 'msys'
    choco upgrade python nodejs yarn
    npm install -g tern
else
    sudo npm install -g tern

    if ((IS_PACMAN)) ; then
        sudo pacman -S python-pip python2-pip vim yarn ruby
        yay direnv
    elif ((IS_SUPERCOW)) ; then
        sudo apt install python3-pip fonts-powerline direnv vim-nox ruby

        curl -L https://releases.hyper.is/download/deb > "$CACHEDIR/hyper.deb"
        sudo dpkg -i "$CACHEDIR/hyper.deb"
        sudo apt install -f

        curl -L http://http.us.debian.org/debian/pool/main/f/fonts-noto-color-emoji/fonts-noto-color-emoji_0~20180102-1_all.deb > "$CACHEDIR/noto-emoji.deb"
        sudo dpkg -i "$CACHEDIR/noto-emoji.deb"
        sudo apt install -f
    elif ((IS_BREW)) ; then
        brew install python python@2 direnv ruby vim
    fi

fi

# Find package.jsons and reinstall all node packages
find "$CURDIR" -iname package.json | while read FILENAME ; do
    PACKAGEDIR="$(dirname "$FILENAME")"
    if [[ -e "$PACKAGEDIR/node_modules" ]] ; then
        continue
    fi

    (
        cd "$PACKAGEDIR"
        yarn install
    )
done

pip3 install --upgrade --user neovim 
pip install --upgrade --user neovim
vim '+PlugInstall' '+qall!'
