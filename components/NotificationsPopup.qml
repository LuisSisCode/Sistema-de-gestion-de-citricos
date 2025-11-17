// NotificationsPopup.qml - Panel de notificaciones
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles" as Styles

Popup {
    id: root
    
    width: 400
    height: 500
    padding: 0
    
    // Posicionamiento
    x: parent ? parent.width - width - 20 : 0
    y: parent ? parent.height + 10 : 0
    
    background: Rectangle {
        color: Styles.AppTheme.colors.bgPaper
        radius: Styles.AppTheme.radiusLg
        border.width: Styles.AppTheme.borderThin
        border.color: Styles.AppTheme.colors.border
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Styles.AppTheme.colors.bgApp
            radius: Styles.AppTheme.radiusLg
            
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.radius
                color: parent.color
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Styles.AppTheme.spaceLg
                anchors.rightMargin: Styles.AppTheme.spaceLg
                spacing: Styles.AppTheme.spaceMd
                
                Text {
                    text: "🔔"
                    font.pixelSize: Styles.AppTheme.fontSizeXl
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Notificaciones"
                    font.pixelSize: Styles.AppTheme.fontSizeLg
                    font.weight: Styles.AppTheme.fontWeightBold
                    color: Styles.AppTheme.colors.textPrimary
                }
                
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: Styles.AppTheme.colors.primary
                    
                    Text {
                        anchors.centerIn: parent
                        text: "3"
                        font.pixelSize: Styles.AppTheme.fontSizeXs
                        font.weight: Styles.AppTheme.fontWeightBold
                        color: Styles.AppTheme.colors.white
                    }
                }
            }
        }
        
        // Lista de notificaciones
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            Column {
                width: parent.width
                spacing: 0
                
                // Notificación 1
                NotificationItem {
                    width: parent.width
                    icon: "✅"
                    title: "Cultivo cosechado"
                    message: "Se ha completado la cosecha de 500kg de naranjas"
                    time: "Hace 2 horas"
                    isUnread: true
                }
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Styles.AppTheme.colors.border
                }
                
                // Notificación 2
                NotificationItem {
                    width: parent.width
                    icon: "⚠️"
                    title: "Mantenimiento pendiente"
                    message: "El tractor TRC-001 requiere mantenimiento preventivo"
                    time: "Hace 5 horas"
                    isUnread: true
                }
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Styles.AppTheme.colors.border
                }
                
                // Notificación 3
                NotificationItem {
                    width: parent.width
                    icon: "💰"
                    title: "Nueva venta registrada"
                    message: "Venta de Bs. 2,500 a Cliente Premium"
                    time: "Ayer"
                    isUnread: true
                }
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Styles.AppTheme.colors.border
                }
                
                // Notificación 4 (leída)
                NotificationItem {
                    width: parent.width
                    icon: "📊"
                    title: "Reporte mensual generado"
                    message: "El reporte de producción de Octubre está disponible"
                    time: "Hace 2 días"
                    isUnread: false
                }
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Styles.AppTheme.colors.border
                }
                
                // Notificación 5 (leída)
                NotificationItem {
                    width: parent.width
                    icon: "🧑‍🌾"
                    title: "Nuevo productor registrado"
                    message: "Juan Pérez ha sido agregado al sistema"
                    time: "Hace 3 días"
                    isUnread: false
                }
            }
        }
        
        // Footer
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: Styles.AppTheme.colors.bgApp
            radius: Styles.AppTheme.radiusLg
            
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: parent.radius
                color: parent.color
            }
            
            RowLayout {
                anchors.centerIn: parent
                spacing: Styles.AppTheme.spaceLg
                
                Text {
                    text: "Marcar todas como leídas"
                    font.pixelSize: Styles.AppTheme.fontSizeSm
                    font.weight: Styles.AppTheme.fontWeightMedium
                    color: markAllMouseArea.containsMouse ?
                           Styles.AppTheme.colors.primary :
                           Styles.AppTheme.colors.textSecondary
                    
                    MouseArea {
                        id: markAllMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Marcar todas como leídas")
                        }
                    }
                }
                
                Rectangle {
                    width: 1
                    height: 20
                    color: Styles.AppTheme.colors.border
                }
                
                Text {
                    text: "Ver todas"
                    font.pixelSize: Styles.AppTheme.fontSizeSm
                    font.weight: Styles.AppTheme.fontWeightMedium
                    color: viewAllMouseArea.containsMouse ?
                           Styles.AppTheme.colors.primary :
                           Styles.AppTheme.colors.textSecondary
                    
                    MouseArea {
                        id: viewAllMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Ver todas las notificaciones")
                            root.close()
                        }
                    }
                }
            }
        }
    }

    // Componente para cada item de notificación
    Rectangle {
        id: notificationItem
        
        // Propiedades públicas
        property string icon: "ℹ️"
        property string title: "Título"
        property string message: "Mensaje"
        property string time: "Ahora"
        property bool isUnread: false
        
        height: 90
        color: mouseArea.containsMouse ? Styles.AppTheme.colors.bgApp : "transparent"
        
        Behavior on color {
            ColorAnimation { duration: 200 }
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
                    text: notificationItem.icon
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
                        text: notificationItem.title
                        font.pixelSize: Styles.AppTheme.fontSizeMd
                        font.weight: notificationItem.isUnread ? Font.Bold : Font.Normal
                        color: Styles.AppTheme.colors.textPrimary
                        elide: Text.ElideRight
                    }
                    
                    Rectangle {
                        visible: notificationItem.isUnread
                        width: 8
                        height: 8
                        radius: 4
                        color: Styles.AppTheme.colors.primary
                    }
                }
                
                Text {
                    Layout.fillWidth: true
                    text: notificationItem.message
                    font.pixelSize: Styles.AppTheme.fontSizeSm
                    color: Styles.AppTheme.colors.textSecondary
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
                
                Text {
                    text: notificationItem.time
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
                console.log("Notificación clickeada:", notificationItem.title)
            }
        }
    }
}

