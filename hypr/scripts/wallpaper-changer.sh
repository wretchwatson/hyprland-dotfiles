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

# Hyprpaper config dosyasını güncelle
cat > "$HYPRPAPER_CONFIG" << EOF
preload = $WALLPAPER
wallpaper = ,$WALLPAPER

splash = false
ipc = on
EOF

# Hyprpaper'ı yeniden başlat
pkill hyprpaper
sleep 1
hyprpaper &

echo "Wallpaper değiştirildi: $(basename "$WALLPAPER")"