import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15 

Rectangle {
    id: cultivosRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // Propiedades para edición de tipos de cultivo
    property bool mostrarFilaEdicionTipo: false
    property var nuevoTipoCultivo: {
        "tipoId": "", 
        "nombre": "", 
        "nombreCientifico": "", 
        "tiempoCosechaMin": 0,
        "tiempoCosechaMax": 0,
        "descripcion": ""
    }
    
    // Propiedades para edición de variedades
    property var nuevaVariedad: {
        "variedadId": "",
        "tipo": "",
        "nombre": "",
        "tiempoProduccion": 0,
        "rendimiento": "",
        "resistencia": "Media",
        "resistenciaColor": "#FF9800"
    }
    
    // Propiedades para el calendario
    property var fechaActual: new Date()

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
                                    "tipoId": "",
                                    "nombre": "",
                                    "nombreCientifico": "",
                                    "tiempoCosechaMin": 0,
                                    "tiempoCosechaMax": 0,
                                    "descripcion": ""
                                }
                                
                                // Mostrar panel de detalles limpio para agregar
                                mostrarFilaEdicionTipo = true
                            }
                        }
                    }
                    
                    // Campo de búsqueda
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Buscar tipo de cultivo..."
                        implicitHeight: 36
                        background: Rectangle {
                            color: "#b2c4c9"
                            radius: height / 2
                        }
                    }

                    // Lista de tipos de cultivo
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: tiposCultivoModel
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
                                    text: nombreCientifico
                                    font.pixelSize: 12
                                    font.italic: true
                                    color: "#757575"
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    parent.ListView.view.currentIndex = index
                                    mostrarFilaEdicionTipo = false
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
                            text: mostrarFilaEdicionTipo ? "" : (tiposCultivoModel.count > 0 ? tiposCultivoModel.get(tiposCultivoList.currentIndex).nombre : "")
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
                            text: mostrarFilaEdicionTipo ? "" : (tiposCultivoModel.count > 0 ? tiposCultivoModel.get(tiposCultivoList.currentIndex).nombreCientifico : "")
                            onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.nombreCientifico = text
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
                            value: mostrarFilaEdicionTipo ? 0 : (tiposCultivoModel.count > 0 ? tiposCultivoModel.get(tiposCultivoList.currentIndex).tiempoCosechaMin : 0)
                            onValueChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.tiempoCosechaMin = value
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
                            value: mostrarFilaEdicionTipo ? 0 : (tiposCultivoModel.count > 0 ? tiposCultivoModel.get(tiposCultivoList.currentIndex).tiempoCosechaMax : 0)
                            onValueChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.tiempoCosechaMax = value
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
                            text: mostrarFilaEdicionTipo ? "" : (tiposCultivoModel.count > 0 ? "Descripción del tipo de cultivo seleccionado" : "")
                            wrapMode: TextArea.Wrap
                            onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.descripcion = text
                        }
                    }
                    
                    // Estadísticas de producción (simplificado cuando no hay datos)
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
                                    // Aquí iría la lógica para actualizar un tipo existente
                                    showMessage("Función para actualizar tipo de cultivo no implementada")
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
                                    "variedadId": "",
                                    "tipo": tiposCultivoModel.count > 0 ? tiposCultivoModel.get(0).nombre : "",
                                    "nombre": "",
                                    "tiempoProduccion": 0,
                                    "rendimiento": "0.0 ton/ha",
                                    "resistencia": "Media",
                                    "resistenciaColor": "#FF9800"
                                }
                                
                                // Mostrar diálogo de nueva variedad
                                dialogNuevaVariedad.open()
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar variedades..."
                            implicitHeight: 25
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los tipos"]
                            implicitHeight: 36
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
                            onClicked: showMessage("Función de exportación no implementada")
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
                        model: variedadesModel
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
                                        text: variedadId || (index + 1)
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
                                        text: tipo
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
                                        text: tiempoProduccion
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
                                        text: rendimiento
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
                                        color: resistenciaColor
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: resistencia
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
                                            onClicked: showMessage("Función para editar variedad no implementada")
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: {
                                                // Aquí añadiríamos un diálogo de confirmación para eliminar
                                                confirmDeleteVariedadDialog.variedadId = variedadId
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
                            model: ["Todos los cultivos", "Limón", "Naranja", "Mandarina", "Toronja", "Lima"]
                            implicitWidth: 200
                            implicitHeight: 36
                        }
                        
                        ComboBox {
                            model: ["Vista mensual", "Vista trimestral", "Vista anual"]
                            implicitWidth: 150
                            implicitHeight: 36
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
                                
                                // Importante: Solo un contenedor para el contenido
                                Column {
                                    id: contenidoDia
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 3
                                    visible: diaNumero > 0
                                    
                                    // Solo un Text para mostrar el número del día
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
        height: 450
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
                        model: getTiposCultivoNombres()
                        onCurrentTextChanged: nuevaVariedad.tipo = currentText
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
                        onValueChanged: nuevaVariedad.tiempoProduccion = value
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
                                nuevaVariedad.rendimiento = text + " ton/ha"
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
                            nuevaVariedad.resistencia = currentText
                            switch (currentText) {
                                case "Alta": nuevaVariedad.resistenciaColor = "#4CAF50"; break;
                                case "Media": nuevaVariedad.resistenciaColor = "#FF9800"; break;
                                case "Baja": nuevaVariedad.resistenciaColor = "#F44336"; break;
                            }
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
                    
                    // Función para formatear la fecha
                    function getFormattedDate() {
                        var today = new Date();
                        var dd = String(today.getDate()).padStart(2, '0');
                        var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
                        var yyyy = today.getFullYear();
                        return dd + '/' + mm + '/' + yyyy;
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
                    if (tiposCultivoModel.count === 0) {
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
            // INTEGRACIÓN CON SQL SERVER:
            // Aquí ejecutaríamos la consulta DELETE en SQL Server
            // Ejemplo:
            // let db = QSqlDatabase.addDatabase("QODBC")
            // db.setDatabaseName("DRIVER={SQL Server};SERVER=tuServidor;DATABASE=tuBaseDeDatos;UID=usuario;PWD=contraseña")
            // if (db.open()) {
            //     let query = QSqlQuery()
            //     query.prepare("DELETE FROM variedades WHERE id = ?")
            //     query.addBindValue(variedadId)
            //     
            //     if (!query.exec()) {
            //         console.error("Error al eliminar variedad:", query.lastError().text)
            //         showMessage("Error al eliminar la variedad")
            //         return
            //     }
            //     
            //     db.close()
            // } else {
            //     console.error("Error de conexión a la base de datos:", db.lastError().text)
            //     showMessage("Error de conexión a la base de datos")
            //     return
            // }
            
            console.log("Eliminando variedad con ID:", variedadId);
            
            // También eliminamos la variedad del modelo local
            for (let i = 0; i < variedadesModel.count; i++) {
                if (variedadesModel.get(i).variedadId === variedadId) {
                    variedadesModel.remove(i)
                    break
                }
            }
            
            showMessage("Variedad eliminada correctamente")
        }
    }
    
    // Función para obtener nombres de tipos de cultivo para el ComboBox
    function getTiposCultivoNombres() {
        var nombres = [];
        for (var i = 0; i < tiposCultivoModel.count; i++) {
            nombres.push(tiposCultivoModel.get(i).nombre);
        }
        
        if (nombres.length === 0) {
            nombres.push("Sin tipos disponibles");
        }
        
        return nombres;
    }
    
    // Función para guardar nuevo tipo de cultivo
    function guardarNuevoTipoCultivo() {
        // Validar datos
        if (txtNombreTipo.text.trim() === "") {
            showMessage("Por favor, ingrese al menos el nombre del tipo de cultivo")
            return
        }
        
        // INTEGRACIÓN CON SQL SERVER:
        // Aquí es donde conectarías con tu base de datos SQL Server
        // Ejemplo:
        // let db = QSqlDatabase.addDatabase("QODBC")
        // db.setDatabaseName("DRIVER={SQL Server};SERVER=tuServidor;DATABASE=tuBaseDeDatos;UID=usuario;PWD=contraseña")
        // if (!db.open()) {
        //     console.error("Error de conexión a la base de datos:", db.lastError().text)
        //     showMessage("Error de conexión a la base de datos")
        //     return
        // }
        //
        // let query = QSqlQuery()
        // query.prepare("INSERT INTO tipos_cultivo (nombre, nombre_cientifico, tiempo_cosecha_min, tiempo_cosecha_max, descripcion) VALUES (?, ?, ?, ?, ?)")
        // query.addBindValue(nuevoTipoCultivo.nombre)
        // query.addBindValue(nuevoTipoCultivo.nombreCientifico || "")
        // query.addBindValue(nuevoTipoCultivo.tiempoCosechaMin || 0)
        // query.addBindValue(nuevoTipoCultivo.tiempoCosechaMax || 0)
        // query.addBindValue(nuevoTipoCultivo.descripcion || "")
        //
        // if (!query.exec()) {
        //     console.error("Error al insertar tipo de cultivo:", query.lastError().text)
        //     showMessage("Error al guardar el tipo de cultivo")
        //     return
        // }
        //
        // // Obtener el ID generado
        // query.exec("SELECT @@IDENTITY as id")
        // let tipoId = -1
        // if (query.first()) {
        //     tipoId = query.value("id")
        // }
        //
        // db.close()
        
        // Crear un objeto con toda la información del tipo de cultivo
        var datosTipoCultivo = {
            tipoId: tiposCultivoModel.count + 1,
            nombre: nuevoTipoCultivo.nombre,
            nombreCientifico: nuevoTipoCultivo.nombreCientifico || "",
            tiempoCosechaMin: nuevoTipoCultivo.tiempoCosechaMin || 0,
            tiempoCosechaMax: nuevoTipoCultivo.tiempoCosechaMax || 0,
            descripcion: nuevoTipoCultivo.descripcion || ""
        };
        
        console.log("Guardando tipo de cultivo:", JSON.stringify(datosTipoCultivo));
        
        // Añadir al modelo local
        tiposCultivoModel.append(datosTipoCultivo)
        
        // Ocultar formulario de edición
        mostrarFilaEdicionTipo = false
        
        // Mensaje de éxito
        showMessage("Tipo de cultivo guardado correctamente")
    }
    
    // Función para guardar nueva variedad
    function guardarNuevaVariedad() {
        // La validación se hace ahora en el botón Guardar del diálogo
        
        // INTEGRACIÓN CON SQL SERVER:
        // Aquí es donde conectarías con tu base de datos SQL Server
        // Ejemplo:
        // let db = QSqlDatabase.addDatabase("QODBC")
        // db.setDatabaseName("DRIVER={SQL Server};SERVER=tuServidor;DATABASE=tuBaseDeDatos;UID=usuario;PWD=contraseña")
        // if (!db.open()) {
        //     console.error("Error de conexión a la base de datos:", db.lastError().text)
        //     mensajeValidacionVariedad.text = "Error de conexión a la base de datos"
        //     return
        // }
        //
        // Obtener el tipo_id correspondiente al nombre seleccionado
        // let tipoId = -1
        // let query = QSqlQuery()
        // query.prepare("SELECT id FROM tipos_cultivo WHERE nombre = ?")
        // query.addBindValue(nuevaVariedad.tipo)
        // if (query.exec() && query.first()) {
        //     tipoId = query.value("id")
        // }
        //
        // query.prepare("INSERT INTO variedades (tipo_id, nombre, tiempo_produccion, rendimiento, resistencia, fecha_registro, descripcion) VALUES (?, ?, ?, ?, ?, ?, ?)")
        // query.addBindValue(tipoId)
        // query.addBindValue(nuevaVariedad.nombre)
        // query.addBindValue(nuevaVariedad.tiempoProduccion)
        // query.addBindValue(nuevaVariedad.rendimiento)
        // query.addBindValue(nuevaVariedad.resistencia)
        // query.addBindValue(txtFechaRegistro.text)
        // query.addBindValue(txtDescripcionVariedad.text)
        //
        // if (!query.exec()) {
        //     console.error("Error al insertar variedad:", query.lastError().text)
        //     mensajeValidacionVariedad.text = "Error al guardar la variedad"
        //     return
        // }
        //
        // // Obtener el ID generado
        // query.exec("SELECT @@IDENTITY as id")
        // let variedadId = -1
        // if (query.first()) {
        //     variedadId = query.value("id")
        // }
        //
        // db.close()
        
        // Crear un objeto con toda la información de la variedad
        var datosVariedad = {
            variedadId: variedadesModel.count + 1,
            tipo: nuevaVariedad.tipo,
            nombre: nuevaVariedad.nombre,
            tiempoProduccion: nuevaVariedad.tiempoProduccion.toString(),
            rendimiento: nuevaVariedad.rendimiento,
            resistencia: nuevaVariedad.resistencia,
            resistenciaColor: nuevaVariedad.resistenciaColor,
            fechaRegistro: txtFechaRegistro.text,
            descripcion: txtDescripcionVariedad.text || ""
        };
        
        console.log("Guardando variedad:", JSON.stringify(datosVariedad));
        
        // Añadir al modelo local
        variedadesModel.append(datosVariedad)
        
        // Cerrar el diálogo
        dialogNuevaVariedad.close()
        
        // Mensaje de éxito
        showMessage("Variedad guardada correctamente")
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

    // Función para simular eventos del calendario
    function getEventsForDay(day, month, year) {
        // Por ahora devolvemos eventos de ejemplo
        var events = [];
        if (day === 5) {
            events.push({text: "Siembra Limón", color: "#2E7D32"});
        } else if (day === 10) {
            events.push({text: "Cosecha Naranja", color: "#FF9800"});
            events.push({text: "Fertilización", color: "#2196F3"});
        } else if (day === 15) {
            events.push({text: "Fumigación", color: "#F44336"});
        } else if (day === 20) {
            events.push({text: "Poda Mandarina", color: "#9C27B0"});
        }
        return events;
        
        // INTEGRACIÓN CON SQL SERVER:
        // En el futuro, aquí se conectaría con la base de datos
        // Ejemplo:
        // let events = [];
        // let db = QSqlDatabase.addDatabase("QODBC")
        // db.setDatabaseName("DRIVER={SQL Server};SERVER=tuServidor;DATABASE=tuBaseDeDatos;UID=usuario;PWD=contraseña")
        // if (db.open()) {
        //     let query = QSqlQuery()
        //     query.prepare("SELECT * FROM eventos_calendario WHERE DAY(fecha) = ? AND MONTH(fecha) = ? AND YEAR(fecha) = ?")
        //     query.addBindValue(day)
        //     query.addBindValue(month + 1) // Se suma 1 porque los meses en JS empiezan desde 0
        //     query.addBindValue(year)
        //
        //     if (query.exec()) {
        //         while (query.next()) {
        //             events.push({
        //                 text: query.value("nombre_evento"),
        //                 color: query.value("color") || "#2E7D32" // Color por defecto si no hay uno definido
        //             });
        //         }
        //     }
        //     db.close()
        // }
        // return events;
    }

    // Modelos de datos (vacíos inicialmente)
    ListModel {
        id: tiposCultivoModel
        // Se agregarán elementos cuando el usuario los cree
    }

    // Modelo de Variedades de Cultivo
    ListModel {
        id: variedadesModel
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
    
    // Inicializar el calendario cuando se carga el componente
    Component.onCompleted: {
        actualizarCalendario();
    }
}                                
