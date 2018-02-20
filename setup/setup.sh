#! /bin/bash
CURDIR="$(dirname $(readlink -f "$0"))"
find "$CURDIR/.." -maxdepth 1 -not -iname setup -not -iname .. -not -iname . -not -iname .git | while read each ; do
    DEST="$HOME/$(basename "$each")"
    [ -e "$DEST" ] && mv -v "$DEST" "$DEST.bak" || echo "$DEST already exists."
    [ ! -e "$DEST" ] && ln -v -s "$each" "$DEST"
done

(
    cd "$CURDIR/../script"
    yarn install
)

pip3 install --upgrade neovim
sudo npm install -g tern
"$CURDIR/../.vim/plugged/fzf/install"
