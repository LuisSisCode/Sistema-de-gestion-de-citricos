import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: productoresRoot
    anchors.fill: parent
    color: "#F8F9FA"

    Component.onCompleted: {
        console.log("=".repeat(50))
        console.log("🔧 MÓDULO PRODUCTORES Y PARCELAS INICIADO")
        console.log("=".repeat(50))
        // Cargar datos iniciales
        productoresparcelasModel.cargar_productores_pagina(1)
        productoresparcelasModel.cargar_parcelas_pagina(1)
    }
    
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Agricultores", "icon": "recursos/image/icons/agricultores.png", "color": "#2E7D32"},
        {"text": "Parcelas", "icon": "recursos/image/icons/parcela.png", "color": "#F57C00"}
    ]
    
    // Propiedades para paginación conectadas al modelo
    property int paginaAgricultores: productoresparcelasModel.paginaActualProductores || 1
    property int totalPaginasAgricultores: productoresparcelasModel.totalPaginasProductores || 1
    property int paginaParcelas: productoresparcelasModel.paginaActualParcelas || 1
    property int totalPaginasParcelas: productoresparcelasModel.totalPaginasParcelas || 1

    // Propiedades para filtros
    property var estadosAgricultores: ["Todos", "Activo", "Inactivo"]
    property var estadosParcelas: ["Todos", "Activo", "Inactivo"]
    
    // Estados de búsqueda
    property bool buscandoAgricultores: false
    property bool buscandoParcelas: false
    property string terminoBusquedaActualAgricultores: ""
    property string terminoBusquedaActualParcelas: ""

    // ==================== CONNECTIONS CON EL MODELO ====================
    Connections {
        target: productoresparcelasModel
        
        function onProductoresChanged() {
            try {
                var total = productoresparcelasModel.productores ? productoresparcelasModel.productores.length : 0
                console.log("✅ PRODUCTORES CHANGED - Total:", total)
                
                if (typeof listaAgricultores !== 'undefined' && listaAgricultores) {
                    listaAgricultores.model = null
                    Qt.callLater(function() {
                        listaAgricultores.model = productoresparcelasModel.productores
                        console.log("✅ ListView actualizado - Items:", listaAgricultores.count)
                    })
                }
            } catch (e) {
                console.error("❌ Error en onProductoresChanged:", e.message)
            }
        }
        
        function onParcelasChanged() {
            try {
                var total = productoresparcelasModel.parcelas ? productoresparcelasModel.parcelas.length : 0
                console.log("✅ PARCELAS CHANGED - Total:", total)
                
                if (typeof listaParcelas !== 'undefined' && listaParcelas) {
                    listaParcelas.model = null
                    Qt.callLater(function() {
                        listaParcelas.model = productoresparcelasModel.parcelas
                        console.log("✅ ListView Parcelas actualizado - Items:", listaParcelas.count)
                    })
                }
            } catch (e) {
                console.error("❌ Error en onParcelasChanged:", e.message)
            }
        }
        
        function onOperacionCompleta(tipo, exito, mensaje) {
            console.log(`📢 Operación ${tipo}: ${exito ? "Éxito" : "Error"} - ${mensaje}`)
            
            if (exito) {
                mostrarNotificacion(`✅ ${mensaje}`, "success")
                
                // Recargar datos según el tipo de operación
                if (tipo.includes('productor')) {
                    if (buscandoAgricultores) {
                        // Si hay búsqueda activa, mantener resultados
                        buscarAgricultores(terminoBusquedaActualAgricultores)
                    } else {
                        productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
                    }
                } else if (tipo.includes('parcela')) {
                    if (buscandoParcelas) {
                        buscarParcelas(terminoBusquedaActualParcelas)
                    } else {
                        productoresparcelasModel.cargar_parcelas_pagina(paginaParcelas)
                    }
                }
            } else {
                mostrarNotificacion(`❌ ${mensaje}`, "error")
            }
        }
    }

    // ==================== FUNCIONES GLOBALES ====================
    
    function mostrarNotificacion(mensaje, tipo) {
        console.log(`📢 ${tipo.toUpperCase()}: ${mensaje}`)
        notificacionToast.mostrar(mensaje, tipo)
    }
    
    function buscarAgricultores(texto) {
        try {
            console.log("🔍 Buscar agricultor:", texto)
            terminoBusquedaActualAgricultores = texto
            
            if (texto.length >= 2) {
                buscandoAgricultores = true
                var resultados = productoresparcelasModel.filtrar_productores_por_nombre(texto)
                console.log(`📊 Resultados búsqueda: ${resultados ? resultados.length : 0} agricultores`)
                
                listaAgricultores.model = null
                listaAgricultores.model = resultados
                
            } else if (texto === "") {
                buscandoAgricultores = false
                terminoBusquedaActualAgricultores = ""
                console.log("🔄 Limpiando búsqueda - cargando página:", paginaAgricultores)
                productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
            }
        } catch (e) {
            console.error("❌ Error en búsqueda:", e.message, e.stack)
        }
    }
    
    function buscarParcelas(texto) {
        try {
            console.log("🔍 Buscar parcela:", texto)
            terminoBusquedaActualParcelas = texto
            
            if (texto.length >= 2) {
                buscandoParcelas = true
                var resultados = productoresparcelasModel.filtrar_parcelas_por_nombre(texto)
                console.log(`📊 Resultados búsqueda: ${resultados ? resultados.length : 0} parcelas`)
                
                listaParcelas.model = null
                listaParcelas.model = resultados
                
            } else if (texto === "") {
                buscandoParcelas = false
                terminoBusquedaActualParcelas = ""
                console.log("🔄 Limpiando búsqueda - cargando página:", paginaParcelas)
                productoresparcelasModel.cargar_parcelas_pagina(paginaParcelas)
            }
        } catch (e) {
            console.error("❌ Error en búsqueda parcelas:", e.message)
        }
    }
    
    function filtrarPorEstadoAgricultores(estadoIndex) {
        console.log("🔍 Filtrar agricultores por estado:", estadosAgricultores[estadoIndex])
        
        if (estadoIndex === 0) {
            // "Todos" - recargar página actual
            productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
        } else {
            // Filtrar por estado específico
            var estadoActivo = estadoIndex === 1 // 1 = Activo, 2 = Inactivo
            var todosProd = productoresparcelasModel.productores || []
            
            var filtrados = todosProd.filter(function(prod) {
                return prod.activo === estadoActivo
            })
            
            listaAgricultores.model = null
            listaAgricultores.model = filtrados
        }
    }
    
    function filtrarPorEstadoParcelas(estadoIndex) {
        console.log("🔍 Filtrar parcelas por estado:", estadosParcelas[estadoIndex])
        
        if (estadoIndex === 0) {
            // "Todos"
            productoresparcelasModel.cargar_parcelas_pagina(paginaParcelas)
        } else {
            var estadoActivo = estadoIndex === 1
            var todasParc = productoresparcelasModel.parcelas || []
            
            var filtradas = todasParc.filter(function(parc) {
                return parc.activo === estadoActivo
            })
            
            listaParcelas.model = null
            listaParcelas.model = filtradas
        }
    }
    
    function guardarAgricultor() {
        console.log("💾 Ejecutando guardarAgricultor...")
        
        // Validaciones
        if (!campoNombre.text || campoNombre.text.trim() === "") {
            mostrarNotificacion("❌ El nombre es obligatorio", "error")
            return
        }
        
        if (!campoApellido.text || campoApellido.text.trim() === "") {
            mostrarNotificacion("❌ El apellido es obligatorio", "error")
            return
        }
        
        if (!campoIdentificacion.text || campoIdentificacion.text.trim() === "") {
            mostrarNotificacion("❌ La identificación es obligatoria", "error")
            return
        }
        
        // Validar correo si está presente
        if (campoCorreo.text.trim() !== "") {
            var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
            if (!emailRegex.test(campoCorreo.text.trim())) {
                mostrarNotificacion("❌ El correo electrónico no es válido", "error")
                return
            }
        }
        
        // Preparar datos
        var datosAgricultor = {
            "nombre": campoNombre.text.trim(),
            "apellido": campoApellido.text.trim(),
            "identificacion": campoIdentificacion.text.trim(),
            "telefono": campoTelefono.text.trim(),
            "correo": campoCorreo.text.trim(),
            "direccion": campoDireccion.text.trim(),
            "activo": comboEstado.currentIndex === 0
        }
        
        console.log("📝 Datos agricultor:", JSON.stringify(datosAgricultor))
        
        var exito = false
        
        if (dialogoAgricultor.modoEdicion && dialogoAgricultor.agricultorActual) {
            // Actualizar
            exito = productoresparcelasModel.actualizar_productor(
                dialogoAgricultor.agricultorActual.id_productor, 
                JSON.stringify(datosAgricultor)
            )
        } else {
            // Crear
            exito = productoresparcelasModel.agregar_productor(JSON.stringify(datosAgricultor))
        }
        
        if (exito) {
            dialogoAgricultor.close()
        }
    }
    
    function guardarParcela() {
        console.log("💾 Ejecutando guardarParcela...")
        
        // Validaciones
        if (!campoNombreParcela.text || campoNombreParcela.text.trim() === "") {
            mostrarNotificacion("❌ El nombre de la parcela es obligatorio", "error")
            return
        }
        
        if (!campoUbicacion.text || campoUbicacion.text.trim() === "") {
            mostrarNotificacion("❌ La ubicación es obligatoria", "error")
            return
        }
        
        if (!campoArea.text || parseFloat(campoArea.text) <= 0) {
            mostrarNotificacion("❌ El área debe ser mayor a 0", "error")
            return
        }
        
        if (comboPropietario.currentIndex < 0) {
            mostrarNotificacion("❌ Debe seleccionar un propietario", "error")
            return
        }
        
        // Obtener ID del propietario seleccionado
        var productores = productoresparcelasModel.productores || []
        var propietarioSeleccionado = productores[comboPropietario.currentIndex]
        
        if (!propietarioSeleccionado) {
            mostrarNotificacion("❌ Error al obtener propietario seleccionado", "error")
            return
        }
        
        // Preparar datos
        var datosParcela = {
            "nombre": campoNombreParcela.text.trim(),
            "ubicacion": campoUbicacion.text.trim(),
            "area_total": parseFloat(campoArea.text),
            "id_productor": propietarioSeleccionado.id_productor,
            "fecha_adquisicion": campoFechaAdquisicion.text || new Date().toISOString().split('T')[0]
        }
        
        console.log("📝 Datos parcela:", JSON.stringify(datosParcela))
        
        var exito = false
        
        if (dialogoParcela.modoEdicion && dialogoParcela.parcelaActual) {
            // Actualizar
            exito = productoresparcelasModel.actualizar_parcela(
                dialogoParcela.parcelaActual.id_parcela, 
                JSON.stringify(datosParcela)
            )
        } else {
            // Crear
            exito = productoresparcelasModel.agregar_parcela(JSON.stringify(datosParcela))
        }
        
        if (exito) {
            dialogoParcela.close()
        }
    }

    // ==================== UI: TÍTULO ====================
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"

        Text {
            text: "GESTIÓN DE PROPIETARIOS Y TERRENO"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.centerIn: parent
        }
    }

    // ==================== UI: BARRA DE PESTAÑAS ====================
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
            tabsData: productoresRoot.tabsInfo
            tabActiva: productoresRoot.tabActiva
            
            onTabChanged: function(index) {
                productoresRoot.tabActiva = index
                
                // Limpiar búsquedas al cambiar de pestaña
                if (index === 0) {
                    buscandoAgricultores = false
                    terminoBusquedaActualAgricultores = ""
                    productoresparcelasModel.cargar_productores_pagina(1)
                } else if (index === 1) {
                    buscandoParcelas = false
                    terminoBusquedaActualParcelas = ""
                    productoresparcelasModel.cargar_parcelas_pagina(1)
                }
            }
        }
    }

    // ==================== UI: CONTENIDO PRINCIPAL ====================
    Item {
        id: contentArea
        width: parent.width - 40
        height: parent.height - modernTabBar.y - modernTabBar.height - 20
        anchors.top: modernTabBar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        
        // ==================== TAB 1: AGRICULTORES ====================
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
                
                // Barra de herramientas
                FilterHeaderComponent {
                    id: filterHeaderAgricultores
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Agricultor"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#2E7D32"
                    searchPlaceholder: "Buscar agricultor..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: estadosAgricultores
                    filterPlaceholder: "Estado..."
                    filterWidth: 150
                    showFilter: true
                    
                    onButtonClicked: {
                        console.log("➕ Nuevo agricultor")
                        dialogoAgricultor.abrirParaNuevo()
                    }
                    
                    onSearchTextChanged: function(text) {
                        buscarAgricultores(text)
                    }
                    
                    onFilterChanged: function(index) {
                        filtrarPorEstadoAgricultores(index)
                    }
                }
                
                // Tabla de Agricultores
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: listaAgricultores
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: productoresparcelasModel.productores
                        headerPositioning: ListView.OverlayHeader
                        spacing: 2
                        
                        header: Rectangle {
                            width: parent ? parent.width : 0
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.14; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Apellido"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Identificación"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Teléfono"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.18; height: parent.height; text: "Correo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.16; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#F0F4FF"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { 
                                    width: parent.width * 0.14; 
                                    height: parent.height; 
                                    text: modelData.nombre || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.14; 
                                    height: parent.height; 
                                    text: modelData.apellido || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.14; 
                                    height: parent.height; 
                                    text: modelData.identificacion || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.12; 
                                    height: parent.height; 
                                    text: modelData.telefono || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.18; 
                                    height: parent.height; 
                                    text: modelData.correo || "N/A"; 
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
                                        width: 70
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: (modelData.activo === true) ? "#E8F5E8" : "#FFF3CD"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: (modelData.activo === true) ? "Activo" : "Inactivo"
                                            font.pixelSize: 11
                                            color: (modelData.activo === true) ? "#2E7D32" : "#B8860B"
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.16
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
                                                console.log("✏️ Editar agricultor:", modelData.id_productor)
                                                dialogoAgricultor.abrirParaEditar(modelData)
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
                                                console.log("🗑️ Eliminar agricultor:", modelData.id_productor)
                                                var nombreCompleto = (modelData.nombre || "") + " " + (modelData.apellido || "")
                                                dialogoConfirmacion.confirmarEliminacion("agricultor", modelData.id_productor, nombreCompleto.trim())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador Agricultores
                Item {
                    Layout.fillWidth: true
                    height: 40
                    visible: !buscandoAgricultores
                    
                    Paginator {
                        id: paginadorAgricultores
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaAgricultores
                        totalPages: totalPaginasAgricultores
                        
                        onPageChanged: function(newPage) {
                            console.log(`📄 Cambiando a página ${newPage} de agricultores`)
                            productoresparcelasModel.cargar_productores_pagina(newPage)
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 2: PARCELAS ====================
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
                
                // Barra de herramientas
                FilterHeaderComponent {
                    id: filterHeaderParcelas
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nueva Parcela"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#F57C00"
                    searchPlaceholder: "Buscar parcela..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: estadosParcelas
                    filterPlaceholder: "Estado..."
                    filterWidth: 150
                    showFilter: true
                    
                    onButtonClicked: {
                        console.log("➕ Nueva parcela")
                        dialogoParcela.abrirParaNuevo()
                    }
                    
                    onSearchTextChanged: function(text) {
                        buscarParcelas(text)
                    }
                    
                    onFilterChanged: function(index) {
                        filtrarPorEstadoParcelas(index)
                    }
                }
                
                // Tabla de Parcelas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: listaParcelas
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: productoresparcelasModel.parcelas
                        headerPositioning: ListView.OverlayHeader
                        spacing: 2
                        
                        header: Rectangle {
                            width: parent ? parent.width : 0
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.16; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.18; height: parent.height; text: "Propietario"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.18; height: parent.height; text: "Ubicación"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Área (ha)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.24; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
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
                                
                                Text { 
                                    width: parent.width * 0.16; 
                                    height: parent.height; 
                                    text: modelData.nombre || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.18; 
                                    height: parent.height; 
                                    text: modelData.productor || modelData.nombre_productor_completo || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.18; 
                                    height: parent.height; 
                                    text: modelData.ubicacion || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.12; 
                                    height: parent.height; 
                                    text: (modelData.area_total || modelData.area || 0).toFixed(2); 
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
                                        width: 70
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: (modelData.activo === true) ? "#E8F5E8" : "#FFF3CD"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: (modelData.activo === true) ? "Activo" : "Inactivo"
                                            font.pixelSize: 11
                                            color: (modelData.activo === true) ? "#2E7D32" : "#B8860B"
                                        }
                                    }
                                }
                                
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
                                                console.log("✏️ Editar parcela:", modelData.id_parcela)
                                                dialogoParcela.abrirParaEditar(modelData)
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
                                                console.log("🗑️ Eliminar parcela:", modelData.id_parcela)
                                                dialogoConfirmacion.confirmarEliminacion("parcela", modelData.id_parcela, modelData.nombre || "Sin nombre")
                                            }
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
                                            ToolTip.text: "Ver detalles"
                                            onClicked: {
                                                console.log("👁️ Ver detalles parcela:", modelData.id_parcela)
                                                dialogoDetallesParcela.mostrarDetalles(modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador Parcelas
                Item {
                    Layout.fillWidth: true
                    height: 40
                    visible: !buscandoParcelas
                    
                    Paginator {
                        id: paginadorParcelas
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaParcelas
                        totalPages: totalPaginasParcelas
                        
                        onPageChanged: function(newPage) {
                            console.log(`📄 Cambiando a página ${newPage} de parcelas`)
                            productoresparcelasModel.cargar_parcelas_pagina(newPage)
                        }
                    }
                }
            }
        }
    }

    // ==================== DIÁLOGO: AGRICULTOR ====================
    Popup {
        id: dialogoAgricultor
        width: 500
        height: 620
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: parent
        
        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#CCCCCC"
            border.width: 1
        }
        
        property bool modoEdicion: false
        property var agricultorActual: null
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            
            // Header
            Text {
                Layout.fillWidth: true
                text: dialogoAgricultor.modoEdicion ? "EDITAR AGRICULTOR" : "NUEVO AGRICULTOR"
                font.pixelSize: 18
                font.bold: true
                color: "#2E7D32"
                horizontalAlignment: Text.AlignHCenter
            }
            
            // ScrollView para el formulario
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: parent.width - 20
                    spacing: 10
                    
                    // Nombre
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Nombre *"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoNombre
                            Layout.fillWidth: true
                            placeholderText: "Ingrese el nombre"
                        }
                    }
                    
                    // Apellido
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Apellido *"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoApellido
                            Layout.fillWidth: true
                            placeholderText: "Ingrese el apellido"
                        }
                    }
                    
                    // Identificación
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Identificación *"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoIdentificacion
                            Layout.fillWidth: true
                            placeholderText: "Número de identificación"
                        }
                    }
                    
                    // Teléfono
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Teléfono"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoTelefono
                            Layout.fillWidth: true
                            placeholderText: "Número de teléfono"
                        }
                    }
                    
                    // Correo
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Correo Electrónico"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoCorreo
                            Layout.fillWidth: true
                            placeholderText: "correo@ejemplo.com"
                        }
                    }
                    
                    // Dirección
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Dirección"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoDireccion
                            Layout.fillWidth: true
                            placeholderText: "Dirección completa"
                        }
                    }
                    
                    // Estado
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Estado"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        ComboBox {
                            id: comboEstado
                            Layout.fillWidth: true
                            model: ["Activo", "Inactivo"]
                        }
                    }
                    
                    // Texto informativo
                    Text {
                        Layout.fillWidth: true
                        text: "* Campos obligatorios"
                        font.pixelSize: 12
                        color: "#757575"
                        font.italic: true
                    }
                }
            }
            
            // Botones
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    height: 40
                    background: Rectangle {
                        color: parent.pressed ? "#E0E0E0" : (parent.hovered ? "#F5F5F5" : "#EEEEEE")
                        radius: 4
                    }
                    onClicked: dialogoAgricultor.close()
                }
                
                Button {
                    Layout.fillWidth: true
                    text: dialogoAgricultor.modoEdicion ? "Actualizar" : "Guardar"
                    height: 40
                    background: Rectangle {
                        color: parent.pressed ? "#1B5E20" : (parent.hovered ? "#388E3C" : "#2E7D32")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        guardarAgricultor()
                    }
                }
            }
        }
        
        function abrirParaNuevo() {
            modoEdicion = false
            agricultorActual = null
            limpiarCampos()
            open()
        }
        
        function abrirParaEditar(agricultor) {
            modoEdicion = true
            agricultorActual = agricultor
            llenarCampos(agricultor)
            open()
        }
        
        function limpiarCampos() {
            campoNombre.text = ""
            campoApellido.text = ""
            campoIdentificacion.text = ""
            campoTelefono.text = ""
            campoCorreo.text = ""
            campoDireccion.text = ""
            comboEstado.currentIndex = 0
        }
        
        function llenarCampos(agricultor) {
            campoNombre.text = agricultor.nombre || ""
            campoApellido.text = agricultor.apellido || ""
            campoIdentificacion.text = agricultor.identificacion || ""
            campoTelefono.text = agricultor.telefono || ""
            campoCorreo.text = agricultor.correo || ""
            campoDireccion.text = agricultor.direccion || ""
            comboEstado.currentIndex = (agricultor.activo === true) ? 0 : 1
        }
    }

    // ==================== DIÁLOGO: PARCELA ====================
    Popup {
        id: dialogoParcela
        width: 500
        height: 550
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: parent
        
        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#CCCCCC"
            border.width: 1
        }
        
        property bool modoEdicion: false
        property var parcelaActual: null
        
        onAboutToShow: {
            // Cargar lista de productores para el ComboBox
            if (!modoEdicion) {
                comboPropietario.model = productoresparcelasModel.productores
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            
            // Header
            Text {
                Layout.fillWidth: true
                text: dialogoParcela.modoEdicion ? "EDITAR PARCELA" : "NUEVA PARCELA"
                font.pixelSize: 18
                font.bold: true
                color: "#F57C00"
                horizontalAlignment: Text.AlignHCenter
            }
            
            // ScrollView para el formulario
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: parent.width - 20
                    spacing: 10
                    
                    // Nombre
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Nombre de la Parcela *"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoNombreParcela
                            Layout.fillWidth: true
                            placeholderText: "Ej: Parcela Norte"
                        }
                    }
                    
                    // Propietario
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Propietario *"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        ComboBox {
                            id: comboPropietario
                            Layout.fillWidth: true
                            textRole: "nombre_completo"
                            displayText: currentIndex >= 0 ? model[currentIndex].nombre_completo : "Seleccione un propietario"
                        }
                    }
                    
                    // Ubicación
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Ubicación *"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoUbicacion
                            Layout.fillWidth: true
                            placeholderText: "Dirección o coordenadas"
                        }
                    }
                    
                    // Área
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Área Total (hectáreas) *"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoArea
                            Layout.fillWidth: true
                            placeholderText: "Ej: 10.5"
                            validator: DoubleValidator {
                                bottom: 0.01
                                decimals: 2
                            }
                        }
                    }
                    
                    // Fecha de Adquisición
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Fecha de Adquisición"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#424242"
                        }
                        
                        TextField {
                            id: campoFechaAdquisicion
                            Layout.fillWidth: true
                            placeholderText: "YYYY-MM-DD"
                            text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                        }
                    }
                    
                    // Texto informativo
                    Text {
                        Layout.fillWidth: true
                        text: "* Campos obligatorios"
                        font.pixelSize: 12
                        color: "#757575"
                        font.italic: true
                    }
                }
            }
            
            // Botones
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    height: 40
                    background: Rectangle {
                        color: parent.pressed ? "#E0E0E0" : (parent.hovered ? "#F5F5F5" : "#EEEEEE")
                        radius: 4
                    }
                    onClicked: dialogoParcela.close()
                }
                
                Button {
                    Layout.fillWidth: true
                    text: dialogoParcela.modoEdicion ? "Actualizar" : "Guardar"
                    height: 40
                    background: Rectangle {
                        color: parent.pressed ? "#E65100" : (parent.hovered ? "#FB8C00" : "#F57C00")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        guardarParcela()
                    }
                }
            }
        }
        
        function abrirParaNuevo() {
            modoEdicion = false
            parcelaActual = null
            limpiarCampos()
            open()
        }
        
        function abrirParaEditar(parcela) {
            modoEdicion = true
            parcelaActual = parcela
            llenarCampos(parcela)
            open()
        }
        
        function limpiarCampos() {
            campoNombreParcela.text = ""
            campoUbicacion.text = ""
            campoArea.text = ""
            campoFechaAdquisicion.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
            comboPropietario.currentIndex = -1
        }
        
        function llenarCampos(parcela) {
            campoNombreParcela.text = parcela.nombre || ""
            campoUbicacion.text = parcela.ubicacion || ""
            campoArea.text = (parcela.area_total || parcela.area || 0).toString()
            campoFechaAdquisicion.text = parcela.fecha_adquisicion || Qt.formatDate(new Date(), "yyyy-MM-dd")
            
            // Buscar y seleccionar el propietario
            var productores = productoresparcelasModel.productores || []
            for (var i = 0; i < productores.length; i++) {
                if (productores[i].id_productor === parcela.id_productor) {
                    comboPropietario.currentIndex = i
                    break
                }
            }
        }
    }

    // ==================== DIÁLOGO: DETALLES PARCELA ====================
    Popup {
        id: dialogoDetallesParcela
        width: 500
        height: 450
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: parent
        
        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#CCCCCC"
            border.width: 1
        }
        
        property var parcelaActual: null
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Header
            Text {
                Layout.fillWidth: true
                text: "DETALLES DE LA PARCELA"
                font.pixelSize: 18
                font.bold: true
                color: "#F57C00"
                horizontalAlignment: Text.AlignHCenter
            }
            
            // Nombre de la parcela destacado
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#FFF3E0"
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: dialogoDetallesParcela.parcelaActual ? dialogoDetallesParcela.parcelaActual.nombre : "N/A"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#E65100"
                }
            }
            
            // Detalles en grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 15
                rowSpacing: 10
                
                // Propietario
                Text {
                    text: "Propietario:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#424242"
                }
                Text {
                    text: dialogoDetallesParcela.parcelaActual ? 
                          (dialogoDetallesParcela.parcelaActual.productor || dialogoDetallesParcela.parcelaActual.nombre_productor_completo || "N/A") : "N/A"
                    font.pixelSize: 14
                    color: "#616161"
                }
                
                // Ubicación
                Text {
                    text: "Ubicación:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#424242"
                }
                Text {
                    text: dialogoDetallesParcela.parcelaActual ? (dialogoDetallesParcela.parcelaActual.ubicacion || "N/A") : "N/A"
                    font.pixelSize: 14
                    color: "#616161"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                
                // Área
                Text {
                    text: "Área Total:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#424242"
                }
                Text {
                    text: dialogoDetallesParcela.parcelaActual ? 
                          ((dialogoDetallesParcela.parcelaActual.area_total || dialogoDetallesParcela.parcelaActual.area || 0).toFixed(2) + " ha") : "N/A"
                    font.pixelSize: 14
                    color: "#616161"
                }
                
                // Fecha de adquisición
                Text {
                    text: "Fecha Adquisición:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#424242"
                }
                Text {
                    text: dialogoDetallesParcela.parcelaActual ? (dialogoDetallesParcela.parcelaActual.fecha_adquisicion || "N/A") : "N/A"
                    font.pixelSize: 14
                    color: "#616161"
                }
                
                // Estado
                Text {
                    text: "Estado:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#424242"
                }
                Rectangle {
                    width: 80
                    height: 28
                    radius: 14
                    color: (dialogoDetallesParcela.parcelaActual && dialogoDetallesParcela.parcelaActual.activo === true) ? "#E8F5E8" : "#FFF3CD"
                    
                    Text {
                        anchors.centerIn: parent
                        text: (dialogoDetallesParcela.parcelaActual && dialogoDetallesParcela.parcelaActual.activo === true) ? "Activo" : "Inactivo"
                        font.pixelSize: 12
                        font.bold: true
                        color: (dialogoDetallesParcela.parcelaActual && dialogoDetallesParcela.parcelaActual.activo === true) ? "#2E7D32" : "#B8860B"
                    }
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Botón cerrar
            Button {
                Layout.fillWidth: true
                text: "Cerrar"
                height: 40
                background: Rectangle {
                    color: parent.pressed ? "#E0E0E0" : (parent.hovered ? "#F5F5F5" : "#EEEEEE")
                    radius: 4
                }
                onClicked: dialogoDetallesParcela.close()
            }
        }
        
        function mostrarDetalles(parcela) {
            parcelaActual = parcela
            console.log("👁️ Mostrando detalles de parcela:", JSON.stringify(parcela))
            open()
        }
    }

    // ==================== DIÁLOGO: CONFIRMACIÓN ====================
    Popup {
        id: dialogoConfirmacion
        width: 420
        height: 220
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: parent
        
        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#D32F2F"
            border.width: 2
        }
        
        property string tipo: ""
        property string nombre: ""
        property int id: -1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Icono y título
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "⚠️"
                    font.pixelSize: 32
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Confirmar Eliminación"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#D32F2F"
                }
            }
            
            // Mensaje
            Text {
                Layout.fillWidth: true
                text: `¿Está seguro que desea eliminar ${dialogoConfirmacion.tipo === "agricultor" ? "al agricultor" : "la parcela"}:\n"${dialogoConfirmacion.nombre}"?`
                font.pixelSize: 14
                color: "#424242"
                wrapMode: Text.WordWrap
            }
            
            // Advertencia
            Rectangle {
                Layout.fillWidth: true
                height: 30
                color: "#FFF3CD"
                radius: 4
                
                Text {
                    anchors.centerIn: parent
                    text: "⚠️ Esta acción no se puede deshacer"
                    font.pixelSize: 12
                    color: "#B8860B"
                    font.bold: true
                }
            }
            
            // Spacer
            Item {
                Layout.fillHeight: true
            }
            
            // Botones
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    height: 40
                    background: Rectangle {
                        color: parent.pressed ? "#E0E0E0" : (parent.hovered ? "#F5F5F5" : "#EEEEEE")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#424242"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: dialogoConfirmacion.close()
                }
                
                Button {
                    Layout.fillWidth: true
                    text: "Eliminar"
                    height: 40
                    background: Rectangle {
                        color: parent.pressed ? "#B71C1C" : (parent.hovered ? "#E53935" : "#D32F2F")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("🗑️ Confirmando eliminación:", dialogoConfirmacion.tipo, dialogoConfirmacion.id)
                        
                        if (dialogoConfirmacion.tipo === "agricultor") {
                            var resultado = productoresparcelasModel.eliminar_productor(dialogoConfirmacion.id)
                            console.log("Resultado eliminación agricultor:", JSON.stringify(resultado))
                            
                            if (resultado && resultado.exito) {
                                mostrarNotificacion("✅ Agricultor eliminado correctamente", "success")
                                // Recargar página actual
                                productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
                            } else {
                                var mensaje = resultado && resultado.mensaje ? resultado.mensaje : "Error desconocido"
                                mostrarNotificacion("❌ " + mensaje, "error")
                            }
                        } else if (dialogoConfirmacion.tipo === "parcela") {
                            var exito = productoresparcelasModel.eliminar_parcela(dialogoConfirmacion.id)
                            
                            if (exito) {
                                mostrarNotificacion("✅ Parcela eliminada correctamente", "success")
                                // Recargar página actual
                                productoresparcelasModel.cargar_parcelas_pagina(paginaParcelas)
                            } else {
                                mostrarNotificacion("❌ Error al eliminar parcela", "error")
                            }
                        }
                        
                        dialogoConfirmacion.close()
                    }
                }
            }
        }
        
        function confirmarEliminacion(tipo, id, nombre) {
            console.log("⚠️ Preparando confirmación de eliminación:", tipo, id, nombre)
            
            // Validar ID
            if (id === undefined || id === null || id < 0) {
                console.error("❌ ID inválido para eliminación:", id)
                mostrarNotificacion("❌ Error: ID inválido", "error")
                return
            }
            
            this.tipo = tipo
            this.id = parseInt(id)
            this.nombre = nombre || "Sin nombre"
            open()
        }
    }

    // ==================== COMPONENTE: NOTIFICACIÓN TOAST ====================
    Rectangle {
        id: notificacionToast
        width: 400
        height: 60
        color: "#323232"
        radius: 4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        opacity: 0
        visible: opacity > 0
        
        property string mensaje: ""
        property string tipo: "info" // "success", "error", "warning", "info"
        
        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            // Icono según tipo
            Text {
                text: {
                    switch(notificacionToast.tipo) {
                        case "success": return "✅"
                        case "error": return "❌"
                        case "warning": return "⚠️"
                        default: return "ℹ️"
                    }
                }
                font.pixelSize: 24
            }
            
            // Mensaje
            Text {
                Layout.fillWidth: true
                text: notificacionToast.mensaje
                color: "white"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
            }
            
            // Botón cerrar
            Button {
                width: 24
                height: 24
                background: Rectangle {
                    color: parent.pressed ? "#555555" : (parent.hovered ? "#424242" : "transparent")
                    radius: 12
                }
                contentItem: Text {
                    text: "✕"
                    color: "white"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    notificacionToast.opacity = 0
                    timerToast.stop()
                }
            }
        }
        
        Timer {
            id: timerToast
            interval: 4000
            repeat: false
            onTriggered: {
                notificacionToast.opacity = 0
            }
        }
        
        function mostrar(mensaje, tipo) {
            console.log("🔔 Mostrando notificación:", mensaje, tipo)
            //notificacionToast.mensaje = mensaje
            //notificacionToast.tipo = tipo || "info"
            //notificacionToast.opacity = 1
            //timerToast.restart()
        }
    }
}