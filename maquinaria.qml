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
    
    // Propiedades para datos dinámicos
    property var equiposData: [
        {
            "id": 1, "codigo": "TR-001", "nombre": "Tractor John Deere", "tipo": "Tractor", 
            "marca": "John Deere", "tipo_combustible": "Diésel", "estado": "Activo"
        },
        {
            "id": 2, "codigo": "FU-001", "nombre": "Fumigadora XYZ", "tipo": "Fumigadora", 
            "marca": "XYZ Agro", "tipo_combustible": "Gasolina", "estado": "En mantenimiento"
        },
        {
            "id": 3, "codigo": "BR-001", "nombre": "Bomba de Riego", "tipo": "Bomba de riego", 
            "marca": "HidroMax", "tipo_combustible": "Eléctrico", "estado": "Activo"
        }
    ]
    
    property var mantenimientoData: [
        {
            "id": 1, "equipo": "Tractor John Deere", "tipo": "Preventivo", 
            "fecha": "15/07/2025", "costo": "450.00", "descripcion": "Cambio de aceite y filtros"
        },
        {
            "id": 2, "equipo": "Fumigadora XYZ", "tipo": "Correctivo", 
            "fecha": "10/07/2025", "costo": "320.00", "descripcion": "Reparación de bomba"
        }
    ]
    
    property var combustibleData: [
        {
            "id": 1, "equipo": "Tractor John Deere", "fecha": "12/07/2025", 
            "litros": "45.5", "costo_unitario": "3.74", "total": "170.17", "observaciones": "Tanque lleno"
        },
        {
            "id": 2, "equipo": "Fumigadora XYZ", "fecha": "14/07/2025", 
            "litros": "12.0", "costo_unitario": "3.72", "total": "44.64", "observaciones": "Medio tanque"
        }
    ]
    
    // Propiedades para filtros
    property var tiposEquipo: ["Todos los tipos", "Tractor", "Fumigadora", "Bomba de riego", "Pulverizadora", "Cosechadora", "Otro"]
    property var estadosEquipo: ["Todos", "Activo", "En mantenimiento", "Inactivo"]
    property var tiposMantenimiento: ["Todos", "Preventivo", "Correctivo", "Predictivo"]
    property var tiposCombustible: ["Todos", "Diésel", "Gasolina", "Gas"]
    
    // Propiedades para paginación
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
        height: 60
        color: "transparent"

        Text {
            text: "GESTIÓN DE EQUIPOS, COMBUSTIBLE Y MANTENIMIENTO"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.centerIn: parent
        }
    }

    // Barra de pestañas - TabBarComponent
    Item {
        id: modernTabBar
        width: parent.width - 40
        height: 70
        anchors.top: titleBar.bottom
        anchors.topMargin: 5
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
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        
        // ==================== TAB 1: EQUIPOS ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 0
            opacity: tabActiva === 0 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderEquipos
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Equipo"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#2E7D32"
                    searchPlaceholder: "Buscar equipo..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: tiposEquipo
                    filterPlaceholder: "Tipo de equipo..."
                    filterWidth: 180
                    
                    onButtonClicked: {
                        console.log("Nuevo equipo")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar equipo:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por tipo:", tiposEquipo[index])
                    }
                }
                
                // Tabla de Equipos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: equiposData
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.10; height: parent.height; text: "Código"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.18; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Marca"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Combustible"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.18; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#E8F5E9"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.codigo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.18; height: parent.height; text: modelData.nombre; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.tipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.marca; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.tipo_combustible; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.estado; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; color: modelData.estado === "Activo" ? "#2E7D32" : "#F57C00" }
                                
                                Rectangle {
                                    width: parent.width * 0.18
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: console.log("Eliminar", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador Equipos
                Item {
                    Layout.fillWidth: true
                    height: 40
                    
                    Paginator {
                        id: paginadorEquipos
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaEquipos
                        totalPages: totalPaginasEquipos
                        
                        onPageChanged: {
                            paginaEquipos = newPage
                        }
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
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                FilterHeaderComponent {
                    id: filterHeaderMantenimiento
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Mantenimiento"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#F57C00"
                    searchPlaceholder: "Buscar mantenimiento..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: tiposMantenimiento
                    filterPlaceholder: "Tipo..."
                    filterWidth: 150
                    
                    onButtonClicked: {
                        console.log("Nuevo mantenimiento")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar mantenimiento:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por tipo:", tiposMantenimiento[index])
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: mantenimientoData
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.20; height: parent.height; text: "Equipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Costo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Descripción"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#FFF3E0"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { width: parent.width * 0.20; height: parent.height; text: modelData.equipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.tipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Bs. " + modelData.costo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#F57C00" }
                                Text { width: parent.width * 0.20; height: parent.height; text: modelData.descripcion; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: console.log("Eliminar", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                    height: 40
                    
                    Paginator {
                        id: paginadorMantenimiento
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaMantenimiento
                        totalPages: totalPaginasMantenimiento
                        
                        onPageChanged: {
                            paginaMantenimiento = newPage
                        }
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
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                FilterHeaderComponent {
                    id: filterHeaderCombustible
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Registro"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#0288D1"
                    searchPlaceholder: "Buscar combustible..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: tiposCombustible
                    filterPlaceholder: "Tipo de combustible..."
                    filterWidth: 180
                    
                    onButtonClicked: {
                        console.log("Nuevo combustible")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar combustible:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por tipo:", tiposCombustible[index])
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: combustibleData
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.15; height: parent.height; text: "Equipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Litros"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.13; height: parent.height; text: "Costo Unit."; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Total"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.21; height: parent.height; text: "Observaciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#E8F4F8"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.equipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.litros; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.13; height: parent.height; text: "Bs. " + modelData.costo_unitario; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Bs. " + modelData.total; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#0288D1" }
                                Text { width: parent.width * 0.21; height: parent.height; text: modelData.observaciones; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: console.log("Eliminar", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                    height: 40
                    
                    Paginator {
                        id: paginadorCombustible
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaCombustible
                        totalPages: totalPaginasCombustible
                        
                        onPageChanged: {
                            paginaCombustible = newPage
                        }
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
