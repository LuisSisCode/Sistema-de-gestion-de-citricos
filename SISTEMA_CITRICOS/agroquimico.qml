import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: agroquimicosRoot
    anchors.fill: parent
    color: "#F8F9FA"

    // Propiedades para manejo de nuevos elementos
    property var nuevoProducto: {
        "productId": "",
        "nombreComercial": "",
        "categoria": "",
        "ingredienteActivo": "",
        "stock": 0,
        "unidad": "Litro",
        "precioUnitario": 0,
        "periodoCarencia": 0,
        "stockMinimo": 0
    }
    
    // Propiedades para nueva categoría
    property var nuevaCategoria: {
        "categoriaId": "",
        "nombre": "",
        "descripcion": "",
        "activo": true
    }
    
    // Propiedades para nueva mezcla
    property var nuevaMezcla: {
        "mezclaId": "",
        "nombre": "",
        "objetivo": "",
        "cantidadAgua": 0,
        "areaAplicacion": 0,
        "componentes": []
    }
    
    // Propiedades para nuevo tratamiento
    property var nuevoTratamiento: {
        "tratamientoId": "",
        "fecha": "",
        "ciclo": "",
        "tipoPlaga": "",
        "area": 0,
        "mezcla": "",
        "costo": 0
    }

    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "GESTIÓN DE PRODUCTOS PARA CONTROL FITOSANITARIO"
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
            text: "Inventario"
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
            text: "Categorías"
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
            text: "Mezclas"
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
            text: "Tratamientos"
            width: implicitWidth + 40
            height:30

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

        // Página de Inventario
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
                        spacing: 15
                        
                        Button {
                            text: "Nuevo Producto"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para el nuevo producto
                                nuevoProducto = {
                                    "productId": "",
                                    "nombreComercial": "",
                                    "categoria": "",
                                    "ingredienteActivo": "",
                                    "stock": 0,
                                    "unidad": "Litro",
                                    "precioUnitario": 0,
                                    "periodoCarencia": 0,
                                    "stockMinimo": 0
                                }
                                
                                // Mostrar diálogo de nuevo producto
                                dialogNuevoProducto.open()
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar producto..."
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas las categorías", "Herbicida", "Insecticida", "Fungicida", "Fertilizante"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Actualizar Stock"
                            icon.source: "Image/Image_UI_interfaz/Inconos/actualizar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: showMessage("Función para actualizar stock no implementada")
                        }
                    }
                }
                
                // Panel de estadísticas de inventario (simplificado para cuando no hay datos)
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Total de productos
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Total Productos"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: productosModel.count.toString()
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Valor del inventario
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Valor Inventario"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 0"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Productos agotados
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Stock Crítico"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "0"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#F44336"
                            }
                        }
                        
                        // Categoría más usada
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Categoría Más Usada"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: productosModel.count > 0 ? "N/A" : "-"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de productos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: productosListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: productosModel
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
                                    text: "Nombre Comercial"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Categoría"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Ingrediente Activo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: "Stock"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: "Precio Unit."
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Período Carencia"
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
                                        text: productId
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Nombre Comercial
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombreComercial
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Categoría
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: categoria
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Ingrediente Activo
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: ingredienteActivo
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Stock
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: stock + " " + unidad
                                        color: stock < stockMinimo ? "#F44336" : "#424242"
                                        font.bold: stock < stockMinimo
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Precio Unitario
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: "Bs. " + precioUnitario
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Período Carencia
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: periodoCarencia + " días"
                                        elide: Text.ElideRight
                                        width: parent.width - 20
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
                                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Agregar Stock"
                                            onClicked: {
                                                // Aquí podríamos abrir un diálogo para agregar stock
                                                showMessage("Función para agregar stock no implementada")
                                            }
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: showMessage("Función para editar producto no implementada")
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
                                                confirmDeleteProductoDialog.productoId = productId
                                                confirmDeleteProductoDialog.nombreProducto = nombreComercial
                                                confirmDeleteProductoDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay productos registrados.\nHaga clic en 'Nuevo Producto' para agregar uno."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: productosModel.count === 0
                        }
                    }
                }
            }
        }

        // Página de Categorías
        Item {
            // Dividir en dos columnas: lista y detalles
            Rectangle {
                id: categoriasList
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
                            text: "Categorías"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Nueva"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para la nueva categoría
                                nuevaCategoria = {
                                    "categoriaId": "",
                                    "nombre": "",
                                    "descripcion": "",
                                    "activo": true
                                }
                                
                                // Mostrar diálogo de nueva categoría
                                dialogNuevaCategoria.open()
                            }
                        }
                    }
                    
                    // Lista de categorías
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: categoriasModel
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
                                    text: descripcion
                                    font.pixelSize: 12
                                    color: "#757575"
                                    elide: Text.ElideRight
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    parent.ListView.view.currentIndex = index
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay categorías registradas.\nHaga clic en 'Nueva' para agregar una."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: categoriasModel.count === 0
                        }
                    }
                }
            }
            
            // Panel de detalles
            Rectangle {
                anchors.left: categoriasList.right
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
                        text: "Detalles de la Categoría"
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
                            Layout.fillWidth: true
                            placeholderText: "Nombre de la categoría"
                            enabled: categoriasModel.count > 0
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
                                text: "Activo"
                                checked: true
                                enabled: categoriasModel.count > 0
                            }
                        }
                        
                        // Descripción
                        Text {
                            text: "Descripción:"
                            font.pixelSize: 14
                        }
                        
                        TextArea {
                            Layout.fillWidth: true
                            Layout.rowSpan: 3
                            Layout.minimumHeight: 100
                            placeholderText: "Descripción de la categoría..."
                            wrapMode: TextArea.Wrap
                            enabled: categoriasModel.count > 0
                        }
                    }
                    
                    // Estadísticas de uso (vacío)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        color: "#F5F5F5"
                        radius: 5
                        
                        Text {
                            anchors.centerIn: parent
                            text: categoriasModel.count > 0 
                                ? "Seleccione una categoría para ver sus estadísticas"
                                : "No hay categorías registradas"
                            color: "#757575"
                            font.pixelSize: 14
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
                            enabled: categoriasModel.count > 0
                        }
                        
                        Button {
                            text: "Guardar Cambios"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            enabled: categoriasModel.count > 0
                            onClicked: showMessage("Función para guardar categoría no implementada")
                        }
                    }
                }
            }
        }

        // Página de Mezclas
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
                        spacing: 15
                        
                        Button {
                            text: "Nueva Mezcla"
                            icon.source: "Image/Image_UI_interfaz/Inconos/mezcla.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para la nueva mezcla
                                nuevaMezcla = {
                                    "mezclaId": "",
                                    "nombre": "",
                                    "objetivo": "",
                                    "cantidadAgua": 0,
                                    "areaAplicacion": 0,
                                    "componentes": []
                                }
                                
                                // Mostrar diálogo de nueva mezcla
                                dialogNuevaMezcla.open()
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar mezcla..."
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los objetivos", "Control de plagas", "Control de enfermedades", "Fertilización"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Grid de tarjetas de mezclas (vacío)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    GridView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: mezclasModel
                        cellWidth: width / 3
                        cellHeight: 220
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay mezclas registradas.\nHaga clic en 'Nueva Mezcla' para agregar una."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: mezclasModel.count === 0
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
                                
                                // Título de la mezcla
                                Text {
                                    text: nombre
                                    font.pixelSize: 16
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                // Objetivo
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    
                                    Text {
                                        text: "Objetivo:"
                                        font.pixelSize: 12
                                        color: "#757575"
                                    }
                                    
                                    Text {
                                        text: objetivo
                                        font.pixelSize: 12
                                    }
                                }
                                
                                // Cantidad de agua
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    
                                    Text {
                                        text: "Agua requerida:"
                                        font.pixelSize: 12
                                        color: "#757575"
                                    }
                                    
                                    Text {
                                        text: cantidadAgua + " litros"
                                        font.pixelSize: 12
                                    }
                                }
                                
                                // Área de aplicación
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
Text {
                                        text: "Área de aplicación:"
                                        font.pixelSize: 12
                                        color: "#757575"
                                    }
                                    
                                    Text {
                                        text: areaAplicacion + " hectáreas"
                                        font.pixelSize: 12
                                    }
                                }
                                
                                // Separador
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: "#EEEEEE"
                                }
                                
                                // Componentes de la mezcla
                                Text {
                                    text: "Componentes:"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                ListView {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 80
                                    model: componentes
                                    clip: true
                                    interactive: true
                                    
                                    delegate: Text {
                                        width: parent.width
                                        text: "• " + nombre + ": " + cantidad + " " + unidad
                                        font.pixelSize: 11
                                        color: "#424242"
                                    }
                                }
                                
                                // Botones de acción
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    
                                    Button {
                                        text: "Ver"
                                        icon.source: "Image/Image_UI_interfaz/Inconos/ojos.svg"
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        font.pixelSize: 12
                                        onClicked: showMessage("Función para ver detalles de mezcla no implementada")
                                    }
                                    
                                    Button {
                                        text: "Editar"
                                        icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        font.pixelSize: 12
                                        onClicked: showMessage("Función para editar mezcla no implementada")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Página de Tratamientos
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
                        spacing: 15
                        
                        Button {
                            text: "Nuevo Tratamiento"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para el nuevo tratamiento
                                nuevoTratamiento = {
                                    "tratamientoId": "",
                                    "fecha": obtenerFechaActual(),
                                    "ciclo": "",
                                    "tipoPlaga": "",
                                    "area": 0,
                                    "mezcla": "",
                                    "costo": 0
                                }
                                
                                // Mostrar diálogo de nuevo tratamiento
                                dialogNuevoTratamiento.open()
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar tratamiento..."
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los ciclos"]
                            implicitHeight: 36
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        ComboBox {
                            Layout.preferredWidth: 150
                            model: ["Último mes", "Últimos 3 meses", "Último año", "Todos"]
                            implicitHeight: 36
                        }
                    }
                }
                
                // Tabla de tratamientos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: tratamientosListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: tratamientosModel
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
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Fecha"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Ciclo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Tipo Plaga/Maleza"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Área (ha)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Mezcla Utilizada"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.11
                                    height: parent.height
                                    text: "Costo"
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
                        
                        // Delegado para cada fila (CORREGIDO)
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
                                        text: tratamientoId
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Fecha
                                Rectangle {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: fecha
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Ciclo
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: ciclo
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Tipo Plaga/Maleza
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: tipoPlaga
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Área
                                Rectangle {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: area
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Mezcla Utilizada
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: mezcla
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Costo
                                Rectangle {
                                    width: parent.width * 0.11
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: "Bs. " + costo
                                        elide: Text.ElideRight
                                        width: parent.width - 20
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
                                            icon.source: "Image/Image_UI_interfaz/Inconos/informacion-del-circulo-de-archivos.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Ver Detalles"
                                            onClicked: showMessage("Función para ver detalles no implementada")
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: showMessage("Función para editar tratamiento no implementada")
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
                                                confirmDeleteTratamientoDialog.tratamientoId = tratamientoId
                                                confirmDeleteTratamientoDialog.nombreTratamiento = ciclo
                                                confirmDeleteTratamientoDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay tratamientos registrados.\nHaga clic en 'Nuevo Tratamiento' para agregar uno."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: tratamientosModel.count === 0
                        }
                    }
                }
            }
        }
    }
    
    // DIÁLOGO DE NUEVO PRODUCTO
    Dialog {
        id: dialogNuevoProducto
        title: "Nuevo Producto Fitosanitario"
        modal: true
        width: 500
        height: 550
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
                    text: "Agregar Nuevo Producto"
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
                    
                    // Nombre Comercial
                    Text {
                        text: "Nombre Comercial:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtNombreComercial
                        placeholderText: "Ingrese nombre comercial"
                        Layout.fillWidth: true
                        onTextChanged: nuevoProducto.nombreComercial = text
                    }
                    
                    // Categoría
                    Text {
                        text: "Categoría:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbCategoria
                        Layout.fillWidth: true
                        model: ["Herbicida", "Insecticida", "Fungicida", "Fertilizante"]
                        onCurrentTextChanged: nuevoProducto.categoria = currentText
                    }
                    
                    // Ingrediente Activo
                    Text {
                        text: "Ingrediente Activo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtIngredienteActivo
                        placeholderText: "Ingrese ingrediente activo"
                        Layout.fillWidth: true
                        onTextChanged: nuevoProducto.ingredienteActivo = text
                    }
                    
                    // Stock Inicial
                    Text {
                        text: "Stock Inicial:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        TextField {
                            id: txtStock
                            Layout.fillWidth: true
                            placeholderText: "Cantidad inicial"
                            validator: DoubleValidator { bottom: 0 }
                            onTextChanged: nuevoProducto.stock = parseFloat(text) || 0
                        }
                        
                        ComboBox {
                            id: cmbUnidad
                            Layout.preferredWidth: 60
                            model: ["Lt", "Kg", "Und"]
                            onCurrentTextChanged: {
                                switch (currentText) {
                                    case "Lt": nuevoProducto.unidad = "Litro"; break;
                                    case "Kg": nuevoProducto.unidad = "Kilogramo"; break;
                                    case "Und": nuevoProducto.unidad = "Unidad"; break;
                                }
                            }
                        }
                    }
                    
                    // Precio Unitario
                    Text {
                        text: "Precio Unitario (Bs):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtPrecioUnitario
                        placeholderText: "Ingrese precio unitario"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: nuevoProducto.precioUnitario = parseFloat(text) || 0
                    }
                    
                    // Período Carencia
                    Text {
                        text: "Período Carencia (días):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtPeriodoCarencia
                        placeholderText: "Ingrese período de carencia"
                        Layout.fillWidth: true
                        validator: IntValidator { bottom: 0 }
                        onTextChanged: nuevoProducto.periodoCarencia = parseInt(text) || 0
                    }
                    
                    // Stock Mínimo
                    Text {
                        text: "Stock Mínimo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtStockMinimo
                        placeholderText: "Ingrese stock mínimo"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: nuevoProducto.stockMinimo = parseFloat(text) || 0
                    }
                    
                    // Fecha de Registro
                    Text {
                        text: "Fecha de Registro:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaRegistroProducto
                        placeholderText: "DD/MM/AAAA"
                        Layout.fillWidth: true
                        readOnly: true
                        text: obtenerFechaActual()
                    }
                    
                    // Observaciones
                    Text {
                        text: "Observaciones:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtObservacionesProducto
                        placeholderText: "Observaciones adicionales (opcional)"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
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
                    id: mensajeValidacionProducto
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
                onClicked: dialogNuevoProducto.close()
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
                    if (txtNombreComercial.text === "" || txtIngredienteActivo.text === "") {
                        mensajeValidacionProducto.text = "Por favor, complete al menos el nombre comercial e ingrediente activo";
                        return;
                    }
                    
                    guardarNuevoProducto();
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            txtNombreComercial.text = ""
            txtIngredienteActivo.text = ""
            txtStock.text = ""
            txtPrecioUnitario.text = ""
            txtPeriodoCarencia.text = ""
            txtStockMinimo.text = ""
            txtObservacionesProducto.text = ""
            cmbCategoria.currentIndex = 0
            cmbUnidad.currentIndex = 0
            mensajeValidacionProducto.text = ""
        }
    }
    
    // DIÁLOGO DE NUEVA CATEGORÍA
    Dialog {
        id: dialogNuevaCategoria
        title: "Nueva Categoría"
        modal: true
        width: 450
        height: 350
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
                    text: "Agregar Nueva Categoría"
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
                        id: txtNombreCategoria
                        placeholderText: "Ingrese nombre de la categoría"
                        Layout.fillWidth: true
                        onTextChanged: nuevaCategoria.nombre = text
                    }
                    
                    // Estado
                    Text {
                        text: "Estado:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    CheckBox {
                        id: chkActivoCategoria
                        text: "Activo"
                        checked: true
                        onCheckedChanged: nuevaCategoria.activo = checked
                    }
                    
                    // Descripción
                    Text {
                        text: "Descripción:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtDescripcionCategoria
                        placeholderText: "Ingrese descripción de la categoría"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        wrapMode: TextArea.Wrap
                        onTextChanged: nuevaCategoria.descripcion = text
                    }
                }
                
                // Espacio adicional
                Item {
                    width: parent.width
                    height: 10
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionCategoria
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
                onClicked: dialogNuevaCategoria.close()
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
                    if (txtNombreCategoria.text === "") {
                        mensajeValidacionCategoria.text = "Por favor, ingrese el nombre de la categoría";
                        return;
                    }
                    
                    guardarNuevaCategoria();
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            txtNombreCategoria.text = ""
            txtDescripcionCategoria.text = ""
            chkActivoCategoria.checked = true
            mensajeValidacionCategoria.text = ""
        }
    }
    
    // DIÁLOGO DE NUEVA MEZCLA
    Dialog {
        id: dialogNuevaMezcla
        title: "Nueva Mezcla"
        modal: true
        width: 550
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
                    text: "Agregar Nueva Mezcla"
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
                        text: "Nombre de la mezcla:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtNombreMezcla
                        placeholderText: "Ingrese nombre de la mezcla"
                        Layout.fillWidth: true
                        onTextChanged: nuevaMezcla.nombre = text
                    }
                    
                    // Objetivo
                    Text {
                        text: "Objetivo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbObjetivoMezcla
                        Layout.fillWidth: true
                        model: ["Control de plagas", "Control de enfermedades", "Fertilización", "Control de malezas"]
                        onCurrentTextChanged: nuevaMezcla.objetivo = currentText
                    }
                    
                    // Cantidad de agua
                    Text {
                        text: "Cantidad de agua (litros):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtCantidadAgua
                        placeholderText: "Ingrese cantidad de agua"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: nuevaMezcla.cantidadAgua = parseFloat(text) || 0
                    }
                    
                    // Área de aplicación
                    Text {
                        text: "Área de aplicación (ha):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtAreaAplicacion
                        placeholderText: "Ingrese área de aplicación"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: nuevaMezcla.areaAplicacion = parseFloat(text) || 0
                    }
                    
                    // Sección de componentes
                    Text {
                        text: "Componentes:"
                        Layout.alignment: Qt.AlignRight
                        font.bold: true
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#EEEEEE"
                    }
                }
                
                // Aquí va la lista de componentes (productos) que forman la mezcla
                Rectangle {
                    width: parent.width
                    height: 200
                    color: "#F5F5F5"
                    radius: 5
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        // Encabezado
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "Producto"
                                font.bold: true
                                Layout.preferredWidth: 180
                            }
                            
                            Text {
                                text: "Cantidad"
                                font.bold: true
                                Layout.preferredWidth: 100
                            }
                            
                            Text {
                                text: "Unidad"
                                font.bold: true
                                Layout.preferredWidth: 80
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                text: "Agregar"
                                implicitHeight: 30
                                background: Rectangle {
                                    color: "#4CAF50"
                                    radius: 15
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    // Aquí añadiríamos otra ventana o sección para agregar componentes
                                    showMessage("Función para agregar componentes a la mezcla no implementada")
                                }
                            }
                        }
                        
                        // Lista de componentes (vacía inicialmente)
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: ListModel {}
                            clip: true
                            
                            delegate: RowLayout {
                                width: parent.width
                                spacing: 10
                                
                                Text {
                                    text: nombre
                                    Layout.preferredWidth: 180
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: cantidad
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: unidad
                                    Layout.preferredWidth: 80
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    icon.source: "Image/Image_UI_interfaz/Inconos/basura.svg"
                                    flat: true
                                    implicitWidth: 30
                                    implicitHeight: 30
                                    onClicked: model.remove(index)
                                }
                            }
                            
                            // Mensaje cuando no hay datos
                            Text {
                                anchors.centerIn: parent
                                text: "No hay componentes añadidos a la mezcla."
                                color: "#757575"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                visible: parent.model.count === 0
                            }
                        }
                    }
                }
                
                // Observaciones
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 15
                    
                    Text {
                        text: "Observaciones:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtObservacionesMezcla
                        placeholderText: "Observaciones adicionales (opcional)"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        wrapMode: TextArea.Wrap
                    }
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionMezcla
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
                onClicked: dialogNuevaMezcla.close()
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
                    if (txtNombreMezcla.text === "" || txtCantidadAgua.text === "" || txtAreaAplicacion.text === "") {
                        mensajeValidacionMezcla.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    guardarNuevaMezcla();
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            txtNombreMezcla.text = ""
            cmbObjetivoMezcla.currentIndex = 0
            txtCantidadAgua.text = ""
            txtAreaAplicacion.text = ""
            txtObservacionesMezcla.text = ""
            mensajeValidacionMezcla.text = ""
            // También habría que resetear la lista de componentes
        }
    }
    
    // DIÁLOGO DE NUEVO TRATAMIENTO
    Dialog {
        id: dialogNuevoTratamiento
        title: "Nuevo Tratamiento"
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
                    text: "Agregar Nuevo Tratamiento"
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
                    
                    // Fecha
                    Text {
                        text: "Fecha:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtFechaTratamiento
                        placeholderText: "DD/MM/AAAA"
                        Layout.fillWidth: true
                        text: nuevoTratamiento.fecha
                        onTextChanged: nuevoTratamiento.fecha = text
                    }
                    
                    // Ciclo de cultivo
                    Text {
                        text: "Ciclo de cultivo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtCiclo
                        placeholderText: "Ingrese ciclo de cultivo"
                        Layout.fillWidth: true
                        onTextChanged: nuevoTratamiento.ciclo = text
                    }
                    
                    // Tipo de plaga/maleza
                    Text {
                        text: "Tipo de plaga/maleza:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbTipoPlaga
                        Layout.fillWidth: true
                        model: ["Insectos", "Hongos", "Malezas", "Bacterias", "Otro"]
                        onCurrentTextChanged: nuevoTratamiento.tipoPlaga = currentText
                    }
                    
                    // Área
                    Text {
                        text: "Área (hectáreas):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtAreaTratamiento
                        placeholderText: "Ingrese área tratada"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: nuevoTratamiento.area = parseFloat(text) || 0
                    }
                    
                    // Mezcla utilizada
                    Text {
                        text: "Mezcla utilizada:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbMezcla
                        Layout.fillWidth: true
                        model: obtenerMezclasModel()
                        onCurrentTextChanged: nuevoTratamiento.mezcla = currentText
                    }
                    
                    // Costo
                    Text {
                        text: "Costo (Bs):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtCostoTratamiento
                        placeholderText: "Ingrese costo total"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: nuevoTratamiento.costo = parseFloat(text) || 0
                    }
                    
                    // Observaciones
                    Text {
                        text: "Observaciones:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtObservacionesTratamiento
                        placeholderText: "Observaciones adicionales (opcional)"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        wrapMode: TextArea.Wrap
                    }
                }
                
                // Mensaje de validación
                Text {
                    id: mensajeValidacionTratamiento
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
                onClicked: dialogNuevoTratamiento.close()
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
                    if (txtFechaTratamiento.text === "" || txtCiclo.text === "" || txtAreaTratamiento.text === "" || cmbMezcla.currentIndex < 0) {
                        mensajeValidacionTratamiento.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    guardarNuevoTratamiento();
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            txtFechaTratamiento.text = obtenerFechaActual() // Fecha actual
            txtCiclo.text = ""
            txtAreaTratamiento.text = ""
            txtCostoTratamiento.text = ""
            txtObservacionesTratamiento.text = ""
            cmbTipoPlaga.currentIndex = 0
            cmbMezcla.currentIndex = 0
            mensajeValidacionTratamiento.text = ""
        }
    }
    
    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR PRODUCTO
    Dialog {
        id: confirmDeleteProductoDialog
        title: "Confirmar eliminación"
        modal: true
        
        property int productoId: -1
        property string nombreProducto: ""
        
        contentItem: Item {
            implicitWidth: 400
            implicitHeight: 100
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    width: parent.width
                    text: "¿Está seguro que desea eliminar el producto '" + confirmDeleteProductoDialog.nombreProducto + "'?"
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
            //     query.prepare("DELETE FROM productos WHERE id = ?")
            //     query.addBindValue(productoId)
            //     
            //     if (!query.exec()) {
            //         console.error("Error al eliminar producto:", query.lastError().text)
            //         showMessage("Error al eliminar el producto")
            //         return
            //     }
            //     
            //     db.close()
            // } else {
            //     console.error("Error de conexión a la base de datos:", db.lastError().text)
            //     showMessage("Error de conexión a la base de datos")
            //     return
            // }
            
            console.log("Eliminando producto con ID:", productoId);
            
            // Eliminar del modelo local
            for (let i = 0; i < productosModel.count; i++) {
                if (productosModel.get(i).productId === productoId) {
                    productosModel.remove(i)
                    break
                }
            }
            
            showMessage("Producto eliminado correctamente")
        }
    }
    
    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR TRATAMIENTO
    Dialog {
        id: confirmDeleteTratamientoDialog
        title: "Confirmar eliminación"
        modal: true
        
        property int tratamientoId: -1
        property string nombreTratamiento: ""
        
        contentItem: Item {
            implicitWidth: 400
            implicitHeight: 100
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    width: parent.width
                    text: "¿Está seguro que desea eliminar el tratamiento para el ciclo '" + confirmDeleteTratamientoDialog.nombreTratamiento + "'?"
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
            // Integración con SQL Server sería similar al diálogo anterior
            
            console.log("Eliminando tratamiento con ID:", tratamientoId);
            
            // Eliminar del modelo local
            for (let i = 0; i < tratamientosModel.count; i++) {
                if (tratamientosModel.get(i).tratamientoId === tratamientoId) {
                    tratamientosModel.remove(i)
                    break
                }
            }
            
            showMessage("Tratamiento eliminado correctamente")
        }
    }
    
    // Función para guardar nuevo producto
    function guardarNuevoProducto() {
        // La validación se hace ahora en el botón Guardar del diálogo
        
        // INTEGRACIÓN CON SQL SERVER:
        // Aquí es donde conectarías con tu base de datos SQL Server
        // Ejemplo:
        // let db = QSqlDatabase.addDatabase("QODBC")
        // db.setDatabaseName("DRIVER={SQL Server};SERVER=tuServidor;DATABASE=tuBaseDeDatos;UID=usuario;PWD=contraseña")
        // if (!db.open()) {
        //     console.error("Error de conexión a la base de datos:", db.lastError().text)
        //     mensajeValidacionProducto.text = "Error de conexión a la base de datos"
        //     return
        // }
        //
        // let query = QSqlQuery()
        // query.prepare("INSERT INTO productos (nombre_comercial, categoria, ingrediente_activo, stock, unidad, precio_unitario, periodo_carencia, stock_minimo, fecha_registro, observaciones) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
        // query.addBindValue(nuevoProducto.nombreComercial)
        // query.addBindValue(nuevoProducto.categoria)
        // query.addBindValue(nuevoProducto.ingredienteActivo)
        // query.addBindValue(nuevoProducto.stock)
        // query.addBindValue(nuevoProducto.unidad)
        // query.addBindValue(nuevoProducto.precioUnitario)
        // query.addBindValue(nuevoProducto.periodoCarencia)
        // query.addBindValue(nuevoProducto.stockMinimo)
        // query.addBindValue(txtFechaRegistroProducto.text)
        // query.addBindValue(txtObservacionesProducto.text)
        //
        // if (!query.exec()) {
        //     console.error("Error al insertar producto:", query.lastError().text)
        //     mensajeValidacionProducto.text = "Error al guardar el producto"
        //     return
        // }
        //
        // // Obtener el ID generado
        // query.exec("SELECT @@IDENTITY as id")
        // let productoId = -1
        // if (query.first()) {
        //     productoId = query.value("id")
        // }
        //
        // db.close()
        
        // Crear un objeto con toda la información del producto
        var datosProducto = {
            productId: productosModel.count + 1,  // ID temporal
            nombreComercial: nuevoProducto.nombreComercial,
            categoria: nuevoProducto.categoria || cmbCategoria.currentText,
            ingredienteActivo: nuevoProducto.ingredienteActivo,
            stock: nuevoProducto.stock,
            unidad: nuevoProducto.unidad,
            precioUnitario: nuevoProducto.precioUnitario,
            periodoCarencia: nuevoProducto.periodoCarencia,
            stockMinimo: nuevoProducto.stockMinimo,
            fechaRegistro: txtFechaRegistroProducto.text,
            observaciones: txtObservacionesProducto.text || ""
        };
        
        console.log("Guardando producto:", JSON.stringify(datosProducto));
        
        // Añadir al modelo local
        productosModel.append(datosProducto)
        
        // Cerrar el diálogo
        dialogNuevoProducto.close()
        
        // Mensaje de éxito
        showMessage("Producto guardado correctamente")
    }
    
    // Función para guardar nueva categoría
    function guardarNuevaCategoria() {
        // La validación se hace en el botón Guardar del diálogo
        
        // INTEGRACIÓN CON SQL SERVER (similar a las otras funciones)
        
        // Crear un objeto con toda la información de la categoría
        var datosCategoria = {
            categoriaId: categoriasModel.count + 1,  // ID temporal
            nombre: nuevaCategoria.nombre,
            descripcion: nuevaCategoria.descripcion || "",
            activo: nuevaCategoria.activo
        };
        
        console.log("Guardando categoría:", JSON.stringify(datosCategoria));
        
        // Añadir al modelo local
        categoriasModel.append(datosCategoria)
        
        // Cerrar el diálogo
        dialogNuevaCategoria.close()
        
        // Mensaje de éxito
        showMessage("Categoría guardada correctamente")
    }
    
    // Función para guardar nueva mezcla
    function guardarNuevaMezcla() {
        // La validación se hace en el botón Guardar del diálogo
        
        // INTEGRACIÓN CON SQL SERVER (similar a las otras funciones)
        
        // Crear un objeto con toda la información de la mezcla
        var datosMezcla = {
            mezclaId: mezclasModel.count + 1,  // ID temporal
            nombre: nuevaMezcla.nombre,
            objetivo: nuevaMezcla.objetivo || cmbObjetivoMezcla.currentText,
            cantidadAgua: nuevaMezcla.cantidadAgua,
            areaAplicacion: nuevaMezcla.areaAplicacion,
            componentes: nuevaMezcla.componentes || [], // Esto debería tener componentes añadidos
            observaciones: txtObservacionesMezcla.text || ""
        };
        
        console.log("Guardando mezcla:", JSON.stringify(datosMezcla));
        
        // Añadir al modelo local
        mezclasModel.append(datosMezcla)
        
        // Cerrar el diálogo
        dialogNuevaMezcla.close()
        
        // Mensaje de éxito
        showMessage("Mezcla guardada correctamente")
    }
    
    // Función para guardar nuevo tratamiento
    function guardarNuevoTratamiento() {
        // La validación se hace en el botón Guardar del diálogo
        
        // INTEGRACIÓN CON SQL SERVER (similar a las otras funciones)
        
        // Crear un objeto con toda la información del tratamiento
        var datosTratamiento = {
            tratamientoId: tratamientosModel.count + 1,  // ID temporal
            fecha: nuevoTratamiento.fecha,
            ciclo: nuevoTratamiento.ciclo,
            tipoPlaga: nuevoTratamiento.tipoPlaga || cmbTipoPlaga.currentText,
            area: nuevoTratamiento.area,
            mezcla: nuevoTratamiento.mezcla || cmbMezcla.currentText,
            costo: nuevoTratamiento.costo,
            observaciones: txtObservacionesTratamiento.text || ""
        };
        
        console.log("Guardando tratamiento:", JSON.stringify(datosTratamiento));
        
        // Añadir al modelo local
        tratamientosModel.append(datosTratamiento)
        
        // Cerrar el diálogo
        dialogNuevoTratamiento.close()
        
        // Mensaje de éxito
        showMessage("Tratamiento guardado correctamente")
    }
    
    // Función para obtener los nombres de mezclas para el ComboBox
    function obtenerMezclasModel() {
        var mezclas = ["Seleccione una mezcla"];
        for (var i = 0; i < mezclasModel.count; i++) {
            mezclas.push(mezclasModel.get(i).nombre);
        }
        return mezclas;
    }
    
    // Función para obtener la fecha actual formateada
    function obtenerFechaActual() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
        var yyyy = today.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
    }

    // Modelos de datos vacíos
    ListModel {
        id: productosModel
        // Se agregarán elementos cuando el usuario los cree
    }

    ListModel {
        id: categoriasModel
        // Se agregarán elementos cuando el usuario los cree
    }
    
    ListModel {
        id: mezclasModel
        // Se agregarán elementos cuando el usuario los cree
    }
    
    ListModel {
        id: tratamientosModel
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
}                                                                       