#!/bin/bash
WALLPAPERDIR="$HOME/Bilder/Wallpapers"
NUMACTIVE=$(xrandr --listactivemonitors | head -1 | awk '{print $NF}')
mkdir -p "$WALLPAPERDIR"
wallargs=()
find "$WALLPAPERDIR" -type f | shuf -n "$NUMACTIVE" - | while read FILENAME ; do
    wallargs+=("--bg-fill" "$FILENAME")
done
[ -z "${wallargs[@]}" ] && exit 1
feh "${wallargs[@]}"
