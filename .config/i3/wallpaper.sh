#!/bin/bash

# date:     2018-06-26
# version:  2.3
# author:   xereeto
# licence:  wtfpl

tries=0
trap "exit 1" TERM
export TOP_PID=$$
[[ -z $DISPLAY ]] && export DISPLAY=:0
[[ -d ~/.wallpapers ]] || mkdir ~/.wallpapers
[[ -f ~/.wallpapers/subreddits ]] || echo -e "wallpapers\nwallpaper\nearthporn\nspaceporn" > ~/.wallpapers/subreddits
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
CACHE_FOLDER="$HOME/.cache/xereeto-wallpaper"
CONFIG_FOLDER="$HOME/.config/xereeto-wallpaper"
wallargs=()
getWallpaper(){
    local time=`date +%s-%N`
    mkdir -p "$CACHE_FOLDER"
    mkdir -p "$CONFIG_FOLDER"
    [[ -e "$CONFIG_FOLDER/subreddits" ]] || { echo "Please create $CONFIG_FOLDER/subreddits" ; exit 1 ; }
    local this_wallpaper="$CACHE_FOLDER/$time.jpg"
    if [[ $tries > 10 ]]; then echo "too many failed attempts, exiting"; kill -s TERM $TOP_PID; fi 
    tries=$((tries+1))
    [[ -z "$1" ]] || echo "that didn't work, let's try again"
    echo "getting wallpaper..."
    curl -s -A "/u/xereeto's wallpaper bot" https://www.reddit.com/r/`grep -v "#" "$CONFIG_FOLDER/subreddits" | shuf -n 1`/.json | python3 -m json.tool | grep -P '\"url\": \"htt(p|ps):\/\/((i.+)?imgur.com\/(?!.\/)[A-z0-9]{5,7}|i.redd.it|staticflickr.com)' | addJpegIfImgur | shuf -n 1 - | xargs wget --quiet -O "$this_wallpaper" 2>/dev/null
    width=$(identify -format %w "$this_wallpaper") 2>/dev/null
    height=$(identify -format %h "$this_wallpaper") 2>/dev/null
    [[ "$width" -ge 1920 && "$height" -ge 1050 ]] || startOver  
    wallargs+=("--bg-fill" "$this_wallpaper")
    tries=0
}
NUMACTIVE=$(xrandr --listactivemonitors | head -1 | awk '{print $NF}')
for (( i=0; i<NUMACTIVE; i++)) ; do
    getWallpaper
done
feh "${wallargs[@]}" # 2>/dev/null || startOver 
echo "hope you like your new wp"
