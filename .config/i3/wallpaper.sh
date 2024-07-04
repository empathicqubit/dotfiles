#!/bin/bash
WALLPAPERDIR="$HOME/Bilder/Wallpapers"
NUMACTIVE=$(xrandr --listactivemonitors | head -1 | awk '{print $NF}')
mkdir -p "$WALLPAPERDIR"
wallargs=()
while read FILENAME ; do
    echo "$FILENAME"
    wallargs+=("--bg-fill" "$FILENAME")
    echo "${wallargs[@]}"
done < <( find "$WALLPAPERDIR" -type f | shuf -n "$NUMACTIVE" - )
if [[ "${#wallargs[@]}" -eq 0 ]] ; then
    exit 1
fi
echo feh "${wallargs[@]}"
feh "${wallargs[@]}"
