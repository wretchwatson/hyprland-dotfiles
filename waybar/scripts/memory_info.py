#!/usr/bin/env python3
import psutil
import json
import os

def bytes_to_gb(bytes_val):
    return bytes_val / (1024**3)

def bytes_to_mb(bytes_val):
    return bytes_val / (1024**2)

def get_memory_info():
    try:
        # Get memory info
        memory = psutil.virtual_memory()
        swap = psutil.swap_memory()
        
        return {
            'total': memory.total,
            'available': memory.available,
            'used': memory.used,
            'free': memory.free,
            'percent': memory.percent,
            'cached': getattr(memory, 'cached', 0),
            'buffers': getattr(memory, 'buffers', 0),
            'swap_total': swap.total,
            'swap_used': swap.used,
            'swap_percent': swap.percent
        }
    except:
        return None

def get_top_processes():
    try:
        # Get top 5 memory consuming processes
        processes = []
        for proc in psutil.process_iter(['pid', 'name', 'memory_percent']):
            try:
                processes.append(proc.info)
            except:
                continue
        
        # Sort by memory usage and get top 5
        processes.sort(key=lambda x: x['memory_percent'], reverse=True)
        return processes[:5]
    except:
        return []

def main():
    mem_info = get_memory_info()
    
    if not mem_info:
        result = {
            "text": "󰍛 Error",
            "tooltip": "Memory monitoring error",
            "class": "memory"
        }
        print(json.dumps(result))
        return
    
    # Format output
    output = f"󰍛 {mem_info['percent']:.0f}%"
    
    # Create detailed tooltip
    tooltip_parts = []
    
    # Memory usage
    used_gb = bytes_to_gb(mem_info['used'])
    total_gb = bytes_to_gb(mem_info['total'])
    available_gb = bytes_to_gb(mem_info['available'])
    
    tooltip_parts.append(f"Memory Usage: {mem_info['percent']:.1f}%")
    tooltip_parts.append(f"Used: {used_gb:.1f}GB / {total_gb:.1f}GB")
    tooltip_parts.append(f"Available: {available_gb:.1f}GB")
    
    # Cache and buffers info
    if mem_info['cached'] > 0:
        cached_gb = bytes_to_gb(mem_info['cached'])
        tooltip_parts.append(f"Cached: {cached_gb:.1f}GB")
    
    if mem_info['buffers'] > 0:
        buffers_gb = bytes_to_gb(mem_info['buffers'])
        tooltip_parts.append(f"Buffers: {buffers_gb:.1f}GB")
    
    # Swap info
    if mem_info['swap_total'] > 0:
        swap_used_gb = bytes_to_gb(mem_info['swap_used'])
        swap_total_gb = bytes_to_gb(mem_info['swap_total'])
        tooltip_parts.append(f"Swap: {swap_used_gb:.1f}GB / {swap_total_gb:.1f}GB ({mem_info['swap_percent']:.1f}%)")
    else:
        tooltip_parts.append("Swap: Not configured")
    
    # Top processes
    top_procs = get_top_processes()
    if top_procs:
        tooltip_parts.append("")
        tooltip_parts.append("Top Memory Users:")
        for proc in top_procs:
            if proc['memory_percent'] > 0.1:  # Only show processes using > 0.1%
                tooltip_parts.append(f"  {proc['name']}: {proc['memory_percent']:.1f}%")
    
    # Output JSON for waybar
    result = {
        "text": output,
        "tooltip": "\n".join(tooltip_parts),
        "class": "memory"
    }
    
    print(json.dumps(result))

if __name__ == "__main__":
    main()