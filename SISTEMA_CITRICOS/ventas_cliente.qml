import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: ventasClientesRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // Propiedades para edición de ventas
    property bool mostrarFilaEdicionVenta: false
    property var nuevaVenta: {
        "ventaId": "",
        "codigo": "",
        "fecha": "",
        "cliente": "",
        "total": 0,
        "estado": "Pendiente"
    }
    
    // Propiedades para edición de clientes
    property bool mostrarNuevoCliente: false
    property var nuevoCliente: {
        "clienteId": "",
        "tipo": "Persona",
        "nombre": "",
        "identificacion": "",
        "telefono": "",
        "ciudad": "",
        "totalCompras": 0,
        "pendiente": 0
    }

    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "GESTIÓN DE VENTAS Y CARTERAS DE CLIENTES"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.centerIn: parent
        }
    }

    // Contenido principal con pestañas
    TabBar {
        id: tabBar
        width: parent.width
        anchors.top: titleBar.bottom
        spacing: 20
        background: Rectangle {
            color: "white"
            Rectangle {
                width: parent.width
                height: 1
                color: "#EEEEEE"
                anchors.bottom: parent.bottom
            }
        }

        TabButton {
            text: "Ventas"
            width: implicitWidth + 40
            height: 30
            background: Rectangle {
                color: parent.checked ? "#32CD32":"#4CAF50"
                radius: height / 2
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        TabButton {
            text: "Clientes"
            width: implicitWidth + 40
            height: 30
            background: Rectangle {
                color: parent.checked ? "#32CD32":"#4CAF50"
                radius: height / 2
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        TabButton {
            text: "Estadísticas"
            width: implicitWidth + 40
            height: 30
            background: Rectangle {
                color: parent.checked ? "#32CD32":"#4CAF50"
                radius: height / 2
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Contenedor de páginas de pestañas
    StackLayout {
        width: parent.width
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        currentIndex: tabBar.currentIndex

        // Página de Ventas
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                
                // Panel de estadísticas de ventas (simplificado)
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Total de ventas del mes
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Ventas del Mes"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 0"
                                font.pixelSize: 22
                                font.bold: true
                            }
                            
                            Text {
                                text: "No hay datos comparativos"
                                font.pixelSize: 11
                                color: "#757575"
                            }
                        }
                        
                        // Ventas pendientes
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Pagos Pendientes"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 0"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#FF9800"
                            }
                            
                            Text {
                                text: "0 clientes"
                                font.pixelSize: 11
                                color: "#757575"
                            }
                        }
                        
                        // Ventas por cobrar vencidas
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Ventas Vencidas"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 0"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#F44336"
                            }
                            
                            Text {
                                text: "0 clientes"
                                font.pixelSize: 11
                                color: "#757575"
                            }
                        }
                        
                        // Cliente más importante
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Cliente Top"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Sin datos"
                                font.pixelSize: 18
                                font.bold: true
                            }
                            
                            Text {
                                text: "0% de las ventas"
                                font.pixelSize: 11
                                color: "#757575"
                            }
                        }
                    }
                }
                
                // Barra de acción
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "white"
                    radius: 25
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Button {
                            text: "Nueva Venta"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para la nueva venta
                                nuevaVenta = { 
                                    "ventaId": "", 
                                    "codigo": "V-" + (ventasModel.count + 1).toString().padStart(4, '0'),
                                    "fecha": Qt.formatDateTime(new Date(), "dd/MM/yyyy"),
                                    "cliente": "",
                                    "total": 0,
                                    "estado": "Pendiente"
                                }
                                
                                // Mostrar fila de edición
                                mostrarFilaEdicionVenta = true
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar venta por código o cliente..."
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los estados", "Pagada", "Pendiente", "Parcial", "Vencida"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        ComboBox {
                            Layout.preferredWidth: 150
                            model: ["Último mes", "Últimos 3 meses", "Último año", "Todas"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Exportar"
                            icon.source: "Image/Image_UI_interfaz/Inconos/exportacion-de-archivos.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: showMessage("Función de exportación no implementada")
                        }
                    }
                }
                
                // Tabla de ventas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: ventasListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ventasModel
                        headerPositioning: ListView.OverlayHeader
                        
                        // Cabecera de la tabla
                        header: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#F5F5F5"
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                
                                Text {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    text: "ID"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Código"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Fecha"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Cliente"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Total"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Estado"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: "Acciones"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                        
                        // Fila de edición para nueva venta
                        Rectangle {
                            id: filaEdicionVenta
                            width: parent.width
                            height: 50
                            color: "#F0F7FF"
                            visible: mostrarFilaEdicionVenta
                            z: 3
                            y: header.height
                            
                            Row {
                                anchors.fill: parent
                                
                                // ID
                                Rectangle {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Nuevo"
                                        font.italic: true
                                    }
                                }
                                
                                // Código
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    TextField {
                                        id: txtCodigo
                                        width: parent.width - 10
                                        height: 36
                                        anchors.centerIn: parent
                                        text: nuevaVenta.codigo
                                        readOnly: true
                                    }
                                }
                                
                                // Fecha
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    TextField {
                                        id: txtFecha
                                        width: parent.width - 10
                                        height: 36
                                        anchors.centerIn: parent
                                        text: nuevaVenta.fecha
                                        readOnly: true
                                    }
                                }
                                
                                // Cliente
                                Rectangle {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    color: "transparent"
                                    
                                    ComboBox {
                                        id: cmbCliente
                                        width: parent.width - 10
                                        height: 36
                                        anchors.centerIn: parent
                                        model: ["Seleccione cliente"]
                                        onCurrentTextChanged: if (currentIndex > 0) nuevaVenta.cliente = currentText
                                    }
                                }
                                
                                // Total
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    TextField {
                                        id: txtTotal
                                        width: parent.width - 10
                                        height: 36
                                        anchors.centerIn: parent
                                        placeholderText: "0.00"
                                        validator: DoubleValidator { bottom: 0 }
                                        onTextChanged: nuevaVenta.total = parseFloat(text) || 0
                                        Keys.onReturnPressed: guardarNuevaVenta()
                                    }
                                }
                                
                                // Estado
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    ComboBox {
                                        id: cmbEstado
                                        width: parent.width - 10
                                        height: 36
                                        anchors.centerIn: parent
                                        model: ["Pendiente", "Parcial", "Pagada"]
                                        onCurrentTextChanged: nuevaVenta.estado = currentText
                                    }
                                }
                                
                                // Acciones
                                Rectangle {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 10
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/guardar.svg"
                                            icon.color: "white"
                                            background: Rectangle {
                                                color: "#4CAF50"
                                                radius: width / 2
                                            }
                                            onClicked: guardarNuevaVenta()
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Guardar"
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                            icon.color: "white"
                                            background: Rectangle {
                                                color: "#F44336"
                                                radius: width / 2
                                            }
                                            onClicked: mostrarFilaEdicionVenta = false
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Cancelar"
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Delegado para cada fila (CORREGIDO)
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"
                            
                            // Usamos Row con Rectangles para cada columna
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                // ID
                                Rectangle {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: ventaId || id
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Código
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: codigo
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Fecha
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: fecha
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Cliente
                                Rectangle {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: cliente
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Total
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: "Bs. " + total
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Estado
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 80
                                        height: 24
                                        radius: 12
                                        color: getEstadoColor(estado)
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: estado
                                            font.pixelSize: 12
                                            color: "white"
                                        }
                                    }
                                }
                                
                                // Acciones
                                Rectangle {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 10
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 80
                                            height: 30
                                            text: "Ver"
                                            icon.source: "Image/Image_UI_interfaz/Inconos/ojos.svg"
                                            flat: true
                                            onClicked: showMessage("Función para ver detalles no implementada")
                                        }
                                        
                                        Button {
                                            width: 80
                                            height: 30
                                            text: "Imprimir"
                                            icon.source: "Image/Image_UI_interfaz/Inconos/imprimir.svg"
                                            flat: true
                                            onClicked: showMessage("Función para imprimir no implementada")
                                        }
                                        
                                        Button {
                                            width: 80
                                            height: 30
                                            text: "Pago"
                                            visible: estado !== "Pagada"
                                            icon.source: "Image/Image_UI_interfaz/Inconos/gastos.svg"
                                            flat: true
                                            onClicked: showMessage("Función para registrar pago no implementada")
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay ventas registradas.\nHaga clic en 'Nueva Venta' para agregar una."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: ventasModel.count === 0 && !mostrarFilaEdicionVenta
                        }
                    }
                }
            }
        }

        // Página de Clientes
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                
                // Barra de acción
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "white"
                    radius: 25
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Button {
                            text: "Nuevo Cliente"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar-usuario.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para el nuevo cliente
                                nuevoCliente = {
                                    "clienteId": "",
                                    "tipo": "Persona",
                                    "nombre": "",
                                    "identificacion": "",
                                    "telefono": "",
                                    "ciudad": "",
                                    "totalCompras": 0,
                                    "pendiente": 0
                                }
                                
                                // Mostrar modal para nuevo cliente (simplificado)
                                mostrarNuevoCliente = true
                                showMessage("Función para crear nuevo cliente no implementada")
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar cliente..."
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los tipos", "Persona", "Empresa"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Importar"
                            icon.source: "Image/Image_UI_interfaz/Inconos/abajo-a-la-linea.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: showMessage("Función de importación no implementada")
                        }
                    }
                }
                
                // Grid de tarjetas de clientes
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    GridView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: clientesModel
                        cellWidth: width / 3
                        cellHeight: 200
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay clientes registrados.\nHaga clic en 'Nuevo Cliente' para agregar uno."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: clientesModel.count === 0
                        }
                        
                        delegate: Rectangle {
                            width: GridView.view.cellWidth - 20
                            height: GridView.view.cellHeight - 20
                            color: "white"
                            radius: 5
                            border.color: "#EEEEEE"
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 8
                                
                                // Cabecera con tipo y estado
                                RowLayout {
                                    Layout.fillWidth: true
                                    
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: tipo === "Empresa" ? "#2E7D32" : "#2196F3"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: tipo === "Empresa" ? "E" : "P"
                                            color: "white"
                                            font.bold: true
                                        }
                                    }
                                    
                                    Text {
                                        text: nombre
                                        font.pixelSize: 16
                                        font.bold: true
                                        Layout.fillWidth: true
                                    }
                                    
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: pendiente > 0 ? "#FF9800" : "#4CAF50"
                                    }
                                }
                                
                                // Identificación
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    
                                    Text {
                                        text: "ID/RIF:"
                                        font.pixelSize: 12
                                        color: "#757575"
                                    }
                                    
                                    Text {
                                        text: identificacion
                                        font.pixelSize: 12
                                    }
                                }
                                
                                // Contacto
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    
                                    Text {
                                        text: "Contacto:"
                                        font.pixelSize: 12
                                        color: "#757575"
                                    }
                                    
                                    Text {
                                        text: telefono
                                        font.pixelSize: 12
                                    }
                                }
                                
                                // Dirección
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    
                                    Text {
                                        text: "Ubicación:"
                                        font.pixelSize: 12
                                        color: "#757575"
                                    }
                                    
                                    Text {
                                        text: ciudad
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                                
                                // Separador
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: "#EEEEEE"
                                }
                                
                                // Estadísticas del cliente
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    
                                    // Total de compras
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        
                                        Text {
                                            text: "Total Compras"
                                            font.pixelSize: 10
                                            color: "#757575"
                                            horizontalAlignment: Text.AlignHCenter
                                            Layout.fillWidth: true
                                        }
                                        
                                        Text {
                                            text: "Bs. " + totalCompras
                                            font.pixelSize: 14
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            Layout.fillWidth: true
                                        }
                                    }
                                    
                                    // Saldo pendiente
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        
                                        Text {
                                            text: "Pendiente"
                                            font.pixelSize: 10
                                            color: "#757575"
                                            horizontalAlignment: Text.AlignHCenter
                                            Layout.fillWidth: true
                                        }
                                        
                                        Text {
                                            text: "Bs. " + pendiente
                                            font.pixelSize: 14
                                            font.bold: pendiente > 0
                                            color: pendiente > 0 ? "#FF9800" : "#4CAF50"
                                            horizontalAlignment: Text.AlignHCenter
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                                
                                // Botones de acción
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    
                                    Button {
                                        text: "Ver Detalle"
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        font.pixelSize: 12
                                        onClicked: showMessage("Función para ver detalle no implementada")
                                    }
                                    
                                    Button {
                                        text: "Nueva Venta"
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        font.pixelSize: 12
                                        onClicked: showMessage("Función para crear nueva venta no implementada")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Página de Estadísticas
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                
                // Filtros y controles
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "white"
                    radius: 25
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Período:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Último mes", "Último trimestre", "Último año", "Personalizado"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Producto:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los productos", "Limón", "Naranja", "Mandarina", "Toronja", "Lima"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Generar Reporte"
                            icon.source: "Image/Image_UI_interfaz/Inconos/comercio.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: showMessage("Función para generar reporte no implementada")
                        }
                    }
                }
                
                // Mensaje cuando no hay datos estadísticos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 15
                        
                        Text {
                            text: "No hay suficientes datos para mostrar estadísticas"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Las estadísticas serán generadas cuando se registren ventas en el sistema."
                            font.pixelSize: 14
                            color: "#757575"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Button {
                            text: "Ir a Ventas"
                            icon.source: "Image/Image_UI_interfaz/Inconos/siguiente.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: tabBar.currentIndex = 0
                        }
                    }
                }
            }
        }
    }
    
    // Función para guardar nueva venta
    function guardarNuevaVenta() {
        // Validar datos
        if (txtTotal.text.trim() === "" || parseFloat(txtTotal.text) <= 0) {
            showMessage("Por favor, ingrese un monto válido mayor a cero")
            return
        }
        
        if (cmbCliente.currentIndex === 0) {
            showMessage("Por favor, seleccione un cliente")
            return
        }
        
        // Añadir al modelo
        ventasModel.append({
            ventaId: ventasModel.count + 1,
            codigo: nuevaVenta.codigo,
            fecha: nuevaVenta.fecha,
            cliente: nuevaVenta.cliente,
            total: nuevaVenta.total,
            estado: nuevaVenta.estado
        })
        
        // Ocultar fila de edición
        mostrarFilaEdicionVenta = false
        
        // Mensaje de éxito
        showMessage("Venta registrada correctamente")
        
        // NOTA: Aquí es donde conectarías con tu base de datos en el futuro
        // Por ejemplo:
        // dbConnection.insertVenta(nuevaVenta.codigo, nuevaVenta.fecha, 
        //                          nuevaVenta.cliente, nuevaVenta.total,
        //                          nuevaVenta.estado)
    }
    
    // Función para determinar el color de estado
    function getEstadoColor(estado) {
        switch (estado) {
            case "Pagada":
                return "#4CAF50";
            case "Pendiente":
                return "#FF9800";
            case "Parcial":
                return "#2196F3";
            case "Vencida":
                return "#F44336";
            default:
                return "#757575";
        }
    }
    
    // Modelos de datos vacíos
    ListModel {
        id: ventasModel
        // Se agregarán elementos cuando el usuario los cree
    }

    ListModel {
        id: clientesModel
        // Se agregarán elementos cuando el usuario los cree
    }
    
    // Componente para mostrar mensajes
    Rectangle {
        id: messageToast
        width: messageText.width + 40
        height: 40
        radius: 20
        color: "#333333"
        opacity: 0.9
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        z: 1000
        
        Text {
            id: messageText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 14
            text: ""
        }
        
        property string text: ""
        onTextChanged: messageText.text = text
        
        Timer {
            id: messageToastTimer
            interval: 3000
            onTriggered: messageToast.visible = false
        }
    }
    
    // Función para mostrar mensajes
    function showMessage(message) {
        messageToast.text = message
        messageToast.visible = true
        messageToastTimer.restart()
    }

    Dialog {
        id: dialogNuevoCliente
        title: "Nuevo Cliente"
        modal: true
        anchors.centerIn: parent
        width: parent.width * 0.6
        height: parent.height * 0.7
        visible: mostrarNuevoCliente

        onClosed: mostrarNuevoCliente = false

        contentItem: Rectangle {
            color: "white"

            Column {
                anchors {
                    fill: parent
                    margins: 20
                }
                spacing: 15

                Text {
                    width: parent.width
                    text: "Ingrese los datos del nuevo cliente"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                // Formulario
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 15

                    // Nombre completo
                    Text {
                        text: "Nombre completo:"
                        Layout.alignment: Qt.AlignRight
                    }

                    TextField {
                        id: txtNombre
                        placeholderText: "Ingrese nombre completo"
                        Layout.fillWidth: true
                    }

                    // Cédula de identidad
                    Text {
                        text: "Cédula de identidad:"
                        Layout.alignment: Qt.AlignRight
                    }

                    TextField {
                        id: txtCedula
                        placeholderText: "Ingrese cédula de identidad"
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 0 }
                    }

                    // Celular
                    Text {
                        text: "Celular:"
                        Layout.alignment: Qt.AlignRight
                    }

                    TextField {
                        id: txtCelular
                        placeholderText: "Ingrese número de celular"
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 0 }
                    }

                    // Correo electrónico
                    Text {
                        text: "Correo electrónico:"
                        Layout.alignment: Qt.AlignRight
                    }

                    TextField {
                        id: txtCorreo
                        placeholderText: "Ingrese correo electrónico"
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhEmailCharactersOnly
                    }

                    // Fecha de creación
                    Text {
                        text: "Fecha de creación:"
                        Layout.alignment: Qt.AlignRight
                    }

                    TextField {
                        id: txtFechaa
                        placeholderText: "DD/MM/AAAA"
                        Layout.fillWidth: true
                        readOnly: true
                        text: getFormattedDate() // Llamamos a la función para obtener la fecha formateada
                    }

                    // Función para formatear la fecha
                    function getFormattedDate() {
                        var today = new Date();
                        var dd = String(today.getDate()).padStart(2, '0');
                        var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
                        var yyyy = today.getFullYear();
                        return dd + '/' + mm + '/' + yyyy;
                    }
                }

                // Espacio adicional
                Item {
                    width: parent.width
                    height: 20
                }

                // Mensaje de validación
                Text {
                    id: mensajeValidacion
                    width: parent.width
                    text: ""
                    color: "red"
                    visible: text !== ""
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: dialogNuevoCliente.close()
            }

            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                onClicked: {
                    // Validación de campos obligatorios
                    if (txtNombre.text === "" || txtCedula.text === "" || txtCelular.text === "" || txtCorreo.text === "") {
                        mensajeValidacion.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }

                    // Validación de formato de correo electrónico
                    var emailRegex = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
                    if (!emailRegex.test(txtCorreo.text)) {
                        mensajeValidacion.text = "El formato del correo electrónico no es válido";
                        return;
                    }

                    // Aquí iría la lógica para guardar el cliente en la base de datos
                    var nuevoCliente = {
                        nombreCompleto: txtNombre.text,
                        cedula: txtCedula.text,
                        celular: txtCelular.text,
                        correo: txtCorreo.text,
                        fechaCreacion: txtFecha.text
                    };

                    console.log("Guardando cliente:", JSON.stringify(nuevoCliente));

                    // Mensaje de éxito y cierre del diálogo
                    showMessage("Cliente guardado exitosamente");
                    dialogNuevoCliente.close();
                }
            }
        }
    }
}