import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15 


Rectangle {
    id: cultivosRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // Propiedades para edición de tipos de cultivo
    property bool mostrarFilaEdicionTipo: false
    property var nuevoTipoCultivo: {
        "nombre": "", 
        "nombre_cientifico": "", 
        "tiempo_cosecha_min": 0,
        "tiempo_cosecha_max": 0,
        "descripcion": "",
        "activo": true
    }
    
    // Propiedades para edición de variedades
    property var nuevaVariedad: {
        "id_tipo_cultivo": 1,
        "nombre": "",
        "tiempo_produccion": 0,
        "rendimiento_esperado": 0.0,
        "resistencia_zona": "Media",
        "activo": true
    }

    property var nuevoCiclo: {
        "id_parcela": 1,
        "id_variedad": 1,
        "fecha_siembra": "",
        "fecha_cosecha_estimada": "",
        "fecha_cosecha_real": "",
        "area_sembrada": 0,
        "densidad_siembra": 0,
        "estado": "Planificado",
        "activo": true,
        "fecha_floracion": "",
        "fecha_poda": "",
        "fecha_limpieza": "",
        "frecuencia_limpieza": 1
    }
    
    // Propiedades para el calendario
    property var fechaActual: new Date()
    property var eventosPorFecha: ({})

    // Al iniciar, cargar datos desde el modelo Python
    Component.onCompleted: {
        console.log("Cargando datos desde el modelo Python...")
        cargarDatosIniciales()
    }

    function cargarDatosIniciales() {
        console.log("Cargando datos iniciales...")
        
        // Primero cargar desde la base de datos
        cultivos.cargar_tipos_cultivo()
        cultivos.cargar_variedades()
        cultivos.cargar_ciclos_produccion()
        
        // Luego actualizar los modelos locales inmediatamente
        cargarTiposCultivo()
        cargarVariedades()
        cargarCiclosProduccion()
        actualizarCalendario()
    }

    // Añade este Timer como propiedad en el componente principal
    Timer {
        id: cargarDatosTimer
        interval: 500 // 500 ms de retraso
        repeat: false
        onTriggered: {
            cargarTiposCultivo()
            cargarVariedades()
            cargarCiclosProduccion()
            actualizarCalendario()
        }
    }

    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "GESTIÓN DE TIPOS Y VARIEDADES DE CÍTRICOS"
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
            text: "Tipos de Cultivo"
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
            text: "Variedades"
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
            text: "Ciclos de Producción"
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
            text: "Calendario de Cultivos"
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

        // Página de Tipos de Cultivo
        Item {
            // Dividir en dos columnas: lista y detalles
            Rectangle {
                id: tiposCultivoList
                width: parent.width * 0.3
                height: parent.height
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    // Cabecera de la lista
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "Tipos de Cítricos"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Nuevo"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para el nuevo tipo de cultivo
                                nuevoTipoCultivo = {
                                    "nombre": "",
                                    "nombre_cientifico": "",
                                    "tiempo_cosecha_min": 0,
                                    "tiempo_cosecha_max": 0,
                                    "descripcion": "",
                                    "activo": true
                                }
                                
                                // Mostrar panel de detalles limpio para agregar
                                mostrarFilaEdicionTipo = true
                            }
                        }
                    }
                    
                    // Campo de búsqueda
                    TextField {
                        id: txtBuscarTipoCultivo
                        Layout.fillWidth: true
                        placeholderText: "Buscar tipo de cultivo..."
                        implicitHeight: 36
                        background: Rectangle {
                            color: "#b2c4c9"
                            radius: height / 2
                        }
                        onTextChanged: filtrarTiposCultivo()
                    }

                    // Lista de tipos de cultivo
                    ListView {
                        id: tiposCultivoListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: ListModel { id: tiposCultivoModel }
                        spacing: 5
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 60
                            color: ListView.isCurrentItem ? "#E3F2FD" : "transparent"
                            radius: 4
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 2
                                
                                Text {
                                    text: nombre
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                                
                                Text {
                                    text: nombre_cientifico || ""
                                    font.pixelSize: 12
                                    font.italic: true
                                    color: "#757575"
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    tiposCultivoListView.currentIndex = index
                                    mostrarFilaEdicionTipo = false
                                    cargarDetallesTipoCultivo(model)
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay tipos de cultivo registrados.\nHaga clic en 'Nuevo' para agregar uno."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: tiposCultivoModel.count === 0
                        }
                    }
                }
            }
            
            // Panel de detalles
            Rectangle {
                anchors.left: tiposCultivoList.right
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "white"
                radius: 5
                border.color: "#EEEEEE"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    // Cabecera de detalles
                    Text {
                        text: mostrarFilaEdicionTipo ? "Nuevo Tipo de Cultivo" : "Detalles del Tipo de Cultivo"
                        font.pixelSize: 20
                        font.bold: true
                    }
                    
                    // Formulario
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 15
                        columnSpacing: 20
                        
                        // Nombre
                        Text {
                            text: "Nombre:"
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: txtNombreTipo
                            Layout.fillWidth: true
                            placeholderText: "Nombre del tipo de cultivo"
                            onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.nombre = text
                        }
                        
                        // Nombre Científico
                        Text {
                            text: "Nombre Científico:"
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: txtNombreCientifico
                            Layout.fillWidth: true
                            placeholderText: "Nombre científico"
                            font.italic: true
                            onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.nombre_cientifico = text
                        }
                        
                        // Tiempo de Cosecha Mínimo
                        Text {
                            text: "Tiempo mín. hasta cosecha (días):"
                            font.pixelSize: 14
                        }
                        
                        SpinBox {
                            id: spinTiempoMin
                            Layout.fillWidth: true
                            from: 0
                            to: 1000
                            onValueChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.tiempo_cosecha_min = value
                        }
                        
                        // Tiempo de Cosecha Máximo
                        Text {
                            text: "Tiempo máx. hasta cosecha (días):"
                            font.pixelSize: 14
                        }
                        
                        SpinBox {
                            id: spinTiempoMax
                            Layout.fillWidth: true
                            from: 0
                            to: 1000
                            onValueChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.tiempo_cosecha_max = value
                        }
                        
                        // Estado
                        Text {
                            text: "Estado:"
                            font.pixelSize: 14
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            CheckBox {
                                id: chkActivo
                                text: "Activo"
                                checked: true
                                onCheckedChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.activo = checked
                            }
                        }
                        
                        // Descripción
                        Text {
                            text: "Descripción:"
                            font.pixelSize: 14
                        }
                        
                        TextArea {
                            id: txtDescripcion
                            Layout.fillWidth: true
                            Layout.rowSpan: 3
                            Layout.minimumHeight: 100
                            placeholderText: "Descripción del tipo de cultivo"
                            wrapMode: TextArea.Wrap
                            onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.descripcion = text
                        }
                    }
                    
                    // Estadísticas de producción
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: "#F5F5F5"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: mostrarFilaEdicionTipo || tiposCultivoModel.count === 0 
                                ? "Las estadísticas estarán disponibles después de registrar ciclos de producción."
                                : "Las estadísticas de producción se mostrarán aquí."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    
                    // Botones de acción
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        spacing: 10
                        
                        Button {
                            text: "Cancelar"
                            implicitHeight: 36
                            flat: true
                            onClicked: mostrarFilaEdicionTipo = false
                        }
                        
                        Button {
                            text: mostrarFilaEdicionTipo ? "Guardar" : "Guardar Cambios"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: {
                                if (mostrarFilaEdicionTipo) {
                                    guardarNuevoTipoCultivo()
                                } else {
                                    actualizarTipoCultivo()
                                }
                            }
                        }
                    }
                }
            }
        }

        // Página de Variedades
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
                        spacing: 20
                        
                        Button {
                            text: "Nueva Variedad"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para la nueva variedad
                                nuevaVariedad = {
                                    "id_tipo_cultivo": tiposCultivoModel.count > 0 ? tiposCultivoModel.get(0).id_tipo_cultivo : 1,
                                    "nombre": "",
                                    "tiempo_produccion": 0,
                                    "rendimiento_esperado": 0.0,
                                    "resistencia_zona": "Media",
                                    "activo": true
                                }
                                
                                // Mostrar diálogo de nueva variedad
                                dialogNuevaVariedad.open()
                            }
                        }
                        
                        TextField {
                            id: txtBuscarVariedad
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar variedades..."
                            implicitHeight: 25
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
                            onTextChanged: filtrarVariedades()
                        }
                        
                        ComboBox {
                            id: cmbFiltroTipos
                            Layout.preferredWidth: 200
                            model: ListModel { id: tiposFiltroModel }
                            implicitHeight: 36
                            Component.onCompleted: {
                                tiposFiltroModel.append({text: "Todos los tipos", value: 0})
                                actualizarTiposFiltro()
                            }
                            onCurrentIndexChanged: filtrarVariedadesPorTipo()
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Exportar"
                            icon.source: "Image/Image_UI_interfaz/Inconos/exportacion-de-archivos.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: exportarVariedades()
                        }
                    }
                }
                
                // Tabla de variedades
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: variedadesListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel { id: variedadesModel }
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Tipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Nombre de Variedad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Tiempo (días)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Rendimiento"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Resistencia"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Acciones"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                        
                        // Delegado para cada fila
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
                                        text: id_variedad
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Tipo
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombre_tipo_cultivo
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Nombre
                                Rectangle {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombre
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Tiempo Producción
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: tiempo_produccion || "No definido"
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Rendimiento
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: rendimiento_esperado ? rendimiento_esperado + " ton/ha" : "No definido"
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Resistencia
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 80
                                        height: 24
                                        radius: 12
                                        color: getResistenciaColor(resistencia_zona)
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: resistencia_zona
                                            font.pixelSize: 12
                                            color: "white"
                                        }
                                    }
                                }
                                
                                // Acciones
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 10
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: editarVariedad(model)
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: {
                                                confirmDeleteVariedadDialog.variedadId = id_variedad
                                                confirmDeleteVariedadDialog.nombreVariedad = nombre
                                                confirmDeleteVariedadDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay variedades registradas.\nHaga clic en 'Nueva Variedad' para agregar una."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: variedadesModel.count === 0
                        }
                    }
                }
            }
        }

        // Página de Ciclos de Producción
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
                        spacing: 20
                        
                        Button {
                            text: "Nuevo Ciclo"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                dialogCicloProduccion.modo = "crear";
                                dialogCicloProduccion.open();
                            }
                        }
                        
                        TextField {
                            id: txtBuscarCiclo
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar ciclos..."
                            implicitHeight: 25
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
                            onTextChanged: filtrarCiclos()
                        }
                        
                        ComboBox {
                            id: cmbFiltroEstados
                            Layout.preferredWidth: 200
                            model: ListModel { id: estadosFiltroModel }
                            implicitHeight: 36
                            Component.onCompleted: {
                                estadosFiltroModel.append({text: "Todos los estados", value: ""})
                                actualizarEstadosFiltro()
                            }
                            onCurrentIndexChanged: filtrarCiclosPorEstado()
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Exportar"
                            icon.source: "Image/Image_UI_interfaz/Inconos/exportacion-de-archivos.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: exportarCiclos()
                        }
                    }
                }
                
                // Tabla de ciclos de producción
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: ciclosListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel { id: ciclosModel }
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
//
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    text: "Parcela"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    text: "Variedad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Siembra"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Cosecha Est."
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Área (ha)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Densidad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.14
                                    height: parent.height
                                    text: "Estado"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Acciones"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        // Delegado para cada fila
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"
                            
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
                                        text: id_ciclo
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Parcela
                                Rectangle {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombre_parcela
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Variedad
                                Rectangle {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombre_variedad
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Fecha Siembra
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: fecha_siembra || "No definida"
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Fecha Cosecha Estimada
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: fecha_cosecha_estimada || "No definida"
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Área sembrada
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: area_sembrada
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Densidad de siembra
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: densidad_siembra || "No definida"
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Estado
                                Rectangle {
                                    width: parent.width * 0.14
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 100
                                        height: 24
                                        radius: 12
                                        color: getEstadoColor(estado)
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: estado
                                            font.pixelSize: 11
                                            color: "white"
                                        }
                                    }
                                }
                                
                                // Acciones
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 10
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: {
                                                // Abrir el diálogo de edición con los datos del ciclo seleccionado
                                                dialogCicloProduccion.modo = "editar";
                                                dialogCicloProduccion.cargarCiclo(id_ciclo);
                                                dialogCicloProduccion.open();
                                            }
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: {
                                                // Mostrar diálogo de confirmación
                                                confirmDeleteCicloDialog.cicloId = id_ciclo;
                                                confirmDeleteCicloDialog.nombreParcela = nombre_parcela;
                                                confirmDeleteCicloDialog.nombreVariedad = nombre_variedad;
                                                confirmDeleteCicloDialog.open();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay ciclos de producción registrados.\nHaga clic en 'Nuevo Ciclo' para agregar uno."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: ciclosModel.count === 0
                        }
                    }
                }
            }
        }
        // Página de Calendario de Cultivos
        Item {
            Rectangle {
                anchors.fill: parent
                color: "white"
                radius: 5
                border.color: "#EEEEEE"
                
                // Vista de Calendario mejorada
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    // Cabecera con controles - Muestra mes y año actual
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        
                        Text {
                            id: txtFechaActual
                            text: obtenerNombreMes(fechaActual.getMonth()) + " " + fechaActual.getFullYear()
                            font.pixelSize: 22
                            font.bold: true
                        }
                        
                        Button {
                            text: "Anterior"
                            implicitHeight: 36
                            icon.source: "Image/Image_UI_interfaz/Inconos/anterior.svg"
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
                                // Restar un mes
                                var nuevaFecha = new Date(fechaActual);
                                nuevaFecha.setMonth(nuevaFecha.getMonth() - 1);
                                fechaActual = nuevaFecha;
                                actualizarCalendario();
                            }
                        }
                        
                        Button {
                            text: "Siguiente"
                            implicitHeight: 36
                            icon.source: "Image/Image_UI_interfaz/Inconos/siguiente.svg"
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
                                // Sumar un mes
                                var nuevaFecha = new Date(fechaActual);
                                nuevaFecha.setMonth(nuevaFecha.getMonth() + 1);
                                fechaActual = nuevaFecha;
                                actualizarCalendario();
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        
                        ComboBox {
                            id: cmbFiltroCultivosCalendario
                            model: ListModel { id: cultivosFiltroModel }
                            implicitWidth: 200
                            implicitHeight: 36
                            Component.onCompleted: {
                                cultivosFiltroModel.append({text: "Todos los cultivos", value: 0})
                                actualizarCultivosFiltro()
                            }
                            onCurrentIndexChanged: actualizarCalendario()
                        }
                        
                        ComboBox {
                            model: ["Vista mensual", "Vista trimestral", "Vista anual"]
                            implicitWidth: 150
                            implicitHeight: 36
                            currentIndex: 0
                            onCurrentIndexChanged: actualizarCalendario()
                        }
                    }
                    
                    // Diagrama del calendario - Visualización simplificada
                    Row {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        spacing: 1
                        
                        // Días de la semana
                        Repeater {
                            model: ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
                            
                            Rectangle {
                                width: (parent.width - 6) / 7
                                height: parent.height
                                color: "#F5F5F5"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                        }
                    }
                    
                    // Cuadrícula del calendario
                    GridLayout {
                        id: calendarGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        rowSpacing: 1
                        columnSpacing: 1
                        
                        // Celdas del calendario (generadas dinámicamente)
                        Repeater {
                            id: calendarRepeater
                            model: 42 // 6 semanas x 7 días
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                property bool esDiaActual: false
                                property bool esDiaMesActual: false
                                property int diaNumero: 0
                                
                                color: esDiaActual ? "#E3F2FD" : (esDiaMesActual ? "white" : "#F5F5F5")
                                border.color: "#EEEEEE"
                                
                                // Contenedor para el contenido
                                Column {
                                    id: contenidoDia
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 3
                                    visible: diaNumero > 0
                                    
                                    // Número del día
                                    Text {
                                        id: numeroDia
                                        text: parent.parent.diaNumero
                                        font.pixelSize: 16
                                        font.bold: parent.parent.esDiaActual
                                        width: parent.width
                                    }
                                    
                                    // Eventos para este día
                                    Repeater {
                                        model: getEventsForDay(parent.parent.diaNumero, fechaActual.getMonth(), fechaActual.getFullYear())
                                        
                                        Rectangle {
                                            width: parent.width
                                            height: 20
                                            radius: 3
                                            color: modelData.color                                         
                                            Text {
                                                anchors.fill: parent
                                                anchors.leftMargin: 5
                                                text: modelData.text
                                                font.pixelSize: 10
                                                color: "white"
                                                verticalAlignment: Text.AlignVCenter
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                    
                                    // Espacio flexible al final
                                    Item { 
                                        width: parent.width
                                        height: 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // DIÁLOGO DE NUEVA VARIEDAD
    Dialog {
        id: dialogNuevaVariedad
        title: "Nueva Variedad"
        modal: true
        width: 500
        height: 600
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Título
                Text {
                    text: "Agregar Nueva Variedad"
                    font.pixelSize: 18
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // Formulario
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 15
                    
                    // Tipo de cultivo
                    Text {
                        text: "Tipo de cultivo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbTipoCultivo
                        Layout.fillWidth: true
                        model: ListModel { id: tiposVariedadModel }
                        textRole: "text"
                        valueRole: "value"
                        Component.onCompleted: actualizarTiposCombobox()
                        onCurrentIndexChanged: {
                            if (currentIndex >= 0) {
                                nuevaVariedad.id_tipo_cultivo = model.get(currentIndex).value
                            }
                        }
                    }
                    
                    // Nombre de variedad
                    Text {
                        text: "Nombre de variedad:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtNombreVariedad
                        placeholderText: "Ingrese nombre de variedad"
                        Layout.fillWidth: true
                        onTextChanged: nuevaVariedad.nombre = text
                    }
                    
                    // Tiempo de producción
                    Text {
                        text: "Tiempo de producción (días):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    SpinBox {
                        id: spinTiempoProduccion
                        Layout.fillWidth: true
                        from: 0
                        to: 500
                        value: 0
                        onValueChanged: nuevaVariedad.tiempo_produccion = value
                    }
                    
                    // Rendimiento
                    Text {
                        text: "Rendimiento (ton/ha):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtRendimiento
                        placeholderText: "Ej: 5.5"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: {
                            if (text.trim() !== "")
                                nuevaVariedad.rendimiento_esperado = parseFloat(text)
                        }
                    }
                    
                    // Resistencia
                    Text {
                        text: "Resistencia:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbResistencia
                        Layout.fillWidth: true
                        model: ["Alta", "Media", "Baja"]
                        currentIndex: 1 // Media por defecto
                        onCurrentTextChanged: {
                            nuevaVariedad.resistencia_zona = currentText
                        }
                    }
                    
                    // Fecha de registro
                    Text {
                        text: "Fecha de registro:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaRegistro
                        placeholderText: "DD/MM/AAAA"
                        Layout.fillWidth: true
                        readOnly: true
                        text: getFormattedDate() // Llamamos a la función para obtener la fecha formateada
                    }
                    
                    // Descripción
                    Text {
                        text: "Descripción:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtDescripcionVariedad
                        placeholderText: "Descripción de la variedad (opcional)"
                        Layout.fillWidth: true
                        Layout.rowSpan: 3
                        Layout.minimumHeight: 80
                        wrapMode: TextArea.Wrap
                    }
                }
                
                // Espacio adicional
                Item {
                    width: parent.width
                    height: 10
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionVariedad
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
                onClicked: dialogNuevaVariedad.close()
            }
            
            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: "#4CAF50"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    // Validación de campos obligatorios
                    if (txtNombreVariedad.text === "" || cmbTipoCultivo.currentIndex < 0) {
                        mensajeValidacionVariedad.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    // Validar que haya tipos de cultivo disponibles
                    if (tiposVariedadModel.count === 0) {
                        mensajeValidacionVariedad.text = "Debe crear al menos un tipo de cultivo primero";
                        return;
                    }
                    
                    guardarNuevaVariedad();
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            txtNombreVariedad.text = ""
            txtRendimiento.text = ""
            spinTiempoProduccion.value = 0
            cmbResistencia.currentIndex = 1
            txtDescripcionVariedad.text = ""
            mensajeValidacionVariedad.text = ""
        }
    }
    
    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR VARIEDAD
    Dialog {
        id: confirmDeleteVariedadDialog
        title: "Confirmar eliminación"
        modal: true
        width: 400
        height: 180
        
        property int variedadId: -1
        property string nombreVariedad: ""
        
        contentItem: Item {
            implicitWidth: 400
            implicitHeight: 100
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    width: parent.width
                    text: "¿Está seguro que desea eliminar la variedad '" + confirmDeleteVariedadDialog.nombreVariedad + "'?"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                }
                
                Text {
                    width: parent.width
                    text: "Esta acción no se puede deshacer."
                    font.pixelSize: 14
                    font.italic: true
                    color: "#F44336"
                    wrapMode: Text.WordWrap
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
                    color: "#F44336"
                    radius: 5
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
        
        onAccepted: {
            eliminarVariedad(variedadId)
        }
    }
    // DIÁLOGO DE CICLO DE PRODUCCIÓN
    // DIÁLOGO DE CICLO DE PRODUCCIÓN
    Dialog {
        id: dialogCicloProduccion
        title: modo === "crear" ? "Nuevo Ciclo de Producción" : "Editar Ciclo de Producción"
        modal: true
        width: 650
        height: 650
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        property string modo: "crear" // "crear" o "editar"
        property int cicloId: -1
        
        // Función para cargar datos de un ciclo existente
        function cargarCiclo(id) {
            cicloId = id;
            
            // Buscar el ciclo en el modelo
            for (let i = 0; i < ciclosModel.count; i++) {
                if (ciclosModel.get(i).id_ciclo === id) {
                    let ciclo = ciclosModel.get(i);
                    
                    // Cargar todos los campos
                    cmbParcelas.currentIndex = getParcelaIndex(ciclo.id_parcela);
                    cmbVariedades.currentIndex = getVariedadIndex(ciclo.id_variedad);
                    txtAreaSembrada.text = ciclo.area_sembrada.toString();
                    spinDensidad.value = ciclo.densidad_siembra || 0;
                    cmbEstado.currentIndex = getEstadoIndex(ciclo.estado);
                    ciclo_chkActivo.checked = ciclo.activo;
                    
                    // Fechas
                    txtFechaSiembra.text = ciclo.fecha_siembra || "";
                    txtFechaCosechaEst.text = ciclo.fecha_cosecha_estimada || "";
                    txtFechaCosechaReal.text = ciclo.fecha_cosecha_real || "";
                    txtFechaFloracion.text = ciclo.fecha_floracion || "";
                    txtFechaPoda.text = ciclo.fecha_poda || "";
                    txtFechaLimpieza.text = ciclo.fecha_limpieza || "";
                    spinFrecuenciaLimpieza.value = ciclo.frecuencia_limpieza || 1;
                    
                    break;
                }
            }
        }
        
        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                
                ColumnLayout {
                    width: parent.width
                    spacing: 15
                    
                    // Título
                    Text {
                        text: dialogCicloProduccion.modo === "crear" ? "Crear Nuevo Ciclo de Producción" : "Editar Ciclo de Producción"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    // Formulario principal
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        columnSpacing: 10
                        rowSpacing: 15
                        
                        // Parcela
                        Text {
                            text: "Parcela:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        ComboBox {
                            id: cmbParcelas
                            Layout.fillWidth: true
                            Layout.columnSpan: 3
                            model: ListModel { id: parcelasModel }
                            textRole: "text"
                            valueRole: "value"
                            Component.onCompleted: {
                                actualizarParcelasCombobox()
                            }
                            onCurrentIndexChanged: {
                                if (dialogCicloProduccion.modo === "crear" && currentIndex >= 0) {
                                    nuevoCiclo.id_parcela = model.get(currentIndex).value
                                }
                            }
                        }
                        
                        // Variedad
                        Text {
                            text: "Variedad:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        ComboBox {
                            id: cmbVariedades
                            Layout.fillWidth: true
                            Layout.columnSpan: 3
                            model: ListModel { id: variedadesCicloModel }
                            textRole: "text"
                            valueRole: "value"
                            Component.onCompleted: {
                                actualizarVariedadesCombobox()
                            }
                            onCurrentIndexChanged: {
                                if (dialogCicloProduccion.modo === "crear" && currentIndex >= 0) {
                                    nuevoCiclo.id_variedad = model.get(currentIndex).value
                                }
                            }
                        }
                        
                        // Estado
                        Text {
                            text: "Estado:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        ComboBox {
                            id: cmbEstado
                            Layout.fillWidth: true
                            model: ["Planificado", "En Preparación", "Sembrado", "En Desarrollo", "En Cosecha", "Finalizado", "Cancelado"]
                            currentIndex: 0
                            onCurrentTextChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.estado = currentText;
                                }
                            }
                        }
                        
                        // Activo
                        Text {
                            text: "Activo:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        CheckBox {
                            id: ciclo_chkActivo
                            checked: true
                            onCheckedChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.activo = checked;
                                }
                            }
                        }
                        
                        // Área sembrada
                        Text {
                            text: "Área sembrada (ha):"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtAreaSembrada
                            Layout.fillWidth: true
                            validator: DoubleValidator { bottom: 0.01 }
                            placeholderText: "Ej: 2.5"
                            onTextChanged: {
                                if (dialogCicloProduccion.modo === "crear" && text.trim() !== "") {
                                    nuevoCiclo.area_sembrada = parseFloat(text);
                                }
                            }
                        }
                        
                        // Densidad de siembra
                        Text {
                            text: "Densidad (plantas/ha):"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        SpinBox {
                            id: spinDensidad
                            Layout.fillWidth: true
                            from: 0
                            to: 10000
                            stepSize: 10
                            onValueChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.densidad_siembra = value;
                                }
                            }
                        }
                        
                        // Separador de sección
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: 4
                            height: 1
                            color: "#EEEEEE"
                        }
                        
                        // Título de fechas
                        Text {
                            text: "Fechas importantes"
                            font.bold: true
                            font.pixelSize: 14
                            Layout.fillWidth: true
                            Layout.columnSpan: 4
                        }
                        
                        // Fecha de siembra
                        Text {
                            text: "Fecha de siembra:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtFechaSiembra
                            Layout.fillWidth: true
                            placeholderText: "DD/MM/AAAA"
                            inputMask: "99/99/9999"
                            onTextChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.fecha_siembra = text;
                                }
                            }
                        }
                        
                        // Fecha de cosecha estimada
                        Text {
                            text: "Cosecha estimada:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtFechaCosechaEst
                            Layout.fillWidth: true
                            placeholderText: "DD/MM/AAAA"
                            inputMask: "99/99/9999"
                            onTextChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.fecha_cosecha_estimada = text;
                                }
                            }
                        }
                        
                        // Fecha de cosecha real
                        Text {
                            text: "Cosecha real:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtFechaCosechaReal
                            Layout.fillWidth: true
                            placeholderText: "DD/MM/AAAA"
                            inputMask: "99/99/9999"
                            onTextChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.fecha_cosecha_real = text;
                                }
                            }
                        }
                        
                        // Fecha de floración
                        Text {
                            text: "Fecha de floración:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtFechaFloracion
                            Layout.fillWidth: true
                            placeholderText: "DD/MM/AAAA"
                            inputMask: "99/99/9999"
                            onTextChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.fecha_floracion = text;
                                }
                            }
                        }
                        
                        // Fecha de poda
                        Text {
                            text: "Fecha de poda:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtFechaPoda
                            Layout.fillWidth: true
                            placeholderText: "DD/MM/AAAA"
                            inputMask: "99/99/9999"
                            onTextChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.fecha_poda = text;
                                }
                            }
                        }
                        
                        // Fecha última limpieza
                        Text {
                            text: "Fecha limpieza:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtFechaLimpieza
                            Layout.fillWidth: true
                            placeholderText: "DD/MM/AAAA"
                            inputMask: "99/99/9999"
                            onTextChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.fecha_limpieza = text;
                                }
                            }
                        }
                        
                        // Frecuencia de limpieza
                        Text {
                            text: "Frecuencia limpieza (meses):"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        SpinBox {
                            id: spinFrecuenciaLimpieza
                            Layout.fillWidth: true
                            from: 1
                            to: 12
                            value: 1
                            onValueChanged: {
                                if (dialogCicloProduccion.modo === "crear") {
                                    nuevoCiclo.frecuencia_limpieza = value;
                                }
                            }
                        }
                    }
                    
                    // Espacio adicional
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 10
                    }
                    
                    // Mensaje de validación
                    Text {
                        id: mensajeValidacionCiclo
                        Layout.fillWidth: true
                        text: ""
                        color: "red"
                        visible: text !== ""
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: dialogCicloProduccion.close()
            }
            
            Button {
                text: dialogCicloProduccion.modo === "crear" ? "Guardar" : "Actualizar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: "#4CAF50"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    // Validación de campos obligatorios
                    if (txtAreaSembrada.text === "" || parseFloat(txtAreaSembrada.text) <= 0) {
                        mensajeValidacionCiclo.text = "Por favor, ingrese un área sembrada válida";
                        return;
                    }
                    
                    if (dialogCicloProduccion.modo === "crear") {
                        guardarNuevoCiclo();
                    } else {
                        actualizarCiclo();
                    }
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            mensajeValidacionCiclo.text = "";
        }
        
        onOpened: {
            if (modo === "crear") {
                // Resetear valores para un nuevo ciclo
                cmbParcelas.currentIndex = 0;
                cmbVariedades.currentIndex = 0;
                txtAreaSembrada.text = "";
                spinDensidad.value = 0;
                cmbEstado.currentIndex = 0;
                ciclo_chkActivo.checked = true;
                
                // Fechas
                txtFechaSiembra.text = "";
                txtFechaCosechaEst.text = "";
                txtFechaCosechaReal.text = "";
                txtFechaFloracion.text = "";
                txtFechaPoda.text = "";
                txtFechaLimpieza.text = "";
                spinFrecuenciaLimpieza.value = 1;
            }
        }
    }

    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR CICLO
    Dialog {
        id: confirmDeleteCicloDialog
        title: "Confirmar eliminación"
        modal: true
        width: 400
        height: 180
        
        property int cicloId: -1
        property string nombreParcela: ""
        property string nombreVariedad: ""
        
        contentItem: Item {
            implicitWidth: 400
            implicitHeight: 100
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    width: parent.width
                    text: "¿Está seguro que desea eliminar el ciclo de producción '" + 
                        confirmDeleteCicloDialog.nombreVariedad + "' en parcela '" + 
                        confirmDeleteCicloDialog.nombreParcela + "'?"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                }
                
                Text {
                    width: parent.width
                    text: "Esta acción no se puede deshacer."
                    font.pixelSize: 14
                    font.italic: true
                    color: "#F44336"
                    wrapMode: Text.WordWrap
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
                    color: "#F44336"
                    radius: 5
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
        
        onAccepted: {
            eliminarCiclo(cicloId);
        }
    }

    // Funciones auxiliares para la gestión de datos

    // Función para obtener el índice en el combobox de parcelas a partir del ID
    function getParcelaIndex(id_parcela) {
        for (let i = 0; i < parcelasModel.count; i++) {
            if (parcelasModel.get(i).value === id_parcela) {
                return i;
            }
        }
        return 0; // Por defecto, la primera
    }

    // Función para obtener el índice en el combobox de variedades a partir del ID
    function getVariedadIndex(id_variedad) {
        for (let i = 0; i < variedadesCicloModel.count; i++) {
            if (variedadesCicloModel.get(i).value === id_variedad) {
                return i;
            }
        }
        return 0; // Por defecto, la primera
    }

    // Función para obtener el índice en el combobox de estados a partir del nombre
    function getEstadoIndex(estado) {
        const estados = ["Planificado", "En Preparación", "Sembrado", "En Desarrollo", "En Cosecha", "Finalizado", "Cancelado"];
        const index = estados.indexOf(estado);
        return index >= 0 ? index : 0;
    }

    // Función para obtener el color correspondiente a un estado
    function getEstadoColor(estado) {
        switch (estado) {
            case "Planificado": return "#2196F3"; // Azul
            case "En Preparación": return "#FF9800"; // Naranja
            case "Sembrado": return "#4CAF50"; // Verde
            case "En Desarrollo": return "#8BC34A"; // Verde claro
            case "En Cosecha": return "#FFC107"; // Amarillo
            case "Finalizado": return "#9E9E9E"; // Gris
            case "Cancelado": return "#F44336"; // Rojo
            default: return "#2196F3"; // Azul (por defecto)
        }
    }

    // Función para obtener el color correspondiente a una resistencia
    function getResistenciaColor(resistencia) {
        switch (resistencia) {
            case "Alta": return "#4CAF50"; // Verde
            case "Media": return "#FF9800"; // Naranja
            case "Baja": return "#F44336"; // Rojo
            default: return "#FF9800"; // Naranja (por defecto)
        }
    }

    // Funciones para cargar datos desde el modelo de Python

    // Actualizar el modelo de tipos de cultivo
    function cargarTiposCultivo() {
        console.log("Intentando cargar tipos de cultivo...")
        tiposCultivoModel.clear()
        
        // Obtener datos directamente del modelo Python
        var tipos = cultivos.tipos_cultivo
        console.log("Tipos recibidos: " + tipos.length)
        
        for (let i = 0; i < tipos.length; i++) {
            let tipo = tipos[i]
            tiposCultivoModel.append({
                id_tipo_cultivo: tipo.id_tipo_cultivo,
                nombre: tipo.nombre,
                nombre_cientifico: tipo.nombre_cientifico || "",
                tiempo_cosecha_min: tipo.tiempo_cosecha_min || 0,
                tiempo_cosecha_max: tipo.tiempo_cosecha_max || 0,
                descripcion: tipo.descripcion || "",
                activo: tipo.activo
            })
            console.log("Agregado tipo: " + tipo.nombre)
        }
    }

    // Actualizar el modelo de variedades
    function cargarVariedades() {
        variedadesModel.clear();
        const variedades = cultivos.variedades;
        for (let i = 0; i < variedades.length; i++) {
            variedadesModel.append({
                id_variedad: variedades[i].id_variedad,
                id_tipo_cultivo: variedades[i].id_tipo_cultivo,
                nombre: variedades[i].nombre,
                tiempo_produccion: variedades[i].tiempo_produccion,
                rendimiento_esperado: variedades[i].rendimiento_esperado,
                resistencia_zona: variedades[i].resistencia_zona,
                activo: variedades[i].activo,
                nombre_tipo_cultivo: variedades[i].nombre_tipo_cultivo
            });
        }
        
        // Actualizar también los combos de filtros
        actualizarTiposFiltro();
        actualizarTiposCombobox();
    }

    // Actualizar el modelo de ciclos de producción
   function cargarCiclosProduccion() {
    console.log("Intentando cargar ciclos de producción...")
    ciclosModel.clear()
    
    const ciclos = cultivos.ciclos_produccion
    console.log("Ciclos recibidos: " + ciclos.length)
    
    for (let i = 0; i < ciclos.length; i++) {
        const ciclo = ciclos[i]
        
        // Asegurar que todos los campos existan con valores predeterminados
        const cicloFormateado = {
            id_ciclo: ciclo.id_ciclo || 0,
            id_parcela: ciclo.id_parcela || 0,
            id_variedad: ciclo.id_variedad || 0,
            fecha_siembra: ciclo.fecha_siembra || "",
            fecha_cosecha_estimada: ciclo.fecha_cosecha_estimada || "",
            fecha_cosecha_real: typeof ciclo.fecha_cosecha_real !== 'undefined' ? ciclo.fecha_cosecha_real : "",
            area_sembrada: parseFloat(ciclo.area_sembrada || 0),
            densidad_siembra: parseInt(ciclo.densidad_siembra || 0),
            estado: ciclo.estado || "Planificado",
            activo: !!ciclo.activo,
            fecha_floracion: typeof ciclo.fecha_floracion !== 'undefined' ? ciclo.fecha_floracion : "",
            fecha_poda: typeof ciclo.fecha_poda !== 'undefined' ? ciclo.fecha_poda : "",
            fecha_limpieza: typeof ciclo.fecha_limpieza !== 'undefined' ? ciclo.fecha_limpieza : "",
            frecuencia_limpieza: parseInt(ciclo.frecuencia_limpieza || 1),
            nombre_parcela: ciclo.nombre_parcela || "Sin parcela",
            nombre_variedad: ciclo.nombre_variedad || "Sin variedad",
            nombre_tipo_cultivo: ciclo.nombre_tipo_cultivo || "Sin tipo"
        }
        
        ciclosModel.append(cicloFormateado)
    }
    
    // Actualizar también los combos de filtros y otros modelos relacionados
    actualizarEstadosFiltro()
    actualizarParcelasCombobox()
    actualizarVariedadesCombobox()
    actualizarCultivosFiltro()
    cargarEventosCalendario()
}
    // Actualizar opciones de tipos para el filtro de variedades
    function actualizarTiposFiltro() {
        // Preservar selección actual si existe
        const seleccionActual = cmbFiltroTipos.currentValue;
        
        // Limpiar modelo excepto el primer elemento "Todos los tipos"
        while (tiposFiltroModel.count > 1) {
            tiposFiltroModel.remove(1);
        }
        
        // Añadir tipos desde el modelo de tipos de cultivo
        for (let i = 0; i < tiposCultivoModel.count; i++) {
            const tipo = tiposCultivoModel.get(i);
            if (tipo.activo) {
                tiposFiltroModel.append({
                    text: tipo.nombre,
                    value: Number(tipo.id_tipo_cultivo)
                });
            }
        }
        
        // Restaurar selección si posible
        if (seleccionActual) {
            for (let i = 0; i < tiposFiltroModel.count; i++) {
                if (tiposFiltroModel.get(i).value === seleccionActual) {
                    cmbFiltroTipos.currentIndex = i;
                    break;
                }
            }
        }
    }

    // Actualizar opciones de tipos para el combobox de nueva variedad
    function actualizarTiposCombobox() {
        tiposVariedadModel.clear();
        
        for (let i = 0; i < tiposCultivoModel.count; i++) {
            const tipo = tiposCultivoModel.get(i);
            if (tipo.activo) {
                tiposVariedadModel.append({
                    text: tipo.nombre,
                    value: tipo.id_tipo_cultivo
                });
            }
        }
        
        // Seleccionar el primero si hay elementos
        if (tiposVariedadModel.count > 0) {
            cmbTipoCultivo.currentIndex = 0;
        }
    }

    // Actualizar opciones de estados para el filtro de ciclos
    function actualizarEstadosFiltro() {
        // Preservar selección actual si existe
        const seleccionActual = cmbFiltroEstados.currentText;
        
        // Limpiar modelo excepto el primer elemento "Todos los estados"
        while (estadosFiltroModel.count > 1) {
            estadosFiltroModel.remove(1);
        }
        
        // Añadir estados desde la lista de estados válidos
        const estados = ["Planificado", "En Preparación", "Sembrado", "En Desarrollo", "En Cosecha", "Finalizado", "Cancelado"];
        for (let i = 0; i < estados.length; i++) {
            estadosFiltroModel.append({
                text: estados[i],
                value: estados[i]
            });
        }
        
        // Restaurar selección si posible
        if (seleccionActual) {
            for (let i = 0; i < estadosFiltroModel.count; i++) {
                if (estadosFiltroModel.get(i).text === seleccionActual) {
                    cmbFiltroEstados.currentIndex = i;
                    break;
                }
            }
        }
    }

    // Actualizar opciones de parcelas para el combobox de nuevo ciclo
    function actualizarParcelasCombobox() {
        // Aquí deberíamos cargar las parcelas desde el modelo de parcelas
        // Por ahora, usaremos datos de ejemplo
        parcelasModel.clear();
        
        // En una implementación real, estas parcelas vendrían de la base de datos
        parcelasModel.append({ text: "Parcela 1", value: 1 });
        parcelasModel.append({ text: "Parcela 2", value: 2 });
        parcelasModel.append({ text: "Parcela 3", value: 3 });
        
        // Seleccionar el primero si hay elementos
        if (parcelasModel.count > 0) {
            cmbParcelas.currentIndex = 0;
        }
    }

    // Actualizar opciones de variedades para el combobox de nuevo ciclo
    function actualizarVariedadesCombobox() {
        variedadesCicloModel.clear();
        
        for (let i = 0; i < variedadesModel.count; i++) {
            const variedad = variedadesModel.get(i);
            if (variedad.activo) {
                variedadesCicloModel.append({
                    text: variedad.nombre + " (" + variedad.nombre_tipo_cultivo + ")",
                    value: variedad.id_variedad
                });
            }
        }
        
        // Seleccionar el primero si hay elementos
        if (variedadesCicloModel.count > 0) {
            cmbVariedades.currentIndex = 0;
        }
    }

    // Actualizar opciones de cultivos para el filtro del calendario
    function actualizarCultivosFiltro() {
        // Preservar selección actual si existe
        const seleccionActual = cmbFiltroCultivosCalendario.currentValue;
        
        // Limpiar modelo excepto el primer elemento "Todos los cultivos"
        while (cultivosFiltroModel.count > 1) {
            cultivosFiltroModel.remove(1);
        }
        
        // Recopilar todos los tipos de cultivo usados en ciclos
        const tiposUsados = new Set();
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i);
            if (ciclo.activo) {
                tiposUsados.add(ciclo.nombre_tipo_cultivo);
            }
        }
        
        // Añadir tipos usados al modelo
        tiposUsados.forEach(nombreTipo => {
            cultivosFiltroModel.append({
                text: nombreTipo,
                value: nombreTipo
            });
        });
        
        // Restaurar selección si posible
        if (seleccionActual) {
            for (let i = 0; i < cultivosFiltroModel.count; i++) {
                if (cultivosFiltroModel.get(i).value === seleccionActual) {
                    cmbFiltroCultivosCalendario.currentIndex = i;
                    break;
                }
            }
        }
    }

    // Función para cargar eventos del calendario desde los ciclos
    function cargarEventosCalendario() {
        eventosPorFecha = {}
        
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i)
            if (!ciclo.activo) continue
            
            // Añadir evento de siembra
            if (ciclo.fecha_siembra && ciclo.fecha_siembra !== "") {
                const fechaSiembra = parseDBDate(ciclo.fecha_siembra)
                if (fechaSiembra) {
                    const key = fechaSiembra.getFullYear() + "-" + (fechaSiembra.getMonth() + 1) + "-" + fechaSiembra.getDate()
                    if (!eventosPorFecha[key]) eventosPorFecha[key] = []
                    eventosPorFecha[key].push({
                        text: "Siembra " + ciclo.nombre_variedad,
                        color: "#2E7D32"
                    })
                }
            }
            
            // Añadir evento de cosecha estimada
            if (ciclo.fecha_cosecha_estimada && ciclo.fecha_cosecha_estimada !== "") {
                const fechaCosecha = parseDBDate(ciclo.fecha_cosecha_estimada)
                if (fechaCosecha) {
                    const key = fechaCosecha.getFullYear() + "-" + (fechaCosecha.getMonth() + 1) + "-" + fechaCosecha.getDate()
                    if (!eventosPorFecha[key]) eventosPorFecha[key] = []
                    eventosPorFecha[key].push({
                        text: "Cosecha " + ciclo.nombre_variedad,
                        color: "#FF9800"
                    })
                }
            }
            
            // Añadir evento de poda (verificar que exista y no esté vacío)
            if (ciclo.fecha_poda && ciclo.fecha_poda !== "") {
                const fechaPoda = parseDBDate(ciclo.fecha_poda)
                if (fechaPoda) {
                    const key = fechaPoda.getFullYear() + "-" + (fechaPoda.getMonth() + 1) + "-" + fechaPoda.getDate()
                    if (!eventosPorFecha[key]) eventosPorFecha[key] = []
                    eventosPorFecha[key].push({
                        text: "Poda " + ciclo.nombre_variedad,
                        color: "#9C27B0"
                    })
                }
            }
            
            // ... Hacer lo mismo para las otras fechas opcionales
        }
        
        // Asegúrate de que el calendario se actualice después de cargar los eventos
        actualizarCalendario()
    }

    // Función para parsear fechas de la base de datos (formato YYYY-MM-DD)
    function parseDBDate(dateStr) {
        // Si la fecha está en formato DD/MM/YYYY
        if (dateStr.includes('/')) {
            const parts = dateStr.split('/');
            if (parts.length === 3) {
                const day = parseInt(parts[0], 10);
                const month = parseInt(parts[1], 10) - 1; // Los meses en JS empiezan en 0
                const year = parseInt(parts[2], 10);
                return new Date(year, month, day);
            }
        } 
        // Si la fecha está en formato YYYY-MM-DD
        else if (dateStr.includes('-')) {
            const parts = dateStr.split('-');
            if (parts.length === 3) {
                const year = parseInt(parts[0], 10);
                const month = parseInt(parts[1], 10) - 1; // Los meses en JS empiezan en 0
                const day = parseInt(parts[2], 10);
                return new Date(year, month, day);
            }
        }
        
        return null;
    }

    // Función para obtener eventos para un día específico
    function getEventsForDay(day, month, year) {
        // Filtrar por tipo de cultivo si está seleccionado
        const filtroTipo = cmbFiltroCultivosCalendario.currentIndex > 0 ? 
                        cmbFiltroCultivosCalendario.currentText : null;
        
        const key = year + "-" + (month + 1) + "-" + day;
        if (eventosPorFecha[key]) {
            if (filtroTipo) {
                // Solo retornar eventos del tipo de cultivo seleccionado
                return eventosPorFecha[key].filter(evento => 
                    evento.text.includes(filtroTipo));
            } else {
                return eventosPorFecha[key];
            }
        }
        return [];
    }

    // Función para actualizar el calendario
    function actualizarCalendario() {
        // Calcular el primer día del mes
        var primerDia = new Date(fechaActual.getFullYear(), fechaActual.getMonth(), 1);
        var diaSemana = primerDia.getDay();
        if (diaSemana === 0) diaSemana = 7; // Domingo es 0, lo convertimos a 7
        
        // Calcular el número de días en el mes actual
        var ultimoDia = new Date(fechaActual.getFullYear(), fechaActual.getMonth() + 1, 0);
        var diasEnMes = ultimoDia.getDate();
        
        // Obtener la fecha actual real
        var hoy = new Date();
        
        // Actualizar las celdas del calendario
        for (var i = 0; i < 42; i++) {
            var celda = calendarRepeater.itemAt(i);
            if (celda) {
                var diaMes = i - (diaSemana - 1) + 1;
                celda.diaNumero = diaMes > 0 && diaMes <= diasEnMes ? diaMes : 0;
                celda.esDiaMesActual = diaMes > 0 && diaMes <= diasEnMes;
                celda.esDiaActual = celda.esDiaMesActual && 
                                fechaActual.getMonth() === hoy.getMonth() && 
                                fechaActual.getFullYear() === hoy.getFullYear() && 
                                diaMes === hoy.getDate();
            }
        }
    }

    // Función para obtener el nombre del mes
    function obtenerNombreMes(mes) {
        var meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
        return meses[mes];
    }

    // Función para formatear la fecha actual
    function getFormattedDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
        var yyyy = today.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
    }

    // Funciones de interacción con la BD a través del modelo Python

    // Guardar nuevo tipo de cultivo
    function guardarNuevoTipoCultivo() {
        // Validar datos
        if (nuevoTipoCultivo.nombre.trim() === "") {
            showMessage("Por favor, ingrese al menos el nombre del tipo de cultivo");
            return;
        }
        
        // Convertir objeto a JSON para enviarlo al modelo Python
        const tipoJSON = JSON.stringify(nuevoTipoCultivo);
        
        // Llamar al método del modelo Python
        const success = cultivos.agregar_tipo_cultivo(tipoJSON);
        
        if (success) {
            // Recargar tipos de cultivo
            cultivos.cargar_tipos_cultivo();
            cargarTiposCultivo();
            
            // Ocultar formulario de edición
            mostrarFilaEdicionTipo = false;
            
            // Mensaje de éxito
            showMessage("Tipo de cultivo guardado correctamente");
        } else {
            showMessage("Error al guardar el tipo de cultivo");
        }
    }

    // Actualizar tipo de cultivo existente
    function actualizarTipoCultivo() {
        // Verificar que haya un tipo seleccionado
        if (tiposCultivoListView.currentIndex < 0) {
            showMessage("Por favor, seleccione un tipo de cultivo para actualizar");
            return;
        }
        
        // Obtener el ID del tipo seleccionado
        const tipo = tiposCultivoModel.get(tiposCultivoListView.currentIndex);
        const id_tipo = tipo.id_tipo_cultivo;
        
        // Crear objeto con los datos actualizados
        const datosActualizados = {
            nombre: txtNombreTipo.text,
            nombre_cientifico: txtNombreCientifico.text,
            tiempo_cosecha_min: spinTiempoMin.value,
            tiempo_cosecha_max: spinTiempoMax.value,
            descripcion: txtDescripcion.text,
            activo: chkActivo.checked
        };
        
        // Convertir objeto a JSON
        const tipoJSON = JSON.stringify(datosActualizados);
        
        // Llamar al método del modelo Python
        const success = cultivos.actualizar_tipo_cultivo(id_tipo, tipoJSON);
        
        if (success) {
            // Recargar tipos de cultivo
            cultivos.cargar_tipos_cultivo();
            cargarTiposCultivo();
            
            // Mensaje de éxito
            showMessage("Tipo de cultivo actualizado correctamente");
        } else {
            showMessage("Error al actualizar el tipo de cultivo");
        }
    }

    // Eliminar tipo de cultivo
    function eliminarTipoCultivo(id_tipo) {
        // Llamar al método del modelo Python
        const success = cultivos.eliminar_tipo_cultivo(id_tipo);
        
        if (success) {
            // Recargar tipos de cultivo
            cultivos.cargar_tipos_cultivo();
            cargarTiposCultivo();
            
            // Mensaje de éxito
            showMessage("Tipo de cultivo eliminado correctamente");
        } else {
            showMessage("No se puede eliminar el tipo de cultivo. Puede tener variedades asociadas.");
        }
    }

    // Desactivar tipo de cultivo
    function desactivarTipoCultivo(id_tipo) {
        // Llamar al método del modelo Python
        const success = cultivos.desactivar_tipo_cultivo(id_tipo);
        
        if (success) {
            // Recargar tipos de cultivo
            cultivos.cargar_tipos_cultivo();
            cargarTiposCultivo();
            
            // Mensaje de éxito
            showMessage("Tipo de cultivo desactivado correctamente");
        } else {
            showMessage("Error al desactivar el tipo de cultivo");
        }
    }

    // Guardar nueva variedad
    function guardarNuevaVariedad() {
        // Validaciones hechas en el botón Guardar del diálogo
        
        // Convertir objeto a JSON
        const variedadJSON = JSON.stringify(nuevaVariedad);
        
        // Llamar al método del modelo Python
        const success = cultivos.agregar_variedad_cultivo(variedadJSON);
        
        if (success) {
            // Recargar variedades
            cultivos.cargar_variedades();
            cargarVariedades();
            
            // Cerrar el diálogo
            dialogNuevaVariedad.close();
            
            // Mensaje de éxito
            showMessage("Variedad guardada correctamente");
        } else {
            mensajeValidacionVariedad.text = "Error al guardar la variedad";
        }
    }

    // Editar variedad existente
    function editarVariedad(variedad) {
        // Abrir diálogo con datos cargados
        dialogNuevaVariedad.title = "Editar Variedad";
        
        // Cargar datos de la variedad en los campos
        cmbTipoCultivo.currentIndex = getTipoIndex(variedad.id_tipo_cultivo);
        txtNombreVariedad.text = variedad.nombre;
        spinTiempoProduccion.value = variedad.tiempo_produccion || 0;
        txtRendimiento.text = variedad.rendimiento_esperado ? variedad.rendimiento_esperado.toString() : "";
        cmbResistencia.currentIndex = getResistenciaIndex(variedad.resistencia_zona);
        
        // Guardar ID para actualización
        nuevaVariedad = {
            id_tipo_cultivo: variedad.id_tipo_cultivo,
            nombre: variedad.nombre,
            tiempo_produccion: variedad.tiempo_produccion || 0,
            rendimiento_esperado: variedad.rendimiento_esperado || 0.0,
            resistencia_zona: variedad.resistencia_zona || "Media",
            activo: variedad.activo
        };
        
        // Variable para identificar que estamos en modo edición
        dialogNuevaVariedad.editing = true;
        dialogNuevaVariedad.variedadId = variedad.id_variedad;
        
        dialogNuevaVariedad.open();
    }

    // Función para obtener índice de tipo de cultivo en combobox
    function getTipoIndex(id_tipo_cultivo) {
        for (let i = 0; i < tiposVariedadModel.count; i++) {
            if (tiposVariedadModel.get(i).value === id_tipo_cultivo) {
                return i;
            }
        }
        return 0;
    }

    // Función para obtener índice de resistencia en combobox
    function getResistenciaIndex(resistencia) {
        const resistencias = ["Alta", "Media", "Baja"];
        const index = resistencias.indexOf(resistencia);
        return index >= 0 ? index : 1; // Por defecto "Media"
    }

    // Eliminar variedad
    function eliminarVariedad(id_variedad) {
        // Llamar al método del modelo Python
        const success = cultivos.eliminar_variedad_cultivo(id_variedad);
        
        if (success) {
            // Recargar variedades
            cultivos.cargar_variedades();
            cargarVariedades();
            
            // Mensaje de éxito
            showMessage("Variedad eliminada correctamente");
        } else {
            showMessage("No se puede eliminar la variedad. Puede tener ciclos de producción asociados.");
        }
    }

    // Guardar nuevo ciclo de producción
    function guardarNuevoCiclo() {
        // Validaciones hechas en el botón Guardar del diálogo
        
        // Convertir objeto a JSON
        const cicloJSON = JSON.stringify(nuevoCiclo);
        
        // Llamar al método del modelo Python
        const success = cultivos.agregar_ciclo_produccion(cicloJSON);
        
        if (success) {
            // Recargar ciclos
            cultivos.cargar_ciclos_produccion();
            cargarCiclosProduccion();
            
            // Cerrar el diálogo
            dialogCicloProduccion.close();
            
            // Mensaje de éxito
            showMessage("Ciclo de producción guardado correctamente");
        } else {
            mensajeValidacionCiclo.text = "Error al guardar el ciclo de producción";
        }
    }

    // Actualizar ciclo de producción existente
    function actualizarCiclo() {
        // Crear objeto con los datos actualizados
        const datosActualizados = {
            id_parcela: parcelasModel.get(cmbParcelas.currentIndex).value,
            id_variedad: variedadesCicloModel.get(cmbVariedades.currentIndex).value,
            fecha_siembra: txtFechaSiembra.text,
            fecha_cosecha_estimada: txtFechaCosechaEst.text,
            fecha_cosecha_real: txtFechaCosechaReal.text,
            area_sembrada: parseFloat(txtAreaSembrada.text),
            densidad_siembra: spinDensidad.value,
            estado: cmbEstado.currentText,
            activo: ciclo_chkActivo.checked,
            fecha_floracion: txtFechaFloracion.text,
            fecha_poda: txtFechaPoda.text,
            fecha_limpieza: txtFechaLimpieza.text,
            frecuencia_limpieza: spinFrecuenciaLimpieza.value
        };
        
        // Convertir objeto a JSON
        const cicloJSON = JSON.stringify(datosActualizados);
        
        // Llamar al método del modelo Python
        const success = cultivos.actualizar_ciclo_produccion(dialogCicloProduccion.cicloId, cicloJSON);
        
        if (success) {
            // Recargar ciclos
            cultivos.cargar_ciclos_produccion();
            cargarCiclosProduccion();
            
            // Cerrar el diálogo
            dialogCicloProduccion.close();
            
            // Mensaje de éxito
            showMessage("Ciclo de producción actualizado correctamente");
        } else {
            mensajeValidacionCiclo.text = "Error al actualizar el ciclo de producción";
        }
    }

    // Eliminar ciclo de producción
    function eliminarCiclo(id_ciclo) {
        // Llamar al método del modelo Python
        const success = cultivos.eliminar_ciclo_produccion(id_ciclo);
        
        if (success) {
            // Recargar ciclos
            cultivos.cargar_ciclos_produccion();
            cargarCiclosProduccion();
            
            // Mensaje de éxito
            showMessage("Ciclo de producción eliminado correctamente");
        } else {
            showMessage("Error al eliminar el ciclo de producción");
        }
    }

    // Funciones de filtrado

    // Filtrar tipos de cultivo por texto de búsqueda
    function filtrarTiposCultivo() {
        const textoBusqueda = txtBuscarTipoCultivo.text.toLowerCase();
        
        // Recargar todos los tipos
        cargarTiposCultivo();
        
        // Si no hay texto de búsqueda, no filtramos
        if (textoBusqueda === "") return;
        
        // Crear una lista temporal con los tipos filtrados
        const tiposFiltrados = [];
        
        for (let i = 0; i < tiposCultivoModel.count; i++) {
            const tipo = tiposCultivoModel.get(i);
            if (tipo.nombre.toLowerCase().includes(textoBusqueda) ||
                (tipo.nombre_cientifico && tipo.nombre_cientifico.toLowerCase().includes(textoBusqueda)) ||
                (tipo.descripcion && tipo.descripcion.toLowerCase().includes(textoBusqueda))) {
                tiposFiltrados.push(tipo);
            }
        }
        
        // Limpiar y volver a llenar el modelo con los tipos filtrados
        tiposCultivoModel.clear();
        for (let i = 0; i < tiposFiltrados.length; i++) {
            tiposCultivoModel.append(tiposFiltrados[i]);
        }
    }

    // Filtrar variedades por texto de búsqueda
    function filtrarVariedades() {
        const textoBusqueda = txtBuscarVariedad.text.toLowerCase();
        
        // Recargar todas las variedades
        cargarVariedades();
        
        // Aplicar filtro de tipo si está activo
        if (cmbFiltroTipos.currentIndex > 0) {
            filtrarVariedadesPorTipo();
        }
        
        // Si no hay texto de búsqueda, no filtramos más
        if (textoBusqueda === "") return;
        
        // Crear una lista temporal con las variedades filtradas
        const variedadesFiltradas = [];
        
        for (let i = 0; i < variedadesModel.count; i++) {
            const variedad = variedadesModel.get(i);
            if (variedad.nombre.toLowerCase().includes(textoBusqueda) ||
                variedad.nombre_tipo_cultivo.toLowerCase().includes(textoBusqueda)) {
                variedadesFiltradas.push(variedad);
            }
        }
        
        // Limpiar y volver a llenar el modelo con las variedades filtradas
        variedadesModel.clear();
        for (let i = 0; i < variedadesFiltradas.length; i++) {
            variedadesModel.append(variedadesFiltradas[i]);
        }
    }

    // Filtrar variedades por tipo de cultivo
    function filtrarVariedadesPorTipo() {
        // Si está seleccionado "Todos los tipos", recargar todas las variedades
        if (cmbFiltroTipos.currentIndex === 0) {
            cargarVariedades();
            return;
        }
        
        // Obtener ID del tipo seleccionado
        const idTipo = cmbFiltroTipos.currentValue;
        
        // Recargar variedades desde Python filtrando por tipo
        cultivos.cargar_variedades_por_tipo(idTipo);
        cargarVariedades();
        
        // Volver a aplicar filtro de búsqueda si existe
        if (txtBuscarVariedad.text !== "") {
            filtrarVariedades();
        }
    }

    // Filtrar ciclos por texto de búsqueda
    function filtrarCiclos() {
        const textoBusqueda = txtBuscarCiclo.text.toLowerCase();
        
        // Recargar todos los ciclos
        cargarCiclosProduccion();
        
        // Aplicar filtro de estado si está activo
        if (cmbFiltroEstados.currentIndex > 0) {
            filtrarCiclosPorEstado();
        }
        
        // Si no hay texto de búsqueda, no filtramos más
        if (textoBusqueda === "") return;
        
        // Crear una lista temporal con los ciclos filtrados
        const ciclosFiltrados = [];
        
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i);
            if (ciclo.nombre_parcela.toLowerCase().includes(textoBusqueda) ||
                ciclo.nombre_variedad.toLowerCase().includes(textoBusqueda) ||
                ciclo.nombre_tipo_cultivo.toLowerCase().includes(textoBusqueda) ||
                ciclo.estado.toLowerCase().includes(textoBusqueda)) {
                ciclosFiltrados.push(ciclo);
            }
        }
        
        // Limpiar y volver a llenar el modelo con los ciclos filtrados
        ciclosModel.clear();
        for (let i = 0; i < ciclosFiltrados.length; i++) {
            ciclosModel.append(ciclosFiltrados[i]);
        }
    }

    // Filtrar ciclos por estado
    function filtrarCiclosPorEstado() {
        // Si está seleccionado "Todos los estados", recargar todos los ciclos
        if (cmbFiltroEstados.currentIndex === 0) {
            cargarCiclosProduccion();
            return;
        }
        
        // Obtener estado seleccionado
        const estado = cmbFiltroEstados.currentText;
        
        // Recargar ciclos desde Python filtrando por estado
        cultivos.cargar_ciclos_por_estado(estado);
        cargarCiclosProduccion();
        
        // Volver a aplicar filtro de búsqueda si existe
        if (txtBuscarCiclo.text !== "") {
            filtrarCiclos();
        }
    }

    // Cargar detalles de un tipo de cultivo seleccionado
    function cargarDetallesTipoCultivo(tipo) {
        txtNombreTipo.text = tipo.nombre;
        txtNombreCientifico.text = tipo.nombre_cientifico || "";
        spinTiempoMin.value = tipo.tiempo_cosecha_min || 0;
        spinTiempoMax.value = tipo.tiempo_cosecha_max || 0;
        chkActivo.checked = tipo.activo;
        txtDescripcion.text = tipo.descripcion || "";
    }

    // Funciones de exportación

    // Exportar variedades a CSV
    function exportarVariedades() {
        // Implementación básica - En una aplicación real se usaría un diálogo de guardar
        let csv = "ID,Tipo,Nombre,Tiempo (días),Rendimiento (ton/ha),Resistencia\n";
        
        for (let i = 0; i < variedadesModel.count; i++) {
            const v = variedadesModel.get(i);
            csv += `${v.id_variedad},${v.nombre_tipo_cultivo},${v.nombre},${v.tiempo_produccion || 0},${v.rendimiento_esperado || 0},${v.resistencia_zona}\n`;
        }
        
        // En una aplicación real, aquí guardaríamos el CSV a un archivo
        console.log("Exportar variedades a CSV:");
        console.log(csv);
        
        showMessage("Función de exportación a CSV implementada. Revise la consola para ver el resultado.");
    }

    // Exportar ciclos a CSV
    function exportarCiclos() {
        // Implementación básica - En una aplicación real se usaría un diálogo de guardar
        let csv = "ID,Parcela,Variedad,Fecha Siembra,Fecha Cosecha Est.,Área (ha),Densidad,Estado\n";
        
        for (let i = 0; i < ciclosModel.count; i++) {
            const c = ciclosModel.get(i);
            csv += `${c.id_ciclo},${c.nombre_parcela},${c.nombre_variedad},${c.fecha_siembra || ""},${c.fecha_cosecha_estimada || ""},${c.area_sembrada},${c.densidad_siembra || 0},${c.estado}\n`;
        }
        
        // En una aplicación real, aquí guardaríamos el CSV a un archivo
        console.log("Exportar ciclos a CSV:");
        console.log(csv);
        
        showMessage("Función de exportación a CSV implementada. Revise la consola para ver el resultado.");
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
}