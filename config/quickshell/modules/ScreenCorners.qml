import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: screenCorners
    
    required property ShellScreen modelData
    screen: modelData
    
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:screenCorners"
    exclusiveZone: 0
    
    mask: Region { item: null }
    
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    
    margins {
        top: 0
    }
    
    RoundedCorner {
        size: 20
        anchors.left: parent.left
        anchors.top: parent.top
        corner: RoundedCorner.CornerEnum.TopLeft
    }
    
    RoundedCorner {
        size: 20
        anchors.right: parent.right
        anchors.top: parent.top
        corner: RoundedCorner.CornerEnum.TopRight
    }
    
    RoundedCorner {
        size: 20
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        corner: RoundedCorner.CornerEnum.BottomLeft
    }
    
    RoundedCorner {
        size: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        corner: RoundedCorner.CornerEnum.BottomRight
    }
}
