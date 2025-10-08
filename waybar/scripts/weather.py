#!/usr/bin/env python3
import requests
import json
import os

def get_weather():
    try:
        api_key = "0ac4f6b0fd31e778aad919cac94a5c7e"
        city = "Ödemiş,TR"  # İzmir Ödemiş
        
        # Current weather
        url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric&lang=tr"
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            
            temp = round(data['main']['temp'])
            feels_like = round(data['main']['feels_like'])
            humidity = data['main']['humidity']
            description = data['weather'][0]['description'].title()
            icon_code = data['weather'][0]['icon']
            wind_speed = data['wind']['speed']
            wind_deg = data['wind'].get('deg', 0)
            
            # Weather icons mapping
            weather_icons = {
                '01d': '☀️', '01n': '🌙',  # clear sky
                '02d': '⛅', '02n': '☁️',  # few clouds
                '03d': '☁️', '03n': '☁️',  # scattered clouds
                '04d': '☁️', '04n': '☁️',  # broken clouds
                '09d': '🌧️', '09n': '🌧️',  # shower rain
                '10d': '🌦️', '10n': '🌧️',  # rain
                '11d': '⛈️', '11n': '⛈️',  # thunderstorm
                '13d': '❄️', '13n': '❄️',  # snow
                '50d': '🌫️', '50n': '🌫️'   # mist
            }
            
            icon = weather_icons.get(icon_code, '🌤️')
            
            # Format output
            output = f"{icon} {temp}°C"
            
            # Create tooltip
            tooltip = f"Hava Durumu - {city}\n"
            tooltip += f"Sıcaklık: {temp}°C (Hissedilen: {feels_like}°C)\n"
            tooltip += f"Durum: {description}\n"
            tooltip += f"Nem: {humidity}%\n"
            tooltip += f"Rüzgar: {wind_speed} m/s ({wind_deg}°)"
            
            result = {
                "text": output,
                "tooltip": tooltip,
                "class": "weather"
            }
            
            print(json.dumps(result))
            
        else:
            print(json.dumps({
                "text": "🌤️ N/A",
                "tooltip": "Hava durumu bilgisi alınamadı",
                "class": "weather"
            }))
            
    except Exception as e:
        print(json.dumps({
            "text": "🌤️ Error",
            "tooltip": f"Hata: {str(e)}",
            "class": "weather"
        }))

if __name__ == "__main__":
    get_weather()