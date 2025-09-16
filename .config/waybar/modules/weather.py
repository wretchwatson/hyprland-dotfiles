#!/home/ridvan/.myenv/bin/python3
import json
import subprocess
import requests

def get_weather():
    try:
        # OpenWeatherMap API (ücretsiz, API key gerekli)
        # API key almak için: https://openweathermap.org/api
        api_key = "0ac4f6b0fd31e778aad919cac94a5c7e"  # OpenWeatherMap API key
        
        if api_key == "YOUR_API_KEY_HERE":
            # API key yoksa basit hava durumu göster
            output = {
                "text": "🌤️ İzmir",
                "tooltip": "Hava durumu için OpenWeatherMap API key gerekli\nhttps://openweathermap.org/api"
            }
        else:
            # Ödemiş için hava durumu al (koordinat kullanarak)
            url = f"http://api.openweathermap.org/data/2.5/weather?lat=38.2221&lon=27.9656&appid={api_key}&units=metric&lang=tr"
            
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                temp = int(data['main']['temp'])
                description = data['weather'][0]['description'].title()
                humidity = data['main']['humidity']
                feels_like = int(data['main']['feels_like'])
                
                # Hava durumu ikonu
                weather_id = data['weather'][0]['id']
                if weather_id < 300:
                    icon = "⛈️"
                elif weather_id < 400:
                    icon = "🌦️"
                elif weather_id < 600:
                    icon = "🌧️"
                elif weather_id < 700:
                    icon = "❄️"
                elif weather_id < 800:
                    icon = "🌫️"
                elif weather_id == 800:
                    icon = "☀️"
                else:
                    icon = "☁️"
                
                output = {
                    "text": f"{icon} {temp}°C",
                    "tooltip": f"Ödemiş - {description}\nSıcaklık: {temp}°C (Hissedilen: {feels_like}°C)\nNem: %{humidity}"
                }
            else:
                # API key henüz aktif değilse geçici gösterim
                output = {
                    "text": "🌤️ Ödemiş",
                    "tooltip": f"API Hatası: {response.status_code} - Key aktifleşiyor..."
                }
            
    except Exception as e:
        output = {
            "text": "🌡️ N/A",
            "tooltip": f"Hata: {str(e)}"
        }
    
    print(json.dumps(output))

if __name__ == "__main__":
    get_weather()