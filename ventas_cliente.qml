import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: ventasClientesRoot
    anchors.fill: parent
    color: "#F8F9FA"

    // ============================================
    // MODELOS Y PROPIEDADES
    // ============================================
    property var ventaModel: ventaModel
    property var clientesModel: clientesModel

    // Variables para datos de resumen
    property string ventasDelMes: "Bs. 0"
    property string pagosPendientes: "Bs. 0"
    property string ventasVendidas: "Bs. 0"
    property string clienteTop: "Sin datos"
    property string porcentajeVentas: "0%"
    property string textoVentasDelMes: "No hay datos comparativos"
    property string textoPagosPendientes: "0 clientes"
    property string textoVentasVendidas: "0 clientes"
    property string textoPorcentajeVentas: "0% de las ventas"

    // Propiedades para pestañas
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Ventas", "icon": "recursos/image/icons/ventaa.png", "color": "#2E7D32"},
        {"text": "Clientes", "icon": "recursos/image/icons/clientes.png", "color": "#0288D1"}
    ]

    // Propiedades para filtros
    property var estadosVenta: ["Todos los estados", "Pagada", "Pendiente", "Parcial", "Vencida"]
    property var tiposCliente: ["Todos los tipos", "Persona", "Empresa"]
    property var periodosVentas: ["Último mes", "Últimos 3 meses", "Último año", "Todas"]
    
    // Propiedades para paginación
    property int paginaVentas: 1
    property int totalPaginasVentas: 1
    property int paginaClientes: 1
    property int totalPaginasClientes: 1

    // Propiedades para nueva venta
    property bool mostrarNuevaVenta: false
    property var nuevaVentaData: ({
        "codigo": "",
        "fecha": Qt.formatDate(new Date(), "dd/MM/yyyy"),
        "clienteId": -1,
        "clienteNombre": "",
        "productos": [],
        "total": 0,
        "estado": "Pendiente"
    })

    // Propiedades para nuevo cliente
    property var nuevoClienteData: ({
        "tipo": "Persona",
        "nombre": "",
        "identificacion": "",
        "telefono": "",
        "email": "",
        "direccion": "",
        "ciudad": ""
    })

    // ============================================
    // FUNCIONES PRINCIPALES
    // ============================================

    function cargarVentas() {
        console.log("Cargando ventas desde modelo...")
        var ventas = ventaModel.obtenerVentas()
        actualizarResumenVentas()
    }

    function cargarClientes() {
        console.log("Cargando clientes desde modelo...")
        var clientes = clientesModel.obtenerClientes()
    }

    function buscarVentas(termino) {
        if (termino.length === 0) {
            cargarVentas()
        } else if (termino.length >= 2) {
            var resultados = ventaModel.buscarVentas(termino)
        }
    }

    function filtrarVentasPorEstado(estado) {
        if (estado === "Todos los estados") {
            cargarVentas()
        } else {
            // Implementar filtrado por estado
            console.log("Filtrando ventas por estado:", estado)
        }
    }

    function actualizarResumenVentas() {
        try {
            var resumen = ventaModel.obtenerResumenMesActual()
            if (resumen) {
                ventasDelMes = "Bs. " + (resumen.ventas_mes || 0)
                pagosPendientes = "Bs. " + (resumen.pagos_pendientes || 0)
                ventasVendidas = "Bs. " + (resumen.ventas_vendidas || 0)
                porcentajeVentas = (resumen.porcentaje_ventas || 0) + "%"
                
                textoPagosPendientes = (resumen.cantidad_pendientes || 0) + " clientes"
                textoVentasVendidas = (resumen.cantidad_vendidas || 0) + " clientes"
                textoPorcentajeVentas = (resumen.porcentaje_ventas || 0) + "% de las ventas"
                
                clienteTop = resumen.cliente_top || "Sin datos"
            }
        } catch (e) {
            console.error("Error al actualizar resumen:", e)
        }
    }

    function abrirNuevaVenta() {
        nuevaVentaData = {
            "codigo": ventaModel.generarCodigoVenta(),
            "fecha": Qt.formatDate(new Date(), "dd/MM/yyyy"),
            "clienteId": -1,
            "clienteNombre": "",
            "productos": [],
            "total": 0,
            "estado": "Pendiente"
        }
        mostrarNuevaVenta = true
        // Agregar pestaña dinámica
        if (!tabsInfo.find(tab => tab.text === "Nueva Venta")) {
            tabsInfo.push({"text": "Nueva Venta", "icon": "recursos/image/icons/agregar.svg", "color": "#FF9800"})
            tabActiva = tabsInfo.length - 1
        }
    }

    function guardarNuevaVenta() {
        if (!nuevaVentaData.clienteId || nuevaVentaData.productos.length === 0) {
            mensajeDialog.mostrarMensaje("Complete todos los campos obligatorios")
            return
        }

        var ventaGuardada = ventaModel.agregarVenta(nuevaVentaData, nuevaVentaData.productos, 1) // 1 = usuario actual
        if (ventaGuardada) {
            mensajeDialog.mostrarMensaje("Venta guardada exitosamente")
            cerrarNuevaVenta()
            cargarVentas()
        } else {
            mensajeDialog.mostrarMensaje("Error al guardar la venta")
        }
    }

    function cerrarNuevaVenta() {
        mostrarNuevaVenta = false
        // Remover pestaña dinámica
        var index = tabsInfo.findIndex(tab => tab.text === "Nueva Venta")
        if (index !== -1) {
            tabsInfo.splice(index, 1)
            tabActiva = Math.max(0, index - 1)
        }
    }

    function abrirNuevoCliente() {
        nuevoClienteDialog.open()
    }

    function guardarNuevoCliente() {
        if (!nuevoClienteData.nombre || !nuevoClienteData.identificacion) {
            mensajeDialog.mostrarMensaje("Nombre e identificación son obligatorios")
            return
        }

        var clienteGuardado = clientesModel.agregarCliente(nuevoClienteData, 1) // 1 = usuario actual
        if (clienteGuardado) {
            mensajeDialog.mostrarMensaje("Cliente guardado exitosamente")
            nuevoClienteDialog.close()
            cargarClientes()
            // Limpiar datos
            nuevoClienteData = {
                "tipo": "Persona",
                "nombre": "",
                "identificacion": "",
                "telefono": "",
                "email": "",
                "direccion": "",
                "ciudad": ""
            }
        } else {
            mensajeDialog.mostrarMensaje("Error al guardar el cliente")
        }
    }

    function exportarDatos() {
        // Implementar exportación
        console.log("Exportando datos...")
        mensajeDialog.mostrarMensaje("Datos exportados exitosamente")
    }

    function importarClientes() {
        // Implementar importación
        console.log("Importando clientes...")
        mensajeDialog.mostrarMensaje("Clientes importados exitosamente")
    }

    Component.onCompleted: {
        cargarVentas()
        cargarClientes()
    }

    // ============================================
    // INTERFAZ PRINCIPAL
    // ============================================

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Título
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "transparent"

            Text {
                text: "GESTIÓN DE VENTAS Y CLIENTES"
                font.pixelSize: 24
                font.bold: true
                color: "#2E7D32"
                anchors.centerIn: parent
            }
        }

        // Resumen de ventas (4 cards)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            color: "transparent"
            Layout.margins: 10

            RowLayout {
                anchors.fill: parent
                spacing: 10

                // Card 1: Ventas del mes
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 8
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        RowLayout {
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: "#E8F5E9"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "💰"
                                    font.pixelSize: 20
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "↑ 12%"
                                color: "#2E7D32"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        Text {
                            text: ventasDelMes
                            font.pixelSize: 24
                            font.bold: true
                            color: "#333333"
                        }

                        Text {
                            text: "Ventas del mes"
                            font.pixelSize: 12
                            color: "#666666"
                        }

                        Text {
                            text: textoVentasDelMes
                            font.pixelSize: 11
                            color: "#999999"
                        }
                    }
                }

                // Card 2: Pagos pendientes
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 8
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        RowLayout {
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: "#FFF3E0"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "⏱️"
                                    font.pixelSize: 20
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "↓ 5%"
                                color: "#F57C00"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        Text {
                            text: pagosPendientes
                            font.pixelSize: 24
                            font.bold: true
                            color: "#333333"
                        }

                        Text {
                            text: "Pagos pendientes"
                            font.pixelSize: 12
                            color: "#666666"
                        }

                        Text {
                            text: textoPagosPendientes
                            font.pixelSize: 11
                            color: "#999999"
                        }
                    }
                }

                // Card 3: Ventas vendidas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 8
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        RowLayout {
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: "#E3F2FD"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    font.pixelSize: 20
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "↑ 8%"
                                color: "#1976D2"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        Text {
                            text: ventasVendidas
                            font.pixelSize: 24
                            font.bold: true
                            color: "#333333"
                        }

                        Text {
                            text: "Ventas completadas"
                            font.pixelSize: 12
                            color: "#666666"
                        }

                        Text {
                            text: textoVentasVendidas
                            font.pixelSize: 11
                            color: "#999999"
                        }
                    }
                }

                // Card 4: Cliente top
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 8
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        RowLayout {
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: "#F3E5F5"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "👤"
                                    font.pixelSize: 20
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: porcentajeVentas
                                color: "#7B1FA2"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        Text {
                            text: clienteTop
                            font.pixelSize: 18
                            font.bold: true
                            color: "#333333"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Cliente del mes"
                            font.pixelSize: 12
                            color: "#666666"
                        }

                        Text {
                            text: textoPorcentajeVentas
                            font.pixelSize: 11
                            color: "#999999"
                        }
                    }
                }
            }
        }

        // Contenedor de pestañas y contenido
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            Layout.margins: 10

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Barra de pestañas
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "white"
                    radius: 8
                    border.color: "#E0E0E0"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // Pestañas dinámicas
                        Repeater {
                            model: tabsInfo

                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.fillHeight: true
                                color: tabActiva === index ? modelData.color : "transparent"
                                radius: 6
                                border.color: tabActiva === index ? modelData.color : "#E0E0E0"
                                border.width: 2

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Image {
                                        source: modelData.icon
                                        sourceSize.width: 24
                                        sourceSize.height: 24
                                    }

                                    Text {
                                        text: modelData.text
                                        font.pixelSize: 14
                                        font.bold: tabActiva === index
                                        color: tabActiva === index ? "white" : "#666666"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: tabActiva = index
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Botón de nueva venta/cliente
                        Button {
                            text: tabActiva === 0 ? "+ Nueva Venta" : "+ Nuevo Cliente"
                            font.pixelSize: 13
                            font.bold: true
                            Layout.preferredHeight: 40
                            palette.buttonText: "white"
                            
                            background: Rectangle {
                                color: parent.down ? "#1976D2" : parent.hovered ? "#2196F3" : "#42A5F5"
                                radius: 6
                            }

                            onClicked: {
                                if (tabActiva === 0) {
                                    abrirNuevaVenta()
                                } else {
                                    abrirNuevoCliente()
                                }
                            }
                        }
                    }
                }

                // Contenido de las pestañas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 10
                    color: "white"
                    radius: 8
                    border.color: "#E0E0E0"

                    StackLayout {
                        anchors.fill: parent
                        currentIndex: tabActiva

                        // PESTAÑA 1: VENTAS
                        Rectangle {
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 15

                                // Barra de búsqueda y filtros
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    TextField {
                                        Layout.fillWidth: true
                                        placeholderText: "Buscar ventas por código, cliente..."
                                        font.pixelSize: 14
                                        onTextChanged: buscarVentas(text)
                                    }

                                    ComboBox {
                                        model: estadosVenta
                                        Layout.preferredWidth: 200
                                        onCurrentTextChanged: filtrarVentasPorEstado(currentText)
                                    }

                                    ComboBox {
                                        model: periodosVentas
                                        Layout.preferredWidth: 150
                                    }

                                    Button {
                                        text: "Exportar"
                                        font.pixelSize: 12
                                        onClicked: exportarDatos()
                                    }
                                }

                                // Tabla de ventas
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "#FAFAFA"
                                    border.color: "#E0E0E0"

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        // Encabezados de columnas
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 50
                                            color: "#E3F2FD"

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 10

                                                Text { text: "Código"; font.bold: true; Layout.preferredWidth: 100 }
                                                Text { text: "Fecha"; font.bold: true; Layout.preferredWidth: 100 }
                                                Text { text: "Cliente"; font.bold: true; Layout.fillWidth: true }
                                                Text { text: "Total"; font.bold: true; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignRight }
                                                Text { text: "Estado"; font.bold: true; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignHCenter }
                                                Text { text: "Acciones"; font.bold: true; Layout.preferredWidth: 150; horizontalAlignment: Text.AlignHCenter }
                                            }
                                        }

                                        // Lista de ventas
                                        ListView {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            clip: true
                                            model: ventaModel

                                            delegate: Rectangle {
                                                width: parent.width
                                                height: 60
                                                color: index % 2 === 0 ? "white" : "#F5F5F5"
                                                border.color: "#E0E0E0"
                                                border.width: 1

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    spacing: 10

                                                    Text { 
                                                        text: model.codigo
                                                        Layout.preferredWidth: 100 
                                                        font.pixelSize: 13
                                                    }
                                                    Text { 
                                                        text: model.fecha
                                                        Layout.preferredWidth: 100 
                                                        font.pixelSize: 13
                                                    }
                                                    Text { 
                                                        text: model.nombre_cliente
                                                        Layout.fillWidth: true 
                                                        font.pixelSize: 13
                                                        elide: Text.ElideRight
                                                    }
                                                    Text { 
                                                        text: "Bs. " + model.total
                                                        Layout.preferredWidth: 120 
                                                        horizontalAlignment: Text.AlignRight
                                                        font.pixelSize: 13
                                                        font.bold: true
                                                    }

                                                    // Estado
                                                    Rectangle {
                                                        Layout.preferredWidth: 100
                                                        Layout.preferredHeight: 30
                                                        radius: 15
                                                        color: {
                                                            switch(model.estado) {
                                                                case "Pagada": return "#C8E6C9"
                                                                case "Pendiente": return "#FFF9C4"
                                                                case "Parcial": return "#FFECB3"
                                                                case "Vencida": return "#FFCDD2"
                                                                default: return "#E0E0E0"
                                                            }
                                                        }

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: model.estado
                                                            font.pixelSize: 11
                                                            font.bold: true
                                                            color: {
                                                                switch(model.estado) {
                                                                    case "Pagada": return "#2E7D32"
                                                                    case "Pendiente": return "#F9A825"
                                                                    case "Parcial": return "#F57C00"
                                                                    case "Vencida": return "#C62828"
                                                                    default: return "#666666"
                                                                }
                                                            }
                                                        }
                                                    }

                                                    // Botones de acción
                                                    RowLayout {
                                                        Layout.preferredWidth: 150
                                                        spacing: 5

                                                        Button {
                                                            text: "Ver"
                                                            font.pixelSize: 11
                                                            Layout.preferredHeight: 30
                                                            palette.buttonText: "#1976D2"
                                                            
                                                            background: Rectangle {
                                                                color: parent.down ? "#E3F2FD" : parent.hovered ? "#BBDEFB" : "white"
                                                                border.color: "#1976D2"
                                                                radius: 4
                                                            }
                                                        }

                                                        Button {
                                                            text: "Editar"
                                                            font.pixelSize: 11
                                                            Layout.preferredHeight: 30
                                                            palette.buttonText: "#F57C00"
                                                            
                                                            background: Rectangle {
                                                                color: parent.down ? "#FFF3E0" : parent.hovered ? "#FFE0B2" : "white"
                                                                border.color: "#F57C00"
                                                                radius: 4
                                                            }
                                                        }

                                                        Button {
                                                            text: "❌"
                                                            font.pixelSize: 11
                                                            Layout.preferredHeight: 30
                                                            Layout.preferredWidth: 30
                                                            
                                                            background: Rectangle {
                                                                color: parent.down ? "#FFCDD2" : parent.hovered ? "#EF9A9A" : "white"
                                                                border.color: "#D32F2F"
                                                                radius: 4
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Paginación de ventas
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text: "Mostrando página " + paginaVentas + " de " + totalPaginasVentas
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        text: "← Anterior"
                                        enabled: paginaVentas > 1
                                        onClicked: paginaVentas--
                                    }

                                    Button {
                                        text: "Siguiente →"
                                        enabled: paginaVentas < totalPaginasVentas
                                        onClicked: paginaVentas++
                                    }
                                }
                            }
                        }

                        // PESTAÑA 2: CLIENTES
                        Rectangle {
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 15

                                // Barra de búsqueda y filtros
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    TextField {
                                        Layout.fillWidth: true
                                        placeholderText: "Buscar clientes por nombre, identificación..."
                                        font.pixelSize: 14
                                    }

                                    ComboBox {
                                        model: tiposCliente
                                        Layout.preferredWidth: 200
                                    }

                                    Button {
                                        text: "Importar"
                                        font.pixelSize: 12
                                        onClicked: importarClientes()
                                    }

                                    Button {
                                        text: "Exportar"
                                        font.pixelSize: 12
                                        onClicked: exportarDatos()
                                    }
                                }

                                // Tabla de clientes
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "#FAFAFA"
                                    border.color: "#E0E0E0"

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        // Encabezados de columnas
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 50
                                            color: "#E3F2FD"

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 10

                                                Text { text: "Tipo"; font.bold: true; Layout.preferredWidth: 80 }
                                                Text { text: "Nombre"; font.bold: true; Layout.fillWidth: true }
                                                Text { text: "Identificación"; font.bold: true; Layout.preferredWidth: 120 }
                                                Text { text: "Teléfono"; font.bold: true; Layout.preferredWidth: 120 }
                                                Text { text: "Ciudad"; font.bold: true; Layout.preferredWidth: 100 }
                                                Text { text: "Ventas"; font.bold: true; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignHCenter }
                                                Text { text: "Acciones"; font.bold: true; Layout.preferredWidth: 120; horizontalAlignment: Text.AlignHCenter }
                                            }
                                        }

                                        // Lista de clientes
                                        ListView {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            clip: true
                                            model: clientesModel

                                            delegate: Rectangle {
                                                width: parent.width
                                                height: 60
                                                color: index % 2 === 0 ? "white" : "#F5F5F5"
                                                border.color: "#E0E0E0"
                                                border.width: 1

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    spacing: 10

                                                    // Tipo
                                                    Rectangle {
                                                        Layout.preferredWidth: 80
                                                        Layout.preferredHeight: 30
                                                        radius: 4
                                                        color: model.tipo === "Persona" ? "#E8F5E9" : "#E3F2FD"

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: model.tipo
                                                            font.pixelSize: 11
                                                            font.bold: true
                                                            color: model.tipo === "Persona" ? "#2E7D32" : "#1976D2"
                                                        }
                                                    }

                                                    Text { 
                                                        text: model.nombre
                                                        Layout.fillWidth: true 
                                                        font.pixelSize: 13
                                                        elide: Text.ElideRight
                                                    }
                                                    Text { 
                                                        text: model.identificacion
                                                        Layout.preferredWidth: 120 
                                                        font.pixelSize: 13
                                                    }
                                                    Text { 
                                                        text: model.telefono || "-"
                                                        Layout.preferredWidth: 120 
                                                        font.pixelSize: 13
                                                    }
                                                    Text { 
                                                        text: model.ciudad || "-"
                                                        Layout.preferredWidth: 100 
                                                        font.pixelSize: 13
                                                    }
                                                    Text { 
                                                        text: model.total_ventas || "0"
                                                        Layout.preferredWidth: 80 
                                                        font.pixelSize: 13
                                                        font.bold: true
                                                        horizontalAlignment: Text.AlignHCenter
                                                    }

                                                    // Botones de acción
                                                    RowLayout {
                                                        Layout.preferredWidth: 120
                                                        spacing: 5

                                                        Button {
                                                            text: "Ver"
                                                            font.pixelSize: 11
                                                            Layout.preferredHeight: 30
                                                            palette.buttonText: "#1976D2"
                                                            
                                                            background: Rectangle {
                                                                color: parent.down ? "#E3F2FD" : parent.hovered ? "#BBDEFB" : "white"
                                                                border.color: "#1976D2"
                                                                radius: 4
                                                            }
                                                        }

                                                        Button {
                                                            text: "Editar"
                                                            font.pixelSize: 11
                                                            Layout.preferredHeight: 30
                                                            palette.buttonText: "#F57C00"
                                                            
                                                            background: Rectangle {
                                                                color: parent.down ? "#FFF3E0" : parent.hovered ? "#FFE0B2" : "white"
                                                                border.color: "#F57C00"
                                                                radius: 4
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Paginación de clientes
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text: "Mostrando página " + paginaClientes + " de " + totalPaginasClientes
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        text: "← Anterior"
                                        enabled: paginaClientes > 1
                                        onClicked: paginaClientes--
                                    }

                                    Button {
                                        text: "Siguiente →"
                                        enabled: paginaClientes < totalPaginasClientes
                                        onClicked: paginaClientes++
                                    }
                                }
                            }
                        }

                        // PESTAÑA 3: NUEVA VENTA (si está activa)
                        Rectangle {
                            visible: mostrarNuevaVenta
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 20

                                // Encabezado
                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: "Nueva Venta"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#FF9800"
                                    }

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        text: "Guardar"
                                        font.bold: true
                                        palette.buttonText: "white"
                                        
                                        background: Rectangle {
                                            color: parent.down ? "#2E7D32" : parent.hovered ? "#388E3C" : "#4CAF50"
                                            radius: 6
                                        }

                                        onClicked: guardarNuevaVenta()
                                    }

                                    Button {
                                        text: "Cancelar"
                                        palette.buttonText: "#666666"
                                        
                                        background: Rectangle {
                                            color: parent.down ? "#E0E0E0" : parent.hovered ? "#EEEEEE" : "white"
                                            border.color: "#BDBDBD"
                                            radius: 6
                                        }

                                        onClicked: cerrarNuevaVenta()
                                    }
                                }

                                // Formulario de venta
                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true

                                    ColumnLayout {
                                        width: parent.parent.width - 20
                                        spacing: 20

                                        // Información básica
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 200
                                            color: "#F5F5F5"
                                            radius: 8
                                            border.color: "#E0E0E0"

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 15
                                                spacing: 15

                                                Text {
                                                    text: "Información de la Venta"
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: "#333333"
                                                }

                                                GridLayout {
                                                    columns: 2
                                                    columnSpacing: 20
                                                    rowSpacing: 10
                                                    Layout.fillWidth: true

                                                    Text { text: "Código:"; font.bold: true }
                                                    TextField {
                                                        Layout.fillWidth: true
                                                        text: nuevaVentaData.codigo
                                                        readOnly: true
                                                        background: Rectangle { color: "#E0E0E0"; radius: 4 }
                                                    }

                                                    Text { text: "Fecha:"; font.bold: true }
                                                    TextField {
                                                        Layout.fillWidth: true
                                                        text: nuevaVentaData.fecha
                                                        readOnly: true
                                                        background: Rectangle { color: "#E0E0E0"; radius: 4 }
                                                    }

                                                    Text { text: "Cliente *:"; font.bold: true }
                                                    RowLayout {
                                                        Layout.fillWidth: true

                                                        TextField {
                                                            Layout.fillWidth: true
                                                            text: nuevaVentaData.clienteNombre
                                                            placeholderText: "Seleccione un cliente..."
                                                            readOnly: true
                                                        }

                                                        Button {
                                                            text: "Buscar"
                                                            onClicked: buscarClienteDialog.open()
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        // Productos
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            color: "#F5F5F5"
                                            radius: 8
                                            border.color: "#E0E0E0"

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 15
                                                spacing: 10

                                                Text {
                                                    text: "Productos"
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: "#333333"
                                                }

                                                // Lista de productos (simplificada)
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    color: "#FAFAFA"
                                                    border.color: "#E0E0E0"

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "Funcionalidad de productos en desarrollo..."
                                                        color: "#666666"
                                                        font.pixelSize: 14
                                                    }
                                                }

                                                // Total
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    height: 40
                                                    color: "#E3F2FD"
                                                    radius: 4

                                                    RowLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 10

                                                        Text {
                                                            text: "TOTAL:"
                                                            font.bold: true
                                                            font.pixelSize: 16
                                                            color: "#1976D2"
                                                        }

                                                        Item { Layout.fillWidth: true }

                                                        Text {
                                                            text: "Bs. " + nuevaVentaData.total
                                                            font.bold: true
                                                            font.pixelSize: 18
                                                            color: "#1976D2"
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
            }
        }
    }

    // ============================================
    // DIÁLOGOS
    // ============================================

    // Diálogo para nuevo cliente
    Dialog {
        id: nuevoClienteDialog
        title: "Nuevo Cliente"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 500
        anchors.centerIn: parent

        ColumnLayout {
            width: parent ? parent.width : 400
            spacing: 15

            Text { text: "Información del Cliente"; font.bold: true; font.pixelSize: 16 }

            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 10

                Text { text: "Tipo:"; font.bold: true }
                ComboBox {
                    Layout.fillWidth: true
                    model: ["Persona", "Empresa"]
                    onCurrentTextChanged: nuevoClienteData.tipo = currentText
                }

                Text { text: "Nombre *:"; font.bold: true }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Nombre completo o razón social"
                    onTextChanged: nuevoClienteData.nombre = text
                }

                Text { text: "Identificación *:"; font.bold: true }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Número de identificación"
                    onTextChanged: nuevoClienteData.identificacion = text
                }

                Text { text: "Teléfono:"; font.bold: true }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Número de teléfono"
                    onTextChanged: nuevoClienteData.telefono = text
                }

                Text { text: "Email:"; font.bold: true }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Correo electrónico"
                    onTextChanged: nuevoClienteData.email = text
                }

                Text { text: "Dirección:"; font.bold: true }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Dirección completa"
                    onTextChanged: nuevoClienteData.direccion = text
                }

                Text { text: "Ciudad:"; font.bold: true }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Ciudad"
                    onTextChanged: nuevoClienteData.ciudad = text
                }
            }
        }

        onAccepted: guardarNuevoCliente()
    }

    // Diálogo para buscar cliente en nueva venta
    Dialog {
        id: buscarClienteDialog
        title: "Buscar Cliente"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 600
        anchors.centerIn: parent

        ColumnLayout {
            width: parent ? parent.width : 400
            spacing: 15

            TextField {
                Layout.fillWidth: true
                placeholderText: "Buscar cliente por nombre o identificación..."
                onTextChanged: {
                    // Implementar búsqueda en tiempo real
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                clip: true
                model: clientesModel
                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    color: mouseArea.containsMouse ? "#E3F2FD" : "white"
                    border.color: "#E0E0E0"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 10

                        Text { 
                            text: model.nombre
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text { 
                            text: model.identificacion
                            color: "#666666"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text { 
                            text: model.tipo
                            color: "#666666"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            nuevaVentaData.clienteId = model.id_cliente
                            nuevaVentaData.clienteNombre = model.nombre
                            buscarClienteDialog.close()
                        }
                    }
                }
            }
        }
    }

    // Diálogo de mensajes simple (reemplazo de MessageDialog)
    Dialog {
        id: mensajeDialog
        title: "Mensaje"
        modal: true
        standardButtons: Dialog.Ok
        width: 400
        anchors.centerIn: parent

        property alias text: mensajeText.text

        function mostrarMensaje(mensaje) {
            text = mensaje
            open()
        }

        Text {
            id: mensajeText
            width: parent ? parent.width : 300
            wrapMode: Text.WordWrap
            font.pixelSize: 14
        }
    }

    // ============================================
    // CONEXIONES CON MODELOS
    // ============================================

    Connections {
        target: ventaModel
        function onVentasActualizadas() {
            cargarVentas()
        }
        function onErrorOcurrido(mensaje) {
            mensajeDialog.mostrarMensaje(mensaje)
        }
        function onOperacionExitosa(mensaje) {
            mensajeDialog.mostrarMensaje(mensaje)
        }
    }

    Connections {
        target: clientesModel
        function onClientesActualizados() {
            cargarClientes()
        }
        function onErrorOcurrido(mensaje) {
            mensajeDialog.mostrarMensaje(mensaje)
        }
        function onOperacionExitosa(mensaje) {
            mensajeDialog.mostrarMensaje(mensaje)
        }
    }
}
