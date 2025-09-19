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

echo -e "${BLUE}1. Paru AUR helper kontrol ediliyor ve yükleniyor...${NC}"

# Paru kontrolü ve kurulumu
if ! command -v paru &> /dev/null; then
    echo -e "${YELLOW}Paru bulunamadı, yükleniyor...${NC}"
    
    # Git ve base-devel paketlerini yükle
    sudo pacman -S --needed --noconfirm git base-devel
    
    # Paru'yu AUR'dan yükle
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
    
    echo -e "${GREEN}Paru başarıyla yüklendi!${NC}"
else
    echo -e "${GREEN}Paru zaten yüklü.${NC}"
fi

echo -e "${BLUE}2. Paketler yükleniyor...${NC}"

# Paket listesi dosyalarını kontrol et
if [ ! -f "./packages.txt" ]; then
    echo -e "${RED}packages.txt dosyası bulunamadı!${NC}"
    exit 1
fi

if [ ! -f "./aur-packages.txt" ]; then
    echo -e "${RED}aur-packages.txt dosyası bulunamadı!${NC}"
    exit 1
fi

# Ana paketleri yükle
if command -v pacman &> /dev/null; then
    echo "Pacman paketleri yükleniyor..."
    sudo pacman -S --needed --noconfirm - < packages.txt
else
    echo -e "${RED}Pacman bulunamadı! Bu script Arch Linux için tasarlanmıştır.${NC}"
    exit 1
fi

# Paru ile AUR paketleri yükle
echo "Paru ile AUR paketleri yükleniyor..."
paru -S --needed --noconfirm - < aur-packages.txt

echo -e "${BLUE}3. Konfigürasyon dosyaları kopyalanıyor...${NC}"

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

echo -e "${BLUE}4. Python sanal ortamı kuruluyor...${NC}"
# Waybar modülleri için Python sanal ortamı
if [ ! -d "~/.myenv" ]; then
    python -m venv ~/.myenv
    ~/.myenv/bin/pip install psutil requests
    echo -e "${GREEN}Python sanal ortamı oluşturuldu.${NC}"
else
    echo -e "${GREEN}Python sanal ortamı zaten mevcut.${NC}"
fi

echo -e "${BLUE}5. Font cache güncelleniyor...${NC}"
fc-cache -fv

echo -e "${BLUE}6. SDDM teması kuruluyor...${NC}"
if [ -d "sddm-theme" ]; then
    sudo cp -r sddm-theme/* /usr/share/sddm/themes/
    
    # SDDM konfigürasyon dosyasını oluştur
    echo -e "${YELLOW}SDDM konfigürasyonu oluşturuluyor...${NC}"
    sudo tee /etc/sddm.conf > /dev/null <<EOF
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=corners-new
CursorTheme=capitaine-cursors
Font=Noto Sans,10,-1,0,50,0,0,0,0,0

[Users]
MaximumUid=60513
MinimumUid=1000
EOF
    echo -e "${GREEN}SDDM konfigürasyonu oluşturuldu.${NC}"
else
    echo -e "${YELLOW}sddm-theme klasörü bulunamadı, SDDM teması atlanıyor.${NC}"
fi

echo -e "${BLUE}7. Servisler etkinleştiriliyor...${NC}"
sudo systemctl enable sddm
sudo systemctl enable bluetooth

echo -e "${BLUE}8. Son ayarlar yapılıyor...${NC}"
# Waybar modüllerini çalıştırılabilir yap
chmod +x ~/.config/waybar/modules/*.py 2>/dev/null || true
chmod +x ~/.config/waybar/modules/*.sh 2>/dev/null || true
chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true

# Cliphist daemon'ını başlat
if command -v cliphist &> /dev/null; then
    pkill cliphist 2>/dev/null || true
    cliphist daemon &
    echo -e "${GREEN}Cliphist daemon başlatıldı.${NC}"
fi

echo -e "${GREEN}✅ Kurulum tamamlandı!${NC}"
echo -e "${YELLOW}Sistemi yeniden başlatmanız önerilir.${NC}"
echo ""
echo -e "${BLUE}Kullanım:${NC}"
echo "• Super + Return: Terminal"
echo "• Super + Space: Uygulama başlatıcısı"
echo "• Super + E: Dosya yöneticisi"
echo "• Super + L: Ekranı kilitle"
echo "• Super + Shift + E: Efekt toggle"
echo "• Super + O: Waybar yenile"
echo ""
echo -e "${GREEN}İyi kullanımlar! 🎉${NC}"
