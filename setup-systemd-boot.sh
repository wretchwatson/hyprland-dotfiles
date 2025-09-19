#!/bin/bash

# Systemd-boot Kurulum ve Konfigürasyon Scripti
# Bu script systemd-boot'u kurar ve arch.conf dosyasını oluşturur

echo "🚀 Systemd-boot Kurulumu Başlıyor..."

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hata kontrolü
set -e

# Root kontrolü
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Bu script root olarak çalıştırılmalıdır!${NC}"
    echo "Kullanım: sudo ./setup-systemd-boot.sh"
    exit 1
fi

echo -e "${BLUE}1. Systemd-boot yükleniyor...${NC}"
bootctl install

echo -e "${BLUE}2. Root partition tespit ediliyor...${NC}"
ROOT_PARTITION=$(findmnt -n -o SOURCE /)
echo -e "${GREEN}Root partition: $ROOT_PARTITION${NC}"

echo -e "${BLUE}3. Loader konfigürasyonu oluşturuluyor...${NC}"
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

echo -e "${BLUE}4. Arch Linux boot entry oluşturuluyor...${NC}"
cat > /boot/loader/entries/arch.conf << EOF
title Arch Linux
linux /vmlinuz-linux-lts
initrd /amd-ucode.img
initrd /initramfs-linux-lts.img
options root=$ROOT_PARTITION rw quiet splash
EOF

echo -e "${BLUE}5. Fallback boot entry oluşturuluyor...${NC}"
cat > /boot/loader/entries/arch-fallback.conf << EOF
title Arch Linux (Fallback)
linux /vmlinuz-linux-lts
initrd /amd-ucode.img
initrd /initramfs-linux-lts-fallback.img
options root=$ROOT_PARTITION rw
EOF

echo -e "${BLUE}6. Boot entry'leri kontrol ediliyor...${NC}"
echo -e "${YELLOW}Oluşturulan dosyalar:${NC}"
ls -la /boot/loader/entries/

echo -e "${BLUE}7. Systemd-boot durumu kontrol ediliyor...${NC}"
bootctl status

echo -e "${GREEN}✅ Systemd-boot kurulumu tamamlandı!${NC}"
echo ""
echo -e "${BLUE}Oluşturulan boot entry'ler:${NC}"
echo "• arch.conf - Ana Arch Linux boot entry"
echo "• arch-fallback.conf - Yedek boot entry"
echo ""
echo -e "${YELLOW}Not: Kernel güncellemelerinden sonra bu script'i tekrar çalıştırabilirsiniz.${NC}"
echo -e "${GREEN}Sistemi yeniden başlatabilirsiniz! 🎉${NC}"