
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal 2.15
import "./components"

Rectangle {
    id: finanzasRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    property int tabActiva: 0
    property var tabsInfo: [{"text": "Flujo de Caja", "icon": "recursos/image/icons/moneda.png", "color": "#009688"}]
    
    property string textoBusqueda: ""
    property string filtroTipo: "Todos"
    property string filtroCategoria: "Todas"
    property string filtroFechaInicio: ""
    property string filtroFechaFin: ""
    
    property int itemsPorPagina: 15
    property int paginaActual: 1
    property int totalPaginas: 1
    
    property var movimientosFiltrados: []
    property var movimientosPaginados: []
    
    function filtrarMovimientos() {
        if (typeof movimientosFinancierosModel === 'undefined' || !movimientosFinancierosModel.movimientos) {
            movimientosFiltrados = []
            return
        }
        
        let resultado = movimientosFinancierosModel.movimientos.filter(function(mov) {
            if (textoBusqueda !== "") {
                let busqueda = textoBusqueda.toLowerCase()
                let desc = (mov.descripcion || "").toLowerCase()
                let cat = (mov.categoria_nombre || "").toLowerCase()
                if (!desc.includes(busqueda) && !cat.includes(busqueda)) return false
            }
            
            if (filtroTipo !== "Todos") {
                if (filtroTipo === "Ingreso" && mov.es_gasto) return false
                if (filtroTipo === "Egreso" && !mov.es_gasto) return false
            }
            
            if (filtroCategoria !== "Todas" && mov.categoria_nombre !== filtroCategoria) return false
            
            if (filtroFechaInicio !== "" && new Date(mov.fecha_movimiento) < new Date(filtroFechaInicio)) return false
            if (filtroFechaFin !== "" && new Date(mov.fecha_movimiento) > new Date(filtroFechaFin)) return false
            
            return true
        })
        
        movimientosFiltrados = resultado
        totalPaginas = Math.max(1, Math.ceil(resultado.length / itemsPorPagina))
        if (paginaActual > totalPaginas) paginaActual = 1
        actualizarMovimientosPaginados()
    }
    
    function actualizarMovimientosPaginados() {
        let inicio = (paginaActual - 1) * itemsPorPagina
        movimientosPaginados = movimientosFiltrados.slice(inicio, inicio + itemsPorPagina)
    }
    
    function formatearFecha(fechaStr) {
        if (!fechaStr) return "N/A"
        let f = new Date(fechaStr)
        return ("0" + f.getDate()).slice(-2) + "/" + ("0" + (f.getMonth() + 1)).slice(-2) + "/" + f.getFullYear()
    }
    
    function formatearMonto(monto) {
        return typeof monto === 'number' ? monto.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",") : "0.00"
    }
    
    function resetearFiltros() {
        textoBusqueda = ""
        filtroTipo = "Todos"
        filtroCategoria = "Todas"
        filtroFechaInicio = ""
        filtroFechaFin = ""
        paginaActual = 1
        filtrarMovimientos()
    }
    
    Component.onCompleted: {
        if (typeof movimientosFinancierosModel !== 'undefined') {
            movimientosFinancierosModel.obtenerBalance()
            movimientosFinancierosModel.obtenerCategorias()
            movimientosFinancierosModel.obtenerMovimientos()
        }
    }
    
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"
        Text {
            text: "GESTIÓN FINANCIERA - FLUJO DE CAJA"
            font.pixelSize: 28
            font.bold: true
            color: "#009688"
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
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            tabsData: finanzasRoot.tabsInfo
            tabActiva: finanzasRoot.tabActiva
            onTabChanged: function(index) { finanzasRoot.tabActiva = index }
        }
    }
    
    Item {
        id: contentArea
        width: parent.width - 40
        height: parent.height - modernTabBar.y - modernTabBar.height - 20
        anchors.top: modernTabBar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        
        Column {
            anchors.fill: parent
            spacing: 15
            visible: tabActiva === 0
            
            Rectangle {
                width: parent.width
                height: 80
                radius: 8
                color: "#FFFFFF"
                border.color: "#E0E0E0"
                border.width: 1
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 20
                    
                    Column {
                        width: parent.width * 0.35
                        height: parent.height
                        spacing: 5
                        Text { text: "BALANCE ACTUAL"; font.pixelSize: 13; color: "#666666"; font.bold: true }
                        Text {
                            text: typeof movimientosFinancierosModel !== 'undefined' ? "BOB " + formatearMonto(movimientosFinancierosModel.balance_actual) : "BOB 0.00"
                            font.pixelSize: 26
                            font.bold: true
                            color: typeof movimientosFinancierosModel !== 'undefined' && movimientosFinancierosModel.balance_actual >= 0 ? "#2E7D32" : "#C62828"
                        }
                    }
                    
                    Rectangle { width: 1; height: parent.height; color: "#E0E0E0" }
                    
                    Column {
                        width: parent.width * 0.25
                        height: parent.height
                        spacing: 5
                        Text { text: "MOVIMIENTOS"; font.pixelSize: 12; color: "#666666"; font.bold: true }
                        Text { text: movimientosFiltrados.length + " registros"; font.pixelSize: 20; font.bold: true; color: "#009688" }
                    }
                    
                    Button {
                        text: "Actualizar"
                        width: 140
                        height: 40
                        anchors.verticalCenter: parent.verticalCenter
                        background: Rectangle {
                            color: parent.hovered ? "#00796B" : "#009688"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            if (typeof movimientosFinancierosModel !== 'undefined') {
                                movimientosFinancierosModel.obtenerBalance()
                                movimientosFinancierosModel.obtenerMovimientos()
                                movimientosFinancierosModel.obtenerCategorias()
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 110
                radius: 8
                color: "#FFFFFF"
                border.color: "#E0E0E0"
                border.width: 1
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    Row {
                        width: parent.width
                        height: 38
                        spacing: 8
                        
                        TextField {
                            id: campoBusqueda
                            width: parent.width - 160
                            height: parent.height
                            placeholderText: "Buscar..."
                            background: Rectangle {
                                color: "#FFFFFF"
                                border.color: "#CCCCCC"
                                border.width: 1
                                radius: 6
                            }
                            onTextChanged: { textoBusqueda = text; filtrarMovimientos() }
                        }
                        
                        Button {
                            text: "+ Nuevo"
                            width: 150
                            height: parent.height
                            background: Rectangle {
                                color: parent.hovered ? "#388E3C" : "#4CAF50"
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: registroMovimientoDialog.abrirDialogo()
                        }
                    }
                    
                    Row {
                        width: parent.width
                        height: 38
                        spacing: 8
                        
                        ComboBox {
                            id: comboTipo
                            width: (parent.width - 40) / 5
                            height: parent.height
                            model: ["Todos", "Ingreso", "Egreso"]
                            background: Rectangle {
                                color: "#FAFAFA"
                                radius: 6
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onCurrentTextChanged: { filtroTipo = currentText; filtrarMovimientos() }
                        }
                        
                        ComboBox {
                            id: comboCategoria
                            width: (parent.width - 40) / 5
                            height: parent.height
                            model: {
                                let cats = ["Todas"]
                                if (typeof movimientosFinancierosModel !== 'undefined' && movimientosFinancierosModel.categorias) {
                                    movimientosFinancierosModel.categorias.forEach(function(c) { cats.push(c.nombre) })
                                }
                                return cats
                            }
                            background: Rectangle {
                                color: "#FAFAFA"
                                radius: 6
                                border.color: "#CCCCCC"
                                border.width: 1
                            }
                            onCurrentTextChanged: { filtroCategoria = currentText; filtrarMovimientos() }
                        }
                        
                        TextField {
                            id: campoFechaInicio
                            width: (parent.width - 40) / 5
                            height: parent.height
                            placeholderText: "Desde"
                            background: Rectangle {
                                color: "#FFFFFF"
                                border.color: "#CCCCCC"
                                border.width: 1
                                radius: 6
                            }
                            onTextChanged: { filtroFechaInicio = text; filtrarMovimientos() }
                        }
                        
                        TextField {
                            id: campoFechaFin
                            width: (parent.width - 40) / 5
                            height: parent.height
                            placeholderText: "Hasta"
                            background: Rectangle {
                                color: "#FFFFFF"
                                border.color: "#CCCCCC"
                                border.width: 1
                                radius: 6
                            }
                            onTextChanged: { filtroFechaFin = text; filtrarMovimientos() }
                        }
                        
                        Button {
                            text: "Limpiar"
                            width: (parent.width - 40) / 5
                            height: parent.height
                            background: Rectangle {
                                color: parent.hovered ? "#616161" : "#757575"
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                resetearFiltros()
                                campoBusqueda.text = ""
                                comboTipo.currentIndex = 0
                                comboCategoria.currentIndex = 0
                                campoFechaInicio.text = ""
                                campoFechaFin.text = ""
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: parent.height - 240
                radius: 8
                color: "#FFFFFF"
                border.color: "#E0E0E0"
                border.width: 1
                
                Column {
                    anchors.fill: parent
                    spacing: 0
                    
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "#009688"
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            Text { width: parent.width * 0.12; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 12; color: "#FFFFFF"; verticalAlignment: Text.AlignVCenter }
                            Text { width: parent.width * 0.10; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 12; color: "#FFFFFF"; verticalAlignment: Text.AlignVCenter }
                            Text { width: parent.width * 0.15; height: parent.height; text: "Categoría"; font.bold: true; font.pixelSize: 12; color: "#FFFFFF"; verticalAlignment: Text.AlignVCenter }
                            Text { width: parent.width * 0.28; height: parent.height; text: "Descripción"; font.bold: true; font.pixelSize: 12; color: "#FFFFFF"; verticalAlignment: Text.AlignVCenter }
                            Text { width: parent.width * 0.13; height: parent.height; text: "Monto"; font.bold: true; font.pixelSize: 12; color: "#FFFFFF"; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight }
                            Text { width: parent.width * 0.12; height: parent.height; text: "Origen"; font.bold: true; font.pixelSize: 12; color: "#FFFFFF"; verticalAlignment: Text.AlignVCenter }
                            Text { width: parent.width * 0.10; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 12; color: "#FFFFFF"; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                        }
                    }
                    
                    ListView {
                        id: listaMovimientos
                        width: parent.width
                        height: parent.height - 40
                        clip: true
                        model: movimientosPaginados
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#F5F5F5"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#E0F2F1"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#F5F5F5"
                            }
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                
                                Text { width: parent.width * 0.12; height: parent.height; text: formatearFecha(modelData.fecha_movimiento); verticalAlignment: Text.AlignVCenter; font.pixelSize: 11; color: "#424242" }
                                
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    Rectangle {
                                        width: 65; height: 22; radius: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: modelData.es_gasto ? "#FFEBEE" : "#E8F5E9"
                                        Text { anchors.centerIn: parent; text: modelData.es_gasto ? "Egreso" : "Ingreso"; font.pixelSize: 10; font.bold: true; color: modelData.es_gasto ? "#C62828" : "#2E7D32" }
                                    }
                                }
                                
                                Text { width: parent.width * 0.15; height: parent.height; text: modelData.categoria_nombre || "N/A"; verticalAlignment: Text.AlignVCenter; font.pixelSize: 11; color: "#666666"; elide: Text.ElideRight }
                                Text { width: parent.width * 0.28; height: parent.height; text: modelData.descripcion || "Sin descripción"; verticalAlignment: Text.AlignVCenter; font.pixelSize: 11; color: "#424242"; elide: Text.ElideRight }
                                Text { width: parent.width * 0.13; height: parent.height; text: "BOB " + formatearMonto(modelData.monto); verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.pixelSize: 12; font.bold: true; color: modelData.es_gasto ? "#C62828" : "#2E7D32" }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.tabla_origen ? modelData.tabla_origen + "#" + modelData.id_origen : "Manual"; verticalAlignment: Text.AlignVCenter; font.pixelSize: 10; color: "#757575"; elide: Text.ElideRight }
                                
                                Row {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    spacing: 3
                                    
                                    Button {
                                        width: 30; height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        background: Rectangle { 
                                            color: parent.hovered ? "#E3F2FD" : "transparent"; 
                                            radius: 3 
                                        }
                                        contentItem: Text { 
                                            text: "👁"; 
                                            font.pixelSize: 16; 
                                            horizontalAlignment: Text.AlignHCenter; 
                                            verticalAlignment: Text.AlignVCenter 
                                        }
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Ver detalles"
                                        onClicked: { 
                                            detalleMovimientoDialog.cargarMovimiento(modelData); 
                                            detalleMovimientoDialog.open() 
                                        }
                                    }
                                    
                                    Button {
                                        width: 30; height: 30
                                        visible: !modelData.tabla_origen
                                        anchors.verticalCenter: parent.verticalCenter
                                        background: Rectangle { 
                                            color: parent.hovered ? "#FFEBEE" : "transparent"; 
                                            radius: 3 
                                        }
                                        contentItem: Text { 
                                            text: "🗑"; 
                                            font.pixelSize: 16; 
                                            horizontalAlignment: Text.AlignHCenter; 
                                            verticalAlignment: Text.AlignVCenter 
                                        }
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Eliminar"
                                        onClicked: { 
                                            confirmarEliminarDialog.idMovimiento = modelData.id_movimiento; 
                                            confirmarEliminarDialog.descripcion = modelData.descripcion || "este movimiento"; 
                                            confirmarEliminarDialog.open() 
                                        }
                                    }
                                }
                            }
                        }
                        
                        Label {
                            anchors.centerIn: parent
                            visible: listaMovimientos.count === 0
                            text: textoBusqueda !== "" || filtroTipo !== "Todos" || filtroCategoria !== "Todas" ? "No se encontraron resultados" : "No hay movimientos"
                            font.pixelSize: 14
                            color: "#757575"
                        }
                    }
                }
            }
            
            Paginator {
                width: parent.width
                height: 40
                currentPage: paginaActual
                totalPages: totalPaginas
                onPageChanged: function(newPage) { paginaActual = newPage; actualizarMovimientosPaginados() }
            }
        }
    }
    
    Popup {
        id: registroMovimientoDialog
        width: 500
        height: 550
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape
        
        property string fechaSeleccionada: ""
        property bool esGasto: true
        property int categoriaSeleccionada: -1
        
        function abrirDialogo() {
            var hoy = new Date()
            fechaSeleccionada = hoy.getFullYear() + "-" + ("0" + (hoy.getMonth() + 1)).slice(-2) + "-" + ("0" + hoy.getDate()).slice(-2)
            campoFechaRegistro.text = fechaSeleccionada
            comboTipoRegistro.currentIndex = 1
            comboCategoriaRegistro.currentIndex = 0
            campoMontoRegistro.text = ""
            campoDescripcionRegistro.text = ""
            open()
        }
        
        background: Rectangle { 
            color: "#FFFFFF"; 
            radius: 8; 
            border.color: "#E0E0E0"; 
            border.width: 1 
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            
            Text { 
                text: "Registrar Movimiento"; 
                font.pixelSize: 18; 
                font.bold: true; 
                color: "#424242" 
            }
            Rectangle { 
                width: parent.width; 
                height: 1; 
                color: "#E0E0E0" 
            }
            
            Column {
                width: parent.width
                spacing: 4
                Label { 
                    text: "Fecha:"; 
                    font.bold: true 
                }
                TextField { 
                    id: campoFechaRegistro; 
                    width: parent.width; 
                    height: 38; 
                    placeholderText: "AAAA-MM-DD"; 
                    background: Rectangle {
                        color: "#FFFFFF"
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 4
                    }
                    onTextChanged: registroMovimientoDialog.fechaSeleccionada = text 
                }
            }
            
            Column {
                width: parent.width
                spacing: 4
                Label { 
                    text: "Tipo:"; 
                    font.bold: true 
                }
                ComboBox { 
                    id: comboTipoRegistro; 
                    width: parent.width; 
                    height: 38; 
                    model: ["Ingreso", "Egreso"]; 
                    background: Rectangle {
                        color: "#FAFAFA"
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 4
                    }
                    onCurrentTextChanged: registroMovimientoDialog.esGasto = (currentText === "Egreso") 
                }
            }
            
            Column {
                width: parent.width
                spacing: 4
                Label { 
                    text: "Categoría:"; 
                    font.bold: true 
                }
                ComboBox {
                    id: comboCategoriaRegistro
                    width: parent.width
                    height: 38
                    model: {
                        let nombres = []
                        if (typeof movimientosFinancierosModel !== 'undefined' && movimientosFinancierosModel.categorias) {
                            movimientosFinancierosModel.categorias.forEach(function(cat) { nombres.push(cat.nombre) })
                        }
                        return nombres
                    }
                    background: Rectangle {
                        color: "#FAFAFA"
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 4
                    }
                    onCurrentIndexChanged: {
                        if (typeof movimientosFinancierosModel !== 'undefined' && movimientosFinancierosModel.categorias && currentIndex >= 0) {
                            registroMovimientoDialog.categoriaSeleccionada = movimientosFinancierosModel.categorias[currentIndex].id_categoria
                        }
                    }
                }
            }
            
            Column {
                width: parent.width
                spacing: 4
                Label { 
                    text: "Monto (BOB):"; 
                    font.bold: true 
                }
                TextField { 
                    id: campoMontoRegistro; 
                    width: parent.width; 
                    height: 38; 
                    placeholderText: "0.00"; 
                    validator: DoubleValidator { 
                        bottom: 0.01; 
                        decimals: 2 
                    }
                    background: Rectangle {
                        color: "#FFFFFF"
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 4
                    }
                }
            }
            
            Column {
                width: parent.width
                spacing: 4
                Label { 
                    text: "Descripción:"; 
                    font.bold: true 
                }
                TextArea { 
                    id: campoDescripcionRegistro; 
                    width: parent.width; 
                    height: 70; 
                    placeholderText: "Detalles..."; 
                    wrapMode: TextArea.Wrap; 
                    background: Rectangle { 
                        color: "#F5F5F5"; 
                        border.color: "#BDBDBD"; 
                        border.width: 1; 
                        radius: 4 
                    } 
                }
            }
            
            Row {
                width: parent.width
                height: 40
                spacing: 8
                
                Button { 
                    text: "Cancelar"; 
                    width: (parent.width - 8) / 2; 
                    height: parent.height; 
                    background: Rectangle {
                        color: parent.hovered ? "#616161" : "#757575"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: registroMovimientoDialog.close() 
                }
                
                Button {
                    text: "Guardar"
                    width: (parent.width - 8) / 2
                    height: parent.height
                    background: Rectangle {
                        color: parent.hovered ? "#388E3C" : "#4CAF50"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (!registroMovimientoDialog.fechaSeleccionada) { 
                            notificacion.mostrar("Ingresa una fecha", false); 
                            return 
                        }
                        if (!campoMontoRegistro.text || parseFloat(campoMontoRegistro.text) <= 0) { 
                            notificacion.mostrar("Monto inválido", false); 
                            return 
                        }
                        if (registroMovimientoDialog.categoriaSeleccionada === -1) { 
                            notificacion.mostrar("Selecciona una categoría", false); 
                            return 
                        }
                        
                        if (movimientosFinancierosModel.registrarMovimientoManual(
                            registroMovimientoDialog.fechaSeleccionada,
                            parseFloat(campoMontoRegistro.text),
                            registroMovimientoDialog.esGasto,
                            registroMovimientoDialog.categoriaSeleccionada,
                            campoDescripcionRegistro.text
                        )) {
                            registroMovimientoDialog.close()
                        }
                    }
                }
            }
        }
    }
    
    Popup {
        id: detalleMovimientoDialog
        width: 450
        height: 450
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape
        
        property var movimiento: null
        function cargarMovimiento(mov) { movimiento = mov }
        
        background: Rectangle { 
            color: "#FFFFFF"; 
            radius: 8; 
            border.color: "#E0E0E0"; 
            border.width: 1 
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            
            Text { 
                text: "Detalle del Movimiento"; 
                font.pixelSize: 18; 
                font.bold: true; 
                color: "#424242" 
            }
            Rectangle { 
                width: parent.width; 
                height: 1; 
                color: "#E0E0E0" 
            }
            
            Grid {
                width: parent.width
                columns: 2
                rowSpacing: 10
                columnSpacing: 15
                
                Label { text: "ID:"; font.bold: true }
                Label { text: detalleMovimientoDialog.movimiento ? "#" + detalleMovimientoDialog.movimiento.id_movimiento : "N/A" }
                Label { text: "Fecha:"; font.bold: true }
                Label { text: detalleMovimientoDialog.movimiento ? formatearFecha(detalleMovimientoDialog.movimiento.fecha_movimiento) : "N/A" }
                Label { text: "Tipo:"; font.bold: true }
                Label { 
                    text: detalleMovimientoDialog.movimiento ? (detalleMovimientoDialog.movimiento.es_gasto ? "EGRESO" : "INGRESO") : "N/A"; 
                    font.bold: true; 
                    color: detalleMovimientoDialog.movimiento && detalleMovimientoDialog.movimiento.es_gasto ? "#C62828" : "#2E7D32" 
                }
                Label { text: "Monto:"; font.bold: true }
                Label { 
                    text: detalleMovimientoDialog.movimiento ? "BOB " + formatearMonto(detalleMovimientoDialog.movimiento.monto) : "N/A"; 
                    font.pixelSize: 16; 
                    font.bold: true; 
                    color: detalleMovimientoDialog.movimiento && detalleMovimientoDialog.movimiento.es_gasto ? "#C62828" : "#2E7D32" 
                }
                Label { text: "Categoría:"; font.bold: true }
                Label { text: detalleMovimientoDialog.movimiento ? detalleMovimientoDialog.movimiento.categoria_nombre : "N/A" }
                Label { text: "Origen:"; font.bold: true }
                Label { 
                    text: detalleMovimientoDialog.movimiento ? 
                          (detalleMovimientoDialog.movimiento.tabla_origen ? 
                           detalleMovimientoDialog.movimiento.tabla_origen + " #" + detalleMovimientoDialog.movimiento.id_origen : 
                           "Manual") : "N/A" 
                }
            }
            
            Column {
                width: parent.width
                spacing: 5
                Label { text: "Descripción:"; font.bold: true }
                Rectangle {
                    width: parent.width; 
                    height: 80
                    color: "#F5F5F5"; 
                    border.color: "#E0E0E0"; 
                    border.width: 1; 
                    radius: 4
                    ScrollView {
                        anchors.fill: parent; 
                        anchors.margins: 8; 
                        clip: true
                        Label { 
                            text: detalleMovimientoDialog.movimiento && detalleMovimientoDialog.movimiento.descripcion ? 
                                  detalleMovimientoDialog.movimiento.descripcion : "Sin descripción"; 
                            wrapMode: Text.WordWrap; 
                            width: parent.width 
                        }
                    }
                }
            }
            
            Button { 
                text: "Cerrar"; 
                width: parent.width; 
                height: 40; 
                background: Rectangle {
                    color: parent.hovered ? "#616161" : "#757575"
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: detalleMovimientoDialog.close() 
            }
        }
    }
    
    Popup {
        id: confirmarEliminarDialog
        width: 380
        height: 200
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape
        
        property int idMovimiento: -1
        property string descripcion: ""
        
        background: Rectangle { 
            color: "#FFFFFF"; 
            radius: 8; 
            border.color: "#E0E0E0"; 
            border.width: 1 
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            
            Text { 
                text: "Confirmar Eliminación"; 
                font.pixelSize: 18; 
                font.bold: true; 
                color: "#424242" 
            }
            Rectangle { 
                width: parent.width; 
                height: 1; 
                color: "#E0E0E0" 
            }
            Label { 
                width: parent.width; 
                text: "¿Eliminar '" + confirmarEliminarDialog.descripcion + "'?\n\nEsta acción no se puede deshacer."; 
                wrapMode: Text.WordWrap 
            }
            
            Row {
                width: parent.width
                height: 40
                spacing: 8
                
                Button { 
                    text: "Cancelar"; 
                    width: (parent.width - 8) / 2; 
                    height: parent.height; 
                    background: Rectangle {
                        color: parent.hovered ? "#616161" : "#757575"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: confirmarEliminarDialog.close() 
                }
                
                Button { 
                    text: "Eliminar"; 
                    width: (parent.width - 8) / 2; 
                    height: parent.height; 
                    background: Rectangle {
                        color: parent.hovered ? "#C62828" : "#D32F2F"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: { 
                        notificacion.mostrar("Función pendiente", false); 
                        confirmarEliminarDialog.close() 
                    }
                }
            }
        }
    }
    
    Rectangle {
        id: notificacion
        width: 350
        height: 50
        radius: 6
        color: "#323232"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        opacity: 0
        visible: opacity > 0
        
        property string mensaje: ""
        property bool esExito: true
        
        function mostrar(msg, exito) {
            mensaje = msg
            esExito = exito
            aparecer.start()
        }
        
        Row {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            Text { 
                text: notificacion.esExito ? "✅" : "❌"; 
                font.pixelSize: 20; 
                anchors.verticalCenter: parent.verticalCenter 
            }
            Text { 
                text: notificacion.mensaje; 
                font.pixelSize: 13; 
                color: "#FFFFFF"; 
                anchors.verticalCenter: parent.verticalCenter; 
                width: parent.width - 40; 
                wrapMode: Text.WordWrap 
            }
        }
        
        SequentialAnimation {
            id: aparecer
            NumberAnimation { 
                target: notificacion; 
                property: "opacity"; 
                to: 1; 
                duration: 250 
            }
            PauseAnimation { duration: 2500 }
            NumberAnimation { 
                target: notificacion; 
                property: "opacity"; 
                to: 0; 
                duration: 250 
            }
        }
    }
    
    Connections {
        target: typeof movimientosFinancierosModel !== 'undefined' ? movimientosFinancierosModel : null
        function onOperacionExitosa(message) { notificacion.mostrar(message, true) }
        function onErrorOcurrido(message) { notificacion.mostrar(message, false) }
        function onMovimientosActualizados() { filtrarMovimientos() }
        function onBalanceCambiado() { }
        function onCategoriasCargadas() { }
    }
}
