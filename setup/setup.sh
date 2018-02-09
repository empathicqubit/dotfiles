#! /bin/bash
CURDIR="$(dirname $(readlink -f "$0"))"
find "$CURDIR/.." -maxdepth 1 -not -iname setup -not -iname .. -not -iname . -not -iname .git | while read each ; do
    DEST="$HOME/$(basename "$each")"
    if [ -e "$DEST" ] ; then
        mv -v "$DEST" "$DEST.bak" || echo "$DEST already exists."
    fi
    ln -v -s "$each" "$DEST"
done
