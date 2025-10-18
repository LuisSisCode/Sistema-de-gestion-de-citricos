import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: gastosRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
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
    
    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"

        Text {
            text: "GESTIÓN DE GASTOS"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.centerIn: parent
        }
        
        // Selector de moneda
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            spacing: 10
            
            Text {
                text: "Moneda:"
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
                color: "#666666"
            }
            
            ComboBox {
                id: cmbMoneda
                width: 80
                height: 35
                model: monedas
                currentIndex: 0
                onCurrentTextChanged: {
                    monedaSeleccionada = currentText
                }
            }
        }
    }

    // Pestañas principales
    Rectangle {
        id: tabBar
        width: parent.width
        height: 50
        anchors.top: titleBar.bottom
        anchors.topMargin: 10
        color: "white"
        radius: 5
        border.color: "#EEEEEE"

        Row {
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: [
                    {"text": "Costos de Producción", "icon": "📊"},
                    {"text": "Pagos a Agricultores", "icon": "💰"},
                    {"text": "Combustible y Maquinaria", "icon": "⛽"},
                    {"text": "Inventario Agroquímicos", "icon": "🧪"}
                ]

                Rectangle {
                    width: tabBar.width / 4
                    height: parent.height
                    color: stackLayout.currentIndex === index ? "#f5922f" : "transparent"
                    radius: stackLayout.currentIndex === index ? 5 : 0

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: modelData.icon
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.text
                            font.pixelSize: 14
                            font.bold: stackLayout.currentIndex === index
                            color: stackLayout.currentIndex === index ? "white" : "#333333"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: stackLayout.currentIndex = index
                    }
                }
            }
        }
    }

    // Contenido de las pestañas
    StackLayout {
        id: stackLayout
        width: parent.width
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        currentIndex: 0

        // PESTAÑA 1: COSTOS DE PRODUCCIÓN
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Barra de acciones
            Rectangle {
                id: actionBarCostos
                width: parent.width
                height: 50
                color: "white"
                radius: 25
                border.color: "#EEEEEE"

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 20
                    spacing: 10

                    Button {
                        text: "Nuevo Costo"
                        icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                        implicitHeight: 36
                        background: Rectangle {
                            color: parent.hovered ? "#E65A00" : "#f5922f"
                            radius: height / 2
                        }
                        onClicked: console.log("Nuevo costo de producción")
                    }

                    ComboBox {
                        id: filtroCiclo
                        implicitWidth: 200
                        implicitHeight: 36
                        model: ["Filtrar por ciclo...", "Todos", "Ciclo Naranja 2025-A", "Ciclo Mandarina 2025-B"]
                        currentIndex: 0
                    }

                    ComboBox {
                        id: filtroCategoria
                        implicitWidth: 180
                        implicitHeight: 36
                        model: ["Filtrar por categoría...", "Todas"].concat(categoriasCostos)
                        currentIndex: 0
                    }

                    TextField {
                        id: txtBuscarCostos
                        placeholderText: "Buscar concepto..."
                        implicitWidth: 250
                        implicitHeight: 28
                        leftPadding: 30

                        background: Rectangle {
                            color: "#ffffff"
                            radius: height / 2
                            border.color: "#808080"
                            border.width: 1

                            Image {
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }
                                source: "Image/Image_UI_interfaz/Inconos/lupa.png"
                                width: 16
                                height: 16
                            }
                        }
                    }
                }
            }

            // Tabla de costos de producción
            Rectangle {
                anchors.top: actionBarCostos.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                ListView {
                    id: costosListView
                    anchors.fill: parent
                    anchors.margins: 1
                    clip: true
                    model: costosProduccion
                    headerPositioning: ListView.OverlayHeader

                    header: Rectangle {
                        width: parent.width
                        height: 40
                        color: "#F5F5F5"
                        z: 2

                        Row {
                            anchors.fill: parent

                            Text { width: parent.width * 0.08; height: parent.height; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.15; height: parent.height; text: "Ciclo"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.12; height: parent.height; text: "Parcela"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.12; height: parent.height; text: "Categoría"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.18; height: parent.height; text: "Concepto"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.08; height: parent.height; text: "Cantidad"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.09; height: parent.height; text: "Total (" + monedaSeleccionada + ")"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.08; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                        }
                    }

                    delegate: Rectangle {
                        width: costosListView.width
                        height: 50
                        color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                        Row {
                            anchors.fill: parent
                            spacing: 0

                            Text { width: parent.width * 0.08; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.15; height: parent.height; text: modelData.ciclo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.12; height: parent.height; text: modelData.parcela; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.12; height: parent.height; text: modelData.categoria; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.18; height: parent.height; text: modelData.concepto; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.08; height: parent.height; text: modelData.cantidad + " " + modelData.unidad; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.09; height: parent.height; text: modelData.total.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            
                            Rectangle {
                                width: parent.width * 0.08
                                height: parent.height
                                color: "transparent"

                                Row {
                                    spacing: 5
                                    anchors.centerIn: parent

                                    Button {
                                        width: 32; height: 32
                                        icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                        flat: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Editar"
                                        onClicked: console.log("Editar costo", modelData.id)
                                    }

                                    Button {
                                        width: 32; height: 32
                                        icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                        flat: true
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
        }

        // PESTAÑA 2: PAGOS A AGRICULTORES
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: actionBarPagos
                width: parent.width
                height: 50
                color: "white"
                radius: 25
                border.color: "#EEEEEE"

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 20
                    spacing: 10

                    Button {
                        text: "Nuevo Pago"
                        icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                        implicitHeight: 36
                        background: Rectangle {
                            color: parent.hovered ? "#E65A00" : "#f5922f"
                            radius: height / 2
                        }
                        onClicked: console.log("Nuevo pago")
                    }

                    ComboBox {
                        id: filtroEstadoPago
                        implicitWidth: 150
                        implicitHeight: 36
                        model: ["Estado del pago...", "Todos"].concat(estadosPago)
                        currentIndex: 0
                    }

                    ComboBox {
                        id: filtroMetodoPago
                        implicitWidth: 150
                        implicitHeight: 36
                        model: ["Método de pago...", "Todos"].concat(metodosPago)
                        currentIndex: 0
                    }

                    TextField {
                        id: txtBuscarPagos
                        placeholderText: "Buscar agricultor..."
                        implicitWidth: 250
                        implicitHeight: 28
                        leftPadding: 30

                        background: Rectangle {
                            color: "#ffffff"
                            radius: height / 2
                            border.color: "#808080"
                            border.width: 1

                            Image {
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }
                                source: "Image/Image_UI_interfaz/Inconos/lupa.png"
                                width: 16
                                height: 16
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: actionBarPagos.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                ListView {
                    id: pagosListView
                    anchors.fill: parent
                    anchors.margins: 1
                    clip: true
                    model: pagosAgricultores
                    headerPositioning: ListView.OverlayHeader

                    header: Rectangle {
                        width: parent.width
                        height: 40
                        color: "#F5F5F5"
                        z: 2

                        Row {
                            anchors.fill: parent

                            Text { width: parent.width * 0.1; height: parent.height; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.2; height: parent.height; text: "Agricultor"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.25; height: parent.height; text: "Concepto"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.12; height: parent.height; text: "Monto (" + monedaSeleccionada + ")"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.1; height: parent.height; text: "Método"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.1; height: parent.height; text: "Estado"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                            Text { width: parent.width * 0.13; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                        }
                    }

                    delegate: Rectangle {
                        width: pagosListView.width
                        height: 50
                        color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                        Row {
                            anchors.fill: parent
                            spacing: 0

                            Text { width: parent.width * 0.1; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.2; height: parent.height; text: modelData.agricultor; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.25; height: parent.height; text: modelData.concepto; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.12; height: parent.height; text: modelData.monto.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            Text { width: parent.width * 0.1; height: parent.height; text: modelData.metodo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                            
                            Rectangle {
                                width: parent.width * 0.1
                                height: parent.height
                                color: "transparent"
                                
                                Rectangle {
                                    width: 70
                                    height: 24
                                    radius: 12
                                    anchors.centerIn: parent
                                    color: modelData.estado === "Confirmado" ? "#E8F5E8" : 
                                           modelData.estado === "Pendiente" ? "#FFF3CD" : "#FADBD8"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.estado
                                        font.pixelSize: 12
                                        color: modelData.estado === "Confirmado" ? "#2E7D32" : 
                                               modelData.estado === "Pendiente" ? "#B8860B" : "#C0392B"
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
                                        icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                        flat: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Editar"
                                        onClicked: console.log("Editar pago", modelData.id)
                                    }

                                    Button {
                                        width: 32; height: 32
                                        icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                        flat: true
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
        }

        // PESTAÑA 3: COMBUSTIBLE Y MAQUINARIA
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Sub-pestañas para combustible y maquinaria
            Rectangle {
                id: subTabBar
                width: parent.width
                height: 40
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                Row {
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: [
                            {"text": "Compras Combustible", "icon": "🔸"},
                            {"text": "Uso Maquinaria", "icon": "🔸"},
                            {"text": "Mantenimientos", "icon": "🔸"}
                        ]

                        Rectangle {
                            width: subTabBar.width / 3
                            height: parent.height
                            color: subStackLayout.currentIndex === index ? "#E3F2FD" : "transparent"
                            radius: subStackLayout.currentIndex === index ? 5 : 0

                            Row {
                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.text
                                    font.pixelSize: 13
                                    font.bold: subStackLayout.currentIndex === index
                                    color: subStackLayout.currentIndex === index ? "#1976D2" : "#666666"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: subStackLayout.currentIndex = index
                            }
                        }
                    }
                }
            }

            StackLayout {
                id: subStackLayout
                width: parent.width
                anchors.top: subTabBar.bottom
                anchors.bottom: parent.bottom
                anchors.topMargin: 10
                currentIndex: 0

                // SUB-PESTAÑA: COMPRAS COMBUSTIBLE
                Item {
                    Rectangle {
                        id: actionBarCombustible
                        width: parent.width
                        height: 50
                        color: "white"
                        radius: 25
                        border.color: "#EEEEEE"

                        RowLayout {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 20
                            spacing: 10

                            Button {
                                text: "Nueva Compra"
                                icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                                implicitHeight: 36
                                background: Rectangle {
                                    color: parent.hovered ? "#E65A00" : "#f5922f"
                                    radius: height / 2
                                }
                                onClicked: console.log("Nueva compra de combustible")
                            }

                            ComboBox {
                                id: filtroTipoCombustible
                                implicitWidth: 180
                                implicitHeight: 36
                                model: ["Tipo de combustible...", "Todos"].concat(tiposCombustible)
                                currentIndex: 0
                            }
                        }
                    }

                    Rectangle {
                        anchors.top: actionBarCombustible.bottom
                        anchors.topMargin: 20
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        color: "white"
                        radius: 5
                        border.color: "#EEEEEE"

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 1
                            clip: true
                            model: comprasCombustible
                            headerPositioning: ListView.OverlayHeader

                            header: Rectangle {
                                width: parent.width
                                height: 40
                                color: "#F5F5F5"
                                z: 2

                                Row {
                                    anchors.fill: parent
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.15; height: parent.height; text: "Tipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Cantidad"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Precio Unit."; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Total (" + monedaSeleccionada + ")"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.25; height: parent.height; text: "Proveedor"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                }
                            }

                            delegate: Rectangle {
                                width: parent.width
                                height: 50
                                color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                                Row {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.tipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.cantidad + " " + modelData.unidad; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.precio_unitario.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.total.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.25; height: parent.height; text: modelData.proveedor; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }

                                    Rectangle {
                                        width: parent.width * 0.12
                                        height: parent.height
                                        color: "transparent"

                                        Row {
                                            spacing: 5
                                            anchors.centerIn: parent

                                            Button {
                                                width: 32; height: 32
                                                icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                                flat: true
                                                ToolTip.visible: hovered
                                                ToolTip.text: "Editar"
                                                onClicked: console.log("Editar compra combustible", modelData.id)
                                            }

                                            Button {
                                                width: 32; height: 32
                                                icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                                flat: true
                                                ToolTip.visible: hovered
                                                ToolTip.text: "Eliminar"
                                                onClicked: console.log("Eliminar compra combustible", modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // SUB-PESTAÑA: USO MAQUINARIA  
                Item {
                    Rectangle {
                        id: actionBarUso
                        width: parent.width
                        height: 50
                        color: "white"
                        radius: 25
                        border.color: "#EEEEEE"

                        RowLayout {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 20
                            spacing: 10

                            Button {
                                text: "Registrar Uso"
                                icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                                implicitHeight: 36
                                background: Rectangle {
                                    color: parent.hovered ? "#E65A00" : "#f5922f"
                                    radius: height / 2
                                }
                                onClicked: console.log("Registrar uso de maquinaria")
                            }
                        }
                    }

                    Rectangle {
                        anchors.top: actionBarUso.bottom
                        anchors.topMargin: 20
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        color: "white"
                        radius: 5
                        border.color: "#EEEEEE"

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 1
                            clip: true
                            model: usoMaquinaria
                            headerPositioning: ListView.OverlayHeader

                            header: Rectangle {
                                width: parent.width
                                height: 40
                                color: "#F5F5F5"
                                z: 2

                                Row {
                                    anchors.fill: parent
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.2; height: parent.height; text: "Maquinaria"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.15; height: parent.height; text: "Usuario"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.2; height: parent.height; text: "Actividad"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Combustible (L)"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.09; height: parent.height; text: "Costo (" + monedaSeleccionada + ")"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                }
                            }

                            delegate: Rectangle {
                                width: parent.width
                                height: 50
                                color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                                Row {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.2; height: parent.height; text: modelData.maquinaria; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.15; height: parent.height; text: modelData.usuario; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.2; height: parent.height; text: modelData.actividad; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.combustible.toFixed(1); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.09; height: parent.height; text: modelData.costo.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }

                                    Rectangle {
                                        width: parent.width * 0.12
                                        height: parent.height
                                        color: "transparent"

                                        Row {
                                            spacing: 5
                                            anchors.centerIn: parent

                                            Button {
                                                width: 32; height: 32
                                                icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                                flat: true
                                                ToolTip.visible: hovered
                                                ToolTip.text: "Editar"
                                                onClicked: console.log("Editar uso", modelData.id)
                                            }

                                            Button {
                                                width: 32; height: 32
                                                icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                                flat: true
                                                ToolTip.visible: hovered
                                                ToolTip.text: "Eliminar"
                                                onClicked: console.log("Eliminar uso", modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // SUB-PESTAÑA: MANTENIMIENTOS
                Item {
                    Rectangle {
                        id: actionBarMantenimiento
                        width: parent.width
                        height: 50
                        color: "white"
                        radius: 25
                        border.color: "#EEEEEE"

                        RowLayout {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 20
                            spacing: 10

                            Button {
                                text: "Nuevo Mantenimiento"
                                icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                                implicitHeight: 36
                                background: Rectangle {
                                    color: parent.hovered ? "#E65A00" : "#f5922f"
                                    radius: height / 2
                                }
                                onClicked: console.log("Nuevo mantenimiento")
                            }
                        }
                    }

                    Rectangle {
                        anchors.top: actionBarMantenimiento.bottom
                        anchors.topMargin: 20
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        color: "white"
                        radius: 5
                        border.color: "#EEEEEE"

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 1
                            clip: true
                            model: mantenimientos
                            headerPositioning: ListView.OverlayHeader

                            header: Rectangle {
                                width: parent.width
                                height: 40
                                color: "#F5F5F5"
                                z: 2

                                Row {
                                    anchors.fill: parent
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Fecha"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.2; height: parent.height; text: "Maquinaria"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Tipo"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.25; height: parent.height; text: "Descripción"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.12; height: parent.height; text: "Costo (" + monedaSeleccionada + ")"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.09; height: parent.height; text: "Estado"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                    Text { width: parent.width * 0.1; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                                }
                            }

                            delegate: Rectangle {
                                width: parent.width
                                height: 50
                                color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                                Row {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.2; height: parent.height; text: modelData.maquinaria; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.tipo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.25; height: parent.height; text: modelData.descripcion; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.12; height: parent.height; text: modelData.costo.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                    
                                    Rectangle {
                                        width: parent.width * 0.09
                                        height: parent.height
                                        color: "transparent"
                                        
                                        Rectangle {
                                            width: 80
                                            height: 24
                                            radius: 12
                                            anchors.centerIn: parent
                                            color: modelData.estado === "Completado" ? "#E8F5E8" : "#FFF3CD"
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.estado
                                                font.pixelSize: 11
                                                color: modelData.estado === "Completado" ? "#2E7D32" : "#B8860B"
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width * 0.1
                                        height: parent.height
                                        color: "transparent"

                                        Row {
                                            spacing: 5
                                            anchors.centerIn: parent

                                            Button {
                                                width: 32; height: 32
                                                icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                                flat: true
                                                ToolTip.visible: hovered
                                                ToolTip.text: "Editar"
                                                onClicked: console.log("Editar mantenimiento", modelData.id)
                                            }

                                            Button {
                                                width: 32; height: 32
                                                icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                                flat: true
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
                }
            }
        }

        // PESTAÑA 4: INVENTARIO AGROQUÍMICOS
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                width: parent.width
                spacing: 20

                // Cards de resumen
                Row {
                    width: parent.width
                    spacing: 20

                    Rectangle {
                        width: (parent.width - 40) / 3
                        height: 80
                        color: "#E3F2FD"
                        radius: 8
                        border.color: "#BBDEFB"

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: "Total en Stock"
                                font.pixelSize: 14
                                color: "#1976D2"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: inventarioAgroquimicos.length + " productos"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#0D47A1"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 40) / 3
                        height: 80
                        color: "#FFF3E0"
                        radius: 8
                        border.color: "#FFCC80"

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: "Stock Bajo"
                                font.pixelSize: 14
                                color: "#F57C00"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: {
                                    var count = 0
                                    for (var i = 0; i < inventarioAgroquimicos.length; i++) {
                                        if (inventarioAgroquimicos[i].estado === "Bajo") count++
                                    }
                                    return count + " productos"
                                }
                                font.pixelSize: 18
                                font.bold: true
                                color: "#E65100"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 40) / 3
                        height: 80
                        color: "#E8F5E8"
                        radius: 8
                        border.color: "#A5D6A7"

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: "Valor Total"
                                font.pixelSize: 14
                                color: "#388E3C"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: {
                                    var total = 0
                                    for (var i = 0; i < inventarioAgroquimicos.length; i++) {
                                        total += inventarioAgroquimicos[i].valor_total
                                    }
                                    return total.toFixed(2) + " " + monedaSeleccionada
                                }
                                font.pixelSize: 18
                                font.bold: true
                                color: "#1B5E20"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                Rectangle {
                    id: actionBarInventario
                    width: parent.width
                    height: 50
                    color: "white"
                    radius: 25
                    border.color: "#EEEEEE"

                    RowLayout {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 20
                        spacing: 10

                        Button {
                            text: "Agregar Producto"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: height / 2
                            }
                            onClicked: console.log("Agregar producto agroquímico")
                        }

                        Button {
                            text: "Registrar Movimiento"
                            icon.source: "Image/Image_UI_interfaz/Inconos/telefono-inteligente-para-transferir-dinero.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#1976D2" : "#2196F3"
                                radius: height / 2
                            }
                            onClicked: console.log("Registrar movimiento de inventario")
                        }

                        TextField {
                            id: txtBuscarInventario
                            placeholderText: "Buscar producto..."
                            implicitWidth: 250
                            implicitHeight: 28
                            leftPadding: 30

                            background: Rectangle {
                                color: "#ffffff"
                                radius: height / 2
                                border.color: "#808080"
                                border.width: 1

                                Image {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: "Image/Image_UI_interfaz/Inconos/lupa.png"
                                    width: 16
                                    height: 16
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: gastosRoot.height - 360 // Ajustar según el espacio disponible
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: inventarioAgroquimicos
                        headerPositioning: ListView.OverlayHeader

                        header: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#F5F5F5"
                            z: 2

                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.2; height: parent.height; text: "Producto"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Categoría"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Stock"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Unidad"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Precio Unit."; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Valor Total"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Estado"; font.bold: true; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Acciones"; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                            }
                        }

                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                            Row {
                                anchors.fill: parent
                                spacing: 0

                                Text { width: parent.width * 0.2; height: parent.height; text: modelData.producto; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.categoria; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.stock.toFixed(1); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.unidad; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.precio_unitario.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.valor_total.toFixed(2); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight }
                                
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
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar producto", modelData.id)
                                        }

                                        Button {
                                            width: 32; height: 32
                                            icon.source: "Image/Image_UI_interfaz/Inconos/ojo.svg"
                                            flat: true
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
            }
        }
    }
}