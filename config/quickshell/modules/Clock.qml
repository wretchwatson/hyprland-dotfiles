import QtQuick
import QtQuick.Layouts

Item {
    id: clock
    implicitWidth: mainLayout.implicitWidth + 32
    implicitHeight: 36
    
    property string timeStr: ""
    property string dateStr: ""
    
    function updateTime() {
        let now = new Date();
        timeStr = now.toLocaleTimeString(Qt.locale(), "hh:mm");
        dateStr = now.toLocaleDateString(Qt.locale(), "dd/MM/yyyy");
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.updateTime()
    }
    
    Component.onCompleted: updateTime()
    
    StyledRect {
        anchors.fill: parent
        variant: "bg"
        
        RowLayout {
            id: mainLayout
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                id: timeText
                text: clock.timeStr
                color: Theme.overBackground
                font.family: Theme.font
                font.bold: true
                font.pixelSize: Theme.fontSize
            }
            
            Rectangle {
                width: 1; height: 16
                color: Theme.outline
                opacity: 0.3
            }
            
            Text {
                text: clock.dateStr
                color: Theme.overBackground
                font.family: Theme.font
                font.bold: true
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
