#!/bin/bash
# Your choice in dmenu will determine what autorandr command to run
chosen=$(ls -1 "$HOME/.config/autorandr" | dmenu -i)
# This is used to determine which external display you have connected
# This may vary between OS. e.g VGA1 instead of VGA-1

autorandr "$chosen"
