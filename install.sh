#!/bin/bash

# Hyprland Dotfiles Kurulum Betiği
# Kullanıcı: ridvan

echo "🚀 Hyprland Dotfiles Kurulum Başlıyor..."

# Git kurulumu
echo "📦 Git kuruluyor..."
sudo pacman -S --needed git base-devel

# Paru kurulumu
echo "📦 Paru kuruluyor..."
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ~

# Ana paketleri yükle
echo "📦 Ana paketler kuruluyor..."
sudo pacman -S --needed hyprland hyprpaper wlogout waybar wofi mako kitty pcmanfm-qt qt6ct kvantum capitaine-cursors arc-gtk-theme papirus-icon-theme fastfetch cliphist wl-clipboard lxqt-policykit-agent network-manager-applet blueman sddm ttf-font-awesome ttf-nerd-fonts-symbols noto-fonts python python-psutil python-requests grim slurp swappy jq lm_sensors xdg-desktop-portal-hyprland xdg-user-dirs xorg-xdpyinfo xorg-xhost xorg-xinit xorg-xinput xorg-xkill xorg-xrandr amd-ucode gnome-disk-utility gnome-keyring gparted seahorse gvfs-smb htop inxi lxqt-archiver zip unzip unrar micro code discord bc mtr mesa-utils mpv nano noto-fonts-cjk noto-fonts-emoji ntfs-3g nwg-look reflector sbctl yt-dlp zsh curl

# AUR paketleri
echo "📦 AUR paketleri kuruluyor..."
paru -S --needed hyprlock sddm-theme-sugar-candy-git

# Config ve font klasörlerini oluştur
echo "📁 Config ve font klasörleri oluşturuluyor..."
mkdir -p /home/ridvan/.config
mkdir -p /home/ridvan/.local/share

# Config dosyalarını kopyala
echo "📋 Config dosyaları kopyalanıyor..."
cp -r hypr /home/ridvan/.config/
cp -r waybar /home/ridvan/.config/
cp -r wlogout /home/ridvan/.config/
cp -r wofi /home/ridvan/.config/
cp -r mako /home/ridvan/.config/
cp -r kitty /home/ridvan/.config/
cp -r fastfetch /home/ridvan/.config/
cp -r Kvantum /home/ridvan/.config/
cp -r qt6ct /home/ridvan/.config/
cp mimeapps.list /home/ridvan/.config/

# Zsh config (varsa)
echo "🐚 Zsh ayarları kopyalanıyor..."
if [ -f .zshrc ]; then
    cp .zshrc /home/ridvan/
fi
if [ -f .p10k.zsh ]; then
    cp .p10k.zsh /home/ridvan/
fi

# Fontları kopyala
echo "🔤 Fontlar kuruluyor..."
cp -r fonts /home/ridvan/.local/share/
fc-cache -fv

# SDDM config
echo "🔧 SDDM ayarlanıyor..."
sudo cp sddm.conf /etc/

# Dosya sahipliklerini düzelt
echo "🔧 Dosya sahiplikleri düzeltiliyor..."
sudo chown -R ridvan:ridvan /home/ridvan/.config/

# SDDM'i etkinleştir
echo "🔧 SDDM etkinleştiriliyor..."
sudo systemctl enable sddm

# GTK ayarları
echo "🎨 GTK ayarları yapılıyor..."
gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'

# Oh My Zsh kurulumu
echo "🐚 Oh My Zsh kuruluyor..."
su - ridvan -c 'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Oh My Zsh pluginlerini kur
echo "🔌 Oh My Zsh pluginleri kuruluyor..."
su - ridvan -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
su - ridvan -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
su - ridvan -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k'

# Zsh'i varsayılan shell yap
echo "🐚 Zsh varsayılan shell yapılıyor..."
sudo chsh -s /usr/bin/zsh ridvan

echo "✅ Kurulum tamamlandı!"
echo "🔄 Sistemi yeniden başlatın ve SDDM'den Hyprland'ı seçin."