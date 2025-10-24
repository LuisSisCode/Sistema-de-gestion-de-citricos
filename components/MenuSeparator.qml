// MenuSeparator.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    property string sectionTitle: "SECCIÓN"
    
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    color: "transparent"
    
    Text {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        text: root.sectionTitle
        font.pixelSize: 11
        font.bold: true
        color: "#7F8C8D"
        letterSpacing: 1
    }
}