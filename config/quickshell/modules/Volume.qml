import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: volume
    implicitWidth: mainRow.implicitWidth + 24
    implicitHeight: 36
    visible: Pipewire.defaultAudioSink !== null
    
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink?.audio
    readonly property bool ready: sink?.ready ?? false
    
    PwObjectTracker {
        objects: [sink]
    }
    
    StyledRect {
        anchors.fill: parent
        variant: "bg"
        
        Row {
            id: mainRow
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (!audio || audio.muted) return "󰖁"
                    const vol = audio.volume || 0
                    if (vol > 0.6) return "󰕾"
                    if (vol > 0.3) return "󰖀"
                    return "󰕿"
                }
                color: audio?.muted ? "#e74c3c" : Theme.overBackground
                font.pixelSize: 20
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: audio ? Math.round((audio.volume || 0) * 100) + "%" : "0%"
                color: Theme.overBackground
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                font.bold: true
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (audio && ready) audio.muted = !audio.muted
            }
            onWheel: wheel => {
                if (!audio || !ready) return
                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                const newVol = Math.max(0, Math.min(1, (audio.volume || 0) + delta))
                audio.volume = newVol
            }
        }
    }
}
