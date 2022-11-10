#! /bin/bash

export PATH="$PATH:/opt/homebrew/bin"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
jq -r '..|.language? | select(.)' storage.json | head -1

TEAMS_PATH="$(dirname "$(ps -x -o command | grep Contents/MacOS/Teams | grep -v grep)")"
if [ -z "$TEAMS_PATH" ] ; then
    exit 0;
fi

STORAGE_FILE="$HOME/Library/Application Support/Microsoft/Teams/storage.json"
TEAMS_LOCALE="$(jq -r '..|.language? | select(.)' "$STORAGE_FILE" | head -1)"
LOCALE_FILE="$TEAMS_PATH/../Resources/locales/locale-$TEAMS_LOCALE.json"
SETTINGS_STRING="$(jq -r .strings.usertask_settings "$LOCALE_FILE")"

osascript "$SCRIPT_DIR/daynight.applescript" "$DARKMODE" "$SETTINGS_STRING"
