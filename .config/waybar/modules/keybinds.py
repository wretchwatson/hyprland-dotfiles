#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json

# Keybind listesi - Türkçe açıklamalarla
keybinds = {
    "🚀 Temel Kısayollar": {
        "Super + Enter": "Terminal Aç",
        "Super + E": "Dosya Yöneticisi",
        "Super + Q": "Pencereyi Kapat",
        "Super + Space": "Uygulama Başlatıcı",
        "Super + F": "Tam Ekran",
        "Super + V": "Floating/Tiling Değiştir"
    },
    "🌐 Uygulamalar": {
        "Super + W": "Chrome",
        "Super + Shift + W": "Firefox", 
        "Super + C": "VS Code",
        "Super + D": "Discord",
        "Super + L": "Hyprlock",
        "Super + G": "Gnome Disks"
    },
    "🖼️ Ekran Görüntüsü": {
        "Print": "Alan Seç",
        "Ctrl + Print": "Aktif Pencere",
        "Alt + Print": "Tüm Ekran"
    },
    "🔊 Ses Kontrol": {
        "Ses +": "Ses Yükselt",
        "Ses -": "Ses Alçalt", 
        "Ses Mute": "Sessiz/Aç"
    },
    "🎵 Medya": {
        "Medya Play": "Oynat/Duraklat",
        "Medya Next": "Sonraki Parça",
        "Medya Prev": "Önceki Parça"
    },
    "💡 Parlaklık": {
        "Parlaklık +": "Parlaklık Artır",
        "Parlaklık -": "Parlaklık Azalt"
    },
    "🏠 Çalışma Alanları": {
        "Super + 1-9": "Çalışma Alanına Git",
        "Super + Shift + 1-9": "Pencereyi Taşı",
        "Super + . / ,": "Sonraki/Önceki Alan"
    },
    "🔧 Pencere Yönetimi": {
        "Super + R": "Boyutlandırma Modu",
        "Super + K": "Grup Modu",
        "Super + Tab": "Grup İçinde Geç",
        "Alt + Tab": "Pencereler Arası Geç"
    },
    "⚙️ Sistem": {
        "Super + O": "Waybar Yenile",
        "Super + Shift + G": "Varsayılan Boşluklar"
    }
}

# Tooltip HTML oluştur
tooltip_html = ""
for category, binds in keybinds.items():
    tooltip_html += f"<b>{category}</b>\n"
    for key, desc in binds.items():
        tooltip_html += f"  <span color='#025939'>{key}</span> → {desc}\n"
    tooltip_html += "\n"

# JSON çıktısı
output = {
    "text": "⌨️",
    "tooltip": tooltip_html.strip(),
    "class": "keybinds"
}

print(json.dumps(output, ensure_ascii=False))