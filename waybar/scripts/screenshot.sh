#!/bin/bash

# Create screenshots directory if it doesn't exist
mkdir -p ~/Resimler

# Get current timestamp
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

case "$1" in
    "full")
        # Full screen screenshot
        grim - | swappy -f - -o ~/Resimler/screenshot_${timestamp}.png
        ;;
    "area")
        # Area selection screenshot
        grim -g "$(slurp)" - | swappy -f - -o ~/Resimler/screenshot_${timestamp}.png
        ;;
    "window")
        # Current window screenshot
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | swappy -f - -o ~/Resimler/screenshot_${timestamp}.png
        ;;
    *)
        echo "Usage: $0 {full|area|window}"
        exit 1
        ;;
esac