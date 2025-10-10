#!/bin/bash

# Hyprland Dotfiles Kurulum Betiği
# Kullanıcı: ridvan

echo "🚀 Hyprland Dotfiles Kurulum Başlıyor..."

# Scriptin doğru dizinde çalıştırıldığını kontrol et
if [ ! -f "hypr/hyprland.conf" ] || [ ! -f "waybar/config" ]; then
    echo "❌ Hata: Script hyprland-dotfiles klasöründe çalıştırılmalı!"
    echo "📁 Lütfen 'cd ~/hyprland-dotfiles' komutu ile doğru dizine geçin."
    exit 1
fi

echo "✅ Dotfiles klasörü bulundu, kuruluma devam ediliyor..."

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

# Her dosyayı ayrı ayrı kontrol ederek kopyala
CONFIG_DIRS="hypr waybar wlogout wofi mako kitty fastfetch Kvantum qt6ct gtk-3.0 gtk-4.0 pcmanfm-qt"
for dir in $CONFIG_DIRS; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir kopyalanıyor..."
        cp -r "$dir" ~/.config/ || echo "  ⚠️ $dir kopyalanamadı"
    else
        echo "  ⚠️ $dir klasörü bulunamadı"
    fi
done

# Tek dosyaları kopyala
if [ -f "mimeapps.list" ]; then
    echo "  ✓ mimeapps.list kopyalanıyor..."
    cp mimeapps.list ~/.config/ || echo "  ⚠️ mimeapps.list kopyalanamadı"
else
    echo "  ⚠️ mimeapps.list bulunamadı"
fi

# Zsh config (varsa)
echo "🐚 Zsh ayarları kopyalanıyor..."
if [ -f ".zshrc" ]; then
    echo "  ✓ .zshrc kopyalanıyor..."
    cp .zshrc ~/ || echo "  ⚠️ .zshrc kopyalanamadı"
else
    echo "  ⚠️ .zshrc bulunamadı"
fi

if [ -f ".p10k.zsh" ]; then
    echo "  ✓ .p10k.zsh kopyalanıyor..."
    cp .p10k.zsh ~/ || echo "  ⚠️ .p10k.zsh kopyalanamadı"
else
    echo "  ⚠️ .p10k.zsh bulunamadı"
fi

# Fontları kopyala
echo "🔤 Fontlar kuruluyor..."
if [ -d "fonts" ]; then
    echo "  ✓ Fontlar kopyalanıyor..."
    cp -r fonts ~/.local/share/ || echo "  ⚠️ Fontlar kopyalanamadı"
    echo "  ✓ Font cache güncelleniyor..."
    fc-cache -fv
else
    echo "  ⚠️ fonts klasörü bulunamadı"
fi

# Wallpaper'ları kopyala (varsa)
echo "🖼️ Wallpaper'lar kopyalanıyor..."
if [ -d "wallpaper" ] && [ "$(ls -A wallpaper 2>/dev/null)" ]; then
    cp -r wallpaper/* ~/.local/share/wallpaper/
else
    echo "ℹ️ Wallpaper klasörü boş veya bulunamadı"
fi

# SDDM config
echo "🔧 SDDM ayarlanıyor..."
if [ -f "sddm.conf" ]; then
    echo "  ✓ SDDM config kopyalanıyor..."
    sudo cp sddm.conf /etc/ || echo "  ⚠️ SDDM config kopyalanamadı"
else
    echo "  ⚠️ sddm.conf bulunamadı"
fi

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
if [ -f "setup-wallpaper-cron.sh" ]; then
    chmod +x setup-wallpaper-cron.sh
    ./setup-wallpaper-cron.sh || echo "  ⚠️ Wallpaper cron job kurulamadı"
else
    echo "  ⚠️ setup-wallpaper-cron.sh bulunamadı"
fi

echo ""
echo "✅ Kurulum tamamlandı!"
echo "📋 Kurulum özeti:"
echo "  • Paketler: ✓ Kuruldu"
echo "  • Config dosyaları: ✓ Kopyalandı"
echo "  • Fontlar: ✓ Kuruldu"
echo "  • SDDM: ✓ Ayarlandı"
echo "  • Zsh: ✓ Yapılandırıldı"
echo ""
echo "🔄 Sistemi yeniden başlatın ve SDDM'den Hyprland'ı seçin."
echo "🖼️ Wallpaper'lar her saat başında otomatik değişecek!"
echo "📁 Wallpaper'larınızı ~/.local/share/wallpaper/ klasörüne ekleyin."