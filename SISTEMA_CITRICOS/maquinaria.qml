import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: maquinariaRoot
    anchors.fill: parent
    color: "#F8F9FA"

    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "GESTIÓN DE EQUIPOS, COMBUSTIBLE Y MANTENIMIENTO"
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
            text: "Equipos"
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
            text: "Mantenimiento"
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
            text: "Combustible"
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

        // Página de Equipos
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                
                // Barra de acción
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Button {
                            text: "Nuevo Equipo"
                            implicitHeight: 36
                            onClicked: dialogNuevoEquipo.open()
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar equipo..."
                            implicitHeight: 36
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los tipos", "Tractor", "Fumigadora", "Bomba de riego"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Tabla de maquinaria
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: equiposListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            id: equiposModel
                        }
                        
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
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Código"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
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
                                    text: "Marca"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    text: "Combustible"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Estado"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
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
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: codigo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: nombre
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: tipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: marca
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    text: combustible
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 120
                                        height: 24
                                        radius: 12
                                        color: estado === "Operativo" ? "#4CAF50" : 
                                              estado === "En mantenimiento" ? "#FF9800" : "#F44336"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: estado
                                            font.pixelSize: 12
                                            color: "white"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Página de Mantenimiento
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                
                // Barra de acción
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Button {
                            text: "Nuevo Mantenimiento"
                            implicitHeight: 36
                            onClicked: dialogNuevoMantenimiento.open()
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar mantenimiento..."
                            implicitHeight: 36
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los equipos", "Tractor John Deere", "Fumigadora a Motor", "Bomba de Riego 10HP"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Tabla de mantenimientos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: mantenimientoListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            id: mantenimientoModel
                        }
                        
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
                                    text: "Equipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Tipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
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
                                    width: parent.width * 0.3
                                    height: parent.height
                                    text: "Descripción"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Costo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Estado"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
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
                                
                                Text {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    text: id
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: equipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: tipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: fecha
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.3
                                    height: parent.height
                                    text: descripcion
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Bs. " + costo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: estado
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    color: estado === "Completado" ? "#4CAF50" : "#FF9800"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Página de Combustible
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                
                // Barra de acción
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Button {
                            text: "Nueva Compra"
                            implicitHeight: 36
                            onClicked: dialogNuevoCombustible.open()
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los tipos", "Gasolina", "Diésel"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Indicadores de combustible
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 30
                        
                        // Gasolina consumo
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Consumo de Gasolina"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "210 litros"
                                font.pixelSize: 22
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "Último mes"
                                font.pixelSize: 12
                                color: "#757575"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                        
                        // Diésel consumo
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Consumo de Diésel"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "310 litros"
                                font.pixelSize: 22
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "Último mes"
                                font.pixelSize: 12
                                color: "#757575"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                        
                        // Gasto total
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Gasto Total"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "Bs. 5.460"
                                font.pixelSize: 22
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "Último mes"
                                font.pixelSize: 12
                                color: "#757575"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
                
                // Tabla de compras de combustible
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: combustibleListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            id: combustibleModel
                        }
                        
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Fecha"
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Precio Unitario"
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
                                    text: "Proveedor"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
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
                                
                                Text {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    text: id
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: tipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: fecha
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: cantidad + " " + unidad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Bs. " + precioUnitario
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Bs. " + total
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: proveedor
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // DIÁLOGO DE NUEVO EQUIPO
    Dialog {
        id: dialogNuevoEquipo
        title: "Nuevo Equipo"
        modal: true
        width: 500
        height: 480
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        // Variables para almacenar datos temporales
        property var nuevoEquipo: ({
            codigo: "",
            nombre: "",
            tipo: "",
            marca: "",
            combustible: "",
            estado: "Operativo"
        })
        
        // Función para generar un nuevo código
        function generarCodigo(tipo) {
            let prefijo = ""
            switch(tipo) {
                case "Tractor": prefijo = "TRA-"; break;
                case "Fumigadora": prefijo = "FUM-"; break;
                case "Bomba de riego": prefijo = "BOM-"; break;
                default: prefijo = "EQP-";
            }
            
            // Contar equipos existentes para este tipo
            let count = 0
            for(let i = 0; i < equiposModel.count; i++) {
                if(equiposModel.get(i).codigo.startsWith(prefijo)) {
                    count++
                }
            }
            
            // Generar nuevo código con número secuencial
            const nuevoNumero = (count + 1).toString().padStart(3, '0')
            return prefijo + nuevoNumero
        }
        
        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Título
                Text {
                    text: "Agregar Nuevo Equipo"
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
                    
                    // Tipo de equipo
                    Text {
                        text: "Tipo de equipo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbTipoEquipo
                        Layout.fillWidth: true
                        model: ["Tractor", "Fumigadora", "Bomba de riego", "Otro"]
                        onCurrentTextChanged: {
                            dialogNuevoEquipo.nuevoEquipo.tipo = currentText
                            if (currentText) {
                                txtCodigoEquipo.text = dialogNuevoEquipo.generarCodigo(currentText)
                            }
                        }
                    }
                    
                    // Código
                    Text {
                        text: "Código:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtCodigoEquipo
                        placeholderText: "Código automático"
                        Layout.fillWidth: true
                        readOnly: true
                        onTextChanged: dialogNuevoEquipo.nuevoEquipo.codigo = text
                    }
                    
                    // Nombre
                    Text {
                        text: "Nombre:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtNombreEquipo
                        placeholderText: "Ingrese nombre del equipo"
                        Layout.fillWidth: true
                        onTextChanged: dialogNuevoEquipo.nuevoEquipo.nombre = text
                    }
                    
                    // Marca
                    Text {
                        text: "Marca:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtMarcaEquipo
                        placeholderText: "Ingrese marca del equipo"
                        Layout.fillWidth: true
                        onTextChanged: dialogNuevoEquipo.nuevoEquipo.marca = text
                    }
                    
                    // Tipo de combustible
                    Text {
                        text: "Combustible:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbCombustibleEquipo
                        Layout.fillWidth: true
                        model: ["Gasolina", "Diésel", "Eléctrico", "Ninguno"]
                        onCurrentTextChanged: dialogNuevoEquipo.nuevoEquipo.combustible = currentText
                    }
                    
                    // Estado
                    Text {
                        text: "Estado:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbEstadoEquipo
                        Layout.fillWidth: true
                        model: ["Operativo", "En mantenimiento", "Fuera de servicio"]
                        onCurrentTextChanged: dialogNuevoEquipo.nuevoEquipo.estado = currentText
                    }
                    
                    // Observaciones
                    Text {
                        text: "Observaciones:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtObservacionesEquipo
                        placeholderText: "Observaciones adicionales (opcional)"
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        wrapMode: TextArea.Wrap
                    }
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionEquipo
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
                onClicked: dialogNuevoEquipo.close()
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
                    if (txtNombreEquipo.text === "" || cmbTipoEquipo.currentIndex < 0 || 
                        txtMarcaEquipo.text === "" || cmbCombustibleEquipo.currentIndex < 0) {
                        mensajeValidacionEquipo.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    // Agregar nuevo equipo al modelo
                    equiposModel.append({
                        codigo: dialogNuevoEquipo.nuevoEquipo.codigo,
                        nombre: dialogNuevoEquipo.nuevoEquipo.nombre,
                        tipo: dialogNuevoEquipo.nuevoEquipo.tipo,
                        marca: dialogNuevoEquipo.nuevoEquipo.marca,
                        combustible: dialogNuevoEquipo.nuevoEquipo.combustible,
                        estado: dialogNuevoEquipo.nuevoEquipo.estado
                    });
                    
                    // Cerrar diálogo
                    dialogNuevoEquipo.close();
                }
            }
        }
    }
    
    // DIÁLOGO DE NUEVO MANTENIMIENTO
    Dialog {
        id: dialogNuevoMantenimiento
        title: "Nuevo Mantenimiento"
        modal: true
        width: 500
        height: 550
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        // Variables para almacenar datos temporales
        property var nuevoMantenimiento: ({
            id: "",
            equipo: "",
            tipo: "",
            fecha: "",
            descripcion: "",
            costo: "",
            estado: "Programado"
        })
        
        // Función para generar un nuevo ID
        function generarID() {
            return (mantenimientoModel.count + 1).toString();
        }
        
        // Función para formatear la fecha actual
        function getFormattedDate() {
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
            var yyyy = today.getFullYear();
            return dd + '/' + mm + '/' + yyyy;
        }
        
        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Título
                Text {
                    text: "Agregar Nuevo Mantenimiento"
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
                    
                    // ID mantenimiento
                    Text {
                        text: "ID:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtIDMantenimiento
                        placeholderText: "ID automático"
                        Layout.fillWidth: true
                        text: dialogNuevoMantenimiento.generarID()
                        readOnly: true
                        onTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.id = text
                    }
                    
                    // Equipo
                    Text {
                        text: "Equipo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbEquipoMantenimiento
                        Layout.fillWidth: true
                        model: {
                            let equipos = []
                            for(let i = 0; i < equiposModel.count; i++) {
                                equipos.push(equiposModel.get(i).nombre)
                            }
                            return equipos
                        }
                        onCurrentTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.equipo = currentText
                    }
                    
                    // Tipo de mantenimiento
                    Text {
                        text: "Tipo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbTipoMantenimiento
                        Layout.fillWidth: true
                        model: ["Preventivo", "Correctivo", "Predictivo"]
                        onCurrentTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.tipo = currentText
                    }
                    
                    // Fecha
                    Text {
                        text: "Fecha:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaMantenimiento
                        placeholderText: "DD/MM/AAAA"
                        Layout.fillWidth: true
                        text: dialogNuevoMantenimiento.getFormattedDate()
                        onTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.fecha = text
                    }
                    
                    // Descripción
                    Text {
                        text: "Descripción:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtDescripcionMantenimiento
                        placeholderText: "Describa el mantenimiento a realizar"
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        wrapMode: TextArea.Wrap
                        onTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.descripcion = text
                    }
                    
                    // Costo
                    Text {
                        text: "Costo (Bs.):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtCostoMantenimiento
                        placeholderText: "Ingrese costo estimado"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.costo = text
                    }
                    
                    // Estado
                    Text {
                        text: "Estado:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbEstadoMantenimiento
                        Layout.fillWidth: true
                        model: ["Programado", "En progreso", "Completado"]
                        onCurrentTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.estado = currentText
                    }
                    
                    // Técnico responsable
                    Text {
                        text: "Técnico responsable:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtTecnicoMantenimiento
                        placeholderText: "Nombre del técnico (opcional)"
                        Layout.fillWidth: true
                    }
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionMantenimiento
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
                onClicked: dialogNuevoMantenimiento.close()
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
                    if (cmbEquipoMantenimiento.currentIndex < 0 || cmbTipoMantenimiento.currentIndex < 0 || 
                        txtFechaMantenimiento.text === "" || txtDescripcionMantenimiento.text === "" ||
                        txtCostoMantenimiento.text === "") {
                        mensajeValidacionMantenimiento.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    // Agregar nuevo mantenimiento al modelo
                    mantenimientoModel.append({
                        id: dialogNuevoMantenimiento.nuevoMantenimiento.id,
                        equipo: dialogNuevoMantenimiento.nuevoMantenimiento.equipo,
                        tipo: dialogNuevoMantenimiento.nuevoMantenimiento.tipo,
                        fecha: dialogNuevoMantenimiento.nuevoMantenimiento.fecha,
                        descripcion: dialogNuevoMantenimiento.nuevoMantenimiento.descripcion,
                        costo: dialogNuevoMantenimiento.nuevoMantenimiento.costo,
                        estado: dialogNuevoMantenimiento.nuevoMantenimiento.estado
                    });
                    
                    // Cerrar diálogo
                    dialogNuevoMantenimiento.close();
                }
            }
        }
    }
    
    // DIÁLOGO DE NUEVA COMPRA DE COMBUSTIBLE
    Dialog {
        id: dialogNuevoCombustible
        title: "Nueva Compra de Combustible"
        modal: true
        width: 500
        height: 500
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        // Variables para almacenar datos temporales
        property var nuevaCompra: ({
            id: "",
            tipo: "",
            fecha: "",
            cantidad: "",
            unidad: "Litros",
            precioUnitario: "",
            total: "",
            proveedor: ""
        })
        
        // Función para generar un nuevo ID
        function generarID() {
            return (combustibleModel.count + 1).toString();
        }
        
        // Función para formatear la fecha actual
        function getFormattedDate() {
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
            var yyyy = today.getFullYear();
            return dd + '/' + mm + '/' + yyyy;
        }
        
        // Función para calcular el total
        function calcularTotal() {
            if (txtCantidadCombustible.text !== "" && txtPrecioUnitarioCombustible.text !== "") {
                const cantidad = parseFloat(txtCantidadCombustible.text);
                const precioUnitario = parseFloat(txtPrecioUnitarioCombustible.text);
                
                if (!isNaN(cantidad) && !isNaN(precioUnitario)) {
                    const total = (cantidad * precioUnitario).toFixed(2);
                    txtTotalCombustible.text = total;
                    dialogNuevoCombustible.nuevaCompra.total = total;
                }
            }
        }
        
        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Título
                Text {
                    text: "Registrar Nueva Compra de Combustible"
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
                    
                    // ID compra
                    Text {
                        text: "ID:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtIDCombustible
                        placeholderText: "ID automático"
                        Layout.fillWidth: true
                        text: dialogNuevoCombustible.generarID()
                        readOnly: true
                        onTextChanged: dialogNuevoCombustible.nuevaCompra.id = text
                    }
                    
                    // Tipo de combustible
                    Text {
                        text: "Tipo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbTipoCombustible
                        Layout.fillWidth: true
                        model: ["Gasolina", "Diésel"]
                        onCurrentTextChanged: dialogNuevoCombustible.nuevaCompra.tipo = currentText
                    }
                    
                    // Fecha de compra
                    Text {
                        text: "Fecha:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaCombustible
                        placeholderText: "DD/MM/AAAA"
                        Layout.fillWidth: true
                        text: dialogNuevoCombustible.getFormattedDate()
                        onTextChanged: dialogNuevoCombustible.nuevaCompra.fecha = text
                    }
                    
                    // Cantidad
                    Text {
                        text: "Cantidad:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtCantidadCombustible
                        placeholderText: "Ingrese cantidad"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: {
                            dialogNuevoCombustible.nuevaCompra.cantidad = text
                            dialogNuevoCombustible.calcularTotal()
                        }
                    }
                    
                    // Unidad
                    Text {
                        text: "Unidad:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbUnidadCombustible
                        Layout.fillWidth: true
                        model: ["Litros", "Galones"]
                        onCurrentTextChanged: dialogNuevoCombustible.nuevaCompra.unidad = currentText
                    }
                    
                    // Precio unitario
                    Text {
                        text: "Precio unitario (Bs.):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtPrecioUnitarioCombustible
                        placeholderText: "Precio por unidad"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: {
                            dialogNuevoCombustible.nuevaCompra.precioUnitario = text
                            dialogNuevoCombustible.calcularTotal()
                        }
                    }
                    
                    // Total
                    Text {
                        text: "Total (Bs.):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtTotalCombustible
                        placeholderText: "Cálculo automático"
                        Layout.fillWidth: true
                        readOnly: true
                        onTextChanged: dialogNuevoCombustible.nuevaCompra.total = text
                    }
                    
                    // Proveedor
                    Text {
                        text: "Proveedor:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtProveedorCombustible
                        placeholderText: "Nombre del proveedor"
                        Layout.fillWidth: true
                        onTextChanged: dialogNuevoCombustible.nuevaCompra.proveedor = text
                    }
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionCombustible
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
                onClicked: dialogNuevoCombustible.close()
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
                    if (cmbTipoCombustible.currentIndex < 0 || txtFechaCombustible.text === "" || 
                        txtCantidadCombustible.text === "" || txtPrecioUnitarioCombustible.text === "" || 
                        txtProveedorCombustible.text === "") {
                        mensajeValidacionCombustible.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    // Agregar nueva compra de combustible al modelo
                    combustibleModel.append({
                        id: dialogNuevoCombustible.nuevaCompra.id,
                        tipo: dialogNuevoCombustible.nuevaCompra.tipo,
                        fecha: dialogNuevoCombustible.nuevaCompra.fecha,
                        cantidad: dialogNuevoCombustible.nuevaCompra.cantidad,
                        unidad: dialogNuevoCombustible.nuevaCompra.unidad,
                        precioUnitario: dialogNuevoCombustible.nuevaCompra.precioUnitario,
                        total: dialogNuevoCombustible.nuevaCompra.total,
                        proveedor: dialogNuevoCombustible.nuevaCompra.proveedor
                    });
                    
                    // Cerrar diálogo
                    dialogNuevoCombustible.close();
                }
            }
        }
    }
}