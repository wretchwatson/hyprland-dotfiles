#!/bin/bash

playerctl -p spotify metadata --format '{{title}}|{{artist}}' --follow 2>/dev/null | while IFS='|' read -r title artist; do
    if [ -n "$title" ] && [ -n "$artist" ]; then
        notify-send -a "Spotify" "$title" "$artist" -i spotify-client
    fi
done
