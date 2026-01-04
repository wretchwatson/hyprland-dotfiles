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
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    property int buttonX: 0
    property int buttonY: 0
    
    signal closeRequested()
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.closeRequested()
        }
    }
    
    StyledRect {
        id: menuContent
        width: 180
        height: 160
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 10
        anchors.topMargin: 0
        
        variant: "bg"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            
            Text {
                text: "Layout Mode"
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
            
            LayoutItem {
                icon: "⊞"
                label: "Dwindle"
                layout: "dwindle"
                onTriggered: runCommand("hyprctl keyword general:layout dwindle")
            }
            
            LayoutItem {
                icon: "⊟"
                label: "Master"
                layout: "master"
                onTriggered: runCommand("hyprctl keyword general:layout master")
            }
            
            LayoutItem {
                icon: "⊠"
                label: "Scrolling"
                layout: "scrolling"
                onTriggered: runCommand("hyprctl keyword general:layout scrolling")
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
    
    component LayoutItem: MouseArea {
        id: itemRoot
        property string icon: ""
        property string label: ""
        property string layout: ""
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
                    color: Theme.primary
                    font.pixelSize: 20
                    font.bold: true
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
