import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

import "./components"

Rectangle {
    id: agroquimicosRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // ==================== PROPIEDADES ====================
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Inventario", "icon": "recursos/image/icons/inventario.png", "color": "#2E7D32"},
        {"text": "Categorías", "icon": "recursos/image/icons/categorias.png", "color": "#FF6F00"},
        {"text": "Mezclas", "icon": "recursos/image/icons/mezclas.png", "color": "#1976D2"},
        {"text": "Tratamientos", "icon": "recursos/image/icons/tratamiento.png", "color": "#D32F2F"}
    ]
    
    // Datos de las listas (desde el modelo)
    property var inventarioData: []
    property var categoriasData: []
    property var mezclasData: []
    property var tratamientosData: []
    
    // Datos filtrados para las búsquedas
    property var inventarioFiltrado: []
    property var categoriasFiltrado: []
    property var mezclasFiltrado: []
    property var tratamientosFiltrado: []
    
    // Opciones de filtros
    property var categoriasFilter: ["Todas las categorías"]
    property var estadosFiltro: ["Todos", "Activos", "Inactivos"]
    
    // Elementos para edición
    property var editarProductoActual: ({})
    property var editarCategoriaActual: ({})
    property var editarMezclaActual: ({})
    property var editarTratamientoActual: ({})
    
    // ==================== CONEXIONES CON EL MODELO ====================
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

    // ==================== INTERFAZ PRINCIPAL ====================
    
    // Barra de título
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

    // Barra de pestañas
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
            }
        }
    }

    // Área de contenido
    Item {
        id: contentArea
        width: parent.width - 40
        height: parent.height - modernTabBar.y - modernTabBar.height - 20
        anchors.top: modernTabBar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        
        // ==================== TAB 1: INVENTARIO DE PRODUCTOS ====================
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
                
                // Encabezado con búsqueda y filtros
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
                    filterWidth: 200
                    
                    onButtonClicked: {
                        limpiarFormularioProducto()
                        dialogoNuevoProducto.open()
                    }
                    
                    onSearchTextChanged: function(text) {
                        filtrarProductos(text, -1)
                    }
                    
                    onFilterChanged: function(index) {
                        var searchText = filterHeaderInventario.searchText
                        filtrarProductos(searchText, index)
                    }
                }
                
                // Lista de productos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: listaProductos
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: inventarioFiltrado
                        spacing: 2
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.08; height: parent.height; text: "ID"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Nombre Comercial"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Categoría"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Formulación"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.08; height: parent.height; text: "Unidad"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Precio"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.17; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 55
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
                                
                                Text { 
                                    width: parent.width * 0.08; height: parent.height
                                    text: modelData.id_producto || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12; font.bold: true
                                    color: "#2E7D32"
                                }
                                Text { 
                                    width: parent.width * 0.20; height: parent.height
                                    text: modelData.nombre_comercial || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12; font.bold: true
                                }
                                Text { 
                                    width: parent.width * 0.15; height: parent.height
                                    text: modelData.categoria || "Sin categoría"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12
                                    color: "#616161"
                                }
                                Text { 
                                    width: parent.width * 0.12; height: parent.height
                                    text: modelData.formulacion || "N/A"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 11
                                }
                                Text { 
                                    width: parent.width * 0.08; height: parent.height
                                    text: modelData.unidad || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12
                                }
                                Text { 
                                    width: parent.width * 0.10; height: parent.height
                                    text: "Bs. " + (modelData.precio ? parseFloat(modelData.precio).toFixed(2) : "0.00")
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12; font.bold: true
                                    color: "#2E7D32"
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.17
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 8
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#1976D2" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar producto"
                                            onClicked: {
                                                editarProductoActual = modelData
                                                cargarDatosEdicionProducto()
                                                dialogoEditarProducto.open()
                                            }
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#D32F2F" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar producto"
                                            onClicked: {
                                                editarProductoActual = modelData
                                                dialogoEliminarProducto.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Mensaje cuando no hay datos
                    Text {
                        anchors.centerIn: parent
                        text: "No hay productos registrados"
                        font.pixelSize: 16
                        color: "#9E9E9E"
                        visible: inventarioFiltrado.length === 0
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
                    filterOptions: estadosFiltro
                    filterPlaceholder: "Estado..."
                    filterWidth: 150
                    
                    onButtonClicked: {
                        limpiarFormularioCategoria()
                        dialogoNuevaCategoria.open()
                    }
                    
                    onSearchTextChanged: function(text) {
                        filtrarCategorias(text, -1)
                    }
                    
                    onFilterChanged: function(index) {
                        var searchText = filterHeaderCategorias.searchText
                        filtrarCategorias(searchText, index)
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
                        id: listaCategorias
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: categoriasFiltrado
                        spacing: 2
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.10; height: parent.height; text: "ID"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.25; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.35; height: parent.height; text: "Descripción"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 55
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
                                
                                Text { 
                                    width: parent.width * 0.10; height: parent.height
                                    text: modelData.id_categoria || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12; font.bold: true
                                    color: "#FF6F00"
                                }
                                Text { 
                                    width: parent.width * 0.25; height: parent.height
                                    text: modelData.nombre || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12; font.bold: true
                                }
                                Text { 
                                    width: parent.width * 0.35; height: parent.height
                                    text: modelData.descripcion || "Sin descripción"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 11
                                    color: "#616161"
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 70; height: 24
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        radius: 12
                                        color: modelData.activo ? "#E8F5E9" : "#FFEBEE"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.activo ? "Activo" : "Inactivo"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: modelData.activo ? "#2E7D32" : "#D32F2F"
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.20
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 8
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#1976D2" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar categoría"
                                            onClicked: {
                                                editarCategoriaActual = modelData
                                                cargarDatosEdicionCategoria()
                                                dialogoEditarCategoria.open()
                                            }
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#D32F2F" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar categoría"
                                            onClicked: {
                                                editarCategoriaActual = modelData
                                                dialogoEliminarCategoria.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "No hay categorías registradas"
                        font.pixelSize: 16
                        color: "#9E9E9E"
                        visible: categoriasFiltrado.length === 0
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
                    filterOptions: estadosFiltro
                    filterPlaceholder: "Estado..."
                    filterWidth: 150
                    
                    onButtonClicked: {
                        limpiarFormularioMezcla()
                        dialogoNuevaMezcla.open()
                    }
                    
                    onSearchTextChanged: function(text) {
                        filtrarMezclas(text, -1)
                    }
                    
                    onFilterChanged: function(index) {
                        var searchText = filterHeaderMezclas.searchText
                        filtrarMezclas(searchText, index)
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
                        id: listaMezclas
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: mezclasFiltrado
                        spacing: 2
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.08; height: parent.height; text: "ID"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.22; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Objetivo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Agua (L)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Área (Ha)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 55
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
                                
                                Text { 
                                    width: parent.width * 0.08; height: parent.height
                                    text: modelData.id_mezcla || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12; font.bold: true
                                    color: "#1976D2"
                                }
                                Text { 
                                    width: parent.width * 0.22; height: parent.height
                                    text: modelData.nombre || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12; font.bold: true
                                }
                                Text { 
                                    width: parent.width * 0.20; height: parent.height
                                    text: modelData.objetivo || "Sin objetivo"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 11
                                    color: "#616161"
                                }
                                Text { 
                                    width: parent.width * 0.10; height: parent.height
                                    text: modelData.cantidad_agua ? parseFloat(modelData.cantidad_agua).toFixed(1) : "0"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12
                                }
                                Text { 
                                    width: parent.width * 0.10; height: parent.height
                                    text: modelData.area_aplicacion ? parseFloat(modelData.area_aplicacion).toFixed(2) : "0"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 70; height: 24
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        radius: 12
                                        color: modelData.activo ? "#E8F5E9" : "#FFEBEE"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.activo ? "Activa" : "Inactiva"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: modelData.activo ? "#2E7D32" : "#D32F2F"
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.20
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 8
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFF9C4" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#F57F17" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Ver detalles"
                                            onClicked: {
                                                editarMezclaActual = modelData
                                                dialogoDetallesMezcla.open()
                                            }
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#1976D2" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar mezcla"
                                            onClicked: {
                                                editarMezclaActual = modelData
                                                cargarDatosEdicionMezcla()
                                                dialogoEditarMezcla.open()
                                            }
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#D32F2F" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar mezcla"
                                            onClicked: {
                                                editarMezclaActual = modelData
                                                dialogoEliminarMezcla.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "No hay mezclas registradas"
                        font.pixelSize: 16
                        color: "#9E9E9E"
                        visible: mezclasFiltrado.length === 0
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
                    filterOptions: ["Todos", "Últimos 30 días", "Últimos 60 días"]
                    filterPlaceholder: "Período..."
                    filterWidth: 170
                    
                    onButtonClicked: {
                        limpiarFormularioTratamiento()
                        dialogoNuevoTratamiento.open()
                    }
                    
                    onSearchTextChanged: function(text) {
                        filtrarTratamientos(text, -1)
                    }
                    
                    onFilterChanged: function(index) {
                        var searchText = filterHeaderTratamientos.searchText
                        filtrarTratamientos(searchText, index)
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
                        id: listaTratamientos
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: tratamientosFiltrado
                        spacing: 2
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.08; height: parent.height; text: "ID"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Parcela"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Tipo Plaga"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Mezcla"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Área (Ha)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.25; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 55
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
                                
                                Text { 
                                    width: parent.width * 0.08; height: parent.height
                                    text: modelData.id_tratamiento || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12; font.bold: true
                                    color: "#D32F2F"
                                }
                                Text { 
                                    width: parent.width * 0.12; height: parent.height
                                    text: modelData.fecha_aplicacion || ""
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 11
                                }
                                Text { 
                                    width: parent.width * 0.15; height: parent.height
                                    text: modelData.nombre_parcela || "Sin parcela"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 11
                                    font.bold: true
                                }
                                Text { 
                                    width: parent.width * 0.15; height: parent.height
                                    text: modelData.nombre_plaga || "Sin especificar"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 11
                                    color: "#616161"
                                }
                                Text { 
                                    width: parent.width * 0.15; height: parent.height
                                    text: modelData.nombre_mezcla || "Sin mezcla"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 11
                                    color: "#616161"
                                }
                                Text { 
                                    width: parent.width * 0.10; height: parent.height
                                    text: modelData.area_tratada ? parseFloat(modelData.area_tratada).toFixed(2) : "0"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 10
                                    elide: Text.ElideRight; font.pixelSize: 12
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 8
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFF9C4" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#F57F17" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Ver detalles"
                                            onClicked: {
                                                editarTratamientoActual = modelData
                                                dialogoDetallesTratamiento.open()
                                            }
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#1976D2" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar tratamiento"
                                            onClicked: {
                                                editarTratamientoActual = modelData
                                                cargarDatosEdicionTratamiento()
                                                dialogoEditarTratamiento.open()
                                            }
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 6
                                                border.color: parent.hovered ? "#D32F2F" : "transparent"
                                                border.width: 1
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 18; height: 18
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar tratamiento"
                                            onClicked: {
                                                editarTratamientoActual = modelData
                                                dialogoEliminarTratamiento.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "No hay tratamientos registrados"
                        font.pixelSize: 16
                        color: "#9E9E9E"
                        visible: tratamientosFiltrado.length === 0
                    }
                }
            }
        }
    }
    
    // ==================== DIÁLOGOS - PRODUCTOS ====================
    
    // Diálogo Nuevo Producto
    Dialog {
        id: dialogoNuevoProducto
        title: "Nuevo Producto Agroquímico"
        modal: true
        anchors.centerIn: parent
        width: 600
        height: 500
        
        contentItem: ScrollView {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                width: parent.width - 20
                spacing: 15
                
                Text {
                    text: "Información del Producto"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                    Layout.bottomMargin: 10
                }
                
                // Nombre comercial
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Nombre Comercial *"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextField {
                        id: inputNombreProducto
                        Layout.fillWidth: true
                        placeholderText: "Ej: Glifosato 48%"
                        font.pixelSize: 13
                    }
                }
                
                // Categoría
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Categoría *"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    ComboBox {
                        id: comboCategoriaProducto
                        Layout.fillWidth: true
                        model: categoriasData.map(c => c.nombre)
                        font.pixelSize: 13
                    }
                }
                
                // Formulación y Unidad
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Formulación"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputFormulacionProducto
                            Layout.fillWidth: true
                            placeholderText: "Ej: Líquido concentrado"
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Unidad *"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        ComboBox {
                            id: comboUnidadProducto
                            Layout.fillWidth: true
                            model: ["litros", "kg", "gramos", "ml", "unidades", "galones"]
                            font.pixelSize: 13
                        }
                    }
                }
                
                // Precio y Registro
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Precio (Bs.)"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputPrecioProducto
                            Layout.fillWidth: true
                            placeholderText: "0.00"
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Nº Registro"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputRegistroProducto
                            Layout.fillWidth: true
                            placeholderText: "Ej: SAN-12345"
                            font.pixelSize: 13
                        }
                    }
                }
                
                // Notas
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Notas Adicionales"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextArea {
                        id: inputNotasProducto
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        placeholderText: "Información adicional sobre el producto..."
                        font.pixelSize: 12
                        wrapMode: TextArea.Wrap
                    }
                }
                
                // Botones
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "Cancelar"
                        Layout.preferredWidth: 120
                        onClicked: dialogoNuevoProducto.close()
                    }
                    
                    Button {
                        text: "Guardar"
                        Layout.preferredWidth: 120
                        highlighted: true
                        enabled: inputNombreProducto.text.trim() !== "" && 
                                comboCategoriaProducto.currentIndex >= 0
                        onClicked: {
                            if (validarFormularioProducto()) {
                                guardarNuevoProducto()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Diálogo Editar Producto
    Dialog {
        id: dialogoEditarProducto
        title: "Editar Producto"
        modal: true
        anchors.centerIn: parent
        width: 600
        height: 500
        
        contentItem: ScrollView {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                width: parent.width - 20
                spacing: 15
                
                Text {
                    text: "Información del Producto"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2E7D32"
                    Layout.bottomMargin: 10
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Nombre Comercial *"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextField {
                        id: inputNombreProductoEdit
                        Layout.fillWidth: true
                        font.pixelSize: 13
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Categoría *"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    ComboBox {
                        id: comboCategoriaProductoEdit
                        Layout.fillWidth: true
                        model: categoriasData.map(c => c.nombre)
                        font.pixelSize: 13
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Formulación"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputFormulacionProductoEdit
                            Layout.fillWidth: true
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Unidad *"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        ComboBox {
                            id: comboUnidadProductoEdit
                            Layout.fillWidth: true
                            model: ["litros", "kg", "gramos", "ml", "unidades", "galones"]
                            font.pixelSize: 13
                        }
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Precio (Bs.)"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputPrecioProductoEdit
                            Layout.fillWidth: true
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Nº Registro"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputRegistroProductoEdit
                            Layout.fillWidth: true
                            font.pixelSize: 13
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Notas Adicionales"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextArea {
                        id: inputNotasProductoEdit
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        font.pixelSize: 12
                        wrapMode: TextArea.Wrap
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "Cancelar"
                        Layout.preferredWidth: 120
                        onClicked: dialogoEditarProducto.close()
                    }
                    
                    Button {
                        text: "Actualizar"
                        Layout.preferredWidth: 120
                        highlighted: true
                        enabled: inputNombreProductoEdit.text.trim() !== ""
                        onClicked: {
                            if (validarFormularioProductoEdit()) {
                                actualizarProducto()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Diálogo Eliminar Producto
    MessageDialog {
        id: dialogoEliminarProducto
        title: "Confirmar Eliminación"
        text: "¿Está seguro de que desea eliminar el producto '" + 
              (editarProductoActual.nombre_comercial || "") + "'?"
        informativeText: "Esta acción no se puede deshacer."
        buttons: MessageDialog.Yes | MessageDialog.No
        
        onAccepted: {
            if (editarProductoActual.id_producto) {
                var exito = agroquimicosModel.eliminar_producto(editarProductoActual.id_producto)
                if (exito) {
                    console.log("Producto eliminado exitosamente")
                } else {
                    console.log("Error al eliminar producto")
                }
            }
        }
    }
    
    // ==================== DIÁLOGOS - CATEGORÍAS ====================
    
    // Diálogo Nueva Categoría
    Dialog {
        id: dialogoNuevaCategoria
        title: "Nueva Categoría"
        modal: true
        anchors.centerIn: parent
        width: 500
        height: 350
        
        contentItem: ColumnLayout {
            spacing: 20
            anchors.fill: parent
            anchors.margins: 20
            
            Text {
                text: "Información de la Categoría"
                font.pixelSize: 16
                font.bold: true
                color: "#FF6F00"
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: "Nombre de la Categoría *"
                    font.pixelSize: 12
                    color: "#616161"
                }
                TextField {
                    id: inputNombreCategoria
                    Layout.fillWidth: true
                    placeholderText: "Ej: Herbicidas, Insecticidas..."
                    font.pixelSize: 13
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: "Descripción"
                    font.pixelSize: 12
                    color: "#616161"
                }
                TextArea {
                    id: inputDescripcionCategoria
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    placeholderText: "Descripción de la categoría..."
                    font.pixelSize: 12
                    wrapMode: TextArea.Wrap
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: 120
                    onClicked: dialogoNuevaCategoria.close()
                }
                
                Button {
                    text: "Guardar"
                    Layout.preferredWidth: 120
                    highlighted: true
                    enabled: inputNombreCategoria.text.trim() !== ""
                    onClicked: {
                        guardarNuevaCategoria()
                    }
                }
            }
        }
    }
    
    // Diálogo Editar Categoría
    Dialog {
        id: dialogoEditarCategoria
        title: "Editar Categoría"
        modal: true
        anchors.centerIn: parent
        width: 500
        height: 350
        
        contentItem: ColumnLayout {
            spacing: 20
            anchors.fill: parent
            anchors.margins: 20
            
            Text {
                text: "Información de la Categoría"
                font.pixelSize: 16
                font.bold: true
                color: "#FF6F00"
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: "Nombre de la Categoría *"
                    font.pixelSize: 12
                    color: "#616161"
                }
                TextField {
                    id: inputNombreCategoriaEdit
                    Layout.fillWidth: true
                    font.pixelSize: 13
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: "Descripción"
                    font.pixelSize: 12
                    color: "#616161"
                }
                TextArea {
                    id: inputDescripcionCategoriaEdit
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    font.pixelSize: 12
                    wrapMode: TextArea.Wrap
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Cancelar"
                    Layout.preferredWidth: 120
                    onClicked: dialogoEditarCategoria.close()
                }
                
                Button {
                    text: "Actualizar"
                    Layout.preferredWidth: 120
                    highlighted: true
                    enabled: inputNombreCategoriaEdit.text.trim() !== ""
                    onClicked: {
                        actualizarCategoria()
                    }
                }
            }
        }
    }
    
    // Diálogo Eliminar Categoría
    MessageDialog {
        id: dialogoEliminarCategoria
        title: "Confirmar Eliminación"
        text: "¿Está seguro de que desea eliminar la categoría '" + 
              (editarCategoriaActual.nombre || "") + "'?"
        informativeText: "Esta acción no se puede deshacer."
        buttons: MessageDialog.Yes | MessageDialog.No
        
        onAccepted: {
            if (editarCategoriaActual.id_categoria) {
                var exito = agroquimicosModel.eliminar_categoria(editarCategoriaActual.id_categoria)
                if (exito) {
                    console.log("Categoría eliminada exitosamente")
                } else {
                    console.log("Error al eliminar categoría")
                }
            }
        }
    }
    
    // ==================== DIÁLOGOS - MEZCLAS ====================
    
    // Diálogo Nueva Mezcla
    Dialog {
        id: dialogoNuevaMezcla
        title: "Nueva Mezcla"
        modal: true
        anchors.centerIn: parent
        width: 550
        height: 450
        
        contentItem: ScrollView {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                width: parent.width - 20
                spacing: 15
                
                Text {
                    text: "Información de la Mezcla"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#1976D2"
                    Layout.bottomMargin: 10
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Nombre de la Mezcla *"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextField {
                        id: inputNombreMezcla
                        Layout.fillWidth: true
                        placeholderText: "Ej: Mezcla Antiplagas 1"
                        font.pixelSize: 13
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Objetivo"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextField {
                        id: inputObjetivoMezcla
                        Layout.fillWidth: true
                        placeholderText: "Ej: Control de plagas en arroz"
                        font.pixelSize: 13
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Cantidad de Agua (L)"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputAguaMezcla
                            Layout.fillWidth: true
                            placeholderText: "200"
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Área de Aplicación (Ha)"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputAreaMezcla
                            Layout.fillWidth: true
                            placeholderText: "1.5"
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Notas"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextArea {
                        id: inputNotasMezcla
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        placeholderText: "Instrucciones especiales..."
                        font.pixelSize: 12
                        wrapMode: TextArea.Wrap
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "Cancelar"
                        Layout.preferredWidth: 120
                        onClicked: dialogoNuevaMezcla.close()
                    }
                    
                    Button {
                        text: "Guardar"
                        Layout.preferredWidth: 120
                        highlighted: true
                        enabled: inputNombreMezcla.text.trim() !== ""
                        onClicked: {
                            guardarNuevaMezcla()
                        }
                    }
                }
            }
        }
    }
    
    // Diálogo Editar Mezcla
    Dialog {
        id: dialogoEditarMezcla
        title: "Editar Mezcla"
        modal: true
        anchors.centerIn: parent
        width: 550
        height: 450
        
        contentItem: ScrollView {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                width: parent.width - 20
                spacing: 15
                
                Text {
                    text: "Información de la Mezcla"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#1976D2"
                    Layout.bottomMargin: 10
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Nombre de la Mezcla *"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextField {
                        id: inputNombreMezclaEdit
                        Layout.fillWidth: true
                        font.pixelSize: 13
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Objetivo"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextField {
                        id: inputObjetivoMezclaEdit
                        Layout.fillWidth: true
                        font.pixelSize: 13
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Cantidad de Agua (L)"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputAguaMezclaEdit
                            Layout.fillWidth: true
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Área de Aplicación (Ha)"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputAreaMezclaEdit
                            Layout.fillWidth: true
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Notas"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextArea {
                        id: inputNotasMezclaEdit
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        font.pixelSize: 12
                        wrapMode: TextArea.Wrap
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "Cancelar"
                        Layout.preferredWidth: 120
                        onClicked: dialogoEditarMezcla.close()
                    }
                    
                    Button {
                        text: "Actualizar"
                        Layout.preferredWidth: 120
                        highlighted: true
                        enabled: inputNombreMezclaEdit.text.trim() !== ""
                        onClicked: {
                            actualizarMezcla()
                        }
                    }
                }
            }
        }
    }
    
    // Diálogo Detalles Mezcla
    Dialog {
        id: dialogoDetallesMezcla
        title: "Detalles de la Mezcla"
        modal: true
        anchors.centerIn: parent
        width: 600
        height: 500
        
        contentItem: ScrollView {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                width: parent.width - 20
                spacing: 20
                
                Text {
                    text: editarMezclaActual.nombre || ""
                    font.pixelSize: 18
                    font.bold: true
                    color: "#1976D2"
                }
                
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: 15
                    columnSpacing: 20
                    
                    Text {
                        text: "Objetivo:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarMezclaActual.objetivo || "Sin objetivo"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    
                    Text {
                        text: "Agua:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: (editarMezclaActual.cantidad_agua ? parseFloat(editarMezclaActual.cantidad_agua).toFixed(1) : "0") + " L"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Área de Aplicación:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: (editarMezclaActual.area_aplicacion ? parseFloat(editarMezclaActual.area_aplicacion).toFixed(2) : "0") + " Ha"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Estado:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Rectangle {
                        width: 70; height: 24
                        radius: 12
                        color: editarMezclaActual.activo ? "#E8F5E9" : "#FFEBEE"
                        
                        Text {
                            anchors.centerIn: parent
                            text: editarMezclaActual.activo ? "Activa" : "Inactiva"
                            font.pixelSize: 11
                            font.bold: true
                            color: editarMezclaActual.activo ? "#2E7D32" : "#D32F2F"
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    visible: editarMezclaActual.notas ? true : false
                    
                    Text {
                        text: "Notas:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarMezclaActual.notas || ""
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#616161"
                    }
                }
                
                Item { Layout.fillHeight: true }
                
                Button {
                    text: "Cerrar"
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: 120
                    onClicked: dialogoDetallesMezcla.close()
                }
            }
        }
    }
    
    // Diálogo Eliminar Mezcla
    MessageDialog {
        id: dialogoEliminarMezcla
        title: "Confirmar Eliminación"
        text: "¿Está seguro de que desea eliminar la mezcla '" + 
              (editarMezclaActual.nombre || "") + "'?"
        informativeText: "Esta acción no se puede deshacer."
        buttons: MessageDialog.Yes | MessageDialog.No
        
        onAccepted: {
            if (editarMezclaActual.id_mezcla) {
                var exito = agroquimicosModel.eliminar_mezcla(editarMezclaActual.id_mezcla)
                if (exito) {
                    console.log("Mezcla eliminada exitosamente")
                } else {
                    console.log("Error al eliminar mezcla")
                }
            }
        }
    }
    
    // ==================== DIÁLOGOS - TRATAMIENTOS ====================
    
    // Diálogo Nuevo Tratamiento
    Dialog {
        id: dialogoNuevoTratamiento
        title: "Nuevo Tratamiento Fitosanitario"
        modal: true
        anchors.centerIn: parent
        width: 600
        height: 550
        
        contentItem: ScrollView {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                width: parent.width - 20
                spacing: 15
                
                Text {
                    text: "Información del Tratamiento"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#D32F2F"
                    Layout.bottomMargin: 10
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Fecha de Aplicación *"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputFechaTratamiento
                            Layout.fillWidth: true
                            placeholderText: "DD/MM/YYYY"
                            font.pixelSize: 13
                            
                            Component.onCompleted: {
                                var today = new Date()
                                text = Qt.formatDate(today, "dd/MM/yyyy")
                            }
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Área Tratada (Ha) *"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputAreaTratamiento
                            Layout.fillWidth: true
                            placeholderText: "1.5"
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Tipo de Plaga/Maleza"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextField {
                        id: inputTipoPlagaTratamiento
                        Layout.fillWidth: true
                        placeholderText: "Ej: Gusano cogollero, Malezas de hoja ancha..."
                        font.pixelSize: 13
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Mezcla Aplicada"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    ComboBox {
                        id: comboMezclaTratamiento
                        Layout.fillWidth: true
                        model: ["Ninguna"].concat(mezclasData.map(m => m.nombre))
                        font.pixelSize: 13
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Método de Aplicación"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        ComboBox {
                            id: comboMetodoTratamiento
                            Layout.fillWidth: true
                            model: ["Aspersión terrestre", "Aspersión aérea", "Manual", "Otro"]
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Cantidad de Agua (L)"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputCantidadAguaTratamiento
                            Layout.fillWidth: true
                            placeholderText: "200"
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Observaciones"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextArea {
                        id: inputObservacionesTratamiento
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        placeholderText: "Observaciones adicionales..."
                        font.pixelSize: 12
                        wrapMode: TextArea.Wrap
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "Cancelar"
                        Layout.preferredWidth: 120
                        onClicked: dialogoNuevoTratamiento.close()
                    }
                    
                    Button {
                        text: "Guardar"
                        Layout.preferredWidth: 120
                        highlighted: true
                        enabled: inputFechaTratamiento.text.trim() !== "" && 
                                inputAreaTratamiento.text.trim() !== ""
                        onClicked: {
                            guardarNuevoTratamiento()
                        }
                    }
                }
            }
        }
    }
    
    // Diálogo Editar Tratamiento
    Dialog {
        id: dialogoEditarTratamiento
        title: "Editar Tratamiento"
        modal: true
        anchors.centerIn: parent
        width: 600
        height: 550
        
        contentItem: ScrollView {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                width: parent.width - 20
                spacing: 15
                
                Text {
                    text: "Información del Tratamiento"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#D32F2F"
                    Layout.bottomMargin: 10
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Fecha de Aplicación *"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputFechaTratamientoEdit
                            Layout.fillWidth: true
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Área Tratada (Ha) *"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputAreaTratamientoEdit
                            Layout.fillWidth: true
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Tipo de Plaga/Maleza"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextField {
                        id: inputTipoPlagaTratamientoEdit
                        Layout.fillWidth: true
                        font.pixelSize: 13
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Mezcla Aplicada"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    ComboBox {
                        id: comboMezclaTratamientoEdit
                        Layout.fillWidth: true
                        model: ["Ninguna"].concat(mezclasData.map(m => m.nombre))
                        font.pixelSize: 13
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Método de Aplicación"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        ComboBox {
                            id: comboMetodoTratamientoEdit
                            Layout.fillWidth: true
                            model: ["Aspersión terrestre", "Aspersión aérea", "Manual", "Otro"]
                            font.pixelSize: 13
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Cantidad de Agua (L)"
                            font.pixelSize: 12
                            color: "#616161"
                        }
                        TextField {
                            id: inputCantidadAguaTratamientoEdit
                            Layout.fillWidth: true
                            validator: DoubleValidator { bottom: 0; decimals: 2 }
                            font.pixelSize: 13
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Observaciones"
                        font.pixelSize: 12
                        color: "#616161"
                    }
                    TextArea {
                        id: inputObservacionesTratamientoEdit
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        font.pixelSize: 12
                        wrapMode: TextArea.Wrap
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "Cancelar"
                        Layout.preferredWidth: 120
                        onClicked: dialogoEditarTratamiento.close()
                    }
                    
                    Button {
                        text: "Actualizar"
                        Layout.preferredWidth: 120
                        highlighted: true
                        enabled: inputFechaTratamientoEdit.text.trim() !== "" && 
                                inputAreaTratamientoEdit.text.trim() !== ""
                        onClicked: {
                            actualizarTratamiento()
                        }
                    }
                }
            }
        }
    }
    
    // Diálogo Detalles Tratamiento
    Dialog {
        id: dialogoDetallesTratamiento
        title: "Detalles del Tratamiento"
        modal: true
        anchors.centerIn: parent
        width: 600
        height: 550
        
        contentItem: ScrollView {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                width: parent.width - 20
                spacing: 20
                
                Text {
                    text: "Tratamiento #" + (editarTratamientoActual.id_tratamiento || "")
                    font.pixelSize: 18
                    font.bold: true
                    color: "#D32F2F"
                }
                
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: 15
                    columnSpacing: 20
                    
                    Text {
                        text: "Fecha:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarTratamientoActual.fecha_aplicacion || ""
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Parcela:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarTratamientoActual.nombre_parcela || "Sin parcela"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Tipo de Plaga:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarTratamientoActual.nombre_plaga || "Sin especificar"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Mezcla:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarTratamientoActual.nombre_mezcla || "Ninguna"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Área Tratada:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: (editarTratamientoActual.area_tratada ? parseFloat(editarTratamientoActual.area_tratada).toFixed(2) : "0") + " Ha"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Método:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarTratamientoActual.metodo_aplicacion || "No especificado"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Cantidad de Agua:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: (editarTratamientoActual.cantidad_agua ? parseFloat(editarTratamientoActual.cantidad_agua).toFixed(1) : "0") + " L"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Costo Total:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: "Bs. " + (editarTratamientoActual.costo_total ? parseFloat(editarTratamientoActual.costo_total).toFixed(2) : "0.00")
                        font.pixelSize: 13
                        font.bold: true
                        color: "#2E7D32"
                    }
                    
                    Text {
                        text: "Realizado por:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarTratamientoActual.nombre_empleado || "Sin especificar"
                        font.pixelSize: 13
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    visible: editarTratamientoActual.observaciones ? true : false
                    
                    Text {
                        text: "Observaciones:"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#424242"
                    }
                    Text {
                        text: editarTratamientoActual.observaciones || ""
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#616161"
                    }
                }
                
                Item { Layout.fillHeight: true }
                
                Button {
                    text: "Cerrar"
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: 120
                    onClicked: dialogoDetallesTratamiento.close()
                }
            }
        }
    }
    
    // Diálogo Eliminar Tratamiento
    MessageDialog {
        id: dialogoEliminarTratamiento
        title: "Confirmar Eliminación"
        text: "¿Está seguro de que desea eliminar el tratamiento #" + 
              (editarTratamientoActual.id_tratamiento || "") + "?"
        informativeText: "Esta acción no se puede deshacer."
        buttons: MessageDialog.Yes | MessageDialog.No
        
        onAccepted: {
            if (editarTratamientoActual.id_tratamiento) {
                var exito = agroquimicosModel.eliminar_tratamiento(editarTratamientoActual.id_tratamiento)
                if (exito) {
                    console.log("Tratamiento eliminado exitosamente")
                } else {
                    console.log("Error al eliminar tratamiento")
                }
            }
        }
    }
    
    // ==================== FUNCIONES JAVASCRIPT ====================
    
    // ========== FUNCIONES DE CARGA DE DATOS ==========
    
    function cargarTodosLosDatos() {
        console.log("Cargando datos de agroquímicos...")
        agroquimicosModel.cargar_productos()
        agroquimicosModel.cargar_categorias()
        agroquimicosModel.cargar_mezclas()
        agroquimicosModel.cargar_tratamientos()
    }

    function cargarProductosDesdeModelo() {
        inventarioData = agroquimicosModel.productos
        inventarioFiltrado = inventarioData
        console.log("✅ Productos cargados:", inventarioData.length)
    }
    
    function cargarCategoriasDesdeModelo() {
        categoriasData = agroquimicosModel.categorias
        categoriasFiltrado = categoriasData
        categoriasFilter = ["Todas las categorías"].concat(categoriasData.map(c => c.nombre))
        console.log("✅ Categorías cargadas:", categoriasData.length)
    }

    function cargarMezclasDesdeModelo() {
        mezclasData = agroquimicosModel.mezclas
        mezclasFiltrado = mezclasData
        console.log("✅ Mezclas cargadas:", mezclasData.length)
    }

    function cargarTratamientosDesdeModelo() {
        tratamientosData = agroquimicosModel.tratamientos
        tratamientosFiltrado = tratamientosData
        console.log("✅ Tratamientos cargados:", tratamientosData.length)
    }
    
    // ========== FUNCIONES DE FILTRADO ==========
    
    function filtrarProductos(textoBusqueda, categoriaIndex) {
        var filtrado = inventarioData
        
        // Filtrar por texto
        if (textoBusqueda && textoBusqueda.trim() !== "") {
            var texto = textoBusqueda.toLowerCase()
            filtrado = filtrado.filter(function(p) {
                return (p.nombre_comercial && p.nombre_comercial.toLowerCase().includes(texto)) ||
                       (p.categoria && p.categoria.toLowerCase().includes(texto)) ||
                       (p.formulacion && p.formulacion.toLowerCase().includes(texto)) ||
                       (p.registro && p.registro.toLowerCase().includes(texto))
            })
        }
        
        // Filtrar por categoría
        if (categoriaIndex > 0) {
            var categoriaNombre = categoriasFilter[categoriaIndex]
            filtrado = filtrado.filter(function(p) {
                return p.categoria === categoriaNombre
            })
        }
        
        inventarioFiltrado = filtrado
    }
    
    function filtrarCategorias(textoBusqueda, estadoIndex) {
        var filtrado = categoriasData
        
        // Filtrar por texto
        if (textoBusqueda && textoBusqueda.trim() !== "") {
            var texto = textoBusqueda.toLowerCase()
            filtrado = filtrado.filter(function(c) {
                return (c.nombre && c.nombre.toLowerCase().includes(texto)) ||
                       (c.descripcion && c.descripcion.toLowerCase().includes(texto))
            })
        }
        
        // Filtrar por estado
        if (estadoIndex > 0) {
            if (estadoIndex === 1) { // Activos
                filtrado = filtrado.filter(function(c) { return c.activo === true })
            } else if (estadoIndex === 2) { // Inactivos
                filtrado = filtrado.filter(function(c) { return c.activo === false })
            }
        }
        
        categoriasFiltrado = filtrado
    }
    
    function filtrarMezclas(textoBusqueda, estadoIndex) {
        var filtrado = mezclasData
        
        // Filtrar por texto
        if (textoBusqueda && textoBusqueda.trim() !== "") {
            var texto = textoBusqueda.toLowerCase()
            filtrado = filtrado.filter(function(m) {
                return (m.nombre && m.nombre.toLowerCase().includes(texto)) ||
                       (m.objetivo && m.objetivo.toLowerCase().includes(texto))
            })
        }
        
        // Filtrar por estado
        if (estadoIndex > 0) {
            if (estadoIndex === 1) { // Activas
                filtrado = filtrado.filter(function(m) { return m.activo === true })
            } else if (estadoIndex === 2) { // Inactivas
                filtrado = filtrado.filter(function(m) { return m.activo === false })
            }
        }
        
        mezclasFiltrado = filtrado
    }
    
    function filtrarTratamientos(textoBusqueda, periodoIndex) {
        var filtrado = tratamientosData
        
        // Filtrar por texto
        if (textoBusqueda && textoBusqueda.trim() !== "") {
            var texto = textoBusqueda.toLowerCase()
            filtrado = filtrado.filter(function(t) {
                return (t.nombre_parcela && t.nombre_parcela.toLowerCase().includes(texto)) ||
                       (t.nombre_plaga && t.nombre_plaga.toLowerCase().includes(texto)) ||
                       (t.nombre_mezcla && t.nombre_mezcla.toLowerCase().includes(texto)) ||
                       (t.metodo_aplicacion && t.metodo_aplicacion.toLowerCase().includes(texto))
            })
        }
        
        // Filtrar por período (implementar si es necesario)
        // TODO: Agregar lógica de filtrado por fecha
        
        tratamientosFiltrado = filtrado
    }
    
    // ========== FUNCIONES DE PRODUCTOS ==========
    
    function limpiarFormularioProducto() {
        inputNombreProducto.text = ""
        comboCategoriaProducto.currentIndex = 0
        inputFormulacionProducto.text = ""
        comboUnidadProducto.currentIndex = 0
        inputPrecioProducto.text = ""
        inputRegistroProducto.text = ""
        inputNotasProducto.text = ""
    }
    
    function validarFormularioProducto() {
        if (inputNombreProducto.text.trim() === "") {
            console.log("El nombre comercial es obligatorio")
            return false
        }
        if (comboCategoriaProducto.currentIndex < 0) {
            console.log("Debe seleccionar una categoría")
            return false
        }
        return true
    }
    
    function guardarNuevoProducto() {
        var producto = {
            "nombre_comercial": inputNombreProducto.text.trim(),
            "id_categoria": categoriasData[comboCategoriaProducto.currentIndex].id_categoria,
            "formulacion": inputFormulacionProducto.text.trim() || null,
            "unidad": comboUnidadProducto.currentText,
            "precio": parseFloat(inputPrecioProducto.text) || 0.0,
            "registro": inputRegistroProducto.text.trim() || null,
            "notas": inputNotasProducto.text.trim() || null
        }
        
        var exito = agroquimicosModel.agregar_producto(JSON.stringify(producto))
        if (exito) {
            console.log("✅ Producto guardado exitosamente")
            dialogoNuevoProducto.close()
            limpiarFormularioProducto()
        } else {
            console.log("❌ Error al guardar producto")
        }
    }
    
    function cargarDatosEdicionProducto() {
        inputNombreProductoEdit.text = editarProductoActual.nombre_comercial || ""
        inputFormulacionProductoEdit.text = editarProductoActual.formulacion || ""
        inputPrecioProductoEdit.text = editarProductoActual.precio ? editarProductoActual.precio.toString() : ""
        inputRegistroProductoEdit.text = editarProductoActual.registro || ""
        inputNotasProductoEdit.text = editarProductoActual.notas || ""
        
        // Seleccionar categoría
        var categoriaIndex = categoriasData.findIndex(function(c) {
            return c.id_categoria === editarProductoActual.id_categoria
        })
        if (categoriaIndex >= 0) {
            comboCategoriaProductoEdit.currentIndex = categoriaIndex
        }
        
        // Seleccionar unidad
        var unidadIndex = comboUnidadProductoEdit.model.indexOf(editarProductoActual.unidad)
        if (unidadIndex >= 0) {
            comboUnidadProductoEdit.currentIndex = unidadIndex
        }
    }
    
    function validarFormularioProductoEdit() {
        if (inputNombreProductoEdit.text.trim() === "") {
            console.log("El nombre comercial es obligatorio")
            return false
        }
        return true
    }
    
    function actualizarProducto() {
        var producto = {
            "nombre_comercial": inputNombreProductoEdit.text.trim(),
            "id_categoria": categoriasData[comboCategoriaProductoEdit.currentIndex].id_categoria,
            "formulacion": inputFormulacionProductoEdit.text.trim() || null,
            "unidad": comboUnidadProductoEdit.currentText,
            "precio": parseFloat(inputPrecioProductoEdit.text) || 0.0,
            "registro": inputRegistroProductoEdit.text.trim() || null,
            "notas": inputNotasProductoEdit.text.trim() || null
        }
        
        var exito = agroquimicosModel.actualizar_producto(
            editarProductoActual.id_producto,
            JSON.stringify(producto)
        )
        
        if (exito) {
            console.log("✅ Producto actualizado exitosamente")
            dialogoEditarProducto.close()
        } else {
            console.log("❌ Error al actualizar producto")
        }
    }
    
    // ========== FUNCIONES DE CATEGORÍAS ==========
    
    function limpiarFormularioCategoria() {
        inputNombreCategoria.text = ""
        inputDescripcionCategoria.text = ""
    }
    
    function guardarNuevaCategoria() {
        var categoria = {
            "nombre": inputNombreCategoria.text.trim(),
            "descripcion": inputDescripcionCategoria.text.trim() || null,
            "activo": true
        }
        
        var exito = agroquimicosModel.agregar_categoria(JSON.stringify(categoria))
        if (exito) {
            console.log("✅ Categoría guardada exitosamente")
            dialogoNuevaCategoria.close()
            limpiarFormularioCategoria()
        } else {
            console.log("❌ Error al guardar categoría")
        }
    }
    
    function cargarDatosEdicionCategoria() {
        inputNombreCategoriaEdit.text = editarCategoriaActual.nombre || ""
        inputDescripcionCategoriaEdit.text = editarCategoriaActual.descripcion || ""
    }
    
    function actualizarCategoria() {
        var categoria = {
            "nombre": inputNombreCategoriaEdit.text.trim(),
            "descripcion": inputDescripcionCategoriaEdit.text.trim() || null
        }
        
        var exito = agroquimicosModel.actualizar_categoria(
            editarCategoriaActual.id_categoria,
            JSON.stringify(categoria)
        )
        
        if (exito) {
            console.log("✅ Categoría actualizada exitosamente")
            dialogoEditarCategoria.close()
        } else {
            console.log("❌ Error al actualizar categoría")
        }
    }
    
    // ========== FUNCIONES DE MEZCLAS ==========
    
    function limpiarFormularioMezcla() {
        inputNombreMezcla.text = ""
        inputObjetivoMezcla.text = ""
        inputAguaMezcla.text = ""
        inputAreaMezcla.text = ""
        inputNotasMezcla.text = ""
    }
    
    function guardarNuevaMezcla() {
        var mezcla = {
            "nombre": inputNombreMezcla.text.trim(),
            "objetivo": inputObjetivoMezcla.text.trim() || null,
            "cantidad_agua": parseFloat(inputAguaMezcla.text) || 0.0,
            "area_aplicacion": parseFloat(inputAreaMezcla.text) || 0.0,
            "notas": inputNotasMezcla.text.trim() || null,
            "activo": true
        }
        
        // Por ahora sin detalles de productos
        var exito = agroquimicosModel.agregar_mezcla(JSON.stringify(mezcla), "")
        if (exito) {
            console.log("✅ Mezcla guardada exitosamente")
            dialogoNuevaMezcla.close()
            limpiarFormularioMezcla()
        } else {
            console.log("❌ Error al guardar mezcla")
        }
    }
    
    function cargarDatosEdicionMezcla() {
        inputNombreMezclaEdit.text = editarMezclaActual.nombre || ""
        inputObjetivoMezclaEdit.text = editarMezclaActual.objetivo || ""
        inputAguaMezclaEdit.text = editarMezclaActual.cantidad_agua ? editarMezclaActual.cantidad_agua.toString() : ""
        inputAreaMezclaEdit.text = editarMezclaActual.area_aplicacion ? editarMezclaActual.area_aplicacion.toString() : ""
        inputNotasMezclaEdit.text = editarMezclaActual.notas || ""
    }
    
    function actualizarMezcla() {
        var mezcla = {
            "nombre": inputNombreMezclaEdit.text.trim(),
            "objetivo": inputObjetivoMezclaEdit.text.trim() || null,
            "cantidad_agua": parseFloat(inputAguaMezclaEdit.text) || 0.0,
            "area_aplicacion": parseFloat(inputAreaMezclaEdit.text) || 0.0,
            "notas": inputNotasMezclaEdit.text.trim() || null
        }
        
        var exito = agroquimicosModel.actualizar_mezcla(
            editarMezclaActual.id_mezcla,
            JSON.stringify(mezcla)
        )
        
        if (exito) {
            console.log("✅ Mezcla actualizada exitosamente")
            dialogoEditarMezcla.close()
        } else {
            console.log("❌ Error al actualizar mezcla")
        }
    }
    
    // ========== FUNCIONES DE TRATAMIENTOS ==========
    
    function limpiarFormularioTratamiento() {
        var today = new Date()
        inputFechaTratamiento.text = Qt.formatDate(today, "dd/MM/yyyy")
        inputAreaTratamiento.text = ""
        inputTipoPlagaTratamiento.text = ""
        comboMezclaTratamiento.currentIndex = 0
        comboMetodoTratamiento.currentIndex = 0
        inputCantidadAguaTratamiento.text = ""
        inputObservacionesTratamiento.text = ""
    }
    
    function guardarNuevoTratamiento() {
        // Convertir fecha de DD/MM/YYYY a YYYY-MM-DD
        var partesFecha = inputFechaTratamiento.text.split("/")
        var fechaFormateada = partesFecha[2] + "-" + partesFecha[1] + "-" + partesFecha[0]
        
        var tratamiento = {
            "fecha_aplicacion": fechaFormateada,
            "area_tratada": parseFloat(inputAreaTratamiento.text) || 0.0,
            "metodo_aplicacion": comboMetodoTratamiento.currentText,
            "cantidad_agua": parseFloat(inputCantidadAguaTratamiento.text) || null,
            "observaciones": inputObservacionesTratamiento.text.trim() || null,
            "id_ciclo": 1, // TODO: Obtener de un selector
            "realizado_por": 1 // TODO: Obtener del usuario actual
        }
        
        // Agregar tipo de plaga si existe (como texto por ahora)
        if (inputTipoPlagaTratamiento.text.trim() !== "") {
            // TODO: Crear o buscar el tipo de plaga en la BD
        }
        
        // Agregar mezcla si se seleccionó
        if (comboMezclaTratamiento.currentIndex > 0) {
            var mezclaNombre = comboMezclaTratamiento.currentText
            var mezclaEncontrada = mezclasData.find(function(m) {
                return m.nombre === mezclaNombre
            })
            if (mezclaEncontrada) {
                tratamiento.id_mezcla = mezclaEncontrada.id_mezcla
            }
        }
        
        var exito = agroquimicosModel.agregar_tratamiento(JSON.stringify(tratamiento))
        if (exito) {
            console.log("✅ Tratamiento guardado exitosamente")
            dialogoNuevoTratamiento.close()
            limpiarFormularioTratamiento()
        } else {
            console.log("❌ Error al guardar tratamiento")
        }
    }
    
    function cargarDatosEdicionTratamiento() {
        inputFechaTratamientoEdit.text = editarTratamientoActual.fecha_aplicacion || ""
        inputAreaTratamientoEdit.text = editarTratamientoActual.area_tratada ? editarTratamientoActual.area_tratada.toString() : ""
        inputTipoPlagaTratamientoEdit.text = editarTratamientoActual.nombre_plaga || ""
        inputCantidadAguaTratamientoEdit.text = editarTratamientoActual.cantidad_agua ? editarTratamientoActual.cantidad_agua.toString() : ""
        inputObservacionesTratamientoEdit.text = editarTratamientoActual.observaciones || ""
        
        // Seleccionar mezcla
        if (editarTratamientoActual.nombre_mezcla) {
            var mezclaIndex = comboMezclaTratamientoEdit.model.indexOf(editarTratamientoActual.nombre_mezcla)
            if (mezclaIndex >= 0) {
                comboMezclaTratamientoEdit.currentIndex = mezclaIndex
            }
        }
        
        // Seleccionar método
        if (editarTratamientoActual.metodo_aplicacion) {
            var metodoIndex = comboMetodoTratamientoEdit.model.indexOf(editarTratamientoActual.metodo_aplicacion)
            if (metodoIndex >= 0) {
                comboMetodoTratamientoEdit.currentIndex = metodoIndex
            }
        }
    }
    
    function actualizarTratamiento() {
        // Convertir fecha si es necesario
        var fechaTexto = inputFechaTratamientoEdit.text
        var fechaFormateada = fechaTexto
        if (fechaTexto.includes("/")) {
            var partesFecha = fechaTexto.split("/")
            fechaFormateada = partesFecha[2] + "-" + partesFecha[1] + "-" + partesFecha[0]
        }
        
        var tratamiento = {
            "fecha_aplicacion": fechaFormateada,
            "area_tratada": parseFloat(inputAreaTratamientoEdit.text) || 0.0,
            "metodo_aplicacion": comboMetodoTratamientoEdit.currentText,
            "cantidad_agua": parseFloat(inputCantidadAguaTratamientoEdit.text) || null,
            "observaciones": inputObservacionesTratamientoEdit.text.trim() || null
        }
        
        // Agregar mezcla si se seleccionó
        if (comboMezclaTratamientoEdit.currentIndex > 0) {
            var mezclaNombre = comboMezclaTratamientoEdit.currentText
            var mezclaEncontrada = mezclasData.find(function(m) {
                return m.nombre === mezclaNombre
            })
            if (mezclaEncontrada) {
                tratamiento.id_mezcla = mezclaEncontrada.id_mezcla
            }
        }
        
        var exito = agroquimicosModel.actualizar_tratamiento(
            editarTratamientoActual.id_tratamiento,
            JSON.stringify(tratamiento)
        )
        
        if (exito) {
            console.log("✅ Tratamiento actualizado exitosamente")
            dialogoEditarTratamiento.close()
        } else {
            console.log("❌ Error al actualizar tratamiento")
        }
    }
}
