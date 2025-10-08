#!/bin/bash

# Wallpaper Cron Job Kurulum Scripti

echo "🖼️ Wallpaper değiştirme cron job'u kuruluyor..."

# Mevcut crontab'ı yedekle
crontab -l > /tmp/current_crontab 2>/dev/null || touch /tmp/current_crontab

# Wallpaper değiştirme job'unu ekle (her saat başında)
echo "0 * * * * DISPLAY=:0 ~/.config/hypr/scripts/wallpaper-changer.sh" >> /tmp/current_crontab

# Yeni crontab'ı yükle
crontab /tmp/current_crontab

# Temizlik
rm /tmp/current_crontab

echo "✅ Cron job kuruldu! Wallpaper her saat başında değişecek."
echo "📋 Cron job'ları görmek için: crontab -l"