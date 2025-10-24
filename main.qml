// main.qml - Dashboard principal de AgroIchilo con autenticación
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: mainContainer
    objectName: "mainContainer"
    anchors.fill: parent
    color: "#ECEFF1"
    
    // Propiedad para rastrear el módulo activo
    property int activeModule: 0
    
    // ============================================
    // SIDEBAR / MENÚ LATERAL
    // ============================================
    Rectangle {
        id: sidebar
        width: 250
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#2C3E50"
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // ============================================
            // HEADER DEL SIDEBAR - Logo y empresa
            // ============================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#1A252F"
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    // Logo circular
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 50
                        height: 50
                        radius: 25
                        color: "#4CAF50"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "AG"
                            font.pixelSize: 20
                            font.bold: true
                            color: "white"
                        }
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "AgroIchilo"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Gestión Agrícola"
                        font.pixelSize: 11
                        color: "#95A5A6"
                    }
                }
            }
            
            // Línea separadora
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#34495E"
            }
            
            // ============================================
            // MENÚ DE NAVEGACIÓN
            // ============================================
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: sidebar.width
                    spacing: 2
                    
                    // Botón Inicio
                    MenuButton {
                        id: btnInicio
                        objectName: "btnInicio"
                        Layout.fillWidth: true
                        buttonText: "Inicio"
                        iconText: "🏠"
                        isActive: mainContainer.activeModule === 0
                    }
                    
                    // Separador de sección
                    MenuSeparator { sectionTitle: "GESTIÓN" }
                    
                    // Botón Usuarios
                    MenuButton {
                        id: btnUsuarios
                        objectName: "btnUsuarios"
                        Layout.fillWidth: true
                        buttonText: "Usuarios"
                        iconText: "👥"
                        isActive: mainContainer.activeModule === 1
                    }
                    
                    // Botón Agricultores
                    MenuButton {
                        id: btnAgricultores
                        objectName: "btnAgricultores"
                        Layout.fillWidth: true
                        buttonText: "Agricultores"
                        iconText: "🧑‍🌾"
                        isActive: mainContainer.activeModule === 2
                    }
                    
                    // Separador de sección
                    MenuSeparator { sectionTitle: "PRODUCCIÓN" }
                    
                    // Botón Cultivos
                    MenuButton {
                        id: btnCultivos
                        objectName: "btnCultivos"
                        Layout.fillWidth: true
                        buttonText: "Cultivos"
                        iconText: "🌱"
                        isActive: mainContainer.activeModule === 3
                    }
                    
                    // Botón Agroquímicos
                    MenuButton {
                        id: btnAgroquimicos
                        objectName: "btnAgroquimicos"
                        Layout.fillWidth: true
                        buttonText: "Agroquímicos"
                        iconText: "🧪"
                        isActive: mainContainer.activeModule === 4
                    }
                    
                    // Separador de sección
                    MenuSeparator { sectionTitle: "COMERCIAL" }
                    
                    // Botón Ventas
                    MenuButton {
                        id: btnVentas
                        objectName: "btnVentas"
                        Layout.fillWidth: true
                        buttonText: "Ventas"
                        iconText: "💰"
                        isActive: mainContainer.activeModule === 5
                    }
                    
                    // Botón Gastos
                    MenuButton {
                        id: btnGastos
                        objectName: "btnGastos"
                        Layout.fillWidth: true
                        buttonText: "Gastos"
                        iconText: "💸"
                        isActive: mainContainer.activeModule === 9
                    }
                    
                    // Separador de sección
                    MenuSeparator { sectionTitle: "RECURSOS" }
                    
                    // Botón Maquinaria
                    MenuButton {
                        id: btnMaquinaria
                        objectName: "btnMaquinaria"
                        Layout.fillWidth: true
                        buttonText: "Maquinaria"
                        iconText: "🚜"
                        isActive: mainContainer.activeModule === 6
                    }
                    
                    // Separador de sección
                    MenuSeparator { sectionTitle: "ANÁLISIS" }
                    
                    // Botón Reportes
                    MenuButton {
                        id: btnReportes
                        objectName: "btnReportes"
                        Layout.fillWidth: true
                        buttonText: "Reportes"
                        iconText: "📊"
                        isActive: mainContainer.activeModule === 8
                    }
                    
                    // Separador de sección
                    MenuSeparator { sectionTitle: "SISTEMA" }
                    
                    // Botón Configuración
                    MenuButton {
                        id: btnConfiguracion
                        objectName: "btnConfiguracion"
                        Layout.fillWidth: true
                        buttonText: "Configuración"
                        iconText: "⚙️"
                        isActive: mainContainer.activeModule === 7
                    }
                    
                    // Espaciador al final
                    Item { 
                        Layout.fillWidth: true
                        Layout.fillHeight: true 
                    }
                }
            }
            
            // ============================================
            // FOOTER DEL SIDEBAR - Info del usuario
            // ============================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#1A252F"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5
                    
                    // Nombre del usuario
                    Text {
                        Layout.fillWidth: true
                        text: appManager.obtenerNombreUsuario()
                        font.pixelSize: 13
                        font.bold: true
                        color: "white"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                    }
                    
                    // Rol del usuario
                    Text {
                        Layout.fillWidth: true
                        text: "🎭 " + appManager.obtenerRolUsuario()
                        font.pixelSize: 11
                        color: "#95A5A6"
                        elide: Text.ElideRight
                    }
                    
                    // Botón cerrar sesión
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: "Cerrar Sesión"
                        
                        background: Rectangle {
                            color: parent.pressed ? "#C0392B" : "#E74C3C"
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 11
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            console.log("👋 Cerrando sesión...")
                            appManager.cerrarSesion()
                        }
                    }
                }
            }
        }
    }
    
    // ============================================
    // ÁREA DE CONTENIDO PRINCIPAL
    // ============================================
    Rectangle {
        id: mainContent
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#ECEFF1"
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // ============================================
            // HEADER / BARRA SUPERIOR
            // ============================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "white"
                
                // Sombra inferior
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#E0E0E0" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    spacing: 20
                    
                    // Título del módulo actual
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            id: txtModuloActual
                            text: obtenerNombreModulo(mainContainer.activeModule)
                            font.pixelSize: 24
                            font.bold: true
                            color: "#2C3E50"
                        }
                        
                        Text {
                            text: obtenerFechaHora()
                            font.pixelSize: 12
                            color: "#7F8C8D"
                        }
                    }
                    
                    // Área derecha - Info adicional
                    RowLayout {
                        spacing: 15
                        
                        // Notificaciones (placeholder)
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#ECF0F1"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🔔"
                                font.pixelSize: 18
                            }
                            
                            // Badge de notificaciones
                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: -2
                                width: 18
                                height: 18
                                radius: 9
                                color: "#E74C3C"
                                visible: false  // Cambiar según haya notificaciones
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "3"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "white"
                                }
                            }
                        }
                        
                        // Avatar del usuario
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#4CAF50"
                            
                            Text {
                                anchors.centerIn: parent
                                text: obtenerIniciales()
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                            }
                        }
                    }
                }
            }
            
            // ============================================
            // CONTENEDOR DE MÓDULOS (Loader)
            // ============================================
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                
                Loader {
                    id: contentContainer
                    objectName: "contentContainer"
                    anchors.fill: parent
                    anchors.margins: 20
                    
                    onStatusChanged: {
                        if (status === Loader.Error) {
                            console.error("❌ Error cargando módulo:", source)
                        } else if (status === Loader.Ready) {
                            console.log("✅ Módulo cargado:", source)
                        }
                    }
                }
            }
        }
    }
    
    // ============================================
    // FUNCIONES AUXILIARES
    // ============================================
    
    function obtenerNombreModulo(index) {
        var modulos = [
            "Inicio",
            "Usuarios y Roles",
            "Agricultores y Parcelas",
            "Cultivos",
            "Agroquímicos",
            "Ventas y Clientes",
            "Maquinaria",
            "Configuración",
            "Reportes Agrícolas",
            "Gastos y Costos"
        ]
        return modulos[index] || "Módulo"
    }
    
    function obtenerFechaHora() {
        var fecha = new Date()
        var dias = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"]
        var meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                     "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
        
        return dias[fecha.getDay()] + ", " + 
               fecha.getDate() + " de " + 
               meses[fecha.getMonth()] + " de " + 
               fecha.getFullYear()
    }
    
    function obtenerIniciales() {
        var nombre = appManager.obtenerNombreUsuario()
        var partes = nombre.split(" ")
        
        if (partes.length >= 2) {
            return partes[0].charAt(0) + partes[1].charAt(0)
        } else if (partes.length === 1) {
            return partes[0].charAt(0) + partes[0].charAt(1)
        }
        
        return "U"
    }
    
    // Timer para actualizar la hora
    Timer {
        interval: 60000  // 1 minuto
        running: true
        repeat: true
        onTriggered: {
            // Forzar actualización de fecha
            txtModuloActual.text = obtenerNombreModulo(mainContainer.activeModule)
        }
    }
}

// ============================================
// COMPONENTE: MenuButton
// ============================================
MenuButton {
    id: menuButtonComponent
    
    Rectangle {
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
                text: iconText
                font.pixelSize: 20
                color: isActive ? "white" : "#95A5A6"
            }
            
            // Texto
            Text {
                Layout.fillWidth: true
                text: buttonText
                font.pixelSize: 14
                font.bold: isActive
                color: isActive ? "white" : "#BDC3C7"
            }
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onEntered: {
                if (!parent.isActive) {
                    parent.color = "#2C3E50"
                }
            }
            
            onExited: {
                if (!parent.isActive) {
                    parent.color = "transparent"
                }
            }
            
            onClicked: {
                parent.clicked()
            }
        }
    }
}

// ============================================
// COMPONENTE: MenuSeparator
// ============================================
MenuSeparator {
    id: menuSeparatorComponent
    
    Rectangle {
        property string sectionTitle: "SECCIÓN"
        
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        color: "transparent"
        
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: sectionTitle
            font.pixelSize: 11
            font.bold: true
            color: "#7F8C8D"
            letterSpacing: 1
        }
    }
}