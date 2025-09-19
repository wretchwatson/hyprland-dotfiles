#!/usr/bin/env python3
"""GPU temperature monitoring module for Waybar."""

import json
import subprocess


def get_gpu_temp():
    """Get GPU temperature from NVIDIA or AMD sensors.
    
    Returns:
        int: GPU temperature in Celsius, 0 if unable to read.
    """
    try:
        # NVIDIA GPU sıcaklığını al
        result = subprocess.run(
            ['nvidia-smi', '--query-gpu=temperature.gpu', 
             '--format=csv,noheader,nounits'], 
            capture_output=True, 
            text=True, 
            check=False
        )
        if result.returncode == 0:
            temp = int(result.stdout.strip())
            return temp
            
        # AMD GPU için alternatif
        result = subprocess.run(
            ['sensors'], 
            capture_output=True, 
            text=True, 
            check=False
        )
        for line in result.stdout.split('\n'):
            if 'edge:' in line.lower() or 'junction:' in line.lower():
                temp_str = line.split('+')[1].split('°')[0]
                return int(float(temp_str))
                
    except (subprocess.SubprocessError, ValueError, IndexError):
        return 0
    return 0

def get_gpu_usage_and_power():
    """Get GPU usage and power consumption.
    
    Returns:
        tuple: (usage_percentage, power_watts) or (0, 0) if unable to read.
    """
    try:
        # NVIDIA GPU kullanım ve güç bilgisi
        result = subprocess.run(
            ['nvidia-smi', '--query-gpu=utilization.gpu,power.draw', 
             '--format=csv,noheader,nounits'], 
            capture_output=True, 
            text=True, 
            check=False
        )
        if result.returncode == 0:
            data = result.stdout.strip().split(', ')
            usage = int(data[0])
            power = float(data[1])
            return usage, power
    except (subprocess.SubprocessError, ValueError, IndexError):
        return 0, 0
    return 0, 0

def main():
    """Main function to generate GPU temperature output for Waybar."""
    temp = get_gpu_temp()
    usage, power = get_gpu_usage_and_power()
    
    if temp == 0:
        output = {
            "text": "󰢮 N/A",
            "tooltip": "GPU sıcaklığı okunamadı",
            "class": "error"
        }
    else:
        # Determine status based on temperature
        if temp >= 85:
            class_name = "critical"
        elif temp >= 75:
            class_name = "warning"
        elif temp >= 65:
            class_name = "high"
        else:
            class_name = "normal"
        
        tooltip = f"GPU Sıcaklığı: {temp}°C\nKullanım: {usage}%"
        if power > 0:
            tooltip += f"\nGüç: {power}W"
        
        output = {
            "text": f"GPU {temp}°C",
            "tooltip": tooltip,
            "class": class_name
        }
    
    print(json.dumps(output))

if __name__ == "__main__":
    main()