import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: productoresRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Agricultores", "icon": "recursos/image/icons/agricultores.png", "color": "#2E7D32"},
        {"text": "Parcelas", "icon": "recursos/image/icons/parcela.png", "color": "#F57C00"},
        {"text": "Mapa", "icon": "recursos/image/icons/mapa.png", "color": "#0288D1"}
    ]
    
    // Propiedades para datos dinámicos conectados al modelo
    property var agricultoresData: productoresparcelasModel.productores || []
    property var parcelasData: productoresparcelasModel.parcelas || []
    
    // Propiedades para paginación conectadas al modelo
    property int paginaAgricultores: productoresparcelasModel.paginaActualProductores || 1
    property int totalPaginasAgricultores: productoresparcelasModel.totalPaginasProductores || 1
    property int paginaParcelas: productoresparcelasModel.paginaActualParcelas || 1
    property int totalPaginasParcelas: productoresparcelasModel.totalPaginasParcelas || 1

    // Propiedades para filtros
    property var estadosAgricultores: ["Todos", "Activo", "Inactivo"]
    property var estadosParcelas: ["Todos", "Activo", "Inactivo"]

    // Conexiones a las señales del modelo
    Connections {
        target: productoresparcelasModel
        function onProductoresChanged() {
            console.log("✅ Datos de agricultores actualizados")
            agricultoresData = productoresparcelasModel.productores
        }
        
        function onParcelasChanged() {
            console.log("✅ Datos de parcelas actualizados")
            parcelasData = productoresparcelasModel.parcelas
        }
        
        function onOperacionCompleta(tipo, exito, mensaje) {
            console.log(`Operación ${tipo}: ${exito ? 'Éxito' : 'Error'} - ${mensaje}`)
            if (exito) {
                mostrarNotificacion(`✅ ${mensaje}`, "success")
            } else {
                mostrarNotificacion(`❌ ${mensaje}`, "error")
            }
        }
    }

    // Inicializar datos al cargar el componente
    Component.onCompleted: {
        console.log("🔄 Inicializando módulo de productores y parcelas...")
        productoresparcelasModel.cargar_productores()
        productoresparcelasModel.cargar_parcelas()
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
                        console.log("Buscar agricultor:", text)
                        if (text.length >= 2) {
                            var resultados = productoresparcelasModel.filtrar_productores_por_nombre(text)
                            console.log(`🔍 Resultados búsqueda: ${resultados.length} agricultores`)
                        } else if (text === "") {
                            productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
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
                        model: agricultoresData
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
                                // En el delegate de parcelas
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
                                                console.log("Editar agricultor:", modelData.id)
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
                                                console.log("Eliminar agricultor:", modelData.id)
                                                var nombreCompleto = (modelData.nombre || "") + " " + (modelData.apellido || "")
                                                dialogoConfirmacion.confirmarEliminacion("agricultor", modelData.id, nombreCompleto.trim())
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
                            var resultados = productoresparcelasModel.filtrar_parcelas_por_nombre(text)
                            console.log(`🔍 Resultados búsqueda: ${resultados.length} parcelas`)
                        } else if (text === "") {
                            productoresparcelasModel.cargar_parcelas_pagina(paginaParcelas)
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
                        model: parcelasData
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
                                // En el delegate de productores
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
                                // En el delegate de parcelas
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
                                                // TODO: Implementar confirmación y eliminación
                                                var resultado = productoresparcelasModel.eliminar_parcela(modelData.id)
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
                            productoresparcelasModel.cargar_parcelas_pagina(newPage)
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 3: MAPA ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 2
            opacity: tabActiva === 2 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            Rectangle {
                anchors.fill: parent
                color: "white"
                radius: 10
                border.color: "#E0E0E0"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "Mapa - En desarrollo"
                    color: "#999999"
                    font.pixelSize: 18
                }
            }
        }
    }

    // Diálogo para Agregar/Editar Agricultor
    Popup {
        id: dialogoAgricultor
        width: 600
        height: 700
        modal: true
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: parent
        padding: 0
        
        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#E0E0E0"
            border.width: 1
        }
        
        property bool modoEdicion: false
        property var agricultorActual: null
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // Header del diálogo
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: dialogoAgricultor.modoEdicion ? "#1976D2" : "#2E7D32"
                radius: 12
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    
                    Text {
                        Layout.fillWidth: true
                        text: dialogoAgricultor.modoEdicion ? "EDITAR AGRICULTOR" : "NUEVO AGRICULTOR"
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                    }
                    
                    Button {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        background: Rectangle {
                            color: "transparent"
                            radius: 16
                            border.color: "white"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: "×"
                            font.pixelSize: 20
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: dialogoAgricultor.close()
                    }
                }
            }
            
            // Contenido del formulario
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 20
                clip: true
                
                ColumnLayout {
                    width: parent.width
                    spacing: 15
                    
                    // Fila 1: Nombre y Apellido
                    RowLayout {
                        spacing: 15
                        
                        Loader {
                            Layout.fillWidth: true
                            sourceComponent: componenteCampoFormulario
                            property string label: "Nombre *"
                            property string placeholder: "Ingrese el nombre"
                            property string valor: dialogoAgricultor.agricultorActual ? dialogoAgricultor.agricultorActual.nombre : ""
                            onValorChanged: if (dialogoAgricultor.agricultorActual) dialogoAgricultor.agricultorActual.nombre = valor
                        }
                        
                        Loader {
                            Layout.fillWidth: true
                            sourceComponent: componenteCampoFormulario
                            property string label: "Apellido *"
                            property string placeholder: "Ingrese el apellido"
                            property string valor: dialogoAgricultor.agricultorActual ? dialogoAgricultor.agricultorActual.apellido : ""
                            onValorChanged: if (dialogoAgricultor.agricultorActual) dialogoAgricultor.agricultorActual.apellido = valor
                        }
                    }
                    
                    // Fila 2: Identificación y Teléfono
                    RowLayout {
                        spacing: 15
                        
                        Loader {
                            Layout.fillWidth: true
                            sourceComponent: componenteCampoFormulario
                            property string label: "Identificación *"
                            property string placeholder: "Número de identificación"
                            property string valor: dialogoAgricultor.agricultorActual ? dialogoAgricultor.agricultorActual.identificacion : ""
                            onValorChanged: if (dialogoAgricultor.agricultorActual) dialogoAgricultor.agricultorActual.identificacion = valor
                        }
                        
                        Loader {
                            Layout.fillWidth: true
                            sourceComponent: componenteCampoFormulario
                            property string label: "Teléfono"
                            property string placeholder: "Número de teléfono"
                            property string valor: dialogoAgricultor.agricultorActual ? dialogoAgricultor.agricultorActual.telefono : ""
                            onValorChanged: if (dialogoAgricultor.agricultorActual) dialogoAgricultor.agricultorActual.telefono = valor
                        }
                    }
                    
                    // Correo electrónico
                    Loader {
                        Layout.fillWidth: true
                        sourceComponent: componenteCampoFormulario
                        property string label: "Correo Electrónico"
                        property string placeholder: "correo@ejemplo.com"
                        property string valor: dialogoAgricultor.agricultorActual ? dialogoAgricultor.agricultorActual.correo : ""
                        onValorChanged: if (dialogoAgricultor.agricultorActual) dialogoAgricultor.agricultorActual.correo = valor
                    }
                    
                    // Dirección
                    Loader {
                        Layout.fillWidth: true
                        sourceComponent: componenteCampoFormulario
                        property string label: "Dirección"
                        property string placeholder: "Dirección completa"
                        property string valor: dialogoAgricultor.agricultorActual ? dialogoAgricultor.agricultorActual.direccion : ""
                        onValorChanged: if (dialogoAgricultor.agricultorActual) dialogoAgricultor.agricultorActual.direccion = valor
                    }
                    
                    // Fila 3: Estado y Fecha de Registro
                    RowLayout {
                        spacing: 15
                        
                        Loader {
                            Layout.fillWidth: true
                            sourceComponent: componenteCampoFormulario
                            property string label: "Estado"
                            property bool isComboBox: true
                            property var comboOptions: ["Activo", "Inactivo"]
                            property string valor: dialogoAgricultor.agricultorActual ? (dialogoAgricultor.agricultorActual.estado || "Activo") : "Activo"
                            onValorChanged: if (dialogoAgricultor.agricultorActual) dialogoAgricultor.agricultorActual.estado = valor
                        }
                        
                        Loader {
                            Layout.fillWidth: true
                            sourceComponent: componenteCampoFormulario
                            property string label: "Fecha de Registro"
                            property string placeholder: "Fecha automática"
                            property bool readOnly: true
                            property string valor: new Date().toLocaleDateString(Qt.locale(), "dd/MM/yyyy")
                        }
                    }
                    
                    // Notas/Comentarios
                    Loader {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        sourceComponent: componenteCampoFormulario
                        property string label: "Notas Adicionales"
                        property string placeholder: "Información adicional sobre el agricultor..."
                        property bool isTextArea: true
                        property string valor: dialogoAgricultor.agricultorActual ? dialogoAgricultor.agricultorActual.notas : ""
                        onValorChanged: if (dialogoAgricultor.agricultorActual) dialogoAgricultor.agricultorActual.notas = valor
                    }
                    
                    // Texto de campos obligatorios
                    Text {
                        Layout.fillWidth: true
                        text: "* Campos obligatorios"
                        font.pixelSize: 12
                        color: "#757575"
                        font.italic: true
                    }
                }
            }
            
            // Footer con botones
            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: "#FAFAFA"
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 15
                    
                    Button {
                        text: "Cancelar"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        background: Rectangle {
                            color: parent.hovered ? "#E0E0E0" : "#F5F5F5"
                            radius: 8
                            border.color: "#BDBDBD"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#424242"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: dialogoAgricultor.close()
                    }
                    
                    Button {
                        text: dialogoAgricultor.modoEdicion ? "Actualizar" : "Guardar"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        background: Rectangle {
                            color: parent.hovered ? (dialogoAgricultor.modoEdicion ? "#1565C0" : "#1B5E20") : (dialogoAgricultor.modoEdicion ? "#1976D2" : "#2E7D32")
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
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
        }
        
        function abrirParaNuevo() {
            modoEdicion = false
            agricultorActual = {
                "nombre": "",
                "apellido": "",
                "identificacion": "",
                "telefono": "",
                "correo": "",
                "direccion": "",
                "estado": "Activo",
                "notas": ""
            }
            open()
        }
        
        function abrirParaEditar(agricultor) {
            modoEdicion = true
            agricultorActual = JSON.parse(JSON.stringify(agricultor)) // Deep copy
            open()
        }
        
       function guardarAgricultor() {
            // Validaciones básicas
            if (!agricultorActual.nombre || agricultorActual.nombre.trim() === "") {
                mostrarNotificacion("❌ El nombre es obligatorio", "error")
                return
            }
            
            if (!agricultorActual.apellido || agricultorActual.apellido.trim() === "") {
                mostrarNotificacion("❌ El apellido es obligatorio", "error")
                return
            }
            
            if (!agricultorActual.identificacion || agricultorActual.identificacion.trim() === "") {
                mostrarNotificacion("❌ La identificación es obligatoria", "error")
                return
            }
            
            // Convertir estado a activo (boolean)
            var estaActivo = (agricultorActual.estado === "Activo")
            
            // Preparar datos para el modelo
            var datosAgricultor = {
                "nombre": agricultorActual.nombre.trim(),
                "apellido": agricultorActual.apellido.trim(),
                "identificacion": agricultorActual.identificacion.trim(),
                "telefono": agricultorActual.telefono ? agricultorActual.telefono.trim() : "",
                "correo": agricultorActual.correo ? agricultorActual.correo.trim() : "",
                "direccion": agricultorActual.direccion ? agricultorActual.direccion.trim() : "",
                "activo": estaActivo, // Usar la propiedad que espera el backend
                "notas": agricultorActual.notas ? agricultorActual.notas.trim() : ""
            }
            
            console.log("📝 Guardando agricultor:", JSON.stringify(datosAgricultor))
            
            if (modoEdicion) {
                // Actualizar agricultor existente
                var exito = productoresparcelasModel.actualizar_productor(agricultorActual.id, JSON.stringify(datosAgricultor))
                if (exito) {
                    mostrarNotificacion("✅ Agricultor actualizado correctamente", "success")
                    dialogoAgricultor.close()
                    // Recargar datos
                    productoresparcelasModel.cargar_productores_pagina(paginaAgricultores)
                } else {
                    mostrarNotificacion("❌ Error al actualizar agricultor", "error")
                }
            } else {
                // Crear nuevo agricultor
                var exito = productoresparcelasModel.agregar_productor(JSON.stringify(datosAgricultor))
                if (exito) {
                    mostrarNotificacion("✅ Agricultor creado correctamente", "success")
                    dialogoAgricultor.close()
                    // Recargar datos
                    productoresparcelasModel.cargar_productores_pagina(1) // Volver a primera página
                } else {
                    mostrarNotificacion("❌ Error al crear agricultor", "error")
                }
            }
        }
    }

    // Diálogo de confirmación para eliminar
    Popup {
        id: dialogoConfirmacion
        width: 400
        height: 200
        modal: true
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: parent
        
        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#E0E0E0"
            border.width: 1
        }
        
        property string tipo: ""
        property string nombre: ""
        property int id: -1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
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
                spacing: 15
                
                Button {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    Layout.preferredHeight: 40
                    background: Rectangle {
                        color: parent.hovered ? "#E0E0E0" : "#F5F5F5"
                        radius: 8
                        border.color: "#BDBDBD"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#424242"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: dialogoConfirmacion.close()
                }
                
                Button {
                    Layout.fillWidth: true
                    text: "Eliminar"
                    Layout.preferredHeight: 40
                    background: Rectangle {
                        color: parent.hovered ? "#C62828" : "#D32F2F"
                        radius: 8
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
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
            this.tipo = tipo
            this.id = id
            this.nombre = nombre
            open()
        }
    }

    // Componente reutilizable para campos de formulario - VERSIÓN CORREGIDA
    Component {
        id: componenteCampoFormulario
        
        ColumnLayout {
            id: campoWrapper
            Layout.fillWidth: true
            spacing: 5
            
            property string label: ""
            property string placeholder: ""
            property string valor: ""
            property bool readOnly: false
            property bool isComboBox: false
            property bool isTextArea: false
            property var comboOptions: []
            

            
            Text {
                text: campoWrapper.label
                font.pixelSize: 14
                font.bold: true
                color: "#424242"
            }
            
            Loader {
                id: campoLoader
                Layout.fillWidth: true
                sourceComponent: {
                    if (campoWrapper.isComboBox) return componenteComboBox
                    else if (campoWrapper.isTextArea) return componenteTextArea
                    else return componenteInput
                }
                
                onLoaded: {
                    // Configurar el valor inicial cuando el componente se carga
                    if (item) {
                        if (campoWrapper.isComboBox) {
                            item.currentIndex = campoWrapper.comboOptions.indexOf(campoWrapper.valor)
                        } else {
                            item.text = campoWrapper.valor
                        }
                    }
                }
            }
        }
    }
    
    // Componentes internos para el campo de formulario
    Component {
        id: componenteInput
        
        TextField {
            id: inputField
            placeholderText: campoWrapper.placeholder
            text: campoWrapper.valor
            readOnly: campoWrapper.readOnly
            selectByMouse: true
            
            background: Rectangle {
                color: inputField.readOnly ? "#F5F5F5" : "white"
                radius: 8
                border.color: inputField.activeFocus ? "#2196F3" : "#E0E0E0"
                border.width: 1
            }
            
            onTextChanged: {
                if (campoWrapper.valor !== text) {
                    campoWrapper.valor = text
                    campoWrapper.valorChanged(text)
                }
            }
        }
    }
    
    Component {
        id: componenteTextArea
        
        TextArea {
            id: textAreaField
            placeholderText: campoWrapper.placeholder
            text: campoWrapper.valor
            wrapMode: TextArea.Wrap
            selectByMouse: true
            
            background: Rectangle {
                color: "white"
                radius: 8
                border.color: textAreaField.activeFocus ? "#2196F3" : "#E0E0E0"
                border.width: 1
            }
            
            onTextChanged: {
                if (campoWrapper.valor !== text) {
                    campoWrapper.valor = text
                    campoWrapper.valorChanged(text)
                }
            }
        }
    }
    
    Component {
        id: componenteComboBox
        
        ComboBox {
            id: comboBoxField
            model: campoWrapper.comboOptions
            
            Component.onCompleted: {
                // Establecer el índice inicial basado en el valor actual
                var index = campoWrapper.comboOptions.indexOf(campoWrapper.valor)
                if (index >= 0) {
                    currentIndex = index
                }
            }
            
            background: Rectangle {
                color: "white"
                radius: 8
                border.color: comboBoxField.activeFocus ? "#2196F3" : "#E0E0E0"
                border.width: 1
            }
            
            onCurrentTextChanged: {
                if (currentText && campoWrapper.valor !== currentText) {
                    campoWrapper.valor = currentText
                    campoWrapper.valorChanged(currentText)
                }
            }
            
            // Asegurar que se actualice cuando cambie el valor externamente
            Connections {
                target: campoWrapper
                function onValorChanged() {
                    var index = comboBoxField.find(campoWrapper.valor)
                    if (index >= 0 && index !== comboBoxField.currentIndex) {
                        comboBoxField.currentIndex = index
                    }
                }
            }
        }
    }
}