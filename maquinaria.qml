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
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderEquipos
                    Layout.fillWidth: true
                    height: 60
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
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 1
                        spacing: 0
                        
                        // Header de la tabla
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            color: "#F5F5F5"
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                
                                Text { width: parent.width * 0.11; height: parent.height; text: "Código"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.24; height: parent.height; text: "Nombre"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Tipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Marca"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Combustible"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Estado"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 13 }
                            }
                        }
                        
                        // Lista de equipos
                        ListView {
                            id: equiposListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: equiposData
                            
                            delegate: Rectangle {
                                width: equiposListView.width
                                height: 45
                                color: index % 2 === 0 ? "#FAFAFA" : "white"
                                border.color: "#EEEEEE"
                                border.width: 1
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    
                                    Text { width: parent.width * 0.11; height: parent.height; text: modelData.codigo; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.24; height: parent.height; text: modelData.nombre; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.14; height: parent.height; text: modelData.tipo; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.14; height: parent.height; text: modelData.marca; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.tipo_combustible; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.estado; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    
                                    Row {
                                        width: parent.width * 0.1
                                        height: parent.height
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 5
                                        
                                        Button {
                                            width: 28; height: 28
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/ojo.svg"
                                                width: 14
                                                height: 14
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Ver detalles"
                                            onClicked: console.log("Ver", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 28; height: 28
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 14
                                                height: 14
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 28; height: 28
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 14
                                                height: 14
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
                
                // Paginador Equipos - CENTRADO
                Item {
                    Layout.fillWidth: true
                    height: 50
                    
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
                spacing: 15
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderMantenimiento
                    Layout.fillWidth: true
                    height: 60
                    buttonText: "Nuevo Mantenimiento"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#F57C00"
                    searchPlaceholder: "Buscar mantenimiento..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: tiposMantenimiento
                    filterPlaceholder: "Tipo de mantenimiento..."
                    filterWidth: 200
                    
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
                
                // Tabla de Mantenimiento
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 1
                        spacing: 0
                        
                        // Header de la tabla
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            color: "#F5F5F5"
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                
                                Text { width: parent.width * 0.15; height: parent.height; text: "Equipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Tipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Costo"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Descripción"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 13 }
                            }
                        }
                        
                        // Lista de mantenimientos
                        ListView {
                            id: mantenimientoListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: mantenimientoData
                            
                            delegate: Rectangle {
                                width: mantenimientoListView.width
                                height: 45
                                color: index % 2 === 0 ? "#FAFAFA" : "white"
                                border.color: "#EEEEEE"
                                border.width: 1
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.equipo; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.20; height: parent.height; text: modelData.tipo; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.20; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.20; height: parent.height; text: "Bs. " + modelData.costo; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.descripcion; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    
                                    Row {
                                        width: parent.width * 0.1
                                        height: parent.height
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 5
                                        
                                        Button {
                                            width: 28; height: 28
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 14
                                                height: 14
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 28; height: 28
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 14
                                                height: 14
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
                
                // Paginador Mantenimiento - CENTRADO
                Item {
                    Layout.fillWidth: true
                    height: 50
                    
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
                spacing: 15
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderCombustible
                    Layout.fillWidth: true
                    height: 60
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
                
                // Tabla de Combustible
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 1
                        spacing: 0
                        
                        // Header de la tabla
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            color: "#F5F5F5"
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                
                                Text { width: parent.width * 0.15; height: parent.height; text: "Equipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Litros"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Costo Unit."; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Total"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Observaciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; font.pixelSize: 13 }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 13 }
                            }
                        }
                        
                        // Lista de combustible
                        ListView {
                            id: combustibleListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: combustibleData
                            
                            delegate: Rectangle {
                                width: combustibleListView.width
                                height: 45
                                color: index % 2 === 0 ? "#FAFAFA" : "white"
                                border.color: "#EEEEEE"
                                border.width: 1
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.equipo; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.litros; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: "Bs. " + modelData.costo_unitario; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: "Bs. " + modelData.total; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.observaciones; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12; elide: Text.ElideRight }
                                    
                                    Row {
                                        width: parent.width * 0.1
                                        height: parent.height
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 5
                                        
                                        Button {
                                            width: 28; height: 28
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 14
                                                height: 14
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 28; height: 28
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 14
                                                height: 14
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
                
                // Paginador Combustible - CENTRADO
                Item {
                    Layout.fillWidth: true
                    height: 50
                    
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