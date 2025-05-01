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
                            onClicked: {
                                dialogNuevoEquipo.nuevoEquipo = {
                                    codigo: "",
                                    nombre: "",
                                    tipo: "",
                                    marca: "",
                                    tipo_combustible: "",
                                    estado: "Operativo"
                                };
                                dialogNuevoEquipo.open();
                            }
                        }
                        
                        TextField {
                            id: txtBuscarEquipo
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar equipo..."
                            implicitHeight: 36
                            onTextChanged: {
                                // Filtrar equipos por nombre o código
                                filtrarMaquinaria(text);
                            }
                        }
                        
                        ComboBox {
                            id: cmbFiltroTipoEquipo
                            Layout.preferredWidth: 200
                            model: ["Todos los tipos", "Tractor", "Fumigadora", "Bomba de riego"]
                            implicitHeight: 36
                            onCurrentTextChanged: {
                                // Filtrar por tipo de equipo
                                filtrarMaquinaria(txtBuscarEquipo.text);
                            }
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Estado"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    text: "Acciones"
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
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    equiposListView.currentIndex = index;
                                }
                            }
                            
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
                                    text: tipo_combustible || ""
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.15
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
                                
                                // Botones de acción
                                Row {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    spacing: 5
                                    
                                    Button {
                                        width: 30
                                        height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "✏️"
                                        onClicked: {
                                            editarMaquinaria(index);
                                        }
                                    }
                                    
                                    Button {
                                        width: 30
                                        height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "🗑️"
                                        onClicked: {
                                            eliminarMaquinaria(id_maquinaria);
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando la lista está vacía
                        Text {
                            anchors.centerIn: parent
                            text: "No hay equipos registrados. Haga clic en 'Nuevo Equipo' para agregar uno."
                            visible: equiposListView.count === 0
                            color: "#757575"
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
                            onClicked: {
                                dialogNuevoMantenimiento.nuevoMantenimiento = {
                                    id_mantenimiento: "",
                                    id_maquinaria: "",
                                    tipo: "Preventivo",
                                    fecha_realizada: new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd"),
                                    descripcion: "",
                                    costo_total: "",
                                    responsable: 1, // ID de usuario actual
                                    estado: "Programado"
                                };
                                dialogNuevoMantenimiento.open();
                            }
                        }
                        
                        TextField {
                            id: txtBuscarMantenimiento
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar mantenimiento..."
                            implicitHeight: 36
                            onTextChanged: {
                                // Filtrar mantenimientos
                                filtrarMantenimientos(text);
                            }
                        }
                        
                        ComboBox {
                            id: cmbFiltroEquipoMantenimiento
                            Layout.preferredWidth: 200
                            model: obtenerNombresMaquinaria()
                            implicitHeight: 36
                            onCurrentTextChanged: {
                                // Filtrar por equipo
                                filtrarMantenimientos(txtBuscarMantenimiento.text);
                            }
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
                                    width: parent.width * 0.25
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
                                
                                Text {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    text: "Acciones"
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
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mantenimientoListView.currentIndex = index;
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                
                                Text {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    text: id_mantenimiento
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: nombre_maquinaria
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
                                    text: fecha_realizada || "Pendiente"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: descripcion
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Bs. " + costo_total.toFixed(2)
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
                                
                                // Botones de acción
                                Row {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    spacing: 5
                                    
                                    Button {
                                        width: 30
                                        height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "✏️"
                                        onClicked: {
                                            editarMantenimiento(index);
                                        }
                                    }
                                    
                                    Button {
                                        width: 30
                                        height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: estado === "Programado" ? "✓" : "🗑️" 
                                        onClicked: {
                                            if (estado === "Programado") {
                                                completarMantenimiento(id_mantenimiento);
                                            } else {
                                                eliminarMantenimiento(id_mantenimiento);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando la lista está vacía
                        Text {
                            anchors.centerIn: parent
                            text: "No hay mantenimientos registrados. Haga clic en 'Nuevo Mantenimiento' para agregar uno."
                            visible: mantenimientoListView.count === 0
                            color: "#757575"
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
                            onClicked: {
                                dialogNuevoCombustible.nuevaCompra = {
                                    id_compra: "",
                                    tipo_combustible: "Gasolina",
                                    fecha_compra: new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd"),
                                    cantidad: "",
                                    unidad_medida: "Litros",
                                    precio_unitario: "",
                                    precio_total: "",
                                    proveedor: "",
                                    responsable: 1, // ID usuario actual
                                    observaciones: ""
                                };
                                dialogNuevoCombustible.open();
                            }
                        }
                        
                        ComboBox {
                            id: cmbFiltroTipoCombustible
                            Layout.preferredWidth: 200
                            model: ["Todos los tipos", "Gasolina", "Diésel"]
                            implicitHeight: 36
                            onCurrentTextChanged: {
                                // Filtrar por tipo de combustible
                                filtrarComprasCombustible();
                            }
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
                                id: txtConsumoGasolina
                                text: "0 litros"
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
                                id: txtConsumoDiesel
                                text: "0 litros"
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
                                id: txtGastoTotal
                                text: "Bs. 0"
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
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Proveedor"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    text: "Acciones"
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
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    combustibleListView.currentIndex = index;
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                
                                
                                Text {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    text: id_compra
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: tipo_combustible
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: fecha_compra
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: cantidad.toFixed(2) + " " + unidad_medida
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Bs. " + precio_unitario.toFixed(2)
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Bs. " + precio_total.toFixed(2)
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: proveedor || ""
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                }
                                
                                // Botones de acción
                                Row {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    spacing: 5
                                    
                                    Button {
                                        width: 30
                                        height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "✏️"
                                        onClicked: {
                                            editarCompraCombustible(index);
                                        }
                                    }
                                    
                                    Button {
                                        width: 30
                                        height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "🗑️"
                                        onClicked: {
                                            eliminarCompraCombustible(id_compra);
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando la lista está vacía
                        Text {
                            anchors.centerIn: parent
                            text: "No hay compras de combustible registradas. Haga clic en 'Nueva Compra' para agregar una."
                            visible: combustibleListView.count === 0
                            color: "#757575"
                        }
                    }
                }
            }
        }
    }
    
    // Funciones para manipulación de datos
    
    // Función para cargar los datos de maquinaria desde el modelo al ListModel
    function cargarMaquinariaDesdeModelo() {
        equiposModel.clear();
        var maquinarias = maquinariaModel.maquinaria;
        for (var i = 0; i < maquinarias.length; i++) {
            var maquina = maquinarias[i];
            equiposModel.append({
                id_maquinaria: maquina.id_maquinaria,
                codigo: maquina.codigo,
                nombre: maquina.nombre,
                tipo: maquina.tipo,
                marca: maquina.marca,
                tipo_combustible: maquina.tipo_combustible,
                estado: maquina.estado,
                ubicacion_actual: maquina.ubicacion_actual,
                activo: maquina.activo
            });
        }
    }
    
    // Función para cargar los datos de mantenimientos desde el modelo al ListModel
    function cargarMantenimientosDesdeModelo() {
        mantenimientoModel.clear();
        var mantenimientos = maquinariaModel.mantenimientos;
        for (var i = 0; i < mantenimientos.length; i++) {
            var mantenimiento = mantenimientos[i];
            mantenimientoModel.append({
                id_mantenimiento: mantenimiento.id_mantenimiento,
                id_maquinaria: mantenimiento.id_maquinaria,
                nombre_maquinaria: mantenimiento.nombre_maquinaria,
                tipo: mantenimiento.tipo,
                fecha_realizada: mantenimiento.fecha_realizada,
                descripcion: mantenimiento.descripcion,
                costo_total: mantenimiento.costo_total,
                responsable: mantenimiento.responsable,
                nombre_responsable: mantenimiento.nombre_responsable,
                estado: mantenimiento.estado
            });
        }
    }
    
    // Función para cargar los datos de compras de combustible desde el modelo al ListModel
    function cargarComprasCombustibleDesdeModelo() {
        combustibleModel.clear();
        var compras = maquinariaModel.compras;
        for (var i = 0; i < compras.length; i++) {
            var compra = compras[i];
            combustibleModel.append({
                id_compra: compra.id_compra,
                tipo_combustible: compra.tipo_combustible,
                fecha_compra: compra.fecha_compra,
                cantidad: compra.cantidad,
                unidad_medida: compra.unidad_medida,
                precio_unitario: compra.precio_unitario,
                precio_total: compra.precio_total,
                proveedor: compra.proveedor,
                responsable: compra.responsable,
                nombre_responsable: compra.nombre_responsable,
                observaciones: compra.observaciones
            });
        }
        actualizarResumenCombustible();
    }
    
    // Función para actualizar el resumen de combustible en los textos
    function actualizarResumenCombustible() {
        var resumen = maquinariaModel.resumen_combustible;
        var consumoGasolina = 0;
        var consumoDiesel = 0;
        var gastoTotal = 0;
        
        // Calcular consumos y gastos
        if (resumen["Gasolina"]) {
            consumoGasolina = resumen["Gasolina"].total_cantidad || 0;
            gastoTotal += resumen["Gasolina"].total_costo || 0;
        }
        
        if (resumen["Diésel"]) {
            consumoDiesel = resumen["Diésel"].total_cantidad || 0;
            gastoTotal += resumen["Diésel"].total_costo || 0;
        }
        
        // Actualizar los textos
        txtConsumoGasolina.text = consumoGasolina.toFixed(2) + " litros";
        txtConsumoDiesel.text = consumoDiesel.toFixed(2) + " litros";
        txtGastoTotal.text = "Bs. " + gastoTotal.toFixed(2);
    }
    
    // Función para filtrar maquinaria
    function filtrarMaquinaria(texto) {
        var tipo = cmbFiltroTipoEquipo.currentText;
        equiposModel.clear();
        
        var maquinarias = maquinariaModel.maquinaria;
        for (var i = 0; i < maquinarias.length; i++) {
            var maquina = maquinarias[i];
            
            // Aplicar filtro de tipo
            if (tipo !== "Todos los tipos" && maquina.tipo !== tipo) {
                continue;
            }
            
            // Aplicar filtro de texto
            if (texto && !(
                maquina.codigo.toLowerCase().includes(texto.toLowerCase()) ||
                maquina.nombre.toLowerCase().includes(texto.toLowerCase())
            )) {
                continue;
            }
            
            equiposModel.append({
                id_maquinaria: maquina.id_maquinaria,
                codigo: maquina.codigo,
                nombre: maquina.nombre,
                tipo: maquina.tipo,
                marca: maquina.marca,
                tipo_combustible: maquina.tipo_combustible,
                estado: maquina.estado,
                ubicacion_actual: maquina.ubicacion_actual,
                activo: maquina.activo
            });
        }
    }
    
    // Función para filtrar mantenimientos
    function filtrarMantenimientos(texto) {
        var equipoSeleccionado = cmbFiltroEquipoMantenimiento.currentText;
        mantenimientoModel.clear();
        
        var mantenimientos = maquinariaModel.mantenimientos;
        for (var i = 0; i < mantenimientos.length; i++) {
            var mantenimiento = mantenimientos[i];
            
            // Aplicar filtro de equipo
            if (equipoSeleccionado !== "Todos los equipos" && mantenimiento.nombre_maquinaria !== equipoSeleccionado) {
                continue;
            }
            
            // Aplicar filtro de texto
            if (texto && !(
                mantenimiento.descripcion.toLowerCase().includes(texto.toLowerCase()) ||
                (mantenimiento.nombre_responsable && mantenimiento.nombre_responsable.toLowerCase().includes(texto.toLowerCase()))
            )) {
                continue;
            }
            
            mantenimientoModel.append({
                id_mantenimiento: mantenimiento.id_mantenimiento,
                id_maquinaria: mantenimiento.id_maquinaria,
                nombre_maquinaria: mantenimiento.nombre_maquinaria,
                tipo: mantenimiento.tipo,
                fecha_realizada: mantenimiento.fecha_realizada,
                descripcion: mantenimiento.descripcion,
                costo_total: mantenimiento.costo_total,
                responsable: mantenimiento.responsable,
                nombre_responsable: mantenimiento.nombre_responsable,
                estado: mantenimiento.estado
            });
        }
    }
    
    
    
    // Funciones para editar y eliminar
    function editarMaquinaria(index) {
        var item = equiposModel.get(index);
        dialogNuevoEquipo.nuevoEquipo = {
            id_maquinaria: item.id_maquinaria,
            codigo: item.codigo,
            nombre: item.nombre,
            tipo: item.tipo,
            marca: item.marca,
            tipo_combustible: item.tipo_combustible,
            estado: item.estado,
            ubicacion_actual: item.ubicacion_actual,
            activo: item.activo
        };
        
        // Establecer valores en los campos del diálogo
        txtCodigoEquipo.text = item.codigo;
        txtNombreEquipo.text = item.nombre;
        txtMarcaEquipo.text = item.marca;
        
        // Establecer índices en los combos
        for (var i = 0; i < cmbTipoEquipo.model.length; i++) {
            if (cmbTipoEquipo.model[i] === item.tipo) {
                cmbTipoEquipo.currentIndex = i;
                break;
            }
        }
        
        for (var j = 0; j < cmbCombustibleEquipo.model.length; j++) {
            if (cmbCombustibleEquipo.model[j] === item.tipo_combustible) {
                cmbCombustibleEquipo.currentIndex = j;
                break;
            }
        }
        
        for (var k = 0; k < cmbEstadoEquipo.model.length; k++) {
            if (cmbEstadoEquipo.model[k] === item.estado) {
                cmbEstadoEquipo.currentIndex = k;
                break;
            }
        }
        
        dialogNuevoEquipo.open();
    }
    
    function eliminarMaquinaria(id_maquinaria) {
        var confirmDialog = Qt.createComponent("qrc:/components/ConfirmDialog.qml").createObject(maquinariaRoot, {
            title: "Eliminar equipo",
            message: "¿Está seguro que desea eliminar este equipo? Esta acción no se puede deshacer.",
            confirmButtonText: "Eliminar",
            cancelButtonText: "Cancelar"
        });
        
        confirmDialog.confirmed.connect(function() {
            if (maquinariaModel.desactivar_maquinaria(id_maquinaria)) {
                maquinariaModel.cargar_maquinaria();
                cargarMaquinariaDesdeModelo();
            }
        });
        
        confirmDialog.open();
    }
    
    function editarMantenimiento(index) {
        var item = mantenimientoModel.get(index);
        dialogNuevoMantenimiento.nuevoMantenimiento = {
            id_mantenimiento: item.id_mantenimiento,
            id_maquinaria: item.id_maquinaria,
            nombre_maquinaria: item.nombre_maquinaria,
            tipo: item.tipo,
            fecha_realizada: item.fecha_realizada,
            descripcion: item.descripcion,
            costo_total: item.costo_total,
            responsable: item.responsable,
            estado: item.estado
        };
        
        // Establecer valores en los campos del diálogo
        txtIDMantenimiento.text = item.id_mantenimiento;
        txtDescripcionMantenimiento.text = item.descripcion;
        txtCostoMantenimiento.text = item.costo_total;
        
        if (item.fecha_realizada) {
            txtFechaMantenimiento.text = item.fecha_realizada;
        }
        
        // Establecer índices en los combos
        for (var i = 0; i < cmbEquipoMantenimiento.model.length; i++) {
            if (cmbEquipoMantenimiento.model[i] === item.nombre_maquinaria) {
                cmbEquipoMantenimiento.currentIndex = i;
                break;
            }
        }
        
        for (var j = 0; j < cmbTipoMantenimiento.model.length; j++) {
            if (cmbTipoMantenimiento.model[j] === item.tipo) {
                cmbTipoMantenimiento.currentIndex = j;
                break;
            }
        }
        
        for (var k = 0; k < cmbEstadoMantenimiento.model.length; k++) {
            if (cmbEstadoMantenimiento.model[k] === item.estado) {
                cmbEstadoMantenimiento.currentIndex = k;
                break;
            }
        }
        
        dialogNuevoMantenimiento.open();
    }
    
    function completarMantenimiento(id_mantenimiento) {
        var confirmDialog = Qt.createComponent("qrc:/components/ConfirmDialog.qml").createObject(maquinariaRoot, {
            title: "Completar mantenimiento",
            message: "¿Marcar este mantenimiento como completado?",
            confirmButtonText: "Completar",
            cancelButtonText: "Cancelar"
        });
        
        confirmDialog.confirmed.connect(function() {
            var mantenimientoData = {
                estado: "Completado",
                fecha_realizada: new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd")
            };
            
            if (maquinariaModel.actualizar_mantenimiento(id_mantenimiento, JSON.stringify(mantenimientoData))) {
                maquinariaModel.cargar_mantenimientos();
                maquinariaModel.cargar_maquinaria();
                cargarMantenimientosDesdeModelo();
                cargarMaquinariaDesdeModelo();
            }
        });
        
        confirmDialog.open();
    }
    
    function eliminarMantenimiento(id_mantenimiento) {
        var confirmDialog = Qt.createComponent("qrc:/components/ConfirmDialog.qml").createObject(maquinariaRoot, {
            title: "Eliminar mantenimiento",
            message: "¿Está seguro que desea eliminar este registro de mantenimiento? Esta acción no se puede deshacer.",
            confirmButtonText: "Eliminar",
            cancelButtonText: "Cancelar"
        });
        
        confirmDialog.confirmed.connect(function() {
            // Aquí iría la llamada a la función de eliminar mantenimiento cuando exista en el modelo
            // Por ahora solo recargamos los datos
            maquinariaModel.cargar_mantenimientos();
            cargarMantenimientosDesdeModelo();
        });
        
        confirmDialog.open();
    }
    
    function editarCompraCombustible(index) {
        var item = combustibleModel.get(index);
        dialogNuevoCombustible.nuevaCompra = {
            id_compra: item.id_compra,
            tipo_combustible: item.tipo_combustible,
            fecha_compra: item.fecha_compra,
            cantidad: item.cantidad,
            unidad_medida: item.unidad_medida,
            precio_unitario: item.precio_unitario,
            precio_total: item.precio_total,
            proveedor: item.proveedor,
            responsable: item.responsable,
            observaciones: item.observaciones
        };
        
        // Establecer valores en los campos del diálogo
        txtIDCombustible.text = item.id_compra;
        txtFechaCombustible.text = item.fecha_compra;
        txtCantidadCombustible.text = item.cantidad;
        txtPrecioUnitarioCombustible.text = item.precio_unitario;
        txtTotalCombustible.text = item.precio_total;
        txtProveedorCombustible.text = item.proveedor || "";
        
        // Establecer índices en los combos
        for (var i = 0; i < cmbTipoCombustible.model.length; i++) {
            if (cmbTipoCombustible.model[i] === item.tipo_combustible) {
                cmbTipoCombustible.currentIndex = i;
                break;
            }
        }
        
        for (var j = 0; j < cmbUnidadCombustible.model.length; j++) {
            if (cmbUnidadCombustible.model[j] === item.unidad_medida) {
                cmbUnidadCombustible.currentIndex = j;
                break;
            }
        }
        
        dialogNuevoCombustible.open();
    }
    
    function eliminarCompraCombustible(id_compra) {
        var confirmDialog = Qt.createComponent("qrc:/components/ConfirmDialog.qml").createObject(maquinariaRoot, {
            title: "Eliminar compra",
            message: "¿Está seguro que desea eliminar este registro de compra de combustible? Esta acción no se puede deshacer.",
            confirmButtonText: "Eliminar",
            cancelButtonText: "Cancelar"
        });
        
        confirmDialog.confirmed.connect(function() {
            if (maquinariaModel.eliminar_compra_combustible(id_compra)) {
                maquinariaModel.cargar_compras_combustible();
                maquinariaModel.cargar_resumen_combustible();
                cargarComprasCombustibleDesdeModelo();
            }
        });
        
        confirmDialog.open();
    }
    
    // DIÁLOGO DE NUEVO EQUIPO
    Dialog {
        id: dialogNuevoEquipo
        title: "Nuevo Equipo"
        modal: true
        width: 500
        height: 600
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        // Variables para almacenar datos temporales
        property var nuevoEquipo: ({
            codigo: "",
            nombre: "",
            tipo: "",
            marca: "",
            tipo_combustible: "",
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
                    text: dialogNuevoEquipo.nuevoEquipo.id_maquinaria ? "Editar Equipo" : "Agregar Nuevo Equipo"
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
                            if (currentText && !dialogNuevoEquipo.nuevoEquipo.id_maquinaria) {
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
                        readOnly: dialogNuevoEquipo.nuevoEquipo.id_maquinaria ? true : false
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
                        onCurrentTextChanged: dialogNuevoEquipo.nuevoEquipo.tipo_combustible = currentText
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
                    
                    // Ubicación actual
                    Text {
                        text: "Ubicación actual:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtUbicacionEquipo
                        placeholderText: "Ingrese ubicación actual del equipo"
                        Layout.fillWidth: true
                        onTextChanged: dialogNuevoEquipo.nuevoEquipo.ubicacion_actual = text
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
                    
                    // Preparar los datos para enviar al modelo
                    var maquinariaData = {
                        codigo: dialogNuevoEquipo.nuevoEquipo.codigo,
                        nombre: dialogNuevoEquipo.nuevoEquipo.nombre,
                        tipo: dialogNuevoEquipo.nuevoEquipo.tipo,
                        marca: dialogNuevoEquipo.nuevoEquipo.marca,
                        tipo_combustible: dialogNuevoEquipo.nuevoEquipo.tipo_combustible,
                        estado: dialogNuevoEquipo.nuevoEquipo.estado,
                        ubicacion_actual: dialogNuevoEquipo.nuevoEquipo.ubicacion_actual
                    };
                    
                    var success = false;
                    if (dialogNuevoEquipo.nuevoEquipo.id_maquinaria) {
                        // Actualizar maquinaria existente
                        success = maquinariaModel.actualizar_maquinaria(
                            dialogNuevoEquipo.nuevoEquipo.id_maquinaria, 
                            JSON.stringify(maquinariaData)
                        );
                    } else {
                        // Agregar nueva maquinaria
                        success = maquinariaModel.agregar_maquinaria(JSON.stringify(maquinariaData));
                    }
                    
                    if (success) {
                        // Recargar los datos
                        maquinariaModel.cargar_maquinaria();
                        cargarMaquinariaDesdeModelo();
                        dialogNuevoEquipo.close();
                    } else {
                        mensajeValidacionEquipo.text = "Error al guardar el equipo. Intente nuevamente.";
                    }
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
        height: 600
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        // Variables para almacenar datos temporales
        property var nuevoMantenimiento: ({
            id_mantenimiento: "",
            id_maquinaria: "",
            tipo: "Preventivo",
            fecha_realizada: "",
            descripcion: "",
            costo_total: "",
            responsable: 1,
            estado: "Programado"
        })
        
        // Función para obtener ID de maquinaria por nombre
        function obtenerIdMaquinariaPorNombre(nombre) {
            var maquinarias = maquinariaModel.maquinaria;
            for (var i = 0; i < maquinarias.length; i++) {
                if (maquinarias[i].nombre === nombre) {
                    return maquinarias[i].id_maquinaria;
                }
            }
            return null;
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
                    text: dialogNuevoMantenimiento.nuevoMantenimiento.id_mantenimiento ? "Editar Mantenimiento" : "Agregar Nuevo Mantenimiento"
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
                    
                    // ID mantenimiento (solo visible en edición)
                    Text {
                        text: "ID:"
                        Layout.alignment: Qt.AlignRight
                        visible: dialogNuevoMantenimiento.nuevoMantenimiento.id_mantenimiento !== ""
                    }
                    
                    TextField {
                        id: txtIDMantenimiento
                        placeholderText: "ID automático"
                        Layout.fillWidth: true
                        readOnly: true
                        visible: dialogNuevoMantenimiento.nuevoMantenimiento.id_mantenimiento !== ""
                    }
                    
                    // Equipo
                    Text {
                        text: "Equipo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbEquipoMantenimiento
                        Layout.fillWidth: true
                        model: obtenerNombresMaquinaria().filter(function(item) { return item !== "Todos los equipos"; })
                        onCurrentTextChanged: {
                            var id = dialogNuevoMantenimiento.obtenerIdMaquinariaPorNombre(currentText);
                            if (id) {
                                dialogNuevoMantenimiento.nuevoMantenimiento.id_maquinaria = id;
                                dialogNuevoMantenimiento.nuevoMantenimiento.nombre_maquinaria = currentText;
                            }
                        }
                    }
                    
                    // Tipo de mantenimiento
                    Text {
                        text: "Tipo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbTipoMantenimiento
                        Layout.fillWidth: true
                        model: ["Preventivo", "Correctivo"]
                        onCurrentTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.tipo = currentText
                    }
                    
                    // Fecha
                    Text {
                        text: "Fecha:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaMantenimiento
                        placeholderText: "YYYY-MM-DD"
                        Layout.fillWidth: true
                        text: new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd")
                        onTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.fecha_realizada = text
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
                        onTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.costo_total = parseFloat(text)
                    }
                    
                    // Estado
                    Text {
                        text: "Estado:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbEstadoMantenimiento
                        Layout.fillWidth: true
                        model: ["Programado", "Completado"]
                        onCurrentTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.estado = currentText
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
                    if (!dialogNuevoMantenimiento.nuevoMantenimiento.id_maquinaria || 
                        !dialogNuevoMantenimiento.nuevoMantenimiento.tipo || 
                        txtDescripcionMantenimiento.text === "" ||
                        txtCostoMantenimiento.text === "") {
                        mensajeValidacionMantenimiento.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    // Preparar los datos para enviar al modelo
                    var mantenimientoData = {
                        id_maquinaria: dialogNuevoMantenimiento.nuevoMantenimiento.id_maquinaria,
                        tipo: dialogNuevoMantenimiento.nuevoMantenimiento.tipo,
                        fecha_realizada: dialogNuevoMantenimiento.nuevoMantenimiento.estado === "Programado" ? null : dialogNuevoMantenimiento.nuevoMantenimiento.fecha_realizada,
                        descripcion: dialogNuevoMantenimiento.nuevoMantenimiento.descripcion,
                        costo_total: parseFloat(dialogNuevoMantenimiento.nuevoMantenimiento.costo_total),
                        responsable: dialogNuevoMantenimiento.nuevoMantenimiento.responsable,
                        estado: dialogNuevoMantenimiento.nuevoMantenimiento.estado
                    };
                    
                    var success = false;
                    if (dialogNuevoMantenimiento.nuevoMantenimiento.id_mantenimiento) {
                        // Actualizar mantenimiento existente
                        success = maquinariaModel.actualizar_mantenimiento(
                            dialogNuevoMantenimiento.nuevoMantenimiento.id_mantenimiento, 
                            JSON.stringify(mantenimientoData)
                        );
                    } else {
                        // Agregar nuevo mantenimiento
                        success = maquinariaModel.registrar_mantenimiento(JSON.stringify(mantenimientoData));
                    }
                    
                    if (success) {
                        // Recargar los datos
                        maquinariaModel.cargar_mantenimientos();
                        maquinariaModel.cargar_maquinaria();
                        cargarMantenimientosDesdeModelo();
                        cargarMaquinariaDesdeModelo();
                        dialogNuevoMantenimiento.close();
                    } else {
                        mensajeValidacionMantenimiento.text = "Error al guardar el mantenimiento. Intente nuevamente.";
                    }
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
        height: 600
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        // Variables para almacenar datos temporales
        property var nuevaCompra: ({
            id_compra: "",
            tipo_combustible: "Gasolina",
            fecha_compra: "",
            cantidad: "",
            unidad_medida: "Litros",
            precio_unitario: "",
            precio_total: "",
            proveedor: "",
            responsable: 1,
            observaciones: ""
        })
        
        // Función para calcular el total
        function calcularTotal() {
            if (txtCantidadCombustible.text !== "" && txtPrecioUnitarioCombustible.text !== "") {
                const cantidad = parseFloat(txtCantidadCombustible.text);
                const precioUnitario = parseFloat(txtPrecioUnitarioCombustible.text);
                
                if (!isNaN(cantidad) && !isNaN(precioUnitario)) {
                    const total = (cantidad * precioUnitario).toFixed(2);
                    txtTotalCombustible.text = total;
                    dialogNuevoCombustible.nuevaCompra.precio_total = parseFloat(total);
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
                    text: dialogNuevoCombustible.nuevaCompra.id_compra ? "Editar Compra de Combustible" : "Registrar Nueva Compra de Combustible"
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
                    
                    // ID compra (solo visible en edición)
                    Text {
                        text: "ID:"
                        Layout.alignment: Qt.AlignRight
                        visible: dialogNuevoCombustible.nuevaCompra.id_compra !== ""
                    }
                    
                    TextField {
                        id: txtIDCombustible
                        placeholderText: "ID automático"
                        Layout.fillWidth: true
                        readOnly: true
                        visible: dialogNuevoCombustible.nuevaCompra.id_compra !== ""
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
                        onCurrentTextChanged: dialogNuevoCombustible.nuevaCompra.tipo_combustible = currentText
                    }
                    
                    // Fecha de compra
                    Text {
                        text: "Fecha:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaCombustible
                        placeholderText: "YYYY-MM-DD"
                        Layout.fillWidth: true
                        text: new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd")
                        onTextChanged: dialogNuevoCombustible.nuevaCompra.fecha_compra = text
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
                            dialogNuevoCombustible.nuevaCompra.cantidad = parseFloat(text) || 0;
                            dialogNuevoCombustible.calcularTotal();
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
                        onCurrentTextChanged: dialogNuevoCombustible.nuevaCompra.unidad_medida = currentText
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
                            dialogNuevoCombustible.nuevaCompra.precio_unitario = parseFloat(text) || 0;
                            dialogNuevoCombustible.calcularTotal();
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
                    
                    // Observaciones
                    Text {
                        text: "Observaciones:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtObservacionesCombustible
                        placeholderText: "Observaciones adicionales (opcional)"
                        Layout.fillWidth: true
                        Layout.minimumHeight: 60
                        wrapMode: TextArea.Wrap
                        onTextChanged: dialogNuevoCombustible.nuevaCompra.observaciones = text
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
                    if (txtCantidadCombustible.text === "" || txtPrecioUnitarioCombustible.text === "" || 
                        txtProveedorCombustible.text === "" || !dialogNuevoCombustible.nuevaCompra.tipo_combustible) {
                        mensajeValidacionCombustible.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    // Preparar los datos para enviar al modelo
                    var compraData = {
                        tipo_combustible: dialogNuevoCombustible.nuevaCompra.tipo_combustible,
                        fecha_compra: dialogNuevoCombustible.nuevaCompra.fecha_compra,
                        cantidad: parseFloat(dialogNuevoCombustible.nuevaCompra.cantidad),
                        unidad_medida: dialogNuevoCombustible.nuevaCompra.unidad_medida,
                        precio_unitario: parseFloat(dialogNuevoCombustible.nuevaCompra.precio_unitario),
                        precio_total: parseFloat(dialogNuevoCombustible.nuevaCompra.precio_total),
                        proveedor: dialogNuevoCombustible.nuevaCompra.proveedor,
                        responsable: dialogNuevoCombustible.nuevaCompra.responsable,
                        observaciones: dialogNuevoCombustible.nuevaCompra.observaciones
                    };
                    
                    var success = false;
                    if (dialogNuevoCombustible.nuevaCompra.id_compra) {
                        // Actualizar compra existente
                        success = maquinariaModel.actualizar_compra_combustible(
                            dialogNuevoCombustible.nuevaCompra.id_compra, 
                            JSON.stringify(compraData)
                        );
                    } else {
                        // Agregar nueva compra
                        success = maquinariaModel.registrar_compra_combustible(JSON.stringify(compraData));
                    }
                    
                    if (success) {
                        // Recargar los datos
                        maquinariaModel.cargar_compras_combustible();
                        maquinariaModel.cargar_resumen_combustible();
                        cargarComprasCombustibleDesdeModelo();
                        dialogNuevoCombustible.close();
                    } else {
                        mensajeValidacionCombustible.text = "Error al guardar la compra de combustible. Intente nuevamente.";
                    }
                }
            }
        }
    
    // Cargar datos iniciales cuando se carga el componente
        Component.onCompleted: {
            cargarMaquinariaDesdeModelo();
            cargarMantenimientosDesdeModelo();
            cargarComprasCombustibleDesdeModelo();
        }
    }

// Función para filtrar compras de combustible
    function filtrarComprasCombustible() {
        var tipoSeleccionado = cmbFiltroTipoCombustible.currentText;
        combustibleModel.clear();
        
        var compras = maquinariaModel.compras;
        for (var i = 0; i < compras.length; i++) {
            var compra = compras[i];
            
            // Aplicar filtro de tipo de combustible
            if (tipoSeleccionado !== "Todos los tipos" && compra.tipo_combustible !== tipoSeleccionado) {
                continue;
            }
            
            combustibleModel.append({
                id_compra: compra.id_compra,
                tipo_combustible: compra.tipo_combustible,
                fecha_compra: compra.fecha_compra,
                cantidad: compra.cantidad,
                unidad_medida: compra.unidad_medida,
                precio_unitario: compra.precio_unitario,
                precio_total: compra.precio_total,
                proveedor: compra.proveedor,
                responsable: compra.responsable,
                nombre_responsable: compra.nombre_responsable,
                observaciones: compra.observaciones
            });
        }
    }
    
    // Función para obtener los nombres de la maquinaria para el combo
    function obtenerNombresMaquinaria() {
        var nombres = ["Todos los equipos"];
        var maquinarias = maquinariaModel.maquinaria;
        for (var i = 0; i < maquinarias.length; i++) {
            nombres.push(maquinarias[i].nombre);
        }
        return nombres;
    }
    
    
}