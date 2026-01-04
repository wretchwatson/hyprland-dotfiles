import QtQuick

Item {
    id: root
    
    enum CornerEnum {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }
    
    property int corner: RoundedCorner.CornerEnum.TopLeft
    property int size: 20
    property color color: "#000000"
    
    implicitWidth: size
    implicitHeight: size
    
    Canvas {
        anchors.fill: parent
        antialiasing: true
        
        onPaint: {
            var ctx = getContext("2d")
            var r = root.size
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            
            switch (root.corner) {
            case RoundedCorner.CornerEnum.TopLeft:
                ctx.arc(r, r, r, Math.PI, 3 * Math.PI / 2)
                ctx.lineTo(0, 0)
                break
            case RoundedCorner.CornerEnum.TopRight:
                ctx.arc(0, r, r, 3 * Math.PI / 2, 2 * Math.PI)
                ctx.lineTo(r, 0)
                break
            case RoundedCorner.CornerEnum.BottomLeft:
                ctx.arc(r, 0, r, Math.PI / 2, Math.PI)
                ctx.lineTo(0, r)
                break
            case RoundedCorner.CornerEnum.BottomRight:
                ctx.arc(0, 0, r, 0, Math.PI / 2)
                ctx.lineTo(r, r)
                break
            }
            
            ctx.closePath()
            ctx.fillStyle = root.color
            ctx.fill()
        }
        
        Component.onCompleted: requestPaint()
    }
}
