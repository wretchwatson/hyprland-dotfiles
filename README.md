# Hypr-Mini Dotfiles

Bu repo Hyprland masaüstü ortamı için kişisel ayarlarımı içerir.

## İçerik

- **hypr/**: Hyprland ana konfigürasyonu
- **waybar/**: Waybar panel ayarları
- **wlogout/**: Çıkış menüsü (Türkçe)
- **wofi/**: Uygulama başlatıcısı
- **mako/**: Bildirim sistemi
- **kitty/**: Terminal emülatörü
- **fastfetch/**: Sistem bilgi gösterici
- **Kvantum/**: Qt tema motoru
- **qt6ct/**: Qt6 tema ayarları
- **fonts/**: Quicksand font dosyaları
- **.zshrc**: Zsh shell ayarları (varsa)
- **.p10k.zsh**: Powerlevel10k tema ayarları (varsa)
- **sddm.conf**: SDDM giriş ekranı ayarları
- **mimeapps.list**: Varsayılan uygulama ayarları

## Otomatik Kurulum

```bash
# Kurulum betiğini çalıştır
./install.sh
```

## Manuel Kurulum

```bash
# Config klasörüne kopyala
cp -r hypr ~/.config/
cp -r waybar ~/.config/
cp -r wlogout ~/.config/
cp -r wofi ~/.config/
cp -r mako ~/.config/
cp -r kitty ~/.config/
cp -r fastfetch ~/.config/
cp -r Kvantum ~/.config/
cp -r qt6ct ~/.config/
cp mimeapps.list ~/.config/

# SDDM config (root yetkisi gerekli)
sudo cp sddm.conf /etc/
```

## Gerekli Paketler

Tüm paket listesi için `packages.txt` dosyasına bakın.

## Özellikler

- Capitaine-cursors tema desteği
- PCManFM-Qt varsayılan dosya yöneticisi
- Türkçe wlogout menüsü
- Qt6 ve GTK tema uyumluluğu