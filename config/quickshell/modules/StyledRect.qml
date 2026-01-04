import QtQuick
import "."

Rectangle {
    id: root
    
    property string variant: "bg"
    property bool enableShadow: false
    property bool enableBorder: true
    
    // Use the Theme radius by default
    radius: Theme.radius
    
    color: {
        if (variant === "primary") return Theme.primary;
        if (variant === "secondary") return Theme.secondary;
        if (variant === "bg") return Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Theme.glassOpacity);
        return Theme.surface;
    }
    
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
    border.width: root.enableBorder ? 1 : 0
}
