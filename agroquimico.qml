import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: agroquimicosRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Inventario", "icon": "recursos/image/icons/inventario.png", "color": "#2E7D32"},
        {"text": "Categorías", "icon": "recursos/image/icons/categorias.png", "color": "#FF6F00"},
        {"text": "Mezclas", "icon": "recursos/image/icons/mezclas.png", "color": "#1976D2"},
        {"text": "Tratamientos", "icon": "recursos/image/icons/tratamiento.png", "color": "#D32F2F"}
    ]
    
    // Propiedades para datos dinámicos
    property var inventarioData: [
        {
            "id": 1, "codigo": "AGR-001", "nombre_comercial": "Insecticida XYZ", "categoria": "Insecticidas",
            "formulacion": "Líquido", "unidad": "L", "precio": "250.00", "stock": "45", "registro": "Aprobado"
        },
        {
            "id": 2, "codigo": "AGR-002", "nombre_comercial": "Fungicida ABC", "categoria": "Fungicidas",
            "formulacion": "Polvo", "unidad": "kg", "precio": "320.00", "stock": "30", "registro": "Pendiente"
        },
        {
            "id": 3, "codigo": "AGR-003", "nombre_comercial": "Herbicida 123", "categoria": "Herbicidas",
            "formulacion": "Líquido", "unidad": "L", "precio": "180.00", "stock": "60", "registro": "Aprobado"
        }
    ]
    
    property var categoriasData: [
        {
            "id": 1, "nombre": "Insecticidas", "descripcion": "Productos para control de insectos", "activo": true
        },
        {
            "id": 2, "nombre": "Fungicidas", "descripcion": "Productos para control de hongos", "activo": true
        },
        {
            "id": 3, "nombre": "Herbicidas", "descripcion": "Productos para control de malezas", "activo": true
        }
    ]
    
    property var mezclasData: [
        {
            "id": 1, "nombre": "Mezcla Control Plagas", "objetivo": "Control de insectos", 
            "cantidadAgua": "100", "areaAplicacion": "5", "estado": "Activa"
        },
        {
            "id": 2, "nombre": "Mezcla Protección Fungal", "objetivo": "Prevención de hongos", 
            "cantidadAgua": "150", "areaAplicacion": "8", "estado": "Activa"
        }
    ]
    
    property var tratamientosData: [
        {
            "id": 1, "fecha": "15/11/2025", "ciclo": "Ciclo 1", "tipo_plaga": "Polilla", 
            "area": "10", "mezcla": "Mezcla Control Plagas", "costo": "450.00"
        },
        {
            "id": 2, "fecha": "12/11/2025", "ciclo": "Ciclo 2", "tipo_plaga": "Roya", 
            "area": "8", "mezcla": "Mezcla Protección Fungal", "costo": "380.00"
        }
    ]
    
    // Propiedades para filtros
    property var categoriasFilter: ["Todas las categorías", "Insecticidas", "Fungicidas", "Herbicidas"]
    property var registrosFilter: ["Todos", "Aprobado", "Pendiente", "Rechazado"]
    property var objetivosFilter: ["Todos los objetivos", "Control de insectos", "Prevención de hongos"]
    property var ciclosFilter: ["Todos los ciclos", "Ciclo 1", "Ciclo 2", "Ciclo 3"]
    
    // Propiedades para paginación
    property int paginaInventario: 1
    property int totalPaginasInventario: 5
    property int paginaCategorias: 1
    property int totalPaginasCategorias: 2
    property int paginaMezclas: 1
    property int totalPaginasMezclas: 3
    property int paginaTratamientos: 1
    property int totalPaginasTratamientos: 4

    Connections {
        target: agroquimicosModel
        
        function onProductosChanged() {
            cargarProductosDesdeModelo()
        }
        
        function onMezclasChanged() {
            cargarMezclasDesdeModelo()
        }
        
        function onTratamientosChanged() {
            cargarTratamientosDesdeModelo()
        }
    }

    // Título
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"

        Text {
            text: "GESTIÓN DE PRODUCTOS PARA CONTROL FITOSANITARIO"
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
            tabsData: agroquimicosRoot.tabsInfo
            tabActiva: agroquimicosRoot.tabActiva
            
            onTabChanged: function(index) {
                agroquimicosRoot.tabActiva = index
                paginaInventario = 1
                paginaCategorias = 1
                paginaMezclas = 1
                paginaTratamientos = 1
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
        
        // ==================== TAB 1: INVENTARIO ====================
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
                    id: filterHeaderInventario
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Producto"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#2E7D32"
                    searchPlaceholder: "Buscar producto..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: categoriasFilter
                    filterPlaceholder: "Categoría..."
                    filterWidth: 180
                    
                    onButtonClicked: {
                        console.log("Nuevo producto")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar producto:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por categoría:", categoriasFilter[index])
                    }
                }
                
                // Tabla de Inventario
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
                        model: inventarioData
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
                                Text { width: parent.width * 0.18; height: parent.height; text: "Nombre Comercial"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Categoría"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Formulación"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Precio"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Stock"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Registro"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                Text { width: parent.width * 0.18; height: parent.height; text: modelData.nombre_comercial; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.categoria; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.formulacion; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Bs. " + modelData.precio; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#2E7D32" }
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.stock + " " + modelData.unidad; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.registro; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.12
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
                
                // Paginador Inventario
                Item {
                    Layout.fillWidth: true
                    height: 40
                    
                    Paginator {
                        id: paginadorInventario
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaInventario
                        totalPages: totalPaginasInventario
                        
                        onPageChanged: {
                            paginaInventario = newPage
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 2: CATEGORÍAS ====================
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
                    id: filterHeaderCategorias
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nueva Categoría"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#FF6F00"
                    searchPlaceholder: "Buscar categoría..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: ["Todas", "Activas", "Inactivas"]
                    filterPlaceholder: "Estado..."
                    filterWidth: 150
                    
                    onButtonClicked: {
                        console.log("Nueva categoría")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar categoría:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar categoría")
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
                        model: categoriasData
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.20; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.50; height: parent.height; text: "Descripción"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
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
                                
                                Text { width: parent.width * 0.20; height: parent.height; text: modelData.nombre; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.50; height: parent.height; text: modelData.descripcion; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 60
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: modelData.activo ? "#E8F5E8" : "#FFEBEE"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.activo ? "Activa" : "Inactiva"
                                            font.pixelSize: 11
                                            color: modelData.activo ? "#2E7D32" : "#C62828"
                                        }
                                    }
                                }
                                
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
                        id: paginadorCategorias
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaCategorias
                        totalPages: totalPaginasCategorias
                        
                        onPageChanged: {
                            paginaCategorias = newPage
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 3: MEZCLAS ====================
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
                    id: filterHeaderMezclas
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nueva Mezcla"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#1976D2"
                    searchPlaceholder: "Buscar mezcla..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: objetivosFilter
                    filterPlaceholder: "Objetivo..."
                    filterWidth: 180
                    
                    onButtonClicked: {
                        console.log("Nueva mezcla")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar mezcla:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por objetivo:", objetivosFilter[index])
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
                        model: mezclasData
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.20; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.25; height: parent.height; text: "Objetivo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Agua (L)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Área (Ha)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.13; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#E3F2FD"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { width: parent.width * 0.20; height: parent.height; text: modelData.nombre; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.25; height: parent.height; text: modelData.objetivo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.cantidadAgua; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.areaAplicacion; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.estado; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; color: modelData.estado === "Activa" ? "#2E7D32" : "#C62828" }
                                
                                Rectangle {
                                    width: parent.width * 0.13
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
                        id: paginadorMezclas
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaMezclas
                        totalPages: totalPaginasMezclas
                        
                        onPageChanged: {
                            paginaMezclas = newPage
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 4: TRATAMIENTOS ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 3
            opacity: tabActiva === 3 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                FilterHeaderComponent {
                    id: filterHeaderTratamientos
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Tratamiento"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#D32F2F"
                    searchPlaceholder: "Buscar tratamiento..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: ciclosFilter
                    filterPlaceholder: "Ciclo..."
                    filterWidth: 180
                    
                    onButtonClicked: {
                        console.log("Nuevo tratamiento")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar tratamiento:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por ciclo:", ciclosFilter[index])
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
                        model: tratamientosData
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.12; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Ciclo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Tipo de Plaga"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Área (Ha)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.16; height: parent.height; text: "Mezcla"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Costo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.24; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#FFEBEE"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.ciclo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.14; height: parent.height; text: modelData.tipo_plaga; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.area; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.16; height: parent.height; text: modelData.mezcla; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Bs. " + modelData.costo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#D32F2F" }
                                
                                Rectangle {
                                    width: parent.width * 0.24
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
                        id: paginadorTratamientos
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaTratamientos
                        totalPages: totalPaginasTratamientos
                        
                        onPageChanged: {
                            paginaTratamientos = newPage
                        }
                    }
                }
            }
        }
    }
    
    // FUNCIONES
    function cargarProductosDesdeModelo() {
        console.log("Cargando productos desde modelo")
    }

    function cargarMezclasDesdeModelo() {
        console.log("Cargando mezclas desde modelo")
    }

    function cargarTratamientosDesdeModelo() {
        console.log("Cargando tratamientos desde modelo")
    }
}
