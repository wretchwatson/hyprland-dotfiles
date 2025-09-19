#!/bin/bash

# Hyprland Efekt Toggle Scripti
# Super + Shift + E ile efektleri aç/kapat

# Efekt durumunu kontrol et
EFFECTS_FILE="/tmp/hypr_effects_state"

if [ -f "$EFFECTS_FILE" ]; then
    # Efektler kapalı, aç
    hyprctl --batch "\
        keyword decoration:blur:enabled true;\
        keyword decoration:drop_shadow true;\
        keyword decoration:rounding 12;\
        keyword animations:enabled true;\
        keyword general:border_size 2"
    
    rm "$EFFECTS_FILE"
    notify-send "🎨 Hyprland Efektleri" "Efektler Açıldı" -t 2000
else
    # Efektler açık, kapat
    hyprctl --batch "\
        keyword decoration:blur:enabled false;\
        keyword decoration:drop_shadow false;\
        keyword decoration:rounding 0;\
        keyword animations:enabled false;\
        keyword general:border_size 1"
    
    touch "$EFFECTS_FILE"
    notify-send "⚡ Hyprland Efektleri" "Efektler Kapatıldı (Performans Modu)" -t 2000
fi