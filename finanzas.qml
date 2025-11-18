import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: finanzasRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // Estado para controlar la pestaña activa
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Flujo de Caja", "icon": "recursos/image/icons/moneda.png", "color": "#009688"},
        {"text": "Costos de Producción", "icon": "recursos/image/icons/costoproduccion.png", "color": "#FF9800"},
        {"text": "Pagos a Agricultores", "icon": "recursos/image/icons/pagosagricultures.png", "color": "#4CAF50"},
        {"text": "Combustible y Maquinaria", "icon": "recursos/image/icons/combustible.png", "color": "#2196F3"},
        {"text": "Inventario Agroquímicos", "icon": "recursos/image/icons/inventario.png", "color": "#9C27B0"}
    ]
    
    // Propiedades para manejar datos dinámicos
    property var costosProduccion: []
    property var pagosAgricultores: []
    property var comprasCombustible: []
    property var usoMaquinaria: []
    property var mantenimientos: []
    property var inventarioAgroquimicos: []
    
    property var categoriasCostos: ["Semillas", "Fertilizantes", "Agroquímicos", "Mano de Obra", "Maquinaria", "Otros"]
    property var metodosPago: ["Efectivo", "Transferencia", "Cheque", "Depósito"]
    property var estadosPago: ["Pendiente", "Confirmado", "Rechazado"]
    property var tiposCombustible: ["Diésel", "Gasolina", "Gas"]
    property var monedas: ["BOB", "USD"]
    property string monedaSeleccionada: "BOB"
    
    // Propiedades para paginación
    property int paginaActualCostos: 1
    property int totalPaginasCostos: 1
    property int paginaActualPagos: 1
    property int totalPaginasPagos: 1
    property int paginaActualCombustible: 1
    property int totalPaginasCombustible: 1
    property int paginaActualInventario: 1
    property int totalPaginasInventario: 1
    property int paginaActualFlujo: 1
    property int totalPaginasFlujo: 1

    // Inicialización del componente
    Component.onCompleted: {
        console.log("💰 Inicializando módulo de finanzas...")
        if (typeof finanzasModel !== 'undefined') {
            finanzasModel.obtenerBalance()
            finanzasModel.obtenerCategorias()
            finanzasModel.obtenerMovimientos()
        } else {
            console.error("❌ finanzasModel no está disponible en el contexto QML")
        }
    }
    
    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"

        Text {
            text: "GESTIÓN FINANCIERA Y FLUJO DE CAJA"
            font.pixelSize: 28
            font.bold: true
            color: "#009688"
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
            tabsData: finanzasRoot.tabsInfo
            tabActiva: finanzasRoot.tabActiva
            
            onTabChanged: function(index) {
                finanzasRoot.tabActiva = index
                // Resetear páginas al cambiar de tab
                paginaActualCostos = 1
                paginaActualPagos = 1
                paginaActualCombustible = 1
                paginaActualInventario = 1
                paginaActualFlujo = 1
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
        
        // ============================================
        // CONTENIDO DE FLUJO DE CAJA (NUEVA PESTAÑA)
        // ============================================
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
                
                // Indicador de Balance
                Rectangle {
                    width: parent.width
                    height: 80
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        Column {
                            width: parent.width * 0.7
                            height: parent.height
                            spacing: 5
                            
                            Text {
                                text: "BALANCE ACTUAL"
                                font.pixelSize: 14
                                color: "#666666"
                                font.bold: true
                            }
                            
                            Text {
                                text: typeof finanzasModel !== 'undefined' ? 
                                      monedaSeleccionada + " " + finanzasModel.balanceActual.toFixed(2) : 
                                      monedaSeleccionada + " 0.00"
                                font.pixelSize: 28
                                font.bold: true
                                color: typeof finanzasModel !== 'undefined' && finanzasModel.balanceActual >= 0 ? 
                                       "#2E7D32" : "#C62828"
                            }
                        }
                        
                        CustomButton {
                            width: 220
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Registrar Capital / Gasto General"
                            iconSource: "recursos/image/icons/agregar.svg"
                            backgroundColor: "#009688"
                            textColor: "#FFFFFF"
                            fontSize: 13
                            borderRadius: 8
                            
                            onClicked: {
                                registroMovimientoDialog.open()
                            }
                        }
                    }
                }
                
                // Barra de herramientas para Flujo de Caja
                FilterHeaderComponent {
                    id: filterHeaderFlujo
                    width: parent.width
                    height: 60
                    buttonText: "Filtrar Movimientos"
                    buttonIcon: "recursos/image/icons/filtrar.svg"
                    buttonColor: "#009688"
                    searchPlaceholder: "Buscar por descripción o categoría..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: ["Todos", "Ingresos", "Egresos"]
                    filterPlaceholder: "Tipo..."
                    filterWidth: 140
                    
                    onButtonClicked: {
                        console.log("Aplicar filtros personalizados")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar movimiento:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por tipo:", filterOptions[index])
                    }
                }
                
                // Tabla de Movimientos Financieros
                Rectangle {
                    width: parent.width
                    height: parent.height - 175
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: movimientosListView
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: typeof finanzasModel !== 'undefined' ? finanzasModel.movimientos : []
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
                                Text { width: parent.width * 0.12; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.18; height: parent.height; text: "Categoría"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.28; height: parent.height; text: "Descripción"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Monto"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
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
                                onEntered: parent.color = "#E0F2F1"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { 
                                    width: parent.width * 0.12; 
                                    height: parent.height; 
                                    text: modelData.fecha_movimiento || ""; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 80
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: modelData.es_gasto ? "#FFEBEE" : "#E8F5E8"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.es_gasto ? "EGRESO" : "INGRESO"
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: modelData.es_gasto ? "#C62828" : "#2E7D32"
                                        }
                                    }
                                }
                                
                                Text { 
                                    width: parent.width * 0.18; 
                                    height: parent.height; 
                                    text: modelData.categoria_nombre || ""; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                
                                Text { 
                                    width: parent.width * 0.28; 
                                    height: parent.height; 
                                    text: modelData.descripcion || ""; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                
                                Text { 
                                    width: parent.width * 0.15; 
                                    height: parent.height; 
                                    text: monedaSeleccionada + " " + (modelData.monto || 0).toFixed(2); 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12; 
                                    font.bold: true; 
                                    color: modelData.es_gasto ? "#C62828" : "#2E7D32" 
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
                                            onClicked: console.log("Editar movimiento", modelData.id)
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
                                            onClicked: console.log("Eliminar movimiento", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador para Flujo de Caja
                Paginator {
                    id: paginadorFlujo
                    width: parent.width
                    height: 40
                    currentPage: paginaActualFlujo
                    totalPages: totalPaginasFlujo
                    
                    onPageChanged: {
                        paginaActualFlujo = newPage
                    }
                }
            }
        }
        
        // ============================================
        // CONTENIDO DE COSTOS DE PRODUCCIÓN (ÍNDICE 1)
        // ============================================
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
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderCostos
                    width: parent.width
                    height: 60
                    buttonText: "Registrar Costo"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#FF9800"
                    searchPlaceholder: "Buscar por concepto, ciclo o parcela..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: categoriasCostos
                    filterPlaceholder: "Categoría..."
                    filterWidth: 150
                    
                    onButtonClicked: {
                        console.log("Registrar nuevo costo")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar costo:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por categoría:", categoriasCostos[index])
                    }
                }
                
                // Tabla de datos
                Rectangle {
                    width: parent.width
                    height: parent.height - 120
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: costosProduccion
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.08; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Ciclo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Parcela"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Categoría"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.18; height: parent.height; text: "Concepto"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.08; height: parent.height; text: "Cant."; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.08; height: parent.height; text: "Costo U."; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Total"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.08; height: parent.height; text: "Comprob."; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.08; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { width: parent.width * 0.08; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.ciclo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.parcela; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.categoria; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.18; height: parent.height; text: modelData.concepto; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.08; height: parent.height; text: modelData.cantidad + " " + modelData.unidad; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.08; height: parent.height; text: monedaSeleccionada + " " + modelData.costo_unitario.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: monedaSeleccionada + " " + modelData.total.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#2E7D32" }
                                Text { width: parent.width * 0.08; height: parent.height; text: modelData.comprobante; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; color: "#0288D1" }
                                
                                Rectangle {
                                    width: parent.width * 0.08
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
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
                                            onClicked: console.log("Editar costo", modelData.id)
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
                                            onClicked: console.log("Eliminar costo", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador para Costos de Producción
                Paginator {
                    id: paginadorCostos
                    width: parent.width
                    height: 40
                    currentPage: paginaActualCostos
                    totalPages: totalPaginasCostos
                    
                    onPageChanged: {
                        paginaActualCostos = newPage
                    }
                }
            }
        }
        
        // ============================================
        // CONTENIDO DE PAGOS A AGRICULTORES (ÍNDICE 2)
        // ============================================
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
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderPagos
                    width: parent.width
                    height: 60
                    buttonText: "Registrar Pago"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#4CAF50"
                    searchPlaceholder: "Buscar por agricultor o concepto..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: estadosPago
                    filterPlaceholder: "Estado..."
                    filterWidth: 140
                    
                    onButtonClicked: {
                        console.log("Registrar nuevo pago")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar pago:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por estado:", estadosPago[index])
                    }
                }
                
                // Tabla de datos
                Rectangle {
                    width: parent.width
                    height: parent.height - 120
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: pagosAgricultores
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.1; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Agricultor"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.22; height: parent.height; text: "Concepto"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Monto"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Método"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Referencia"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.09; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.agricultor; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true }
                                Text { width: parent.width * 0.22; height: parent.height; text: modelData.concepto; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: monedaSeleccionada + " " + modelData.monto.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#2E7D32" }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.metodo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 80
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: modelData.estado === "Confirmado" ? "#E8F5E8" : 
                                               modelData.estado === "Pendiente" ? "#FFF3E0" : "#FFEBEE"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.estado
                                            font.pixelSize: 11
                                            color: modelData.estado === "Confirmado" ? "#2E7D32" : 
                                                   modelData.estado === "Pendiente" ? "#F57C00" : "#C62828"
                                        }
                                    }
                                }
                                
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.referencia; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; color: "#0288D1" }
                                
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
                                            onClicked: console.log("Editar pago", modelData.id)
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
                                            onClicked: console.log("Eliminar pago", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador para Pagos a Agricultores
                Paginator {
                    id: paginadorPagos
                    width: parent.width
                    height: 40
                    currentPage: paginaActualPagos
                    totalPages: totalPaginasPagos
                    
                    onPageChanged: {
                        paginaActualPagos = newPage
                    }
                }
            }
        }
        
        // ============================================
        // CONTENIDO DE COMBUSTIBLE Y MAQUINARIA (ÍNDICE 3)
        // ============================================
        Item {
            anchors.fill: parent
            visible: tabActiva === 3
            opacity: tabActiva === 3 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            Column {
                anchors.fill: parent
                spacing: 15
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderCombustible
                    width: parent.width
                    height: 60
                    buttonText: "Registrar Combustible"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#2196F3"
                    searchPlaceholder: "Buscar combustible..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: ["Todos", "Diésel", "Gasolina", "Gas"]
                    filterPlaceholder: "Tipo..."
                    filterWidth: 140
                    
                    onButtonClicked: {
                        console.log("Registrar nuevo combustible")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar combustible:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por tipo:", filterOptions[index])
                    }
                }
                
                // Tabs secundarias
                Rectangle {
                    id: subTabContainer
                    width: parent.width
                    height: 45
                    color: "transparent"
                    
                    property int subTabActiva: 0
                    
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        
                        Repeater {
                            model: ["Compras de Combustible", "Uso de Maquinaria", "Mantenimientos"]
                            
                            Rectangle {
                                width: 180
                                height: 35
                                radius: 18
                                color: subTabContainer.subTabActiva === index ? "#2196F3" : "transparent"
                                border.color: subTabContainer.subTabActiva === index ? "#2196F3" : "#CCCCCC"
                                border.width: 1
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 12
                                    font.bold: subTabContainer.subTabActiva === index
                                    color: subTabContainer.subTabActiva === index ? "white" : "#666666"
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        subTabContainer.subTabActiva = index
                                        paginaActualCombustible = 1
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Tabla de datos
                Rectangle {
                    width: parent.width
                    height: parent.height - 170
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: subTabContainer.subTabActiva === 0 ? comprasCombustible : 
                               subTabContainer.subTabActiva === 1 ? usoMaquinaria : mantenimientos
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                visible: parent.parent.parent.parent.parent.parent.subTabActiva === 0
                                
                                Text { width: parent.width * 0.12; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Cantidad"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Precio Unit."; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Total"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.25; height: parent.height; text: "Proveedor"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                            
                            Row {
                                anchors.fill: parent
                                visible: parent.parent.parent.parent.parent.parent.subTabActiva === 1
                                
                                Text { width: parent.width * 0.1; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.2; height: parent.height; text: "Maquinaria"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Usuario"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.2; height: parent.height; text: "Actividad"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Combustible (L)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Costo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.13; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                            
                            Row {
                                anchors.fill: parent
                                visible: parent.parent.parent.parent.parent.parent.subTabActiva === 2
                                
                                Text { width: parent.width * 0.1; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.2; height: parent.height; text: "Maquinaria"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.25; height: parent.height; text: "Descripción"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Costo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
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
                                visible: parent.parent.parent.parent.parent.parent.subTabActiva === 0
                                
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.fecha || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.tipo || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: (modelData.cantidad || 0) + " " + (modelData.unidad || ""); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: monedaSeleccionada + " " + (modelData.precio_unitario || 0).toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: monedaSeleccionada + " " + (modelData.total || 0).toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#2E7D32" }
                                Text { width: parent.width * 0.25; height: parent.height; text: modelData.proveedor || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
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
                                            onClicked: console.log("Editar combustible", modelData.id)
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
                                            onClicked: console.log("Eliminar combustible", modelData.id)
                                        }
                                    }
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                visible: parent.parent.parent.parent.parent.parent.subTabActiva === 1
                                
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.fecha || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.2; height: parent.height; text: modelData.maquinaria || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.usuario || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.2; height: parent.height; text: modelData.actividad || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: (modelData.combustible || 0).toFixed(1); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: monedaSeleccionada + " " + (modelData.costo || 0).toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#2E7D32" }
                                
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
                                            onClicked: console.log("Editar uso", modelData.id)
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
                                            onClicked: console.log("Eliminar uso", modelData.id)
                                        }
                                    }
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                visible: parent.parent.parent.parent.parent.parent.subTabActiva === 2
                                
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.fecha || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.2; height: parent.height; text: modelData.maquinaria || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.tipo || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.25; height: parent.height; text: modelData.descripcion || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: monedaSeleccionada + " " + (modelData.costo || 0).toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#2E7D32" }
                                
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 80
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: modelData.estado === "Completado" ? "#E8F5E8" : "#FFF3E0"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.estado || ""
                                            font.pixelSize: 11
                                            color: modelData.estado === "Completado" ? "#2E7D32" : "#F57C00"
                                        }
                                    }
                                }
                                
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
                                            onClicked: console.log("Editar mantenimiento", modelData.id)
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
                                            onClicked: console.log("Eliminar mantenimiento", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador para Combustible y Maquinaria
                Paginator {
                    id: paginadorCombustible
                    width: parent.width
                    height: 40
                    currentPage: paginaActualCombustible
                    totalPages: totalPaginasCombustible
                    
                    onPageChanged: {
                        paginaActualCombustible = newPage
                    }
                }
            }
        }
        
        // ============================================
        // CONTENIDO DE INVENTARIO AGROQUÍMICOS (ÍNDICE 4)
        // ============================================
        Item {
            anchors.fill: parent
            visible: tabActiva === 4
            opacity: tabActiva === 4 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            Column {
                anchors.fill: parent
                spacing: 15
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderInventario
                    width: parent.width
                    height: 60
                    buttonText: "Agregar Producto"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#9C27B0"
                    searchPlaceholder: "Buscar producto..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: ["Todos", "Herbicida", "Fungicida", "Insecticida", "Fertilizante"]
                    filterPlaceholder: "Categoría..."
                    filterWidth: 150
                    
                    onButtonClicked: {
                        console.log("Agregar nuevo producto")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar producto:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por categoría:", filterOptions[index])
                    }
                }
                
                // Tabla de datos
                Rectangle {
                    width: parent.width
                    height: parent.height - 120
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: inventarioAgroquimicos
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.2; height: parent.height; text: "Producto"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Categoría"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Stock"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Unidad"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Precio Unit."; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Valor Total"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
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
                                onEntered: parent.color = "#F3E5F5"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { width: parent.width * 0.2; height: parent.height; text: modelData.producto; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.categoria; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.stock.toFixed(1); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.unidad; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: monedaSeleccionada + " " + modelData.precio_unitario.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: monedaSeleccionada + " " + modelData.valor_total.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12; font.bold: true; color: "#2E7D32" }
                                
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 60
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: modelData.estado === "Normal" ? "#E8F5E8" : "#FFF3CD"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.estado
                                            font.pixelSize: 11
                                            color: modelData.estado === "Normal" ? "#2E7D32" : "#B8860B"
                                        }
                                    }
                                }
                                
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
                                            onClicked: console.log("Editar producto", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#F3E5F5" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/ojo.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Ver movimientos"
                                            onClicked: console.log("Ver movimientos", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador para Inventario Agroquímicos
                Paginator {
                    id: paginadorInventario
                    width: parent.width
                    height: 40
                    currentPage: paginaActualInventario
                    totalPages: totalPaginasInventario
                    
                    onPageChanged: {
                        paginaActualInventario = newPage
                    }
                }
            }
        }
    }
    
    // ============================================
    // DIÁLOGO DE REGISTRO DE MOVIMIENTOS
    // ============================================
    RegistroMovimientoDialog { 
        id: registroMovimientoDialog
    }
    
    // ============================================
    // CONEXIONES CON EL MODELO FINANZAS
    // ============================================
    Connections {
        target: typeof finanzasModel !== 'undefined' ? finanzasModel : null
        
        function onOperacionExitosa(message) {
            console.log("✅ Operación exitosa:", message)
            // Aquí podrías mostrar un Snackbar o notificación
        }
        
        function onErrorOcurrido(message) {
            console.error("❌ Error en finanzasModel:", message)
            // Aquí podrías mostrar una alerta o notificación de error
        }
        
        function onMovimientosActualizados() {
            console.log("📊 Movimientos actualizados en la vista")
        }
        
        function onBalanceCambiado() {
            console.log("💰 Balance actualizado en la vista")
        }
        
        function onCategoriasCargadas() {
            console.log("📂 Categorías cargadas en la vista")
        }
    }
}