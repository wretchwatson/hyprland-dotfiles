#!/usr/bin/env python3
"""Turkish date and time display module for Waybar."""

import calendar
import datetime
import json
import locale


def main():
    """Generate Turkish date and time output for Waybar."""
    try:
        locale.setlocale(locale.LC_TIME, 'tr_TR.UTF-8')
    except locale.Error:
        pass
    
    now = datetime.datetime.now()
    
    turkish_months = {
        1: "Oca", 2: "Şub", 3: "Mar", 4: "Nis", 5: "May", 6: "Haz",
        7: "Tem", 8: "Ağu", 9: "Eyl", 10: "Eki", 11: "Kas", 12: "Ara"
    }
    
    turkish_days = {
        0: "Pzt", 1: "Sal", 2: "Çar", 3: "Per", 4: "Cum", 5: "Cmt", 6: "Paz"
    }
    
    time_str = now.strftime("%H:%M")
    day = now.day
    month = turkish_months[now.month]
    weekday = turkish_days[now.weekday()]
    
    # Takvim oluştur
    cal = calendar.month(now.year, now.month)
    
    # Bugünü vurgula
    cal_formatted = cal.replace(
        f' {now.day} ', 
        f' <span background="#025939" foreground="white">{now.day}</span> '
    )
    
    output = {
        "text": f"󰥔  {time_str}  {weekday}, {day} {month}",
        "tooltip": f"<big>{now.strftime('%Y %B')}</big>\n<tt><small>{cal_formatted}</small></tt>"
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    main()