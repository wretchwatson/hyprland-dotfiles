#!/usr/bin/env python3
"""CPU temperature monitoring module for Waybar."""

import json
import os
import subprocess


def get_cpu_temp():
    """Get CPU temperature from various sensors.
    
    Returns:
        int: CPU temperature in Celsius, 0 if unable to read.
    """
    try:
        # k10temp sensöründen CPU sıcaklığını al
        result = subprocess.run(
            ['sensors', '-A', '-j'], 
            capture_output=True, 
            text=True, 
            check=False
        )
        if result.returncode == 0:
            data = json.loads(result.stdout)
            
            # k10temp sensörünü bul
            if 'k10temp-pci-00c3' in data:
                temp_data = data['k10temp-pci-00c3']
                if 'Tctl' in temp_data:
                    temp = temp_data['Tctl']['temp1_input']
                    return int(temp)
            
            # Alternatif olarak gigabyte_wmi'den al
            if 'gigabyte_wmi-virtual-0' in data:
                temp_data = data['gigabyte_wmi-virtual-0']
                if 'temp1' in temp_data:
                    temp = temp_data['temp1']['temp1_input']
                    return int(temp)
                    
        # Fallback: hwmon'dan direkt oku
        with open('/sys/class/hwmon/hwmon0/temp1_input', 'r', encoding='utf-8') as f:
            temp = int(f.read().strip()) // 1000
            return temp
            
    except (subprocess.SubprocessError, json.JSONDecodeError, 
            FileNotFoundError, ValueError, OSError):
        # Son çare: sensors komutunu parse et
        try:
            result = subprocess.run(
                ['sensors'], 
                capture_output=True, 
                text=True, 
                check=False
            )
            for line in result.stdout.split('\n'):
                if 'Tctl:' in line:
                    temp_str = line.split('+')[1].split('°')[0]
                    return int(float(temp_str))
        except (subprocess.SubprocessError, IndexError, ValueError):
            return 0
    return 0

def get_cpu_usage():
    """Get CPU usage percentage.
    
    Returns:
        float: CPU usage percentage, 0 if unable to read.
    """
    try:
        # /proc/stat'tan CPU kullanımını hesapla
        with open('/proc/stat', 'r', encoding='utf-8') as f:
            line = f.readline()
        cpu_times = [int(x) for x in line.split()[1:]]
        idle_time = cpu_times[3]
        total_time = sum(cpu_times)
        usage = round(100 * (total_time - idle_time) / total_time, 1)
        return usage
    except (FileNotFoundError, ValueError, IndexError, OSError):
        return 0

def get_cpu_power():
    """Get CPU power consumption.
    
    Returns:
        float: CPU power in Watts, 0 if unable to read.
    """
    try:
        # AMD CPU power - zenpower sensörü
        result = subprocess.run(
            ['sensors', '-A', '-j'], 
            capture_output=True, 
            text=True, 
            check=False
        )
        if result.returncode == 0:
            data = json.loads(result.stdout)
            # zenpower sensörünü ara
            for sensor_name in data:
                if 'zenpower' in sensor_name.lower():
                    sensor_data = data[sensor_name]
                    for key in sensor_data:
                        if ('power' in key.lower() and 
                            'input' in sensor_data[key]):
                            power = sensor_data[key]['power1_input']
                            return round(power, 1)
        
        # Alternatif: hwmon'dan direkt oku
        for hwmon in os.listdir('/sys/class/hwmon/'):
            try:
                power_file = f'/sys/class/hwmon/{hwmon}/power1_input'
                with open(power_file, 'r', encoding='utf-8') as f:
                    # microWatt to Watt
                    power = int(f.read().strip()) / 1000000
                    return round(power, 1)
            except (FileNotFoundError, ValueError, OSError):
                continue
                
    except (subprocess.SubprocessError, json.JSONDecodeError, 
            FileNotFoundError, OSError):
        return 0
    return 0

def main():
    """Main function to generate CPU temperature output for Waybar."""
    temp = get_cpu_temp()
    usage = get_cpu_usage()
    power = get_cpu_power()
    
    # Determine status based on temperature
    if temp >= 80:
        class_name = "critical"
    elif temp >= 70:
        class_name = "warning"
    elif temp >= 60:
        class_name = "high"
    else:
        class_name = "normal"
    
    tooltip = f"CPU Sıcaklığı: {temp}°C\nKullanım: {usage}%"
    if power > 0:
        tooltip += f"\nGüç: {power}W"
    else:
        tooltip += "\nGüç: N/A"
    
    output = {
        "text": f"CPU {temp}°C",
        "tooltip": tooltip,
        "class": class_name
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    main()