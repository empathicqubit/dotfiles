#! /bin/bash
setuplink () {
    local SRCPATH="$1"
    local DEST="$2"

    if [ -f "$DEST" ] ; then
       mv -v "$DEST" "$DEST.bak" || echo "$DEST already exists."
    fi

    if [ ! -e "$DEST" ] ; then
        local MDIR
        case "$OSTYPE" in
            linux-gnu)
                ln -v -s "$SRCPATH" "$DEST"
            ;;
            *)
                echo "$DEST -> $SRCPATH"
                if [ -d "$each" ] ; then
                    MDIR="/d"
                else
                    MDIR=""
                fi
                # Also, screw any version of Windows other than 10.
                powershell.exe -Command New-Item -ItemType SymbolicLink -Path "$(cygpath -w "$DEST")" -Value "$(cygpath -w "$SRCPATH")"
            ;;
        esac
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

CURDIR="$(dirname $(readlink -f "$0"))"
CACHEDIR="$HOME/.cache/dotfiles"

which pacman 2>&1 >/dev/null && ((im_pacman=1)) || ((im_pacman=0))
which apt 2>&1 >/dev/null && ((im_supercow=1)) || ((im_supercow=0))

mkdir -p "$CACHEDIR"

# This will probably get annoying...
setuplinks "$CURDIR/.." "$HOME"

# We don't want to include this whole folder because lots of apps live here. Need some control...
setuplinks "$CURDIR/../.config" "$HOME/.config"
setuplinks "$CURDIR/../.config/xfce4" "$HOME/.config/xfce4"

setuplink "$CURDIR/../.vim" "$HOME/vimfiles"

case "$OSTYPE" in
    linux-gnu)
        sudo npm install -g tern

        if ((im_pacman)) ; then
            sudo pacman -S python-pip python2-pip vim yarn
            yay direnv
        elif ((im_supercow)) ; then
            sudo apt install python3-pip fonts-powerline direnv vim-nox

            curl -L https://releases.hyper.is/download/deb > "$CACHEDIR/hyper.deb"
            sudo dpkg -i "$CACHEDIR/hyper.deb"
            sudo apt install -f

            curl -L http://http.us.debian.org/debian/pool/main/f/fonts-noto-color-emoji/fonts-noto-color-emoji_0~20180102-1_all.deb > "$CACHEDIR/noto-emoji.deb"
            sudo dpkg -i "$CACHEDIR/noto-emoji.deb"
            sudo apt install -f
        fi
    ;;
    *)
        # Windows stuff. Not clear all the environment types that are possible here, so assuming Windows if we don't know.
	# Also, screw darwin.
        # Git Bash: 'msys'
	choco upgrade python nodejs yarn
        npm install -g tern
    ;;
esac

(
    cd "$CURDIR/../script"
    yarn install
)

pip3 install --upgrade --user neovim 
pip install --upgrade --user neovim
vim '+PlugInstall' '+qall!'
