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
    
    property var inventarioData: []
    property var categoriasData: []
    property var mezclasData: []
    property var tratamientosData: []
    
    property var categoriasFilter: []
    property var registrosFilter: ["Todos", "Aprobado", "Pendiente", "Rechazado"]
    property var objetivosFilter: []
    property var ciclosFilter: []
    
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
        
        function onCategoriasChanged() {
            cargarCategoriasDesdeModelo()
        }
        
        function onMezclasChanged() {
            cargarMezclasDesdeModelo()
        }
        
        function onTratamientosChanged() {
            cargarTratamientosDesdeModelo()
        }
    }

    Component.onCompleted: {
        cargarTodosLosDatos()
    }

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
                        dialogoNuevoProducto.open()
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar producto:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por categoría:", categoriasFilter[index])
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
                                Text { width: parent.width * 0.08; height: parent.height; text: "Código"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Categoría"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Formulación"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.08; height: parent.height; text: "Precio"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.08; height: parent.height; text: "Stock"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Registro"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.19; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { width: parent.width * 0.08; height: parent.height; text: modelData.codigo || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.nombre_comercial || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.categoria || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.formulacion || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.08; height: parent.height; text: "Bs. " + (modelData.precio || "0"); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#2E7D32" }
                                Text { width: parent.width * 0.08; height: parent.height; text: modelData.stock || "0"; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; color: modelData.stock < 10 ? "#D32F2F" : "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.registro || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.19
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
                                            onClicked: {
                                                editarProductoActual = modelData
                                                dialogoEditarProducto.open()
                                            }
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
                                            onClicked: {
                                                agroquimicosModel.eliminar_producto(modelData.id)
                                                cargarProductosDesdeModelo()
                                            }
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
                        dialogoNuevaCategoria.open()
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar categoría:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar categorías:", index)
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
                                Text { width: parent.width * 0.15; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.50; height: parent.height; text: "Descripción"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.nombre || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true }
                                Text { width: parent.width * 0.50; height: parent.height; text: modelData.descripcion || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.activo ? "✓ Activa" : "✗ Inactiva"
                                        font.pixelSize: 12
                                        color: modelData.activo ? "#2E7D32" : "#D32F2F"
                                        font.bold: true
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.20
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
                                            onClicked: {
                                                editarCategoriaActual = modelData
                                                dialogoEditarCategoria.open()
                                            }
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
                                            onClicked: {
                                                agroquimicosModel.eliminar_categoria(modelData.id)
                                                cargarCategoriasDesdeModelo()
                                            }
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
                    filterOptions: ["Todas", "Activas", "Inactivas"]
                    filterPlaceholder: "Estado..."
                    filterWidth: 150
                    
                    onButtonClicked: {
                        dialogoNuevaMezcla.open()
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar mezcla:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar mezclas:", index)
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
                                Text { width: parent.width * 0.15; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Objetivo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Agua (L)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Área (Ha)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.21; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.nombre || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true }
                                Text { width: parent.width * 0.20; height: parent.height; text: modelData.objetivo || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.cantidadAgua || "0"; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.areaAplicacion || "0"; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.estado || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; color: modelData.estado === "Activa" ? "#2E7D32" : "#D32F2F" }
                                
                                Rectangle {
                                    width: parent.width * 0.21
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
                                            onClicked: {
                                                editarMezclaActual = modelData
                                                dialogoEditarMezcla.open()
                                            }
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
                                            onClicked: {
                                                agroquimicosModel.eliminar_mezcla(modelData.id)
                                                cargarMezclasDesdeModelo()
                                            }
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
                        dialogoNuevoTratamiento.open()
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
                                Text { width: parent.width * 0.24; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.fecha || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.ciclo || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.14; height: parent.height; text: modelData.tipo_plaga || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.10; height: parent.height; text: modelData.area || "0"; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.16; height: parent.height; text: modelData.mezcla || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Bs. " + (modelData.costo || "0"); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#D32F2F" }
                                
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
                                            onClicked: {
                                                editarTratamientoActual = modelData
                                                dialogoEditarTratamiento.open()
                                            }
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
                                            onClicked: {
                                                agroquimicosModel.eliminar_tratamiento(modelData.id)
                                                cargarTratamientosDesdeModelo()
                                            }
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
    
    // VARIABLES DE CONTROL
    property var editarProductoActual: ({})
    property var editarCategoriaActual: ({})
    property var editarMezclaActual: ({})
    property var editarTratamientoActual: ({})
    
    // DIÁLOGOS
    Dialog {
        id: dialogoNuevoProducto
        title: "Nuevo Producto"
        width: 600
        height: 500
        
        contentItem: ColumnLayout {
            spacing: 15
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputCodigoProducto
                    placeholderText: "Código (ej: AGR-001)"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputNombreProducto
                    placeholderText: "Nombre comercial"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                ComboBox {
                    id: comboCategoriaProducto
                    model: categoriasData.map(c => c.nombre)
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputFormulacion
                    placeholderText: "Formulación (Líquido, Polvo, etc)"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputPrecioProducto
                    placeholderText: "Precio"
                    Layout.preferredWidth: parent.width * 0.48
                }
                TextField {
                    id: inputStockProducto
                    placeholderText: "Stock"
                    Layout.preferredWidth: parent.width * 0.48
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                ComboBox {
                    id: comboRegistroProducto
                    model: ["Aprobado", "Pendiente", "Rechazado"]
                    Layout.fillWidth: true
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Guardar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: {
                        var producto = {
                            "codigo": inputCodigoProducto.text,
                            "nombre_comercial": inputNombreProducto.text,
                            "categoria": comboCategoriaProducto.currentText,
                            "formulacion": inputFormulacion.text,
                            "precio": inputPrecioProducto.text,
                            "stock": inputStockProducto.text,
                            "registro": comboRegistroProducto.currentText,
                            "unidad": "L"
                        }
                        
                        agroquimicosModel.agregar_producto(JSON.stringify(producto))
                        dialogoNuevoProducto.close()
                    }
                }
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: dialogoNuevoProducto.close()
                }
            }
        }
    }
    
    Dialog {
        id: dialogoEditarProducto
        title: "Editar Producto"
        width: 600
        height: 500
        
        contentItem: ColumnLayout {
            spacing: 15
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputCodigoProductoEdit
                    text: editarProductoActual.codigo || ""
                    placeholderText: "Código"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputNombreProductoEdit
                    text: editarProductoActual.nombre_comercial || ""
                    placeholderText: "Nombre comercial"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                ComboBox {
                    id: comboCategoriaProductoEdit
                    model: categoriasData.map(c => c.nombre)
                    currentIndex: categoriasData.findIndex(c => c.nombre === editarProductoActual.categoria)
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputFormulacionEdit
                    text: editarProductoActual.formulacion || ""
                    placeholderText: "Formulación"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputPrecioProductoEdit
                    text: editarProductoActual.precio || ""
                    placeholderText: "Precio"
                    Layout.preferredWidth: parent.width * 0.48
                }
                TextField {
                    id: inputStockProductoEdit
                    text: editarProductoActual.stock || ""
                    placeholderText: "Stock"
                    Layout.preferredWidth: parent.width * 0.48
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                ComboBox {
                    id: comboRegistroProductoEdit
                    model: ["Aprobado", "Pendiente", "Rechazado"]
                    currentIndex: model.indexOf(editarProductoActual.registro || "Aprobado")
                    Layout.fillWidth: true
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Actualizar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: {
                        var producto = {
                            "codigo": inputCodigoProductoEdit.text,
                            "nombre_comercial": inputNombreProductoEdit.text,
                            "categoria": comboCategoriaProductoEdit.currentText,
                            "formulacion": inputFormulacionEdit.text,
                            "precio": inputPrecioProductoEdit.text,
                            "stock": inputStockProductoEdit.text,
                            "registro": comboRegistroProductoEdit.currentText,
                            "unidad": "L"
                        }
                        
                        agroquimicosModel.actualizar_producto(editarProductoActual.id, JSON.stringify(producto))
                        dialogoEditarProducto.close()
                    }
                }
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: dialogoEditarProducto.close()
                }
            }
        }
    }
    
    Dialog {
        id: dialogoNuevaCategoria
        title: "Nueva Categoría"
        width: 500
        height: 300
        
        contentItem: ColumnLayout {
            spacing: 15
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputNombreCategoria
                    placeholderText: "Nombre de categoría"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextArea {
                    id: inputDescripcionCategoria
                    placeholderText: "Descripción"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Guardar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: {
                        var categoria = {
                            "nombre": inputNombreCategoria.text,
                            "descripcion": inputDescripcionCategoria.text,
                            "activo": true
                        }
                        
                        agroquimicosModel.agregar_categoria(JSON.stringify(categoria))
                        dialogoNuevaCategoria.close()
                    }
                }
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: dialogoNuevaCategoria.close()
                }
            }
        }
    }
    
    Dialog {
        id: dialogoEditarCategoria
        title: "Editar Categoría"
        width: 500
        height: 300
        
        contentItem: ColumnLayout {
            spacing: 15
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputNombreCategoriaEdit
                    text: editarCategoriaActual.nombre || ""
                    placeholderText: "Nombre"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextArea {
                    id: inputDescripcionCategoriaEdit
                    text: editarCategoriaActual.descripcion || ""
                    placeholderText: "Descripción"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Actualizar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: {
                        var categoria = {
                            "nombre": inputNombreCategoriaEdit.text,
                            "descripcion": inputDescripcionCategoriaEdit.text,
                            "activo": editarCategoriaActual.activo || true
                        }
                        
                        agroquimicosModel.actualizar_categoria(editarCategoriaActual.id, JSON.stringify(categoria))
                        dialogoEditarCategoria.close()
                    }
                }
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: dialogoEditarCategoria.close()
                }
            }
        }
    }
    
    Dialog {
        id: dialogoNuevaMezcla
        title: "Nueva Mezcla"
        width: 550
        height: 400
        
        contentItem: ColumnLayout {
            spacing: 15
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputNombreMezcla
                    placeholderText: "Nombre de mezcla"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputObjetivoMezcla
                    placeholderText: "Objetivo (Control de insectos, etc)"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputAguaMezcla
                    placeholderText: "Cantidad de agua (L)"
                    Layout.preferredWidth: parent.width * 0.48
                }
                TextField {
                    id: inputAreaMezcla
                    placeholderText: "Área de aplicación (Ha)"
                    Layout.preferredWidth: parent.width * 0.48
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Guardar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: {
                        var mezcla = {
                            "nombre": inputNombreMezcla.text,
                            "objetivo": inputObjetivoMezcla.text,
                            "cantidadAgua": inputAguaMezcla.text,
                            "areaAplicacion": inputAreaMezcla.text,
                            "estado": "Activa"
                        }
                        
                        agroquimicosModel.agregar_mezcla(JSON.stringify(mezcla))
                        dialogoNuevaMezcla.close()
                    }
                }
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: dialogoNuevaMezcla.close()
                }
            }
        }
    }
    
    Dialog {
        id: dialogoEditarMezcla
        title: "Editar Mezcla"
        width: 550
        height: 400
        
        contentItem: ColumnLayout {
            spacing: 15
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputNombreMezclaEdit
                    text: editarMezclaActual.nombre || ""
                    placeholderText: "Nombre"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputObjetivoMezclaEdit
                    text: editarMezclaActual.objetivo || ""
                    placeholderText: "Objetivo"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputAguaMezclaEdit
                    text: editarMezclaActual.cantidadAgua || ""
                    placeholderText: "Cantidad agua"
                    Layout.preferredWidth: parent.width * 0.48
                }
                TextField {
                    id: inputAreaMezclaEdit
                    text: editarMezclaActual.areaAplicacion || ""
                    placeholderText: "Área"
                    Layout.preferredWidth: parent.width * 0.48
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Actualizar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: {
                        var mezcla = {
                            "nombre": inputNombreMezclaEdit.text,
                            "objetivo": inputObjetivoMezclaEdit.text,
                            "cantidadAgua": inputAguaMezclaEdit.text,
                            "areaAplicacion": inputAreaMezclaEdit.text,
                            "estado": editarMezclaActual.estado || "Activa"
                        }
                        
                        agroquimicosModel.actualizar_mezcla(editarMezclaActual.id, JSON.stringify(mezcla))
                        dialogoEditarMezcla.close()
                    }
                }
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: dialogoEditarMezcla.close()
                }
            }
        }
    }
    
    Dialog {
        id: dialogoNuevoTratamiento
        title: "Nuevo Tratamiento"
        width: 600
        height: 450
        
        contentItem: ColumnLayout {
            spacing: 15
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputFechaTratamiento
                    placeholderText: "Fecha (DD/MM/YYYY)"
                    Layout.preferredWidth: parent.width * 0.45
                }
                ComboBox {
                    id: comboCicloTratamiento
                    model: ciclosFilter
                    Layout.preferredWidth: parent.width * 0.45
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputPlagaTratamiento
                    placeholderText: "Tipo de plaga"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputAreaTratamiento
                    placeholderText: "Área (Ha)"
                    Layout.preferredWidth: parent.width * 0.45
                }
                ComboBox {
                    id: comboMezclaTratamiento
                    model: mezclasData.map(m => m.nombre)
                    Layout.preferredWidth: parent.width * 0.45
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputCostoTratamiento
                    placeholderText: "Costo (Bs.)"
                    Layout.fillWidth: true
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Guardar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: {
                        var tratamiento = {
                            "fecha": inputFechaTratamiento.text,
                            "ciclo": comboCicloTratamiento.currentText,
                            "tipo_plaga": inputPlagaTratamiento.text,
                            "area": inputAreaTratamiento.text,
                            "mezcla": comboMezclaTratamiento.currentText,
                            "costo": inputCostoTratamiento.text
                        }
                        
                        agroquimicosModel.agregar_tratamiento(JSON.stringify(tratamiento))
                        dialogoNuevoTratamiento.close()
                    }
                }
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: dialogoNuevoTratamiento.close()
                }
            }
        }
    }
    
    Dialog {
        id: dialogoEditarTratamiento
        title: "Editar Tratamiento"
        width: 600
        height: 450
        
        contentItem: ColumnLayout {
            spacing: 15
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputFechaTratamientoEdit
                    text: editarTratamientoActual.fecha || ""
                    placeholderText: "Fecha"
                    Layout.preferredWidth: parent.width * 0.45
                }
                ComboBox {
                    id: comboCicloTratamientoEdit
                    model: ciclosFilter
                    currentIndex: ciclosFilter.indexOf(editarTratamientoActual.ciclo || "")
                    Layout.preferredWidth: parent.width * 0.45
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputPlagaTratamientoEdit
                    text: editarTratamientoActual.tipo_plaga || ""
                    placeholderText: "Tipo de plaga"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputAreaTratamientoEdit
                    text: editarTratamientoActual.area || ""
                    placeholderText: "Área"
                    Layout.preferredWidth: parent.width * 0.45
                }
                ComboBox {
                    id: comboMezclaTratamientoEdit
                    model: mezclasData.map(m => m.nombre)
                    currentIndex: mezclasData.findIndex(m => m.nombre === editarTratamientoActual.mezcla)
                    Layout.preferredWidth: parent.width * 0.45
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: inputCostoTratamientoEdit
                    text: editarTratamientoActual.costo || ""
                    placeholderText: "Costo"
                    Layout.fillWidth: true
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Actualizar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: {
                        var tratamiento = {
                            "fecha": inputFechaTratamientoEdit.text,
                            "ciclo": comboCicloTratamientoEdit.currentText,
                            "tipo_plaga": inputPlagaTratamientoEdit.text,
                            "area": inputAreaTratamientoEdit.text,
                            "mezcla": comboMezclaTratamientoEdit.currentText,
                            "costo": inputCostoTratamientoEdit.text
                        }
                        
                        agroquimicosModel.actualizar_tratamiento(editarTratamientoActual.id, JSON.stringify(tratamiento))
                        dialogoEditarTratamiento.close()
                    }
                }
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: parent.width * 0.45
                    onClicked: dialogoEditarTratamiento.close()
                }
            }
        }
    }
    
    // FUNCIONES
    function cargarTodosLosDatos() {
        agroquimicosModel.cargar_productos()
        agroquimicosModel.cargar_categorias()
        agroquimicosModel.cargar_mezclas()
        agroquimicosModel.cargar_tratamientos()
    }

    function cargarProductosDesdeModelo() {
        inventarioData = agroquimicosModel.productos
        console.log("Productos cargados:", inventarioData.length)
    }
    
    function cargarCategoriasDesdeModelo() {
        categoriasData = agroquimicosModel.categorias
        categoriasFilter = ["Todas las categorías"].concat(categoriasData.map(c => c.nombre))
        console.log("Categorías cargadas:", categoriasData.length)
    }

    function cargarMezclasDesdeModelo() {
        mezclasData = agroquimicosModel.mezclas
        console.log("Mezclas cargadas:", mezclasData.length)
    }

    function cargarTratamientosDesdeModelo() {
        tratamientosData = agroquimicosModel.tratamientos
        ciclosFilter = ["Todos los ciclos"].concat([...new Set(tratamientosData.map(t => t.ciclo))])
        console.log("Tratamientos cargados:", tratamientosData.length)
    }
}