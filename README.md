# Hyprland Dotfiles

Modern ve şık Hyprland masaüstü konfigürasyonu.

## 🖥️ Ekran Görüntüleri

![Desktop](screenshots/desktop.png)

## ✨ Özellikler

- **Window Manager**: Hyprland (Wayland)
- **Status Bar**: Waybar (özel modüller ile)
- **Application Launcher**: Wofi
- **Terminal**: Kitty
- **File Manager**: PCManFM-Qt
- **Notification Daemon**: Mako
- **Screen Locker**: Hyprlock
- **Logout Menu**: Wlogout
- **Theme**: Modern dark theme with Quicksand font
- **Icons**: Papirus-Dark
- **Cursor**: Bibata-Modern-Classic

## 📦 Kurulum

### 1. Paketleri Yükle

```bash
# Ana paketler
sudo pacman -S --needed - < packages.txt

# AUR paketleri (paru kullanarak)
paru -S --needed - < aur-packages.txt
```

### 2. Dotfiles'ları Kopyala

```bash
# Bu repo'yu klonla
git clone https://github.com/kullaniciadi/hyprland-dotfiles.git
cd hyprland-dotfiles

# Konfigürasyon dosyalarını kopyala
cp -r .config/* ~/.config/
cp -r .fonts/* ~/.local/share/fonts/
cp -r .icons/* ~/.local/share/icons/
cp -r .themes/* ~/.local/share/themes/
cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh
cp .gtkrc-2.0 ~/.gtkrc-2.0

# Font cache'i güncelle
fc-cache -fv
```

### 3. SDDM Temasını Kur

```bash
sudo cp -r sddm-theme/* /usr/share/sddm/themes/
sudo nano /etc/sddm.conf
# [Theme] bölümünde Current=tema_adi olarak ayarla
```

### 4. Servisleri Etkinleştir

```bash
sudo systemctl enable sddm
sudo systemctl enable bluetooth
```

## 🎨 Konfigürasyon

### Waybar Modülleri

- **CPU/GPU Sıcaklık**: Gerçek zamanlı sıcaklık gösterimi
- **Ağ Hızı**: Upload/Download hızları
- **Türkçe Tarih**: Türkçe tarih ve saat
- **Hava Durumu**: Anlık hava durumu
- **Clipboard**: Clipboard geçmişi
- **Emoji Picker**: Wofi-emoji entegrasyonu
- **Screenshot**: Grim/Slurp ile ekran görüntüsü
- **Keybinds**: Klavye kısayolları gösterimi

### Hyprland Kısayolları

| Kısayol | Açıklama |
|---------|----------|
| `Super + Q` | Terminal aç |
| `Super + C` | Pencereyi kapat |
| `Super + M` | Çıkış menüsü |
| `Super + E` | Dosya yöneticisi |
| `Super + V` | Clipboard geçmişi |
| `Super + L` | Ekranı kilitle |
| `Super + Space` | Uygulama başlatıcısı |
| `Super + P` | Güç menüsü |
| `Super + 1-9` | Workspace değiştir |

### Zsh Aliases

```bash
# Pacman kısayolları
alias up='sudo pacman -Syu'
alias in='sudo pacman -S'
alias search='pacman -Ss'

# Paru kısayolları  
alias pup='paru -Syu'
alias pin='paru -S'
alias psearch='paru -Ss'

# Diğer
alias n='nano'
alias sn='sudo nano'
```

## 🛠️ Özelleştirme

### Renk Teması Değiştirme

Waybar ve Hyprland renklerini değiştirmek için:
- `~/.config/waybar/style.css`
- `~/.config/hypr/hyprland.conf`

### Font Değiştirme

Ana font Quicksand. Değiştirmek için:
- `~/.config/waybar/style.css` (font-family)
- `~/.config/hypr/hyprlock.conf` (font_family)

## 📋 Gereksinimler

- Arch Linux tabanlı dağıtım
- Wayland desteği
- GPU sürücüleri (NVIDIA için ek konfigürasyon gerekebilir)

## 🐛 Sorun Giderme

### Hyprland başlamıyor
```bash
# Log kontrol et
journalctl -u sddm
```

### Waybar modülleri çalışmıyor
```bash
# Python modüllerini kontrol et
python ~/.config/waybar/modules/cpu_temp.py
```

### Font görünmüyor
```bash
# Font cache'i yenile
fc-cache -fv
fc-list | grep Quicksand
```

## 📄 Lisans

MIT License

## 🤝 Katkıda Bulunma

Pull request'ler memnuniyetle karşılanır!

## 📞 İletişim

- GitHub: [@kullaniciadi](https://github.com/kullaniciadi)