#!/bin/bash

# Configuration
directory=/home/ridvan/.local/share/wallpaper
monitor="DP-1"
config_file="$HOME/.config/hypr/hyprpaper.conf"

# Find a random image
if [ -d "$directory" ]; then
    random_background=$(find "$directory" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

    if [ -n "$random_background" ]; then
        # Create a perfectly formatted config using the NEW block syntax (v0.8.0+)
        cat > "$config_file" << EOF
wallpaper {
    monitor = 
    path = $random_background
    fit_mode = cover
}

wallpaper {
    monitor = $monitor
    path = $random_background
    fit_mode = cover
}

ipc = on
splash = false
EOF
        
        # Ensure hyprpaper is running
        if ! pgrep -x "hyprpaper" > /dev/null; then
            hyprpaper &
            sleep 1
        fi

        # Try to update live using the NEW IPC format (v0.8.0+)
        # Format: hyprctl hyprpaper wallpaper "monitor, path, fit_mode"
        if ! hyprctl hyprpaper wallpaper ", $random_background, cover" >/dev/null 2>&1; then
            # If IPC fails, restart hyprpaper as fallback
            pkill -9 hyprpaper
            sleep 0.2
            hyprpaper &
        else
            hyprctl hyprpaper wallpaper "$monitor, $random_background, cover"
        fi
        
        notify-send "Wallpaper Changed" "$(basename "$random_background")"
    fi
else
    notify-send "Wallpaper Switcher" "Directory not found: $directory"
fi
