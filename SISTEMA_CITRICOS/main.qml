import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1280
    height: 720
    title: "Sistema de Gestión Agrícola de Cítricos"
    color: "#f5f5f5"

    // Propiedades de diseño - Basado en la paleta proporcionada
    property color colorVerdeBosque: "#2E7D32"    // Color principal
    property color colorNaranjaCitrico: "#FF9800" // Color secundario
    property color colorAmarilloCalido: "#FFEB3B" // Destacados
    property color colorBlancoNieve: "#FFFFFF"    // Fondo
    property color colorMarronTierra: "#795548"   // Bordes y texto
    property color colorAzulAgua: "#2196F3"       // Enlaces

    // Colores adicionales
    property color colorFondoCard: "#FFFFFF"
    property color colorTextoNormal: "#424242"
    property color colorTextoSecundario: "#757575"
    property color colorDivider: "#EEEEEE"
    property color colorAlertaRoja: "#F44336"
    property color colorAlertaVerde: "#4CAF50"
    property color colorAlertaAmarilla: "#FFC107"
    property int activeModule: 0  // 0: Inicio, 1: Usuarios, 2: Agricultores, etc.

    // Definimos el componente MenuButton
    component MenuButton: Rectangle {
        height: 50
        color: mouseArea.containsMouse ? Qt.darker(colorVerdeBosque, 1.1) : "transparent"

        property string icon: ""
        property string text: ""
        property int moduleIndex: 0
        // Señal que será conectada desde Python
        signal clicked()

        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 15
            spacing: 15

            // Ícono
            Text {
                text: icon
                font.pixelSize: 18
                color: colorAmarilloCalido
            }

            // Texto
            Text {
                text: parent.parent.text
                font.family: "Arial"
                font.pixelSize: 14
                color: "white"
                font.bold: true
            }
        }

        // Indicador de selección (visible cuando está activo)
        Rectangle {
            width: 4
            height: parent.height
            anchors.left: parent.left
            color: "white"
            visible: mainWindow.activeModule === moduleIndex
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                mainWindow.activeModule = moduleIndex
                parent.clicked()
            }
        }
    }

    Rectangle {
        id: sideBar
        width: 250
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: colorVerdeBosque

        // Logo y título
        Rectangle {
            id: logoContainer
            width: parent.width
            height: 60
            color: Qt.darker(colorVerdeBosque, 1.2)

            RowLayout {
                anchors.centerIn: parent
                spacing: 10

                // Ícono de cítrico simplificado
                Text {
                    text: "🍊"
                    font.pixelSize: 24
                }

                Text {
                    text: "SISTEMA CÍTRICOS"
                    font.family: "Arial"
                    font.pixelSize: 16
                    font.bold: true
                    color: "white"
                }
            }
        }

        // ScrollView para contener los menús
        ScrollView {
            anchors.top: logoContainer.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true

            Column {
                width: parent.width
                spacing: 4

                // Dashboard (seleccionado por defecto)
                MenuButton {
                    id: btnInicio
                    objectName: "btnInicio"
                    width: parent.width
                    icon: "📊"
                    text: "INICIO"
                    moduleIndex: 0
                    color: mainWindow.activeModule === 0 ? colorNaranjaCitrico : "transparent"

                }

                // Usuarios/Roles
                MenuButton {
                    id: btnUsuarios
                    objectName: "btnUsuarios"
                    width: parent.width
                    icon: "👥"
                    text: "USUARIOS/  ROLES"
                    moduleIndex: 1
                    color: mainWindow.activeModule === 1 ? colorNaranjaCitrico : "transparent"
                }

                // Agricultores/Parcelas
                MenuButton {
                    id: btnAgricultores
                    objectName: "btnAgricultores"
                    width: parent.width
                    icon: "👨‍🌾"
                    text: "AGRICULTORES/ PARCELA"
                    moduleIndex: 2
                    color: mainWindow.activeModule === 2 ? colorNaranjaCitrico : "transparent"
                }

                // Cultivos
                MenuButton {
                    id: btnCultivos
                    objectName: "btnCultivos"
                    width: parent.width
                    icon: "🍊"
                    text: "CULTIVOS"
                    moduleIndex: 3
                    color: mainWindow.activeModule === 3 ? colorNaranjaCitrico : "transparent"
                }

                // Agroquímicos
                MenuButton {
                    id: btnAgroquimicos
                    objectName: "btnAgroquimicos"
                    width: parent.width
                    icon: "💊"
                    text: "AGROQUIMICOS"
                    moduleIndex: 4
                    color: mainWindow.activeModule === 4 ? colorNaranjaCitrico : "transparent"
                }

                // Ventas/Clientes
                MenuButton {
                    id: btnVentas
                    objectName: "btnVentas"
                    width: parent.width
                    icon: "💰"
                    text: "VENTAS/ CLIENTES"
                    moduleIndex: 5
                    color: mainWindow.activeModule === 5 ? colorNaranjaCitrico : "transparent"
                }

                // Maquinaria
                MenuButton {
                    id: btnMaquinaria
                    objectName: "btnMaquinaria"
                    width: parent.width
                    icon: "🚜"
                    text: "MAQUINARIA"
                    moduleIndex: 6
                    color: mainWindow.activeModule === 6 ? colorNaranjaCitrico : "transparent"
                }

                // Reportes
                MenuButton {
                    id: btnReportes
                    objectName: "btnReportes"
                    width: parent.width
                    icon: "📈"
                    text: "REPORTES"
                    moduleIndex: 7
                    color: mainWindow.activeModule === 7 ? colorNaranjaCitrico : "transparent"
                }

                // Separador
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.darker(colorVerdeBosque, 1.3)
                    opacity: 0.5
                }

                // Configuración
                MenuButton {
                    id: btnConfiguracion
                    objectName: "btnConfiguracion"
                    width: parent.width
                    icon: "⚙️"
                    text: "CONFIGURACION"
                    moduleIndex: 8
                    color: mainWindow.activeModule === 8 ? colorNaranjaCitrico : "transparent"
                }

                Item {
                    width: parent.width
                    height: 20
                }
            }
        }
    }

    // Barra superior
    Rectangle {
        id: topBar
        height: 60
        anchors.left: sideBar.right
        anchors.right: parent.right
        anchors.top: parent.top
        color: colorBlancoNieve

        // Sombra
        Rectangle {
            id: topBarShadow
            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 5
            color: "#20000000"
            opacity: 0.5
        }

        // Búsqueda global
        Rectangle {
            id: searchBox
            width: 300
            height: 36
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            color: "#F5F5F5"
            radius: 18

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "🔍"
                    font.bold: true
                    font.pixelSize: 16
                    color: colorTextoSecundario
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Buscar..."
                    font.family:"Arial"
                    background: null
                    selectByMouse: true
                }
            }
        }

        // Notificaciones y perfil
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 15

            // Botón de notificaciones
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "🔔"
                    font.pixelSize: 16
                }

                // Indicador de notificaciones
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: colorAlertaRoja
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -2
                    anchors.topMargin: -2

                    Text {
                        anchors.centerIn: parent
                        text: "3"
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Mostrar popup de notificaciones
                        notificacionesPopup.open()
                    }
                }
            }

            // Perfil de usuario
            Rectangle {
                width: 150
                height: 36
                radius: 18
                color: "#F5F5F5"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8

                    // Avatar
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: colorVerdeBosque

                        Text {
                            anchors.centerIn: parent
                            text: "L"
                            font.pixelSize: 14
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Nombre de usuario
                    Text {
                        text: "Luis López"
                        font.bold: true
                        font.family: "Arial"
                        font.pixelSize: 12
                        color: colorTextoNormal
                        Layout.fillWidth: true
                    }

                    // Flecha desplegable
                    Text {
                        text: "▼"
                        font.pixelSize: 8
                        color: colorTextoSecundario
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Mostrar perfil
                        perfilPopup.open()
                    }
                }
            }
        }
    }
    
    // Contenedor principal que cargará los diferentes módulos QML
    Loader {
        id: contentContainer
        objectName: "contentContainer"
        anchors.left: sideBar.right
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        asynchronous: true
        
        // El source se configurará desde Python cuando se haga clic en un botón del menú
    }

    // COMPONENTE ADICIONAL: Modal para notificaciones
    Popup {
        id: notificacionesPopup
        width: 350
        height: 450
        x: topBar.width - width - 20
        y: topBar.height + 5
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            color: colorBlancoNieve
            radius: 10
            border.color: "#DDDDDD"
            border.width: 1

            // Usamos un rectángulo extra para simular sombra en lugar de DropShadow
            Rectangle {
                z: -1
                anchors.fill: parent
                anchors.margins: -3
                radius: 12
                color: "#30000000"
                opacity: 0.5
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Encabezado
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: colorVerdeBosque
                radius: 10
                // Para evitar esquinas redondeadas abajo
                Rectangle {
                    width: parent.width
                    height: parent.height / 2
                    anchors.bottom: parent.bottom
                    color: colorVerdeBosque
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15

                    Text {
                        text: "Notificaciones"
                        font.bold: true
                        font.family: "Arial"
                        font.pixelSize: 16
                        color: "white"
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Marcar como leídas"
                        font.bold: true
                        font.family: "Arial"
                        font.pixelSize: 12
                        color: "white"
                        opacity: 0.8

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Lógica para marcar notificaciones
                            }
                        }
                    }
                }
            }

            // Pestañas
            TabBar {
                id: notificationsTabs
                Layout.fillWidth: true
                background: Rectangle { color: "transparent" }

                TabButton {
                    text: "Todas"
                    font.bold: true
                    font.family: "Arial"
                    width: notificationsTabs.width / 3

                    background: Rectangle {
                        color: notificationsTabs.currentIndex === 0 ? "transparent" : "transparent"
                        Rectangle {
                            width: parent.width
                            height: 3
                            anchors.bottom: parent.bottom
                            color: notificationsTabs.currentIndex === 0 ? colorNaranjaCitrico : "transparent"
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: notificationsTabs.currentIndex === 0 ? colorTextoNormal : colorTextoSecundario
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                TabButton {
                    text: "Alertas"
                    font.family: "Arial"
                    font.bold: true
                    width: notificationsTabs.width / 3

                    background: Rectangle {
                        color: notificationsTabs.currentIndex === 1 ? "transparent" : "transparent"
                        Rectangle {
                            width: parent.width
                            height: 3
                            anchors.bottom: parent.bottom
                            color: notificationsTabs.currentIndex === 1 ? colorNaranjaCitrico : "transparent"
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: notificationsTabs.currentIndex === 1 ? colorTextoNormal : colorTextoSecundario
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                TabButton {
                    text: "Sistema"
                    font.bold: true
                    font.family: "Arial"
                    width: notificationsTabs.width / 3

                    background: Rectangle {
                        color: notificationsTabs.currentIndex === 2 ? "transparent" : "transparent"
                        Rectangle {
                            width: parent.width
                            height: 3
                            anchors.bottom: parent.bottom
                            color: notificationsTabs.currentIndex === 2 ? colorNaranjaCitrico : "transparent"
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: notificationsTabs.currentIndex === 2 ? colorTextoNormal : colorTextoSecundario
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Separador
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: colorDivider
            }

            // Datos de ejemplo para listados de notificaciones
            ListModel {
                id: notificacionesModel
                
                ListElement {
                    tipo: "urgente"
                    texto: "Nivel bajo de fungicida. Revisar inventario."
                    fecha: "Hoy, 10:25"
                    icono: "⚠️"
                }
                ListElement {
                    tipo: "importante"
                    texto: "Próxima cosecha en Parcela 3 en 5 días."
                    fecha: "Hoy, 09:15"
                    icono: "🍊"
                }
                ListElement {
                    tipo: "normal"
                    texto: "Reporte mensual de ventas disponible."
                    fecha: "Ayer, 15:30"
                    icono: "📊"
                }
            }
            
            Component {
                id: notificacionesDelegate
                
                Rectangle {
                    width: ListView.view.width
                    height: 70
                    color: index % 2 == 0 ? "#FAFAFA" : "#FFFFFF"
                    
                    Rectangle {
                        width: 3
                        height: parent.height - 16
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: tipo === "urgente" ? "#F44336" : tipo === "importante" ? "#FFC107" : "#2196F3"
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15
                        
                        Text {
                            text: icono
                            font.pixelSize: 24
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: texto
                                font.family: "Arial"
                                font.pixelSize: 14
                                color: "#424242"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            
                            Text {
                                text: fecha
                                font.family: "Arial"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                        }
                    }
                }
            }

            // Contenido de notificaciones (usando SwipeView para multiples páginas)
            SwipeView {
                id: notificationsSwipeView
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: notificationsTabs.currentIndex
                interactive: false

                // Todas las notificaciones
                ListView {
                    clip: true
                    model: notificacionesModel
                    delegate: notificacionesDelegate
                    ScrollBar.vertical: ScrollBar {}
                }

                // Solo alertas
                ListView {
                    clip: true
                    model: ListModel {
                        ListElement {
                            tipo: "urgente"
                            texto: "Stock bajo de fungicida. Quedan 5 unidades."
                            fecha: "Hoy, 10:25"
                            icono: "⚠️"
                        }
                        ListElement {
                            tipo: "importante"
                            texto: "Presencia de mosca blanca detectada en Parcela 7."
                            fecha: "08/04/2025"
                            icono: "🐛"
                        }
                    }
                    delegate: notificacionesDelegate
                    ScrollBar.vertical: ScrollBar {}
                }

                // Solo sistema
                ListView {
                    clip: true
                    model: ListModel {
                        ListElement {
                            tipo: "normal"
                            texto: "Actualización del sistema completada."
                            fecha: "Hoy, 08:30"
                            icono: "🔄"
                        }
                        ListElement {
                            tipo: "normal"
                            texto: "Copia de seguridad automática realizada."
                            fecha: "Ayer, 23:00"
                            icono: "💾"
                        }
                    }
                    delegate: notificacionesDelegate
                    ScrollBar.vertical: ScrollBar {}
                }
            }

            // Pie del modal
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#F5F5F5"

                Text {
                    anchors.centerIn: parent
                    text: "Ver historial completo"
                    font.family: "Arial"
                    font.pixelSize: 12
                    color: colorAzulAgua

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Lógica para ver historial completo
                            notificacionesPopup.close()
                        }
                    }
                }
            }
        }

        // Conexión entre las pestañas y el SwipeView
        Connections {
            target: notificationsTabs
            function onCurrentIndexChanged() {
                notificationsSwipeView.currentIndex = notificationsTabs.currentIndex
            }
        }
    }

    // COMPONENTE ADICIONAL: Modal para perfil de usuario
    Popup {
        id: perfilPopup
        width: 300
        height: 350
        x: topBar.width - width - 20
        y: topBar.height + 5
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            color: colorBlancoNieve
            radius: 10
            border.color: "#DDDDDD"
            border.width: 1

            // Simulación de sombra
            Rectangle {
                z: -1
                anchors.fill: parent
                anchors.margins: -3
                radius: 12
                color: "#30000000"
                opacity: 0.5
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Encabezado con avatar y nombre
            Rectangle {
                Layout.fillWidth: true
                height: 100
                color: colorVerdeBosque
                radius: 10
                // Para evitar esquinas redondeadas abajo
                Rectangle {
                    width: parent.width
                    height: parent.height / 2
                    anchors.bottom: parent.bottom
                    color: colorVerdeBosque
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5

                    // Avatar grande
                    Rectangle {
                        width: 60
                        height: 60
                        radius: 30
                        color: colorBlancoNieve
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            anchors.centerIn: parent
                            text: "L"
                            font.pixelSize: 30
                            font.bold: true
                            color: colorVerdeBosque
                        }
                    }

                    // Nombre de usuario
                    Text {
                        text: "Luis López"
                        font.family: "Arial"
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Contenido del perfil
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: ListModel {
                    ListElement { icon: "👤"; text: "Mi perfil" }
                    ListElement { icon: "🔐"; text: "Cambiar contraseña" }
                    ListElement { icon: "⚙️"; text: "Preferencias" }
                    ListElement { icon: "🔔"; text: "Notificaciones" }
                    ListElement { icon: "❓"; text: "Ayuda" }
                    ListElement { icon: "📋"; text: "Términos y condiciones" }
                    ListElement { icon: "🔒"; text: "Privacidad" }
                }
                delegate: Rectangle {
                    width: ListView.view.width
                    height: 50
                    color: mouseArea.containsMouse ? "#F5F5F5" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Text {
                            text: icon
                            font.pixelSize: 20
                        }

                        Text {
                            text: model.text
                            font.family: "Arial"
                            font.pixelSize: 14
                            color: "#424242"
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Acciones según la opción seleccionada
                            perfilPopup.close()
                        }
                    }
                }
            }

            // Botón de cierre de sesión
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#F5F5F5"
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Text {
                        text: "🚪"
                        font.pixelSize: 16
                    }
                    
                    Text {
                        text: "Cerrar sesión"
                        font.bold: true
                        font.family: "Arial"
                        font.pixelSize: 14
                        color: colorAlertaRoja
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Lógica para cerrar sesión
                        perfilPopup.close()
                    }
                }
            }
        }
    }
}