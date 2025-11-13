import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: gastosRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // Estado para controlar la pestaña activa
    property int tabActiva: 1
    property var tabsInfo: [
        {"text": "Costos de Producción", "icon": "recursos/image/icons/costoproduccion.png", "color": "#FF9800"},
        {"text": "Pagos a Agricultores", "icon": "recursos/image/icons/pagosagricultures.png", "color": "#4CAF50"},
        {"text": "Combustible y Maquinaria", "icon": "recursos/image/icons/combustible.png", "color": "#2196F3"},
        {"text": "Inventario Agroquímicos", "icon": "recursos/image/icons/inventario.png", "color": "#9C27B0"}
    ]
    
    // Propiedades para manejar datos dinámicos
    property var costosProduccion: [
        {
            "id": 1, "fecha": "15/07/2025", "ciclo": "Ciclo Naranja 2025-A", "parcela": "Parcela Norte", 
            "categoria": "Semillas", "concepto": "Semillas de naranja valencia", "cantidad": 50, 
            "unidad": "Kg", "costo_unitario": 25.00, "total": 1250.00, "comprobante": "FAC-001"
        },
        {
            "id": 2, "fecha": "16/07/2025", "ciclo": "Ciclo Mandarina 2025-B", "parcela": "Parcela Sur", 
            "categoria": "Fertilizantes", "concepto": "Fertilizante NPK", "cantidad": 100, 
            "unidad": "Kg", "costo_unitario": 15.50, "total": 1550.00, "comprobante": "FAC-002"
        },
        {
            "id": 3, "fecha": "17/07/2025", "ciclo": "Ciclo Naranja 2025-A", "parcela": "Parcela Este", 
            "categoria": "Mano de Obra", "concepto": "Jornales de siembra", "cantidad": 8, 
            "unidad": "Días", "costo_unitario": 120.00, "total": 960.00, "comprobante": "REC-003"
        }
    ]
    
    property var pagosAgricultores: [
        {
            "id": 1, "fecha": "10/07/2025", "agricultor": "Juan Pérez", "concepto": "Pago cosecha naranja", 
            "monto": 2500.00, "metodo": "Efectivo", "estado": "Confirmado", "referencia": "PAG-001"
        },
        {
            "id": 2, "fecha": "12/07/2025", "agricultor": "María González", "concepto": "Anticipo siembra", 
            "monto": 1800.00, "metodo": "Transferencia", "estado": "Pendiente", "referencia": "PAG-002"
        },
        {
            "id": 3, "fecha": "14/07/2025", "agricultor": "Carlos Mendoza", "concepto": "Pago por mantenimiento", 
            "monto": 950.00, "metodo": "Cheque", "estado": "Confirmado", "referencia": "PAG-003"
        }
    ]
    
    property var comprasCombustible: [
        {
            "id": 1, "fecha": "08/07/2025", "tipo": "Diésel", "cantidad": 200, "unidad": "L", 
            "precio_unitario": 3.74, "total": 748.00, "proveedor": "Estación El Sol"
        },
        {
            "id": 2, "fecha": "11/07/2025", "tipo": "Gasolina", "cantidad": 150, "unidad": "L", 
            "precio_unitario": 3.72, "total": 558.00, "proveedor": "Petrobras"
        }
    ]
    
    property var usoMaquinaria: [
        {
            "id": 1, "fecha": "09/07/2025", "maquinaria": "Tractor John Deere", "usuario": "Pedro Ramos", 
            "actividad": "Arado de terreno", "combustible": 45.5, "costo": 170.27
        },
        {
            "id": 2, "fecha": "13/07/2025", "maquinaria": "Cosechadora", "usuario": "Ana Silva", 
            "actividad": "Cosecha de naranja", "combustible": 78.2, "costo": 292.45
        }
    ]
    
    property var mantenimientos: [
        {
            "id": 1, "fecha": "05/07/2025", "maquinaria": "Tractor John Deere", "tipo": "Preventivo", 
            "descripcion": "Cambio de aceite y filtros", "costo": 450.00, "estado": "Completado"
        },
        {
            "id": 2, "fecha": "15/07/2025", "maquinaria": "Bomba de agua", "tipo": "Correctivo", 
            "descripcion": "Reparación de motor", "costo": 680.00, "estado": "Programado"
        }
    ]
    
    property var inventarioAgroquimicos: [
        {
            "id": 1, "producto": "Roundup", "categoria": "Herbicida", "stock": 25.5, "unidad": "L", 
            "precio_unitario": 45.00, "valor_total": 1147.50, "estado": "Normal"
        },
        {
            "id": 2, "producto": "Fungicida Copper", "categoria": "Fungicida", "stock": 8.2, "unidad": "Kg", 
            "precio_unitario": 35.80, "valor_total": 293.56, "estado": "Bajo"
        },
        {
            "id": 3, "producto": "Insecticida BT", "categoria": "Insecticida", "stock": 45.0, "unidad": "L", 
            "precio_unitario": 28.50, "valor_total": 1282.50, "estado": "Normal"
        }
    ]
    
    property var categoriasCostos: ["Semillas", "Fertilizantes", "Agroquímicos", "Mano de Obra", "Maquinaria", "Otros"]
    property var metodosPago: ["Efectivo", "Transferencia", "Cheque", "Depósito"]
    property var estadosPago: ["Pendiente", "Confirmado", "Rechazado"]
    property var tiposCombustible: ["Diésel", "Gasolina", "Gas"]
    property var monedas: ["BOB", "USD"]
    property string monedaSeleccionada: "BOB"
    
    // Propiedades para paginación
    property int paginaActualCostos: 1
    property int totalPaginasCostos: 5
    property int paginaActualPagos: 1
    property int totalPaginasPagos: 3
    property int paginaActualCombustible: 1
    property int totalPaginasCombustible: 4
    property int paginaActualInventario: 1
    property int totalPaginasInventario: 2
    
    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"
        anchors.top: parent.top
        
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20
            
            // Ícono principal
            Image {
                source: "recursos/image/icons/gastos.png"
                width: 45
                height: 45
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Column {
                anchors.verticalCenter: parent.verticalCenter
                
                Text {
                    text: "GESTIÓN DE GASTOS Y COSTOS"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#2E7D32"
                }
                
                Text {
                    text: "Control detallado de gastos operativos y costos de producción"
                    font.pixelSize: 12
                    color: "#666666"
                }
            }
        }
        
        // Selector de moneda
        Rectangle {
            width: 120
            height: 35
            radius: 8
            color: "#E8F5E9"
            border.color: "#4CAF50"
            border.width: 1
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            
            ComboBox {
                anchors.fill: parent
                model: monedas
                currentIndex: 0
                
                contentItem: Text {
                    text: parent.displayText
                    font.pixelSize: 13
                    font.bold: true
                    color: "#2E7D32"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
                
                background: Rectangle {
                    color: "transparent"
                }
                
                onActivated: {
                    monedaSeleccionada = monedas[index]
                }
            }
        }
    }
    
    // Barra de pestañas
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
            tabsData: gastosRoot.tabsInfo
            tabActiva: gastosRoot.tabActiva
            
            onTabChanged: function(index) {
                gastosRoot.tabActiva = index
                // Resetear páginas al cambiar de tab
                paginaActualCostos = 1
                paginaActualPagos = 1
                paginaActualCombustible = 1
                paginaActualInventario = 1
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
        
        // Contenido de Costos de Producción
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
                    height: 50
                    currentPage: paginaActualCostos
                    totalPages: totalPaginasCostos
                    
                    onPageChanged: {
                        paginaActualCostos = newPage
                    }
                }
            }
        }
        
        // Contenido de Pagos a Agricultores
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
                    height: 50
                    currentPage: paginaActualPagos
                    totalPages: totalPaginasPagos
                    
                    onPageChanged: {
                        paginaActualPagos = newPage
                    }
                }
            }
        }
        
        // Contenido de Combustible y Maquinaria
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
                    height: 50
                    currentPage: paginaActualCombustible
                    totalPages: totalPaginasCombustible
                    
                    onPageChanged: {
                        paginaActualCombustible = newPage
                    }
                }
            }
        }
        
        // Contenido de Inventario de Agroquímicos
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
                    height: 50
                    currentPage: paginaActualInventario
                    totalPages: totalPaginasInventario
                    
                    onPageChanged: {
                        paginaActualInventario = newPage
                    }
                }
            }
        }
    }
}
