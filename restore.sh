#!/bin/bash

# Hyprland & System Configuration Restoration Script
# Created for: ridvan

DOTFILES_DIR="$HOME/hyprland-dotfiles"
CONFIG_BACKUP="$DOTFILES_DIR/config"
ETC_BACKUP="$DOTFILES_DIR/etc"

# Colors for TTY visibility
GREEN='\033[0;32m'
NC='\033[0m' # No Color

msg() {
    echo -e "${GREEN}==> $1${NC}"
}

msg "Restoration process starting..."

# 1. Package Installation
msg "Installing native packages from pkglist.txt..."
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist.txt"
    msg "Native packages installed successfully."
else
    echo "⚠️ pkglist.txt not found, skipping native package install."
fi

msg "Installing AUR packages from aurpkglist.txt..."
if [ -f "$DOTFILES_DIR/aurpkglist.txt" ]; then
    if ! command -v paru > /dev/null && ! command -v yay > /dev/null; then
        msg "AUR helper not found. Installing paru (from source)..."
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        (cd /tmp/paru && makepkg -si --noconfirm)
        rm -rf /tmp/paru
        msg "Paru installed successfully."
    fi

    if command -v paru > /dev/null; then
        paru -S --needed --noconfirm $(cat "$DOTFILES_DIR/aurpkglist.txt")
        msg "AUR packages (via paru) installed successfully."
    elif command -v yay > /dev/null; then
        yay -S --needed --noconfirm $(cat "$DOTFILES_DIR/aurpkglist.txt")
        msg "AUR packages (via yay) installed successfully."
    else
        echo "⚠️ Failed to install an AUR helper. Skipping AUR packages."
    fi
else
    echo "⚠️ aurpkglist.txt not found, skipping AUR package install."
fi

# 2. Restore .config Folders
msg "Restoring .config folders..."
mkdir -p "$HOME/.config"
if [ -d "$CONFIG_BACKUP" ]; then
    cp -rv "$CONFIG_BACKUP"/* "$HOME/.config/"
    msg ".config folders restored."
else
    echo "⚠️ Configuration backup directory not found."
fi

# 3. Restore Home Dotfiles
msg "Restoring home directory dotfiles (.zshrc, .p10k.zsh, .gtkrc-2.0)..."
cp -v "$DOTFILES_DIR/.zshrc" "$HOME/" 2>/dev/null
cp -v "$DOTFILES_DIR/.p10k.zsh" "$HOME/" 2>/dev/null
cp -v "$DOTFILES_DIR/.gtkrc-2.0" "$HOME/" 2>/dev/null
msg "Home dotfiles restored."

# 4. Apply GTK Settings (gsettings)
msg "Applying GTK theme settings..."
gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark-compact'
gsettings set org.gnome.desktop.interface icon-theme 'Fluent-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Fluent-dark-cursors'
gsettings set org.gnome.desktop.interface font-name 'Comfortaa Medium 11'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
msg "GTK settings applied."

# 5. Zsh Environment (Oh My Zsh & Plugins)
msg "Setting up Zsh environment (Oh My Zsh & Plugins)..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    msg "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    msg "Oh My Zsh installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
msg "Installing Zsh plugins..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

msg "Installing Powerlevel10k theme..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi
msg "Zsh plugins and theme installed."

# 6. Restore System Configs
msg "Restoring system-level configurations (sudo required)..."

# Locale Generation
msg "Configuring locale (en_US.UTF-8)..."
if [ -f "/etc/locale.gen" ]; then
    sudo sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
    if ! grep -q "^en_US.UTF-8 UTF-8" /etc/locale.gen; then
        echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
    fi
    sudo locale-gen
    msg "Locale generated successfully."
fi

# SDDM Config
if [ -f "$ETC_BACKUP/sddm.conf" ]; then
    sudo cp -v "$ETC_BACKUP/sddm.conf" "/etc/sddm.conf"
fi
if [ -d "$ETC_BACKUP/sddm.conf.d" ]; then
    sudo mkdir -p "/etc/etc/sddm.conf.d"
    sudo cp -rv "$ETC_BACKUP/sddm.conf.d"/* "/etc/etc/sddm.conf.d/"
fi
msg "Activating SDDM service..."
sudo systemctl enable sddm
msg "System configurations restored and SDDM enabled."

# 7. Final Environment Update
msg "Updating XDG user directories..."
xdg-user-dirs-update
msg "XDG user directories updated."

msg "✅ Restoration complete! Please restart your session."
