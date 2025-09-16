#!/bin/bash

# Hyprland Dotfiles Kurulum Scripti
# Bu script dotfiles'ları otomatik olarak kurar

echo "🚀 Hyprland Dotfiles Kurulumu Başlıyor..."

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hata kontrolü
set -e

# Yedekleme fonksiyonu
backup_existing() {
    local target=$1
    if [ -e "$target" ]; then
        echo -e "${YELLOW}Mevcut $target yedekleniyor...${NC}"
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

echo -e "${BLUE}1. Paketler yükleniyor...${NC}"

# Ana paketleri yükle
if command -v pacman &> /dev/null; then
    echo "Pacman paketleri yükleniyor..."
    sudo pacman -S --needed --noconfirm - < packages.txt
else
    echo -e "${RED}Pacman bulunamadı! Bu script Arch Linux için tasarlanmıştır.${NC}"
    exit 1
fi

# AUR helper kontrolü
if command -v paru &> /dev/null; then
    echo "Paru ile AUR paketleri yükleniyor..."
    paru -S --needed --noconfirm - < aur-packages.txt
elif command -v yay &> /dev/null; then
    echo "Yay ile AUR paketleri yükleniyor..."
    yay -S --needed --noconfirm - < aur-packages.txt
else
    echo -e "${YELLOW}AUR helper bulunamadı. AUR paketlerini manuel yüklemeniz gerekecek.${NC}"
    echo "AUR paketleri: $(cat aur-packages.txt | tr '\n' ' ')"
fi

echo -e "${BLUE}2. Konfigürasyon dosyaları kopyalanıyor...${NC}"

# Gerekli dizinleri oluştur
mkdir -p ~/.config
mkdir -p ~/.local/share/fonts
mkdir -p ~/.local/share/icons
mkdir -p ~/.local/share/themes

# Konfigürasyon dosyalarını yedekle ve kopyala
backup_existing ~/.config/hypr
backup_existing ~/.config/waybar
backup_existing ~/.config/kitty
backup_existing ~/.config/mako
backup_existing ~/.config/wofi
backup_existing ~/.config/wlogout
backup_existing ~/.zshrc
backup_existing ~/.p10k.zsh

# Dosyaları kopyala
cp -r .config/* ~/.config/
cp -r .fonts/* ~/.local/share/fonts/
cp -r .icons/* ~/.local/share/icons/ 2>/dev/null || true
cp -r .themes/* ~/.local/share/themes/
cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh
cp .gtkrc-2.0 ~/.gtkrc-2.0

echo -e "${BLUE}3. Font cache güncelleniyor...${NC}"
fc-cache -fv

echo -e "${BLUE}4. SDDM teması kuruluyor...${NC}"
if [ -d "sddm-theme" ]; then
    sudo cp -r sddm-theme/* /usr/share/sddm/themes/
    echo -e "${YELLOW}SDDM konfigürasyonunu manuel olarak ayarlamanız gerekiyor:${NC}"
    echo "sudo nano /etc/sddm.conf"
    echo "[Theme] bölümünde Current=corners-new olarak ayarlayın"
fi

echo -e "${BLUE}5. Servisler etkinleştiriliyor...${NC}"
sudo systemctl enable sddm
sudo systemctl enable bluetooth

echo -e "${GREEN}✅ Kurulum tamamlandı!${NC}"
echo -e "${YELLOW}Sistemi yeniden başlatmanız önerilir.${NC}"
echo ""
echo -e "${BLUE}Kullanım:${NC}"
echo "• Super + Q: Terminal"
echo "• Super + Space: Uygulama başlatıcısı"
echo "• Super + E: Dosya yöneticisi"
echo "• Super + L: Ekranı kilitle"
echo "• Super + M: Çıkış menüsü"
echo ""
echo -e "${GREEN}İyi kullanımlar! 🎉${NC}"