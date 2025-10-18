import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1280
    height: 720
    title: "AgroIchilo - Sistema de Gestión Agrícola"
    color: "#f5f5f5"

    // Propiedades de diseño - Basado en la paleta proporcionada
    property color colorVerdeBosque: "#2E7D32"    // Color principal
    property color colorNaranjaCitrico: "#2f2e2e" // Color secundario
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

    property bool sideBarCollapsed: false
    property int collapsedSidebarWidth: 70
    property int expandedSidebarWidth: 250

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
            anchors.leftMargin:15
            spacing: 15

            // Ícono - corregido
            Item {
                width: 35
                height: 35
                
                // Imagen para rutas de archivo
                Image {
                    anchors.fill: parent
                    source: icon.length > 2 ? icon : ""
                    fillMode: Image.PreserveAspectFit
                    visible: icon.length > 2
                }
            }

            // Texto - solo visible cuando expandido
            Text {
                text: parent.parent.text
                font.family: "Arial"
                font.pixelSize: 14
                color: "white"
                font.bold: true
                visible: !mainWindow.sideBarCollapsed
            }
        }

        // Corrige el indicador de selección para que se oculte en estado colapsado
        Rectangle {
            width: 4
            height: parent.height
            anchors.left: parent.left
            color: "white"
            visible: mainWindow.activeModule === moduleIndex && !mainWindow.sideBarCollapsed
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
        width: mainWindow.sideBarCollapsed ? collapsedSidebarWidth : expandedSidebarWidth
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: colorVerdeBosque

        Behavior on width {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        // Logo y título
        Rectangle {
            id: logoContainer
            width: parent.width
            height: 60
            color: Qt.darker(colorVerdeBosque, 1.2)

            RowLayout {
                anchors.centerIn: parent
                spacing: 10
                visible: !mainWindow.sideBarCollapsed

                // Ícono de cítrico simplificado (Por ahora no)
                // Agrega este Image para el icono
                Image {
                    source: "Image/Image_UI_interfaz/Inconos/AgroIchilo.svg" // Ruta a tu logo SVG
                    sourceSize.width: 32
                    sourceSize.height: 32
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    text: "AGROICHILO"
                    font.family: "Arial"
                    font.pixelSize: 16
                    font.bold: true
                    color: "white"
                }
            }

            Image {
                anchors.centerIn: parent
                source: "Image/Image_UI_interfaz/Inconos/AgroIchilo.svg"
                sourceSize.width: 30
                sourceSize.height: 30
                fillMode: Image.PreserveAspectFit
                visible: mainWindow.sideBarCollapsed
            }

            // Boton Hamburguesa
            Rectangle {
                id: hamburgerButton
                width: 40
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                color: "transparent"
                
                
                Image {
                    anchors.centerIn: parent
                    source: "Image/Image_UI_interfaz/Inconos/menu-hamburguesa.svg"
                    width: 24
                    height: 24
                    rotation: mainWindow.sideBarCollapsed ? 180 : 0
                    
                    Behavior on rotation {
                        NumberAnimation { duration: 200 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mainWindow.sideBarCollapsed = !mainWindow.sideBarCollapsed
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
                    icon :"Image/Image_UI_interfaz/Inconos/hogar.png" 
                    text: "INICIO"
                    moduleIndex: 0
                    color: mainWindow.activeModule === 0 ? colorNaranjaCitrico : "transparent"

                }

                // Usuarios/Roles
                MenuButton {
                    id: btnUsuarios
                    objectName: "btnUsuarios"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/usuario.png"
                    text: "USUARIOS"
                    moduleIndex: 1
                    color: mainWindow.activeModule === 1 ? colorNaranjaCitrico : "transparent"
                }

                // Agricultores/Parcelas
                MenuButton {
                    id: btnAgricultores
                    objectName: "btnAgricultores"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/agricultor.png"
                    text: "AGRICULTORES/PARCELA"
                    moduleIndex: 2
                    color: mainWindow.activeModule === 2 ? colorNaranjaCitrico : "transparent"
                }

                // Cultivos
                MenuButton {
                    id: btnCultivos
                    objectName: "btnCultivos"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/cultivos.png"
                    text: "CULTIVOS"
                    moduleIndex: 3
                    color: mainWindow.activeModule === 3 ? colorNaranjaCitrico : "transparent"
                }

                // Agroquímicos
                MenuButton {
                    id: btnAgroquimicos
                    objectName: "btnAgroquimicos"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/productos-quimicos.png"
                    text: "AGROQUIMICOS"
                    moduleIndex: 4
                    color: mainWindow.activeModule === 4 ? colorNaranjaCitrico : "transparent"
                }

                // Ventas/Clientes
                MenuButton {
                    id: btnVentas
                    objectName: "btnVentas"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/ventas.png"
                    text: "VENTAS/CLIENTES"
                    moduleIndex: 5
                    color: mainWindow.activeModule === 5 ? colorNaranjaCitrico : "transparent"
                }

                // Maquinaria
                MenuButton {
                    id: btnMaquinaria
                    objectName: "btnMaquinaria"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/tractor.png"
                    text: "MAQUINARIA"
                    moduleIndex: 6
                    color: mainWindow.activeModule === 6 ? colorNaranjaCitrico : "transparent"
                }

                // Configuración
                MenuButton {
                    id: btnConfiguracion
                    objectName: "btnConfiguracion"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/configuraciones.png"
                    text: "CONFIGURACION"
                    moduleIndex: 7
                    color: mainWindow.activeModule === 7 ? colorNaranjaCitrico : "transparent"
                }
                // reportes
                MenuButton {
                    id: btnReportes
                    objectName: "btnReportes"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/configuraciones.png"
                    text: "REPORTES"
                    moduleIndex: 8
                    color: mainWindow.activeModule === 8 ? colorNaranjaCitrico : "transparent"
                }
                // Usuarios/Roles
                MenuButton {
                    id: btnGastos
                    objectName: "btnGastos"
                    width: parent.width
                    icon: "Image/Image_UI_interfaz/Inconos/mandarinaincor.svg"
                    text: "GASTOS"
                    moduleIndex: 9
                    color: mainWindow.activeModule === 1 ? colorNaranjaCitrico : "transparent"
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

        // Añadir esta propiedad
        property var agricultoresModel: agricultoresparcelas
        onLoaded: {
            if (source == "agricultores_parcela.qml" && item) {
                item.agricultoresparcelas = agricultoresModel;
            }
        }
        
    }

    // COMPONENTE MEJORADO: Modal para notificaciones
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

        // Propiedades para controlar el contenido visible
        property int currentTab: 0  // 0: Todas, 1: Alertas, 2: Sistema

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

            // Pestañas personalizadas
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Pestaña "Todas"
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Todas"
                            font.bold: notificacionesPopup.currentTab === 0
                            font.family: "Arial"
                            font.pixelSize: 14
                            color: notificacionesPopup.currentTab === 0 ? colorTextoNormal : colorTextoSecundario
                        }

                        Rectangle {
                            width: parent.width
                            height: 3
                            anchors.bottom: parent.bottom
                            color: notificacionesPopup.currentTab === 0 ? colorNaranjaCitrico : "transparent"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                notificacionesPopup.currentTab = 0
                            }
                        }
                    }

                    // Pestaña "Alertas"
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Alertas"
                            font.bold: notificacionesPopup.currentTab === 1
                            font.family: "Arial"
                            font.pixelSize: 14
                            color: notificacionesPopup.currentTab === 1 ? colorTextoNormal : colorTextoSecundario
                        }

                        Rectangle {
                            width: parent.width
                            height: 3
                            anchors.bottom: parent.bottom
                            color: notificacionesPopup.currentTab === 1 ? colorNaranjaCitrico : "transparent"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                notificacionesPopup.currentTab = 1
                            }
                        }
                    }

                    // Pestaña "Sistema"
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Sistema"
                            font.bold: notificacionesPopup.currentTab === 2
                            font.family: "Arial"
                            font.pixelSize: 14
                            color: notificacionesPopup.currentTab === 2 ? colorTextoNormal : colorTextoSecundario
                        }

                        Rectangle {
                            width: parent.width
                            height: 3
                            anchors.bottom: parent.bottom
                            color: notificacionesPopup.currentTab === 2 ? colorNaranjaCitrico : "transparent"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                notificacionesPopup.currentTab = 2
                            }
                        }
                    }
                }
            }

            // Separador
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: colorDivider
            }

            // CONTENIDO DE NOTIFICACIONES
            // Este es el contenedor principal que mostrará las listas según la pestaña seleccionada
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                clip: true

                // LISTA DE TODAS LAS NOTIFICACIONES
                ListView {
                    id: todasListView
                    anchors.fill: parent
                    visible: notificacionesPopup.currentTab === 0
                    clip: true
                    model: ListModel {
                        id: todasModel
                        // Notificaciones de tipo urgente
                        ListElement {
                            tipo: "urgente"
                            texto: "Nivel bajo de fungicida. Revisar inventario."
                            fecha: "Hoy, 10:25"
                            icono: "⚠️"
                        }
                        ListElement {
                            tipo: "urgente"
                            texto: "Stock bajo de fungicida. Quedan 5 unidades."
                            fecha: "Hoy, 10:25"
                            icono: "⚠️"
                        }
                        // Notificaciones de tipo importante
                        ListElement {
                            tipo: "importante"
                            texto: "Próxima cosecha en Parcela 3 en 5 días."
                            fecha: "Hoy, 09:15"
                            icono: "🍊"
                        }
                        ListElement {
                            tipo: "importante"
                            texto: "Presencia de mosca blanca detectada en Parcela 7."
                            fecha: "08/04/2025"
                            icono: "🐛"
                        }
                        // Notificaciones de tipo normal/sistema
                        ListElement {
                            tipo: "normal"
                            texto: "Reporte mensual de ventas disponible."
                            fecha: "Ayer, 15:30"
                            icono: "📊"
                        }
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

                // LISTA SOLO DE ALERTAS
                ListView {
                    id: alertasListView
                    anchors.fill: parent
                    visible: notificacionesPopup.currentTab === 1
                    clip: true
                    model: ListModel {
                        id: alertasModel
                        // Solo notificaciones de tipo urgente e importante
                        ListElement {
                            tipo: "urgente"
                            texto: "Nivel bajo de fungicida. Revisar inventario."
                            fecha: "Hoy, 10:25"
                            icono: "⚠️"
                        }
                        ListElement {
                            tipo: "urgente"
                            texto: "Stock bajo de fungicida. Quedan 5 unidades."
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
                            tipo: "importante"
                            texto: "Presencia de mosca blanca detectada en Parcela 7."
                            fecha: "08/04/2025"
                            icono: "🐛"
                        }
                    }
                    delegate: notificacionesDelegate
                    ScrollBar.vertical: ScrollBar {}
                }

                // LISTA SOLO DE SISTEMA
                ListView {
                    id: sistemaListView
                    anchors.fill: parent
                    visible: notificacionesPopup.currentTab === 2
                    clip: true
                    model: ListModel {
                        id: sistemaModel
                        // Solo notificaciones de tipo normal/sistema
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
                        ListElement {
                            tipo: "normal"
                            texto: "Reporte mensual de ventas disponible."
                            fecha: "Ayer, 15:30"
                            icono: "📊"
                        }
                        ListElement {
                            tipo: "normal"
                            texto: "Nueva versión disponible: 2.1.5"
                            fecha: "27/04/2025"
                            icono: "📱"
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

        // COMPONENTE DELEGADO PARA LAS NOTIFICACIONES
        // Este componente define la apariencia de cada notificación
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
    }

    // COMPONENTE CORREGIDO: Modal para perfil de usuario
    Popup {
        id: perfilPopup
        width: 400
        height: 600
        x: parent.width - width - 20
        y: 60  // Posición justo debajo de la barra superior
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0
        
        // Importante: z superior para asegurar que aparezca sobre otros elementos
        z: 1000

        // Propiedad para controlar qué vista se muestra
        property string currentView: "menu" // Valores posibles: "menu", "perfil", "password"

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

        // VISTA DE MENÚ PRINCIPAL
        Item {
            id: menuView
            anchors.fill: parent
            visible: perfilPopup.currentView === "menu"

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
                    Image {
                        anchors.centerIn: parent
                        source: "Image/Image_UI_interfaz/Inconos/AgroIchilo.svg"
                        sourceSize.width: 80
                        sourceSize.height: 80
                        fillMode: Image.PreserveAspectFit
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
                        // Eliminadas las opciones de Preferencias y Notificaciones
                        ListElement { icon: "👤"; text: "Mi perfil"; view: "perfil" }
                        ListElement { icon: "🔐"; text: "Cambiar contraseña"; view: "password" }
                        ListElement { icon: "❓"; text: "Ayuda"; view: "" }
                        ListElement { icon: "📋"; text: "Términos y condiciones"; view: "" }
                        ListElement { icon: "🔒"; text: "Privacidad"; view: "" }
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
                                if (model.view !== "") {
                                    // Cambiar a la vista correspondiente si tiene una asignada
                                    perfilPopup.currentView = model.view
                                } else {
                                    // Para opciones sin vista específica
                                    perfilPopup.close()
                                }
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

        // VISTA DE MI PERFIL
        Item {
            id: perfilView
            anchors.fill: parent
            visible: perfilPopup.currentView === "perfil"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Encabezado
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: colorVerdeBosque

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        
                        // Botón de regresar
                        Rectangle {
                            width: 30
                            height: 30
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "←"
                                font.pixelSize: 20
                                color: "white"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    perfilPopup.currentView = "menu"
                                }
                            }
                        }
                        
                        Text {
                            text: "Mi Perfil"
                            font.bold: true
                            font.family: "Arial"
                            font.pixelSize: 16
                            color: "white"
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }

                // Contenido del formulario de perfil
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20
                        
                        // Foto de perfil
                        Item {
                            Layout.fillWidth: true
                            height: 100
                            Layout.topMargin: 20
                            
                            Rectangle {
                                width: 80
                                height: 80
                                radius: 40
                                color: colorVerdeBosque
                                anchors.centerIn: parent
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "L"
                                    font.pixelSize: 36
                                    font.bold: true
                                    color: "white"
                                }
                            }
                            
                            Rectangle {
                                width: 30
                                height: 30
                                radius: 15
                                color: colorNaranjaCitrico
                                anchors.right: parent.horizontalCenter
                                anchors.rightMargin: -30
                                anchors.bottom: parent.verticalCenter
                                anchors.bottomMargin: -30
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "📷"
                                    font.pixelSize: 16
                                    color: "white"
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // Lógica para cambiar la foto
                                    }
                                }
                            }
                        }
                        
                        // Datos personales
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                            columns: 2
                            rowSpacing: 15
                            columnSpacing: 10
                            
                            // Nombre
                            Text {
                                text: "Nombre:"
                                font.bold: true
                                font.family: "Arial"
                                font.pixelSize: 14
                                color: colorTextoNormal
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 35
                                color: "#F5F5F5"
                                border.color: "#E0E0E0"
                                border.width: 1
                                radius: 4
                                
                                TextInput {
                                    id: inputNombre
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    font.family: "Arial"
                                    font.pixelSize: 14
                                    text: "Luis"
                                    color: colorTextoNormal
                                }
                            }
                            
                            // Apellidos
                            Text {
                                text: "Apellidos:"
                                font.bold: true
                                font.family: "Arial"
                                font.pixelSize: 14
                                color: colorTextoNormal
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 35
                                color: "#F5F5F5"
                                border.color: "#E0E0E0"
                                border.width: 1
                                radius: 4
                                
                                TextInput {
                                    id: inputApellidos
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    font.family: "Arial"
                                    font.pixelSize: 14
                                    text: "López Pérez"
                                    color: colorTextoNormal
                                }
                            }
                            
                            // Email
                            Text {
                                text: "Email:"
                                font.bold: true
                                font.family: "Arial"
                                font.pixelSize: 14
                                color: colorTextoNormal
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 35
                                color: "#F5F5F5"
                                border.color: "#E0E0E0"
                                border.width: 1
                                radius: 4
                                
                                TextInput {
                                    id: inputEmail
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    font.family: "Arial"
                                    font.pixelSize: 14
                                    text: "luis.lopez@example.com"
                                    color: colorTextoNormal
                                }
                            }
                            
                            // Teléfono
                            Text {
                                text: "Teléfono:"
                                font.bold: true
                                font.family: "Arial"
                                font.pixelSize: 14
                                color: colorTextoNormal
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 35
                                color: "#F5F5F5"
                                border.color: "#E0E0E0"
                                border.width: 1
                                radius: 4
                                
                                TextInput {
                                    id: inputTelefono
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    font.family: "Arial"
                                    font.pixelSize: 14
                                    text: "+34 612 345 678"
                                    color: colorTextoNormal
                                }
                            }
                            
                            // Rol
                            Text {
                                text: "Rol:"
                                font.bold: true
                                font.family: "Arial"
                                font.pixelSize: 14
                                color: colorTextoNormal
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 35
                                color: "#EEEEEE"
                                border.color: "#E0E0E0"
                                border.width: 1
                                radius: 4
                                
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    font.family: "Arial"
                                    font.pixelSize: 14
                                    text: "Administrador"
                                    color: colorTextoSecundario
                                }
                            }
                        }
                        
                        // Botón de guardar
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                            Layout.topMargin: 20
                            height: 40
                            color: colorVerdeBosque
                            radius: 4
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Guardar Cambios"
                                font.bold: true
                                font.family: "Arial"
                                font.pixelSize: 14
                                color: "white"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Lógica para guardar cambios
                                    perfilPopup.currentView = "menu"
                                }
                            }
                        }
                        
                        Item {
                            height: 20
                        }
                    }
                }
            }
        }
        
        // VISTA DE CAMBIAR CONTRASEÑA
        Item {
            id: passwordView
            anchors.fill: parent
            visible: perfilPopup.currentView === "password"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Encabezado
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: colorVerdeBosque

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        
                        // Botón de regresar
                        Rectangle {
                            width: 30
                            height: 30
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "←"
                                font.pixelSize: 20
                                color: "white"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    perfilPopup.currentView = "menu"
                                }
                            }
                        }
                        
                        Text {
                            text: "Cambiar Contraseña"
                            font.bold: true
                            font.family: "Arial"
                            font.pixelSize: 16
                            color: "white"
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }

                // Contenido del formulario de cambio de contraseña
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "Por favor, introduzca su contraseña actual y la nueva contraseña."
                        font.family: "Arial"
                        font.pixelSize: 12
                        color: colorTextoSecundario
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    // Contraseña actual
                    Text {
                        text: "Contraseña actual:"
                        font.bold: true
                        font.family: "Arial"
                        font.pixelSize: 14
                        color: colorTextoNormal
                        Layout.topMargin: 10
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 35
                        color: "#F5F5F5"
                        border.color: "#E0E0E0"
                        border.width: 1
                        radius: 4
                        
                        TextInput {
                            id: inputPassActual
                            anchors.fill: parent
                            anchors.margins: 8
                            font.family: "Arial"
                            font.pixelSize: 14
                            color: colorTextoNormal
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                        }
                    }
                    
                    // Nueva contraseña
                    Text {
                        text: "Nueva contraseña:"
                        font.bold: true
                        font.family: "Arial"
                        font.pixelSize: 14
                        color: colorTextoNormal
                        Layout.topMargin: 10
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 35
                        color: "#F5F5F5"
                        border.color: "#E0E0E0"
                        border.width: 1
                        radius: 4
                        
                        TextInput {
                            id: inputPassNueva
                            anchors.fill: parent
                            anchors.margins: 8
                            font.family: "Arial"
                            font.pixelSize: 14
                            color: colorTextoNormal
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                        }
                    }
                    
                    // Confirmar nueva contraseña
                    Text {
                        text: "Confirmar nueva contraseña:"
                        font.bold: true
                        font.family: "Arial"
                        font.pixelSize: 14
                        color: colorTextoNormal
                        Layout.topMargin: 10
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 35
                        color: "#F5F5F5"
                        border.color: "#E0E0E0"
                        border.width: 1
                        radius: 4
                        
                        TextInput {
                            id: inputPassConfirm
                            anchors.fill: parent
                            anchors.margins: 8
                            font.family: "Arial"
                            font.pixelSize: 14
                            color: colorTextoNormal
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                        }
                    }
                    
                    // Mensaje de validación
                    Text {
                        id: mensajeValidacion
                        text: "Las contraseñas deben tener al menos 8 caracteres incluyendo letras y números."
                        font.family: "Arial"
                        font.pixelSize: 12
                        color: colorTextoSecundario
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    // Botón de cambiar contraseña
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        color: colorVerdeBosque
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Cambiar Contraseña"
                            font.bold: true
                            font.family: "Arial"
                            font.pixelSize: 14
                            color: "white"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Validación simple
                                if (inputPassNueva.text.length < 8) {
                                    mensajeValidacion.color = colorAlertaRoja
                                    mensajeValidacion.text = "La contraseña debe tener al menos 8 caracteres."
                                } else if (inputPassNueva.text !== inputPassConfirm.text) {
                                    mensajeValidacion.color = colorAlertaRoja
                                    mensajeValidacion.text = "Las contraseñas no coinciden."
                                } else {
                                    // Lógica para cambiar la contraseña
                                    mensajeValidacion.color = colorAlertaVerde
                                    mensajeValidacion.text = "Contraseña cambiada con éxito."
                                    
                                    // Después de un tiempo, volver al menú
                                    passwordChangeTimer.start()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Timer para volver al menú después de cambiar la contraseña
        Timer {
            id: passwordChangeTimer
            interval: 1500
            onTriggered: {
                perfilPopup.currentView = "menu"
            }
        }

        // Función para resetear la vista cuando se cierra el popup
        onClosed: {
            perfilPopup.currentView = "menu"
        }
    }
}