import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "."

StyledRect {
    id: root
    variant: "bg"
    implicitWidth: mainLayout.implicitWidth + 16
    implicitHeight: 36
    
    property var window
    
    RowLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: -6
        
        Repeater {
            model: SystemTray.items
            
            delegate: MouseArea {
                id: trayItemRoot
                required property SystemTrayItem modelData
                
                width: 28
                height: 36
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                
                onClicked: (mouse) => {
                    console.log("Tray click:", modelData.title, "Button:", mouse.button);
                    if (mouse.button === Qt.LeftButton) {
                        console.log("Calling activate() for:", modelData.title);
                        modelData.activate();
                        console.log("Activate called successfully");
                    } else if (mouse.button === Qt.RightButton) {
                        console.log("Showing menu at:", mouse.x, mouse.y);
                        // Position menu directly below the icon
                        let globalPos = mapToGlobal(Qt.point(0, height));
                        modelData.display(root.window, globalPos.x, globalPos.y);
                    }
                }
                
                IconImage {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    // Prioritize iconName for themed icons
                    source: modelData.iconName || modelData.icon
                    smooth: true
                }
                
                // Tooltip placeholder (can be improved with a custom tooltip component later)
                Text {
                    visible: trayItemRoot.containsMouse && modelData.tooltipTitle !== ""
                    text: modelData.tooltipTitle
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 10
                    color: "white"
                    font.family: Theme.font
                    font.pixelSize: 12
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        color: "black"
                        opacity: 0.8
                        z: -1
                        radius: 4
                    }
                }
            }
        }
    }
}
