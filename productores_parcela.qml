import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15


Rectangle {
    id: productoresParcelaRoot
    anchors.fill: parent
    color: "#F8F9FA"

    // Propiedades para emitir señales
    property bool modelReady: false
    property bool productoresLoaded: false
    // Controlar cuando el modelo está disponible
    onProductoresparcelasChanged: {
        if (productoresparcelas) {
            productoresparcelas.cargar_productores()
            productoresparcelas.cargar_parcelas()
            modelReady = true
        }
    }

    property double latitudSeleccionada: -17.4001
    property double longitudSeleccionada: -63.9260  
    // Propiedades para la edición de productores
    property var nuevoProductor: {  
        "nombre": "", 
        "apellido": "", 
        "identificacion": "", 
        "telefono": "", 
        "correo": "",
        "direccion": "",
        "esPropietario": false

    }
    
    // Propiedades para la edición de parcelas
    property var nuevaParcela: {
        "nombre": "",
        "propietario": "",
        "ubicacion": "",
        "area": 0,
        "porcentajeUso": 0,
        "latitud": 0,
        "longitud": 0
    }
    // Propiedades de paginación para productores
    property int paginaActualProductores: 1
    property int totalPaginasProductores: 1
    property int productoresPorPagina: 6

    // Propiedades de paginación para parcelas
    property int paginaActualParcelas: 1
    property int totalPaginasParcelas: 1
    property int parcelasPorPagina: 3
    
    // productoresparcelas
    property var productoresparcelas: contentContainer.productoresModel

    Component.onCompleted: {
        if (!productoresparcelas && contentContainer.productoresModel) {
            productoresparcelas = contentContainer.productoresModel;
        }
        //console.log("Modelo disponible:", productoresparcelas !== null)
        if (productoresparcelas) {
            console.log("Tipo de productoresparcelas.productores:", typeof productoresparcelas.productores)
            console.log("Es array:", Array.isArray(productoresparcelas.productores))
            
            if (productoresparcelas.productores) {
                console.log("Número de productores:", productoresparcelas.productores.length)
                if (productoresparcelas.productores.length > 0) {
                    console.log("Primer agricultor:", JSON.stringify(productoresparcelas.productores[0]))
                }
            }
            
            // Cargar explícitamente los datos
            productoresparcelas.cargar_productores_pagina(1)
            productoresparcelas.cargar_parcelas_pagina(1)
        }
    }
    
    Connections {
        target: productoresparcelas ? productoresparcelas : null
        ignoreUnknownSignals: true
        
        function onProductoresChanged() {
            if (productoresparcelas) {
                productoresLoaded = true
                productoresListView.model = productoresparcelas.productores
                paginaActualProductores = productoresparcelas.paginaActualProductores || 1
                totalPaginasProductores = productoresparcelas.totalPaginasProductores || 1
                console.log("Productores actualizados:", productoresparcelas.productores.length)
            }
        }
        
        function onParcelasChanged() {
            if (productoresparcelas) {
                parcelasGrid.model = productoresparcelas.parcelas
                paginaActualParcelas = productoresparcelas.paginaActualParcelas || 1
                totalPaginasParcelas = productoresparcelas.totalPaginasParcelas || 1
                console.log("Parcelas actualizadas:", productoresparcelas.parcelas.length)
                console.log("Página parcelas:", paginaActualParcelas, "de", totalPaginasParcelas)
            }
        }
        
        function onPropietariosChanged() {
            console.log("Propietarios actualizados:", productoresparcelas.propietarios.length)
        }
    }
    
    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 30
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
                        icon.source: "recursos/image/icons/agregar-usuario.svg"
                        implicitHeight: 36
                        background: Rectangle {
                            color: parent.hovered ? "#E65A00" : "#f5922f"
                            radius: height / 2
                        }
                        onClicked: {
                            // Inicializa los valores para el nuevo agricultor
                            nuevoProductor = {  
                                "nombre": "", 
                                "apellido": "", 
                                "identificacion": "", 
                                "telefono": "", 
                                "correo": "",
                                "direccion": "", 
                                "esPropietario": false 
                            }
                            
                            // Mostrar el diálogo de nuevo agricultor
                            dialogNuevoAgricultor.open()
                        }
                    }

                    TextField {
                        id: txtBuscarAgricultor
                        placeholderText: "Buscar agricultor..."
                        implicitWidth: 400
                        implicitHeight: 28
                        leftPadding: 30

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
                            if (text.length > 2) {
                                var resultados = productoresparcelas.filtrar_productores_por_nombre(text)
                                productoresListView.model = resultados
                            } else if (text.length === 0) {
                                // Restaurar la lista completa
                                productoresListView.model = productoresparcelas.productores
                            }
                        }
                    }
                }
            }

            // Tabla de productores
            Rectangle {
                anchors.top: actionBar.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: navegacionProductores.top
                anchors.bottomMargin: 10
                color: "white"
                radius: 5
                border.color: "#EEEEEE"

                BusyIndicator {
                    anchors.centerIn: parent
                    running: !productoresLoaded && modelReady
                    visible: running
                }

                ListView {
                    id: productoresListView
                    anchors.fill: parent
                    anchors.margins: 1
                    clip: true
                    model: productoresparcelas ? productoresparcelas.productores : []
                    onModelChanged: {
                        console.log("Modelo de productores cambiado, elementos:", model ? model.length : 0)
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
                                text: "Nombre Completo"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.10
                                height: parent.height
                                text: "Identificación"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.10
                                height: parent.height
                                text: "Teléfono"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.20
                                height: parent.height
                                text: "Correo"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.20
                                height: parent.height
                                text: "Direcciones"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            Text {
                                width: parent.width * 0.20
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
                        width: productoresParcelaRoot.width
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
                                    text: modelData.id_productor 
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            // Columna Nombre Completo
                            Rectangle {
                                width: parent.width * 0.15
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.nombre + " " + modelData.apellido
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Identificación
                            Rectangle {
                                width: parent.width * 0.10
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.identificacion
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Teléfono
                            Rectangle {
                                width: parent.width * 0.10
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.telefono
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Correo
                            Rectangle {
                                width: parent.width * 0.20
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.correo
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }

                            // Columna Direccion
                            Rectangle {
                                width: parent.width * 0.20
                                height: parent.height
                                color: "transparent"
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: modelData.direccion
                                    elide: Text.ElideRight
                                    width: parent.width - 20
                                }
                            }
                            

                            // Columna Acciones
                            Rectangle {
                                width: parent.width * 0.20
                                height: parent.height
                                color: "transparent"
                                
                                Row {
                                    spacing: 10
                                    anchors.centerIn: parent
                                    
                                    Button {
                                        width: 36
                                        height: 36
                                        icon.source: "recursos/image/icons/editar.svg"
                                        flat: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Editar"
                                        onClicked:{
                                            // Cargar datos del agricultor a editar
                                            nuevoProductor = {
                                                "id_productor": modelData.id_productor,
                                                "nombre": modelData.nombre,
                                                "apellido": modelData.apellido,
                                                "identificacion": modelData.identificacion,
                                                "telefono": modelData.telefono,
                                                "correo": modelData.correo,
                                                "direccion": modelData.direccion,
                                                "esPropietario":Boolean(modelData.esPropietario) ? true : false
                                            }
                                             // Actualizar controles del formulario
                                            txtNombre.text = modelData.nombre
                                            txtApellido.text = modelData.apellido
                                            txtIdentificacion.text = modelData.identificacion
                                            txtTelefono.text = modelData.telefono
                                            txtCorreo.text = modelData.correo
                                            txtDireccion.text = modelData.direccion
                                            chkPropietario.checked = Boolean(modelData.esPropietario) || false // modificado
                                            
                                            // Configurar el diálogo para modo edición
                                            dialogNuevoAgricultor.isEditMode = true
                                            dialogNuevoAgricultor.title = "Editar Agricultor"
                                            dialogNuevoAgricultor.open()
                                        }
                                    }
                                    
                                    Button {
                                        width: 36
                                        height: 36
                                        icon.source: "recursos/image/icons/basura.svg"
                                        flat: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Eliminar"
                                        onClicked: {
                                            // Mostrar diálogo de confirmación de eliminación
                                            confirmDeleteProductorDialog.agricultorId = modelData.id_productor
                                            confirmDeleteProductorDialog.nombreProductor = modelData.nombre + " " + modelData.apellido
                                            confirmDeleteProductorDialog.open()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Mensaje cuando no hay datos
                    Text {
                        anchors.centerIn: parent
                        text: "No hay productores registrados.\nHaga clic en 'Nuevo Productor' para agregar uno."
                        color: "#757575"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        visible: productoresarcelas && productoresparcelas.productores && productoresparcelas.productores.length === 0
                    }
                }
            }
            Rectangle{
                id: navegacionProductores
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                color: "transparent"

                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Button {
                        text: "← Anterior"
                        enabled: paginaActualProductores > 1
                        onClicked: productoresparcelas.pagina_anterior_productores()
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Página " + paginaActualProductores + " de " + totalPaginasProductores
                        font.pixelSize: 14
                    }
                    
                    Button {
                        text: "Siguiente →"
                        enabled: paginaActualProductores < totalPaginasProductores
                        onClicked: productoresparcelas.pagina_siguiente_productores()
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
                        icon.source: "recursos/image/icons/agregar-documento.svg"
                        implicitHeight: 36
                        background: Rectangle {
                            color: parent.hovered ? "#E65A00" : "#f5922f"
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
                        implicitWidth: 450
                        implicitHeight: 28
                        leftPadding: 30
                        
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
                                source: "recursos/image/icons/lupa.png" // lupa.png
                                width: 16
                                height: 16
                            }
                        }
                        onTextChanged: {
                            if (text.length > 2) {
                                var resultados = productoresparcelas.filtrar_parcelas_por_nombre(text)
                                parcelasGrid.model = resultados
                            } else if (text.length === 0) {
                                // Restaurar la lista completa
                                parcelasGrid.model = productoresparcelas.parcelas
                            }
                        }
                    }

                    ComboBox {
                        id: cmbFiltroAgricultores
                        implicitWidth: 200
                        implicitHeight: 36
                        
                        // Modelo inicial con la opción "Todos los productores"
                        model: {
                            var items = [{ id: 0, nombre: "Todos los productores" }];
                            if (productoresparcelas && productoresparcelas.propietarios) {
                                // Agregar los propietarios de la lista
                                items = items.concat(productoresparcelas.propietarios);
                            }
                            return items;
                        }
                        
                        // Configurar las propiedades necesarias para mostrar y seleccionar correctamente
                        textRole: "nombre"
                        valueRole: "id"
                        
                        // Cuando se cambia la selección, filtrar las parcelas
                        onActivated: {
                            var selectedId = cmbFiltroAgricultores.currentValue;
                            if (selectedId === 0) {
                                parcelasGrid.model = productoresparcelas.parcelas;
                            } else {
                                parcelasGrid.model = productoresparcelas.obtener_parcelas_por_propietario(selectedId);
                            }

                        }
                        
                        // Actualizar cuando cambien los datos
                        Connections {
                            target: productoresparcelas ? productoresparcelas : null
                            
                            function onPropietariosChanged() {
                                // Recrear el modelo con la opción "Todos" + la lista de propietarios
                                var items = [{ id: 0, nombre: "Todos los productores" }];
                                if (productoresparcelas && productoresparcelas.propietarios) {
                                    items = items.concat(productoresparcelas.propietarios);
                                }
                                cmbFiltroAgricultores.model = items;
                            }
                            
                            function onParcelasChanged() {
                                // Si está seleccionado un propietario específico, actualizar el filtro
                                var selectedId = cmbFiltroAgricultores.currentValue;
                                if (selectedId === 0) {
                                    parcelasGrid.model = productoresparcelas.parcelas;
                                } else {
                                    parcelasGrid.model = productoresparcelas.obtener_parcelas_por_propietario(selectedId);
                                }
                            }
                        }
                    }
                }
            }

            // Tarjetas de parcelas (contenedor vacío)
            GridView {
                id: parcelasGrid
                anchors.top: parcelasActionBar.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: navegacionParcelas.top
                anchors.bottomMargin: 10
                clip: true
                model: productoresparcelas ? productoresparcelas.parcelas : []
                onModelChanged: {
                    console.log("Modelo de parcelas cambiado, elementos:", model ? model.length : 0)
                }
                cellWidth: width / 3
                cellHeight: 200
                
                // Mensaje cuando no hay datos
                Text {
                    anchors.centerIn: parent
                    text: "No hay parcelas registradas.\nHaga clic en 'Nueva Parcela' para agregar una."
                    color: "#757575"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    visible: productoresparcelas && productoresparcelas.parcelas && productoresparcelas.parcelas.length === 0
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
                            text: modelData.nombre
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
                                text: modelData.propietario
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
                                text: modelData.ubicacion
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
                                text: modelData.area + " hectáreas"
                                font.pixelSize: 12
                            }
                        }

                        // Gráfico visual del uso de la parcela
                        Rectangle {
                            Layout.fillWidth: true
                            height: 20
                            color: "#2b2a2a"
                            radius: 10

                            Rectangle {
                                width: parent.width * modelData.porcentajeUso / 100
                                height: parent.height
                                color: "#2E7D32"
                                radius: 10
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.porcentajeUso + "% en uso"
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
                                onClicked: {
                                    dialogDetallesParcela.parcela = modelData
                                    dialogDetallesParcela.open()
                                }
                            }

                            Button {
                                text: "Editar"
                                Layout.fillWidth: true
                                implicitHeight: 30
                                font.pixelSize: 12
                                onClicked: abrirEdicionParcela(modelData)
                            }
                        }
                    }
                }
            }
            // Panel de navegación para parcelas
            Rectangle {
                id: navegacionParcelas
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                color: "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Button {
                        text: "← Anterior"
                        enabled: paginaActualParcelas > 1
                        onClicked: productoresparcelas.pagina_anterior_parcelas()
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Página " + paginaActualParcelas + " de " + totalPaginasParcelas
                        font.pixelSize: 14
                    }
                    
                    Button {
                        text: "Siguiente →"
                        enabled: paginaActualParcelas < totalPaginasParcelas
                        onClicked: productoresparcelas.pagina_siguiente_parcelas()
                    }
                }
            } 
        }


        // Página de Mapa
        Item {
            anchors.fill: parent
            MapaInteractivo {
                id: mapaInteractivo
                anchors.fill: parent
                anchors.margins: 10
            }
        }
    }
    
    // DIÁLOGO DE NUEVO AGRICULTOR
    Dialog {
        id: dialogNuevoAgricultor
        title: "Nuevo Agricultor"
        modal: true
        width: 500
        height: 600
        property bool isEditMode: false
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
                    text: "Agregar Nuevo Productor"
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
                        onTextChanged: nuevoProductor.nombre = text
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
                        onTextChanged: nuevoProductor.apellido = text
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
                        onTextChanged: nuevoProductor.identificacion = text
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
                        onTextChanged: nuevoProductor.telefono = text
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
                        onTextChanged: nuevoProductor.correo = text
                    }
                    // Dirección
                    Text {
                        text: "Dirección:"
                        Layout.alignment: Qt.AlignRight
                    }

                    TextField {
                        id: txtDireccion
                        placeholderText: "Ingrese dirección"
                        Layout.fillWidth: true
                        onTextChanged: nuevoProductor.direccion = text
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
                    // Verificar si está en modo edición o creación
                    if (dialogNuevoAgricultor.isEditMode) {
                        editarProductor();
                    } else {
                        guardarNuevoProductor();
                    }
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
            txtDireccion.text = ""
            chkPropietario.checked = false
            mensajeValidacionAgricultor.text = ""
            isEditMode = false
            title = "Nuevo Productor"  // Restaurar el título original
        }
    }
    // DIÁLOGO DE NUEVA PARCELA
    Dialog {
        id: dialogNuevaParcela
        title: "Nueva Parcela"
        modal: true
        width: 600
        height: 700
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        property bool isEditMode: false
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
                        model: productoresparcelas ? productoresparcelas.propietarios : []
                        textRole: "nombre"
                        valueRole: "id"

                        // Actualizar cuando cambien los propietarios
                        Connections {
                            target: productoresparcelas ? productoresparcelas : null
                            function onPropietariosChanged() {
                                cmbPropietario.model = productoresparcelas ? productoresparcelas.propietarios : [];
                            }
                        }
                        
                        onActivated: {
                            var selectedId = cmbPropietario.currentValue
                            nuevaParcela.propietarioId = selectedId
                        }
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
                    // Latitud
                    Text {
                        text: "Latitud:"
                        Layout.alignment: Qt.AlignRight
                    }

                    TextField {
                        id: txtLatitud
                        placeholderText: "Ej: -16.5430"
                        Layout.fillWidth: true
                        validator: DoubleValidator {}
                        onTextChanged: {
                            if (text.trim() !== "")
                                nuevaParcela.latitud = parseFloat(text)
                        }
                    }

                    // Longitud
                    Text {
                        text: "Longitud:"
                        Layout.alignment: Qt.AlignRight
                    }

                    TextField {
                        id: txtLongitud
                        placeholderText: "Ej: -68.1025"
                        Layout.fillWidth: true
                        validator: DoubleValidator {}
                        onTextChanged: {
                            if (text.trim() !== "")
                                nuevaParcela.longitud = parseFloat(text)
                        }
                    }

                    // También puedes agregar un botón para abrir un selector de mapa
                    Button {
                        text: "Seleccionar en mapa"
                        Layout.columnSpan: 2
                        Layout.alignment: Qt.AlignCenter
                        onClicked: selectorUbicacionDialog.open()
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
                    
                    if (dialogNuevaParcela.isEditMode) {
                        editarParcela();
                    } else {
                        guardarNuevaParcela();
                    }
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
    // Agregar este diálogo a tu archivo principal
    Dialog {
        id: selectorUbicacionDialog
        title: "Seleccionar ubicación"
        modal: true
        width: 600
        height: 500
        
        contentItem: Rectangle {
            color: "white"
            
            Plugin {
                id: selectorMapPlugin
                name: "osm"
            }
            
            Map {
                id: selectorMapa
                anchors.fill: parent
                anchors.margins: 10
                plugin: selectorMapPlugin
                center: QtPositioning.coordinate(-16.5000, -68.1500) // Ajusta según tu ubicación
                zoomLevel: 13
                
                // Marcador movible
                MapQuickItem {
                    id: selectorMarker
                    coordinate: selectorMapa.center
                    anchorPoint.x: selectorIcon.width/2
                    anchorPoint.y: selectorIcon.height
                    
                    sourceItem: Image { 
                        id: selectorIcon
                        source: "Image/Image_UI_interfaz/Inconos/marcado_de_mapa.svg"
                        width: 30
                        height: 30
                    }
                }
                
                // Permitir que el usuario haga clic en el mapa para colocar el marcador
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var coordinate = selectorMapa.toCoordinate(Qt.point(mouseX, mouseY))
                        selectorMarker.coordinate = coordinate
                    }
                }
            }
            
            Text {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 10
                text: "Haz clic en el mapa para seleccionar la ubicación de la parcela"
                font.pixelSize: 14
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Confirmar ubicación"
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
            }
        }
        
        onAccepted: {
            // Guardar coordenadas en los campos del formulario
            txtLatitud.text = selectorMarker.coordinate.latitude.toFixed(6)
            txtLongitud.text = selectorMarker.coordinate.longitude.toFixed(6)
        }
    }

    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR AGRICULTOR
    Dialog {
        id: confirmDeleteAgricultorDialog
        title: "Confirmar eliminación"
        modal: true
        width: 400  
        height: 200
        
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
            var exito = productoresparcelas.eliminar_agricultor(confirmDeleteAgricultorDialog.agricultorId);
            if (exito) {
                showMessage("Agricultor eliminado correctamente")
            } else {
                showMessage("No se pudo eliminar el agricultor")
            }
        }     
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
    // DIÁLOGO DE DETALLES DE PARCELA
    Dialog {
        id: dialogDetallesParcela
        title: "Detalles de Parcela"
        modal: true
        width: 600
        height: 650
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        property var parcela: null

        // Agrega esto después de la definición del diálogo
        onOpened: {
            if (parcela && detailsMap) {
                var lat, lng;
                
                // Intentar obtener coordenadas de propiedades específicas
                if (parcela.latitud && parcela.longitud) {
                    lat = parcela.latitud;
                    lng = parcela.longitud;
                } 
                // Alternativamente, parsear coordenadasGPS
                else if (parcela.coordenadasGPS) {
                    var coordParts = parcela.coordenadasGPS.split(',');
                    if (coordParts.length === 2) {
                        lat = parseFloat(coordParts[0]);
                        lng = parseFloat(coordParts[1]);
                    }
                }
                
                if (lat && lng) {
                    detailsMap.center = QtPositioning.coordinate(lat, lng);
                    detailsMap.zoomLevel = 14;
                    detailsMapMarker.coordinate = detailsMap.center;
                    detailsMapMarker.visible = true;
                }
            }
        }
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Título
                Text {
                    text: dialogDetallesParcela.parcela ? dialogDetallesParcela.parcela.nombre : ""
                    font.pixelSize: 24
                    font.bold: true
                    width: parent.width
                }
                
                // Contenido de detalles
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 15
                    
                    // Propietario
                    Text {
                        text: "Propietario:"
                        font.bold: true
                    }
                    
                    Text {
                        text: dialogDetallesParcela.parcela ? dialogDetallesParcela.parcela.propietario : ""
                        Layout.fillWidth: true
                    }
                    
                    // Ubicación
                    Text {
                        text: "Ubicación:"
                        font.bold: true
                    }
                    
                    Text {
                        text: dialogDetallesParcela.parcela ? dialogDetallesParcela.parcela.ubicacion : ""
                        Layout.fillWidth: true
                    }
                    
                    // Área
                    Text {
                        text: "Área:"
                        font.bold: true
                    }
                    
                    Text {
                        text: dialogDetallesParcela.parcela ? dialogDetallesParcela.parcela.area + " hectáreas" : ""
                        Layout.fillWidth: true
                    }
                    
                    // Coordenadas GPS
                    Text {
                        text: "Coordenadas GPS:"
                        font.bold: true
                    }
                    
                    Text {
                        text: {
                            if (!dialogDetallesParcela.parcela) return "";
                    
                            // Intentar obtener coordenadas de latitud/longitud específicas
                            if (dialogDetallesParcela.parcela.latitud && dialogDetallesParcela.parcela.longitud) {
                                return "Lat: " + dialogDetallesParcela.parcela.latitud.toFixed(6) + ", Lng: " + dialogDetallesParcela.parcela.longitud.toFixed(6);
                            }
                            
                            // Alternativamente, usar coordenadasGPS si está disponible
                            if (dialogDetallesParcela.parcela.coordenadasGPS) {
                                return dialogDetallesParcela.parcela.coordenadasGPS;
                            }
                            
                            return "No disponibles";
                        }
                        Layout.fillWidth: true
                    }
                    
                    // Porcentaje de uso
                    Text {
                        text: "Porcentaje de uso:"
                        font.bold: true
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 20
                        color: "#d6d1d1"
                        radius: 10
                        
                        Rectangle {
                            width: parent.width * (dialogDetallesParcela.parcela ? dialogDetallesParcela.parcela.porcentajeUso / 100 : 0)
                            height: parent.height
                            color: "#2E7D32"
                            radius: 10
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text:(dialogDetallesParcela.parcela ? dialogDetallesParcela.parcela.porcentajeUso : 0) + "% en uso"
                            color: "black"
                        }
                    }
                    
                    // Fecha de adquisición
                    Text {
                        text: "Fecha de adquisición:"
                        font.bold: true
                    }
                    
                    Text {
                        text: dialogDetallesParcela.parcela ? (dialogDetallesParcela.parcela.fechaAdquisicion || "No disponible") : ""
                        Layout.fillWidth: true
                    }
                }
                
                // Mapa pequeño
                Rectangle {
                    id: detailsMapContainer
                    width: parent.width
                    height: 200
                    color: "#F5F5F5"
                    border.color: "#DDDDDD"
                    
                    Plugin {
                        id: detailsMapPlugin
                        name: "osm"
                    }
                    Map {
                        id: detailsMap
                        anchors.fill: parent
                        anchors.margins: 5
                        plugin: detailsMapPlugin

                        // Establecer centro y nivel de zoom cuando se cargue el diálogo
                        Component.onCompleted: {
                            if (dialogDetallesParcela.parcela) {
                                var lat, lng;
                                
                                // Intentar obtener coordenadas de propiedades específicas
                                if (dialogDetallesParcela.parcela.latitud && dialogDetallesParcela.parcela.longitud) {
                                    lat = dialogDetallesParcela.parcela.latitud;
                                    lng = dialogDetallesParcela.parcela.longitud;
                                } 
                                // Alternativamente, parsear coordenadasGPS
                                else if (dialogDetallesParcela.parcela.coordenadasGPS) {
                                    var coordParts = dialogDetallesParcela.parcela.coordenadasGPS.split(',');
                                    if (coordParts.length === 2) {
                                        lat = parseFloat(coordParts[0]);
                                        lng = parseFloat(coordParts[1]);
                                    }
                                }
                                
                                if (lat && lng) {
                                    center = QtPositioning.coordinate(lat, lng);
                                    zoomLevel = 14;
                                    detailsMapMarker.coordinate = center;
                                    detailsMapMarker.visible = true;
                                }
                            }
                        }
                        MapQuickItem {
                           id: detailsMapMarker
                            visible: false
                            anchorPoint.x: 16
                            anchorPoint.y: 16
                            
                            sourceItem: Rectangle {
                                width: 32
                                height: 32
                                color: "transparent"
                                
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "#F44336"
                                    border.color: "white"
                                    border.width: 2
                                }
                            } 
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "Coordenadas no disponibles para esta parcela"
                            color: "#757575"
                            visible: {
                                if (!dialogDetallesParcela.parcela) return true;
                                
                                if (dialogDetallesParcela.parcela.latitud && dialogDetallesParcela.parcela.longitud) {
                                    return false;
                                }
                                
                                if (dialogDetallesParcela.parcela.coordenadasGPS) {
                                    var coordParts = dialogDetallesParcela.parcela.coordenadasGPS.split(',');
                                    return !(coordParts.length === 2);
                                }
                                
                                return true;
                            }
                        }
                    }
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cerrar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Editar Parcela"
                DialogButtonBox.buttonRole: DialogButtonBox.ActionRole
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
                    dialogDetallesParcela.close()
                    abrirEdicionParcela(parcela)
                }
            }
        }
    }

    // Funciones para el Mapa
    // Funciones para gestionar el servicio de mapas
    function inicializar_servicio_mapa() {
        // Llamar a Python para iniciar el servicio
        var exito = contentContainer.iniciarServicioMapa()
        console.log("Resultado inicio servicio:", exito)
        return exito
    }

    function obtener_url_mapa() {
        return contentContainer.obtenerUrlMapa()
    }

    function obtenerPropietariosModel() {
            var propietariosArray = [];
            if (productoresparcelas && productoresparcelas.propietarios) {
                for (var i = 0; i < productoresparcelas.propietarios.length; i++) {
                    propietariosArray.push({
                    id: productoresparcelas.propietarios[i].id,
                    text: productoresparcelas.propietarios[i].nombre
                    });
                }
            }
            return propietariosArray;
        }

        function guardarNuevoProductor() {
            // Asegúrate de que nuevoProductor tenga todos los campos requeridos
            nuevoProductor.fecha_registro = getFormattedDate();
            // Asegúrate de que esPropietario sea booleano
            nuevoProductor.esPropietario = nuevoProductor.esPropietario ? true : false;
            
            var agricultor_json = JSON.stringify(nuevoProductor);
            var exito = productoresparcelas.agregar_agricultor(agricultor_json);
            
            if (exito) {
                showMessage("Agricultor guardado correctamente");
                dialogNuevoAgricultor.close();
            } else {
                mensajeValidacionAgricultor.text = "Error al guardar el agricultor";
        }
    }
    
    function guardarNuevaParcela() {
        // Buscar el id del propietario seleccionado
        // Tu código existente aquí...
        
        // Agregar las coordenadas al objeto nuevaParcela
        nuevaParcela.latitud = parseFloat(txtLatitud.text) || null;
        nuevaParcela.longitud = parseFloat(txtLongitud.text) || null;
        
        var parcela_json = JSON.stringify(nuevaParcela);
        var exito = productoresparcelas.agregar_parcela(parcela_json);
        
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

    // Función para formatear la fecha
    function getFormattedDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
        var yyyy = today.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
    }
    function editarProductor() {
        // Crear objeto con los datos actualizados
        var agricultor_actualizado = {
            "nombre": nuevoProductor.nombre,
            "apellido": nuevoProductor.apellido,
            "identificacion": nuevoProductor.identificacion,
            "telefono": nuevoProductortelefono,
            "correo": nuevoProductor.correo,
            "direccion": nuevoProductor.direccion,
            "esPropietario": nuevoProductor.esPropietario
        }
        
        // Enviar al modelo para actualizar
        var exito = productoresparcelas.actualizar_productor(nuevoProductor.id_productor, JSON.stringify(agricultor_actualizado))
        
        if (exito) {
            showMessage("Productor actualizado correctamente")
            dialogNuevoProductor.close()
        } else {
            mensajeValidacionProductor.text = "Error al actualizar el agricultor"
        }
    }
    function abrirEdicionParcela(parcela) {
        // Cargar los datos de la parcela al objeto nuevaParcela
        nuevaParcela = {
            "parcelaId": parcela.parcelaId,
            "nombre": parcela.nombre,
            "propietarioId": parcela.propietarioId,
            "ubicacion": parcela.ubicacion,
            "area": parcela.area,
            "porcentajeUso": parcela.porcentajeUso,
            "latitud": parcela.latitud,
            "longitud": parcela.longitud
        }
        
        // Actualizar controles del formulario
        txtNombreParcela.text = parcela.nombre
        txtUbicacion.text = parcela.ubicacion
        txtArea.text = parcela.area.toString()
        txtLatitud.text = parcela.latitud ? parcela.latitud.toString() : ""
        txtLongitud.text = parcela.longitud ? parcela.longitud.toString() : ""
        sliderPorcentajeUso.value = parcela.porcentajeUso
        
        // Seleccionar el propietario en el combobox
        for(var i = 0; i < cmbPropietario.count; i++) {
            if(cmbPropietario.model[i].id === parcela.propietarioId) {
                cmbPropietario.currentIndex = i
                break
            }
        }
        
        // Configurar el diálogo para modo edición
        dialogNuevaParcela.isEditMode = true
        dialogNuevaParcela.title = "Editar Parcela"
        dialogNuevaParcela.open()
    }
    function editarParcela() {
        // Crear objeto con los datos actualizados
        var parcela_actualizada = {
            "nombre": nuevaParcela.nombre,
            "propietarioId": nuevaParcela.propietarioId,
            "ubicacion": nuevaParcela.ubicacion,
            "area": parseFloat(txtArea.text),
            "porcentajeUso": sliderPorcentajeUso.value,
            "latitud": parseFloat(txtLatitud.text),
            "longitud": parseFloat(txtLongitud.text)
        }
        
        // Enviar al modelo para actualizar (necesitarás agregar este método en productores_parcelas_model.py)
        var exito = productoresparcelas.actualizar_parcela(nuevaParcela.parcelaId, JSON.stringify(parcela_actualizada))
        
        if (exito) {
            showMessage("Parcela actualizada correctamente")
            dialogNuevaParcela.close()
        } else {
            mensajeValidacionParcela.text = "Error al actualizar la parcela"
        }
    }
}