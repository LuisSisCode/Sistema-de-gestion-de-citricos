// UserMenuPopup.qml - Menú desplegable del perfil de usuario
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles" as Styles

Popup {
    id: root
    
    width: 250
    height: contentColumn.height + 20
    padding: 10
    
    // Propiedades
    property string userName: "Usuario"
    property string userRole: "Rol"
    
    // Señales
    signal profileClicked()
    signal settingsClicked()
    signal logoutClicked()
    
    // Posicionamiento
    x: parent.width - width - 20
    y: parent.height + 10
    
    background: Rectangle {
        color: Styles.AppTheme.colors.bgPaper
        radius: Styles.AppTheme.radiusLg
        border.width: Styles.AppTheme.borderThin
        border.color: Styles.AppTheme.colors.border
    }
    
    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 0
        
        // Información del usuario
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Styles.AppTheme.colors.bgApp
            radius: Styles.AppTheme.radiusMd
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Styles.AppTheme.spaceMd
                spacing: Styles.AppTheme.spaceXs
                
                Text {
                    text: userName
                    font.pixelSize: Styles.AppTheme.fontSizeMd
                    font.weight: Styles.AppTheme.fontWeightBold
                    color: Styles.AppTheme.colors.textPrimary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Text {
                    text: userRole
                    font.pixelSize: Styles.AppTheme.fontSizeSm
                    color: Styles.AppTheme.colors.textSecondary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    radius: 2
                    color: Styles.AppTheme.colors.primary
                }
            }
        }
        
        // Separador
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: Styles.AppTheme.spaceSm
            Layout.bottomMargin: Styles.AppTheme.spaceSm
            color: Styles.AppTheme.colors.border
        }
        
        // Opción: Mi Perfil
        Rectangle {
            id: profileOption
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: profileMouseArea.containsMouse ? 
                   Styles.AppTheme.colors.bgApp : "transparent"
            radius: Styles.AppTheme.radiusMd
            
            Behavior on color {
                ColorAnimation { duration: Styles.AppTheme.transitionFast }
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Styles.AppTheme.spaceMd
                anchors.rightMargin: Styles.AppTheme.spaceMd
                spacing: Styles.AppTheme.spaceMd
                
                Text {
                    text: "👤"
                    font.pixelSize: Styles.AppTheme.fontSizeLg
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Mi Perfil"
                    font.pixelSize: Styles.AppTheme.fontSizeMd
                    color: Styles.AppTheme.colors.textPrimary
                }
                
                Text {
                    text: "→"
                    font.pixelSize: Styles.AppTheme.fontSizeSm
                    color: Styles.AppTheme.colors.textHint
                }
            }
            
            MouseArea {
                id: profileMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.profileClicked()
                    root.close()
                }
            }
        }
        
        // Opción: Configuración
        Rectangle {
            id: settingsOption
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: settingsMouseArea.containsMouse ? 
                   Styles.AppTheme.colors.bgApp : "transparent"
            radius: Styles.AppTheme.radiusMd
            
            Behavior on color {
                ColorAnimation { duration: Styles.AppTheme.transitionFast }
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Styles.AppTheme.spaceMd
                anchors.rightMargin: Styles.AppTheme.spaceMd
                spacing: Styles.AppTheme.spaceMd
                
                Text {
                    text: "⚙️"
                    font.pixelSize: Styles.AppTheme.fontSizeLg
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Configuración"
                    font.pixelSize: Styles.AppTheme.fontSizeMd
                    color: Styles.AppTheme.colors.textPrimary
                }
                
                Text {
                    text: "→"
                    font.pixelSize: Styles.AppTheme.fontSizeSm
                    color: Styles.AppTheme.colors.textHint
                }
            }
            
            MouseArea {
                id: settingsMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.settingsClicked()
                    root.close()
                }
            }
        }
        
        // Separador
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: Styles.AppTheme.spaceSm
            Layout.bottomMargin: Styles.AppTheme.spaceSm
            color: Styles.AppTheme.colors.border
        }
        
        // Opción: Cerrar Sesión
        Rectangle {
            id: logoutOption
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: logoutMouseArea.containsMouse ? 
                   Styles.AppTheme.colors.errorBg : "transparent"
            radius: Styles.AppTheme.radiusMd
            
            Behavior on color {
                ColorAnimation { duration: Styles.AppTheme.transitionFast }
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Styles.AppTheme.spaceMd
                anchors.rightMargin: Styles.AppTheme.spaceMd
                spacing: Styles.AppTheme.spaceMd
                
                Text {
                    text: "🚪"
                    font.pixelSize: Styles.AppTheme.fontSizeLg
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Cerrar Sesión"
                    font.pixelSize: Styles.AppTheme.fontSizeMd
                    font.weight: Styles.AppTheme.fontWeightMedium
                    color: logoutMouseArea.containsMouse ?
                           Styles.AppTheme.colors.error :
                           Styles.AppTheme.colors.textPrimary
                }
            }
            
            MouseArea {
                id: logoutMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.logoutClicked()
                    root.close()
                }
            }
        }
    }
}
