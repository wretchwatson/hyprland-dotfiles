#!/usr/bin/env python3
import subprocess
import json

try:
    status = subprocess.run(['systemctl', 'is-active', 'tailscaled.service'], 
                          capture_output=True, text=True).stdout.strip()
    
    if status == 'active':
        print(json.dumps({"text": "󰖂", "tooltip": "Tailscale: Aktif", "class": "active"}))
    else:
        print(json.dumps({"text": "󰖂", "tooltip": "Tailscale: Kapalı", "class": "inactive"}))
except:
    print(json.dumps({"text": "󰖂", "tooltip": "Tailscale: Bilinmiyor", "class": "inactive"}))
