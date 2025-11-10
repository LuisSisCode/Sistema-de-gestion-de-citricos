import QtQuick 2.15
import QtQuick.Controls.Universal 2.15

Rectangle {
    id: tabBarRoot
    width: parent.width
    height: parent.height
    color: "transparent"
    
    // Propiedades
    property var tabsData: []
    property int tabActiva: 0
    
    // Señales
    signal tabChanged(int index)
    
    // Contenedor de pestañas centrado
    Row {
        id: tabsRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        
        Repeater {
            model: tabsData
            
            Item {
                id: tabItem
                width: 280
                height: 80
                
                // Indicador de pestaña activa
                Rectangle {
                    id: activeIndicator
                    width: parent.width - 20
                    height: 4
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: tabsData[index].color
                    radius: 2
                    opacity: tabActiva === index ? 1 : 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }
                
                // Card de la pestaña
                Rectangle {
                    id: tabCard
                    anchors.fill: parent
                    anchors.margins: 5
                    radius: 12
                    color: tabActiva === index ? "white" : "transparent"
                    border.color: tabActiva === index ? tabsData[index].color : "#E0E0E0"
                    border.width: tabActiva === index ? 2 : 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                    
                    Behavior on y {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 300 }
                    }
                    
                    y: tabActiva === index ? -5 : 0
                    
                    // Sombra
                    Rectangle {
                        width: parent.width + 8
                        height: parent.height + 8
                        anchors.centerIn: parent
                        radius: 12
                        color: "#15000000"
                        visible: tabActiva === index
                        z: -1
                    }
                    
                    // Contenido
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onEntered: {
                            if (tabActiva !== index) {
                                tabCard.color = "#FAFAFA"
                                iconContainer.scale = 1.1
                            }
                        }
                        
                        onExited: {
                            if (tabActiva !== index) {
                                tabCard.color = "transparent"
                                iconContainer.scale = 1.0
                            }
                        }
                        
                        onClicked: {
                            tabActiva = index
                            tabChanged(index)
                        }
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: 12
                            
                            // Contenedor del icono
                            Item {
                                id: iconContainer
                                width: 42
                                height: 42
                                
                                Behavior on scale {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutBack }
                                }
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: tabActiva === index ? tabsData[index].color : "#F5F5F5"
                                    opacity: tabActiva === index ? 0.15 : 1
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 300 }
                                    }
                                    
                                    Behavior on opacity {
                                        NumberAnimation { duration: 300 }
                                    }
                                }
                                
                                // CORRECCIÓN: Usar Qt.resolvedUrl para rutas correctas
                                Image {
                                    id: tabIcon
                                    source: {
                                        // Resolver la ruta correctamente desde la ubicación del componente
                                        var iconPath = tabsData[index].icon
                                        if (iconPath.startsWith("recursos/")) {
                                            // Si la ruta es relativa, ajustarla para que funcione desde components/
                                            return "../" + iconPath
                                        }
                                        return iconPath
                                    }
                                    width: 24
                                    height: 24
                                    anchors.centerIn: parent
                                    opacity: tabActiva === index ? 1 : 0.7
                                    fillMode: Image.PreserveAspectFit
                                    sourceSize: Qt.size(48, 48)
                                    cache: true
                                    asynchronous: false
                                    
                                    // Debug: mostrar información del icono
                                    onStatusChanged: {
                                        if (status === Image.Error) {
                                            console.log("Error cargando icono:", source, "para pestaña:", tabsData[index].text)
                                        }
                                    }
                                    
                                    Behavior on opacity {
                                        NumberAnimation { duration: 300 }
                                    }
                                }
                            }
                            
                            // Texto
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                
                                Text {
                                    text: tabsData[index].text
                                    font.pixelSize: 14
                                    font.weight: tabActiva === index ? Font.Bold : Font.Normal
                                    color: tabActiva === index ? tabsData[index].color : "#616161"
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 300 }
                                    }
                                }
                                
                                Rectangle {
                                    width: 40
                                    height: 18
                                    radius: 9
                                    color: tabActiva === index ? tabsData[index].color : "#E0E0E0"
                                    opacity: tabActiva === index ? 1 : 0
                                    visible: tabActiva === index
                                    
                                    Behavior on opacity {
                                        NumberAnimation { duration: 300 }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            switch(index) {
                                                case 0: return "3"
                                                case 1: return "3"
                                                case 2: return "4"
                                                case 3: return "3"
                                                default: return "0"
                                            }
                                        }
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "white"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}