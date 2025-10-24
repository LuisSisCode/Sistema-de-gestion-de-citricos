// MenuButton.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    property string buttonText: "Botón"
    property string iconText: "📄"
    property bool isActive: false
    
    signal clicked()
    
    width: parent.width
    height: 48
    color: isActive ? "#34495E" : "transparent"
    
    // Borde izquierdo cuando está activo
    Rectangle {
        visible: isActive
        width: 4
        height: parent.height
        color: "#4CAF50"
        anchors.left: parent.left
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 15
        
        // Icono
        Text {
            text: root.iconText
            font.pixelSize: 20
            color: root.isActive ? "white" : "#95A5A6"
        }
        
        // Texto
        Text {
            Layout.fillWidth: true
            text: root.buttonText
            font.pixelSize: 14
            font.bold: root.isActive
            color: root.isActive ? "white" : "#BDC3C7"
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onEntered: {
            if (!root.isActive) {
                root.color = "#2C3E50"
            }
        }
        
        onExited: {
            if (!root.isActive) {
                root.color = "transparent"
            }
        }
        
        onClicked: {
            root.clicked()
        }
    }
}