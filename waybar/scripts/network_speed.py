#!/usr/bin/env python3
import time
import json
import subprocess
import socket
import requests

def get_network_stats():
    try:
        with open('/proc/net/dev', 'r') as f:
            lines = f.readlines()
        
        # Find active interface (not lo)
        for line in lines[2:]:
            parts = line.split()
            interface = parts[0].rstrip(':')
            if interface != 'lo' and int(parts[1]) > 0:  # Has received bytes
                rx_bytes = int(parts[1])
                tx_bytes = int(parts[9])
                return interface, rx_bytes, tx_bytes
        
        return None, 0, 0
    except:
        return None, 0, 0

def bytes_to_mbits(bytes_val):
    return (bytes_val * 8) / (1024 * 1024)

def get_local_ip():
    try:
        # Connect to a remote address to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except:
        return None

def get_public_ip():
    try:
        # Try multiple services for public IP
        services = [
            "https://api.ipify.org",
            "https://ipinfo.io/ip",
            "https://icanhazip.com"
        ]
        
        for service in services:
            try:
                response = requests.get(service, timeout=3)
                if response.status_code == 200:
                    return response.text.strip()
            except:
                continue
        return None
    except:
        return None

def main():
    interface, rx1, tx1 = get_network_stats()
    
    if not interface:
        result = {
            "text": "󰞉 No Connection",
            "tooltip": "No network connection",
            "class": "network"
        }
        print(json.dumps(result))
        return
    
    time.sleep(1)
    
    interface, rx2, tx2 = get_network_stats()
    
    if not interface:
        result = {
            "text": "󰞉 No Connection",
            "tooltip": "No network connection",
            "class": "network"
        }
        print(json.dumps(result))
        return
    
    rx_speed = bytes_to_mbits(rx2 - rx1)
    tx_speed = bytes_to_mbits(tx2 - tx1)
    
    # Get IP addresses
    local_ip = get_local_ip()
    public_ip = get_public_ip()
    
    # Format output
    output = f"󰞉 ↓{rx_speed:.1f} ↑{tx_speed:.1f}"
    
    # Create tooltip
    tooltip_parts = [
        f"Interface: {interface}",
        f"Download: {rx_speed:.1f} Mbps",
        f"Upload: {tx_speed:.1f} Mbps"
    ]
    
    if local_ip:
        tooltip_parts.append(f"Local IP: {local_ip}")
    
    if public_ip:
        tooltip_parts.append(f"Public IP: {public_ip}")
    
    # Output JSON for waybar
    result = {
        "text": output,
        "tooltip": "\n".join(tooltip_parts),
        "class": "network"
    }
    
    print(json.dumps(result))

if __name__ == "__main__":
    main()