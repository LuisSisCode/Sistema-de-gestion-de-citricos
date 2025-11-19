import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import "./components"

Rectangle {
    id: maquinariaRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // ==================== PROPIEDADES ====================
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Equipos", "icon": "recursos/image/icons/equipo.png", "color": "#2E7D32"},
        {"text": "Mantenimiento", "icon": "recursos/image/icons/mantenimientoMaq.png", "color": "#F57C00"},
        {"text": "Combustible", "icon": "recursos/image/icons/combustiblemaq.png", "color": "#0288D1"}
    ]
    
    // Listas filtradas
    property var equiposFiltrados: []
    property var mantenimientosFiltrados: []
    property var combustiblesFiltrados: []
    
    // Búsqueda
    property string searchTextEquipos: ""
    property string searchTextMantenimiento: ""
    property string searchTextCombustible: ""
    
    // Filtros
    property int filtroTipoEquipoIndex: 0
    property int filtroEstadoEquipoIndex: 0
    property int filtroTipoMantenimientoIndex: 0
    property int filtroTipoCombustibleIndex: 0
    
    // Opciones de filtros
    property var tiposEquipo: ["Todos los tipos", "Tractor", "Fumigadora", "Bomba de riego", "Pulverizadora", "Cosechadora", "Otro"]
    property var estadosEquipo: ["Todos", "Operativo", "En mantenimiento", "Fuera de servicio"]
    property var tiposMantenimiento: ["Todos", "Preventivo", "Correctivo", "Predictivo"]
    property var tiposCombustible: ["Todos", "Diesel", "Gasolina", "Eléctrico"]
    property var estadosMantenimiento: ["Todos", "Programado", "En progreso", "Completado"]
    
    // Datos para edición
    property var equipoSeleccionado: null
    property var mantenimientoSeleccionado: null
    property var combustibleSeleccionado: null
    
    // ==================== CONEXIONES CON EL MODELO ====================
    Connections {
        target: maquinariaModel
        
        function onMaquinariaChanged() {
            console.log("✅ Señal maquinariaChanged recibida")
            aplicarFiltrosEquipos()
        }
        
        function onMantenimientosChanged() {
            console.log("✅ Señal mantenimientosChanged recibida")
            aplicarFiltrosMantenimiento()
        }
        
        function onComprasChanged() {
            console.log("✅ Señal comprasChanged recibida")
            aplicarFiltrosCombustible()
        }
    }
    
    // ==================== COMPONENT.ONCOMPLETED ====================
    Component.onCompleted: {
        console.log("🚜 Módulo Maquinaria inicializado")
        cargarDatosIniciales()
    }
    
    // ==================== FUNCIONES PRINCIPALES ====================
    function cargarDatosIniciales() {
        console.log("📥 Cargando datos iniciales de maquinaria...")
        maquinariaModel.cargar_maquinaria()
        maquinariaModel.cargar_mantenimientos()
        maquinariaModel.cargar_compras_combustible()
    }
    
    // ==================== FILTROS EQUIPOS ====================
    function aplicarFiltrosEquipos() {
        var maquinaria = maquinariaModel.maquinaria
        console.log("🔍 Aplicando filtros a equipos. Total:", maquinaria.length)
        
        equiposFiltrados = maquinaria.filter(function(equipo) {
            // Filtro por búsqueda
            var coincideBusqueda = true
            if (searchTextEquipos !== "") {
                var searchLower = searchTextEquipos.toLowerCase()
                coincideBusqueda = (
                    equipo.codigo.toLowerCase().includes(searchLower) ||
                    equipo.nombre.toLowerCase().includes(searchLower) ||
                    equipo.tipo.toLowerCase().includes(searchLower) ||
                    equipo.marca.toLowerCase().includes(searchLower)
                )
            }
            
            // Filtro por tipo
            var coincideTipo = true
            if (filtroTipoEquipoIndex > 0) {
                var tipoSeleccionado = tiposEquipo[filtroTipoEquipoIndex]
                coincideTipo = (equipo.tipo === tipoSeleccionado)
            }
            
            // Filtro por estado
            var coincideEstado = true
            if (filtroEstadoEquipoIndex > 0) {
                var estadoSeleccionado = estadosEquipo[filtroEstadoEquipoIndex]
                coincideEstado = (equipo.estado === estadoSeleccionado)
            }
            
            return coincideBusqueda && coincideTipo && coincideEstado
        })
        
        console.log("✅ Equipos filtrados:", equiposFiltrados.length)
    }
    
    // ==================== FILTROS MANTENIMIENTO ====================
    function aplicarFiltrosMantenimiento() {
        var mantenimientos = maquinariaModel.mantenimientos
        console.log("🔍 Aplicando filtros a mantenimientos. Total:", mantenimientos.length)
        
        mantenimientosFiltrados = mantenimientos.filter(function(mant) {
            // Filtro por búsqueda
            var coincideBusqueda = true
            if (searchTextMantenimiento !== "") {
                var searchLower = searchTextMantenimiento.toLowerCase()
                coincideBusqueda = (
                    mant.maquinaria_nombre.toLowerCase().includes(searchLower) ||
                    mant.descripcion.toLowerCase().includes(searchLower) ||
                    mant.responsable_nombre.toLowerCase().includes(searchLower)
                )
            }
            
            // Filtro por tipo
            var coincideTipo = true
            if (filtroTipoMantenimientoIndex > 0) {
                var tipoSeleccionado = tiposMantenimiento[filtroTipoMantenimientoIndex]
                coincideTipo = (mant.tipo === tipoSeleccionado)
            }
            
            return coincideBusqueda && coincideTipo
        })
        
        console.log("✅ Mantenimientos filtrados:", mantenimientosFiltrados.length)
    }
    
    // ==================== FILTROS COMBUSTIBLE ====================
    function aplicarFiltrosCombustible() {
        var compras = maquinariaModel.compras
        console.log("🔍 Aplicando filtros a combustible. Total:", compras.length)
        
        combustiblesFiltrados = compras.filter(function(compra) {
            // Filtro por búsqueda
            var coincideBusqueda = true
            if (searchTextCombustible !== "") {
                var searchLower = searchTextCombustible.toLowerCase()
                coincideBusqueda = (
                    compra.tipo_combustible.toLowerCase().includes(searchLower) ||
                    compra.proveedor_nombre.toLowerCase().includes(searchLower) ||
                    compra.observaciones.toLowerCase().includes(searchLower)
                )
            }
            
            // Filtro por tipo
            var coincideTipo = true
            if (filtroTipoCombustibleIndex > 0) {
                var tipoSeleccionado = tiposCombustible[filtroTipoCombustibleIndex]
                coincideTipo = (compra.tipo_combustible === tipoSeleccionado)
            }
            
            return coincideBusqueda && coincideTipo
        })
        
        console.log("✅ Combustible filtrado:", combustiblesFiltrados.length)
    }
    
    // ==================== ACCIONES EQUIPOS ====================
    function abrirDialogNuevoEquipo() {
        equipoSeleccionado = null
        dialogEquipo.tituloDialog = "Nuevo Equipo"
        dialogEquipo.limpiarCampos()
        dialogEquipo.open()
    }
    
    function abrirDialogEditarEquipo(equipo) {
        equipoSeleccionado = equipo
        dialogEquipo.tituloDialog = "Editar Equipo"
        dialogEquipo.cargarDatos(equipo)
        dialogEquipo.open()
    }
    
    function eliminarEquipo(id, codigo) {
        equipoSeleccionado = {"id_maquinaria": id, "codigo": codigo}
        confirmDialogEquipo.titulo = "Eliminar Equipo"
        confirmDialogEquipo.mensaje = "¿Está seguro de eliminar el equipo '" + codigo + "'?"
        confirmDialogEquipo.open()
    }
    
    function confirmarEliminarEquipo() {
        if (equipoSeleccionado) {
            var resultado = maquinariaModel.eliminar_maquinaria(equipoSeleccionado.id_maquinaria)
            if (resultado) {
                mostrarNotificacion("Equipo eliminado correctamente", "success")
            } else {
                mostrarNotificacion("Error al eliminar el equipo", "error")
            }
        }
    }
    
    // ==================== ACCIONES MANTENIMIENTO ====================
    function abrirDialogNuevoMantenimiento() {
        mantenimientoSeleccionado = null
        dialogMantenimiento.tituloDialog = "Nuevo Mantenimiento"
        dialogMantenimiento.limpiarCampos()
        dialogMantenimiento.open()
    }
    
    function abrirDialogEditarMantenimiento(mantenimiento) {
        mantenimientoSeleccionado = mantenimiento
        dialogMantenimiento.tituloDialog = "Editar Mantenimiento"
        dialogMantenimiento.cargarDatos(mantenimiento)
        dialogMantenimiento.open()
    }
    
    function eliminarMantenimiento(id, descripcion) {
        mantenimientoSeleccionado = {"id_mantenimiento": id, "descripcion": descripcion}
        confirmDialogMantenimiento.titulo = "Eliminar Mantenimiento"
        confirmDialogMantenimiento.mensaje = "¿Está seguro de eliminar este mantenimiento?"
        confirmDialogMantenimiento.open()
    }
    
    function confirmarEliminarMantenimiento() {
        if (mantenimientoSeleccionado) {
            var resultado = maquinariaModel.eliminar_mantenimiento(mantenimientoSeleccionado.id_mantenimiento)
            if (resultado) {
                mostrarNotificacion("Mantenimiento eliminado correctamente", "success")
            } else {
                mostrarNotificacion("Error al eliminar el mantenimiento", "error")
            }
        }
    }
    
    // ==================== ACCIONES COMBUSTIBLE ====================
    function abrirDialogNuevoCombustible() {
        combustibleSeleccionado = null
        dialogCombustible.tituloDialog = "Nuevo Registro de Combustible"
        dialogCombustible.limpiarCampos()
        dialogCombustible.open()
    }
    
    function abrirDialogEditarCombustible(combustible) {
        combustibleSeleccionado = combustible
        dialogCombustible.tituloDialog = "Editar Registro de Combustible"
        dialogCombustible.cargarDatos(combustible)
        dialogCombustible.open()
    }
    
    function eliminarCombustible(id, tipo) {
        combustibleSeleccionado = {"id_compra": id, "tipo_combustible": tipo}
        confirmDialogCombustible.titulo = "Eliminar Registro"
        confirmDialogCombustible.mensaje = "¿Está seguro de eliminar este registro de combustible?"
        confirmDialogCombustible.open()
    }
    
    function confirmarEliminarCombustible() {
        if (combustibleSeleccionado) {
            var resultado = maquinariaModel.eliminar_compra_combustible(combustibleSeleccionado.id_compra)
            if (resultado) {
                mostrarNotificacion("Registro eliminado correctamente", "success")
            } else {
                mostrarNotificacion("Error al eliminar el registro", "error")
            }
        }
    }
    
    // ==================== NOTIFICACIÓN ====================
    function mostrarNotificacion(mensaje, tipo) {
        notificationPopup.message = mensaje
        notificationPopup.notificationType = tipo
        notificationPopup.open()
    }

    // ==================== TÍTULO ====================
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"

        Text {
            text: "GESTIÓN DE EQUIPOS, COMBUSTIBLE Y MANTENIMIENTO"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.centerIn: parent
        }
    }

    // ==================== BARRA DE PESTAÑAS ====================
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
            tabsData: maquinariaRoot.tabsInfo
            tabActiva: maquinariaRoot.tabActiva
            
            onTabChanged: function(index) {
                maquinariaRoot.tabActiva = index
            }
        }
    }

    // ==================== ÁREA DE CONTENIDO ====================
    Item {
        id: contentArea
        width: parent.width - 40
        height: parent.height - modernTabBar.y - modernTabBar.height - 20
        anchors.top: modernTabBar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        
        // ==================== TAB 1: EQUIPOS ====================
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
                    id: filterHeaderEquipos
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Equipo"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#2E7D32"
                    searchPlaceholder: "Buscar equipo..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: tiposEquipo
                    filterPlaceholder: "Tipo de equipo..."
                    filterWidth: 180
                    
                    onButtonClicked: {
                        abrirDialogNuevoEquipo()
                    }
                    
                    onSearchTextChanged: function(text) {
                        searchTextEquipos = text
                        aplicarFiltrosEquipos()
                    }
                    
                    onFilterChanged: function(index) {
                        filtroTipoEquipoIndex = index
                        aplicarFiltrosEquipos()
                    }
                }
                
                // Tabla de equipos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: listaEquipos
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: equiposFiltrados
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.12; height: parent.height; text: "Código"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.20; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.13; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.13; height: parent.height; text: "Marca"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Combustible"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { 
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: modelData.codigo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.20
                                    height: parent.height
                                    text: modelData.nombre
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.13
                                    height: parent.height
                                    text: modelData.tipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.13
                                    height: parent.height
                                    text: modelData.marca
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: modelData.tipo_combustible
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: contentText.width + 20
                                        height: 24
                                        radius: 12
                                        color: {
                                            if (modelData.estado === "Operativo") return "#C8E6C9"
                                            if (modelData.estado === "En mantenimiento") return "#FFE082"
                                            return "#FFCDD2"
                                        }
                                        
                                        Text {
                                            id: contentText
                                            anchors.centerIn: parent
                                            text: modelData.estado
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: {
                                                if (modelData.estado === "Operativo") return "#2E7D32"
                                                if (modelData.estado === "En mantenimiento") return "#F57C00"
                                                return "#C62828"
                                            }
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32
                                            height: 32
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
                                            onClicked: abrirDialogEditarEquipo(modelData)
                                        }
                                        
                                        Button {
                                            width: 32
                                            height: 32
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
                                            onClicked: eliminarEquipo(modelData.id_maquinaria, modelData.codigo)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 2: MANTENIMIENTO ====================
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
                
                FilterHeaderComponent {
                    id: filterHeaderMantenimiento
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Mantenimiento"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#F57C00"
                    searchPlaceholder: "Buscar mantenimiento..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: tiposMantenimiento
                    filterPlaceholder: "Tipo de mantenimiento..."
                    filterWidth: 180
                    
                    onButtonClicked: {
                        abrirDialogNuevoMantenimiento()
                    }
                    
                    onSearchTextChanged: function(text) {
                        searchTextMantenimiento = text
                        aplicarFiltrosMantenimiento()
                    }
                    
                    onFilterChanged: function(index) {
                        filtroTipoMantenimientoIndex = index
                        aplicarFiltrosMantenimiento()
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: listaMantenimientos
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: mantenimientosFiltrados
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.15; height: parent.height; text: "Equipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Costo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.25; height: parent.height; text: "Descripción"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { 
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: modelData.maquinaria_nombre
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: modelData.tipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: modelData.fecha_realizada || "N/A"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: "Bs. " + modelData.costo_total.toFixed(2)
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#F57C00"
                                }
                                
                                Text { 
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: modelData.descripcion
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: Math.max(estadoText.width + 20, 80)
                                        height: 24
                                        radius: 12
                                        color: {
                                            if (modelData.estado === "Completado") return "#C8E6C9"
                                            if (modelData.estado === "En progreso") return "#FFE082"
                                            return "#BBDEFB"
                                        }
                                        
                                        Text {
                                            id: estadoText
                                            anchors.centerIn: parent
                                            text: modelData.estado
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: {
                                                if (modelData.estado === "Completado") return "#2E7D32"
                                                if (modelData.estado === "En progreso") return "#F57C00"
                                                return "#1976D2"
                                            }
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32
                                            height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFF3E0" : "transparent"
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
                                            onClicked: abrirDialogEditarMantenimiento(modelData)
                                        }
                                        
                                        Button {
                                            width: 32
                                            height: 32
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
                                            onClicked: eliminarMantenimiento(modelData.id_mantenimiento, modelData.descripcion)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 3: COMBUSTIBLE ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 2
            opacity: tabActiva === 2 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                
                FilterHeaderComponent {
                    id: filterHeaderCombustible
                    Layout.fillWidth: true
                    height: 50
                    buttonText: "Nuevo Registro"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#0288D1"
                    searchPlaceholder: "Buscar combustible..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: tiposCombustible
                    filterPlaceholder: "Tipo de combustible..."
                    filterWidth: 180
                    
                    onButtonClicked: {
                        abrirDialogNuevoCombustible()
                    }
                    
                    onSearchTextChanged: function(text) {
                        searchTextCombustible = text
                        aplicarFiltrosCombustible()
                    }
                    
                    onFilterChanged: function(index) {
                        filtroTipoCombustibleIndex = index
                        aplicarFiltrosCombustible()
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        id: listaCombustibles
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: combustiblesFiltrados
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.12; height: parent.height; text: "Tipo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Fecha"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.10; height: parent.height; text: "Cantidad"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Precio Unit."; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Total"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Proveedor"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Observaciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.15; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
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
                                
                                Text { 
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: modelData.tipo_combustible
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: modelData.fecha_compra
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: modelData.cantidad.toFixed(1) + " " + modelData.unidad_medida
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Bs. " + modelData.precio_unitario.toFixed(2)
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Bs. " + modelData.precio_total.toFixed(2)
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#0288D1"
                                }
                                
                                Text { 
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: modelData.proveedor_nombre
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Text { 
                                    width: parent.width * 0.14
                                    height: parent.height
                                    text: modelData.observaciones
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32
                                            height: 32
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
                                            onClicked: abrirDialogEditarCombustible(modelData)
                                        }
                                        
                                        Button {
                                            width: 32
                                            height: 32
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
                                            onClicked: eliminarCombustible(modelData.id_compra, modelData.tipo_combustible)
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
    
    // ==================== DIÁLOGOS ====================
    
    // Dialog para Equipos
    Dialog {
        id: dialogEquipo
        title: tituloDialog
        width: 600
        height: 500
        modal: true
        anchors.centerIn: parent
        
        property string tituloDialog: "Nuevo Equipo"
        
        function limpiarCampos() {
            txtCodigo.text = ""
            txtNombre.text = ""
            txtMarca.text = ""
            txtUbicacion.text = ""
            comboTipo.currentIndex = 0
            comboCombustible.currentIndex = 0
            comboEstado.currentIndex = 0
        }
        
        function cargarDatos(equipo) {
            txtCodigo.text = equipo.codigo
            txtNombre.text = equipo.nombre
            txtMarca.text = equipo.marca
            txtUbicacion.text = equipo.ubicacion_actual || ""
            
            // Buscar índice para tipo
            for (var i = 0; i < tiposEquipo.length; i++) {
                if (tiposEquipo[i] === equipo.tipo) {
                    comboTipo.currentIndex = i - 1 // -1 porque el primer item es "Todos"
                    break
                }
            }
            
            // Buscar índice para combustible
            for (i = 0; i < tiposCombustible.length; i++) {
                if (tiposCombustible[i] === equipo.tipo_combustible) {
                    comboCombustible.currentIndex = i - 1
                    break
                }
            }
            
            // Buscar índice para estado
            for (i = 0; i < estadosEquipo.length; i++) {
                if (estadosEquipo[i] === equipo.estado) {
                    comboEstado.currentIndex = i - 1
                    break
                }
            }
        }
        
        contentItem: ScrollView {
            implicitWidth: 580
            implicitHeight: 450
            
            ColumnLayout {
                width: parent.width
                spacing: 15
                
                Text {
                    text: "Código *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtCodigo
                    Layout.fillWidth: true
                    placeholderText: "Ej: TR-001"
                }
                
                Text {
                    text: "Nombre *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtNombre
                    Layout.fillWidth: true
                    placeholderText: "Ej: Tractor John Deere 5075E"
                }
                
                Text {
                    text: "Tipo *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                ComboBox {
                    id: comboTipo
                    Layout.fillWidth: true
                    model: tiposEquipo.slice(1) // Excluir "Todos los tipos"
                }
                
                Text {
                    text: "Marca *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtMarca
                    Layout.fillWidth: true
                    placeholderText: "Ej: John Deere"
                }
                
                Text {
                    text: "Tipo de Combustible"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                ComboBox {
                    id: comboCombustible
                    Layout.fillWidth: true
                    model: tiposCombustible.slice(1) // Excluir "Todos"
                }
                
                Text {
                    text: "Estado"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                ComboBox {
                    id: comboEstado
                    Layout.fillWidth: true
                    model: estadosEquipo.slice(1) // Excluir "Todos"
                    currentIndex: 0 // Por defecto "Operativo"
                }
                
                Text {
                    text: "Ubicación Actual"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtUbicacion
                    Layout.fillWidth: true
                    placeholderText: "Ej: Parcela A"
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                enabled: txtCodigo.text !== "" && txtNombre.text !== "" && txtMarca.text !== ""
            }
            
            onAccepted: {
                var datos = {
                    "codigo": txtCodigo.text,
                    "nombre": txtNombre.text,
                    "tipo": tiposEquipo[comboTipo.currentIndex + 1],
                    "marca": txtMarca.text,
                    "tipo_combustible": tiposCombustible[comboCombustible.currentIndex + 1],
                    "estado": estadosEquipo[comboEstado.currentIndex + 1],
                    "ubicacion_actual": txtUbicacion.text
                }
                
                var resultado
                if (equipoSeleccionado === null) {
                    // Crear nuevo
                    resultado = maquinariaModel.agregar_maquinaria(JSON.stringify(datos))
                    if (resultado) {
                        mostrarNotificacion("Equipo creado correctamente", "success")
                    } else {
                        mostrarNotificacion("Error al crear el equipo", "error")
                    }
                } else {
                    // Actualizar
                    resultado = maquinariaModel.actualizar_maquinaria(
                        equipoSeleccionado.id_maquinaria,
                        JSON.stringify(datos)
                    )
                    if (resultado) {
                        mostrarNotificacion("Equipo actualizado correctamente", "success")
                    } else {
                        mostrarNotificacion("Error al actualizar el equipo", "error")
                    }
                }
                
                dialogEquipo.close()
            }
            
            onRejected: dialogEquipo.close()
        }
    }
    
    // Dialog para Mantenimientos
    Dialog {
        id: dialogMantenimiento
        title: tituloDialog
        width: 600
        height: 550
        modal: true
        anchors.centerIn: parent
        
        property string tituloDialog: "Nuevo Mantenimiento"
        
        function limpiarCampos() {
            comboEquipoMant.currentIndex = 0
            comboTipoMant.currentIndex = 0
            txtFechaMant.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
            txtCostoMant.text = ""
            txtDescripcionMant.text = ""
            comboEstadoMant.currentIndex = 0
        }
        
        function cargarDatos(mantenimiento) {
            // Buscar equipo
            var equipos = maquinariaModel.maquinaria
            for (var i = 0; i < equipos.length; i++) {
                if (equipos[i].id_maquinaria === mantenimiento.id_maquinaria) {
                    comboEquipoMant.currentIndex = i
                    break
                }
            }
            
            // Buscar tipo
            for (i = 0; i < tiposMantenimiento.length; i++) {
                if (tiposMantenimiento[i] === mantenimiento.tipo) {
                    comboTipoMant.currentIndex = i - 1
                    break
                }
            }
            
            txtFechaMant.text = mantenimiento.fecha_realizada || Qt.formatDate(new Date(), "yyyy-MM-dd")
            txtCostoMant.text = mantenimiento.costo_total.toString()
            txtDescripcionMant.text = mantenimiento.descripcion
            
            // Buscar estado
            for (i = 0; i < estadosMantenimiento.length; i++) {
                if (estadosMantenimiento[i] === mantenimiento.estado) {
                    comboEstadoMant.currentIndex = i - 1
                    break
                }
            }
        }
        
        contentItem: ScrollView {
            implicitWidth: 580
            implicitHeight: 500
            
            ColumnLayout {
                width: parent.width
                spacing: 15
                
                Text {
                    text: "Equipo *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                ComboBox {
                    id: comboEquipoMant
                    Layout.fillWidth: true
                    model: maquinariaModel.maquinaria
                    textRole: "nombre"
                    valueRole: "id_maquinaria"
                }
                
                Text {
                    text: "Tipo de Mantenimiento *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                ComboBox {
                    id: comboTipoMant
                    Layout.fillWidth: true
                    model: tiposMantenimiento.slice(1)
                }
                
                Text {
                    text: "Fecha *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtFechaMant
                    Layout.fillWidth: true
                    placeholderText: "YYYY-MM-DD"
                    text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                }
                
                Text {
                    text: "Costo Total *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtCostoMant
                    Layout.fillWidth: true
                    placeholderText: "0.00"
                    validator: DoubleValidator { bottom: 0; decimals: 2 }
                }
                
                Text {
                    text: "Estado *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                ComboBox {
                    id: comboEstadoMant
                    Layout.fillWidth: true
                    model: estadosMantenimiento.slice(1)
                }
                
                Text {
                    text: "Descripción *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextArea {
                    id: txtDescripcionMant
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    placeholderText: "Describe el mantenimiento realizado..."
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                enabled: txtCostoMant.text !== "" && txtDescripcionMant.text !== ""
            }
            
            onAccepted: {
                var equipos = maquinariaModel.maquinaria
                var idMaquinaria = equipos[comboEquipoMant.currentIndex].id_maquinaria
                
                var datos = {
                    "id_maquinaria": idMaquinaria,
                    "tipo": tiposMantenimiento[comboTipoMant.currentIndex + 1],
                    "fecha_realizada": txtFechaMant.text,
                    "costo_total": parseFloat(txtCostoMant.text),
                    "descripcion": txtDescripcionMant.text,
                    "estado": estadosMantenimiento[comboEstadoMant.currentIndex + 1],
                    "responsable": maquinariaModel.obtener_usuario_actual()
                }
                
                var resultado
                if (mantenimientoSeleccionado === null) {
                    resultado = maquinariaModel.agregar_mantenimiento(JSON.stringify(datos))
                    if (resultado) {
                        mostrarNotificacion("Mantenimiento registrado correctamente", "success")
                    } else {
                        mostrarNotificacion("Error al registrar el mantenimiento", "error")
                    }
                } else {
                    resultado = maquinariaModel.actualizar_mantenimiento(
                        mantenimientoSeleccionado.id_mantenimiento,
                        JSON.stringify(datos)
                    )
                    if (resultado) {
                        mostrarNotificacion("Mantenimiento actualizado correctamente", "success")
                    } else {
                        mostrarNotificacion("Error al actualizar el mantenimiento", "error")
                    }
                }
                
                dialogMantenimiento.close()
            }
            
            onRejected: dialogMantenimiento.close()
        }
    }
    
    // Dialog para Combustible
    Dialog {
        id: dialogCombustible
        title: tituloDialog
        width: 600
        height: 550
        modal: true
        anchors.centerIn: parent
        
        property string tituloDialog: "Nuevo Registro de Combustible"
        
        function limpiarCampos() {
            comboTipoComb.currentIndex = 0
            txtFechaComb.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
            txtCantidadComb.text = ""
            txtPrecioUnitComb.text = ""
            txtObservacionesComb.text = ""
        }
        
        function cargarDatos(combustible) {
            // Buscar tipo
            for (var i = 0; i < tiposCombustible.length; i++) {
                if (tiposCombustible[i] === combustible.tipo_combustible) {
                    comboTipoComb.currentIndex = i - 1
                    break
                }
            }
            
            txtFechaComb.text = combustible.fecha_compra
            txtCantidadComb.text = combustible.cantidad.toString()
            txtPrecioUnitComb.text = combustible.precio_unitario.toString()
            txtObservacionesComb.text = combustible.observaciones
        }
        
        contentItem: ScrollView {
            implicitWidth: 580
            implicitHeight: 500
            
            ColumnLayout {
                width: parent.width
                spacing: 15
                
                Text {
                    text: "Tipo de Combustible *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                ComboBox {
                    id: comboTipoComb
                    Layout.fillWidth: true
                    model: tiposCombustible.slice(1)
                }
                
                Text {
                    text: "Fecha de Compra *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtFechaComb
                    Layout.fillWidth: true
                    placeholderText: "YYYY-MM-DD"
                    text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                }
                
                Text {
                    text: "Cantidad (Litros) *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtCantidadComb
                    Layout.fillWidth: true
                    placeholderText: "0.0"
                    validator: DoubleValidator { bottom: 0; decimals: 2 }
                }
                
                Text {
                    text: "Precio Unitario (Bs.) *"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextField {
                    id: txtPrecioUnitComb
                    Layout.fillWidth: true
                    placeholderText: "0.00"
                    validator: DoubleValidator { bottom: 0; decimals: 2 }
                }
                
                Text {
                    text: "Total: Bs. " + (parseFloat(txtCantidadComb.text || 0) * parseFloat(txtPrecioUnitComb.text || 0)).toFixed(2)
                    font.bold: true
                    font.pixelSize: 14
                    color: "#0288D1"
                }
                
                Text {
                    text: "Observaciones"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                TextArea {
                    id: txtObservacionesComb
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    placeholderText: "Observaciones adicionales..."
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                enabled: txtCantidadComb.text !== "" && txtPrecioUnitComb.text !== ""
            }
            
            onAccepted: {
                var cantidad = parseFloat(txtCantidadComb.text)
                var precioUnit = parseFloat(txtPrecioUnitComb.text)
                
                var datos = {
                    "tipo_combustible": tiposCombustible[comboTipoComb.currentIndex + 1],
                    "fecha_compra": txtFechaComb.text,
                    "cantidad": cantidad,
                    "unidad_medida": "Litros",
                    "precio_unitario": precioUnit,
                    "precio_total": cantidad * precioUnit,
                    "observaciones": txtObservacionesComb.text,
                    "responsable": maquinariaModel.obtener_usuario_actual()
                }
                
                var resultado
                if (combustibleSeleccionado === null) {
                    resultado = maquinariaModel.registrar_compra_combustible(JSON.stringify(datos))
                    if (resultado) {
                        mostrarNotificacion("Compra registrada correctamente", "success")
                    } else {
                        mostrarNotificacion("Error al registrar la compra", "error")
                    }
                } else {
                    resultado = maquinariaModel.actualizar_compra_combustible(
                        combustibleSeleccionado.id_compra,
                        JSON.stringify(datos)
                    )
                    if (resultado) {
                        mostrarNotificacion("Compra actualizada correctamente", "success")
                    } else {
                        mostrarNotificacion("Error al actualizar la compra", "error")
                    }
                }
                
                dialogCombustible.close()
            }
            
            onRejected: dialogCombustible.close()
        }
    }
    
    // Diálogo de confirmación para Equipos
    Dialog {
        id: confirmDialogEquipo
        title: titulo
        width: 400
        height: 200
        modal: true
        anchors.centerIn: parent
        
        property string titulo: "Confirmar"
        property string mensaje: ""
        
        contentItem: Rectangle {
            color: "white"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Image {
                    source: "recursos/image/icons/warning.svg"
                    Layout.alignment: Qt.AlignHCenter
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
                
                Text {
                    text: confirmDialogEquipo.mensaje
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Eliminar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: parent.pressed ? "#C62828" : (parent.hovered ? "#E53935" : "#F44336")
                    radius: 4
                }
            }
            
            onAccepted: {
                confirmarEliminarEquipo()
                confirmDialogEquipo.close()
            }
            
            onRejected: confirmDialogEquipo.close()
        }
    }
    
    // Diálogo de confirmación para Mantenimiento
    Dialog {
        id: confirmDialogMantenimiento
        title: titulo
        width: 400
        height: 200
        modal: true
        anchors.centerIn: parent
        
        property string titulo: "Confirmar"
        property string mensaje: ""
        
        contentItem: Rectangle {
            color: "white"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Image {
                    source: "recursos/image/icons/warning.svg"
                    Layout.alignment: Qt.AlignHCenter
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
                
                Text {
                    text: confirmDialogMantenimiento.mensaje
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Eliminar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: parent.pressed ? "#C62828" : (parent.hovered ? "#E53935" : "#F44336")
                    radius: 4
                }
            }
            
            onAccepted: {
                confirmarEliminarMantenimiento()
                confirmDialogMantenimiento.close()
            }
            
            onRejected: confirmDialogMantenimiento.close()
        }
    }
    
    // Diálogo de confirmación para Combustible
    Dialog {
        id: confirmDialogCombustible
        title: titulo
        width: 400
        height: 200
        modal: true
        anchors.centerIn: parent
        
        property string titulo: "Confirmar"
        property string mensaje: ""
        
        contentItem: Rectangle {
            color: "white"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Image {
                    source: "recursos/image/icons/warning.svg"
                    Layout.alignment: Qt.AlignHCenter
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                }
                
                Text {
                    text: confirmDialogCombustible.mensaje
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Eliminar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: parent.pressed ? "#C62828" : (parent.hovered ? "#E53935" : "#F44336")
                    radius: 4
                }
            }
            
            onAccepted: {
                confirmarEliminarCombustible()
                confirmDialogCombustible.close()
            }
            
            onRejected: confirmDialogCombustible.close()
        }
    }
    
    // ==================== NOTIFICACIÓN ====================
    NotificationsPopup {
        id: notificationPopup
    }
}
