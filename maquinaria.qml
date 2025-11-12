import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: maquinariaRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Equipos", "icon": "recursos/image/icons/equipo.png", "color": "#2E7D32"},
        {"text": "Mantenimiento", "icon": "recursos/image/icons/mantenimientoMaq.png", "color": "#F57C00"},
        {"text": "Combustible", "icon": "recursos/image/icons/combustiblemaq.png", "color": "#0288D1"}
    ]
    
    property int paginaEquipos: 1
    property int totalPaginasEquipos: 5
    property int paginaMantenimiento: 1
    property int totalPaginasMantenimiento: 3
    property int paginaCombustible: 1
    property int totalPaginasCombustible: 4

    Connections {
        target: maquinariaModel
        
        function onComprasChanged() {
            cargarComprasCombustibleDesdeModelo()
        }
        
        function onResumenCombustibleChanged() {
            actualizarResumenCombustible()
        }
    }

    // Título
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "GESTIÓN DE EQUIPOS, COMBUSTIBLE Y MANTENIMIENTO"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Barra de pestañas - TabBarComponent
    Item {
        id: modernTabBar
        width: parent.width - 40
        height: 90
        anchors.top: titleBar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        
        TabBarComponent {
            id: tabBar
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            tabsData: maquinariaRoot.tabsInfo
            tabActiva: maquinariaRoot.tabActiva
            
            onTabChanged: function(index) {
                maquinariaRoot.tabActiva = index
                paginaEquipos = 1
                paginaMantenimiento = 1
                paginaCombustible = 1
            }
        }
    }

    // Área de contenido principal
    Item {
        id: contentArea
        width: parent.width - 40
        height: parent.height - modernTabBar.y - modernTabBar.height - 20
        anchors.top: modernTabBar.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        
        // ==================== TAB 1: EQUIPOS ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 0
            opacity: tabActiva === 0 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            Column {
                anchors.fill: parent
                spacing: 15
                
                // Barra de herramientas
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Button {
                            width: 140
                            height: 36
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: 8
                            }
                            
                            contentItem: Row {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Image {
                                    source: Qt.resolvedUrl("recursos/image/icons/agregar.svg")
                                    width: 16
                                    height: 16
                                    fillMode: Image.PreserveAspectFit
                                }
                                
                                Text {
                                    text: "Nuevo Equipo"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }
                            
                            onClicked: {
                                console.log("Nuevo equipo")
                            }
                        }
                        
                        TextField {
                            id: txtBuscarEquipo
                            width: 250
                            height: 36
                            placeholderText: "Buscar equipo..."
                        }
                        
                        ComboBox {
                            id: cmbFiltroEquipo
                            width: 200
                            height: 36
                            model: ["Todos los tipos", "Tractor", "Fumigadora", "Bomba de riego", "Pulverizadora", "Cosechadora", "Otro"]
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // ListView Equipos
                Rectangle {
                    width: parent.width
                    height: parent.height - 150
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: equiposListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            id: equiposModel
                        }
                        
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#F5F5F5"
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                
                                Text { width: parent.width * 0.11; text: "Código"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.24; text: "Nombre"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.14; text: "Tipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.14; text: "Marca"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.12; text: "Combustible"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: "Estado"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.1; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 45
                            color: index % 2 === 0 ? "#FAFAFA" : "white"
                            border.color: "#EEEEEE"
                            border.width: 1
                            
                            Row {
                                anchors.fill: parent
                                
                                Text { width: parent.width * 0.11; text: model.codigo; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.24; text: model.nombre; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.14; text: model.tipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.14; text: model.marca; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.12; text: model.tipo_combustible; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: model.estado; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                
                                Row {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 5
                                    leftPadding: 10
                                    
                                    MouseArea {
                                        width: 20
                                        height: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        Image {
                                            anchors.fill: parent
                                            source: Qt.resolvedUrl("recursos/image/icons/ojo.svg")
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        
                                        onClicked: console.log("Ver", model.id)
                                    }
                                    
                                    MouseArea {
                                        width: 20
                                        height: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        Image {
                                            anchors.fill: parent
                                            source: Qt.resolvedUrl("recursos/image/icons/editar.svg")
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        
                                        onClicked: console.log("Editar", model.id)
                                    }
                                    
                                    MouseArea {
                                        width: 20
                                        height: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        Image {
                                            anchors.fill: parent
                                            source: Qt.resolvedUrl("recursos/image/icons/basura.svg")
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        
                                        onClicked: console.log("Eliminar", model.id)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador Equipos
                Paginator {
                    id: paginadorEquipos
                    width: parent.width
                    height: 50
                    currentPage: paginaEquipos
                    totalPages: totalPaginasEquipos
                    
                    onPageChanged: {
                        paginaEquipos = newPage
                    }
                }
            }
        }
        
        // ==================== TAB 2: MANTENIMIENTO ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 1
            opacity: tabActiva === 1 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            Column {
                anchors.fill: parent
                spacing: 15
                
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Button {
                            width: 160
                            height: 36
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: 8
                            }
                            
                            contentItem: Row {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Image {
                                    source: Qt.resolvedUrl("recursos/image/icons/agregar.svg")
                                    width: 16
                                    height: 16
                                    fillMode: Image.PreserveAspectFit
                                }
                                
                                Text {
                                    text: "Nuevo Mantenimiento"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }
                            
                            onClicked: console.log("Nuevo mantenimiento")
                        }
                        
                        TextField {
                            width: 250
                            height: 36
                            placeholderText: "Buscar mantenimiento..."
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: parent.height - 150
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: mantenimientoListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            id: mantenimientoModel
                        }
                        
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#F5F5F5"
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                
                                Text { width: parent.width * 0.15; text: "Equipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.20; text: "Tipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.20; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.20; text: "Costo"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: "Descripción"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.1; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 45
                            color: index % 2 === 0 ? "#FAFAFA" : "white"
                            border.color: "#EEEEEE"
                            border.width: 1
                            
                            Row {
                                anchors.fill: parent
                                
                                Text { width: parent.width * 0.15; text: model.equipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.20; text: model.tipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.20; text: model.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.20; text: model.costo; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: model.descripcion; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                
                                Row {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 5
                                    leftPadding: 10
                                    
                                    MouseArea {
                                        width: 20
                                        height: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        Image {
                                            anchors.fill: parent
                                            source: Qt.resolvedUrl("recursos/image/icons/editar.svg")
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        
                                        onClicked: console.log("Editar", model.id)
                                    }
                                    
                                    MouseArea {
                                        width: 20
                                        height: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        Image {
                                            anchors.fill: parent
                                            source: Qt.resolvedUrl("recursos/image/icons/basura.svg")
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        
                                        onClicked: console.log("Eliminar", model.id)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Paginator {
                    id: paginadorMantenimiento
                    width: parent.width
                    height: 50
                    currentPage: paginaMantenimiento
                    totalPages: totalPaginasMantenimiento
                    
                    onPageChanged: {
                        paginaMantenimiento = newPage
                    }
                }
            }
        }
        
        // ==================== TAB 3: COMBUSTIBLE ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 2
            opacity: tabActiva === 2 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            Column {
                anchors.fill: parent
                spacing: 15
                
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Button {
                            width: 140
                            height: 36
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: 8
                            }
                            
                            contentItem: Row {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Image {
                                    source: Qt.resolvedUrl("recursos/image/icons/agregar.svg")
                                    width: 16
                                    height: 16
                                    fillMode: Image.PreserveAspectFit
                                }
                                
                                Text {
                                    text: "Nuevo Registro"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }
                            
                            onClicked: console.log("Nuevo combustible")
                        }
                        
                        TextField {
                            width: 250
                            height: 36
                            placeholderText: "Buscar combustible..."
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: parent.height - 150
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: combustibleListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            id: combustibleModel
                        }
                        
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#F5F5F5"
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                
                                Text { width: parent.width * 0.15; text: "Equipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: "Litros"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: "Costo Unit."; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: "Total"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: "Observaciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.1; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 45
                            color: index % 2 === 0 ? "#FAFAFA" : "white"
                            border.color: "#EEEEEE"
                            border.width: 1
                            
                            Row {
                                anchors.fill: parent
                                
                                Text { width: parent.width * 0.15; text: model.equipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: model.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: model.litros; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: model.costo_unitario; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: model.total; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.15; text: model.observaciones; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                
                                Row {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 5
                                    leftPadding: 10
                                    
                                    MouseArea {
                                        width: 20
                                        height: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        Image {
                                            anchors.fill: parent
                                            source: Qt.resolvedUrl("recursos/image/icons/editar.svg")
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        
                                        onClicked: console.log("Editar", model.id)
                                    }
                                    
                                    MouseArea {
                                        width: 20
                                        height: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        Image {
                                            anchors.fill: parent
                                            source: Qt.resolvedUrl("recursos/image/icons/basura.svg")
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        
                                        onClicked: console.log("Eliminar", model.id)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Paginator {
                    id: paginadorCombustible
                    width: parent.width
                    height: 50
                    currentPage: paginaCombustible
                    totalPages: totalPaginasCombustible
                    
                    onPageChanged: {
                        paginaCombustible = newPage
                    }
                }
            }
        }
    }
    
    // FUNCIONES
    function filtrarMaquinaria(filtro) {
        console.log("Filtrando:", filtro)
    }

    function cargarComprasCombustibleDesdeModelo() {
        console.log("Cargando combustible desde modelo")
    }

    function actualizarResumenCombustible() {
        console.log("Actualizando resumen combustible")
    }
}
