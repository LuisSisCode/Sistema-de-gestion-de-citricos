import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: filterHeaderRoot
    width: parent.width
    height: 60
    color: "transparent"
    
    // Propiedades configurables
    property string buttonText: "Registrar"
    property string buttonIcon: ""
    property string searchPlaceholder: "Buscar..."
    property string searchIcon: "recursos/image/icons/lupa.png"
    property color buttonColor: "#4CAF50"
    property bool showFilter: true
    property bool showButton: true
    property bool showSearch: true
    property bool showRefreshButton: false
    
    // Filter properties
    property var filterOptions: []
    property string filterPlaceholder: "Seleccione..."
    property int filterCurrentIndex: -1
    property string filterIcon: "recursos/image/icons/filtro.svg"
    property color filterSelectedColor: "#5C6BC0"
    property color filterHoverColor: "#E8EAF6"
    property int filterWidth: 200
    property int popupMaxHeight: 300
    
    // Signals
    signal buttonClicked()
    signal searchTextChanged(string text)
    signal filterChanged(int index)
    signal refreshClicked
    
    Row {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 15
        
        // BOTÓN DE ACCIÓN - ÍCONO CORREGIDO
        Rectangle {
            id: actionButton
            visible: showButton
            width: 180
            height: 40
            radius: 6
            color: buttonColor
            anchors.verticalCenter: parent.verticalCenter
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: buttonClicked()
                onEntered: parent.color = Qt.lighter(buttonColor, 1.1)
                onExited: parent.color = buttonColor
            }
            
            Row {
                anchors.centerIn: parent
                spacing: 8
                
                Image {
                    width: 18
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    source: buttonIcon ? Qt.resolvedUrl("../" + buttonIcon) : ""
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(36, 36)
                    visible: buttonIcon !== ""
                }
                
                Text {
                    text: buttonText
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        
        Item { width: 1; height: 1 }
        
        // FILTRO/SELECTOR - ÍCONO CORREGIDO
        Rectangle {
            id: filterContainer
            visible: showFilter
            width: filterWidth
            height: 40
            radius: 6
            color: "#FAFAFA"
            border.color: "#CCCCCC"
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    if (filterPopup.visible) {
                        filterPopup.close()
                    } else {
                        filterPopup.open()
                    }
                }
                
                onEntered: {
                    parent.border.color = "#999999"
                }
                onExited: {
                    if (!filterPopup.visible) {
                        parent.border.color = "#CCCCCC"
                    }
                }
            }
            
            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                
                Image {
                    width: 14
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    source: filterIcon ? Qt.resolvedUrl("../" + filterIcon) : ""
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(28, 28)
                    opacity: 0.7
                }
                
                Text {
                    id: filterText
                    anchors.verticalCenter: parent.verticalCenter
                    text: filterCurrentIndex >= 0 && filterCurrentIndex < filterOptions.length 
                          ? filterOptions[filterCurrentIndex] 
                          : filterPlaceholder
                    color: filterCurrentIndex >= 0 ? "#333333" : "#999999"
                    font.pixelSize: 12
                    font.bold: filterCurrentIndex >= 0
                    elide: Text.ElideRight
                    width: parent.width - 50
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: filterPopup.visible ? "▲" : "▼"
                    color: "#666666"
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // Popup del filtro (sin cambios)
            Popup {
                id: filterPopup
                width: filterContainer.width
                height: Math.min(filterOptions.length * 38, popupMaxHeight)
                y: filterContainer.height + 2
                x: 0
                padding: 0
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                
                background: Rectangle {
                    color: "white"
                    radius: 6
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        anchors.margins: -1
                        color: "#10000000"
                        radius: parent.radius + 1
                    }
                }
                
                contentItem: ListView {
                    id: filterListView
                    anchors.fill: parent
                    clip: true
                    model: filterOptions
                    boundsBehavior: Flickable.StopAtBounds
                    
                    delegate: Rectangle {
                        id: delegateItem
                        width: filterListView.width
                        height: 38
                        color: index === filterCurrentIndex ? filterSelectedColor : 
                              (delegateMouseArea.containsMouse ? filterHoverColor : "white")
                        
                        MouseArea {
                            id: delegateMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                filterCurrentIndex = index
                                filterChanged(index)
                                filterPopup.close()
                            }
                        }
                        
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            text: modelData
                            color: index === filterCurrentIndex ? "white" : "#333333"
                            font.pixelSize: 12
                            font.bold: index === filterCurrentIndex
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        
                        Rectangle {
                            width: parent.width - 16
                            height: 1
                            color: "#F0F0F0"
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: index < filterOptions.length - 1
                        }
                    }
                    
                    ScrollBar.vertical: ScrollBar {
                        width: 6
                        policy: filterOptions.length * 38 > popupMaxHeight ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                        background: Rectangle { color: "transparent" }
                        contentItem: Rectangle {
                            color: "#C0C0C0"
                            radius: 3
                        }
                    }
                }
            }
        }
        
        // BUSCADOR - ÍCONO CORREGIDO
        Rectangle {
            id: searchBox
            visible: showSearch
            width: 220
            height: 40
            radius: 6
            color: "white"
            border.color: "#CCCCCC"
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            
            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                
                Rectangle {
                    width: 16
                    height: 16
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Image {
                        anchors.fill: parent
                        source: searchIcon ? Qt.resolvedUrl("../" + searchIcon) : ""
                        fillMode: Image.PreserveAspectFit
                        sourceSize: Qt.size(32, 32)
                        opacity: 0.7
                    }
                }
                
                TextInput {
                    id: searchInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 40
                    color: "#333333"
                    font.pixelSize: 12
                    selectByMouse: true
                    verticalAlignment: Text.AlignVCenter
                    
                    onTextChanged: searchTextChanged(text)
                    
                    Text {
                        text: searchPlaceholder
                        color: "#999999"
                        font.pixelSize: 12
                        visible: !parent.text
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
        // Boton para refrescar
        Button {
            id: refreshButton
            visible: filterHeaderRoot.showRefreshButton
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            ToolTip.visible: hovered
            ToolTip.text: "Actualizar lista"
            
            background: Rectangle {
                color: refreshButton.hovered ? "#E3F2FD" : "transparent"
                radius: 5
                border.color: "#1E88E5"
                border.width: 1
            }
            
            contentItem: Image {
                source: "recursos/image/icons/actualizar.svg"
                width: 18
                height: 18
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                
                // Animación de rotación al hacer clic
                RotationAnimation on rotation {
                    id: refreshAnimation
                    from: 0
                    to: 360
                    duration: 500
                    running: false
                }
            }
            
            onClicked: {
                // Animación de rotación
                refreshAnimation.start()
                
                // Emitir señal después de un pequeño delay
                
            }
        }
    }
}