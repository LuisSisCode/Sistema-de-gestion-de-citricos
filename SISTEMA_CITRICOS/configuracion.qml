import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: configuracionRoot
    anchors.fill: parent
    color: "#F8F9FA"

    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "AJUSTE Y PREFERNCIAS DEL SISTEMA"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.centerIn: parent
        }
    }

    // Contenido principal con dos columnas
    Item {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        
        // Panel de menú lateral
        Rectangle {
            id: menuLateral
            width: 250
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "white"
            radius: 5
            border.color: "#EEEEEE"
            
            ListView {
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                model: ListModel {
                    ListElement { nombre: "Cuenta"; icono: "👤" }
                    ListElement { nombre: "Empresa"; icono: "🏢" }
                    ListElement { nombre: "Notificaciones"; icono: "🔔" }
                    ListElement { nombre: "Seguridad"; icono: "🔒" }
                    ListElement { nombre: "Respaldo de Datos"; icono: "💾" }
                    ListElement { nombre: "Apariencia"; icono: "🎨" }
                    ListElement { nombre: "Idioma"; icono: "🌐" }
                    ListElement { nombre: "Ayuda"; icono: "❓" }
                    ListElement { nombre: "Acerca de"; icono: "ℹ️" }
                }
                
                spacing: 5
                currentIndex: 0
                
                delegate: Rectangle {
                    width: parent.width
                    height: 50
                    color: ListView.isCurrentItem ? "#E3F2FD" : "transparent"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: icono
                            font.pixelSize: 18
                        }
                        
                        Text {
                            text: nombre
                            font.pixelSize: 14
                            font.bold: ListView.isCurrentItem
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            parent.ListView.view.currentIndex = index
                        }
                    }
                }
            }
        }
        
        // Panel de contenido
        Rectangle {
            anchors.left: menuLateral.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 20
            color: "white"
            radius: 5
            border.color: "#EEEEEE"
            
            // Información de Cuenta (vista predeterminada)
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Título de la sección
                Text {
                    text: "Información de Cuenta"
                    font.pixelSize: 20
                    font.bold: true
                }
                
                // Perfil de usuario
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    
                    // Avatar
                    Rectangle {
                        width: 100
                        height: 100
                        radius: 50
                        color: "#2E7D32"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "JD"
                            font.pixelSize: 36
                            font.bold: true
                            color: "white"
                        }
                    }
                    
                    // Datos básicos
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: "Juan Delgado"
                            font.pixelSize: 22
                            font.bold: true
                        }
                        
                        Text {
                            text: "Administrador"
                            font.pixelSize: 16
                            color: "#757575"
                        }
                        
                        Text {
                            text: "Último acceso: 10/04/2025, 08:45 AM"
                            font.pixelSize: 14
                            color: "#757575"
                        }
                    }
                    
                    // Botón de edición
                    Button {
                        text: "Cambiar Imagen"
                        implicitHeight: 36
                    }
                }
                
                // Formulario de datos
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 15
                    columnSpacing: 20
                    
                    // Nombre
                    Text {
                        text: "Nombre:"
                        font.pixelSize: 14
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "Juan"
                        placeholderText: "Nombre"
                    }
                    
                    // Apellido
                    Text {
                        text: "Apellido:"
                        font.pixelSize: 14
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "Delgado"
                        placeholderText: "Apellido"
                    }
                    
                    // Correo
                    Text {
                        text: "Correo electrónico:"
                        font.pixelSize: 14
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "juan.delgado@example.com"
                        placeholderText: "Correo electrónico"
                    }
                    
                    // Teléfono
                    Text {
                        text: "Teléfono:"
                        font.pixelSize: 14
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "+58 412-5551234"
                        placeholderText: "Teléfono"
                    }
                    
                    // Usuario
                    Text {
                        text: "Nombre de usuario:"
                        font.pixelSize: 14
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "jdelgado"
                        placeholderText: "Nombre de usuario"
                    }
                    
                    // Cambiar contraseña
                    Text {
                        text: "Contraseña:"
                        font.pixelSize: 14
                    }
                    
                    Button {
                        text: "Cambiar Contraseña"
                        implicitHeight: 36
                    }
                }
                
                // Separador
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#EEEEEE"
                }
                
                // Preferencias
                Text {
                    text: "Preferencias"
                    font.pixelSize: 18
                    font.bold: true
                }
                
                // Opciones de notificaciones
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    CheckBox {
                        text: "Recibir notificaciones por correo electrónico"
                        checked: true
                    }
                    
                    CheckBox {
                        text: "Recibir alertas de stock bajo"
                        checked: true
                    }
                    
                    CheckBox {
                        text: "Recibir recordatorios de mantenimiento"
                        checked: true
                    }
                }
                
                // Espaciador
                Item {
                    Layout.fillHeight: true
                }
                
                // Botones de acción
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "Cancelar"
                        implicitHeight: 36
                        flat: true
                    }
                    
                    Button {
                        text: "Guardar Cambios"
                        implicitHeight: 36
                    }
                }
            }
        }
    }
}