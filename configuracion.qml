import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: configuracionRoot
    anchors.fill: parent
    color: "#F5F7FA"

    // Page Title
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "AJUSTES Y PREFERENCIAS DEL SISTEMA"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.centerIn: parent
        }
    }

    // Main Content with Two Columns
    Item {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        
        // Side Menu Panel
        Rectangle {
            id: menuLateral
            width: 220
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "white"
            radius: 8
            border.color: "#E0E0E0"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8
                
                ListView {
                    id: menuListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: ListModel {
                        ListElement { nombre: "Cuenta"; icono: "recursos/image/icons/cuenta.png" }
                        ListElement { nombre: "Empresa"; icono: "recursos/image/icons/empresa.png" }
                        ListElement { nombre: "Notificaciones"; icono: "recursos/image/icons/notificaciones.png" }
                        ListElement { nombre: "Respaldo de Datos"; icono: "recursos/image/icons/respaldo.png" }
                        ListElement { nombre: "Ayuda"; icono: "recursos/image/icons/ayuda.png" }
                    }
                    
                    spacing: 8
                    currentIndex: 0
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 48
                        color: ListView.isCurrentItem ? "#2E7D32" : "transparent"
                        radius: 6
                        
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                if (!ListView.isCurrentItem) {
                                    parent.color = "#F0F0F0"
                                }
                            }
                            onExited: {
                                if (!ListView.isCurrentItem) {
                                    parent.color = "transparent"
                                }
                            }
                            onClicked: {
                                menuListView.currentIndex = index
                                contentLoader.sourceComponent = contentComponents[index]
                            }
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 6
                                color: ListView.isCurrentItem ? "rgba(255,255,255,0.2)" : "transparent"
                                Layout.alignment: Qt.AlignVCenter
                                
                                Image {
                                    source: icono
                                    width: 18
                                    height: 18
                                    anchors.centerIn: parent
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            
                            Text {
                                text: nombre
                                font.pixelSize: 13
                                font.bold: ListView.isCurrentItem
                                color: ListView.isCurrentItem ? "white" : "#424242"
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
        
        // Content Panel
        Rectangle {
            anchors.left: menuLateral.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 20
            color: "white"
            radius: 8
            border.color: "#E0E0E0"
            border.width: 1
            
            // Dynamic Content Loader
            Loader {
                id: contentLoader
                anchors.fill: parent
                anchors.margins: 30
                sourceComponent: contentComponents[0] // Default to Account view
            }
        }
    }

    // Component for Account View
    Component {
        id: cuentaComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Información de Cuenta"
                font.pixelSize: 22
                font.bold: true
                color: "#2E7D32"
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            // User Profile
            RowLayout {
                Layout.fillWidth: true
                spacing: 25
                
                // Avatar
                Rectangle {
                    width: 90
                    height: 90
                    radius: 45
                    color: "#2E7D32"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "JD"
                        font.pixelSize: 36
                        font.bold: true
                        color: "white"
                    }
                }
                
                // Basic User Info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: "Juan Delgado"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#212121"
                    }
                    
                    Text {
                        text: "Administrador del Sistema"
                        font.pixelSize: 14
                        color: "#2E7D32"
                        font.bold: true
                    }
                    
                    Text {
                        text: "Último acceso: 10/04/2025, 08:45 AM"
                        font.pixelSize: 12
                        color: "#757575"
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            // User Data Form
            Text {
                text: "Datos Personales"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 18
                columnSpacing: 25
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Nombre"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "Juan"
                        placeholderText: "Nombre"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Apellido"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "Delgado"
                        placeholderText: "Apellido"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Email"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "juan.delgado@example.com"
                        placeholderText: "Email"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Teléfono"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "+58 412-5551234"
                        placeholderText: "Teléfono"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Usuario"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "jdelgado"
                        placeholderText: "Nombre de usuario"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Contraseña"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            Layout.fillWidth: true
                            text: "••••••••"
                            placeholderText: "Contraseña"
                            echoMode: TextInput.Password
                            background: Rectangle {
                                color: "#F5F5F5"
                                border.color: "#E0E0E0"
                                border.width: 1
                                radius: 4
                            }
                        }
                        
                        Button {
                            implicitHeight: 36
                            implicitWidth: 100
                            text: "Cambiar"
                            background: Rectangle {
                                color: parent.hovered ? "#F57C00" : "#FF9800"
                                radius: 4
                            }
                            contentItem: Text {
                                text: "Cambiar"
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                Button {
                    implicitHeight: 38
                    implicitWidth: 120
                    text: "Cancelar"
                    background: Rectangle {
                        color: parent.hovered ? "#EEEEEE" : "white"
                        radius: 4
                        border.color: "#E0E0E0"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: "Cancelar"
                        color: "#424242"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    implicitHeight: 38
                    implicitWidth: 140
                    text: "Guardar Cambios"
                    background: Rectangle {
                        color: parent.hovered ? "#388E3C" : "#2E7D32"
                        radius: 4
                    }
                    contentItem: Text {
                        text: "Guardar Cambios"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Component for Empresa View
    Component {
        id: empresaComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Información de Empresa"
                font.pixelSize: 22
                font.bold: true
                color: "#2E7D32"
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Text {
                text: "Datos de la Empresa"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 18
                columnSpacing: 25
                
                ColumnLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Nombre de Empresa"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "Agro Chile"
                        placeholderText: "Nombre de empresa"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "RUT/NIT"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "12.345.678-9"
                        placeholderText: "RUT/NIT"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Teléfono"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "+58 (212) 555-1234"
                        placeholderText: "Teléfono"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Email Corporativo"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "contacto@agrochile.com"
                        placeholderText: "Email"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Dirección"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "Calle Principal 123"
                        placeholderText: "Dirección"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Sitio Web"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "www.agrochile.com"
                        placeholderText: "Sitio web"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Text {
                text: "Persona de Contacto"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 18
                columnSpacing: 25
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Nombre"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "Carlos Mendez"
                        placeholderText: "Nombre"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Cargo"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "Gerente General"
                        placeholderText: "Cargo"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Teléfono"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "+58 412-5559999"
                        placeholderText: "Teléfono"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Email"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#424242"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "cmendez@agrochile.com"
                        placeholderText: "Email"
                        background: Rectangle {
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 4
                        }
                    }
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                Button {
                    implicitHeight: 38
                    implicitWidth: 120
                    text: "Cancelar"
                    background: Rectangle {
                        color: parent.hovered ? "#EEEEEE" : "white"
                        radius: 4
                        border.color: "#E0E0E0"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: "Cancelar"
                        color: "#424242"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    implicitHeight: 38
                    implicitWidth: 140
                    text: "Guardar Cambios"
                    background: Rectangle {
                        color: parent.hovered ? "#388E3C" : "#2E7D32"
                        radius: 4
                    }
                    contentItem: Text {
                        text: "Guardar Cambios"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Component for Notificaciones View
    Component {
        id: notificacionesComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Configurar Notificaciones"
                font.pixelSize: 22
                font.bold: true
                color: "#2E7D32"
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Text {
                text: "Notificaciones por Email"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 14
                
                RowLayout {
                    spacing: 12
                    
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 3
                        color: "#2E7D32"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    
                    Text {
                        text: "Alertas de Mantenimiento"
                        font.pixelSize: 14
                        color: "#212121"
                        Layout.fillWidth: true
                    }
                }
                
                RowLayout {
                    spacing: 12
                    
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 3
                        color: "#2E7D32"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    
                    Text {
                        text: "Reportes Semanales"
                        font.pixelSize: 14
                        color: "#212121"
                        Layout.fillWidth: true
                    }
                }
                
                RowLayout {
                    spacing: 12
                    
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 3
                        color: "#E0E0E0"
                    }
                    
                    Text {
                        text: "Notificaciones de Ventas"
                        font.pixelSize: 14
                        color: "#757575"
                        Layout.fillWidth: true
                    }
                }
                
                RowLayout {
                    spacing: 12
                    
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 3
                        color: "#2E7D32"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    
                    Text {
                        text: "Actualizaciones del Sistema"
                        font.pixelSize: 14
                        color: "#212121"
                        Layout.fillWidth: true
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Text {
                text: "Notificaciones en Pantalla"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 18
                
                RowLayout {
                    spacing: 15
                    
                    Text {
                        text: "Habilitar notificaciones emergentes"
                        font.pixelSize: 14
                        color: "#212121"
                        Layout.fillWidth: true
                    }
                    
                    Rectangle {
                        width: 50
                        height: 28
                        radius: 14
                        color: "#2E7D32"
                        
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: "white"
                            anchors.top: parent.top
                            anchors.topMargin: 2
                            anchors.right: parent.right
                            anchors.rightMargin: 2
                        }
                    }
                }
                
                RowLayout {
                    spacing: 15
                    
                    Text {
                        text: "Sonido de notificaciones"
                        font.pixelSize: 14
                        color: "#212121"
                        Layout.fillWidth: true
                    }
                    
                    Rectangle {
                        width: 50
                        height: 28
                        radius: 14
                        color: "#E0E0E0"
                        
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: "white"
                            anchors.top: parent.top
                            anchors.topMargin: 2
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                        }
                    }
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                Button {
                    implicitHeight: 38
                    implicitWidth: 120
                    text: "Cancelar"
                    background: Rectangle {
                        color: parent.hovered ? "#EEEEEE" : "white"
                        radius: 4
                        border.color: "#E0E0E0"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: "Cancelar"
                        color: "#424242"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    implicitHeight: 38
                    implicitWidth: 140
                    text: "Guardar Cambios"
                    background: Rectangle {
                        color: parent.hovered ? "#388E3C" : "#2E7D32"
                        radius: 4
                    }
                    contentItem: Text {
                        text: "Guardar Cambios"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Component for Respaldo de Datos View
    Component {
        id: respaldoDatosComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Respaldo de Datos"
                font.pixelSize: 22
                font.bold: true
                color: "#2E7D32"
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 110
                radius: 8
                color: "#E8F5E9"
                border.color: "#2E7D32"
                border.width: 2
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10
                    
                    Text {
                        text: "Último Respaldo"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2E7D32"
                    }
                    
                    Text {
                        text: "15/04/2025 - 03:45 AM"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#212121"
                    }
                    
                    Text {
                        text: "Tamaño: 2.5 GB • Estado: Exitoso"
                        font.pixelSize: 12
                        color: "#2E7D32"
                    }
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    implicitHeight: 38
                    text: "Respaldar Ahora"
                    background: Rectangle {
                        color: parent.hovered ? "#388E3C" : "#2E7D32"
                        radius: 4
                    }
                    contentItem: Text {
                        text: "Respaldar Ahora"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    implicitHeight: 38
                    text: "Descargar Respaldo"
                    background: Rectangle {
                        color: parent.hovered ? "#42A5F5" : "#0288D1"
                        radius: 4
                    }
                    contentItem: Text {
                        text: "Descargar Respaldo"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Text {
                text: "Historial de Respaldos"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 8
                border.color: "#E0E0E0"
                border.width: 1
                
                ListView {
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    
                    model: ListModel {
                        ListElement { fecha: "15/04/2025, 03:00"; tipo: "Automático"; estado: "Exitoso" }
                        ListElement { fecha: "08/04/2025, 03:00"; tipo: "Automático"; estado: "Exitoso" }
                        ListElement { fecha: "01/04/2025, 03:00"; tipo: "Automático"; estado: "Exitoso" }
                        ListElement { fecha: "28/03/2025, 20:15"; tipo: "Manual"; estado: "Exitoso" }
                        ListElement { fecha: "21/03/2025, 03:00"; tipo: "Automático"; estado: "Exitoso" }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 45
                        color: index % 2 === 0 ? "#FAFAFA" : "white"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 15
                            
                            Text {
                                text: fecha
                                font.pixelSize: 12
                                color: "#212121"
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: tipo
                                font.pixelSize: 12
                                color: "#757575"
                                Layout.preferredWidth: 80
                            }
                            
                            Rectangle {
                                width: 60
                                height: 24
                                radius: 4
                                color: "#4CAF50"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "✓ " + estado
                                    color: "white"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Component for Ayuda View
    Component {
        id: ayudaComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Centro de Ayuda"
                font.pixelSize: 22
                font.bold: true
                color: "#2E7D32"
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Text {
                text: "Recursos de Ayuda"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    implicitHeight: 44
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: parent.hovered ? "#F5F5F5" : "white"
                        radius: 6
                        border.color: "#E0E0E0"
                        border.width: 1
                    }
                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 12
                        
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 6
                            color: "#E8F5E9"
                            
                            Image {
                                source: "recursos/image/icons/ayuda.png"
                                width: 18
                                height: 18
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                        
                        Text {
                            text: "Manual de Usuario"
                            color: "#2E7D32"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }
                        
                        Image {
                            source: "recursos/image/icons/siguiente.svg"
                            width: 16
                            height: 16
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    onClicked: {
                        console.log("Abriendo Manual de Usuario")
                    }
                }
                
                Button {
                    implicitHeight: 44
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: parent.hovered ? "#F5F5F5" : "white"
                        radius: 6
                        border.color: "#E0E0E0"
                        border.width: 1
                    }
                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 12
                        
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 6
                            color: "#E8F5E9"
                            
                            Image {
                                source: "recursos/image/icons/ayuda.png"
                                width: 18
                                height: 18
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                        
                        Text {
                            text: "Preguntas Frecuentes"
                            color: "#2E7D32"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }
                        
                        Image {
                            source: "recursos/image/icons/siguiente.svg"
                            width: 16
                            height: 16
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    onClicked: {
                        console.log("Mostrando Preguntas Frecuentes")
                    }
                }
                
                Button {
                    implicitHeight: 44
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: parent.hovered ? "#F5F5F5" : "white"
                        radius: 6
                        border.color: "#E0E0E0"
                        border.width: 1
                    }
                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 12
                        
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 6
                            color: "#E8F5E9"
                            
                            Image {
                                source: "recursos/image/icons/ayuda.png"
                                width: 18
                                height: 18
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                        
                        Text {
                            text: "Tutoriales en Video"
                            color: "#2E7D32"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }
                        
                        Image {
                            source: "recursos/image/icons/siguiente.svg"
                            width: 16
                            height: 16
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    onClicked: {
                        console.log("Abriendo Tutoriales")
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Text {
                text: "Información de Contacto"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                
                RowLayout {
                    spacing: 15
                    
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: "#E8F5E9"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "📞"
                            font.pixelSize: 16
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "Soporte Técnico"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#424242"
                        }
                        
                        Text {
                            text: "+58 (212) 555-7890"
                            font.pixelSize: 13
                            color: "#2E7D32"
                        }
                    }
                }
                
                RowLayout {
                    spacing: 15
                    
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: "#E8F5E9"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "📧"
                            font.pixelSize: 16
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "Correo Electrónico"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#424242"
                        }
                        
                        Text {
                            text: "soporte@empresa.com"
                            font.pixelSize: 13
                            color: "#2E7D32"
                        }
                    }
                }
                
                RowLayout {
                    spacing: 15
                    
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: "#E8F5E9"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🕐"
                            font.pixelSize: 16
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "Horario de Atención"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#424242"
                        }
                        
                        Text {
                            text: "Lunes a Viernes: 8:00 AM - 6:00 PM"
                            font.pixelSize: 13
                            color: "#2E7D32"
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            Text {
                text: "Sistema de Tickets"
                font.pixelSize: 16
                font.bold: true
                color: "#2E7D32"
            }
            
            Button {
                implicitHeight: 40
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignLeft
                text: "Crear Nuevo Ticket"
                background: Rectangle {
                    color: parent.hovered ? "#388E3C" : "#2E7D32"
                    radius: 4
                }
                contentItem: Text {
                    text: "Crear Nuevo Ticket"
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    console.log("Creando Nuevo Ticket")
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 8
                border.color: "#E0E0E0"
                border.width: 1
                
                ListView {
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    
                    model: ListModel {
                        ListElement { numero: "#1234"; asunto: "Problema con actualización"; estado: "En Proceso" }
                        ListElement { numero: "#1233"; asunto: "Consulta de funcionalidad"; estado: "Resuelto" }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 48
                        color: index % 2 === 0 ? "#FAFAFA" : "white"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 15
                            
                            Text {
                                text: numero
                                font.pixelSize: 12
                                font.bold: true
                                color: "#2E7D32"
                                Layout.preferredWidth: 60
                            }
                            
                            Text {
                                text: asunto
                                font.pixelSize: 12
                                color: "#212121"
                                Layout.fillWidth: true
                            }
                            
                            Rectangle {
                                width: 90
                                height: 26
                                radius: 4
                                color: estado === "Resuelto" ? "#E8F5E9" : "#FFF3E0"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: estado
                                    font.pixelSize: 11
                                    color: estado === "Resuelto" ? "#2E7D32" : "#F57C00"
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
        }
    }

    
    // Propiedades de los componentes
    property var contentComponents: [
        cuentaComponent,        // Cuenta
        empresaComponent,       // Empresa
        notificacionesComponent,// Notificaciones
        respaldoDatosComponent, // Respaldo de Datos
        ayudaComponent,         // Ayuda
    ]
}
