#!/bin/bash

# date:     2018-06-26
# version:  2.3
# author:   xereeto
# licence:  wtfpl

time=`date +%s`
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
    rm "~/.wallpapers/$time.jpg" 2>/dev/null
    getWallpaper "shitsfucked"
}
getWallpaper(){
		if [[ $tries > 10 ]]; then echo "too many failed attempts, exiting"; kill -s TERM $TOP_PID; fi 
		tries=$((tries+1))
        [[ -z "$1" ]] || echo "that didn't work, let's try again"
        echo "getting wallpaper..."
        curl -s -A "/u/xereeto's wallpaper bot" https://www.reddit.com/r/`grep -v "#" ~/.wallpapers/subreddits | shuf -n 1`/.json | python -m json.tool | grep -P '\"url\": \"htt(p|ps):\/\/((i.+)?imgur.com\/(?!.\/)[A-z0-9]{5,7}|i.redd.it|staticflickr.com)' | addJpegIfImgur | shuf -n 1 - | xargs wget --quiet -O ~/.wallpapers/$time.jpg 2>/dev/null
        width=$(identify -format %w ~/.wallpapers/$time.jpg) 2>/dev/null
        height=$(identify -format %h ~/.wallpapers/$time.jpg) 2>/dev/null
        [[ "$width" -ge 1920 && "$height" -ge 1050 ]] || startOver  
        feh --bg-fill ~/.wallpapers/$time.jpg 2>/dev/null || startOver 
}
getWallpaper
echo "hope you like your new wp"
