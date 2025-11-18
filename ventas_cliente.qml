import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: ventasClientesRoot
    anchors.fill: parent
    color: "#F8F9FA"

    ListModel { id: ventasListViewModel }
    ListModel { id: clientesViewModel }
    ListModel { id: clientesComboModel }

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

    // Propiedades para datos dinámicos
    property var ventasData: []
    property var clientesData: []

    // Propiedades para filtros
    property var estadosVenta: ["Todos los estados", "Pagada", "Pendiente", "Parcial", "Vencida"]
    property var tiposCliente: ["Todos los tipos", "Persona", "Empresa"]
    property var periodosVentas: ["Último mes", "Últimos 3 meses", "Último año", "Todas"]
    
    // Propiedades para paginación
    property int paginaVentas: 1
    property int totalPaginasVentas: 5
    property int paginaClientes: 1
    property int totalPaginasClientes: 3

    // Propiedades para edición
    property bool mostrarDialogoNuevaVenta: false
    property int filaSeleccionada: -1
    property var nuevaVenta: {
        "ventaId": "",
        "codigo": "",
        "fecha": "",
        "cliente": "",
        "cantidad": 0,
        "precio100u": 0,
        "total": 0,
        "estado": "Pendiente"
    }
    
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

    Connections {
        target: ventaModel
        
        function onVentasChanged() {
            cargarVentasDesdeModelo()
        }
        
        function onClientesChanged() {
            cargarClientesDesdeModelo()
        }
    }

    function safeGetModelData(functionName, defaultValue) {
        try {
            if (ventaModel && ventaModel[functionName]) {
                return ventaModel[functionName]();
            }
        } catch(e) {
            console.error("Error al llamar a " + functionName + ": " + e);
        }
        return defaultValue || "[]";
    }

    function safeText(value, defaultValue) {
        return (value !== undefined && value !== null) ? String(value) : (defaultValue || "");
    }

    function cargarVentasDesdeModelo() {
        console.log("Iniciando carga de ventas desde modelo...");
        ventasListViewModel.clear();
        var ventasJson = safeGetModelData("get_ventas_json");
        console.log("JSON de ventas recibido, longitud: " + ventasJson.length);
        
        try {
            var ventas = JSON.parse(ventasJson);
            console.log("Cantidad de ventas parseadas: " + ventas.length);
            
            for (var i = 0; i < ventas.length; i++) {
                var venta = ventas[i];
                var item = {
                    id_venta: venta.id_venta || 0,
                    codigo: safeText(venta.codigo_venta, ""),
                    fecha: safeText(venta.fecha_venta, ""),
                    cliente: safeText(venta.cliente_nombre, ""),
                    cantidad: venta.cantidad || 0,
                    precio100u: venta.precio_unitario || 0,
                    total: venta.total || 0,
                    estado: safeText(venta.estado_nombre, "Pendiente"),
                    estado_pago: safeText(venta.estado_pago, "Pendiente")
                };
                ventasListViewModel.append(item);
            }
            
            console.log("Carga de ventas completada. Total ventas: " + ventasListViewModel.count);
            actualizarResumenVentas();
        } catch (e) {
            console.error("Error al cargar ventas: " + e);
        }
    }

    function cargarClientesDesdeModelo() {
        clientesViewModel.clear();
        var clientesJson = safeGetModelData("get_clientes_json");
        var clientes = JSON.parse(clientesJson);
        
        for (var i = 0; i < clientes.length; i++) {
            clientesViewModel.append(clientes[i]);
        }
    }

    function cargarClientesCombo() {
        clientesComboModel.clear();
        var clientesJson = safeGetModelData("get_clientes_json");
        
        try {
            var clientes = JSON.parse(clientesJson);
            for (var i = 0; i < clientes.length; i++) {
                clientesComboModel.append({
                    id: clientes[i].id_cliente,
                    nombre: clientes[i].nombre
                });
            }
        } catch (e) {
            console.error("Error al cargar clientes: " + e);
        }
    }

    function buscarVentas(termino) {
        if (termino.length === 0) {
            cargarVentasDesdeModelo();
            return;
        }
        
        if (ventaModel && typeof ventaModel.buscar_ventas === 'function') {
            var resultadosJson = ventaModel.buscar_ventas(termino);
            var resultados = JSON.parse(resultadosJson);
            
            ventasListViewModel.clear();
            for (var i = 0; i < resultados.length; i++) {
                ventasListViewModel.append(resultados[i]);
            }
        }
    }

    function filtrarVentasPorEstado(estado) {
        if (estado === "Todos los estados") {
            cargarVentasDesdeModelo();
            return;
        }
        
        if (ventaModel && typeof ventaModel.filtrar_ventas_por_estado_pago === 'function') {
            var resultadosJson = ventaModel.filtrar_ventas_por_estado_pago(estado);
            var resultados = JSON.parse(resultadosJson);
            
            ventasListViewModel.clear();
            for (var i = 0; i < resultados.length; i++) {
                ventasListViewModel.append(resultados[i]);
            }
        }
    }

    function actualizarResumenVentas() {
        try {
            if (ventaModel && typeof ventaModel.get_resumen_ventas_json === 'function') {
                var resumenJson = ventaModel.get_resumen_ventas_json();
                var resumen = JSON.parse(resumenJson);
                
                ventasDelMes = "Bs. " + (resumen.ventas_mes || 0);
                pagosPendientes = "Bs. " + (resumen.pagos_pendientes || 0);
                ventasVendidas = "Bs. " + (resumen.ventas_vendidas || 0);
                porcentajeVentas = (resumen.porcentaje_ventas || 0) + "%";
                
                textoPagosPendientes = (resumen.cantidad_pendientes || 0) + " clientes";
                textoVentasVendidas = (resumen.cantidad_vendidas || 0) + " clientes";
                textoPorcentajeVentas = (resumen.porcentaje_ventas || 0) + "% de las ventas";
                
                if (ventaModel && typeof ventaModel.get_cliente_top_json === 'function') {
                    var clienteTopJson = ventaModel.get_cliente_top_json();
                    var clienteTopData = JSON.parse(clienteTopJson);
                    clienteTop = clienteTopData.nombre || "Sin datos";
                }
            }
        } catch (e) {
            console.error("Error al actualizar resumen: " + e);
        }
    }

    function exportarDatos() {
        if (ventaModel && typeof ventaModel.exportar_ventas === 'function') {
            ventaModel.exportar_ventas();
        }
    }

    function importarClientes() {
        if (ventaModel && typeof ventaModel.importar_clientes === 'function') {
            ventaModel.importar_clientes();
        }
    }

    function mostrarNuevaVenta() {
        console.log("Mostrar nueva venta");
    }

    function showMessage(message) {
        console.log("Mensaje:", message);
    }

    Component.onCompleted: {
        cargarClientesCombo();
        cargarVentasDesdeModelo();
        cargarClientesDesdeModelo();
        actualizarResumenVentas();
    }

    // Título
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
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
            tabsData: ventasClientesRoot.tabsInfo
            tabActiva: ventasClientesRoot.tabActiva
            
            onTabChanged: function(index) {
                ventasClientesRoot.tabActiva = index
                paginaVentas = 1
                paginaClientes = 1
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
        
        // ==================== TAB 1: VENTAS ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 0
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                
                // Panel de resumen modernizado - TARJETAS COMPACTAS
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "white"
                    radius: 10
                    border.color: "#E8E8E8"
                    border.width: 1
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        // Ventas del Mes
                        Rectangle {
                            width: (parent.width - 48) / 5
                            height: parent.height
                            color: "#F0F7F0"
                            radius: 8
                            border.color: "#D4E8D4"
                            border.width: 1
                            
                            Column {
                                anchors.centerIn: parent
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 3
                                
                                Text {
                                    text: "Ventas del Mes"
                                    font.pixelSize: 10
                                    color: "#555555"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: ventasDelMes
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#2E7D32"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: textoVentasDelMes
                                    font.pixelSize: 8
                                    color: "#888888"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 10
                                    elide: Text.ElideRight
                                }
                            }
                        }
                        
                        // Pagos Pendientes
                        Rectangle {
                            width: (parent.width - 48) / 5
                            height: parent.height
                            color: "#FFFAF0"
                            radius: 8
                            border.color: "#FFE8C8"
                            border.width: 1
                            
                            Column {
                                anchors.centerIn: parent
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 3
                                
                                Text {
                                    text: "Pagos Pendientes"
                                    font.pixelSize: 10
                                    color: "#555555"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: pagosPendientes
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#F9A825"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: textoPagosPendientes
                                    font.pixelSize: 8
                                    color: "#888888"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 10
                                    elide: Text.ElideRight
                                }
                            }
                        }
                        
                        // Ventas Vendidas
                        Rectangle {
                            width: (parent.width - 48) / 5
                            height: parent.height
                            color: "#FFF0F1"
                            radius: 8
                            border.color: "#FFCCCC"
                            border.width: 1
                            
                            Column {
                                anchors.centerIn: parent
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 3
                                
                                Text {
                                    text: "Ventas Vendidas"
                                    font.pixelSize: 10
                                    color: "#555555"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: ventasVendidas
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#D32F2F"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: textoVentasVendidas
                                    font.pixelSize: 8
                                    color: "#888888"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 10
                                    elide: Text.ElideRight
                                }
                            }
                        }
                        
                        // Cliente Top
                        Rectangle {
                            width: (parent.width - 48) / 5
                            height: parent.height
                            color: "#F0F4FF"
                            radius: 8
                            border.color: "#D4E1FF"
                            border.width: 1
                            
                            Column {
                                anchors.centerIn: parent
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 3
                                
                                Text {
                                    text: "Cliente Top"
                                    font.pixelSize: 10
                                    color: "#555555"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: clienteTop
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#1976D2"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    elide: Text.ElideRight
                                    width: parent.width - 10
                                }
                                Text {
                                    text: "Sin datos"
                                    font.pixelSize: 8
                                    color: "#888888"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                        
                        // Porcentaje Ventas
                        Rectangle {
                            width: (parent.width - 48) / 5
                            height: parent.height
                            color: "#F0F8F5"
                            radius: 8
                            border.color: "#D4E8E0"
                            border.width: 1
                            
                            Column {
                                anchors.centerIn: parent
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 3
                                
                                Text {
                                    text: "Porcentaje Ventas"
                                    font.pixelSize: 10
                                    color: "#555555"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: porcentajeVentas
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#00897B"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: textoPorcentajeVentas
                                    font.pixelSize: 8
                                    color: "#888888"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 10
                                    elide: Text.ElideRight
                                }
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
                            icon.source: "recursos/image/icons/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: height / 2
                            }
                            contentItem: Row {
                                spacing: 5
                                anchors.centerIn: parent
                                Image {
                                    source: "recursos/image/icons/agregar.svg"
                                    width: 16
                                    height: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Nueva Venta"
                                    color: "white"
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            onClicked: {
                                nuevaVenta = { 
                                    "ventaId": "", 
                                    "codigo": "",
                                    "fecha": Qt.formatDateTime(new Date(), "dd/MM/yyyy"),
                                    "cliente": "",
                                    "total": 0,
                                    "estado": "Pendiente"
                                }
                                mostrarNuevaVenta();
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar venta por código o cliente..."
                            implicitWidth: 450
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
                                    source: "recursos/image/icons/lupa.png"
                                    width: 16
                                    height: 16
                                }
                            }
                            onTextChanged: {
                                if (text.length > 2 || text.length === 0) {
                                    buscarVentas(text);
                                }
                            }
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los estados", "Pagada", "Pendiente", "Parcial", "Vencida"]
                            implicitHeight: 36

                            onCurrentIndexChanged: {
                                if (currentIndex === 0) {
                                    cargarVentasDesdeModelo();
                                } else {
                                    filtrarVentasPorEstado(currentText);
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        ComboBox {
                            Layout.preferredWidth: 150
                            model: ["Último mes", "Últimos 3 meses", "Último año", "Todas"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Exportar"
                            icon.source: "recursos/image/icons/exportacion-de-archivos.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: exportarDatos()
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
                        model: ventasListViewModel
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#F5F5F5"
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Código"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Fecha"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Cliente"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Cantidad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Precio Unit."
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Total"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.16
                                    height: parent.height
                                    text: "Estado"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Acciones"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
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
                                
                                Text { width: parent.width * 0.1; height: parent.height; text: codigo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: fecha; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: cliente; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: cantidad; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: precio100u; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: total; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.16
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 80
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: estado === "Completada" ? "#E8F5E8" : (estado === "Pendiente" ? "#FFF3CD" : "#FFEBEE")
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: estado
                                            font.pixelSize: 11
                                            color: estado === "Completada" ? "#2E7D32" : (estado === "Pendiente" ? "#B8860B" : "#D32F2F")
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 5
                                    }
                                }
                            }
                        }
                        
                        footer: Rectangle {
                            width: parent.width
                            height: ventasListViewModel.count === 0 ? 100 : 0
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "No hay ventas registradas"
                                font.pixelSize: 14
                                color: "#999999"
                            }
                        }
                    }
                }
                
                // Paginador Ventas
                Paginator {
                    Layout.fillWidth: true
                    height: 50
                    currentPage: paginaVentas
                    totalPages: totalPaginasVentas
                    
                    onPageChanged: function(newPage) {
                        paginaVentas = newPage
                    }
                }
            }
        }
        
        // ==================== TAB 2: CLIENTES ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 1
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                
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
                            icon.source: "recursos/image/icons/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#0277bd" : "#0288D1"
                                radius: height / 2
                            }
                            contentItem: Row {
                                spacing: 5
                                anchors.centerIn: parent
                                Image {
                                    source: "recursos/image/icons/agregar.svg"
                                    width: 16
                                    height: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Nuevo Cliente"
                                    color: "white"
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            onClicked: {
                                mostrarNuevoCliente = true;
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar cliente..."
                            implicitWidth: 450
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
                                    source: "recursos/image/icons/lupa.png"
                                    width: 16
                                    height: 16
                                }
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
                            icon.source: "recursos/image/icons/impotar.png"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: importarClientes()
                        }
                    }
                }
                
                // Tabla de Clientes
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: clientesViewModel
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#F5F5F5"
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Nombre"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Tipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Identificación"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Teléfono"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Ciudad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Total Compras"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Pendiente"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.09
                                    height: parent.height
                                    text: "Acciones"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
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
                                
                                Text { width: parent.width * 0.15; height: parent.height; text: nombre || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: tipo || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.15; height: parent.height; text: identificacion || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: telefono || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: ciudad || ""; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Bs. " + (total_compras || 0); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: "Bs. " + (pendiente || 0); verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.09
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        
                                        Rectangle {
                                            width: 28
                                            height: 28
                                            radius: 4
                                            color: "#E3F2FD"
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "✎"
                                                font.pixelSize: 14
                                            }
                                            
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: console.log("Editar cliente: " + nombre)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        footer: Rectangle {
                            width: parent.width
                            height: clientesViewModel.count === 0 ? 100 : 0
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "No hay clientes registrados"
                                font.pixelSize: 14
                                color: "#999999"
                            }
                        }
                    }
                }
                
                // Paginador Clientes
                Paginator {
                    Layout.fillWidth: true
                    height: 50
                    currentPage: paginaClientes
                    totalPages: totalPaginasClientes
                    
                    onPageChanged: function(newPage) {
                        paginaClientes = newPage
                    }
                }
            }
        }
    }
}
