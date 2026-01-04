import QtQuick
import Quickshell.Io
import "."

Item {
    id: network
    implicitWidth: mainRow.implicitWidth + 24
    implicitHeight: 36
    
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property string localIP: ""
    property string publicIP: ""
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: process.running = true
    }
    
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            ipProcess.running = true
            publicIPProcess.running = true
        }
    }
    
    Process {
        id: process
        command: ["bash", "-c", "awk '/^[^lo]/ && NF>9 {rx+=$2; tx+=$10} END {print rx\" \"tx}' /proc/net/dev"]
        
        property var lastRx: 0
        property var lastTx: 0
        property bool firstRead: true
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(' ')
                if (parts.length !== 2) return
                
                const totalRx = parseInt(parts[0]) || 0
                const totalTx = parseInt(parts[1]) || 0
                
                if (!process.firstRead && process.lastRx > 0) {
                    const rxDiff = totalRx - process.lastRx
                    const txDiff = totalTx - process.lastTx
                    
                    downloadSpeed = Math.max(0, (rxDiff * 8) / 1000000)
                    uploadSpeed = Math.max(0, (txDiff * 8) / 1000000)
                }
                
                process.lastRx = totalRx
                process.lastTx = totalTx
                process.firstRead = false
            }
        }
    }
    
    Process {
        id: ipProcess
        command: ["bash", "-c", "ip route get 1.1.1.1 | awk '{print $7}' | head -1"]
        
        stdout: SplitParser {
            onRead: data => {
                localIP = data.trim()
            }
        }
    }
    
    Process {
        id: publicIPProcess
        command: ["bash", "-c", "curl -s --max-time 3 ifconfig.me || echo 'N/A'"]
        
        stdout: SplitParser {
            onRead: data => {
                publicIP = data.trim()
            }
        }
    }
    
    Component.onCompleted: {
        process.running = true
        ipProcess.running = true
        publicIPProcess.running = true
    }
    
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
                    text: "↓"
                    color: Theme.primary
                    font.pixelSize: 18
                }
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: downloadSpeed.toFixed(1) + " Mb/s"
                    color: Theme.overBackground
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    font.bold: true
                }
            }
            
            Row {
                spacing: 6
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "↑"
                    color: Theme.secondary
                    font.pixelSize: 18
                }
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: uploadSpeed.toFixed(1) + " Mb/s"
                    color: Theme.overBackground
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    font.bold: true
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
