import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: configuracionRoot
    anchors.fill: parent
    color: "#F8F9FA"

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
        
        // Side Menu Panel
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
                id: menuListView
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                model: ListModel {
                    ListElement { nombre: "Cuenta"; icono: "👤" }
                    ListElement { nombre: "Empresa"; icono: "🏢" }
                    ListElement { nombre: "Notificaciones"; icono: "🔔" }
                    ListElement { nombre: "Respaldo de Datos"; icono: "💾" }
                    ListElement { nombre: "Apariencia"; icono: "🎨" }
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
                            // Switch content based on selected menu item
                            contentLoader.sourceComponent = contentComponents[index]
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
            radius: 5
            border.color: "#EEEEEE"
            
            // Dynamic Content Loader
            Loader {
                id: contentLoader
                anchors.fill: parent
                anchors.margins: 20
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
                font.pixelSize: 20
                font.bold: true
            }
            
            // User Profile
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
                
                // Basic User Info
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
                
                // Edit Button
                Button {
                    text: "Cambiar Imagen"
                    implicitHeight: 36
                }
            }
            
            // User Data Form
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 15
                columnSpacing: 20
                
                // Name
                Text {
                    text: "Nombre:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "Juan"
                    placeholderText: "Nombre"
                }
                
                // Surname
                Text {
                    text: "Apellido:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "Delgado"
                    placeholderText: "Apellido"
                }
                
                // Email
                Text {
                    text: "Correo electrónico:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "juan.delgado@example.com"
                    placeholderText: "Correo electrónico"
                }
                
                // Phone
                Text {
                    text: "Teléfono:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "+58 412-5551234"
                    placeholderText: "Teléfono"
                }
                
                // Username
                Text {
                    text: "Nombre de usuario:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "jdelgado"
                    placeholderText: "Nombre de usuario"
                }
                
                // Change Password
                Text {
                    text: "Contraseña:"
                    font.pixelSize: 14
                }
                
                Button {
                    text: "Cambiar Contraseña"
                    implicitHeight: 36
                }
            }
            
            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#EEEEEE"
            }
            
            // Preferences
            Text {
                text: "Preferencias"
                font.pixelSize: 18
                font.bold: true
            }
            
            // Notification Options
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
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Action Buttons
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

    // Component for Company View
    Component {
        id: empresaComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Información de Empresa"
                font.pixelSize: 20
                font.bold: true
            }
            
            GridLayout {
                columns: 2
                rowSpacing: 15
                columnSpacing: 20
                
                Text {
                    text: "Nombre de la Empresa:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "Empresa Ejemplo S.A."
                    placeholderText: "Nombre de la Empresa"
                }
                
                Text {
                    text: "NIT/RIF:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "J-12345678-9"
                    placeholderText: "Número de Identificación"
                }
                
                Text {
                    text: "Dirección:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "Av. Principal, Edificio Corporativo"
                    placeholderText: "Dirección completa"
                }
                
                Text {
                    text: "Teléfono Corporativo:"
                    font.pixelSize: 14
                }
                
                TextField {
                    Layout.fillWidth: true
                    text: "+58 (212) 555-1234"
                    placeholderText: "Teléfono de la Empresa"
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Action Buttons
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

    // Component for Notifications View
    Component {
        id: notificacionesComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Configuración de Notificaciones"
                font.pixelSize: 20
                font.bold: true
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Preferencias de Notificación"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                CheckBox {
                    text: "Notificaciones por correo electrónico"
                    checked: true
                }
                
                CheckBox {
                    text: "Notificaciones push en dispositivos móviles"
                    checked: false
                }
                
                CheckBox {
                    text: "Notificaciones de escritorio"
                    checked: true
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Tipos de Notificaciones"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                CheckBox {
                    text: "Alertas de inventario"
                    checked: true
                }
                
                CheckBox {
                    text: "Recordatorios de mantenimiento"
                    checked: true
                }
                
                CheckBox {
                    text: "Actualizaciones de sistema"
                    checked: false
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Action Buttons
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
    // Componente de Respaldo de Datos
    Component {
        id: respaldoDatosComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Respaldo de Datos"
                font.pixelSize: 20
                font.bold: true
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Configuración de Respaldo Automático"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                CheckBox {
                    text: "Habilitar respaldo automático"
                    checked: true
                }
                
                RowLayout {
                    Text {
                        text: "Frecuencia de respaldo:"
                        font.pixelSize: 14
                    }
                    
                    ComboBox {
                        model: ["Diario", "Semanal", "Mensual"]
                        currentIndex: 1 // Semanal por defecto
                    }
                }
                
                RowLayout {
                    Text {
                        text: "Ubicación de respaldo:"
                        font.pixelSize: 14
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        text: "/home/usuario/respaldos"
                        placeholderText: "Ruta de respaldo"
                    }
                    
                    Button {
                        text: "Examinar"
                        implicitHeight: 36
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Respaldo Manual"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Button {
                    text: "Realizar Respaldo Ahora"
                    implicitHeight: 36
                }
                
                Text {
                    text: "Último respaldo: 05/04/2025, 22:30"
                    font.pixelSize: 14
                    color: "#757575"
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Historial de Respaldos"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                ListView {
                    Layout.fillWidth: true
                    height: 150
                    clip: true
                    
                    model: ListModel {
                        ListElement { fecha: "05/04/2025, 22:30"; tipo: "Automático"; estado: "Exitoso" }
                        ListElement { fecha: "28/03/2025, 20:15"; tipo: "Manual"; estado: "Exitoso" }
                        ListElement { fecha: "21/03/2025, 03:00"; tipo: "Automático"; estado: "Exitoso" }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: index % 2 === 0 ? "#F5F5F5" : "white"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            
                            Text {
                                text: fecha
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: tipo
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: estado
                                font.pixelSize: 12
                                color: estado === "Exitoso" ? "#2E7D32" : "#D32F2F"
                                Layout.fillWidth: true
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

    // Componente de Apariencia
    Component {
        id: aparienciaComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Configuración de Apariencia"
                font.pixelSize: 20
                font.bold: true
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Tema"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                RowLayout {
                    Text {
                        text: "Modo de Color:"
                        font.pixelSize: 14
                    }
                    
                    ComboBox {
                        model: ["Claro", "Oscuro", "Sistema"]
                        currentIndex: 0
                    }
                }
                
                RowLayout {
                    Text {
                        text: "Esquema de Color:"
                        font.pixelSize: 14
                    }
                    
                    ComboBox {
                        model: ["Predeterminado", "Azul", "Verde", "Naranja"]
                        currentIndex: 0
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Fuente"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                RowLayout {
                    Text {
                        text: "Tipo de Fuente:"
                        font.pixelSize: 14
                    }
                    
                    ComboBox {
                        model: ["Sistema", "Arial", "Roboto", "Open Sans"]
                        currentIndex: 0
                    }
                }
                
                RowLayout {
                    Text {
                        text: "Tamaño de Fuente:"
                        font.pixelSize: 14
                    }
                    
                    Slider {
                        from: 8
                        to: 24
                        stepSize: 1
                        value: 12
                    }
                    
                    Text {
                        text: "12"
                        font.pixelSize: 14
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Personalización Avanzada"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                RowLayout {
                    Text {
                        text: "Escala de Interfaz:"
                        font.pixelSize: 14
                    }
                    
                    Slider {
                        from: 0.5
                        to: 2.0
                        stepSize: 0.1
                        value: 1.0
                    }
                    
                    Text {
                        text: "100%"
                        font.pixelSize: 14
                    }
                }
                
                CheckBox {
                    text: "Animaciones suaves"
                    checked: true
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Action Buttons
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
    // Componente de Ayuda
    Component {
        id: ayudaComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Centro de Ayuda"
                font.pixelSize: 20
                font.bold: true
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Recursos de Ayuda"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Button {
                    text: "Manual de Usuario"
                    implicitHeight: 36
                    onClicked: {
                        // Lógica para abrir manual de usuario
                        console.log("Abriendo Manual de Usuario")
                    }
                }
                
                Button {
                    text: "Preguntas Frecuentes"
                    implicitHeight: 36
                    onClicked: {
                        // Lógica para mostrar preguntas frecuentes
                        console.log("Mostrando Preguntas Frecuentes")
                    }
                }
                
                Button {
                    text: "Tutoriales en Video"
                    implicitHeight: 36
                    onClicked: {
                        // Lógica para mostrar tutoriales
                        console.log("Abriendo Tutoriales")
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Información de Contacto"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                GridLayout {
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 5
                    
                    Text {
                        text: "Soporte Técnico:"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Text {
                        text: "+58 (212) 555-7890"
                        font.pixelSize: 14
                    }
                    
                    Text {
                        text: "Correo Electrónico:"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Text {
                        text: "soporte@empresa.com"
                        font.pixelSize: 14
                    }
                    
                    Text {
                        text: "Horario de Atención:"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Text {
                        text: "Lunes a Viernes: 8:00 AM - 6:00 PM"
                        font.pixelSize: 14
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Sistema de Tickets"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Button {
                    text: "Crear Nuevo Ticket"
                    implicitHeight: 36
                    onClicked: {
                        // Lógica para crear ticket de soporte
                        console.log("Creando Nuevo Ticket")
                    }
                }
                
                ListView {
                    Layout.fillWidth: true
                    height: 150
                    clip: true
                    
                    model: ListModel {
                        ListElement { numero: "#1234"; asunto: "Problema con actualización"; estado: "En Proceso" }
                        ListElement { numero: "#1233"; asunto: "Consulta de funcionalidad"; estado: "Resuelto" }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: index % 2 === 0 ? "#F5F5F5" : "white"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            
                            Text {
                                text: numero
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: asunto
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: estado
                                font.pixelSize: 12
                                color: estado === "Resuelto" ? "#2E7D32" : "#FFA500"
                                Layout.fillWidth: true
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

    // Componente de Acerca de
    Component {
        id: acercaDeComponent
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "Acerca del Sistema"
                font.pixelSize: 20
                font.bold: true
            }
            
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 200
                height: 200
                color: "#2E7D32"
                
                Text {
                    anchors.centerIn: parent
                    text: "Logo\nEmpresa"
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "Sistema de Gestión Empresarial"
                    font.pixelSize: 18
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "Versión 1.0.0 (Build 2025.04.15)"
                    font.pixelSize: 14
                    color: "#757575"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "© 2025 Empresa Ejemplo S.A. Todos los derechos reservados."
                    font.pixelSize: 12
                    color: "#757575"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Información del Sistema"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 10
                    
                    Text {
                        text: "Sistema Operativo:"
                        font.pixelSize: 14
                    }
                    Text {
                        text: "Windows 10 Pro"
                        font.pixelSize: 14
                        color: "#757575"
                    }
                    
                    Text {
                        text: "Arquitectura:"
                        font.pixelSize: 14
                    }
                    Text {
                        text: "x64"
                        font.pixelSize: 14
                        color: "#757575"
                    }
                    
                    Text {
                        text: "Memoria RAM:"
                        font.pixelSize: 14
                    }
                    Text {
                        text: "16 GB"
                        font.pixelSize: 14
                        color: "#757575"
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Componentes del Sistema"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                ListView {
                    Layout.fillWidth: true
                    height: 150
                    clip: true
                    
                    model: ListModel {
                        ListElement { componente: "Base de Datos"; version: "PostgreSQL 13.3"; estado: "Activo" }
                        ListElement { componente: "Lenguaje de Programación"; version: "Python 3.9"; estado: "Activo" }
                        ListElement { componente: "Framework"; version: "Qt 5.15"; estado: "Activo" }
                    }
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: index % 2 === 0 ? "#F5F5F5" : "white"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            
                            Text {
                                text: componente
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: version
                                font.pixelSize: 12
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: estado
                                font.pixelSize: 12
                                color: estado === "Activo" ? "#2E7D32" : "#D32F2F"
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: "Información de Licencia"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 10
                    
                    Text {
                        text: "Tipo de Licencia:"
                        font.pixelSize: 14
                    }
                    Text {
                        text: "Empresa - Multiusuario"
                        font.pixelSize: 14
                        color: "#757575"
                    }
                    
                    Text {
                        text: "Número de Licencia:"
                        font.pixelSize: 14
                    }
                    Text {
                        text: "EMPJ-2025-0001"
                        font.pixelSize: 14
                        color: "#757575"
                    }
                    
                    Text {
                        text: "Fecha de Expiración:"
                        font.pixelSize: 14
                    }
                    Text {
                        text: "31/12/2025"
                        font.pixelSize: 14
                        color: "#757575"
                    }
                }
                
                Button {
                    text: "Renovar Licencia"
                    implicitHeight: 36
                    Layout.alignment: Qt.AlignRight
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
        aparienciaComponent,    // Apariencia
        ayudaComponent,         // Ayuda
        acercaDeComponent       // Acerca de
    ]
}
