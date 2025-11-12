import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: paginatorRoot
    width: parent.width
    height: 50
    color: "transparent"
    
    property int currentPage: 1
    property int totalPages: 1
    property int itemsPerPage: 10
    
    signal pageChanged(int newPage)
    
    Row {
        anchors.centerIn: parent
        spacing: 20
        
        // Botón Anterior
        Rectangle {
            width: 120
            height: 36
            radius: 18
            color: currentPage > 1 ? "#E0E0E0" : "#D0D0D0"
            border.color: "#B0B0B0"
            border.width: 1
            
            MouseArea {
                anchors.fill: parent
                enabled: currentPage > 1
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                
                onClicked: {
                    if (currentPage > 1) {
                        currentPage--
                        pageChanged(currentPage)
                    }
                }
                
                hoverEnabled: true
                onEntered: if (enabled) parent.color = "#D8D8D8"
                onExited: if (enabled) parent.color = "#E0E0E0"
            }
            
            Text {
                anchors.centerIn: parent
                text: "← Anterior"
                color: currentPage > 1 ? "#333333" : "#888888"
                font.pixelSize: 12
                font.bold: true
            }
        }
        
        // Información de página
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Página " + currentPage + " de " + totalPages
            color: "#666666"
            font.pixelSize: 12
            font.bold: true
            width: 100
            horizontalAlignment: Text.AlignHCenter
        }
        
        // Botón Siguiente
        Rectangle {
            width: 120
            height: 36
            radius: 18
            color: currentPage < totalPages ? "#E0E0E0" : "#D0D0D0"
            border.color: "#B0B0B0"
            border.width: 1
            
            MouseArea {
                anchors.fill: parent
                enabled: currentPage < totalPages
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                
                onClicked: {
                    if (currentPage < totalPages) {
                        currentPage++
                        pageChanged(currentPage)
                    }
                }
                
                hoverEnabled: true
                onEntered: if (enabled) parent.color = "#D8D8D8"
                onExited: if (enabled) parent.color = "#E0E0E0"
            }
            
            Text {
                anchors.centerIn: parent
                text: "Siguiente →"
                color: currentPage < totalPages ? "#333333" : "#888888"
                font.pixelSize: 12
                font.bold: true
            }
        }
    }
}
