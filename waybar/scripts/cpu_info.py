#!/usr/bin/env python3
import psutil
import json
import glob
import os

def get_cpu_temp():
    try:
        # Try hwmon first
        hwmon_files = glob.glob('/sys/class/hwmon/hwmon*/temp*_input')
        for file_path in hwmon_files:
            try:
                with open(file_path, 'r') as f:
                    temp = int(f.read().strip()) / 1000
                    if 20 <= temp <= 100:
                        return temp
            except:
                continue
        
        # Try thermal zones
        thermal_files = glob.glob('/sys/class/thermal/thermal_zone*/temp')
        for file_path in thermal_files:
            try:
                with open(file_path, 'r') as f:
                    temp = int(f.read().strip()) / 1000
                    if 20 <= temp <= 100:
                        return temp
            except:
                continue
        
        # Try sensors command
        import subprocess
        result = subprocess.run(['sensors', '-A'], capture_output=True, text=True)
        if result.returncode == 0:
            lines = result.stdout.split('\n')
            for line in lines:
                if 'Core' in line and '°C' in line:
                    temp_str = line.split('+')[1].split('°C')[0]
                    return float(temp_str)
        
        return None
    except:
        return None

def get_cpu_power():
    try:
        # Try to get CPU power from RAPL
        power_files = glob.glob('/sys/class/powercap/intel-rapl/intel-rapl:0/power*_uw')
        for file_path in power_files:
            try:
                with open(file_path, 'r') as f:
                    power_uw = int(f.read().strip())
                    power_w = power_uw / 1000000  # Convert microwatts to watts
                    if 0 < power_w < 200:  # Reasonable CPU power range
                        return power_w
            except:
                continue
        
        # Try hwmon power sensors
        hwmon_files = glob.glob('/sys/class/hwmon/hwmon*/power*_input')
        for file_path in hwmon_files:
            try:
                with open(file_path, 'r') as f:
                    power_uw = int(f.read().strip())
                    power_w = power_uw / 1000000
                    if 0 < power_w < 200:
                        return power_w
            except:
                continue
        
        return None
    except:
        return None

def main():
    # Get CPU usage
    cpu_percent = psutil.cpu_percent(interval=1)
    
    # Get CPU temperature
    temp = get_cpu_temp()
    
    # Get CPU power
    power = get_cpu_power()
    
    # Get CPU frequency
    try:
        freq = psutil.cpu_freq()
        current_freq = freq.current / 1000 if freq else None  # Convert to GHz
    except:
        current_freq = None
    
    # Format output
    output = f"󰻠 {cpu_percent:.0f}%"
    
    # Create tooltip info
    tooltip_parts = [f"CPU Usage: {cpu_percent:.1f}%"]
    
    if temp:
        tooltip_parts.append(f"Temperature: {temp:.0f}°C")
    
    if power:
        tooltip_parts.append(f"Power: {power:.1f}W")
    
    if current_freq:
        tooltip_parts.append(f"Frequency: {current_freq:.1f} GHz")
    
    # Get core count
    core_count = psutil.cpu_count(logical=False)
    thread_count = psutil.cpu_count(logical=True)
    tooltip_parts.append(f"Cores: {core_count} ({thread_count} threads)")
    
    # Output JSON for waybar
    result = {
        "text": output,
        "tooltip": "\n".join(tooltip_parts),
        "class": "cpu"
    }
    
    print(json.dumps(result))

if __name__ == "__main__":
    main()