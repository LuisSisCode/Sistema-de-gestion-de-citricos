// MenuSeparator.qml - Separador de secciones del menú
// Sprint 1.4 - Actualizado con sistema de estilos

import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../styles" as Styles

Rectangle {
    id: root
    
    // Propiedades públicas
    property string sectionTitle: "SECCIÓN"
    
    // Dimensiones
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    Layout.topMargin: Styles.AppTheme.spaceSm
    Layout.bottomMargin: Styles.AppTheme.spaceXxs
    color: "transparent"
    
    // Texto del título
    Text {
        anchors.left: parent.left
        anchors.leftMargin: Styles.AppTheme.spaceMd
        anchors.verticalCenter: parent.verticalCenter
        text: root.sectionTitle
        font.pixelSize: Styles.AppTheme.fontSizeXs
        font.weight: Styles.AppTheme.fontWeightBold
        font.family: Styles.AppTheme.fontFamily
        font.letterSpacing: 1.2
        color: Styles.AppTheme.colors.sidebarTextMuted
    }
    
    // Línea decorativa (opcional)
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Styles.AppTheme.spaceMd
            rightMargin: Styles.AppTheme.spaceMd
        }
        height: 1
        color: Styles.AppTheme.colors.sidebarSeparator
        opacity: 0.3
    }
}
