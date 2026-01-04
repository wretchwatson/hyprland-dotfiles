import QtQuick
import Quickshell.Io

Item {
    id: weather
    implicitWidth: mainRow.implicitWidth + 24
    implicitHeight: 36
    
    property string temp: ""
    property string icon: ""
    property string description: ""
    
    Timer {
        interval: 600000 // 10 dakika
        running: true
        repeat: true
        onTriggered: process.running = true
    }
    
    Process {
        id: process
        command: ["bash", "-c", "curl -s 'http://api.openweathermap.org/data/2.5/weather?q=Ödemiş,TR&appid=0ac4f6b0fd31e778aad919cac94a5c7e&units=metric&lang=tr'"]
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data)
                    temp = Math.round(json.main.temp) + "°C"
                    description = json.weather[0].description
                    
                    // Weather icon mapping (Nerd Font icons)
                    const weatherId = json.weather[0].id
                    if (weatherId >= 200 && weatherId < 300) icon = "󰙾" // Thunderstorm
                    else if (weatherId >= 300 && weatherId < 400) icon = "󰖗" // Drizzle
                    else if (weatherId >= 500 && weatherId < 600) icon = "󰖖" // Rain
                    else if (weatherId >= 600 && weatherId < 700) icon = "󰼶" // Snow
                    else if (weatherId >= 700 && weatherId < 800) icon = "󰖑" // Fog
                    else if (weatherId === 800) icon = "󰖙" // Clear
                    else if (weatherId > 800) icon = "󰖐" // Clouds
                } catch (e) {
                    console.log("Weather parse error:", e)
                }
            }
        }
    }
    
    Component.onCompleted: process.running = true
    
    StyledRect {
        anchors.fill: parent
        variant: "bg"
        
        Row {
            id: mainRow
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: icon
                color: Theme.primary
                font.pixelSize: 20
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: temp
                color: Theme.overBackground
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                font.bold: true
            }
        }
    }
}