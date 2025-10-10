#!/bin/bash

# Wallpaper Cron Job Kurulum Scripti

echo "🖼️ Wallpaper değiştirme cron job'u kuruluyor..."

# Mevcut crontab'ı yedekle
crontab -l > /tmp/current_crontab 2>/dev/null || touch /tmp/current_crontab

# Eski wallpaper job'larını temizle
grep -v "wallpaper-changer.sh" /tmp/current_crontab > /tmp/clean_crontab || touch /tmp/clean_crontab

# Wallpaper değiştirme job'unu ekle (her saat başında) - Wayland için
echo "0 * * * * XDG_RUNTIME_DIR=/run/user/$(id -u) ~/.config/hypr/scripts/wallpaper-changer.sh" >> /tmp/clean_crontab

# Yeni crontab'ı yükle
crontab /tmp/clean_crontab

# Temizlik
rm /tmp/current_crontab /tmp/clean_crontab

echo "✅ Cron job kuruldu! Wallpaper her saat başında değişecek."
echo "📋 Cron job'ları görmek için: crontab -l"