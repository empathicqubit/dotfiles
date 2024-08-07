#! /bin/bash
set -e

which gls 2>/dev/null && IS_BREW=1 || IS_BREW=0

IS_DARWIN=$((0))
IS_LINUX=$((0))
IS_WINDOWS=$((0))
LINKS_ONLY=$((0))
case "$OSTYPE" in
    linux-*) IS_LINUX=$((1)) ;;
    darwin*) IS_DARWIN=$((1)) ;;
    *) IS_WINDOWS=$((1)) ;;
esac

USE_NPM=$((1))
while [ -n "$1" ] ; do
    case "$1" in
        --skip-npm) USE_NPM=$((0)) ;;
        --links-only) LINKS_ONLY=$((1)) ;;
    esac
    shift
done

curlorwget () {
    curl -sL "$@" | wget -qO- "$@"
}

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

which pacman 2>&1 >/dev/null && IS_PACMAN=1 || IS_PACMAN=0
which apt 2>&1 >/dev/null && IS_SUPERCOW=1 || IS_SUPERCOW=0
IS_SUPERCOW=$((!IS_BREW && IS_SUPERCOW))

mkdir -p "$CACHEDIR"

# This will probably get annoying...
setuplinks "$CURDIR/.." "$HOME"

# We don't want to include this whole folder because lots of apps live here. Need some control...
setuplinks "$CURDIR/../.config" "$HOME/.config"

mkdir -p "$HOME/.config/xfce4"
setuplinks "$CURDIR/../.config/xfce4" "$HOME/.config/xfce4"

mkdir -p "$HOME/.config/dark-mode-notify"
setuplinks "$CURDIR/../.config/dark-mode-notify" "$HOME/.config/dark-mode-notify"

setuplink "$CURDIR/../.vim" "$HOME/vimfiles"

setuplink "$CURDIR/../.nvim" "$HOME/.config/nvim"

mkdir -p "$HOME/.bashrc.local.d"

((LINKS_ONLY)) && exit 0

if ((IS_WINDOWS)) ; then
    # Git Bash: 'msys'
    choco upgrade python nodejs neovim
    ((USE_NPM)) && npm install -g pnpm
    ((USE_NPM)) && pnpm add -g tern
else
    if ((IS_PACMAN)) ; then
        # pstree untested
        # silversearcher-ag untested
        sudo pacman -S python-pip python2-pip vim ruby pstree silversearcher-ag neovim
        yay direnv
    elif ((IS_SUPERCOW)) ; then
        echo "USING APT"

        wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/vscodium.gpg
        echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list.d/vscodium.list

        curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -

        sudo apt update
        sudo apt install blueman network-manager-gnome python3-pip python3-configobj fonts-powerline direnv vim-nox ruby silversearcher-ag nodejs jq codium pasystray gxkb rofi xdotool x11-xserver-utils indent libanyevent-i3-perl feh tk i3lock xautolock fonts-noto fonts-material-design-icons-iconfont fonts-materialdesignicons-webfont polybar fonts-font-awesome i3 curl playerctl xfce4-screenshooter imagemagick diodon fcitx-bin fcitx-mozc fcitx-imlist

        curlorwget https://releases.hyper.is/download/deb > "$CACHEDIR/hyper.deb"
        sudo dpkg -i "$CACHEDIR/hyper.deb" || sudo apt install -f

        curlorwget http://cloudfront.debian.net/debian/pool/main/f/fonts-noto-color-emoji/fonts-noto-color-emoji_0~20200916-1_all.deb > "$CACHEDIR/noto-emoji.deb"
        sudo dpkg -i "$CACHEDIR/noto-emoji.deb"
        sudo apt install -f
    elif ((IS_BREW)) ; then
        brew install ipython direnv ruby vim nodejs pstree bash-completion ag neovim pyenv jq coreutils findutils fzf
    fi

    ((USE_NPM && !IS_BREW)) && sudo npm install -g pnpm
    ((USE_NPM && !IS_BREW)) && sudo pnpm add -g tern
fi

vim '+PlugInstall' '+qall!'

if ((!IS_BREW)) ; then
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

    # For neovim
    pyenv update

    pyenv install 2.7.11
    pyenv install 3.4.4

    pyenv virtualenv 2.7.11 neovim2
    pyenv virtualenv 3.4.4 neovim3

    pyenv activate neovim2
    pip install neovim
    PYPATH2=$(pyenv which python)

    pyenv activate neovim3
    pip install neovim
    PYPATH3=$(pyenv which python)

    pip3 install --upgrade --user i3-workspace-names-daemon

    pip3 install --upgrade --user neovim 
    pip install --upgrade --user neovim websocket-client sexpdata

    echo "$PYPATH2"
    echo "$PYPATH3"

    curl https://sdk.cloud.google.com | bash
else
    cd $HOME/.vim/plugged/dark-mode-notify
    sudo make install
fi
