import QtQuick

Item {
    id: tooltip
    
    property string text: ""
    property bool showTooltip: false
    property int delay: 500
    
    Timer {
        id: showTimer
        interval: tooltip.delay
        onTriggered: tooltipRect.visible = true
    }
    
    Timer {
        id: hideTimer
        interval: 100
        onTriggered: tooltipRect.visible = false
    }
    
    onShowTooltipChanged: {
        if (showTooltip && text !== "") {
            hideTimer.stop()
            showTimer.start()
        } else {
            showTimer.stop()
            hideTimer.start()
        }
    }
    
    Rectangle {
        id: tooltipRect
        visible: false
        
        width: tooltipText.implicitWidth + 16
        height: tooltipText.implicitHeight + 8
        
        anchors.bottom: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 8
        
        color: "#1a1b26"
        border.color: "#7aa2f7"
        border.width: 1
        radius: 8
        
        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: tooltip.text
            color: "#c0caf5"
            font.family: Theme.font
            font.pixelSize: 12
        }
    }
}