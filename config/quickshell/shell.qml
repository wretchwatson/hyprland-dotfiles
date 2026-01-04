//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "modules"

ShellRoot {
    property bool powerMenuVisible: false
    property bool layoutMenuVisible: false
    
    Component.onCompleted: {
        // Set icon theme for system tray and other icons
        Quickshell.iconTheme = "Papirus-Dark"
    }
    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: window
            required property ShellScreen modelData
            screen: modelData
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            implicitWidth: modelData.width
            implicitHeight: 44
            color: "transparent"
            
            WlrLayershell.layer: WlrLayer.Top
            exclusiveZone: implicitHeight
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                spacing: 16
                
                Loader {
                    source: "modules/Workspaces.qml"
                    Layout.alignment: Qt.AlignVCenter
                }
                
                Item { Layout.fillWidth: true } // Spacer
                
                RowLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter
                    
                    Loader {
                        source: "modules/Network.qml"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    Loader {
                        source: "modules/Memory.qml"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    Loader {
                        id: layoutLoader
                        source: "modules/LayoutSelector.qml"
                        Layout.alignment: Qt.AlignVCenter
                        
                        onLoaded: {
                            item.menuVisibleChanged.connect(function() {
                                layoutMenuVisible = item.menuVisible
                            })
                        }
                    }
                    
                    Loader {
                        source: "modules/Volume.qml"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    Loader {
                        source: "modules/SysTray.qml"
                        Layout.alignment: Qt.AlignVCenter
                        onLoaded: item.window = window
                    }
                    
                    Loader {
                        id: powerLoader
                        source: "modules/Power.qml"
                        Layout.alignment: Qt.AlignVCenter
                        
                        onLoaded: {
                            item.powerClicked.connect(function() {
                                powerMenuVisible = !powerMenuVisible
                            })
                        }
                        
                        onStatusChanged: if (status == Loader.Error) console.log("Power module error: " + errorString())
                    }
                }
            }
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 2
                
                Loader {
                    source: "modules/Clock.qml"
                }
                
                Loader {
                    source: "modules/Weather.qml"
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens
        
        PowerMenu {
            visible: powerMenuVisible
            onCloseRequested: powerMenuVisible = false
        }
    }
    
    Variants {
        model: Quickshell.screens
        
        LayoutMenu {
            visible: layoutMenuVisible
            onCloseRequested: layoutMenuVisible = false
        }
    }
    
    Variants {
        model: Quickshell.screens
        
        ScreenCorners {
            modelData: modelData
        }
    }
    

}
