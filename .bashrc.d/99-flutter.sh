function cdf {
    local CURDIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
    local FILENAMES=()

    local GROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

    if [[ -z "$GROOT" ]] ; then
        echo "Not a git repo!"
    fi

    # bash on macos will not handle exclamation marks in math expressions correctly!
    while read FILENAME ; do 
        if [[ $(yq -r '.flutter != null' "$FILENAME") != true ]] ; then
            continue
        fi 
        if [[ $(yq -r '.flutter != null and .flutter.plugin != null' "$FILENAME") == true ]] ; then
            continue
        fi

        FILENAME="$(readlink -m "$(dirname "$FILENAME")")"
        FILENAMES+=("$FILENAME")
    done < <( find "$GROOT" -iname 'pubspec.yaml' )

    local LAUNCH_JSON="$GROOT/.vscode/launch.json" 
    if [[ ${#FILENAMES[@]} -gt 0 ]] ; then
        while read VSCODEPATH ; do
            VSCODEPATH="$(readlink -m "$GROOT/$VSCODEPATH")"
            for FILENAME in "${FILENAMES[@]}" ; do
                if [[ "$FILENAME" == "$VSCODEPATH" ]] ; then
                    cd "$FILENAME"
                    return
                fi
            done
        done < <( dart run "$CURDIR/cdf/bin/cdf.dart" "$LAUNCH_JSON" )

        for FILENAME in "${FILENAMES[@]}" ; do
            cd "$FILENAME"
            return
        done
    fi

    echo 'No matching dart projects!'
}
