#!/bin/bash

# Get clipboard history without numbers for display
selected=$(cliphist list | cut -f2- | wofi --dmenu --prompt='Clipboard History')

if [ -n "$selected" ]; then
    # Find the original entry with number and decode it
    cliphist list | grep -F "$selected" | head -1 | cliphist decode | wl-copy
fi