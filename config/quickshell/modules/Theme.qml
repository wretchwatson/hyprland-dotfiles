pragma Singleton
import QtQuick

QtObject {
    // Basic colors from Ambxst
    readonly property color background: "black"
    readonly property color overBackground: "#ffffff"
    readonly property color primary: "#3498db"
    readonly property color secondary: "#2ecc71"
    readonly property color surface: "#000000"
    readonly property color outline: "#333333"
    
    // Glass effect settings
    readonly property real glassOpacity: 0.8
    readonly property real glassBlur: 15
    
    // Radius and sizes
    readonly property real radius: 18
    readonly property real fontSize: 16
    readonly property string font: "Comfortaa"
}
