// main.qml - Dashboard principal de AgroIchilo v2.0
// Sprint 1.4 - Sistema de Diseño y Arquitectura Visual
// Reestructurado con sistema de estilos profesional

// ⚠️ NOTA: DropShadow no está disponible en Qt 6 / PySide6 / Python 3.13
// Se usan bordes y efectos alternativos para mantener compatibilidad

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Importar sistema de estilos
import "styles" as Styles
import "components"

Rectangle {
    id: mainContainer
    objectName: "mainContainer"
    anchors.fill: parent
    color: Styles.AppTheme.colors.bgApp
    
    // ============================================
    // PROPIEDADES
    // ============================================
    property int activeModule: 0
    
    // Observar cambios en activeModule
    onActiveModuleChanged: {
        console.log("📂 Módulo activo cambiado a:", activeModule)
        cargarModulo(activeModule)
    }
    
    // ============================================
    // FUNCIONES
    // ============================================
    
    function cargarModulo(moduleIndex) {
        var modulosFiles = {
            0: "dashboard.qml",
            1: "usuario_roles.qml",
            2: "productores_parcela.qml",
            3: "cultivos.qml",
            4: "agroquimico.qml",
            5: "ventas_cliente.qml",
            6: "maquinaria.qml",
            7: "configuracion.qml",
            8: "reportesAgricola.qml",
            9: "finanzas.qml"
        }
        
        var qmlFile = modulosFiles[moduleIndex]
        if (qmlFile) {
            console.log("📄 Cargando:", qmlFile)
            contentContainer.source = qmlFile
        } else {
            console.error("❌ No se encontró módulo para índice:", moduleIndex)
        }
    }
    
    function obtenerNombreModulo(index) {
        var modulos = [
            "Inicio",
            "Usuarios y Roles",
            "Productores y Parcelas",
            "Cultivos",
            "Agroquímicos",
            "Ventas y Clientes",
            "Maquinaria",
            "Configuración",
            "Reportes Agrícolas",
            "Finanzas"
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
    
    // ============================================
    // LAYOUT PRINCIPAL
    // ============================================
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // ============================================
        // SIDEBAR / MENÚ LATERAL
        // ============================================
        Rectangle {
            id: sidebar
            Layout.preferredWidth: Styles.AppTheme.sidebarWidth
            Layout.fillHeight: true
            color: Styles.AppTheme.colors.sidebarBg
            
            // Borde derecho en lugar de sombra
            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: Qt.rgba(0, 0, 0, 0.15)
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // ============================================
                // HEADER DEL SIDEBAR - Logo y empresa
                // ============================================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Styles.AppTheme.sidebarHeaderHeight
                    color: Styles.AppTheme.colors.sidebarHeader
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Styles.AppTheme.spaceSm
                        
                        // Logo circular
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: Styles.AppTheme.sidebarLogoSize
                            height: Styles.AppTheme.sidebarLogoSize
                            radius: Styles.AppTheme.radiusFull
                            color: Styles.AppTheme.colors.primaryLight
                            
                            // Borde sutil en lugar de sombra
                            border.width: 2
                            border.color: Qt.rgba(255, 255, 255, 0.2)
                            
                            Text {
                                anchors.centerIn: parent
                                text: "AG"
                                font.pixelSize: Styles.AppTheme.fontSizeXl
                                font.weight: Styles.AppTheme.fontWeightBold
                                color: Styles.AppTheme.colors.white
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "AgroIchilo"
                            font.pixelSize: Styles.AppTheme.fontSizeLg
                            font.weight: Styles.AppTheme.fontWeightSemiBold
                            font.family: Styles.AppTheme.fontFamilyHeading
                            color: Styles.AppTheme.colors.sidebarText
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Gestión Agrícola"
                            font.pixelSize: Styles.AppTheme.fontSizeXs
                            font.weight: Styles.AppTheme.fontWeightNormal
                            color: Styles.AppTheme.colors.sidebarTextMuted
                        }
                    }
                }
                
                // Línea separadora
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Styles.AppTheme.colors.sidebarSeparator
                }
                
                // ============================================
                // MENÚ DE NAVEGACIÓN
                // ============================================
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    
                    ColumnLayout {
                        width: sidebar.width
                        spacing: Styles.AppTheme.spaceXxs
                        
                        // Espaciado superior
                        Item { Layout.preferredHeight: Styles.AppTheme.spaceSm }
                        
                        // Botón Inicio
                        MenuButton {
                            id: btnInicio
                            objectName: "btnInicio"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Inicio"
                            iconSource: "../recursos/image/icons/Home.png"
                            isActive: mainContainer.activeModule === 0
                            onClicked: mainContainer.activeModule = 0
                        }
                        
                        // Separador de sección
                        MenuSeparator { sectionTitle: "GESTIÓN" }
                        
                        // Botón Usuarios
                        MenuButton {
                            id: btnUsuarios
                            objectName: "btnUsuarios"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Usuarios"
                            iconSource: "../recursos/image/icons/usuario.png"
                            isActive: mainContainer.activeModule === 1
                            onClicked: mainContainer.activeModule = 1
                        }
                        
                        // Botón Productores
                        MenuButton {
                            id: btnProductores
                            objectName: "btnProductores" 
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Productores"
                            iconSource: "../recursos/image/icons/agricultor.png" 
                            isActive: mainContainer.activeModule === 2
                            onClicked: mainContainer.activeModule = 2
                        }
                        
                        // Separador de sección
                        MenuSeparator { sectionTitle: "PRODUCCIÓN" }
                        
                        // Botón Cultivos
                        MenuButton {
                            id: btnCultivos
                            objectName: "btnCultivos"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Cultivos"
                            iconSource: "../recursos/image/icons/cultivos.png"
                            isActive: mainContainer.activeModule === 3
                            onClicked: mainContainer.activeModule = 3
                        }
                        
                        // Botón Agroquímicos
                        MenuButton {
                            id: btnAgroquimicos
                            objectName: "btnAgroquimicos"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Agroquímicos"
                            iconSource: "../recursos/image/icons/productos-quimicos.png"
                            isActive: mainContainer.activeModule === 4
                            onClicked: mainContainer.activeModule = 4
                        }
                        
                        // Separador de sección
                        MenuSeparator { sectionTitle: "COMERCIAL" }
                        
                        // Botón Ventas
                        MenuButton {
                            id: btnVentas
                            objectName: "btnVentas"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Ventas"
                            iconSource: "../recursos/image/icons/ventas.png"
                            isActive: mainContainer.activeModule === 5
                            onClicked: mainContainer.activeModule = 5
                        }
                        
                        // Botón Gastos
                        MenuButton {
                            id: btnGastos
                            objectName: "btnGastos"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Finanzas"
                            iconSource: "../recursos/image/icons/gasto.png"
                            isActive: mainContainer.activeModule === 9
                            onClicked: mainContainer.activeModule = 9
                        }
                        
                        // Separador de sección
                        MenuSeparator { sectionTitle: "RECURSOS" }
                        
                        // Botón Maquinaria
                        MenuButton {
                            id: btnMaquinaria
                            objectName: "btnMaquinaria"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Maquinaria"
                            iconSource: "../recursos/image/icons/tractor.png"
                            isActive: mainContainer.activeModule === 6
                            onClicked: mainContainer.activeModule = 6
                        }
                        
                        // Separador de sección
                        MenuSeparator { sectionTitle: "ANÁLISIS" }
                        
                        // Botón Reportes
                        MenuButton {
                            id: btnReportes
                            objectName: "btnReportes"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Reportes"
                            iconSource: "../recursos/image/icons/reportes.png"
                            isActive: mainContainer.activeModule === 8
                            onClicked: mainContainer.activeModule = 8
                        }
                        
                        // Espaciador para empujar configuración al final
                        Item { Layout.fillHeight: true }
                        
                        // Línea separadora
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.margins: Styles.AppTheme.spaceMd
                            color: Styles.AppTheme.colors.sidebarSeparator
                        }
                        
                        // Botón Configuración
                        MenuButton {
                            id: btnConfiguracion
                            objectName: "btnConfiguracion"
                            Layout.fillWidth: true
                            Layout.margins: Styles.AppTheme.spaceXs
                            buttonText: "Configuración"
                            iconSource: "../recursos/image/icons/configuraciones.png"
                            isActive: mainContainer.activeModule === 7
                            onClicked: mainContainer.activeModule = 7
                        }
                        
                        // Espaciado inferior
                        Item { Layout.preferredHeight: Styles.AppTheme.spaceMd }
                    }
                }
            }
        }
        
        // ============================================
        // ÁREA DE CONTENIDO PRINCIPAL
        // ============================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            
            // ============================================
            // HEADER / BARRA SUPERIOR
            // ============================================
            Rectangle {
                id: header
                Layout.fillWidth: true
                Layout.preferredHeight: Styles.AppTheme.headerHeight
                color: Styles.AppTheme.colors.headerBg
                
                // Borde inferior
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Styles.AppTheme.colors.headerBorder
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Styles.AppTheme.headerPadding
                    anchors.rightMargin: Styles.AppTheme.headerPadding
                    spacing: Styles.AppTheme.spaceLg
                    
                    // ============================================
                    // LADO IZQUIERDO - Título y fecha
                    // ============================================
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Styles.AppTheme.spaceXxs
                        
                        Text {
                            id: txtModulo
                            text: obtenerNombreModulo(mainContainer.activeModule)
                            font.pixelSize: Styles.AppTheme.fontSize2xl
                            font.weight: Styles.AppTheme.fontWeightBold
                            font.family: Styles.AppTheme.fontFamilyHeading
                            color: Styles.AppTheme.colors.headerText
                        }
                        
                        Text {
                            id: txtFecha
                            text: obtenerFechaHora()
                            font.pixelSize: Styles.AppTheme.fontSizeSm
                            font.weight: Styles.AppTheme.fontWeightNormal
                            color: Styles.AppTheme.colors.headerTextMuted
                        }
                    }
                    
                    // Espaciador
                    Item { Layout.fillWidth: true }
                    
                    // ============================================
                    // LADO DERECHO - Notificaciones y perfil
                    // ============================================
                    RowLayout {
                        spacing: Styles.AppTheme.spaceMd
                        
                        // Botón de notificaciones
                        Rectangle {
                            id: notificationButton
                            width: Styles.AppTheme.headerNotificationSize
                            height: Styles.AppTheme.headerNotificationSize
                            radius: Styles.AppTheme.radiusFull
                            color: notificationMouseArea.containsMouse ? 
                                   Styles.AppTheme.colors.gray100 : "transparent"
                            
                            Behavior on color {
                                ColorAnimation { duration: Styles.AppTheme.transitionFast }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🔔"
                                font.pixelSize: Styles.AppTheme.fontSizeLg
                            }
                            
                            // Badge de notificaciones
                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: -2
                                width: 18
                                height: 18
                                radius: Styles.AppTheme.radiusFull
                                color: Styles.AppTheme.colors.error
                                visible: true  // Hay 3 notificaciones no leídas
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "3"
                                    font.pixelSize: Styles.AppTheme.fontSizeXs
                                    font.weight: Styles.AppTheme.fontWeightBold
                                    color: Styles.AppTheme.colors.white
                                }
                            }
                            
                            MouseArea {
                                id: notificationMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("🔔 Abriendo panel de notificaciones")
                                    notificationsPopup.open()
                                }
                            }
                        }
                        
                        // Separador vertical
                        Rectangle {
                            width: 1
                            height: 30
                            color: Styles.AppTheme.colors.border
                        }
                        
                        // Perfil de usuario
                        Rectangle {
                            id: userProfile
                            width: profileContent.width
                            height: Styles.AppTheme.headerNotificationSize
                            radius: Styles.AppTheme.radiusLg
                            color: profileMouseArea.containsMouse ? 
                                   Styles.AppTheme.colors.gray100 : "transparent"
                            
                            Behavior on color {
                                ColorAnimation { duration: Styles.AppTheme.transitionFast }
                            }
                            
                            RowLayout {
                                id: profileContent
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Styles.AppTheme.spaceSm
                                
                                // Avatar
                                Rectangle {
                                    width: Styles.AppTheme.headerAvatarSize
                                    height: Styles.AppTheme.headerAvatarSize
                                    radius: Styles.AppTheme.radiusFull
                                    color: Styles.AppTheme.colors.primaryLight
                                    
                                    // Borde sutil
                                    border.width: 2
                                    border.color: Qt.rgba(46, 125, 50, 0.2)
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: obtenerIniciales()
                                        font.pixelSize: Styles.AppTheme.fontSizeMd
                                        font.weight: Styles.AppTheme.fontWeightBold
                                        color: Styles.AppTheme.colors.white
                                    }
                                }
                                
                                // Información del usuario
                                ColumnLayout {
                                    spacing: 0
                                    
                                    Text {
                                        text: appManager.obtenerNombreUsuario()
                                        font.pixelSize: Styles.AppTheme.fontSizeSm
                                        font.weight: Styles.AppTheme.fontWeightMedium
                                        color: Styles.AppTheme.colors.headerText
                                    }
                                    
                                    Text {
                                        text: appManager.obtenerRolUsuario()
                                        font.pixelSize: Styles.AppTheme.fontSizeXs
                                        color: Styles.AppTheme.colors.headerTextMuted
                                    }
                                }
                                
                                // Icono de dropdown
                                Text {
                                    text: "▼"
                                    font.pixelSize: Styles.AppTheme.fontSizeXs
                                    color: Styles.AppTheme.colors.headerTextMuted
                                }
                            }
                            
                            MouseArea {
                                id: profileMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("👤 Abriendo menú de usuario")
                                    userMenuPopup.open()
                                }
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
                    anchors.margins: Styles.AppTheme.spaceXl
                    
                    source: "dashboard.qml"
                    
                    onStatusChanged: {
                        if (status === Loader.Error) {
                            console.error("❌ Error cargando módulo:", source)
                        } else if (status === Loader.Ready) {
                            console.log("✅ Módulo cargado:", source)
                        } else if (status === Loader.Loading) {
                            console.log("⏳ Cargando módulo:", source)
                        }
                    }
                }
                
                // Indicador de carga
                Rectangle {
                    anchors.centerIn: parent
                    width: 200
                    height: 80
                    color: Styles.AppTheme.colors.white
                    radius: Styles.AppTheme.radiusLg
                    visible: contentContainer.status === Loader.Loading
                    
                    border.color: Styles.AppTheme.colors.border
                    border.width: Styles.AppTheme.borderThin
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Styles.AppTheme.spaceSm
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "⏳"
                            font.pixelSize: Styles.AppTheme.fontSize2xl
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Cargando módulo..."
                            font.pixelSize: Styles.AppTheme.fontSizeMd
                            color: Styles.AppTheme.colors.textSecondary
                        }
                    }
                }
                
                // Mensaje de error
                Rectangle {
                    anchors.centerIn: parent
                    width: 300
                    height: 120
                    color: Styles.AppTheme.colors.warningBg
                    radius: Styles.AppTheme.radiusLg
                    visible: contentContainer.status === Loader.Error
                    
                    border.color: Styles.AppTheme.colors.warning
                    border.width: Styles.AppTheme.borderMedium
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.AppTheme.spaceLg
                        spacing: Styles.AppTheme.spaceSm
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "⚠️"
                            font.pixelSize: Styles.AppTheme.fontSize2xl
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            text: "Error cargando el módulo"
                            font.pixelSize: Styles.AppTheme.fontSizeMd
                            font.weight: Styles.AppTheme.fontWeightBold
                            color: Styles.AppTheme.colors.warningDark
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            text: contentContainer.source
                            font.pixelSize: Styles.AppTheme.fontSizeXs
                            color: Styles.AppTheme.colors.warningDark
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }
        }
    }
    
    // ============================================
    // POPUPS
    // ============================================
    
    // Popup del menú de usuario
    UserMenuPopup {
        id: userMenuPopup
        parent: userProfile
        userName: appManager.obtenerNombreUsuario()
        userRole: appManager.obtenerRolUsuario()
        
        onProfileClicked: {
            console.log("🔧 Abrir perfil de usuario")
            // TODO: Navegar a módulo de perfil
        }
        
        onSettingsClicked: {
            console.log("⚙️ Abrir configuración")
            mainContainer.activeModule = 7  // Módulo de configuración
        }
        
        onLogoutClicked: {
            console.log("🚪 Cerrando sesión...")
            appManager.cerrarSesion()
        }
    }
    
    // Popup de notificaciones
    NotificationsPopup {
        id: notificationsPopup
        parent: notificationButton
    }
    
    // ============================================
    // TIMER PARA ACTUALIZAR FECHA
    // ============================================
    Timer {
        interval: 60000  // 1 minuto
        running: true
        repeat: true
        onTriggered: {
            txtFecha.text = obtenerFechaHora()
        }
    }
    
    // ============================================
    // INICIALIZACIÓN
    // ============================================
    Component.onCompleted: {
        console.log("✅ main.qml v2.0 completamente cargado")
        console.log("📂 Módulo inicial: dashboard")
        console.log("🎨 Sistema de diseño aplicado")
    }
}
