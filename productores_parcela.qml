import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: productoresRoot
    anchors.fill: parent
    color: "#F8F9FA"

    Component.onCompleted: {
        console.log("=" .repeat(50))
        console.log("🔧 VERIFICACIÓN DE CONSOLA QML")
        console.log("=" .repeat(50))
        console.log("✅ Console.log funciona correctamente")
        console.log("📍 Módulo: productores_parcela.qml")
        console.log("🕐 Timestamp:", new Date().toISOString())
        console.log("=" .repeat(50))
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

    Connections {
        target: productoresparcelasModel
        
        function onProductoresChanged() {
            try {
                var total = productoresparcelasModel.productores ? productoresparcelasModel.productores.length : 0
                console.log("=" .repeat(50))
                console.log("✅ PRODUCTORES CHANGED")
                console.log("📊 Total productores:", total)
                console.log("🔗 ListView ID existe:", typeof listaAgricultores !== 'undefined')
                console.log("=" .repeat(50))
                
                // Forzar actualización
                if (typeof listaAgricultores !== 'undefined' && listaAgricultores) {
                    console.log("🔄 Forzando refresh del ListView...")
                    listaAgricultores.model = null
                    Qt.callLater(function() {
                        listaAgricultores.model = productoresparcelasModel.productores
                        console.log("✅ ListView actualizado - Items:", listaAgricultores.count)
                    })
                } else {
                    console.error("❌ listaAgricultores no está disponible!")
                }
            } catch (e) {
                console.error("❌ Error en onProductoresChanged:", e.message)
            }
        }
        
        function onParcelasChanged() {
            try {
                var total = productoresparcelasModel.parcelas ? productoresparcelasModel.parcelas.length : 0
                console.log("✅ Parcelas actualizadas - Total:", total)
                
                if (typeof listaParcelas !== 'undefined' && listaParcelas) {
                    listaParcelas.model = null
                    Qt.callLater(function() {
                        listaParcelas.model = productoresparcelasModel.parcelas
                    })
                }
            } catch (e) {
                console.error("❌ Error en onParcelasChanged:", e.message)
            }
        }
        
        function onOperacionCompleta(tipo, exito, mensaje) {
            if (exito) {
                // Recargar después de operaciones exitosas
                if (tipo.includes('productor')) {
                    productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
                } else if (tipo.includes('parcela')) {
                    productoresparcelasModel.cargar_parcelas_pagina(paginaParcelas)
                }
                mostrarNotificacion(`✅ ${mensaje}`, "success")
            } else {
                mostrarNotificacion(`❌ ${mensaje}`, "error")
            }
        }
    }

    

    // Función para mostrar notificaciones
    function mostrarNotificacion(mensaje, tipo) {
        // Implementar lógica de notificación aquí
        console.log(`📢 ${tipo.toUpperCase()}: ${mensaje}`)
    }

    // Título
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
            tabsData: productoresRoot.tabsInfo
            tabActiva: productoresRoot.tabActiva
            
            onTabChanged: function(index) {
                productoresRoot.tabActiva = index
                // Recargar datos al cambiar de pestaña
                if (index === 0) {
                    productoresparcelasModel.cargar_productores_pagina(1)
                } else if (index === 1) {
                    productoresparcelasModel.cargar_parcelas_pagina(1)
                }
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
                
                // Barra de herramientas con FilterHeaderComponent
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
                        console.log("Nuevo agricultor - Abrir diálogo de creación")
                        dialogoAgricultor.abrirParaNuevo()
                    }
                    
                    onSearchTextChanged: function(text) {
                        try {
                            console.log("🔍 Buscar agricultor:", text)
                            
                            if (text.length >= 2) {
                                var resultados = productoresparcelasModel.filtrar_productores_por_nombre(text)
                                console.log(`📊 Resultados búsqueda: ${resultados ? resultados.length : 0} agricultores`)
                                
                                // ✅ CRÍTICO: Forzar actualización del ListView
                                listaAgricultores.model = null
                                listaAgricultores.model = resultados
                                
                            } else if (text === "") {
                                console.log("🔄 Limpiando búsqueda - cargando página:", paginaAgricultores)
                                productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
                                
                                // ✅ Restaurar modelo original
                                listaAgricultores.model = null
                                listaAgricultores.model = productoresparcelasModel.productores
                            }
                        } catch (e) {
                            console.error("❌ Error en búsqueda:", e.message, e.stack)
                        }
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por estado:", estadosAgricultores[index])
                        // TODO: Implementar filtrado por estado
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
                        
                        header: Rectangle {
                            width: parent.width
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
                                        color: (modelData.activo === true || modelData.estado === "Activo") ? "#E8F5E8" : "#FFF3CD"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: (modelData.activo === true || modelData.estado === "Activo") ? "Activo" : "Inactivo"
                                            font.pixelSize: 11
                                            color: (modelData.activo === true || modelData.estado === "Activo") ? "#2E7D32" : "#B8860B"
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
                                                console.log("Editar agricultor:", modelData.id_productor)
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
                                                console.log("Eliminar agricultor:", modelData.id_productor)
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
                
                // Paginador Agricultores - CENTRADO
                Item {
                    Layout.fillWidth: true
                    height: 40
                    
                    Paginator {
                        id: paginadorAgricultores
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaAgricultores
                        totalPages: totalPaginasAgricultores
                        
                        onPageChanged: {
                            console.log(`📄 Cambiando a página ${newPage} de agricultores`)
                            modelData.cargar_productores_pagina(newPage)
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
                
                // Barra de herramientas con FilterHeaderComponent
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
                        console.log("Nueva parcela - Abrir diálogo de creación")
                        // TODO: Implementar diálogo de creación
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar parcela:", text)
                        if (text.length >= 2) {
                            var resultados = modelData.filtrar_parcelas_por_nombre(text)
                            console.log(`🔍 Resultados búsqueda: ${resultados.length} parcelas`)
                        } else if (text === "") {
                            modelData.cargar_parcelas_pagina(paginaParcelas)
                        }
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por estado:", estadosParcelas[index])
                        // TODO: Implementar filtrado por estado
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
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.13; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.16; height: parent.height; text: "Propietario"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Ubicación"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.11; height: parent.height; text: "Área (ha)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "% Uso"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
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
                                    width: parent.width * 0.13; 
                                    height: parent.height; 
                                    text: modelData.nombre || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.16; 
                                    height: parent.height; 
                                    text: modelData.propietario || modelData.nombre_propietario || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.14; 
                                    height: parent.height; 
                                    text: modelData.ubicacion || "N/A"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.11; 
                                    height: parent.height; 
                                    text: modelData.area || "0"; 
                                    verticalAlignment: Text.AlignVCenter; 
                                    leftPadding: 10; 
                                    elide: Text.ElideRight; 
                                    font.pixelSize: 12 
                                }
                                Text { 
                                    width: parent.width * 0.1; 
                                    height: parent.height; 
                                    text: (modelData.porcentaje_uso || modelData.porcentajeUso || 0) + "%"; 
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
                                        color: (modelData.activo === true || modelData.estado === "Activo") ? "#E8F5E8" : "#FFF3CD"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: (modelData.activo === true || modelData.estado === "Activo") ? "Activo" : "Inactivo"
                                            font.pixelSize: 11
                                            color: (modelData.activo === true || modelData.estado === "Activo") ? "#2E7D32" : "#B8860B"
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
                                                console.log("Editar parcela:", modelData.id)
                                                // TODO: Implementar edición
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
                                                console.log("Eliminar parcela:", modelData.id)
                                                var resultado = modelData.eliminar_parcela(modelData.id)
                                                console.log("Resultado eliminación:", resultado)
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
                                                console.log("Ver detalles parcela:", modelData.id)
                                                // TODO: Implementar vista de detalles
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador Parcelas - CENTRADO
                Item {
                    Layout.fillWidth: true
                    height: 40
                    
                    Paginator {
                        id: paginadorParcelas
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaParcelas
                        totalPages: totalPaginasParcelas
                        
                        onPageChanged: {
                            console.log(`📄 Cambiando a página ${newPage} de parcelas`)
                            modelData.cargar_parcelas_pagina(newPage)
                        }
                    }
                }
            }
        }
    }

    // ==================== DIÁLOGO SIMPLIFICADO PARA AGRICULTOR ====================
        // ==================== FUNCIONES GLOBALES DEL COMPONENTE ====================
    function guardarAgricultor() {
        console.log("🔄 Ejecutando guardarAgricultor...")
        
        // Validaciones básicas
        if (!campoNombre || !campoNombre.text || campoNombre.text.trim() === "") {
            mostrarNotificacion("❌ El nombre es obligatorio", "error")
            return
        }
        
        if (!campoApellido || !campoApellido.text || campoApellido.text.trim() === "") {
            mostrarNotificacion("❌ El apellido es obligatorio", "error")
            return
        }
        
        if (!campoIdentificacion || !campoIdentificacion.text || campoIdentificacion.text.trim() === "") {
            mostrarNotificacion("❌ La identificación es obligatoria", "error")
            return
        }
        
        // Preparar datos
        var datosAgricultor = {
            "nombre": campoNombre.text.trim(),
            "apellido": campoApellido.text.trim(),
            "identificacion": campoIdentificacion.text.trim(),
            "telefono": campoTelefono ? campoTelefono.text.trim() : "",
            "correo": campoCorreo ? campoCorreo.text.trim() : "",
            "direccion": campoDireccion ? campoDireccion.text.trim() : "",
            "activo": comboEstado.currentIndex === 0
        }
        
        console.log("📝 Guardando agricultor:", JSON.stringify(datosAgricultor))
        
        if (dialogoAgricultor.modoEdicion && dialogoAgricultor.agricultorActual) {
            // Actualizar agricultor existente
            var exito = productoresparcelasModel.actualizar_productor(
                dialogoAgricultor.agricultorActual.id_productor, 
                JSON.stringify(datosAgricultor)
            )
            if (exito) {
                mostrarNotificacion("✅ Agricultor actualizado correctamente", "success")
                dialogoAgricultor.close()
                // Recargar datos
                productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
                console.log("Recargando página actual de agricultores:", paginaAgricultores)
            } else {
                mostrarNotificacion("❌ Error al actualizar agricultor", "error")
            }
        } else {
            // Crear nuevo agricultor
            var exito = productoresparcelasModel.agregar_productor(JSON.stringify(datosAgricultor))
            if (exito) {
                mostrarNotificacion("✅ Agricultor creado correctamente", "success")
                dialogoAgricultor.close()
                // Recargar primera página
                productoresparcelasModel.cargar_productores_pagina(1)
            } else {
                mostrarNotificacion("❌ Error al crear agricultor", "error")
            }
        }
    }
    Popup {
        id: dialogoAgricultor
        width: 500
        height: 600
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
            
            // Campos del formulario - SIMPLIFICADOS
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
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
            
            // Botones
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    onClicked: dialogoAgricultor.close()
                }
                
                Button {
                    Layout.fillWidth: true
                    text: dialogoAgricultor.modoEdicion ? "Actualizar" : "Guardar"
                    onClicked: {
                        console.log("Guardar agricultor - Modo edición:", dialogoAgricultor.modoEdicion)
                        guardarAgricultor()
                            // Forzar recarga para asegurar que la interfaz refleje los cambios guardados
                        if (dialogoAgricultor.modoEdicion) {
                            productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
                            console.log("Recargando página actual de agricultores:", paginaAgricultores)
                        } else {
                            productoresparcelasModel.cargar_productores_pagina(1)
                        }
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
            
            // Estado
            var estadoIndex = 0 // Por defecto Activo
            if (agricultor.estado === "Inactivo" || agricultor.activo === false) {
                estadoIndex = 1
            }
            comboEstado.currentIndex = estadoIndex
            
        }
        
        
    }

    // ==================== DIÁLOGO DE CONFIRMACIÓN SIMPLIFICADO ====================
    Popup {
        id: dialogoConfirmacion
        width: 400
        height: 200
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: parent
        
        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#CCCCCC"
            border.width: 1
        }
        
        property string tipo: ""
        property string nombre: ""
        property int id: -1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            
            Text {
                Layout.fillWidth: true
                text: "Confirmar Eliminación"
                font.pixelSize: 18
                font.bold: true
                color: "#D32F2F"
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                Layout.fillWidth: true
                text: `¿Está seguro que desea eliminar ${dialogoConfirmacion.tipo === "agricultor" ? "al agricultor" : "la parcela"}:\n"${dialogoConfirmacion.nombre}"?`
                font.pixelSize: 14
                color: "#424242"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                Layout.fillWidth: true
                text: "⚠️ Esta acción no se puede deshacer"
                font.pixelSize: 12
                color: "#F57C00"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    onClicked: dialogoConfirmacion.close()
                }
                
                Button {
                    Layout.fillWidth: true
                    text: "Eliminar"
                    onClicked: {
                        if (dialogoConfirmacion.tipo === "agricultor") {
                            var resultado = productoresparcelasModel.eliminar_productor(dialogoConfirmacion.id)
                            if (resultado) {
                                mostrarNotificacion("✅ Agricultor eliminado correctamente", "success")
                            } else {
                                mostrarNotificacion("❌ Error al eliminar agricultor", "error")
                            }
                        } else if (dialogoConfirmacion.tipo === "parcela") {
                            var exito = productoresparcelasModel.eliminar_parcela(dialogoConfirmacion.id)
                            if (exito) {
                                mostrarNotificacion("✅ Parcela eliminada correctamente", "success")
                            }
                        }
                        dialogoConfirmacion.close()
                    }
                }
            }
        }
        
        function confirmarEliminacion(tipo, id, nombre) {
            console.log("Confirmando eliminación:", tipo, id, nombre)
            
            // VALIDAR que id sea un número válido
            if (id === undefined || id === null || id < 0) {
                console.error("❌ ID inválido para eliminación:", id)
                mostrarNotificacion("❌ Error: ID inválido", "error")
                return
            }
            
            this.tipo = tipo
            this.id = parseInt(id)  // Asegurar que sea int
            this.nombre = nombre || "Sin nombre"
            open()
        }
    }
}