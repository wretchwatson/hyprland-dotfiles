#!/bin/bash

# Wallpaper Değiştirme Scripti
# Her saat başında rastgele wallpaper değiştirir

WALLPAPER_DIR="$HOME/.local/share/wallpaper"
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Wallpaper klasörü kontrolü
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    echo "Wallpaper klasörü boş veya bulunamadı: $WALLPAPER_DIR"
    exit 1
fi

# Rastgele wallpaper seç
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "Uygun wallpaper dosyası bulunamadı"
    exit 1
fi

echo "Yeni wallpaper: $WALLPAPER"

# Hyprctl ile wallpaper değiştir (yeniden başlatmadan)
if pgrep -x "hyprpaper" > /dev/null; then
    # Hyprpaper çalışıyorsa, hyprctl ile değiştir
    hyprctl hyprpaper preload "$WALLPAPER"
    hyprctl hyprpaper wallpaper ",""$WALLPAPER"""
    
    # Config dosyasını da güncelle
    cat > "$HYPRPAPER_CONFIG" << EOF
preload = $WALLPAPER
wallpaper = ,$WALLPAPER

splash = false
ipc = on
EOF
else
    # Hyprpaper çalışmıyorsa, config'i güncelle ve başlat
    cat > "$HYPRPAPER_CONFIG" << EOF
preload = $WALLPAPER
wallpaper = ,$WALLPAPER

splash = false
ipc = on
EOF
    hyprpaper &
fi

echo "Wallpaper değiştirildi: $(basename "$WALLPAPER")"