import QtQuick
import QtQuick.Controls

Item {
    id: power
    implicitWidth: 36
    implicitHeight: 36
    
    signal powerClicked()
    
    StyledRect {
        anchors.fill: parent
        variant: "bg"
        
        Text {
            anchors.centerIn: parent
            text: "⏻"
            color: "#e74c3c"
            font.pixelSize: 22
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: power.powerClicked()
        }
    }
}
