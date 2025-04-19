import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: agricultorerParcelaRoot
    anchors.fill: parent
    color: "#F8F9FA"
    property var agricultoresparcelas: null  
    // Propiedades para la edición de agricultores
    property var nuevoAgricultor: { 
        "agricultorId": "", 
        "nombre": "", 
        "apellido": "", 
        "identificacion": "", 
        "telefono": "", 
        "correo": "", 
        "esPropietario": false 
    }
    
    // Propiedades para la edición de parcelas
    property var nuevaParcela: {
        "parcelaId": "",
        "nombre": "",
        "propietario": "",
        "ubicacion": "",
        "area": 0,
        "porcentajeUso": 0
    }

    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "GESTIÓN DE PROPIETARIOS Y TERRENO"
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
        spacing: 20   // 👈 Espaciado horizontal entre botones
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
            text: "Agricultores"
            width:contentItem.implicitWidth + 40
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
            text: "Parcelas"
            width: contentItem.implicitWidth + 40
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
            text: "Mapa"
            width: contentItem.implicitWidth + 40
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

        // Página de Agricultores
        Item {
            // Barra de acciones
            Rectangle {
                id: actionBar
                width: parent.width
                height: 50
                color: "white"
                radius: 25
                border.color: "#EEEEEE"

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 20
                    spacing: 25

                    Button {
                        text: "Nuevo Agricultor"
                        icon.source: "Image/Image_UI_interfaz/Inconos/agregar-usuario.svg"
                        implicitHeight: 36
                        background: Rectangle {
                            color: "#f5922f"
                            radius: height / 2
                        }
                        onClicked: {
                            // Inicializa los valores para el nuevo agricultor
                            nuevoAgricultor = { 
                                "agricultorId": "", 
                                "nombre": "", 
                                "apellido": "", 
                                "identificacion": "", 
                                "telefono": "", 
                                "correo": "", 
                                "esPropietario": false 
                            }
                            
                            // Mostrar el diálogo de nuevo agricultor
                            dialogNuevoAgricultor.open()
                        }
                    }

                    TextField {
                        placeholderText: "Buscar agricultor..."
                        implicitWidth: 400
                        implicitHeight: 25
                        background: Rectangle {
                            color: "#b2c4c9"
                            radius: height / 2
                        }
                    }
                }
            }

            // Tabla de agricultores
            Rectangle {
                anchors.top: actionBar.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                ListView {
                    id: agricultoesListView
                    anchors.fill: parent
                    anchors.margins: 1
                    clip: true
                    model: agricultoresparcelas ? agricultoresparcelas.agricultoresModel : null
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
                                width: parent.width * 0.25
                                height: parent.height
                                text: "Nombre Completo"
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
                                width: parent.width * 0.15
                                height: parent.height
                                text: "Teléfono"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.25
                                height: parent.height
                                text: "Correo"
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
                            spacing: 0  // Sin espaciado entre columnas

                            // Columna ID
                            Rectangle {
                                width: parent.width * 0.05
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: agricultorId
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            // Columna Nombre Completo
                            Rectangle {
                                width: parent.width * 0.25
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: nombre + " " + apellido
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Identificación
                            Rectangle {
                                width: parent.width * 0.15
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: identificacion
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Teléfono
                            Rectangle {
                                width: parent.width * 0.15
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: telefono
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Correo
                            Rectangle {
                                width: parent.width * 0.25
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: correo
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Acciones
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
                                        onClicked: showMessage("Función de edición no implementada")
                                    }
                                    
                                    Button {
                                        width: 36
                                        height: 36
                                        icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                        flat: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Eliminar"
                                        onClicked: {
                                            // Mostrar diálogo de confirmación de eliminación
                                            confirmDeleteAgricultorDialog.agricultorId = agricultorId
                                            confirmDeleteAgricultorDialog.nombreAgricultor = nombre + " " + apellido
                                            confirmDeleteAgricultorDialog.open()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Mensaje cuando no hay datos
                    Text {
                        anchors.centerIn: parent
                        text: "No hay agricultores registrados.\nHaga clic en 'Nuevo Agricultor' para agregar uno."
                        color: "#757575"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        visible: agricultoresModel.count === 0
                    }
                }
            }
        }

        // Página de Parcelas
        Item {
            // Barra de acciones
            Rectangle {
                id: parcelasActionBar
                width: parent.width
                height: 50
                color: "white"
                radius: 25
                border.color: "#EEEEEE"

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 20
                    spacing: 10

                    Button {
                        text: "Nueva Parcela"
                        icon.source: "Image/Image_UI_interfaz/Inconos/agregar-documento.svg"
                        implicitHeight: 36
                        background: Rectangle {
                            color: "#f5922f"
                            radius: height / 2
                        }
                        onClicked: {
                            // Inicializa los valores para la nueva parcela
                            nuevaParcela = {
                                "parcelaId": "",
                                "nombre": "",
                                "propietario": "",
                                "ubicacion": "",
                                "area": 0,
                                "porcentajeUso": 0
                            }
                            
                            // Mostrar el diálogo de nueva parcela
                            dialogNuevaParcela.open()
                        }
                    }

                    TextField {
                        placeholderText: "Buscar parcela..."
                        implicitWidth: 250
                        implicitHeight: 36
                        background: Rectangle {
                            color: "#b2c4c9"
                            radius: height / 2
                        }
                    }

                    ComboBox {
                        model: ["Todos los agricultores"]
                        implicitWidth: 200
                        implicitHeight: 36
                    }
                }
            }

            // Tarjetas de parcelas (contenedor vacío)
            GridView {
                anchors.top: parcelasActionBar.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true
                model: agricultoresparcelas ? agricultoresparcelas.parcelasModel : null
                cellWidth: width / 3
                cellHeight: 200
                
                // Mensaje cuando no hay datos
                Text {
                    anchors.centerIn: parent
                    text: "No hay parcelas registradas.\nHaga clic en 'Nueva Parcela' para agregar una."
                    color: "#757575"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    visible: parcelasModel.count === 0
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

                        // Título de la parcela
                        Text {
                            text: nombre
                            font.pixelSize: 16
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        // Propietario
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "Propietario:"
                                font.pixelSize: 12
                                color: "#757575"
                            }

                            Text {
                                text: propietario
                                font.pixelSize: 12
                            }
                        }

                        // Ubicación
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "Ubicación:"
                                font.pixelSize: 12
                                color: "#757575"
                            }

                            Text {
                                text: ubicacion
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        // Área
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "Área:"
                                font.pixelSize: 12
                                color: "#757575"
                            }

                            Text {
                                text: area + " hectáreas"
                                font.pixelSize: 12
                            }
                        }

                        // Gráfico visual del uso de la parcela
                        Rectangle {
                            Layout.fillWidth: true
                            height: 20
                            color: "#F5F5F5"
                            radius: 10

                            Rectangle {
                                width: parent.width * porcentajeUso / 100
                                height: parent.height
                                color: "#2E7D32"
                                radius: 10
                            }

                            Text {
                                anchors.centerIn: parent
                                text: porcentajeUso + "% en uso"
                                font.pixelSize: 10
                                color: "white"
                            }
                        }

                        // Botones de acción
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 5
                            spacing: 10

                            Button {
                                text: "Ver Detalles"
                                Layout.fillWidth: true
                                implicitHeight: 30
                                font.pixelSize: 12
                                onClicked: showMessage("Función para ver detalles no implementada")
                            }

                            Button {
                                text: "Editar"
                                Layout.fillWidth: true
                                implicitHeight: 30
                                font.pixelSize: 12
                                onClicked: showMessage("Función para editar parcela no implementada")
                            }
                        }
                    }
                }
            }
        }

        // Página de Mapa
        Item {
            Rectangle {
                anchors.fill: parent
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                // Placeholder para el mapa
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 20
                    color: "#E0E0E0"

                    Text {
                        anchors.centerIn: parent
                        text: "Aquí se mostrará el mapa interactivo de parcelas"
                        font.pixelSize: 18
                        color: "#757575"
                    }

                    // Controles de mapa
                    Column {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 20
                        spacing: 10

                        Button {
                            text: "+"
                            font.pixelSize: 20
                            width: 40
                            height: 40
                        }

                        Button {
                            text: "-"
                            font.pixelSize: 20
                            width: 40
                            height: 40
                        }
                    }
                }
            }
        }
    }
    
    // DIÁLOGO DE NUEVO AGRICULTOR
    Dialog {
        id: dialogNuevoAgricultor
        title: "Nuevo Agricultor"
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
                    text: "Agregar Nuevo Agricultor"
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
                    
                    // Nombre
                    Text {
                        text: "Nombre:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtNombre
                        placeholderText: "Ingrese nombre"
                        Layout.fillWidth: true
                        onTextChanged: nuevoAgricultor.nombre = text
                    }
                    
                    // Apellido
                    Text {
                        text: "Apellido:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtApellido
                        placeholderText: "Ingrese apellido"
                        Layout.fillWidth: true
                        onTextChanged: nuevoAgricultor.apellido = text
                    }
                    
                    // Identificación
                    Text {
                        text: "Identificación:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtIdentificacion
                        placeholderText: "Ingrese número de identificación"
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: RegularExpressionValidator { regularExpression: /\d+/ }
                        onTextChanged: nuevoAgricultor.identificacion = text
                    }
                    
                    // Teléfono
                    Text {
                        text: "Teléfono:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtTelefono
                        placeholderText: "Ingrese número de teléfono"
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: RegularExpressionValidator { regularExpression: /\d+/ }
                        onTextChanged: nuevoAgricultor.telefono = text
                    }
                    
                    // Correo
                    Text {
                        text: "Correo electrónico:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtCorreo
                        placeholderText: "Ingrese correo electrónico"
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhEmailCharactersOnly
                        onTextChanged: nuevoAgricultor.correo = text
                    }
                    
                    // Es Propietario
                    Text {
                        text: "Es propietario:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    CheckBox {
                        id: chkPropietario
                        text: "Marcar como propietario de parcelas"
                        onCheckedChanged: nuevoAgricultor.esPropietario = checked
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
                }
                
                // Espacio adicional
                Item {
                    width: parent.width
                    height: 10
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionAgricultor
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
                onClicked: dialogNuevoAgricultor.close()
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
                    if (txtNombre.text === "" || txtApellido.text === "" || txtIdentificacion.text === "") {
                        mensajeValidacionAgricultor.text = "Por favor, complete al menos nombre, apellido e identificación";
                        return;
                    }
                    
                    // Validación de formato de correo electrónico
                    if (txtCorreo.text !== "") {
                        var emailRegex = /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
                        if (!emailRegex.test(txtCorreo.text)) {
                            mensajeValidacionAgricultor.text = "El formato del correo electrónico no es válido";
                            return;
                        }
                    }
                    
                    guardarNuevoAgricultor();
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            txtNombre.text = ""
            txtApellido.text = ""
            txtIdentificacion.text = ""
            txtTelefono.text = ""
            txtCorreo.text = ""
            chkPropietario.checked = false
            mensajeValidacionAgricultor.text = ""
        }
    }
    
    // DIÁLOGO DE NUEVA PARCELA
    Dialog {
        id: dialogNuevaParcela
        title: "Nueva Parcela"
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
                    text: "Agregar Nueva Parcela"
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
                    
                    // Nombre
                    Text {
                        text: "Nombre de la parcela:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtNombreParcela
                        placeholderText: "Ingrese nombre de la parcela"
                        Layout.fillWidth: true
                        onTextChanged: nuevaParcela.nombre = text
                    }
                    
                    // Propietario
                    Text {
                        text: "Propietario:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbPropietario
                        Layout.fillWidth: true
                        model: obtenerPropietariosModel()
                        onCurrentTextChanged: nuevaParcela.propietario = currentText
                    }
                    
                    // Ubicación
                    Text {
                        text: "Ubicación:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtUbicacion
                        placeholderText: "Ingrese ubicación o dirección"
                        Layout.fillWidth: true
                        onTextChanged: nuevaParcela.ubicacion = text
                    }
                    
                    // Área
                    Text {
                        text: "Área (hectáreas):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtArea
                        placeholderText: "Ej: 5.5"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: {
                            if (text.trim() !== "")
                                nuevaParcela.area = parseFloat(text)
                        }
                    }
                    
                    // Porcentaje de uso
                    Text {
                        text: "Porcentaje de uso (%):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    Slider {
                        id: sliderPorcentajeUso
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        stepSize: 1
                        value: 0
                        
                        Text {
                            anchors.top: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(parent.value) + "%"
                        }
                        
                        onValueChanged: nuevaParcela.porcentajeUso = Math.round(value)
                    }
                    
                    // Fecha de registro
                    Text {
                        text: "Fecha de registro:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaRegistroParcela
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
                        id: txtDescripcionParcela
                        placeholderText: "Descripción de la parcela (opcional)"
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
                    id: mensajeValidacionParcela
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
                onClicked: dialogNuevaParcela.close()
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
                    if (txtNombreParcela.text === "" || txtUbicacion.text === "" || txtArea.text === "") {
                        mensajeValidacionParcela.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    guardarNuevaParcela();
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            txtNombreParcela.text = ""
            txtUbicacion.text = ""
            txtArea.text = ""
            sliderPorcentajeUso.value = 0
            txtDescripcionParcela.text = ""
            mensajeValidacionParcela.text = ""
        }
    }
    
    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR AGRICULTOR
    Dialog {
        id: confirmDeleteAgricultorDialog
        title: "Confirmar eliminación"
        modal: true
        
        property int agricultorId: -1
        property string nombreAgricultor: ""
        
        contentItem: Item {
            implicitWidth: 400
            implicitHeight: 100
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    width: parent.width
                    text: "¿Está seguro que desea eliminar al agricultor '" + confirmDeleteAgricultorDialog.nombreAgricultor + "'?"
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
            var exito = agricultoresparcelas.eliminar_agricultor(agricultorId);
            if (exito) {
                showMessage("Agricultor eliminado correctamente")
            } else {
                showMessage("No se pudo eliminar el agricultor")
            }
        }     
    }
    
    // Modelos de datos vacíos
    ListModel {
        id: agricultoresModel
        // Se agregarán elementos cuando el usuario los cree
    }

    ListModel {
        id: parcelasModel
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
    function obtenerPropietariosModel() {
        var propietariosArray = [];
        if (agricultoresparcelas && agricultoresparcelas.propietarios) {
            for (var i = 0; i < agricultoresparcelas.propietarios.length; i++) {
                propietariosArray.push(agricultoresparcelas.propietarios[i].nombre);
            }
        }
        return propietariosArray;
    }

    function guardarNuevoAgricultor() {
        var agricultor_json = JSON.stringify(nuevoAgricultor);
        var exito = agricultoresparcelas.agregar_agricultor(agricultor_json);
        
        if (exito) {
            showMessage("Agricultor guardado correctamente");
            dialogNuevoAgricultor.close();
        } else {
            mensajeValidacionAgricultor.text = "Error al guardar el agricultor";
        }
    }

    function guardarNuevaParcela() {
        // Buscar el id del propietario seleccionado
        var propietarioId = -1;
        if (agricultoresparcelas && agricultoresparcelas.propietarios) {
            for (var i = 0; i < agricultoresparcelas.propietarios.length; i++) {
                if (agricultoresparcelas.propietarios[i].nombre === cmbPropietario.currentText) {
                    propietarioId = agricultoresparcelas.propietarios[i].id;
                    break;
                }
            }
        }
        
        nuevaParcela.propietarioId = propietarioId;
        var parcela_json = JSON.stringify(nuevaParcela);
        var exito = agricultoresparcelas.agregar_parcela(parcela_json);
        
        if (exito) {
            showMessage("Parcela guardada correctamente");
            dialogNuevaParcela.close();
        } else {
            mensajeValidacionParcela.text = "Error al guardar la parcela";
        }
    }   
    // Función para mostrar mensajes
    function showMessage(message) {
        messageToast.text = message
        messageToast.visible = true
        messageToastTimer.restart()
    }
}