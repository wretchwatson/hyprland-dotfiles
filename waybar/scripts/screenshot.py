#!/usr/bin/env python3
import json
import os
from datetime import datetime

def main():
    # Get screenshot directory
    screenshot_dir = os.path.expanduser("~/Resimler")
    
    # Count recent screenshots (last 24 hours)
    recent_count = 0
    if os.path.exists(screenshot_dir):
        try:
            files = os.listdir(screenshot_dir)
            now = datetime.now()
            for file in files:
                if file.lower().endswith(('.png', '.jpg', '.jpeg')):
                    file_path = os.path.join(screenshot_dir, file)
                    file_time = datetime.fromtimestamp(os.path.getmtime(file_path))
                    if (now - file_time).days == 0:  # Same day
                        recent_count += 1
        except:
            pass
    
    # Format output
    output = "📸"
    
    # Create tooltip
    tooltip_parts = ["Screenshot Tools"]
    tooltip_parts.append(f"Recent screenshots today: {recent_count}")
    tooltip_parts.append("")
    tooltip_parts.append("Left click: Full screen")
    tooltip_parts.append("Right click: Select area")
    tooltip_parts.append("Middle click: Current window")
    tooltip_parts.append("")
    tooltip_parts.append(f"Saved to: {screenshot_dir}")
    
    result = {
        "text": output,
        "tooltip": "\n".join(tooltip_parts),
        "class": "screenshot"
    }
    
    print(json.dumps(result))

if __name__ == "__main__":
    main()