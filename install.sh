#!/bin/bash

# Hyprland Dotfiles Kurulum Betiği
# Kullanıcı: ridvan

echo "🚀 Hyprland Dotfiles Kurulum Başlıyor..."

# Git kurulumu
echo "📦 Git kuruluyor..."
sudo pacman -S --needed git base-devel

# Paru kurulumu
if ! command -v paru &> /dev/null; then
    echo "📦 Paru kuruluyor..."
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
else
    echo "✅ Paru zaten kurulu"
fi

# Ana paketleri yükle
echo "📦 Ana paketler kontrol ediliyor..."
PACMAN_PACKAGES="hyprland hyprpaper waybar wofi mako kitty pcmanfm-qt qt6ct kvantum capitaine-cursors papirus-icon-theme fastfetch cliphist wl-clipboard lxqt-policykit network-manager-applet blueman sddm ttf-font-awesome ttf-nerd-fonts-symbols noto-fonts python python-psutil python-requests grim slurp swappy jq lm_sensors xdg-desktop-portal-hyprland xdg-user-dirs xorg-xdpyinfo xorg-xhost xorg-xinit xorg-xinput xorg-xkill xorg-xrandr amd-ucode gnome-disk-utility gnome-keyring gparted seahorse gvfs-smb htop inxi lxqt-archiver zip unzip unrar micro code discord bc mtr mesa-utils mpv nano noto-fonts-cjk noto-fonts-emoji ntfs-3g nwg-look reflector sbctl yt-dlp zsh curl cronie"

MISSING_PACKAGES=""
for pkg in $PACMAN_PACKAGES; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
        MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
    fi
done

if [ -n "$MISSING_PACKAGES" ]; then
    echo "📦 Eksik paketler kuruluyor:$MISSING_PACKAGES"
    sudo pacman -S --needed $MISSING_PACKAGES
else
    echo "✅ Tüm ana paketler zaten kurulu"
fi

# AUR paketleri
echo "📦 AUR paketleri kontrol ediliyor..."
AUR_PACKAGES="hyprlock wlogout arc-gtk-theme sddm-theme-sugar-candy-git google-chrome fjordlauncher-bin zenpower3-dkms"

MISSING_AUR=""
for pkg in $AUR_PACKAGES; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
        MISSING_AUR="$MISSING_AUR $pkg"
    fi
done

if [ -n "$MISSING_AUR" ]; then
    echo "📦 Eksik AUR paketleri kuruluyor:$MISSING_AUR"
    paru -S --needed $MISSING_AUR
else
    echo "✅ Tüm AUR paketleri zaten kurulu"
fi

# Config ve font klasörlerini oluştur
echo "📁 Config ve font klasörleri oluşturuluyor..."
mkdir -p ~/.config
mkdir -p ~/.local/share
mkdir -p ~/.local/share/wallpaper

# XDG kullanıcı klasörlerini güncelle
echo "📁 XDG kullanıcı klasörleri güncelleniyor..."
xdg-user-dirs-update

# Config dosyalarını kopyala
echo "📋 Config dosyaları kopyalanıyor..."
cp -r hypr ~/.config/
cp -r waybar ~/.config/
cp -r wlogout ~/.config/
cp -r wofi ~/.config/
cp -r mako ~/.config/
cp -r kitty ~/.config/
cp -r fastfetch ~/.config/
cp -r Kvantum ~/.config/
cp -r qt6ct ~/.config/
cp -r gtk-3.0 ~/.config/
cp -r gtk-4.0 ~/.config/
cp -r pcmanfm-qt ~/.config/
cp mimeapps.list ~/.config/

# Zsh config (varsa)
echo "🐚 Zsh ayarları kopyalanıyor..."
if [ -f .zshrc ]; then
    cp .zshrc ~/
fi
if [ -f .p10k.zsh ]; then
    cp .p10k.zsh ~/
fi

# Fontları kopyala
echo "🔤 Fontlar kuruluyor..."
cp -r fonts ~/.local/share/
fc-cache -fv

# Wallpaper'ları kopyala (varsa)
echo "🖼️ Wallpaper'lar kopyalanıyor..."
if [ -d "wallpaper" ] && [ "$(ls -A wallpaper 2>/dev/null)" ]; then
    cp -r wallpaper/* ~/.local/share/wallpaper/
else
    echo "ℹ️ Wallpaper klasörü boş veya bulunamadı"
fi

# SDDM config
echo "🔧 SDDM ayarlanıyor..."
sudo cp sddm.conf /etc/

# Dosya sahipliklerini düzelt
echo "🔧 Dosya sahiplikleri düzeltiliyor..."
sudo chown -R $USER:$USER ~/.config/

# SDDM ve Cronie'yi etkinleştir
echo "🔧 SDDM etkinleştiriliyor..."
sudo systemctl enable sddm
echo "⏰ Cronie (cron) etkinleştiriliyor..."
sudo systemctl enable cronie

# Oh My Zsh kurulumu
if [ ! -d "~/.oh-my-zsh" ]; then
    echo "🐚 Oh My Zsh kuruluyor..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh zaten kurulu"
fi

# Oh My Zsh pluginlerini kur
echo "🔌 Oh My Zsh pluginleri kuruluyor..."
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Zsh'i varsayılan shell yap
echo "🐚 Zsh varsayılan shell yapılıyor..."
sudo chsh -s /usr/bin/zsh $USER

# Wallpaper cron job kur
echo "🖼️ Wallpaper değiştirme cron job'u kuruluyor..."
./setup-wallpaper-cron.sh

echo "✅ Kurulum tamamlandı!"
echo "🔄 Sistemi yeniden başlatın ve SDDM'den Hyprland'ı seçin."
echo "🖼️ Wallpaper'lar her saat başında otomatik değişecek!"