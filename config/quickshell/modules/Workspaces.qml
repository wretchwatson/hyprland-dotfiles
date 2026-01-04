import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: workspaces
    implicitWidth: row.implicitWidth + 8
    implicitHeight: 36
    
    readonly property var monitor: Hyprland.monitorFor(Quickshell.screens[0])
    property var visibleWorkspaces: []
    
    function updateVisible() {
        const activeId = monitor?.activeWorkspace?.id || 1
        const occupied = []
        
        // Get all workspaces that exist in Hyprland
        const allWorkspaces = Hyprland.workspaces.values
        
        for (let i = 1; i <= 10; i++) {
            const ws = allWorkspaces.find(w => w.id === i)
            const exists = ws !== undefined
            const isActive = i === activeId
            
            if (exists || isActive) {
                occupied.push({
                    id: i,
                    hasWindows: exists,
                    isActive: isActive
                })
            }
        }
        
        visibleWorkspaces = occupied
    }
    
    Component.onCompleted: updateVisible()
    
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { updateVisible() }
    }
    
    Connections {
        target: monitor
        function onActiveWorkspaceChanged() { updateVisible() }
    }
    
    StyledRect {
        anchors.fill: parent
        variant: "bg"
    }
    
    Row {
        id: row
        spacing: -2
        anchors.centerIn: parent
        
        Repeater {
            model: workspaces.visibleWorkspaces
            
            Item {
                required property var modelData
                
                width: 36
                height: 36
                
                Rectangle {
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    radius: Theme.radius
                    color: modelData.hasWindows ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                StyledRect {
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    variant: "primary"
                    opacity: modelData.isActive ? 1 : 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    color: modelData.isActive ? "black" : Theme.overBackground
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    font.bold: true
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                }
            }
        }
    }
}
