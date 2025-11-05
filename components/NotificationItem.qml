// NotificationItem.qml - Item individual de notificación
import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../styles" as Styles

Rectangle {
    id: root
    
    property string icon: "ℹ️"
    property string title: "Título"
    property string message: "Mensaje"
    property string time: "Ahora"
    property bool isUnread: false
    
    signal clicked()
    
    height: 90
    color: mouseArea.containsMouse ?
           Styles.AppTheme.colors.bgApp : "transparent"
    
    Behavior on color {
        ColorAnimation { duration: Styles.AppTheme.transitionFast }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: Styles.AppTheme.spaceMd
        spacing: Styles.AppTheme.spaceMd
        
        // Icono
        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: Qt.rgba(
                Styles.AppTheme.colors.primary.r,
                Styles.AppTheme.colors.primary.g,
                Styles.AppTheme.colors.primary.b,
                0.1
            )
            
            Text {
                anchors.centerIn: parent
                text: root.icon
                font.pixelSize: Styles.AppTheme.fontSizeLg
            }
        }
        
        // Contenido
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Styles.AppTheme.spaceXxs
            
            RowLayout {
                Layout.fillWidth: true
                spacing: Styles.AppTheme.spaceXs
                
                Text {
                    Layout.fillWidth: true
                    text: root.title
                    font.pixelSize: Styles.AppTheme.fontSizeMd
                    font.weight: root.isUnread ?
                               Styles.AppTheme.fontWeightBold :
                               Styles.AppTheme.fontWeightNormal
                    color: Styles.AppTheme.colors.textPrimary
                    elide: Text.ElideRight
                }
                
                Rectangle {
                    visible: root.isUnread
                    width: 8
                    height: 8
                    radius: 4
                    color: Styles.AppTheme.colors.primary
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: root.message
                font.pixelSize: Styles.AppTheme.fontSizeSm
                color: Styles.AppTheme.colors.textSecondary
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            
            Text {
                text: root.time
                font.pixelSize: Styles.AppTheme.fontSizeXs
                color: Styles.AppTheme.colors.textHint
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked()
        }
    }
}
