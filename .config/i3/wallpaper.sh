#!/bin/bash

# date:     2018-06-26
# version:  2.3
# author:   xereeto
# licence:  wtfpl

tries=0
trap "exit 1" TERM
export TOP_PID=$$
CACHE_FOLDER="$HOME/.cache/xereeto-wallpaper"
CONFIG_FOLDER="$HOME/.config/xereeto-wallpaper"
[[ -z $DISPLAY ]] && export DISPLAY=:0
[[ -d "$CACHE_FOLDER" ]] || mkdir -p "$CACHE_FOLDER"
[[ -d "$CONFIG_FOLDER" ]] || mkdir -p "$CONFIG_FOLDER"
[[ -f "$CONFIG_FOLDER/subreddits" ]] || echo -e "wallpapers\nwallpaper\nearthporn\nspaceporn" > "$CONFIG_FOLDER/subreddits"
addJpegIfImgur(){
    while read url; do
        isImgur=$(echo "$url" | grep imgur);
        url=$(echo $url | sed -e 's/"url": "//' -e 's/",//' -e 's/gallery\///')
        [[ -z "$isImgur" ]] && echo $url || echo $url | sed -e 's/$/\.jpg/'
    done
}
startOver(){
    getWallpaper "shitsfucked"
}
wallargs=()
getWallpaper(){
    local time=`date +%s-%N`
    local this_wallpaper="$CACHE_FOLDER/$time.jpg"
    if [[ $tries > 10 ]]; then echo "too many failed attempts, exiting"; kill -s TERM $TOP_PID; fi 
    tries=$((tries+1))
    [[ -z "$1" ]] || echo "that didn't work, let's try again"
    echo "getting wallpaper..."
    curl -s -A "/u/xereeto's wallpaper bot" https://www.reddit.com/r/`grep -v "#" "$CONFIG_FOLDER/subreddits" | shuf -n 1`/.json | jq -r '.data.children[] | .data.url' | addJpegIfImgur | shuf -n 1 - | xargs wget --quiet -O "$this_wallpaper" 2>/dev/null
    return
    width=$(identify -format %w "$this_wallpaper") 2>/dev/null
    height=$(identify -format %h "$this_wallpaper") 2>/dev/null
    [[ "$width" -ge 1920 && "$height" -ge 1050 ]] || startOver  
    wallargs+=("--bg-fill" "$this_wallpaper")
    tries=0
}
NUMACTIVE=$(xrandr --listactivemonitors | head -1 | awk '{print $NF}')
for (( i=0; i<NUMACTIVE; i++)) ; do
    getWallpaper
    sleep 10
done
feh "${wallargs[@]}" # 2>/dev/null || startOver 
echo "hope you like your new wp"
