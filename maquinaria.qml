import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: maquinariaRoot
    anchors.fill: parent
    color: "#F8F9FA"

    Connections {
        target: maquinariaModel
        
        function onComprasChanged() {
            cargarComprasCombustibleDesdeModelo()
        }
        
        function onResumenCombustibleChanged() {
            actualizarResumenCombustible()
        }
    }
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
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
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
                                dialogNuevoEquipo.nuevoEquipo = {
                                    codigo: "",
                                    nombre: "",
                                    tipo: "",
                                    marca: "",
                                    tipo_combustible: "Gasolina",
                                    estado: "Operativo"
                                };
                                // Resetear los controles del formulario
                                cmbTipoEquipo.currentIndex = -1;
                                cmbCombustibleEquipo.currentIndex = 0; // Gasolina por defecto
                                cmbEstadoEquipo.currentIndex = 0; // Operativo por defecto
                                txtCodigoEquipo.text = "";
                                txtNombreEquipo.text = "";
                                txtMarcaEquipo.text = "";
                                txtUbicacionEquipo.text = "";
                                mensajeValidacionEquipo.text = "";
                                dialogNuevoEquipo.open();
                            }
                        }
                        
                        TextField {
                            id: txtBuscarEquipo
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar equipo..."
                            implicitWidth: 450
                            implicitHeight: 28
                            leftPadding: 30  // Espacio para el icono
                            
                            background: Rectangle {
                                color: "#ffffff"
                                radius: height / 2
                                border.color: "#808080"
                                border.width: 1
                                
                                // Icono de lupa
                                Image {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: "Image/Image_UI_interfaz/Inconos/lupa.png" // Cambia por tu ruta
                                    width: 16
                                    height: 16
                                }
                            }
                            onTextChanged: {
                                // Filtrar equipos por nombre o código
                                filtrarMaquinaria(text);
                            }
                        }
                        
                        ComboBox {
                            id: cmbFiltroTipoEquipo
                            Layout.preferredWidth: 200
                            model: ["Todos los tipos", "Tractor", "Fumigadora", "Bomba de riego", "Pulverizadora", "Cosechadora", "Otro"]
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
                                    width: parent.width * 0.11
                                    height: parent.height
                                    text: "Código"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.24
                                    height: parent.height
                                    text: "Nombre"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.14
                                    height: parent.height
                                    text: "Tipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.14
                                    height: parent.height
                                    text: "Marca"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
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
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Acciones"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                        
                        // Delegado para cada fila        ---------------------------------------------------
                        delegate: Rectangle {
                            width: maquinariaRoot.width
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
                                spacing : 0
                                
                                Text {
                                    width: parent.width * 0.11
                                    height: parent.height
                                    text: codigo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.24
                                    height: parent.height
                                    text: nombre
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.14
                                    height: parent.height
                                    text: tipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.14
                                    height: parent.height
                                    text: marca
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
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
                                        width: Math.min(110, parent.width - 20)
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
                                            font.bold: true
                                        }
                                    }
                                }
                                
                                // Columna Acciones - Editar forma de botones
                                // Botones de Acciones
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 7
                                        anchors.centerIn: parent

                                        // Boton editar de maquinaria siempre disponible
                                        Button {
                                            width: 40
                                            height: 40
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar equipo"
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            onClicked: {
                                                editarMaquinaria(index);
                                            }
                                        }
                                        Button {
                                            width: 40
                                            height: 40
                                            flat: true
                                            ToolTip.visible: hovered

                                            // Cambiar icono y función según el estado
                                            icon.source: {
                                                if (estado === "Fuera de servicio") {
                                                    return "Image/Image_UI_interfaz/Inconos/check.svg"; // Reactivar
                                                } else {
                                                    return "Image/Image_UI_interfaz/Inconos/advertencia.svg"; // Poner fuera de servicio
                                                }
                                            }
                                            icon.color: estado === "Fuera de servicio" ? "#4CAF50" : "#FF9800"
                                            ToolTip.text: {
                                                if (estado === "Fuera de servicio") {
                                                    return "Reactivar equipo";
                                                } else {
                                                    return "Poner fuera de servicio";
                                                }
                                            }
                                            background: Rectangle {
                                                color: {
                                                    if (parent.hovered) {
                                                        return estado === "Fuera de servicio" ? "#E8F5E8" : "#FFF3E0";
                                                    }
                                                    return "transparent";
                                                }
                                                radius: 4
                                            }
                                            onClicked: {
                                                eliminarMaquinaria(id_maquinaria);
                                            }

                                        }
                                        
                                        // Boton de eliminar de la pagina equipos
                                        Button {
                                            width: 40
                                            height: 40
                                            icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar equipo"
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            onClicked: {
                                                eliminarEquipoDefinitivo(id_maquinaria);
                                            }
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
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
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
                                // ✅ LLAMAR resetForm() CORRECTAMENTE
                                dialogNuevoMantenimiento.resetForm();
                                dialogNuevoMantenimiento.open();
                            }
                        }
                        
                        TextField {
                            id: txtBuscarMantenimiento
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar mantenimiento..."
                            implicitWidth: 450
                            implicitHeight: 28
                            leftPadding: 30  // Espacio para el icono
                            
                            background: Rectangle {
                                color: "#ffffff"
                                radius: height / 2
                                border.color: "#808080"
                                border.width: 1
                                
                                // Icono de lupa
                                Image {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: "Image/Image_UI_interfaz/Inconos/lupa.png" // Cambia por tu ruta
                                    width: 16
                                    height: 16
                                }
                            }
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
                            width: parent ? parent.width : maquinariaRoot.width
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

                                Rectangle{
                                    width: parent.width * 0.05
                                    height: parent.height
                                    color: "transparent"

                                    // Botones de acción para Mantenimientos
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 40
                                            height: 40
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar mantenimiento"
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            onClicked: {
                                                editarMantenimiento(index);
                                            }
                                        }
                                        
                                        Button {
                                            width: 40
                                            height: 40
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: estado === "Programado" ? "Completar mantenimiento" : "Eliminar mantenimiento"
                                             icon.source: estado === "Programado" ? 
                                                "Image/Image_UI_interfaz/Inconos/check.svg" : 
                                                "Image/Image_UI_interfaz/Inconos/basura.svg"

                                            icon.color: estado === "Programado" ? "#4CAF50" : "#F44336"

                                            background: Rectangle {
                                                color: parent.hovered ? (estado === "Programado" ? "#E8F5E8" : "#FFEBEE") : "transparent"
                                                radius: 4
                                            }
                                            onClicked: {
                                                if (estado === "Programado") {
                                                    completarMantenimiento(id_mantenimiento);
                                                } else {
                                                    eliminarMantenimiento(id_mantenimiento);
                                                }
                                            }
                                        }

                                        Text {
                                            width: parent.width * 0.25
                                            height: parent.height
                                            text: ""
                                            font.bold: true 
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
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
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
                                dialogNuevoCombustible.nuevaCompra = {
                                    id_compra: "",
                                    tipo_combustible: "Gasolina",
                                    fecha_compra: new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd"),
                                    cantidad: 0,
                                    unidad_medida: "Litros",
                                    precio_unitario: 0,
                                    precio_total: 0,
                                    proveedor: "",
                                    responsable: obtenerUsuarioActual(), // ID usuario actual
                                    observaciones: ""
                                };
                                // ✅ LIMPIAR CAMPOS
                                txtCantidadCombustible.text = "";
                                txtPrecioUnitarioCombustible.text = "";
                                txtTotalCombustible.text = "0.00";
                                txtProveedorCombustible.text = "";
                                txtObservacionesCombustible.text = "";

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
                                text: "Último año"
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
                                text: "Último año"
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
                                text: "Último año"
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
                            width: parent ? parent.width : maquinariaRoot.width
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

                                // Botones de acción Para la pagina combustible
                                Rectangle {
                                    width: parent.width * 0.05
                                    height: parent.height
                                    color: "transparent"

                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 40
                                            height: 40
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar Compra Combustibles"
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            onClicked: {
                                                editarCompraCombustible(index);
                                            }
                                        }
                                        
                                        Button {
                                            width: 40
                                            height: 40
                                            icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                            icon.color: "#F44336"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar compra de combustible"
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            onClicked: {
                                                eliminarCompraCombustible(id_compra);
                                            }
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
                        model: ["Tractor", "Fumigadora", "Bomba de riego", "Pulverizadora", "Cosechadora", "Otro"]
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
                        model: ["Gasolina", "Diésel", "Eléctrico", "Otro", "Ninguno"]
                        onActivated: dialogNuevoEquipo.nuevoEquipo.tipo_combustible = currentText
                        Component.onCompleted: {
                            if (dialogNuevoEquipo.nuevoEquipo.tipo_combustible) {
                                currentIndex = indexOfValue(dialogNuevoEquipo.nuevoEquipo.tipo_combustible)
                            }
                        }
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

                    // Asegurar que el tipo de combustible tenga valor
                    if (!dialogNuevoEquipo.nuevoEquipo.tipo_combustible) {
                        dialogNuevoEquipo.nuevoEquipo.tipo_combustible = cmbCombustibleEquipo.currentText;
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
                        filtrarMaquinaria("");
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

        function resetForm() {
            nuevoMantenimiento = {
                id_mantenimiento: "",
                id_maquinaria: "",
                tipo: "Preventivo",
                fecha_realizada: "",
                descripcion: "",
                costo_total: "",
                responsable:obtenerUsuarioActual(),
                estado: "Programado"
            };
            
            // Limpiar campos del formulario
            txtIDMantenimiento.text = "";
            txtDescripcionMantenimiento.text = "";
            txtCostoMantenimiento.text = "";
            txtFechaMantenimiento.text = new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd");
            mensajeValidacionMantenimiento.text = "";
            
            // Resetear combos a valores por defecto
            cmbEquipoMantenimiento.currentIndex = 0;
            cmbTipoMantenimiento.currentIndex = 0; // Preventivo
            cmbEstadoMantenimiento.currentIndex = 0; // Programado
        }
        
        // Variables para almacenar datos temporales
        property var nuevoMantenimiento: ({
            id_mantenimiento: "",
            id_maquinaria: "",
            tipo: "Preventivo",
            fecha_realizada: "",
            descripcion: "",
            costo_total: "",
            responsable:obtenerUsuarioActual(),
            estado: "Programado"
        })    

        // Función para obtener ID de maquinaria por nombre
        function obtenerIdMaquinariaPorNombre(nombre) {
            // Verificar que maquinariaModel no sea null y tenga la propiedad maquinaria
            if (!maquinariaModel || !maquinariaModel.maquinaria) {
                console.log("maquinariaModel no disponible en obtenerIdMaquinariaPorNombre");
                return null;
            }
            
            try {
                var maquinarias = maquinariaModel.maquinaria;
                for (var i = 0; i < maquinarias.length; i++) {
                    if (maquinarias[i] && maquinarias[i].nombre === nombre) {
                        return maquinarias[i].id_maquinaria;
                    }
                }
                return null;
            } catch (error) {
                console.log("Error en obtenerIdMaquinariaPorNombre:", error);
                return null;
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
                    
                    // 1. Equipo
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
                    
                    // 2. Tipo de mantenimiento
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
                    
                    // 3. Estado
                    Text {
                        text: "Estado:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbEstadoMantenimiento
                        Layout.fillWidth: true
                        model: ["Programado", "Completado"]
                        onCurrentTextChanged: {
                            dialogNuevoMantenimiento.nuevoMantenimiento.estado = currentText;
                            
                            if (currentText === "Completado") {
                                // Al completar: establecer fecha realizada si está vacía
                                if (txtFechaMantenimiento.text === "") {
                                    txtFechaMantenimiento.text = new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd");
                                }
                            } else if (currentText === "Programado") {
                                // Al programar: limpiar fecha realizada
                                txtFechaMantenimiento.text = "";
                                dialogNuevoMantenimiento.nuevoMantenimiento.fecha_realizada = "";
                            }
                        }
                    }
                    
                    // 4. Fecha (condicional según estado)
                    Text {
                        text: cmbEstadoMantenimiento.currentText === "Completado" ? "Fecha realizada:" : "Fecha programada:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaMantenimiento
                        placeholderText: cmbEstadoMantenimiento.currentText === "Completado" ? 
                            "YYYY-MM-DD (cuándo se realizó)" : "YYYY-MM-DD (cuándo debe realizarse)"
                        Layout.fillWidth: true
                        validator: RegularExpressionValidator {
                            regularExpression: /^\d{4}-\d{2}-\d{2}$/
                        }
                        onTextChanged: {
                            if (acceptableInput && text !== "") {
                                if (cmbEstadoMantenimiento.currentText === "Completado") {
                                    dialogNuevoMantenimiento.nuevoMantenimiento.fecha_realizada = text;
                                } else {
                                    dialogNuevoMantenimiento.nuevoMantenimiento.FechaMantenimiento = text;
                                }
                            } else {
                                if (cmbEstadoMantenimiento.currentText === "Completado") {
                                    dialogNuevoMantenimiento.nuevoMantenimiento.fecha_realizada = "";
                                } else {
                                    dialogNuevoMantenimiento.nuevoMantenimiento.FechaMantenimiento = "";
                                }
                            }
                        }
                    }
                    
                    // 5. Costo
                    Text {
                        text: cmbEstadoMantenimiento.currentText === "Completado" ? "Costo real (Bs.):" : "Costo estimado (Bs.):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtCostoMantenimiento
                        placeholderText: cmbEstadoMantenimiento.currentText === "Completado" ? 
                            "Costo real (obligatorio)" : "Costo estimado (opcional)"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0; decimals: 2 }
                        onTextChanged: {
                            if (text.trim() === "") {
                                dialogNuevoMantenimiento.nuevoMantenimiento.costo_total = null;
                            } else {
                                dialogNuevoMantenimiento.nuevoMantenimiento.costo_total = parseFloat(text);
                            }
                        }
                    }
                    
                    // 6. Descripción
                    Text {
                        text: "Descripción:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtDescripcionMantenimiento
                        placeholderText: cmbEstadoMantenimiento.currentText === "Completado" ? 
                            "Describa qué se realizó" : "Describa el mantenimiento a realizar"
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80
                        wrapMode: TextArea.Wrap
                        onTextChanged: dialogNuevoMantenimiento.nuevoMantenimiento.descripcion = text
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
                    // ✅ VALIDACIÓN MEJORADA
                    var errores = [];
                    
                    if (!dialogNuevoMantenimiento.nuevoMantenimiento.id_maquinaria) 
                        errores.push("Seleccione un equipo");
                    if (txtDescripcionMantenimiento.text.trim() === "")
                        errores.push("Ingrese una descripción");

                    // Validaciones específicas por estado
                    if (dialogNuevoMantenimiento.nuevoMantenimiento.estado === "Programado") {
                        // Para programados: fecha programada obligatoria
                        if (txtFechaMantenimiento.text.trim() === "") {
                            errores.push("Ingrese la fecha programada");
                        }
                    } else if (dialogNuevoMantenimiento.nuevoMantenimiento.estado === "Completado") {
                        // Para completados: fecha realizada y costo obligatorios
                        if (txtFechaMantenimiento.text.trim() === "") {
                            errores.push("Ingrese la fecha de realización");
                        }
                        if (txtCostoMantenimiento.text === "" || isNaN(parseFloat(txtCostoMantenimiento.text))) {
                            errores.push("Ingrese el costo real del mantenimiento");
                        }
                    }
                    
                    // Solo validar fecha si el estado es Completado
                    if (dialogNuevoMantenimiento.nuevoMantenimiento.estado === "Completado") {
                        if (txtFechaMantenimiento.text.trim() === "") {
                            errores.push("Ingrese la fecha de realización para mantenimientos completados");
                        } else if (!txtFechaMantenimiento.acceptableInput) {
                            errores.push("La fecha debe tener formato YYYY-MM-DD");
                        }
                    }
                    
                    if (errores.length > 0) {
                        mensajeValidacionMantenimiento.text = errores.join(", ");
                        return;
                    }
                    
                    // ✅ PREPARAR DATOS MEJORADO
                    var mantenimientoData = {
                        id_maquinaria: parseInt(dialogNuevoMantenimiento.nuevoMantenimiento.id_maquinaria),
                        tipo: dialogNuevoMantenimiento.nuevoMantenimiento.tipo,
                        descripcion: txtDescripcionMantenimiento.text.trim(),
                        responsable: parseInt(obtenerUsuarioActual()),
                        estado: cmbEstadoMantenimiento.currentText,
                        fecha_realizada: txtFechaMantenimiento.text.trim() // ← SIEMPRE ESTE CAMPO
                    };
                    // Agregar costo si no está vacío
                    if (txtCostoMantenimiento.text.trim() !== "") {
                        mantenimientoData.costo_total = parseFloat(txtCostoMantenimiento.text);
                    }
                    
                    // Solo agregar fecha si está completado y hay una fecha válida
                    if (dialogNuevoMantenimiento.nuevoMantenimiento.estado === "Completado" && 
                        txtFechaMantenimiento.text.trim() !== "") {
                        mantenimientoData.fecha_realizada = txtFechaMantenimiento.text.trim();
                    }
                    
                    console.log("Datos a enviar:", JSON.stringify(mantenimientoData));
                    
                    var success = false;
                    if (dialogNuevoMantenimiento.nuevoMantenimiento.id_mantenimiento) {
                        // Actualizar mantenimiento existente
                        success = maquinariaModel.actualizar_mantenimiento(
                            parseInt(dialogNuevoMantenimiento.nuevoMantenimiento.id_mantenimiento), 
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
            responsable: obtenerUsuarioActual(),
            observaciones: ""
        })
        
        // Función para calcular el total
        function calcularTotal() {
            if (txtCantidadCombustible.text !== "" && txtPrecioUnitarioCombustible.text !== "") {
                // ✅ CORRECCIÓN: Manejar notación científica y decimales
                let cantidadStr = txtCantidadCombustible.text.replace(',', '.');
                let precioStr = txtPrecioUnitarioCombustible.text.replace(',', '.');
                
                const cantidad = parseFloat(cantidadStr);
                const precioUnitario = parseFloat(precioStr);
                
                if (!isNaN(cantidad) && !isNaN(precioUnitario) && cantidad > 0 && precioUnitario > 0) {
                    const total = (cantidad * precioUnitario).toFixed(2);
                    txtTotalCombustible.text = total;
                    dialogNuevoCombustible.nuevaCompra.precio_total = parseFloat(total);
                    
                    // ✅ LOGGING PARA DEPURACIÓN
                    console.log("Cálculo total:");
                    console.log("  Cantidad:", cantidad);
                    console.log("  Precio unitario:", precioUnitario);
                    console.log("  Total calculado:", total);
                } else {
                    txtTotalCombustible.text = "0.00";
                    dialogNuevoCombustible.nuevaCompra.precio_total = 0;
                    console.log("Error en cálculo - valores inválidos:", cantidadStr, precioStr);
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
                       validator: DoubleValidator { 
                            bottom: 0.01
                            top: 999999.99
                            decimals: 2
                            notation: DoubleValidator.StandardNotation
                            locale: "en_US"
                        }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: {
                            let cleanText = text.replace(',', '.');
                            let valor = parseFloat(cleanText);
                            if (!isNaN(valor) && valor > 0) {
                                dialogNuevoCombustible.nuevaCompra.cantidad = valor;
                            } else {
                                dialogNuevoCombustible.nuevaCompra.cantidad = 0;
                            }
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
                        validator: DoubleValidator { 
                            bottom: 0.01
                            top: 999999.99
                            decimals: 2
                            notation: DoubleValidator.StandardNotation 
                            locale: "en_US"
                        }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: {
                            let cleanText = text.replace(',', '.');
                            let valor = parseFloat(cleanText);
                            if (!isNaN(valor) && valor > 0) {
                                dialogNuevoCombustible.nuevaCompra.precio_unitario = valor;
                            } else {
                                dialogNuevoCombustible.nuevaCompra.precio_unitario = 0;
                            }
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
                     // ✅ CONVERSIÓN SEGURA DE NÚMEROS
                    let cantidadStr = txtCantidadCombustible.text.replace(',', '.');
                    let precioStr = txtPrecioUnitarioCombustible.text.replace(',', '.');
                    
                    let cantidad = parseFloat(cantidadStr);
                    let precioUnitario = parseFloat(precioStr);
                    
                    if (isNaN(cantidad) || isNaN(precioUnitario) || cantidad <= 0 || precioUnitario <= 0) {
                        mensajeValidacionCombustible.text = "Cantidad y precio unitario deben ser números válidos mayores a 0";
                        return;
                    }
                                
                    // Preparar los datos para enviar al modelo
                    var compraData = {
                        tipo_combustible: dialogNuevoCombustible.nuevaCompra.tipo_combustible,
                        fecha_compra: dialogNuevoCombustible.nuevaCompra.fecha_compra,
                        cantidad: cantidad,
                        unidad_medida: dialogNuevoCombustible.nuevaCompra.unidad_medida,
                        precio_unitario: precioUnitario,
                        precio_total: cantidad * precioUnitario,
                        proveedor: dialogNuevoCombustible.nuevaCompra.proveedor || "",
                        responsable: obtenerUsuarioActual(),
                        observaciones: dialogNuevoCombustible.nuevaCompra.observaciones || ""
                    };
                    // ✅ LOGGING DETALLADO
                    console.log("=== DATOS A ENVIAR ===");
                    console.log("Tipo:", compraData.tipo_combustible);
                    console.log("Fecha:", compraData.fecha_compra);
                    console.log("Cantidad:", compraData.cantidad, typeof compraData.cantidad);
                    console.log("Precio unitario:", compraData.precio_unitario, typeof compraData.precio_unitario);
                    console.log("Precio total:", compraData.precio_total, typeof compraData.precio_total);
                    console.log("Proveedor:", compraData.proveedor);
                    console.log("Responsable:", compraData.responsable, typeof compraData.responsable);
                    
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
            filtrarMaquinaria("");
            cargarMantenimientosDesdeModelo();
            maquinariaModel.cargar_resumen_combustible('año'); // ← CAMBIAR A AÑO
            actualizarResumenCombustible();
        }
    }

    // DIÁLOGO DE CONFIRMACIÓN REUTILIZABLE
    Dialog {
        id: dialogConfirmacion
        title: "Confirmar acción"
        modal: true
        width: 400
        height: 200
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        property string mensaje: ""
        property var funcionCallback: null
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    text: dialogConfirmacion.mensaje
                    font.pixelSize: 14
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: dialogConfirmacion.close()
            }
            
            Button {
                text: "Confirmar"
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
                onClicked: {
                    dialogConfirmacion.close()
                    if (dialogConfirmacion.funcionCallback) {
                        dialogConfirmacion.funcionCallback()
                    }
                }
            }
        }
    }
    // Editar aqui
    Dialog {
        id: dialogOpcionesEquipo
        title: "Opciones de Equipo"
        modal: true
        width: 450
        height: 300
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        property int equipoId: 0
        property string equipoNombre: ""
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    text: `¿Qué desea hacer con "${dialogOpcionesEquipo.equipoNombre}"?`
                    font.pixelSize: 16
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }
                
                Column {
                    width: parent.width
                    spacing: 15
                    
                    Button {
                        width: parent.width
                        height: 50
                        icon.source:"Image/Image_UI_interfaz/Inconos/fuera_de_servicio.svg"
                        //text: "🔧 Poner fuera de servicio"
                        background: Rectangle {
                            color: parent.hovered ? "#FFA726" : "#FFB74D"
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
                            var equipoData = { estado: "Fuera de servicio" };
                            if (maquinariaModel.actualizar_maquinaria(dialogOpcionesEquipo.equipoId, JSON.stringify(equipoData))) {
                                maquinariaModel.cargar_maquinaria();
                                filtrarMaquinaria(txtBuscarEquipo ? txtBuscarEquipo.text : "");
                            }
                            dialogOpcionesEquipo.close();
                        }
                    }
                    
                    Button {
                        width: parent.width
                        height: 50
                        text: "🗑️ Eliminar permanentemente"
                        background: Rectangle {
                            color: parent.hovered ? "#E53935" : "#F44336"
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
                            dialogConfirmacion.mensaje = "⚠️ ADVERTENCIA: Esta acción eliminará permanentemente el equipo del sistema.\n\n¿Está completamente seguro?";
                            dialogConfirmacion.funcionCallback = function() {
                                if (maquinariaModel.desactivar_maquinaria(dialogOpcionesEquipo.equipoId)) {
                                    maquinariaModel.cargar_maquinaria();
                                    filtrarMaquinaria(txtBuscarEquipo ? txtBuscarEquipo.text : "");
                                }
                            }
                            dialogOpcionesEquipo.close();
                            dialogConfirmacion.open();
                        }
                    }
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: dialogOpcionesEquipo.close()
            }
        }
    }

    // Timer para recargar la interfaz después de recargar datos
    Timer {
        id: recargarTimer
        interval: 500
        repeat: false
        onTriggered: {
            txtDiagnostico.append("Recargando interfaz...");
            cargarMaquinariaDesdeModelo();
            filtrarMaquinaria("");
            txtDiagnostico.append(`Interfaz recargada: ${equiposModel.count} equipos en modelo`);
        }
    }

    // Función corregida para filtrar compras de combustible
    function filtrarComprasCombustible() {
        var tipoSeleccionado = cmbFiltroTipoCombustible ? cmbFiltroTipoCombustible.currentText : "Todos los tipos";
        combustibleModel.clear();

        // Al inicio de cada función que use maquinariaModel
        if (!maquinariaModel) {
            console.log("maquinariaModel no disponible - aplicación cerrándose");
            return;
        }
        
        // Verificar que maquinariaModel y compras existan
        if (!maquinariaModel || !maquinariaModel.compras) {
            return;
        }
        
        var compras = maquinariaModel.compras;
        for (var i = 0; i < compras.length; i++) {
            var compra = compras[i];
            
            // Aplicar filtro de tipo de combustible
            if (tipoSeleccionado !== "Todos los tipos" && (compra.tipo_combustible || "") !== tipoSeleccionado) {
                continue;
            }
            
            combustibleModel.append({
                id_compra: compra.id_compra || 0,
                tipo_combustible: compra.tipo_combustible || "",
                fecha_compra: compra.fecha_compra || "",
                cantidad: compra.cantidad || 0,
                unidad_medida: compra.unidad_medida || "Litros",
                precio_unitario: compra.precio_unitario || 0,
                precio_total: compra.precio_total || 0,
                proveedor: compra.proveedor || "",
                responsable: compra.responsable || 0,
                nombre_responsable: compra.nombre_responsable || "",
                observaciones: compra.observaciones || ""
            });
        }
    }
    
    // Función corregida para obtener los nombres de la maquinaria para el combo
    function obtenerNombresMaquinaria() {
        var nombres = ["Todos los equipos"];
        
        if (!maquinariaModel || !maquinariaModel.maquinaria) {
            return nombres;
        }
        
        try {
            var maquinarias = maquinariaModel.maquinaria;
            for (var i = 0; i < maquinarias.length; i++) {
                var maquina = maquinarias[i];
                if (maquina && maquina.activo === true) {  // ← CAMBIO: Mostrar todos los equipos activos
                    nombres.push(maquina.nombre);
                }
            }
            return nombres;
        } catch (error) {
            return nombres;
        }
    }
    
    // Función para cargar los datos de maquinaria desde el modelo al ListModel
    function cargarMaquinariaDesdeModelo() {
        equiposModel.clear();
        
        // Verificar que maquinariaModel y maquinaria existan
        if (!maquinariaModel || !maquinariaModel.maquinaria) {
            console.log("maquinariaModel o maquinaria no están disponibles");
            return;
        }
        
        var maquinarias = maquinariaModel.maquinaria;
        for (var i = 0; i < maquinarias.length; i++) {
            var maquina = maquinarias[i];
            // Solo mostrar equipos activos
            if (!maquina.activo) {
                continue;
            }
            equiposModel.append({
                id_maquinaria: maquina.id_maquinaria || 0,
                codigo: maquina.codigo || "",
                nombre: maquina.nombre || "",
                tipo: maquina.tipo || "",
                marca: maquina.marca || "",
                tipo_combustible: (maquina.tipo_combustible !== undefined && maquina.tipo_combustible !== null) ? maquina.tipo_combustible : "",
                estado: maquina.estado || "Operativo",
                ubicacion_actual: maquina.ubicacion_actual || "",
                activo: maquina.activo !== undefined ? maquina.activo : true
            });
        }
    }
    
    // Función para cargar los datos de mantenimientos desde el modelo al ListModel
    function cargarMantenimientosDesdeModelo() {
        mantenimientoModel.clear();
        
        // Verificar que maquinariaModel y mantenimientos existan
        if (!maquinariaModel || !maquinariaModel.mantenimientos) return;
        
        var mantenimientos = maquinariaModel.mantenimientos;
        for (var i = 0; i < mantenimientos.length; i++) {
            var mantenimiento = mantenimientos[i];
            var fechaRealizada = mantenimiento.fecha_realizada ? mantenimiento.fecha_realizada : "Pendiente";

            mantenimientoModel.append({
                id_mantenimiento: mantenimiento.id_mantenimiento || 0,
                id_maquinaria: mantenimiento.id_maquinaria || 0,
                nombre_maquinaria: mantenimiento.nombre_maquinaria || "",
                tipo: mantenimiento.tipo || "",
                fecha_realizada: fechaRealizada,
                descripcion: mantenimiento.descripcion || "",
                costo_total: mantenimiento.costo_total || 0,
                responsable: mantenimiento.responsable || 0,
                nombre_responsable: mantenimiento.nombre_responsable || "",
                estado: mantenimiento.estado || "Programado"
            });
        }
    }
    
    // Función para cargar los datos de compras de combustible desde el modelo al ListModel
    function cargarComprasCombustibleDesdeModelo() {
        combustibleModel.clear();
        if (!maquinariaModel || !maquinariaModel.compras) return;
        
        var compras = maquinariaModel.compras;
        for (var i = 0; i < compras.length; i++) {
            var compra = compras[i];
                combustibleModel.append({
                id_compra: compra.id_compra || 0,
                tipo_combustible: compra.tipo_combustible || "",
                fecha_compra: compra.fecha_compra || "",
                cantidad: compra.cantidad || 0,
                unidad_medida: compra.unidad_medida || "Litros",
                precio_unitario: compra.precio_unitario || 0,
                precio_total: compra.precio_total || 0,
                proveedor: compra.proveedor || "",
                responsable: compra.responsable || 0,
                observaciones: compra.observaciones || ""
            });
        }
        actualizarResumenCombustible();
    }
    
    // Función para actualizar el resumen de combustible en los textos
    function actualizarResumenCombustible() {
        console.log("=== DEPURANDO RESUMEN ===");
        
        if (!maquinariaModel || !maquinariaModel.resumen_combustible) {
            console.log("ERROR: maquinariaModel o resumen no disponible");
            txtConsumoGasolina.text = "0 litros";
            txtConsumoDiesel.text = "0 litros";
            txtGastoTotal.text = "Bs. 0";
            return;
        }
        
        var resumen = maquinariaModel.resumen_combustible;
        console.log("Resumen completo:", JSON.stringify(resumen));
        
        var consumoGasolina = 0;
        var consumoDiesel = 0;
        var gastoTotal = 0;
        
        // Calcular consumos y gastos
        if (resumen["Gasolina"]) {
            console.log("Datos Gasolina:", JSON.stringify(resumen["Gasolina"]));
            consumoGasolina = resumen["Gasolina"]["total_cantidad"] || 0;
            gastoTotal += resumen["Gasolina"]["total_costo"] || 0;
        }
        
        if (resumen["Diésel"]) {
            console.log("Datos Diésel:", JSON.stringify(resumen["Diésel"]));
            consumoDiesel = resumen["Diésel"]["total_cantidad"] || 0;
            gastoTotal += resumen["Diésel"]["total_costo"] || 0;
        }
        
        console.log("Calculado - Gasolina:", consumoGasolina, "Diésel:", consumoDiesel, "Total:", gastoTotal);
        
        // Actualizar los textos
        txtConsumoGasolina.text = consumoGasolina.toFixed(2) + " litros";
        txtConsumoDiesel.text = consumoDiesel.toFixed(2) + " litros";
        txtGastoTotal.text = "Bs. " + gastoTotal.toFixed(2);
    }
    
    // Función para filtrar maquinaria
    function filtrarMaquinaria(texto) {
        // Verificar que los elementos existan antes de usar
        if (!cmbFiltroTipoEquipo || !maquinariaModel || !maquinariaModel.maquinaria) {
            console.log("Elementos no disponibles para filtrar maquinaria");
            return;
        }
        var tipo = cmbFiltroTipoEquipo.currentText;
        equiposModel.clear();
        
        var maquinarias = maquinariaModel.maquinaria;
        for (var i = 0; i < maquinarias.length; i++) {
            var maquina = maquinarias[i];
            
            // Filtrar solo equipos activos
            if (!maquina || !maquina.activo===true) continue;
            
            // Aplicar filtro de tipo
            if (tipo !== "Todos los tipos" && maquina.tipo !== tipo) {
                continue;
            }
            
            // Aplicar filtro de texto
            if (texto && texto.trim() !== "") {
                var textoLower = texto.toLowerCase().trim();
                if (!(
                    maquina.codigo.toLowerCase().includes(textoLower) ||
                    maquina.nombre.toLowerCase().includes(textoLower) ||
                    maquina.marca.toLowerCase().includes(textoLower)
                )) {
                    continue;
                }
            }
            
            equiposModel.append({
                id_maquinaria: maquina.id_maquinaria || 0,
                codigo: maquina.codigo || "",
                nombre: maquina.nombre || "",
                tipo: maquina.tipo || "",
                marca: maquina.marca || "",
                tipo_combustible: (maquina.tipo_combustible !== undefined && maquina.tipo_combustible !== null) ? maquina.tipo_combustible : "",  // ← CORRECCIÓN APLICADA
                estado: maquina.estado || "Operativo",
                ubicacion_actual: maquina.ubicacion_actual || "",
                activo: maquina.activo !== undefined ? maquina.activo : true
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
               fecha_realizada: mantenimiento.fecha_realizada ? mantenimiento.fecha_realizada : "Pendiente",
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

         // Solo aplicar valores si estamos editando un equipo existente
        if (item.id_maquinaria) {
            txtCodigoEquipo.text = item.codigo;
            txtNombreEquipo.text = item.nombre;
            txtMarcaEquipo.text = item.marca;
            txtUbicacionEquipo.text = item.ubicacion_actual || "";
        }

        
        dialogNuevoEquipo.open();
    }
    
    // Función corregida para eliminar maquinaria
    function eliminarMaquinaria(id_maquinaria) {
        // Buscar el equipo actual
        var equipoActual = null;
        for (var i = 0; i < equiposModel.count; i++) {
            var item = equiposModel.get(i);
            if (item.id_maquinaria === id_maquinaria) {
                equipoActual = item;
                break;
            }
        }
        
        if (!equipoActual) return;

        var mensaje = "";
        var accion = "";

        if (equipoActual.estado === "Operativo") {
            mensaje = `El equipo "${equipoActual.nombre}" está operativo.\n\n¿Desea ponerlo fuera de servicio?\n\n(Nota: Para auditoría, no se eliminan equipos permanentemente)`;
            var nuevoEstado = "Fuera de servicio";
        } else if (equipoActual.estado === "En mantenimiento") {
            mensaje = `El equipo "${equipoActual.nombre}" está en mantenimiento.\n\n¿Desea ponerlo fuera de servicio?\n\n(El mantenimiento pendiente se mantendrá)`;
           var nuevoEstado = "Fuera de servicio";
        } else if (equipoActual.estado === "Fuera de servicio") {
            mensaje = `El equipo "${equipoActual.nombre}" ya está fuera de servicio.\n\n¿Desea reactivarlo?\n\n(Volverá a estado Operativo)`;
            var nuevoEstado = "Operativo";
        }
        
        dialogConfirmacion.mensaje = mensaje;
        dialogConfirmacion.funcionCallback = function() {
            var equipoData = { estado: nuevoEstado };
            
            if (maquinariaModel && typeof maquinariaModel.actualizar_maquinaria === 'function') {
                if (maquinariaModel.actualizar_maquinaria(id_maquinaria, JSON.stringify(equipoData))) {
                    maquinariaModel.cargar_maquinaria();
                    filtrarMaquinaria(txtBuscarEquipo ? txtBuscarEquipo.text : "");
                }
            }
        }
        dialogConfirmacion.open();
    }

    function eliminarEquipoDefinitivo(id_maquinaria) {
        // Buscar el equipo para mostrar su nombre
        var equipoNombre = "";
        for (var i = 0; i < equiposModel.count; i++) {
            var item = equiposModel.get(i);
            if (item.id_maquinaria === id_maquinaria) {
                equipoNombre = item.nombre;
                break;
            }
        }
        
        dialogConfirmacion.mensaje = `¿Está seguro que desea eliminar permanentemente "${equipoNombre}"?\n\nEsta acción:\n• Desactivará el equipo\n• No aparecerá en las listas\n• Se conserva para auditoría`;
        
        dialogConfirmacion.funcionCallback = function() {
            if (maquinariaModel && typeof maquinariaModel.desactivar_maquinaria === 'function') {
                if (maquinariaModel.desactivar_maquinaria(id_maquinaria)) {
                    maquinariaModel.cargar_maquinaria();
                    filtrarMaquinaria(txtBuscarEquipo ? txtBuscarEquipo.text : "");
                }
            }
        }
        dialogConfirmacion.open();
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

        if (item.fecha_realizada) {
            txtFechaMantenimiento.text = item.fecha_realizada;
        }
        
        // Establecer valores en los campos del diálogo
        txtIDMantenimiento.text = item.id_mantenimiento;
        txtDescripcionMantenimiento.text = item.descripcion;
        txtCostoMantenimiento.text = item.costo_total;
        
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
    
    // Función corregida para completar mantenimiento
    function completarMantenimiento(id_mantenimiento) {
        dialogConfirmacion.mensaje = "¿Marcar este mantenimiento como completado?"
        dialogConfirmacion.funcionCallback = function() {
            var mantenimientoData = {
                estado: "Completado",
                fecha_realizada: new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd")
            };
            
            if (maquinariaModel && typeof maquinariaModel.actualizar_mantenimiento === 'function') {
                if (maquinariaModel.actualizar_mantenimiento(id_mantenimiento, JSON.stringify(mantenimientoData))) {
                    maquinariaModel.cargar_mantenimientos();
                    maquinariaModel.cargar_maquinaria();
                    cargarMantenimientosDesdeModelo();
                    cargarMaquinariaDesdeModelo();
                }
            }
        }
        dialogConfirmacion.open()
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
    
    // Función corregida para eliminar compra de combustible
    function eliminarCompraCombustible(id_compra) {
        dialogConfirmacion.mensaje = "¿Está seguro que desea eliminar este registro de compra de combustible? Esta acción no se puede deshacer."
        dialogConfirmacion.funcionCallback = function() {
            if (maquinariaModel && typeof maquinariaModel.eliminar_compra_combustible === 'function') {
                // Asegúrate de usar la cantidad correcta de paréntesis aquí también
                if (maquinariaModel.eliminar_compra_combustible(id_compra)) {
                    maquinariaModel.cargar_compras_combustible();
                    maquinariaModel.cargar_resumen_combustible();
                    cargarComprasCombustibleDesdeModelo();
                }
            }
        }
        dialogConfirmacion.open()
    }
    function obtenerUsuarioActual() {
            // Leer el usuario actual desde el modelo Python
        return maquinariaModel.obtener_usuario_actual();;
    }
    function reactivarEquipo(id_maquinaria) {
        dialogConfirmacion.mensaje = "¿Está seguro que desea poner este equipo en estado Operativo?"
        dialogConfirmacion.funcionCallback = function() {
            var equipoData = {
                estado: "Operativo"
            };
            
            if (maquinariaModel && typeof maquinariaModel.actualizar_maquinaria === 'function') {
                if (maquinariaModel.actualizar_maquinaria(id_maquinaria, JSON.stringify(equipoData))) {
                    maquinariaModel.cargar_maquinaria();
                    filtrarMaquinaria(txtBuscarEquipo ? txtBuscarEquipo.text : "");
                }
            }
        }
        dialogConfirmacion.open();
    }
}