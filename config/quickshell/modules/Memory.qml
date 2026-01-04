import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: memory
    implicitWidth: mainRow.implicitWidth + 24
    implicitHeight: 36
    
    property real ramUsed: 0
    property real ramTotal: 0
    property real swapUsed: 0
    property real swapTotal: 0
    property int lineCount: 0
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: process.running = true
    }
    
    Process {
        id: process
        command: ["bash", "-c", "free -m | awk 'NR==2{print $3\" \"$2} NR==3{print $3\" \"$2}'"]
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(' ')
                if (parts.length >= 2) {
                    if (lineCount === 0) {
                        ramUsed = parseInt(parts[0]) || 0
                        ramTotal = parseInt(parts[1]) || 0
                        lineCount = 1
                    } else {
                        swapUsed = parseInt(parts[0]) || 0
                        swapTotal = parseInt(parts[1]) || 0
                        lineCount = 0
                    }
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
            spacing: 12
            
            Row {
                spacing: 6
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰍛"
                    color: Theme.primary
                    font.pixelSize: 18
                }
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ramUsed + "M"
                    color: Theme.overBackground
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    font.bold: true
                }
            }
            
            Row {
                spacing: 6
                visible: swapTotal > 0
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰓡"
                    color: Theme.secondary
                    font.pixelSize: 18
                }
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: swapUsed + "M"
                    color: Theme.overBackground
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    font.bold: true
                }
            }
        }
    }
}