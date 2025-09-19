#!/home/ridvan/.myenv/bin/python3

import psutil
import json
import time
import os
import socket
import requests
import threading

# Ölçüm durumunu dosyada sakla
STATE_FILE = "/tmp/network_speed_state.json"
IP_CACHE_FILE = "/tmp/network_ip_cache.json"
IP_CACHE_TIMEOUT = 300  # 5 dakika

def load_state():
    """Önceki durumu dosyadan yükle"""
    try:
        if os.path.exists(STATE_FILE):
            with open(STATE_FILE, 'r') as f:
                return json.load(f)
    except:
        pass
    return None

def save_state(bytes_sent, bytes_recv, timestamp):
    """Mevcut durumu dosyaya kaydet"""
    state = {
        'last_bytes_sent': bytes_sent,
        'last_bytes_recv': bytes_recv,
        'last_timestamp': timestamp
    }
    try:
        with open(STATE_FILE, 'w') as f:
            json.dump(state, f)
    except:
        pass

def get_local_ip(interface="enp9s0"):
    """Local IP adresini al"""
    try:
        addresses = psutil.net_if_addrs()
        if interface in addresses:
            for addr in addresses[interface]:
                if addr.family == socket.AF_INET:
                    return addr.address
        return "Bulunamadı"
    except:
        return "Hata"

def get_external_ip():
    """External IP adresini al (cache'li)"""
    try:
        # Cache kontrolü
        if os.path.exists(IP_CACHE_FILE):
            with open(IP_CACHE_FILE, 'r') as f:
                cache_data = json.load(f)
                if time.time() - cache_data['timestamp'] < IP_CACHE_TIMEOUT:
                    return cache_data['ip']
    except:
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
                with open(IP_CACHE_FILE, 'w') as f:
                    json.dump(cache_data, f)
                
                return external_ip
        except:
            continue
    
    # Cache'ten dön (eğer varsa)
    try:
        if os.path.exists(IP_CACHE_FILE):
            with open(IP_CACHE_FILE, 'r') as f:
                return json.load(f)['ip']
    except:
        pass
    
    return "Bulunamadı"

def get_smooth_color(value, thresholds, colors):
    """Yumuşak renk geçişi sağla"""
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
                hex_color = hex_color.lstrip('#')
                return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
            
            def rgb_to_hex(rgb):
                return '#{:02x}{:02x}{:02x}'.format(*rgb)
            
            rgb_lower = hex_to_rgb(colors[i-1])
            rgb_upper = hex_to_rgb(colors[i])
            
            rgb_result = [
                int(rgb_lower[j] + (rgb_upper[j] - rgb_lower[j]) * ratio)
                for j in range(3)
            ]
            
            return rgb_to_hex(rgb_result)
    
    return colors[-1]

def get_network_speed(interface="enp9s0"):
    """Ağ hızını ölç"""
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

def get_network_info(interface="enp9s0"):
    """Tüm ağ bilgilerini topla"""
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

if __name__ == "__main__":
    try:
        download, upload, error, local_ip, external_ip = get_network_info("enp9s0")
        
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
            
            # Tooltip
            tooltip_text = f"""Arayüz: enp9s0
Local IP: {local_ip}
External IP: {external_ip}
Download: {download:.2f} Mbit/s
Upload: {upload:.2f} Mbit/s"""
            
            output = {
                "text": f"🌐 <span color='{download_color}'>↓{download_display:.1f}</span> <span color='{upload_color}'>↑{upload_display:.1f}</span>",
                "tooltip": tooltip_text,
                "class": "network-speed"
            }
        
        print(json.dumps(output))
        
    except Exception as e:
        error_output = {
            "text": "❌ Hata",
            "tooltip": f"Script hatası: {str(e)}",
            "class": "error"
        }
        print(json.dumps(error_output))