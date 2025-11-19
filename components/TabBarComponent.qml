import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: tabBarRoot
    width: parent.width
    height: 120
    color: "transparent"
    
    property var tabsData: []
    property int tabActiva: 0
    
    signal tabChanged(int index)
    
    Column {
        anchors.fill: parent
        spacing: 0
        
        Rectangle {
            width: parent.width
            height: 1
            color: "#EEEEEE"
        }
        
        Row {
            id: tabsRow
            width: parent.width
            height: 60
            spacing: 0
            leftPadding: 20
            
            Repeater {
                model: tabsData
                
                Rectangle {
                    id: tabButton
                    width: 200
                    height: parent.height
                    color: "transparent"
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            tabActiva = index
                            tabChanged(index)
                        }
                    }
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 12
                        
                        // Icono
                        Image {
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter
                            source: Qt.resolvedUrl("../" + modelData.icon)
                            fillMode: Image.PreserveAspectFit
                            sourceSize: Qt.size(48, 48)
                            opacity: tabActiva === index ? 1 : 0.6
                            
                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.error("Error cargando icono:", source)
                                }
                            }
                        }
                        
                        // Texto
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.text
                            color: tabActiva === index ? "#2E7D32" : "#666666"
                            font.pixelSize: 14
                            font.bold: tabActiva === index
                        }
                    }
                    
                    // Línea indicadora
                    Rectangle {
                        width: parent.width
                        height: 3
                        anchors.bottom: parent.bottom
                        color: tabActiva === index ? "#2E7D32" : "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }
                }
            }
        }
        
        Rectangle {
            width: parent.width
            height: 1
            color: "#EEEEEE"
        }
    }
}
