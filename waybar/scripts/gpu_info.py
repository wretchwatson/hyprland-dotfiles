#!/usr/bin/env python3
import subprocess
import json
import glob
import os
import re

def get_nvidia_info():
    try:
        # Try nvidia-smi
        result = subprocess.run(['nvidia-smi', '--query-gpu=utilization.gpu,temperature.gpu,power.draw,memory.used,memory.total,name', '--format=csv,noheader,nounits'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            line = result.stdout.strip()
            parts = line.split(', ')
            return {
                'usage': float(parts[0]),
                'temp': float(parts[1]),
                'power': float(parts[2]),
                'mem_used': float(parts[3]),
                'mem_total': float(parts[4]),
                'name': parts[5],
                'type': 'nvidia'
            }
    except:
        pass
    return None

def get_amd_info():
    try:
        # Try AMD GPU info from sysfs
        gpu_dirs = glob.glob('/sys/class/drm/card*/device')
        for gpu_dir in gpu_dirs:
            try:
                # Check if it's AMD GPU
                with open(f"{gpu_dir}/vendor", 'r') as f:
                    vendor = f.read().strip()
                if vendor == "0x1002":  # AMD vendor ID
                    info = {'type': 'amd'}
                    
                    # Get GPU usage
                    gpu_busy_file = f"{gpu_dir}/gpu_busy_percent"
                    if os.path.exists(gpu_busy_file):
                        with open(gpu_busy_file, 'r') as f:
                            info['usage'] = float(f.read().strip())
                    
                    # Get temperature
                    temp_files = glob.glob(f"{gpu_dir}/hwmon/hwmon*/temp*_input")
                    for temp_file in temp_files:
                        with open(temp_file, 'r') as f:
                            temp = int(f.read().strip()) / 1000
                            if 20 <= temp <= 120:
                                info['temp'] = temp
                                break
                    
                    # Get power
                    power_files = glob.glob(f"{gpu_dir}/hwmon/hwmon*/power*_average")
                    for power_file in power_files:
                        with open(power_file, 'r') as f:
                            power = int(f.read().strip()) / 1000000  # Convert to watts
                            if 0 < power < 500:
                                info['power'] = power
                                break
                    
                    # Get memory info
                    mem_info_file = f"{gpu_dir}/mem_info_vram_used"
                    mem_total_file = f"{gpu_dir}/mem_info_vram_total"
                    if os.path.exists(mem_info_file) and os.path.exists(mem_total_file):
                        with open(mem_info_file, 'r') as f:
                            info['mem_used'] = int(f.read().strip()) / (1024**2)  # Convert to MB
                        with open(mem_total_file, 'r') as f:
                            info['mem_total'] = int(f.read().strip()) / (1024**2)
                    
                    # Get GPU name
                    try:
                        result = subprocess.run(['lspci', '-d', '1002:', '-nn'], capture_output=True, text=True)
                        if result.returncode == 0:
                            for line in result.stdout.split('\n'):
                                if 'VGA' in line or 'Display' in line:
                                    info['name'] = line.split(': ')[1].split(' [')[0]
                                    break
                    except:
                        info['name'] = "AMD GPU"
                    
                    return info
            except:
                continue
    except:
        pass
    return None

def get_intel_info():
    try:
        # Try Intel GPU info
        intel_dirs = glob.glob('/sys/class/drm/card*/device')
        for gpu_dir in intel_dirs:
            try:
                with open(f"{gpu_dir}/vendor", 'r') as f:
                    vendor = f.read().strip()
                if vendor == "0x8086":  # Intel vendor ID
                    info = {'type': 'intel'}
                    
                    # Intel GPU usage from debugfs (if available)
                    try:
                        with open('/sys/kernel/debug/dri/0/i915_engine_info', 'r') as f:
                            content = f.read()
                            # Parse engine usage - this is approximate
                            usage_match = re.search(r'render.*?(\d+)%', content)
                            if usage_match:
                                info['usage'] = float(usage_match.group(1))
                    except:
                        pass
                    
                    # Get temperature if available
                    temp_files = glob.glob(f"{gpu_dir}/hwmon/hwmon*/temp*_input")
                    for temp_file in temp_files:
                        with open(temp_file, 'r') as f:
                            temp = int(f.read().strip()) / 1000
                            if 20 <= temp <= 120:
                                info['temp'] = temp
                                break
                    
                    # Get GPU name
                    try:
                        result = subprocess.run(['lspci', '-d', '8086:', '-nn'], capture_output=True, text=True)
                        if result.returncode == 0:
                            for line in result.stdout.split('\n'):
                                if 'VGA' in line or 'Display' in line:
                                    info['name'] = line.split(': ')[1].split(' [')[0]
                                    break
                    except:
                        info['name'] = "Intel GPU"
                    
                    return info
            except:
                continue
    except:
        pass
    return None

def main():
    # Try to get GPU info from different sources
    gpu_info = get_nvidia_info() or get_amd_info() or get_intel_info()
    
    if not gpu_info:
        # Fallback - just show that GPU exists
        try:
            result = subprocess.run(['lspci'], capture_output=True, text=True)
            if 'VGA' in result.stdout or 'Display' in result.stdout:
                print(json.dumps({
                    "text": "󰢮 N/A",
                    "tooltip": "GPU detected but no monitoring available",
                    "class": "gpu"
                }))
            else:
                print(json.dumps({
                    "text": "󰢮 No GPU",
                    "tooltip": "No GPU detected",
                    "class": "gpu"
                }))
        except:
            print(json.dumps({
                "text": "󰢮 Error",
                "tooltip": "GPU monitoring error",
                "class": "gpu"
            }))
        return
    
    # Format output
    usage = gpu_info.get('usage', 0)
    output = f"󰢮 {usage:.0f}%"
    
    # Create tooltip
    tooltip_parts = []
    
    if 'name' in gpu_info:
        tooltip_parts.append(f"GPU: {gpu_info['name']}")
    
    tooltip_parts.append(f"Usage: {usage:.1f}%")
    
    if 'temp' in gpu_info:
        tooltip_parts.append(f"Temperature: {gpu_info['temp']:.0f}°C")
    
    if 'power' in gpu_info:
        tooltip_parts.append(f"Power: {gpu_info['power']:.1f}W")
    
    if 'mem_used' in gpu_info and 'mem_total' in gpu_info:
        mem_percent = (gpu_info['mem_used'] / gpu_info['mem_total']) * 100
        tooltip_parts.append(f"VRAM: {gpu_info['mem_used']:.0f}MB / {gpu_info['mem_total']:.0f}MB ({mem_percent:.1f}%)")
    
    # Output JSON for waybar
    result = {
        "text": output,
        "tooltip": "\n".join(tooltip_parts),
        "class": "gpu"
    }
    
    print(json.dumps(result))

if __name__ == "__main__":
    main()