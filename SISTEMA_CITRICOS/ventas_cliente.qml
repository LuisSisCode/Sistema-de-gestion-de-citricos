import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: ventasClientesRoot
    anchors.fill: parent
    color: "#F8F9FA"

    ListModel { id: ventasListViewModel }
    ListModel { id: clientesViewModel }
    ListModel { id: clientesComboModel }

    // Agregar después de la línea ListModel { id: clientesComboModel }
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
    // Función para probar la conexión con el modelo
    function testModelConnection() {
        if (!ventaModel) {
            showMessage("Error: El modelo de ventas no está disponible");
            console.error("ventaModel es null");
            return false;
        }
        
        // Lista de métodos que deberían estar disponibles
        var metodos = [
            "get_ventas_json", 
            "get_clientes_json",
            "get_estados_venta_json",
            "get_resumen_ventas_json",
            "get_cliente_top_json"
        ];
        
        var faltantes = [];
        for (var i = 0; i < metodos.length; i++) {
            if (typeof ventaModel[metodos[i]] !== 'function') {
                faltantes.push(metodos[i]);
            }
        }
        
        if (faltantes.length > 0) {
            showMessage("Error: Faltan métodos en el modelo: " + faltantes.join(", "));
            console.error("Métodos faltantes: " + faltantes.join(", "));
            return false;
        }
        
        showMessage("Conexión con el modelo correcta");
        return true;
    }

    // Llamar a la función de prueba después de un breve retraso
    Timer {
        id: modelTestTimer
        interval: 2000
        running: true
        onTriggered: testModelConnection()
    }

    

    function cargarVentasDesdeModelo() {
        ventasListViewModel.clear();
        var ventasJson = safeGetModelData("get_ventas_json");
        
        try {
            var ventas = JSON.parse(ventasJson);
            
            for (var i = 0; i < ventas.length; i++) {
                // Crear objeto con valores seguros para evitar undefined o null
                var item = {
                    id_venta: ventas[i].id_venta || 0,
                    codigo: safeText(ventas[i].codigo_venta, ""),
                    fecha: safeText(ventas[i].fecha_venta, ""),
                    cliente: safeText(ventas[i].cliente_nombre, ""),
                    cantidad: ventas[i].cantidad || 0,
                    precio100u: ventas[i].precio_unitario || 0,
                    total: ventas[i].total || 0,
                    estado: safeText(ventas[i].estado_nombre, "Pendiente"),
                    estado_pago: safeText(ventas[i].estado_pago, "Pendiente"),
                    fecha_entrega: safeText(ventas[i].fecha_entrega, ""),
                    lugar_entrega: safeText(ventas[i].lugar_entrega, ""),
                    observaciones: safeText(ventas[i].observaciones, "")
                };
                ventasListViewModel.append(item);
            }
        } catch (e) {
            console.error("Error al cargar ventas: " + e);
            showMessage("Error al cargar los datos de ventas");
        }
    }

    function buscarVentas(termino) {
        if (termino.length === 0) {
            cargarVentasDesdeModelo(); // Cargar todas las ventas
            return;
        }
        
        var resultadosJson = ventaModel.buscar_ventas(termino);
        var resultados = JSON.parse(resultadosJson);
        
        ventasListViewModel.clear();
        for (var i = 0; i < resultados.length; i++) {
            ventasListViewModel.append(resultados[i]);
        }
    }
    function filtrarVentasPorEstado(estado) {
        if (estado === "Todos los estados") {
            cargarVentasDesdeModelo();
            return;
        }
        
        var resultadosJson = ventaModel.filtrar_ventas_por_estado_pago(estado);
        var resultados = JSON.parse(resultadosJson);
        
        ventasListViewModel.clear();
        for (var i = 0; i < resultados.length; i++) {
            ventasListViewModel.append(resultados[i]);
        }
    }

    function actualizarResumenVentas() {
        var resumenJson = safeGetModelData("get_resumen_ventas_json");
        var resumen = JSON.parse(resumenJson);
        
        // Actualizar los campos de estadísticas
        // (ajusta estos nombres de campo según tu interfaz)
        txtVentasMes.text = "Bs. " + (resumen.totales?.monto_total || 0).toFixed(2);
        txtPagosPendientes.text = "Bs. " + (resumen.totales?.pendiente || 0).toFixed(2);
        txtVentasVencidas.text = "Bs. " + (resumen.totales?.vencido || 0).toFixed(2);
        
        // Cliente top
        var clienteTopJson = safeGetModelData("get_cliente_top_json");
        var clienteTop = JSON.parse(clienteTopJson);
        
        if (clienteTop && clienteTop.nombre) {
            txtClienteTop.text = clienteTop.nombre;
            txtPorcentajeVentas.text = (clienteTop.porcentaje || 0).toFixed(1) + "% de las ventas";
        } else {
            txtClienteTop.text = "Sin datos";
            txtPorcentajeVentas.text = "0% de las ventas";
        }
    }
    function verDetalleVenta() {
        var ventaJson = safeGetModelData("get_venta_seleccionada_json");
        try {
            var venta = JSON.parse(ventaJson);
            
            if (venta && venta.id_venta) {
                // Configurar datos para el diálogo de factura de manera segura
                dialogFactura.facturaDatos = {
                    id_venta: venta.id_venta || 0,
                    codigo: safeText(venta.codigo_venta, ""),
                    fecha_venta: safeText(venta.fecha_venta, ""),
                    cliente_nombre: safeText(venta.cliente_nombre, ""),
                    estado_nombre: safeText(venta.estado_nombre, ""),
                    estado_pago: safeText(venta.estado_pago, ""),
                    total: venta.total || 0,
                    subtotal: venta.subtotal || 0,
                    // Más propiedades según sea necesario
                };
                
                // Cargar productos de la venta
                actualizarProductosFactura(venta.id_venta);
                
                // Abrir el diálogo
                dialogFactura.open();
            } else {
                showMessage("No se pudo cargar el detalle de la venta");
            }
        } catch (e) {
            showMessage("Error al procesar datos de la venta: " + e);
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
    // Función para obtener datos completos de una venta
    function obtenerDatosVenta(ventaId) {
        // Llamar al modelo Python para obtener los datos de la venta
        try {
            if (ventaModel && typeof ventaModel.get_venta_por_id_json === 'function') {
                var ventaJson = ventaModel.get_venta_por_id_json(ventaId);
                return JSON.parse(ventaJson);
            }
        } catch (e) {
            showMessage("Error al cargar datos de la venta: " + e);
        }
        return {
            codigo: "Error",
            fecha: "",
            cliente: "",
            total: 0,
            estado: "Error"
        };
    }

    // Función para obtener productos de una venta
    function obtenerProductosVenta(ventaId) {
        try {
            if (ventaModel && typeof ventaModel.get_productos_venta_json === 'function') {
                var productosJson = ventaModel.get_productos_venta_json(ventaId);
                var productos = JSON.parse(productosJson);
                console.log("Productos obtenidos:", productos.length);
                return productos;
            }
        } catch (e) {
            showMessage("Error al cargar productos de la venta: " + e);
            console.error("Error al cargar productos:", e);
        }
        return [];
    }

    // Función para actualizar contenido del ListView de productos en la factura
    function actualizarProductosFactura(ventaId) {
        var productos = obtenerProductosVenta(ventaId);
        var productosModel = dialogFactura.productosModel;
        
        productosModel.clear();
        
        for (var i = 0; i < productos.length; i++) {
            productosModel.append(productos[i]);
        }
    }

    // Función para exportar datos (placeholder)
    function exportarDatos(tipo, datos) {
        // Implementación básica para exportar datos
        showMessage("Exportando datos " + tipo + "...");
        // Aquí iría la lógica para exportar a CSV o PDF
        showMessage("Datos exportados correctamente");
    }

    function cargarVariedadesCitricos() {
        // Obtener variedades del modelo Python
        variedadesCitricosModel.clear();
        
        try {
            if (ventaModel && typeof ventaModel.obtener_variedades_disponibles === 'function') {
                var variedades = ventaModel.obtener_variedades_disponibles();
                
                for (var i = 0; i < variedades.length; i++) {
                    if (variedades[i].activo) {
                        variedadesCitricosModel.append({
                            id_variedad: variedades[i].id_variedad,
                            nombre: variedades[i].variedad,
                            nombre_tipo_cultivo: variedades[i].tipo_cultivo,
                            producto_completo: variedades[i].producto_completo
                        });
                    }
                }
            } else {
                console.error("La función obtener_variedades_disponibles no está disponible");
            }
        } catch (e) {
            console.error("Error al cargar variedades: " + e);
        }
    }

    // Propiedades para edición de ventas mostrarFilaEdicionVenta
    property bool mostrarDialogoNuevaVenta: false

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
    Component.onCompleted: {
        // Cargar datos iniciales
        cargarVariedadesCitricos();
        cargarClientesCombo();
        cargarVentasDesdeModelo();
        
        // Actualizar estadísticas y resumen
        actualizarResumenVentas();
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
        
        TabButton {
            id: nuevaVentaTab
            text: "Nueva Venta"
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
            visible: false  // Solo visible cuando se activa
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
                    border.color: "#757575"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 0
                        // Separador
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "#EEEEEE"
                        }
                        
                        // Total de ventas del mes
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 5

                            Text {
                                text: "Ventas del Mes"
                                font.pixelSize: 12
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                            Text {
                                id: txtVentasMes  // Agregar este id
                                text: "Bs. 0"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 22
                                font.bold: true
                            }
                            Text {
                                text: "No hay datos comparativos"
                                font.pixelSize: 11
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "#EEEEEE"
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 5

                            Text {
                                text: "Pagos Pendientes"
                                font.pixelSize: 12
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                id: txtPagosPendientes  // Agregar este id
                                text: "Bs. 0"
                                font.pixelSize: 22
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.bold: true
                                color: "#FF9800"
                            }

                            Text {
                                text: "0 clientes"
                                font.pixelSize: 11
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                        }
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "#EEEEEE"
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 5

                            Text {
                                text: "Ventas Vencidas"
                                font.pixelSize: 12
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                id: txtVentasVencidas  // Agregar este id
                                text: "Bs. 0"
                                font.pixelSize: 22
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.bold: true
                                color: "#F44336"
                            }

                            Text {
                                text: "0 clientes"
                                font.pixelSize: 11
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                        // Separador
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "#EEEEEE"
                        }   
                        // Cliente Top
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 5

                            Text {
                                text: "Cliente Top"
                                font.pixelSize: 12
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                id: txtClienteTop  // Agregar este id
                                text: "Sin datos"
                                font.pixelSize: 18
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.bold: true
                            }
                            
                            Text {
                                text: "0% de las ventas"
                                font.pixelSize: 11
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "#EEEEEE"
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 5

                            Text {
                                text: "Porcentaje Ventas"
                                font.pixelSize: 12
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                id: txtPorcentajeVentas  // Agregar este id
                                text: "0% de las ventas"
                                font.pixelSize: 11
                                Layout.alignment: Qt.AlignHCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: "#757575"
                            }
                        }
                        // Separador
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: "#EEEEEE"
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
                            contentItem: Row {
                                spacing: 5
                                anchors.centerIn: parent
                                Image {
                                    source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
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
                                // Inicializa los valores para la nueva venta
                                nuevaVenta = { 
                                    "ventaId": "", 
                                    "codigo": "V-" + (ventaModel && ventaModel.count ? ventaModel.count + 1 : 1).toString().padStart(4, '0'),
                                    "fecha": Qt.formatDateTime(new Date(), "dd/MM/yyyy"),
                                    "cliente": "",
                                    "total": 0,
                                    "estado": "Pendiente"
                                }
                                
                                // Mostrar la pestana de nueva venta
                                mostrarNuevaVenta();
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
                            // Agregar esto:
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

                            // Agregar esto:
                            onCurrentIndexChanged: {
                                if (currentIndex === 0) {
                                    cargarVentasDesdeModelo(); // Cargar todas las ventas
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
                    
                    //
                    ListView {
                        id: ventasListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ventasListViewModel  // Referencia directa al modelo
    
                        // El Component.onCompleted debe estar a nivel del ListView
                        Component.onCompleted: {
                            cargarVentasDesdeModelo();
                        }
                        headerPositioning: ListView.OverlayHeader
                        
                        // Cabecera de la tabla con las nuevas columnas
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
                                    //leftPadding: a10
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
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Precio 100U"
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
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: "Acciones"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                        
                        // Delegado para cada fila con las nuevas columnas
                        delegate: Rectangle {
                            width: ventasClientesRoot.width
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
                                        text: safeText(model.id_venta || "")
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
                                        text: safeText(model.codigo || "")
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
                                        text: safeText(model.fecha, "")
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Cliente
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: safeText(model.cliente, "")
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Cantidad
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: safeText(model.cantidad, "0")
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Precio 100U
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: model.precio100u ? "Bs. " + model.precio100u : "N/A" // Asumiendo que podría no existir
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
                                        text: "Bs. " + safeText(model.total, 0)
                                        elide: Text.ElideRight
                                        width: parent.width - 20
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
                                            icon.source: "Image/Image_UI_interfaz/Inconos/ojos.svg"
                                            icon.color: "white"
                                            background: Rectangle {
                                                color: "#2196F3"
                                                radius: width / 2
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Ver detalles"
                                            onClicked: {
                                                ventaModel.cargar_venta_por_id(model.id_venta);
                                                // Mostrar diálogo o vista detallada con los datos cargados
                                                verDetalleVenta();
                                            }
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/imprimir.svg"
                                            icon.color: "white"
                                            background: Rectangle {
                                                color: "#4CAF50"
                                                radius: width / 2
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Imprimir"
                                            onClicked: showMessage("Función para imprimir no implementada")
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/gastos.svg"
                                            icon.color: "white"
                                            visible: model.estado !== "Pagada"
                                            background: Rectangle {
                                                color: "#FF9800"
                                                radius: width / 2
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Registrar pago"
                                            onClicked: showMessage("Función para registrar pago no implementada")
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
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: {
                                                // Mostrar confirmación
                                                confirmDialog.text = "¿Está seguro que desea eliminar esta venta?";
                                                confirmDialog.acceptHandler = function() {
                                                    // Llamar al modelo para eliminar
                                                    if (ventaModel.cancelar_venta(model.id_venta, "Eliminada por usuario")) {
                                                        cargarVentasDesdeModelo();
                                                        showMessage("Venta eliminada correctamente");
                                                    } else {
                                                        showMessage("Error al eliminar la venta");
                                                    }
                                                };
                                                confirmDialog.open();
                                                productosVentaModel.remove(index);
                                                actualizarTotalVenta();
                                            }
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
                            visible: ventasListViewModel.count === 0
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
                        model: clientesViewModel
                        Component.onCompleted: {
                            cargarClientesDesdeModelo();
                        }
                        
                        cellWidth: width / 3
                        cellHeight: 200
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay clientes registrados.\nHaga clic en 'Nuevo Cliente' para agregar uno."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: clientesViewModel.count === 0
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
                                        color: model.tipo === "Empresa" ? "#2E7D32" : "#2196F3"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: model.tipo === "Empresa" ? "E" : "P"
                                            color: "white"
                                            font.bold: true
                                        }
                                    }
                                    
                                    Text {
                                        text: model.nombre
                                        font.pixelSize: 16
                                        font.bold: true
                                        Layout.fillWidth: true
                                    }
                                    
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: model.pendiente > 0 ? "#FF9800" : "#4CAF50"
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
                                        text: safeText(model.identificacion)
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
                                        text: model.telefono
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
                                        text: model.ciudad
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
                                            text: "Bs. " + (model.totalCompras || 0)
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
                                            text: "Bs. " + (model.pendiente || 0)
                                            font.pixelSize: 14
                                            font.bold: model.pendiente > 0
                                            color: model.pendiente > 0 ? "#FF9800" : "#4CAF50"
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

            // Página de Nueva Venta
        Item {
            id: nuevaVentaPage
            visible: tabBar.currentIndex === 3  // Ajustar según sea necesario
            // Scroll para todo el contenido
            ScrollView {
                id: scrollViewNuevaVenta
                anchors.fill: parent
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                
                // Contenedor principal
                ColumnLayout {
                    width: scrollViewNuevaVenta.width
                    spacing: 20
                    Layout.margins: 20  // Usar esta propiedad en lugar de anchors.margins

                                    
                    // Título de la página
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "#4CAF50"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: "FACTURA DE VENTA"
                            font.pixelSize: 20
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Formulario con GridLayout para información general
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 6  // Usamos 6 columnas para manejar pares de etiqueta/campo
                        columnSpacing: 15
                        rowSpacing: 15
                        
                        // COLUMNA 1 - 3 filas
                        
                        // Fila 1: Código
                        Text {
                            text: "Código:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: txtCodigoVenta
                            text: nuevaVenta.codigo
                            readOnly: true
                            Layout.preferredWidth: 150
                            background: Rectangle {
                                border.color: "#DDDDDD"
                                border.width: 1
                                radius: 4
                                color: "#F5F5F5"
                            }
                        }
                        
                        // Fila 1: Fecha (COLUMNA 2)
                        Text {
                            text: "Fecha:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: txtFechaVenta
                            text: nuevaVenta.fecha
                            readOnly: false
                            placeholderText: "DD/MM/YYYY"
                            inputMask: "99/99/9999"
                            Layout.preferredWidth: 150
                            background: Rectangle {
                                border.color: "#DDDDDD"
                                border.width: 1
                                radius: 4
                            }
                        }
                        
                        // Fila 1, COLUMNA 3: Producto y Botón
                        ComboBox {
                            id: cmbVariedadCitrico
                            Layout.preferredWidth: 150
                            model: ListModel { id: variedadesCitricosModel }
                            textRole: "nombre"
                            valueRole: "id_variedad"
                            displayText: currentIndex >= 0 ? currentText : "Seleccionar producto"
                            
                            Component.onCompleted: {
                                cargarVariedadesCitricos();
                                currentIndex = -1;
                            }
                        }
                        
                        Button {
                            text: "Añadir"
                            Layout.preferredWidth: 80
                            implicitHeight: 36
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
                            onClicked: {
                                // El mismo código del botón original
                                if (cmbVariedadCitrico.currentIndex < 0) {
                                    mensajeValidacionVenta.text = "Seleccione un producto";
                                    return;
                                }
                                
                                if (!txtCantidadProducto.text || !txtPrecioProducto.text) {
                                    mensajeValidacionVenta.text = "Ingrese cantidad y precio";
                                    return;
                                }
                                
                                var variedad = variedadesCitricosModel.get(cmbVariedadCitrico.currentIndex);
                                var cantidad = parseInt(txtCantidadProducto.text);
                                var precioUnitario = parseFloat(txtPrecioProducto.text);
                                var unidad = cmbUnidadMedida.currentText;
                                
                                var subtotal = (precioUnitario * cantidad) / 100;
                                
                                productosVentaModel.append({
                                    id_variedad: variedad.id_variedad,
                                    nombre: variedad.nombre + " (" + variedad.nombre_tipo_cultivo + ")",
                                    cantidad: cantidad,
                                    unidad: unidad,
                                    precioUnitario: precioUnitario,
                                    subtotal: subtotal
                                });
                                actualizarTotalVenta();
    
                                mensajeValidacionVenta.text = "";
                            }
                        }
                        
                        // Fila 2: Cliente (COLUMNA 1)
                        Text {
                            text: "Cliente:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            id: cmbClienteVenta
                            model: clientesComboModel
                            textRole: "nombre"
                            valueRole: "id"
                            
                            onCurrentIndexChanged: {
                                console.log("Índice actual: " + currentIndex);
                                console.log("Valor actual: " + (currentIndex >= 0 ? currentValue : "ninguno"));
                                console.log("Texto actual: " + (currentIndex >= 0 ? currentText : "ninguno"));
                                
                                if (currentIndex > 0) {  // El índice 0 es "Seleccione cliente"
                                    nuevaVenta.cliente = currentText;
                                    nuevaVenta.id_cliente = currentValue;
                                    console.log("ID de cliente asignado: " + nuevaVenta.id_cliente);
                                } else {
                                    nuevaVenta.cliente = "";
                                    nuevaVenta.id_cliente = null;  // Usar null en lugar de 0
                                }
                            }
                        }
                        
                        // Fila 2: Estado de venta (COLUMNA 2)
                        Text {
                            text: "Estado de venta:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            id: cmbEstadoVenta
                            model: ListModel { id: estadosVentaModel }
                            textRole: "nombre"
                            valueRole: "id"
                            Layout.preferredWidth: 150
                            
                            onCurrentIndexChanged: {
                                if (currentIndex >= 0) {
                                    nuevaVenta.estado = currentText;
                                    nuevaVenta.id_estado = currentValue;
                                    console.log("Estado seleccionado: " + currentText + " (ID: " + currentValue + ")");
                                }
                            }
                            
                            Component.onCompleted: {
                                cargarEstadosVenta();
                                currentIndex = 0; // Seleccionar "En Proceso" por defecto
                            }
                        }
                                                
                        // Fila 2, COLUMNA 3: Cantidad y Precio
                        TextField {
                            id: txtCantidadProducto
                            Layout.preferredWidth: 100
                            placeholderText: "Cantidad"
                            validator: IntValidator { bottom: 1 }
                        }
                        
                        TextField {
                            id: txtPrecioProducto
                            Layout.preferredWidth: 100
                            placeholderText: "Precio/100u"
                            validator: DoubleValidator { bottom: 0.01 }
                        }
                        
                        // Fila 3: Estado de pago (COLUMNA 1)
                        Text {
                            text: "Estado de pago:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            id: cmbEstadoPago
                            model: ["Pendiente", "Parcial", "Pagado"]
                            Layout.preferredWidth: 150
                            onCurrentTextChanged: nuevaVenta.estado_pago = currentText
                        }
                        
                        // Fila 3: Condiciones de pago (COLUMNA 2)
                        Text {
                            text: "Condiciones de pago:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: txtCondicionesPago
                            placeholderText: "Ej: 30 días, contado, etc."
                            Layout.preferredWidth: 150
                        }
                        
                        // Fila 3, COLUMNA 3: Unidad y Fecha de entrega
                        ComboBox {
                            id: cmbUnidadMedida
                            Layout.preferredWidth: 80
                            model: ["Kg", "Ton", "Unidad"]
                            currentIndex: 0
                        }
                        
                        RowLayout {
                            spacing: 5
                            
                            Text {
                                text: "Entrega:"
                                font.pixelSize: 14
                            }
                            
                            TextField {
                                id: txtFechaEntrega
                                placeholderText: "DD/MM/YYYY"
                                inputMask: "99/99/9999"
                                Layout.preferredWidth: 95
                            }
                        }
                        
                        // Fila 4: Solo el campo de lugar de entrega
                        Text {
                            text: "Lugar de entrega:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: txtLugarEntrega
                            placeholderText: "Dirección de entrega"
                            Layout.preferredWidth: 150
                            Layout.columnSpan: 5
                            Layout.fillWidth: true
                        }
                    }
                                
                    // Tabla de productos
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        border.color: "#DDDDDD"
                        border.width: 1
                        radius: 5
                        
                        ListView {
                            id: listaProductosVenta
                            anchors.fill: parent
                            anchors.margins: 5
                            clip: true
                            model: ListModel { id: productosVentaModel }
                            
                            header: Rectangle {
                                width: parent.width
                                height: 30
                                color: "#f5f5f5"
                                
                                Row {
                                    anchors.fill: parent
                                    
                                    Text { 
                                        width: parent.width * 0.05
                                        height: parent.height
                                        text: "ID"
                                        font.bold: true
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.30
                                        height: parent.height
                                        text: "Producto"
                                        font.bold: true
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 5
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.15
                                        height: parent.height
                                        text: "Cantidad" 
                                        font.bold: true
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignCenter
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.15
                                        height: parent.height
                                        text: "Precio 100u" 
                                        font.bold: true
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignCenter
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.15
                                        height: parent.height
                                        text: "Subtotal" 
                                        font.bold: true
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignCenter
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.20
                                        height: parent.height
                                        text: "Acciones" 
                                        font.bold: true
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignCenter
                                    }
                                }
                            }
                            
                            delegate: Rectangle {
                                width: parent.width
                                height: 40
                                color: index % 2 === 0 ? "white" : "#f9f9f9"
                                
                                Row {
                                    anchors.fill: parent
                                    
                                    Text { 
                                        width: parent.width * 0.05
                                        height: parent.height
                                        text: index + 1
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.30
                                        height: parent.height
                                        text: nombre
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 5
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.15
                                        height: parent.height
                                        text: cantidad + " " + unidad
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignCenter
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.15
                                        height: parent.height
                                        text: "Bs. " + precioUnitario.toFixed(2)
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignCenter
                                    }
                                    
                                    Text { 
                                        width: parent.width * 0.15
                                        height: parent.height
                                        text: "Bs. " + subtotal.toFixed(2)
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignCenter
                                    }
                                    
                                    Row {
                                        width: parent.width * 0.20
                                        height: parent.height
                                        spacing: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        layoutDirection: Qt.RightToLeft
                                        rightPadding: 5
                                        
                                        Button {
                                            width: 28
                                            height: 28
                                            icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                            icon.color: "white"
                                            anchors.verticalCenter: parent.verticalCenter
                                            background: Rectangle {
                                                color: "#F44336"
                                                radius: width / 2
                                            }
                                            onClicked: {
                                                productosVentaModel.remove(index);
                                                actualizarTotalVenta();
                                            }
                                        }
                                        
                                        Button {
                                            width: 28
                                            height: 28
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            icon.color: "white"
                                            anchors.verticalCenter: parent.verticalCenter
                                            background: Rectangle {
                                                color: "#2196F3"
                                                radius: width / 2
                                            }
                                            onClicked: {
                                                // Aquí iría lógica para editar producto
                                                // Por simplicidad, podemos implementarlo después
                                                showMessage("Edición de producto no implementada");
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Mensaje cuando no hay productos
                            Text {
                                anchors.centerIn: parent
                                text: "No hay productos agregados a la venta.\nUse el formulario superior para agregar productos."
                                color: "#757575"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                visible: productosVentaModel.count === 0
                            }
                        }
                    }                   
                    // Resumen de totales
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 15
                        rowSpacing: 15
                        
                        Item { Layout.fillWidth: true }
                        
                        GridLayout {
                            columns: 2
                            columnSpacing: 15
                            rowSpacing: 10
                            Layout.alignment: Qt.AlignRight
                            Layout.preferredWidth: 300
                            
                            // Subtotal
                            Text {
                                text: "Subtotal:"
                                Layout.alignment: Qt.AlignRight
                                font.pixelSize: 14
                            }
                            
                            TextField {
                                id: txtSubtotalVenta
                                text: "0.00"
                                readOnly: true
                                Layout.preferredWidth: 150
                                horizontalAlignment: Text.AlignRight
                                background: Rectangle {
                                    border.color: "#DDDDDD"
                                    border.width: 1
                                    radius: 4
                                    color: "#F5F5F5"
                                }
                            }
                            
                            // Total
                            Text {
                                text: "Total:"
                                Layout.alignment: Qt.AlignRight
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            TextField {
                                id: txtTotalVenta
                                text: "0.00"
                                readOnly: true
                                Layout.preferredWidth: 150
                                horizontalAlignment: Text.AlignRight
                                font.bold: true
                                background: Rectangle {
                                    border.color: "#DDDDDD"
                                    border.width: 1
                                    radius: 4
                                    color: "#F0F7FF"
                                }
                            }
                        }
                    }
                    // Información del usuario actual
                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        color: "#edf7ed"  // Color verde claro para que coincida con tu tema
                        radius: 5
                        
                        Text {
                            id: currentUserActiveLabel  // Cambié el nombre del ID para que sea único
                            text: "Usuario actual: " + (ventaModel && ventaModel.current_user_name ? ventaModel.current_user_name : "Usuario Desconocido")
                            font.pixelSize: 12
                            color: "#2E7D32"  // Verde que coincide con tu tema
                            anchors.centerIn: parent
                        }
                    }
                    
                    // Sección de observaciones
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        color: "#e8f5e9"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: "OBSERVACIONES"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#2E7D32"
                        }
                    }
                    
                    // Observaciones
                    TextArea {
                        id: txtObservacionesVenta
                        Layout.fillWidth: true
                        height: 100
                        placeholderText: "Ingrese observaciones o notas adicionales sobre esta venta..."
                        wrapMode: TextEdit.Wrap
                        background: Rectangle {
                            border.color: "#DDDDDD"
                            border.width: 1
                            radius: 4
                        }
                    }

                    // Información del usuario actual - ESTE ES EL CÓDIGO NUEVO
                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        color: "#edf7ed"  // Color verde claro para que coincida con tu tema
                        radius: 5
                        
                        Text {
                            id: currentUserLabel
                            text: "Usuario actual: " + (ventaModel && ventaModel.current_user_name ? ventaModel.current_user_name : "Usuario Desconocido")
                            font.pixelSize: 12
                            color: "#2E7D32"  // Verde que coincide con tu tema
                            anchors.centerIn: parent
                        }
                    }

                    // Mensaje de validación
                    Text {
                        id: mensajeValidacionVenta
                        Layout.fillWidth: true
                        text: ""
                        color: "red"
                        visible: text !== ""
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14
                    }
                    

                    
                    
                    // Botones de acción
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        spacing: 15
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Cancelar"
                            implicitHeight: 40
                            implicitWidth: 120
                            background: Rectangle {
                                color: "#EEEEEE"
                                radius: height / 2
                            }
                            contentItem: Text {
                                text: parent.text
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                // Volver a la pestaña de ventas
                                tabBar.currentIndex = 0;
                                nuevaVentaTab.visible = false;
                            }
                        }
                        //
                        
                        Button {
                            text: "Guardar"
                            implicitHeight: 40
                            implicitWidth: 120
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            contentItem: Row {
                                spacing: 5
                                anchors.centerIn: parent
                                Image {
                                    source: "Image/Image_UI_interfaz/Inconos/hogar.png"
                                    width: 18
                                    height: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Guardar"
                                    color: "white"
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            onClicked: {
                                // Debugging - imprimir valores
                                console.log("Cliente seleccionado index: " + cmbClienteVenta.currentIndex);
                                console.log("Cliente seleccionado text: " + cmbClienteVenta.currentText);
                                console.log("Cliente seleccionado value: " + (cmbClienteVenta.currentIndex >= 0 ? cmbClienteVenta.currentValue : "ninguno"));
                                
                                // Validación de datos
                                if (cmbClienteVenta.currentIndex <= 0) {
                                    mensajeValidacionVenta.text = "Por favor, seleccione un cliente";
                                    return;
                                }
                                
                                // Obtener ID directamente del ComboBox en lugar de nuevaVenta
                                var clienteID = cmbClienteVenta.currentValue;
                                console.log("ID del cliente obtenido directamente: " + clienteID);
                                
                                if (!clienteID) {
                                    mensajeValidacionVenta.text = "Seleccione un cliente válido";
                                    return;
                                }
                                
                                if (productosVentaModel.count === 0) {
                                    mensajeValidacionVenta.text = "Debe agregar al menos un producto a la venta";
                                    return;
                                }
                                
                                if (parseFloat(txtTotalVenta.text) <= 0) {
                                    mensajeValidacionVenta.text = "El total debe ser mayor a cero";
                                    return;
                                }
                                
                                if (txtFechaEntrega.text !== "" && !validarFecha(txtFechaEntrega.text)) {
                                    mensajeValidacionVenta.text = "El formato de fecha de entrega debe ser DD/MM/AAAA";
                                    return;
                                }
                                
                                // Preparar objeto venta completo
                                var venta = {
                                    id_cliente: clienteID, // Usar el valor obtenido directamente del ComboBox
                                    codigo_venta: txtCodigoVenta.text,
                                    fecha_venta: formatearFechaBD(txtFechaVenta.text),
                                    subtotal: parseFloat(txtSubtotalVenta.text),
                                    total: parseFloat(txtTotalVenta.text),
                                    condiciones_pago: txtCondicionesPago.text,
                                    fecha_entrega: txtFechaEntrega.text ? formatearFechaBD(txtFechaEntrega.text) : "",
                                    lugar_entrega: txtLugarEntrega.text || "",
                                    id_estado: obtenerIdEstado(cmbEstadoVenta.currentText),
                                    estado_pago: cmbEstadoPago.currentText,
                                    observaciones: txtObservacionesVenta.text || "",
                                    registrado_por: 1  // ID del usuario actual (habría que obtenerlo de algún sistema de autenticación)
                                };
                                
                                // Preparar detalles de venta
                                var detalles = [];
                                for (var i = 0; i < productosVentaModel.count; i++) {
                                    var producto = productosVentaModel.get(i);
                                    detalles.push({
                                        id_variedad: producto.id_variedad,
                                        cantidad: producto.cantidad,
                                        unidad_medida: producto.unidad,
                                        precio_unitario: producto.precioUnitario,
                                        subtotal: producto.subtotal,
                                        total: producto.subtotal,
                                        observaciones: ""
                                    });
                                }
                                
                                // Convertir a JSON para enviar al modelo Python
                                var ventaJSON = JSON.stringify(venta);
                                var detallesJSON = JSON.stringify(detalles);
                                
                                // Agregar logs para debugging
                                console.log("Enviando venta JSON:", ventaJSON);
                                console.log("Enviando detalles JSON:", detallesJSON);
                                
                                // Llamar al modelo Python para guardar
                                var success = ventaModel.agregar_venta(ventaJSON, detallesJSON);
                                
                                if (success) {
                                    // Actualizar la lista de ventas
                                    cargarVentasDesdeModelo();
                                    
                                    // Limpiar formulario y volver a la lista de ventas
                                    limpiarFormularioVenta();
                                    
                                    // Mostrar mensaje de éxito
                                    showMessage("Venta registrada correctamente");
                                    
                                    // Volver a la pestaña de ventas
                                    tabBar.currentIndex = 0;
                                    nuevaVentaTab.visible = false;
                                } else {
                                    mensajeValidacionVenta.text = "Error al guardar la venta";
                                }
                            }
                        }                       
                        Button {
                            text: "Guardar e Imprimir"
                            implicitHeight: 40
                            implicitWidth: 180
                            background: Rectangle {
                                color: "#FF9800"
                                radius: height / 2
                            }
                            contentItem: Row {
                                spacing: 5
                                anchors.centerIn: parent
                                Image {
                                    source: "Image/Image_UI_interfaz/Inconos/imprimir.svg"
                                    width: 18
                                    height: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Guardar e Imprimir"
                                    color: "white"
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            onClicked: {
                                // Primero guardar, luego imprimir
                                // Por ahora solo mostramos mensaje
                                showMessage("Función para guardar e imprimir no implementada");

                            }
                        }
                    }
                }
            }
        }
    
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
  

    //
    Dialog {
        id: dialogNuevoCliente
        title: "Nuevo Cliente"
        modal: true
        anchors.centerIn: parent
        width: 800
        height: 600
        visible: mostrarNuevoCliente

        onClosed: mostrarNuevoCliente = false

        contentItem: Rectangle {
            color: "white"

            // ScrollView para hacer el contenido desplazable
            ScrollView {
                id: scrollViewCliente
                anchors.fill: parent
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                // Contenedor principal de nuevo cliente
                Column {
                    id: contenedorCliente
                    width: scrollViewCliente.width
                    spacing: 20
                    topPadding: 20
                    bottomPadding: 20
                    leftPadding: 20
                    rightPadding: 20

                    Text {
                        width: parent.width - 40
                        text: "Registro de Nuevo Cliente"
                        font.pixelSize: 18
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Sección de tipo de cliente
                    Rectangle {
                        width: parent.width - 40
                        height: 40
                        color: "#e3f2fd"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: "TIPO DE CLIENTE"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1565C0"
                        }
                    }

                    // Selector de tipo de cliente
                    RowLayout {
                        width: parent.width - 40
                        spacing: 20
                        
                        Text {
                            text: "Seleccione tipo de cliente:"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        RadioButton {
                            id: rbPersona
                            checked: true
                            text: "Persona"
                            onCheckedChanged: {
                                if (checked) {
                                    nuevoCliente.tipo = "Persona"
                                    
                                }
                            }
                        }
                        
                        RadioButton {
                            id: rbEmpresa
                            text: "Empresa"
                            onCheckedChanged: {
                                if (checked) {
                                    nuevoCliente.tipo = "Empresa"
                                
                                }
                            }
                        }
                    }

                    // Sección de información personal
                    Rectangle {
                        width: parent.width - 40
                        height: 40
                        color: "#e3f2fd"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: "INFORMACIÓN PERSONAL"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1565C0"
                        }
                    }

                    // Formulario con GridLayout
                    GridLayout {
                        width: parent.width - 40
                        columns: 4
                        columnSpacing: 10
                        rowSpacing: 15

                        // Nombre completo
                        Text {
                            text: "Nombre:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtNombreCliente
                            placeholderText: "Nombre completo o razón social"
                            Layout.columnSpan: 3
                            Layout.fillWidth: true
                        }

                        // Identificación
                        Text {
                            text: "Identificación:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtIdentificacion
                            placeholderText: "Cédula o RIF"
                            Layout.fillWidth: true
                        }
                        
                        // Fecha de registro
                        Text {
                            text: "Fecha de registro:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtFechaRegistro
                            text: getFormattedDate()
                            readOnly: true
                            Layout.fillWidth: true
                            background: Rectangle {
                                border.color: "#DDDDDD"
                                border.width: 1
                                radius: 4
                                color: "#F5F5F5"
                            }
                        }

                        // Espacio vacío para mantener la disposición
                        Item {
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            visible: !rbEmpresa.checked
                        }

                        // Teléfono
                        Text {
                            text: "Teléfono:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtTelefono
                            placeholderText: "Número de teléfono"
                            Layout.fillWidth: true
                            inputMethodHints: Qt.ImhDigitsOnly
                        }

                        // Correo electrónico
                        Text {
                            text: "Correo electrónico:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtCorreoCliente
                            placeholderText: "Correo electrónico"
                            Layout.fillWidth: true
                            inputMethodHints: Qt.ImhEmailCharactersOnly
                        }
                    }

                    // Sección de dirección
                    Rectangle {
                        width: parent.width - 40
                        height: 40
                        color: "#e3f2fd"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: "DIRECCIÓN"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1565C0"
                        }
                    }

                    // Formulario de dirección
                    GridLayout {
                        width: parent.width - 40
                        columns: 4
                        columnSpacing: 10
                        rowSpacing: 15

                        // Dirección completa
                        Text {
                            text: "Dirección:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtDireccion
                            placeholderText: "Dirección completa"
                            Layout.columnSpan: 3
                            Layout.fillWidth: true
                        }

                        // Ciudad
                        Text {
                            text: "Ciudad:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtCiudad
                            placeholderText: "Ciudad"
                            Layout.fillWidth: true
                        }

                        // Estado/Provincia
                        Text {
                            text: "Estado/Provincia:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtEstadoProvincia
                            placeholderText: "Estado o provincia"
                            Layout.fillWidth: true
                        }
                        
                    }

                    // Sección de información comercial
                    Rectangle {
                        width: parent.width - 40
                        height: 40
                        color: "#e3f2fd"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: "INFORMACIÓN COMERCIAL"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1565C0"
                        }
                    }

                    // Formulario de información comercial
                    GridLayout {
                        width: parent.width - 40
                        columns: 4
                        columnSpacing: 10
                        rowSpacing: 15

                        // Condiciones de pago
                        Text {
                            text: "Condiciones de pago:"
                            Layout.alignment: Qt.AlignRight
                            font.pixelSize: 14
                        }

                        TextField {
                            id: txtCondicionesPagoCliente
                            placeholderText: "Ej: 30 días, contado, etc."
                            Layout.columnSpan: 3
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Bs."
                            Layout.alignment: Qt.AlignLeft
                        }
                        
                        // Espacio para mantener alineación
                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    // Sección de notas
                    Rectangle {
                        width: parent.width - 40
                        height: 40
                        color: "#e3f2fd"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: "NOTAS ADICIONALES"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1565C0"
                        }
                    }

                    // Campo de notas
                    TextArea {
                        id: txtNotasCliente
                        width: parent.width - 40
                        height: 100
                        placeholderText: "Ingrese notas o información adicional sobre este cliente..."
                        wrapMode: TextEdit.Wrap
                        background: Rectangle {
                            border.color: "#DDDDDD"
                            border.width: 1
                            radius: 4
                        }
                    }

                    // Mensaje de validación
                    Text {
                        id: mensajeValidacion
                        width: parent.width - 40
                        text: ""
                        color: "red"
                        visible: text !== ""
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14
                    }
                }
            }
        }

        footer: DialogButtonBox {
            background: Rectangle {
                color: "#F8F9FA"
                height: 60
            }
            padding: 10

            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                implicitHeight: 40
                background: Rectangle {
                    color: "#EEEEEE"
                    radius: height / 2
                }
                contentItem: Text {
                    text: parent.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: dialogNuevoCliente.close()
            }

            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                implicitHeight: 40
                background: Rectangle {
                    color: "#2196F3"
                    radius: height / 2
                }
                contentItem: Row {
                    spacing: 5
                    anchors.centerIn: parent
                    Image {
                        source: "Image/Image_UI_interfaz/Inconos/sobre.svg" //agregar un icono de guardar
                        width: 18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Guardar"
                        color: "white"
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                onClicked: {
                    // Validación de campos obligatorios
                    if (txtNombreCliente.text.trim() === "") {
                        mensajeValidacion.text = "Por favor, ingrese el nombre del cliente";
                        return;
                    }

                    if (txtIdentificacion.text.trim() === "") {
                        mensajeValidacion.text = "Por favor, ingrese la identificación del cliente";
                        return;
                    }

                    if (txtTelefono.text.trim() === "") {
                        mensajeValidacion.text = "Por favor, ingrese un número de teléfono";
                        return;
                    }

                    // Validación de correo electrónico si se proporcionó
                    if (txtCorreoCliente.text.trim() !== "") {
                        var emailRegex = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
                        if (!emailRegex.test(txtCorreoCliente.text)) {
                            mensajeValidacion.text = "El formato del correo electrónico no es válido";
                            return;
                        }
                    }
                                

                    // Preparar objeto de cliente para guardar
                    var cliente = {
                        tipo: rbEmpresa.checked ? "Empresa" : "Persona",
                        nombre: txtNombreCliente.text,
                        identificacion: txtIdentificacion.text,
                        telefono: txtTelefono.text,
                        correo: txtCorreoCliente.text,
                        direccion: txtDireccion.text,
                        ciudad: txtCiudad.text,
                        estado_provincia: txtEstadoProvincia.text,
                        condiciones_pago: txtCondicionesPagoCliente.text,
                        notas: txtNotasCliente.text,
                        fecha_registro: formatearFechaBD(txtFechaRegistro.text),
                        registrado_por: 1  
                    };
                    
                    // Convertir a JSON y guardar usando el modelo Python
                    var clienteJSON = JSON.stringify(cliente);
                    var success = ventaModel.agregar_cliente(clienteJSON);
                    
                    if (success) {
                        // Recargar la lista de clientes y el combo
                        cargarClientesCombo();
                        
                        // Mensaje de éxito
                        showMessage("Cliente registrado correctamente");
                        
                        // Cerrar el diálogo
                        dialogNuevoCliente.close();
                    } else {
                        mensajeValidacion.text = "Error al registrar el cliente";
                    }
                }
            }
        }
    }
    // Diálogo para mostrar la factura
    Dialog {
        id: dialogFactura
        title: "Factura"
        width: 600
        height: 800
        
        property var facturaDatos: null
        property ListModel productosModel: ListModel { id: facturaProductosModel }
        
        contentItem: ScrollView {
            anchors.fill: parent
            
            // Diseño simple de factura
            ColumnLayout {
                width: parent.width
                spacing: 10
                
                // Cabecera
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#f5f5f5"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        Text {
                            text: "FACTURA"
                            font.pixelSize: 24
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: "Nº " + (dialogFactura.facturaDatos ? dialogFactura.facturaDatos.codigo : "")
                            font.pixelSize: 16
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
                
                // Información básica
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    Layout.margins: 10
                    
                    Text { text: "Fecha:" }
                    Text { text: dialogFactura.facturaDatos ? safeText(dialogFactura.facturaDatos.fecha_venta, "") : "" }
                    
                    Text { text: "Cliente:" }
                    Text { text: dialogFactura.facturaDatos ? safeText(dialogFactura.facturaDatos.cliente_nombre, "") : "" }
                    
                    Text { text: "Estado:" }
                    Text { 
                        text: dialogFactura.facturaDatos ? safeText(dialogFactura.facturaDatos.estado_nombre, "") : "" 
                        color: dialogFactura.facturaDatos ? getEstadoColor(safeText(dialogFactura.facturaDatos.estado_nombre, "")) : "#000000"
                    }
                }
                
                // Productos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    border.color: "#dddddd"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 5
                        model: dialogFactura.productosModel
                        clip: true
                        
                        header: Rectangle {
                            width: parent.width
                            height: 30
                            color: "#f0f0f0"
                            
                            Row {
                                anchors.fill: parent
                                
                                Text { width: parent.width * 0.05; text: "#"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                Text { width: parent.width * 0.35; text: "Producto"; font.bold: true; horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter; leftPadding: 5 }
                                Text { width: parent.width * 0.15; text: "Cantidad"; font.bold: true; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                Text { width: parent.width * 0.20; text: "Precio"; font.bold: true; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                Text { width: parent.width * 0.25; text: "Subtotal"; font.bold: true; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter; rightPadding: 5 }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 30
                            color: index % 2 === 0 ? "#ffffff" : "#f9f9f9"
                            
                            Row {
                                anchors.fill: parent
                                
                                Text { width: parent.width * 0.05; text: index + 1; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                Text { width: parent.width * 0.35; text: model.nombre; horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter; leftPadding: 5; elide: Text.ElideRight }
                                Text { width: parent.width * 0.15; text: model.cantidad + " " + model.unidad; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                Text { width: parent.width * 0.20; text: "Bs. " + model.precio_unitario; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                Text { width: parent.width * 0.25; text: "Bs. " + model.subtotal; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter; rightPadding: 5 }
                            }
                        }
                    }
                }
                
                // Totales
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "#f5f5f5"
                    
                    GridLayout {
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        columns: 2
                        
                        Text { text: "Total:"; font.bold: true }
                        Text { 
                            text: dialogFactura.facturaDatos ? 
                                "Bs. " + (dialogFactura.facturaDatos.total || 0).toFixed(2) : "Bs. 0.00"
                            font.bold: true 
                        }
                    }
                }
            }
        }
        
        // Botones para imprimir/exportar
        footer: DialogButtonBox {
            Button {
                text: "Cerrar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Imprimir"
                DialogButtonBox.buttonRole: DialogButtonBox.ApplyRole
                onClicked: showMessage("Función de impresión no implementada")
            }
            
            Button {
                text: "Exportar PDF"
                DialogButtonBox.buttonRole: DialogButtonBox.ActionRole
                onClicked: exportarDatos("PDF", dialogFactura.facturaDatos)
            }
        }
        
        onOpened: {
            if (facturaDatos && facturaDatos.id_venta) {
                actualizarProductosFactura(facturaDatos.id_venta);
            }
        }
    }
    // AGREGAR AL FINAL DEL ARCHIVO:
    Dialog {
        id: confirmDialog
        title: "Confirmar"
        
        property string text: ""
        property var acceptHandler: null
        
        Label {
            text: confirmDialog.text
            wrapMode: Text.Wrap
            width: parent.width
        }
        
        standardButtons: Dialog.Yes | Dialog.No
        
        onAccepted: {
            if (acceptHandler) {
                acceptHandler();
            }
        }
    }

    function calcularTotal() {
        var cantidad = parseInt(txtCantidadVenta.text) || 0
        var precio100u = parseFloat(txtPrecio100uVenta.text) || 0
        
        // Calcular el total (precio por 100 unidades * cantidad / 100)
        var total = (precio100u * cantidad) / 100
        
        // Actualizar campo de total
        txtSubtotalVenta.text = total.toFixed(2)
        txtTotalVenta.text = total.toFixed(2)
        nuevaVenta.cantidad = cantidad
        nuevaVenta.precio100u = precio100u
        nuevaVenta.total = total
    }
    function actualizarTotalVenta() {
        // 1. Calcular subtotal sumando todos los productos
        var subtotal = 0;
        
        // Añadir log para depuración
        console.log("Calculando total de " + productosVentaModel.count + " productos");
        
        for (var i = 0; i < productosVentaModel.count; i++) {
            var producto = productosVentaModel.get(i);
            var productoSubtotal = parseFloat(producto.subtotal) || 0;
            
            // Log para depuración
            console.log("Producto " + i + ": " + producto.nombre + " - Subtotal: " + productoSubtotal);
            
            subtotal += productoSubtotal;
        }
        
        // Log del subtotal calculado
        console.log("Subtotal calculado: " + subtotal);
        
        // 2. Calcular total final (sin descuento ni impuestos por ahora)
        var total = subtotal;
        
        // 3. Actualizar la UI y el modelo
        txtSubtotalVenta.text = subtotal.toFixed(2);
        txtTotalVenta.text = total.toFixed(2);
        nuevaVenta.total = total;
        
        // 4. Actualizar también los campos de total global al final de la página
        // Busca estos elementos en tu UI y actualízalos
        if (typeof subtotalGlobal !== "undefined") {
            subtotalGlobal.text = subtotal.toFixed(2);
        }
        if (typeof totalGlobal !== "undefined") {
            totalGlobal.text = total.toFixed(2);
        }
    }

    // Función para guardar nueva venta
    function guardarNuevaVenta() {
        // Esta función ahora solo sirve como puente hacia el modal
        if (mostrarDialogoNuevaVenta) {
            // Si ya está abierto el diálogo, intentar guardar desde ahí
            return;
        }
        
        // Si no, abrir el diálogo de nueva venta
        nuevaVenta = { 
            "ventaId": "", 
            "codigo": "V-" + (ventaModel && ventaModel.count ? ventaModel.count + 1 : 1).toString().padStart(4, '0'),
            "fecha": Qt.formatDateTime(new Date(), "dd/MM/yyyy"),
            "cliente": "",
            "total": 0,
            "estado": "Pendiente"
        }
        
        mostrarDialogoNuevaVenta = true;
    }                        
    
    // Función para determinar el color de estado
    function getEstadoColor(estado) {
        estado = estado || "";
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
    // Función para formatear la fecha
    function getFormattedDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
        var yyyy = today.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
    }
    // Función para mostrar mensajes
    function showMessage(message) {
        messageToast.text = message
        messageToast.visible = true
        messageToastTimer.restart()
    }

    // Función para validar el formato de fecha
    function validarFecha(fecha) {
        var regex = /^(\d{2})\/(\d{2})\/(\d{4})$/;
        if (!regex.test(fecha)) {
            return false;
        }
            
        var partes = fecha.split('/');
        var dia = parseInt(partes[0], 10);
        var mes = parseInt(partes[1], 10) - 1;
        var anio = parseInt(partes[2], 10);
            
        var date = new Date(anio, mes, dia);
        return date.getDate() === dia && 
            date.getMonth() === mes && 
            date.getFullYear() === anio;
    }
    // carga las variedades en la factura o nueva venta
    
    // Función para mostrar la pestaña de nueva venta
    function mostrarNuevaVenta() {
        nuevaVentaTab.visible = true;
        tabBar.currentIndex = 3;  // Índice de la nueva pestaña
    }

    // Función para generar factura (vista previa)
    function verFactura(ventaId) {
        // Obtener datos de la venta
        var venta = obtenerDatosVenta(ventaId);
        
        // Mostrar vista previa de factura
        dialogFactura.facturaDatos = venta;
        dialogFactura.open();
    }
    // funcion para cargar los estados de venta
    function cargarEstadosVenta() {
        // Limpiar el modelo actual
        estadosVentaModel.clear();
        
        // Obtener estados desde el backend
        var estadosJson = safeGetModelData("get_estados_venta_json");
        try {
            var estados = JSON.parse(estadosJson);
            console.log("Estados de venta cargados: " + estados.length);
            
            for (var i = 0; i < estados.length; i++) {
                estadosVentaModel.append({
                    id: estados[i].id_estado,
                    nombre: estados[i].nombre
                });
            }
        } catch (e) {
            console.error("Error al cargar estados de venta: " + e);
            // Agregar opciones predeterminadas como fallback
            estadosVentaModel.append({id: 1, nombre: "En Proceso"});
            estadosVentaModel.append({id: 2, nombre: "Facturada"});
            estadosVentaModel.append({id: 3, nombre: "Despachada"});
        }
    }

    // Función para cargar clientes al combo
    function cargarClientesCombo() {
        clientesComboModel.clear();
        clientesComboModel.append({id: -1, nombre: "Seleccione cliente"});
        
        var clientesJson = safeGetModelData("get_clientes_json");

        try {
            var clientes = JSON.parse(clientesJson);
            
            for (var i = 0; i < clientes.length; i++) {
                if (clientes[i].activo !== false) {
                    // Debug: Imprimir valores para verificar
                    console.log("Agregando cliente: ID=" + clientes[i].id_cliente + ", Nombre=" + clientes[i].nombre);
                    
                    // Asegúrate de que el id_cliente se está agregando correctamente
                    clientesComboModel.append({
                        id: clientes[i].id_cliente,
                        nombre: clientes[i].nombre
                    });
                }
            }
        } catch (e) {
            console.error("Error al cargar clientes: " + e);
            showMessage("Error al cargar la lista de clientes");
        }
    }
    function obtenerIdEstado(estadoTexto) {
        // Mapear estados a IDs según tu base de datos
        var estados = {
            "En Proceso": 1,
            "Facturada": 2, 
            "Despachada": 3
        };
        
        // Agregar logging para debugging
        console.log("Mapeando estado: " + estadoTexto + " a ID: " + estados[estadoTexto]);
        
        // Si el estado no está en el diccionario, usar 1 como valor por defecto
        return estados[estadoTexto] || 1;
    }

    function calcularCantidadTotal() {
        var total = 0;
        for (var i = 0; i < productosVentaModel.count; i++) {
            total += productosVentaModel.get(i).cantidad;
        }
        return total;
    }

    function obtenerPrecioPromedio() {
        if (productosVentaModel.count === 0) return 0;
        var total = 0;
        for (var i = 0; i < productosVentaModel.count; i++) {
            total += productosVentaModel.get(i).precioUnitario;
        }
        return total / productosVentaModel.count;
    }

    function limpiarFormularioVenta() {
        productosVentaModel.clear();
        txtFechaVenta.text = Qt.formatDateTime(new Date(), "dd/MM/yyyy");
        cmbClienteVenta.currentIndex = 0;
        cmbEstadoVenta.currentIndex = 0;
        cmbEstadoPago.currentIndex = 0;
        txtCondicionesPago.text = "";
        txtFechaEntrega.text = "";
        txtLugarEntrega.text = "";
        txtObservacionesVenta.text = "";
    }
    function formatearFechaBD(fecha) {
        // Convierte de "DD/MM/YYYY" a "YYYY-MM-DD"
        var partes = fecha.split("/");
        if (partes.length === 3) {
            return partes[2] + "-" + partes[1] + "-" + partes[0];
        }
        return fecha; // Si el formato es incorrecto, devolver original
    }
}