#!/bin/bash

# Mikrofon ses seviyesini kalıcı hale getir
# İstediğin seviyeyi buradan ayarla (örnek: 100% = 65536, 150% = 98304)

MIC_VOLUME="98304"  # %150 seviyesi, istersen değiştirebilirsin %100 = 65536 %150 = 98304 %50 = 32768

# Tüm input cihazlarına uygula
pactl list sources short | grep input | awk '{print $2}' | while read -r source; do
    pactl set-source-volume "$source" "$MIC_VOLUME"
done
