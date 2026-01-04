import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root
    
    required property var modelData
    screen: modelData
    
    color: "transparent"
    visible: false
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    
    exclusionMode: ExclusionMode.Ignore
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    margins {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }
    
    signal closeRequested()
    
    // Background (transparent, no dimming)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        opacity: 0
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.closeRequested()
        }
    }
    
    // Menu content (sliding from top)
    StyledRect {
        id: menuContent
        width: 180
        height: 200
        radius: 24 // Even softer corners
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 10
        anchors.topMargin: 44
        
        variant: "bg"
        enableShadow: true

        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 2
            
            Text {
                text: "Power"
                color: "white"
                font.family: Theme.font
                font.bold: true
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.outline
                opacity: 0.2
            }
            
            // Power Actions
            PowerItem {
                icon: "󰍃"
                label: "Exit Hyprland"
                itemColor: "#e67e22"
                onTriggered: runCommand("hyprctl dispatch exit")
            }
            
            PowerItem {
                icon: "󰑐"
                label: "Reboot System"
                itemColor: "#f1c40f"
                onTriggered: runCommand("systemctl reboot")
            }
            
            PowerItem {
                icon: "󰐥"
                label: "Power Off"
                itemColor: "#e74c3c"
                onTriggered: runCommand("systemctl poweroff")
            }
            
            PowerItem {
                icon: "󰌾"
                label: "Lock Screen"
                itemColor: "#9b59b6"
                onTriggered: runCommand("hyprlock")
            }
        }
    }
    
    function runCommand(cmd) {
        process.command = ["bash", "-c", cmd]
        process.running = true
        root.closeRequested()
    }
    
    Process {
        id: process
    }
    
    // Helper component with improved property passing
    component PowerItem: MouseArea {
        id: itemRoot
        property string icon: ""
        property string label: ""
        property color itemColor: "white"
        signal triggered()
        
        Layout.fillWidth: true
        height: 32
        hoverEnabled: true
        
        Rectangle {
            anchors.fill: parent
            color: itemRoot.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
            radius: 8
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 10
                
                Text {
                    text: itemRoot.icon
                    color: itemRoot.itemColor
                    font.pixelSize: 20
                }
                
                Text {
                    text: itemRoot.label
                    color: "white"
                    font.family: Theme.font
                    font.bold: true
                    font.pixelSize: 14
                }
            }
        }
        
        onClicked: triggered()
    }
}
