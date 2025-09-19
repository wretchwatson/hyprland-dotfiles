#!/home/ridvan/.myenv/bin/python3
"""Network speed monitoring module for Waybar."""

import json
import os
import socket
import threading
import time

import psutil
import requests

# Ölçüm durumunu dosyada sakla
STATE_FILE = "/tmp/network_speed_state.json"
IP_CACHE_FILE = "/tmp/network_ip_cache.json"
IP_CACHE_TIMEOUT = 300  # 5 dakika

def load_state():
    """Önceki durumu dosyadan yükle.
    
    Returns:
        dict or None: Previous state data or None if unable to load.
    """
    try:
        if os.path.exists(STATE_FILE):
            with open(STATE_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return None
    return None

def save_state(bytes_sent, bytes_recv, timestamp):
    """Mevcut durumu dosyaya kaydet.
    
    Args:
        bytes_sent (int): Sent bytes count.
        bytes_recv (int): Received bytes count.
        timestamp (float): Current timestamp.
    """
    state = {
        'last_bytes_sent': bytes_sent,
        'last_bytes_recv': bytes_recv,
        'last_timestamp': timestamp
    }
    try:
        with open(STATE_FILE, 'w', encoding='utf-8') as f:
            json.dump(state, f)
    except (FileNotFoundError, OSError):
        pass

def get_active_interface():
    """Aktif internet bağlantısı olan interface'i bul.
    
    Returns:
        str: Active network interface name or None.
    """
    try:
        # Default route'u kontrol et
        with open('/proc/net/route', 'r', encoding='utf-8') as f:
            for line in f:
                fields = line.strip().split()
                if len(fields) >= 2 and fields[1] == '00000000':  # Default route
                    return fields[0]
    except (FileNotFoundError, OSError):
        pass
    
    # Alternatif: psutil ile aktif interface'leri kontrol et
    try:
        stats = psutil.net_io_counters(pernic=True)
        addresses = psutil.net_if_addrs()
        
        for interface, addrs in addresses.items():
            # Loopback ve down interface'leri atla
            if interface.startswith('lo') or interface.startswith('docker'):
                continue
                
            # IPv4 adresi olan interface'leri kontrol et
            has_ipv4 = any(addr.family == socket.AF_INET and 
                          not addr.address.startswith('127.') 
                          for addr in addrs)
            
            # Aktif trafik olan interface'leri kontrol et
            if (has_ipv4 and interface in stats and 
                (stats[interface].bytes_sent > 0 or stats[interface].bytes_recv > 0)):
                return interface
                
    except (OSError, AttributeError):
        pass
    
    # Son çare: bilinen interface isimlerini dene
    common_interfaces = ['enp9s0', 'eth0', 'wlan0', 'wlp3s0', 'eno1']
    stats = psutil.net_io_counters(pernic=True)
    
    for interface in common_interfaces:
        if interface in stats:
            return interface
    
    return None

def get_local_ip(interface=None):
    """Local IP adresini al.
    
    Args:
        interface (str): Network interface name.
        
    Returns:
        str: Local IP address or error message.
    """
    if interface is None:
        interface = get_active_interface()
        
    if interface is None:
        return "Interface bulunamadı"
        
    try:
        addresses = psutil.net_if_addrs()
        if interface in addresses:
            for addr in addresses[interface]:
                if addr.family == socket.AF_INET:
                    return addr.address
        return "Bulunamadı"
    except (OSError, AttributeError):
        return "Hata"

def get_external_ip():
    """External IP adresini al (cache'li).
    
    Returns:
        str: External IP address or error message.
    """
    try:
        # Cache kontrolü
        if os.path.exists(IP_CACHE_FILE):
            with open(IP_CACHE_FILE, 'r', encoding='utf-8') as f:
                cache_data = json.load(f)
                if time.time() - cache_data['timestamp'] < IP_CACHE_TIMEOUT:
                    return cache_data['ip']
    except (FileNotFoundError, json.JSONDecodeError, KeyError, OSError):
        pass
    
    # IP servisleri listesi (yedekli)
    ip_services = [
        "https://api.ipify.org",
        "https://icanhazip.com",
        "https://ident.me",
        "https://checkip.amazonaws.com"
    ]
    
    for service in ip_services:
        try:
            response = requests.get(service, timeout=5)
            if response.status_code == 200:
                external_ip = response.text.strip()
                
                # Cache'e kaydet
                cache_data = {
                    'ip': external_ip,
                    'timestamp': time.time()
                }
                with open(IP_CACHE_FILE, 'w', encoding='utf-8') as f:
                    json.dump(cache_data, f)
                
                return external_ip
        except (requests.RequestException, OSError):
            continue
    
    # Cache'ten dön (eğer varsa)
    try:
        if os.path.exists(IP_CACHE_FILE):
            with open(IP_CACHE_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)['ip']
    except (FileNotFoundError, json.JSONDecodeError, KeyError, OSError):
        pass
    
    return "Bulunamadı"

def get_smooth_color(value, thresholds, colors):
    """Yumuşak renk geçişi sağla.
    
    Args:
        value (float): Current value to map to color.
        thresholds (list): Threshold values for color mapping.
        colors (list): Color values corresponding to thresholds.
        
    Returns:
        str: Hex color code.
    """
    if value <= thresholds[0]:
        return colors[0]
    elif value >= thresholds[-1]:
        return colors[-1]
    
    for i in range(1, len(thresholds)):
        if value <= thresholds[i]:
            lower_thresh = thresholds[i-1]
            upper_thresh = thresholds[i]
            ratio = (value - lower_thresh) / (upper_thresh - lower_thresh)
            
            def hex_to_rgb(hex_color):
                """Convert hex color to RGB tuple."""
                hex_color = hex_color.lstrip('#')
                return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
            
            def rgb_to_hex(rgb):
                """Convert RGB tuple to hex color."""
                return '#{:02x}{:02x}{:02x}'.format(*rgb)
            
            rgb_lower = hex_to_rgb(colors[i-1])
            rgb_upper = hex_to_rgb(colors[i])
            
            rgb_result = [
                int(rgb_lower[j] + (rgb_upper[j] - rgb_lower[j]) * ratio)
                for j in range(3)
            ]
            
            return rgb_to_hex(rgb_result)
    
    return colors[-1]

def get_network_speed(interface=None):
    """Ağ hızını ölç.
    
    Args:
        interface (str): Network interface name.
        
    Returns:
        tuple: (download_speed, upload_speed, error_message)
    """
    if interface is None:
        interface = get_active_interface()
        
    if interface is None:
        return None, None, "Aktif ağ interface'i bulunamadı"
        
    all_interfaces = psutil.net_io_counters(pernic=True)
    
    if interface not in all_interfaces:
        return None, None, f"{interface} arayüzü bulunamadı"
    
    current_bytes_sent = all_interfaces[interface].bytes_sent
    current_bytes_recv = all_interfaces[interface].bytes_recv
    current_time = time.time()
    
    previous_state = load_state()
    
    if previous_state is None:
        save_state(current_bytes_sent, current_bytes_recv, current_time)
        return 0, 0, None
    
    prev_bytes_sent = previous_state['last_bytes_sent']
    prev_bytes_recv = previous_state['last_bytes_recv']
    prev_time = previous_state['last_timestamp']
    
    time_diff = current_time - prev_time
    if time_diff <= 0:
        time_diff = 1
    
    bytes_sent_diff = current_bytes_sent - prev_bytes_sent
    bytes_recv_diff = current_bytes_recv - prev_bytes_recv
    
    if bytes_sent_diff < 0:
        bytes_sent_diff = 0
    if bytes_recv_diff < 0:
        bytes_recv_diff = 0
    
    upload_speed = (bytes_sent_diff * 8) / (time_diff * 1024 * 1024)
    download_speed = (bytes_recv_diff * 8) / (time_diff * 1024 * 1024)
    
    save_state(current_bytes_sent, current_bytes_recv, current_time)
    
    return download_speed, upload_speed, None

def get_network_info(interface=None):
    """Tüm ağ bilgilerini topla.
    
    Args:
        interface (str): Network interface name.
        
    Returns:
        tuple: (download, upload, error, local_ip, external_ip)
    """
    download, upload, error = get_network_speed(interface)
    
    # IP bilgilerini thread'lerde al (performans için)
    local_ip = "Yükleniyor..."
    external_ip = "Yükleniyor..."
    
    def fetch_ips():
        nonlocal local_ip, external_ip
        local_ip = get_local_ip(interface)
        external_ip = get_external_ip()
    
    # Thread başlat
    ip_thread = threading.Thread(target=fetch_ips)
    ip_thread.daemon = True
    ip_thread.start()
    ip_thread.join(timeout=2)  # Maksimum 2 saniye bekle
    
    return download, upload, error, local_ip, external_ip

def main():
    """Main function to generate network speed output for Waybar."""
    try:
        # Aktif interface'i otomatik bul
        active_interface = get_active_interface()
        if active_interface is None:
            output = {
                "text": "⚠️ Ağ",
                "tooltip": "Aktif ağ interface'i bulunamadı",
                "class": "error"
            }
            print(json.dumps(output))
            return
            
        download, upload, error, local_ip, external_ip = get_network_info(active_interface)
        
        if error:
            output = {
                "text": "⚠️ Ağ",
                "tooltip": error,
                "class": "error"
            }
        else:
            download_display = round(download, 1) if download >= 0.05 else 0
            upload_display = round(upload, 1) if upload >= 0.05 else 0
            
            # Renkler
            upload_thresholds = [0, 5, 10]
            upload_colors = ["#a3be8c", "#ebcb8b", "#bf616a"]
            upload_color = get_smooth_color(upload, upload_thresholds, upload_colors)
            
            download_thresholds = [0, 25, 50]
            download_colors = ["#a3be8c", "#ebcb8b", "#bf616a"]
            download_color = get_smooth_color(download, download_thresholds, download_colors)
            
            # Hız seviyesine göre CSS class belirle
            total_speed = download + upload
            if total_speed == 0:
                speed_class = "network-speed inactive"
            elif total_speed < 10:
                speed_class = "network-speed low"
            elif total_speed < 50:
                speed_class = "network-speed medium"
            else:
                speed_class = "network-speed high"
            
            # Tooltip
            tooltip_text = f"""Arayüz: {active_interface}
Local IP: {local_ip}
External IP: {external_ip}
Download: {download:.2f} Mbit/s
Upload: {upload:.2f} Mbit/s"""
            
            output = {
                "text": f"🌐 <span color='{download_color}'>↓{download_display:.1f}</span> <span color='{upload_color}'>↑{upload_display:.1f}</span>",
                "tooltip": tooltip_text,
                "class": speed_class
            }
        
        print(json.dumps(output))
        
    except Exception as e:
        error_output = {
            "text": "❌ Hata",
            "tooltip": f"Script hatası: {str(e)}",
            "class": "error"
        }
        print(json.dumps(error_output))


if __name__ == "__main__":
    main()