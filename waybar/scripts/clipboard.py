#!/usr/bin/env python3
import subprocess
import json
import os

def get_clipboard_content():
    try:
        # Get clipboard content using wl-paste
        result = subprocess.run(['wl-paste'], capture_output=True, text=True, timeout=2)
        if result.returncode == 0:
            content = result.stdout.strip()
            if content:
                # Limit content length for display
                if len(content) > 30:
                    display_content = content[:27] + "..."
                else:
                    display_content = content
                
                # Replace newlines with spaces for display
                display_content = display_content.replace('\n', ' ').replace('\r', ' ')
                
                return content, display_content
        return None, None
    except:
        return None, None

def get_clipboard_history():
    try:
        # Get clipboard history using cliphist if available
        result = subprocess.run(['cliphist', 'list'], capture_output=True, text=True, timeout=3)
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')[:5]  # Get last 5 items
            return [line.strip() for line in lines if line.strip()]
        return []
    except:
        return []

def main():
    content, display_content = get_clipboard_content()
    
    if content:
        # Format output
        output = "📋"
        
        # Create tooltip with clipboard history
        tooltip_parts = ["Clipboard Content:"]
        tooltip_parts.append(f"Current: {content[:100]}{'...' if len(content) > 100 else ''}")
        
        # Add history if available
        history = get_clipboard_history()
        if history:
            tooltip_parts.append("\nRecent History:")
            for item in history[:3]:
                # Clean up history item - cliphist format is "number\tcontent"
                if '\t' in item:
                    clean_item = item.split('\t', 1)[1]  # Get content after tab
                else:
                    clean_item = item
                
                if len(clean_item) > 50:
                    clean_item = clean_item[:47] + "..."
                tooltip_parts.append(f"• {clean_item}")
        
        tooltip_parts.append("\nClick: Open clipboard manager")
        
        result = {
            "text": output,
            "tooltip": "\n".join(tooltip_parts),
            "class": "clipboard"
        }
    else:
        result = {
            "text": "📋",
            "tooltip": "Clipboard is empty\nClick: Open clipboard manager",
            "class": "clipboard"
        }
    
    print(json.dumps(result))

if __name__ == "__main__":
    main()