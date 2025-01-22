#! /bin/bash


function archivebox {
    local ARGS=()
    if [ "$1" == "add" ] ; then
        shift
        ARGS+=("add" "--extract" "singlefile,title,favicon")
    fi
    ARGS+=("$@")
    echo CHROME_USER_DATA_DIR="$HOME/.config/archivebox/chrome_profile" CHROME_USER_AGENT='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36' TIMEOUT=120 command archivebox "${ARGS[@]}"
}
