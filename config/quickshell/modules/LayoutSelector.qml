import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: layoutSelector
    implicitWidth: 36
    implicitHeight: 36
    
    property bool menuVisible: false
    property string currentLayout: "dwindle"
    
    function getLayoutIcon(layout) {
        switch (layout) {
        case "dwindle": return "⊞"
        case "master": return "⊟"
        case "scrolling": return "⊠"
        default: return "⊞"
        }
    }
    
    Process {
        id: layoutProcess
        command: ["bash", "-c", "hyprctl getoption general:layout -j | jq -r '.str'"]
        running: true
        
        stdout: SplitParser {
            onRead: data => {
                currentLayout = data.trim()
            }
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: layoutProcess.running = true
    }
    
    StyledRect {
        anchors.fill: parent
        variant: "bg"
        
        Text {
            anchors.centerIn: parent
            text: getLayoutIcon(currentLayout)
            color: Theme.overBackground
            font.pixelSize: 20
            font.bold: true
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: menuVisible = !menuVisible
        }
    }
}
