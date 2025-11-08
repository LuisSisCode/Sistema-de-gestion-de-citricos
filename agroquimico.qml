import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: agroquimicosRoot
    anchors.fill: parent
    color: "#F8F9FA"

    property var mezcla: null
    property var detalles: []
    property var tratamiento: null

    property var nuevoProducto: {
        "id_producto": "",
        "id_categoria": "",
        "nombre_comercial": "",
        "formulacion": "Líquido",
        "unidad": "L",
        "precio": 0,
        "stock": 0,
        "registro": "PENDIENTE",
        "notas": "",
        "fecha_registro": obtenerFechaActual(),
        "activo": true
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

    // Conexión con el modelo de Python
    Component.onCompleted: {
        actualizarDatos()
    }

    function actualizarDatos() {
        if ( typeof agroquimicosModel !== 'undefined' && agroquimicosModel) {
            agroquimicosModel.cargar_productos()
            agroquimicosModel.cargar_categorias()
            agroquimicosModel.cargar_mezclas()
            agroquimicosModel.cargar_tratamientos()
            agroquimicosModel.cargar_tipos_plagas()
            agroquimicosModel.cargar_ciclos_activos()
        }
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
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para el nuevo producto
                                nuevoProducto = {
                                    "id_producto": "",
                                    "id_categoria": "",
                                    "nombre_comercial": "",
                                    "formulacion": "Líquido",
                                    "unidad": "L",
                                    "precio": 0,
                                    "stock": 0,
                                    "registro": "PENDIENTE",
                                    "notas": "",
                                    "fecha_registro": obtenerFechaActual(),
                                    "activo": true
                                }
                                
                                // Mostrar diálogo de nuevo producto
                                dialogNuevoProducto.open()
                            }
                        }
                        
                        TextField {
                            id : txtBuscarProducto
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar producto..."
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
                            onTextChanged: buscarProductos(text)
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: obtenerModeloCategorias()
                            implicitHeight: 36
                            onCurrentIndexChanged: {
                                // Aquí puedes agregar la lógica de filtrado
                                filtrarProductosPorCategoria(currentIndex)
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Actualizar Stock"
                            icon.source: "Image/Image_UI_interfaz/Inconos/actualizar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#58e600" : "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: dialogActualizarStock.open()
                        }
                    }
                }
                
                // Panel de estadísticas de inventario
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
                                text: agroquimicosModel.productos ? agroquimicosModel.productos.length.toString() : "0"
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
                                text: calcularValorInventario()
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
                                text: calcularStockCritico()
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
                                text: calcularCategoriaMasUsada()
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
                        model: agroquimicosModel.productos
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
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: "Categoría"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: "Formulación"
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
                                    text: "Registro"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Notas"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.10
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
                                        text: modelData.id_producto
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
                                        text: modelData.nombre_comercial
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Categoría
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: modelData.categoria
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Formulación
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: modelData.formulacion
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
                                        text: modelData.stock + " " + modelData.unidad
                                        color: modelData.stock < 10 ? "#F44336" : "#424242"
                                        font.bold: modelData.stock < 10
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
                                        text: "Bs. " + modelData.precio
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Registro
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: modelData.registro
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Notas
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: modelData.notas || ""
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Acciones
                                Rectangle {
                                    width: parent.width * 0.10
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
                                                dialogAgregarStock.productoId = modelData.id_producto
                                                dialogAgregarStock.nombreProducto = modelData.nombre_comercial
                                                dialogAgregarStock.unidadProducto = modelData.unidad
                                                dialogAgregarStock.stockActual = modelData.stock
                                                dialogAgregarStock.open()
                                            }
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "recursos/image/icons/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: {
                                                editarProducto(modelData.id_producto)
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
                                                confirmDeleteProductoDialog.productoId = modelData.id_producto
                                                confirmDeleteProductoDialog.nombreProducto = modelData.nombre_comercial
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
                            visible: !agroquimicosModel.productos || agroquimicosModel.productos.length === 0
                        }
                    }
                }
            }
        }

        // Página de Categorías
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
                            text: "Nueva Categoría"
                            icon.source: "Image/Image_UI_interfaz/Inconos/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                nuevaCategoria = {
                                    "id_categoria": "",
                                    "nombre": "",
                                    "descripcion": "",
                                    "activo": true
                                }
                                
                                dialogNuevaCategoria.open()
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar categoría..."
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
                            onTextChanged: buscarCategorias(text)
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Tabla de categorías
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: categoriasListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: agroquimicosModel.categorias
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 40
                            color: "#F5F5F5"
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                
                                Text {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    text: "ID"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    width: parent.width * 0.20
                                    height: parent.height
                                    text: "Nombre"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.40
                                    height: parent.height
                                    text: "Descripción"
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Acciones"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                // ID
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.id_categoria
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Nombre
                                Rectangle {
                                    width: parent.width * 0.20
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: modelData.nombre
                                        font.bold: true
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Descripción
                                Rectangle {
                                    width: parent.width * 0.40
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: modelData.descripcion || ""
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Estado
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: modelData.activo ? "Activo" : "Inactivo"
                                        color: modelData.activo ? "#4CAF50" : "#F44336"
                                        font.bold: true
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
                                            icon.source: "recursos/image/icons/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: {
                                                editarCategoria(modelData.id_categoria)
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
                                                confirmDeleteCategoriaDialog.categoriaId = modelData.id_categoria
                                                confirmDeleteCategoriaDialog.nombreCategoria = modelData.nombre
                                                confirmDeleteCategoriaDialog.open()
                                            }
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: modelData.activo ? "Image/Image_UI_interfaz/Inconos/comenta-alt-check.svg" : "Image/Image_UI_interfaz/Inconos/marca-x-rectangular.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: modelData.activo ? "Desactivar" : "Activar"
                                            onClicked: {
                                                cambiarEstadoCategoria(modelData.id_categoria, !modelData.activo)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay categorías registradas.\nHaga clic en 'Nueva Categoría' para agregar una."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: !agroquimicosModel.categorias || agroquimicosModel.categorias.length === 0
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
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                nuevaMezcla = {
                                    "mezclaId": "",
                                    "nombre": "",
                                    "objetivo": "",
                                    "cantidadAgua": 0,
                                    "areaAplicacion": 0,
                                    "componentes": []
                                }
                                
                                dialogNuevaMezcla.open()
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar mezcla..."
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
                            onTextChanged: buscarMezclas(text)
                        }
                        
                        ComboBox {
                            id: cmbFiltroObjetivos
                            Layout.preferredWidth: 200
                            model: obtenerModeloObjetivos()
                            implicitHeight: 36
                            onCurrentIndexChanged: {
                                filtrarMezclasPorObjetivo(currentIndex)
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Grid de tarjetas de mezclas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    GridView {
                        id: gridMezclas
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: agroquimicosModel.mezclas
                        cellWidth: width / 3
                        cellHeight: 220
                        
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
                                    text: modelData.nombre
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
                                        text: modelData.objetivo || ""
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
                                        text: modelData.cantidad_agua + " litros"
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
                                        text: modelData.area_aplicacion + " hectáreas"
                                        font.pixelSize: 12
                                    }
                                }
                                
                                // Separador
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: "#EEEEEE"
                                }
                                
                                // Componentes
                                Text {
                                    text: "Componentes:"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                // Botones de acción
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    
                                    Button {
                                        text: "Ver Detalles"
                                        icon.source: "Image/Image_UI_interfaz/Inconos/ojos.svg"
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        font.pixelSize: 12
                                        onClicked: verDetallesMezcla(modelData.id_mezcla)
                                    }
                                    
                                    Button {
                                        text: "Editar"
                                        icon.source: "recursos/image/icons/editar.svg"
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        font.pixelSize: 12
                                        onClicked: editarMezcla(modelData.id_mezcla)
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay mezclas registradas.\nHaga clic en 'Nueva Mezcla' para agregar una."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: !agroquimicosModel.mezclas || agroquimicosModel.mezclas.length === 0
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
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                nuevoTratamiento = {
                                    "tratamientoId": "",
                                    "fecha": obtenerFechaActual(),
                                    "ciclo": "",
                                    "tipoPlaga": "",
                                    "area": 0,
                                    "mezcla": "",
                                    "costo": 0
                                }
                                
                                dialogNuevoTratamiento.open()
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar tratamiento..."
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
                            onTextChanged: buscarTratamientos(text)
                        }
                        
                        ComboBox {
                            id: cmbFiltroCiclos
                            Layout.preferredWidth: 200
                            model: obtenerModeloCiclos()
                            implicitHeight: 36
                            onCurrentIndexChanged: {
                                filtrarTratamientos()
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        ComboBox {
                            id: cmbFiltroPeriodo
                            Layout.preferredWidth: 150
                            model: ["Último mes", "Últimos 3 meses", "Último año", "Todos"]
                            implicitHeight: 36
                            onCurrentIndexChanged: {
                                filtrarTratamientos()
                            }
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
                        model: agroquimicosModel.tratamientos
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
                                        text: modelData.id_tratamiento
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
                                        text: modelData.fecha_aplicacion
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
                                        text: modelData.variedad + " - " + modelData.parcela
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
                                        text: modelData.tipo_plaga || ""
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
                                        text: modelData.area_tratada
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
                                        text: modelData.mezcla || ""
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
                                        text: "Bs. " + modelData.costo_total
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
                                            onClicked: verDetallesTratamiento(modelData.id_tratamiento)
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "recursos/image/icons/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: editarTratamiento(modelData.id_tratamiento)
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "recursos/image/icons/basura.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: {
                                                confirmDeleteTratamientoDialog.tratamientoId = modelData.id_tratamiento
                                                confirmDeleteTratamientoDialog.nombreTratamiento = modelData.variedad + " - " + modelData.fecha_aplicacion
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
                            visible: !agroquimicosModel.tratamientos || agroquimicosModel.tratamientos.length === 0
                        }
                    }
                }
            }
        }
    }
    
    // DIÁLOGOS DE LA APLICACIÓN
// DIÁLOGO DE NUEVO PRODUCTO
    Dialog {
        id: dialogNuevoProducto
        property bool modoEdicion: false
        title: "Nuevo Producto Fitosanitario"
        modal: true
        width: 500
        height: 700
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "Agregar Nuevo Producto"
                    font.pixelSize: 18
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
                
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 15
                    
                    Text {
                        text: "Nombre Comercial:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtNombreComercial
                        placeholderText: "Ingrese nombre comercial"
                        Layout.fillWidth: true
                        onTextChanged: nuevoProducto.nombre_comercial = text
                    }
                    
                    Text {
                        text: "Categoría:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbCategoria
                        Layout.fillWidth: true
                        model: agroquimicosModel.categorias
                        textRole: "nombre"
                        valueRole: "id_categoria"
                        onCurrentIndexChanged: {
                            if (currentIndex >= 0 && agroquimicosModel.categorias[currentIndex]) {
                                nuevoProducto.id_categoria = agroquimicosModel.categorias[currentIndex].id_categoria
                            }
                        }
                    }
                    
                    Text {
                        text: "Formulación:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbFormulacion
                        Layout.fillWidth: true
                        model: ["Líquido", "Polvo", "Granulado", "Emulsión"]
                        onCurrentTextChanged: nuevoProducto.formulacion = currentText
                    }
                    
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
                            model: ["L", "Kg"]
                            onCurrentTextChanged: nuevoProducto.unidad = currentText
                        }
                    }
                    
                    Text {
                        text: "Precio Unitario (Bs):"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtPrecio
                        placeholderText: "Ingrese precio unitario"
                        Layout.fillWidth: true
                        validator: DoubleValidator { bottom: 0 }
                        onTextChanged: nuevoProducto.precio = parseFloat(text) || 0
                    }
                    
                    Text {
                        text: "N° Registro:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextField {
                        id: txtRegistro
                        placeholderText: "Ingrese N° de registro"
                        Layout.fillWidth: true
                        onTextChanged: nuevoProducto.registro = text || "PENDIENTE"
                    }
                    
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
                        onTextChanged: nuevoProducto.fecha_registro = text
                    }
                    
                    Text {
                        text: "Estado:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    CheckBox {
                        id: chkActivo
                        text: "Activo"
                        checked: true
                        onCheckedChanged: nuevoProducto.activo = checked
                    }
                    
                    Text {
                        text: "Notas:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    TextArea {
                        id: txtNotas
                        placeholderText: "Notas adicionales (opcional)"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        wrapMode: TextArea.Wrap
                        onTextChanged: nuevoProducto.notas = text
                    }
                }
                
                Item {
                    width: parent.width
                    height: 10
                }
                
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
                    if (dialogNuevoProducto.modoEdicion){
                        actualizarProducto()
                    }else{
                        if (txtNombreComercial.text === "" || cmbCategoria.currentIndex < 0) {
                            mensajeValidacionProducto.text = "Por favor, complete el nombre comercial y seleccione una categoría";
                            return;
                        }
                        guardarNuevoProducto();
                    }
                }
            }
        }
        
        onClosed: {
            dialogNuevoProducto.modoEdicion = false
            dialogNuevoProducto.title = "Nuevo Producto"
            txtNombreComercial.text = ""
            txtStock.text = ""
            txtPrecio.text = ""
            txtRegistro.text = ""
            txtNotas.text = ""
            cmbCategoria.currentIndex = 0
            cmbFormulacion.currentIndex = 0
            cmbUnidad.currentIndex = 0
            chkActivo.checked = true
            mensajeValidacionProducto.text = ""

        }
    }
    //////// falta conectar con con insertar bd y sus funciones
    // DIÁLOGO DE NUEVA CATEGORÍA
    Dialog {
        id: dialogNuevaCategoria
        title: "Nueva Categoría"
        modal: true
        width: 450
        height:500
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        // Propiedad para saber si estamos en modo edición
        property bool modoEdicion: false
        
        // Contenido del diálogo
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Título
                Text {
                    text: dialogNuevaCategoria.modoEdicion ? "Editar Categoría" : "Agregar Nueva Categoría"
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
                        text: dialogNuevaCategoria.modoEdicion ? nuevaCategoria.nombre : ""
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
                        checked: dialogNuevaCategoria.modoEdicion ? nuevaCategoria.activo : true
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
                        text: dialogNuevaCategoria.modoEdicion ? nuevaCategoria.descripcion : ""
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
                text: dialogNuevaCategoria.modoEdicion ? "Actualizar" : "Guardar"
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
                    
                    if (dialogNuevaCategoria.modoEdicion) {
                        actualizarCategoria();
                    } else {
                        guardarNuevaCategoria();
                    }
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
            txtNombreCategoria.text = ""
            txtDescripcionCategoria.text = ""
            chkActivoCategoria.checked = true
            mensajeValidacionCategoria.text = ""
            modoEdicion = false
            title = "Nueva Categoría"
        }
    }
// DIÁLOGO DE NUEVA MEZCLA
    Dialog {
        id: dialogNuevaMezcla
        title: "Nueva Mezcla"
        modal: true
        width: 550
        height: 700
        //
        property bool modoEdicion : false
        //
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "Agregar Nueva Mezcla"
                    font.pixelSize: 18
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
                
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 15
                    
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
                
                Rectangle {
                    width: parent.width
                    height: 200
                    color: "#F5F5F5"
                    radius: 5
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
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
                                    dialogAgregarComponenteMezcla.open()
                                }
                            }
                        }
                        
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: componentesMezclaModel
                            clip: true
                            
                            delegate: RowLayout {
                                width: parent.width
                                spacing: 10
                                
                                Text {
                                    text: modelData.nombre_producto
                                    Layout.preferredWidth: 180
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: modelData.cantidad
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: modelData.unidad_medida
                                    Layout.preferredWidth: 80
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    icon.source: "recursos/image/icons/basura.svg"
                                    flat: true
                                    implicitWidth: 30
                                    implicitHeight: 30
                                    onClicked: componentesMezclaModel.remove(index)
                                }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "No hay componentes añadidos a la mezcla."
                                color: "#757575"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                visible: componentesMezclaModel.count === 0
                            }
                        }
                    }
                }
                
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
                    if (txtNombreMezcla.text === "" || txtCantidadAgua.text === "" || txtAreaAplicacion.text === "") {
                        mensajeValidacionMezcla.text = "Por favor, complete todos los campos obligatorios";
                        return;
                    }
                    
                    guardarNuevaMezcla()
                }
            }
        }
        
        onClosed: {
            txtNombreMezcla.text = ""
            cmbObjetivoMezcla.currentIndex = 0
            txtCantidadAgua.text = ""
            txtAreaAplicacion.text = ""
            txtObservacionesMezcla.text = ""
            mensajeValidacionMezcla.text = ""
            componentesMezclaModel.clear()
        }
    }
    
    // DIÁLOGO DE NUEVO TRATAMIENTO
    Dialog {
        id: dialogNuevoTratamiento
        title: "Nuevo Tratamiento"
        modal: true
        width: 500
        height: 600
        //
        property bool modoEdicion: false
        //
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "Agregar Nuevo Tratamiento"
                    font.pixelSize: 18
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
                
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 15
                    
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
                    
                    Text {
                        text: "Ciclo de cultivo:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbCiclo
                        Layout.fillWidth: true
                        model: agroquimicosModel.ciclos_activos
                        textRole: "descripcion"
                        //valueRole: "id_ciclo"
                        onCurrentIndexChanged: {
                            if (currentIndex >= 0 && agroquimicosModel.ciclos_activos[currentIndex]) {
                                nuevoTratamiento.ciclo = agroquimicosModel.ciclos_activos[currentIndex].id_ciclo
                            }
                        }
                    }
                    
                    Text {
                        text: "Tipo de plaga/maleza:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbTipoPlaga
                        Layout.fillWidth: true
                        model: agroquimicosModel.tipos_plagas
                        textRole: "nombre"
                        //valueRole: "id_tipo"
                        onCurrentIndexChanged: {
                            if (currentIndex >= 0 && agroquimicosModel.tipos_plagas[currentIndex]) {
                                nuevoTratamiento.tipoPlaga = agroquimicosModel.tipos_plagas[currentIndex].id_tipo
                            }
                        }
                    }
                    
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
                    
                    Text {
                        text: "Mezcla utilizada:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbMezcla
                        Layout.fillWidth: true
                        model: agroquimicosModel.mezclas
                        textRole: "nombre"
                        valueRole: "id_mezcla"
                        onCurrentIndexChanged: {
                            if (currentIndex >= 0 && agroquimicosModel.mezclas[currentIndex]) {
                                nuevoTratamiento.mezcla = agroquimicosModel.mezclas[currentIndex].id_mezcla
                            }
                        }
                    }
                    
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
                    if (txtFechaTratamiento.text === "" || cmbCiclo.currentIndex < 0 || txtAreaTratamiento.text === "" || cmbMezcla.currentIndex < 0) {
                        mensajeValidacionTratamiento.text = "Por favor, complete todos los campos obligatorios"
                        return
                    }
                    
                    guardarNuevoTratamiento()
                }
            }
        }
        
        onClosed: {
            txtFechaTratamiento.text = obtenerFechaActual()
            cmbCiclo.currentIndex = 0
            cmbTipoPlaga.currentIndex = 0
            txtAreaTratamiento.text = ""
            cmbMezcla.currentIndex = 0
            txtCostoTratamiento.text = ""
            txtObservacionesTratamiento.text = ""
            mensajeValidacionTratamiento.text = ""
        }
    }
    
    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR PRODUCTO
    Dialog {
        id: confirmDeleteProductoDialog
        title: "Confirmar eliminación"
        modal: true
        width: 400
        height: 250
        
        property int productoId: -1
        property string nombreProducto: ""
        
        contentItem: Item {
            //implicitWidth: 400
            //implicitHeight: 100
            
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
            if (agroquimicosModel.eliminar_producto(productoId)) {
                showMessage("Producto eliminado correctamente")
            } else {
                showMessage("Error al eliminar el producto")
            }
        }
    }
    
    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR CATEGORÍA
    Dialog {
        id: confirmDeleteCategoriaDialog
        title: "Confirmar eliminación"
        modal: true
        
        property int categoriaId: -1
        property string nombreCategoria: ""
        
        contentItem: Item {
            implicitWidth: 400
            implicitHeight: 100
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    width: parent.width
                    text: "¿Está seguro que desea eliminar la categoría '" + confirmDeleteCategoriaDialog.nombreCategoria + "'?"
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
            // Implementar la eliminación de categoría
            showMessage("Función de eliminación de categoría por implementar")
        }
    }
    
    // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR TRATAMIENTO
    Dialog {
        id: confirmDeleteTratamientoDialog
        title: "Confirmar eliminación"
        modal: true
        width:400
        height: 250
        
        property int tratamientoId: -1
        property string nombreTratamiento: ""
        
        contentItem: Item {
            //implicitWidth: 400
            //implicitHeight: 100
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    width: parent.width
                    text: "¿Está seguro que desea eliminar el tratamiento '" + confirmDeleteTratamientoDialog.nombreTratamiento + "'?"
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
            // Implementar la eliminación de tratamiento
            showMessage("Función de eliminación de tratamiento por implementar")
        }
    }
    // DIÁLOGO DE DETALLES DE MEZCLA
    Dialog {
        id: dialogDetallesMezcla
        title: "Detalles de Mezcla"
        modal: true
        width: 600
        height: 500
        
        property var mezcla: null
        property var detalles: []
        
        contentItem: Item {
            Rectangle {
                anchors.fill: parent
                color: "white"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // Información básica
                    Text {
                        text: dialogDetallesMezcla.mezcla ? dialogDetallesMezcla.mezcla.nombre : ""
                        font.pixelSize: 18
                        font.bold: true
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#EEEEEE"
                    }
                    
                    RowLayout {
                        spacing: 20
                        Layout.fillWidth: true
                        
                        Column {
                            Text {
                                text: "Objetivo"
                                font.bold: true
                                color: "#666"
                            }
                            Text {
                                text: dialogDetallesMezcla.mezcla ? dialogDetallesMezcla.mezcla.objetivo : ""
                            }
                        }
                        
                        Column {
                            Text {
                                text: "Cantidad de Agua"
                                font.bold: true
                                color: "#666"
                            }
                            Text {
                                text: dialogDetallesMezcla.mezcla ? dialogDetallesMezcla.mezcla.cantidad_agua + " litros" : ""
                            }
                        }
                        
                        Column {
                            Text {
                                text: "Área de Aplicación"
                                font.bold: true
                                color: "#666"
                            }
                            Text {
                                text: dialogDetallesMezcla.mezcla ? dialogDetallesMezcla.mezcla.area_aplicacion + " hectáreas" : ""
                            }
                        }
                    }
                    
                    Text {
                        text: "Componentes"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.topMargin: 10
                    }
                    
                    // Lista de componentes
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: dialogDetallesMezcla.detalles
                        
                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                Text {
                                    text: modelData.nombre_producto
                                    Layout.preferredWidth: 200
                                }
                                
                                Text {
                                    text: modelData.cantidad + " " + modelData.unidad_medida
                                    Layout.preferredWidth: 100
                                }
                                
                                Text {
                                    text: modelData.observaciones || ""
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
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
        }
    }

    // DIÁLOGO DE DETALLES DE TRATAMIENTO
    Dialog {
        id: dialogDetallesTratamiento
        title: "Detalles de Tratamiento"
        modal: true
        width: 600
        height: 500
        property var tratamiento: null
        
        contentItem: Item {
            Rectangle {
                anchors.fill: parent
                color: "white"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // Información básica
                    Text {
                        text: "Tratamiento #" + (tratamiento ? tratamiento.id_tratamiento : "")
                        font.pixelSize: 18
                        font.bold: true
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#EEEEEE"
                    }
                    
                    GridLayout {
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 20
                        
                        Text {
                            text: "Fecha:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? tratamiento.fecha_aplicacion : ""
                        }
                        
                        Text {
                            text: "Ciclo:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? tratamiento.variedad + " - " + tratamiento.parcela : ""
                        }
                        
                        Text {
                            text: "Tipo de Plaga:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? tratamiento.tipo_plaga : ""
                        }
                        
                        Text {
                            text: "Área Tratada:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? tratamiento.area_tratada + " ha" : ""
                        }
                        
                        Text {
                            text: "Mezcla Utilizada:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? tratamiento.mezcla : ""
                        }
                        
                        Text {
                            text: "Costo Total:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? "Bs. " + tratamiento.costo_total : ""
                        }
                        
                        Text {
                            text: "Método de Aplicación:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? tratamiento.metodo_aplicacion : ""
                        }
                        
                        Text {
                            text: "Condiciones Climáticas:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? tratamiento.condiciones_climaticas : ""
                        }
                        
                        Text {
                            text: "Responsable:"
                            font.bold: true
                            color: "#666"
                        }
                        Text {
                            text: tratamiento ? tratamiento.responsable : ""
                        }
                    }
                    
                    Text {
                        text: "Observaciones"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.topMargin: 10
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: "#F5F5F5"
                        radius: 5
                        
                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 10
                            
                            Text {
                                text: tratamiento ? (tratamiento.observaciones || "Sin observaciones") : ""
                                wrapMode: Text.WordWrap
                                width: parent.width
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
        }
    }
    
    // DIÁLOGO PARA AGREGAR COMPONENTE A MEZCLA
    Dialog {
        id: dialogAgregarComponenteMezcla
        title: "Agregar Componente"
        modal: true
        width: 400
        height: 300
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "Agregar Componente a la Mezcla"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                ComboBox {
                    id: cmbProductoComponente
                    width: parent.width
                    model: agroquimicosModel.productos
                    textRole: "nombre_comercial"
                    valueRole: "id_producto"
                }
                
                RowLayout {
                    width: parent.width
                    spacing: 10
                    
                    TextField {
                        id: txtCantidadComponente
                        Layout.fillWidth: true
                        placeholderText: "Cantidad"
                        validator: DoubleValidator { bottom: 0 }
                    }
                    
                    ComboBox {
                        id: cmbUnidadComponente
                        model: ["L", "Kg", "ml", "g"]
                    }
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
            
            Button {
                text: "Agregar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                onClicked: {
                    if (cmbProductoComponente.currentIndex >= 0 && txtCantidadComponente.text !== "") {
                        componentesMezclaModel.append({
                            "id_producto": agroquimicosModel.productos[cmbProductoComponente.currentIndex].id_producto,
                            "nombre_producto": agroquimicosModel.productos[cmbProductoComponente.currentIndex].nombre_comercial,
                            "cantidad": parseFloat(txtCantidadComponente.text),
                            "unidad_medida": cmbUnidadComponente.currentText
                        })
                        dialogAgregarComponenteMezcla.close()
                    }
                }
            }
        }
        
        onClosed: {
            cmbProductoComponente.currentIndex = 0
            txtCantidadComponente.text = ""
            cmbUnidadComponente.currentIndex = 0
        }
    }

    // DIÁLOGO PARA ACTUALIZAR STOCK DE PRODUCTOS
    Dialog {
        id: dialogActualizarStock
        title: "Actualizar Stock"
        modal: true
        width: 600
        height: 500
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "Actualizar Stock de Productos"
                    font.pixelSize: 18
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
                
                ListView {
                    id: listViewActualizarStock
                    width: parent.width
                    height: parent.height - 100
                    clip: true
                    model: agroquimicosModel.productos
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: index % 2 === 0 ? "#F5F5F5" : "white"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15
                            
                            Text {
                                text: modelData.nombre_comercial
                                Layout.preferredWidth: 200
                                font.bold: true
                            }
                            
                            Text {
                                text: "Stock actual: " + modelData.stock + " " + modelData.unidad
                                Layout.preferredWidth: 120
                                color: modelData.stock < 10 ? "#F44336" : "#424242"
                            }
                            
                            TextField {
                                id: txtNuevoStock
                                Layout.preferredWidth: 100
                                placeholderText: "Nuevo stock"
                                validator: DoubleValidator { bottom: 0 }
                                property string productoId: modelData.id_producto
                                property double stockAnterior: modelData.stock
                            }
                            
                            Button {
                                text: "Actualizar"
                                Layout.preferredWidth: 100
                                onClicked: {
                                    var textField = parent.children[2] // Acceso al TextField
                                    if (textField.text !== "") {
                                        var nuevoStock = parseFloat(textField.text)
                                        actualizarStockProducto(textField.productoId, nuevoStock)
                                        textField.text = ""
                                    }
                                }
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
                onClicked: dialogActualizarStock.close()
            }
        }
    }

    // DIÁLOGO PARA AGREGAR STOCK A UN PRODUCTO
    Dialog {
        id: dialogAgregarStock
        title: "Agregar Stock"
        modal: true
        width: 400
        height: 300
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        property int productoId: -1
        property string nombreProducto: ""
        property string unidadProducto: ""
        property double stockActual: 0
        
        contentItem: Rectangle {
            color: "white"
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "Agregar Stock a: " + dialogAgregarStock.nombreProducto
                    font.pixelSize: 16
                    font.bold: true
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                
                Text {
                    text: "Stock actual: " + dialogAgregarStock.stockActual + " " + dialogAgregarStock.unidadProducto
                    width: parent.width
                }
                
                Row {
                    width: parent.width
                    spacing: 10
                    
                    Text {
                        text: "Cantidad a agregar:"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    TextField {
                        id: txtCantidadAgregar
                        width: 150
                        placeholderText: "Cantidad"
                        validator: DoubleValidator { bottom: 0 }
                    }
                    
                    Text {
                        text: dialogAgregarStock.unidadProducto
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Text {
                    id: txtNuevoStockCalculado
                    width: parent.width
                    text: "Nuevo stock: " + dialogAgregarStock.stockActual + " " + dialogAgregarStock.unidadProducto
                    font.bold: true
                    color: "#4CAF50"
                }
                
                // Actualizar el nuevo stock calculado cuando se cambia la cantidad
                Connections {
                    target: txtCantidadAgregar
                    function onTextChanged() {
                        var cantidad = parseFloat(txtCantidadAgregar.text) || 0
                        var nuevoStock = dialogAgregarStock.stockActual + cantidad
                        txtNuevoStockCalculado.text = "Nuevo stock: " + nuevoStock + " " + dialogAgregarStock.unidadProducto
                    }
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cancelar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: dialogAgregarStock.close()
            }
            
            Button {
                text: "Guardar"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                enabled: txtCantidadAgregar.text !== ""
                background: Rectangle {
                    color: parent.enabled ? "#4CAF50" : "#CCCCCC"
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
                    var cantidad = parseFloat(txtCantidadAgregar.text) || 0
                    var nuevoStock = dialogAgregarStock.stockActual + cantidad
                    agregarStockProducto(dialogAgregarStock.productoId, nuevoStock)
                    dialogAgregarStock.close()
                }
            }
        }
        
        onOpened: {
            txtCantidadAgregar.text = ""
        }
    }

    // MODELOS AUXILIARES
    ListModel {
        id: componentesMezclaModel
    }
    
    // FUNCIONES DE GESTIÓN
    function guardarNuevoProducto() {
        var productoData = {
            "id_categoria": nuevoProducto.id_categoria,
            "nombre_comercial": nuevoProducto.nombre_comercial,
            "formulacion": nuevoProducto.formulacion,
            "unidad": nuevoProducto.unidad,
            "precio": nuevoProducto.precio,
            "stock": nuevoProducto.stock,
            "registro": nuevoProducto.registro,
            "notas": nuevoProducto.notas,
            "fecha_registro": nuevoProducto.fecha_registro,
            "activo": nuevoProducto.activo
        }
        
        var productoDataJson = JSON.stringify(productoData)
        
        if (agroquimicosModel.agregar_producto(productoDataJson)) {
            dialogNuevoProducto.close()
            showMessage("Producto guardado correctamente")
        } else {
            showMessage("Error al guardar el producto")
        }
    }
    
    function guardarNuevaCategoria() {
        var categoriaData = {
            "nombre": nuevaCategoria.nombre,
            "descripcion": nuevaCategoria.descripcion,
            "activo": nuevaCategoria.activo
        }
        
        var categoriaDataJson = JSON.stringify(categoriaData)
        
        if (agroquimicosModel.agregar_categoria(categoriaDataJson)) {
            dialogNuevaCategoria.close()
            showMessage("Categoría guardada correctamente")
        } else {
            showMessage("Error al guardar la categoría")
        }
    }
    
    function guardarNuevaMezcla() {
        var mezclaData = {
            "nombre": nuevaMezcla.nombre,
            "objetivo": nuevaMezcla.objetivo,
            "cantidad_agua": nuevaMezcla.cantidadAgua,
            "area_aplicacion": nuevaMezcla.areaAplicacion,
            "indicaciones": txtObservacionesMezcla.text,
            "activo": true
        }
        
        var detallesData = []
        for (var i = 0; i < componentesMezclaModel.count; i++) {
            var componente = componentesMezclaModel.get(i)
            detallesData.push({
                "id_producto": componente.id_producto,
                "cantidad": componente.cantidad,
                "unidad_medida": componente.unidad_medida
            })
        }
        
        var mezclaDataJson = JSON.stringify(mezclaData)
        var detallesDataJson = JSON.stringify(detallesData)
        
        if (agroquimicosModel.agregar_mezcla(mezclaDataJson, detallesDataJson)) {
            dialogNuevaMezcla.close()
            showMessage("Mezcla guardada correctamente")
        } else {
            showMessage("Error al guardar la mezcla")
        }
    }
    
    function guardarNuevoTratamiento() {
        // Obtener los IDs seleccionados en lugar de los nombres
        var cicloSeleccionado = agroquimicosModel.ciclos_activos[cmbCiclo.currentIndex];
        var tipoPlaga = agroquimicosModel.tipos_plagas[cmbTipoPlaga.currentIndex];
        var mezcla = agroquimicosModel.mezclas[cmbMezcla.currentIndex];

        var tratamientoData = {
            "id_ciclo": cicloSeleccionado.id_ciclo,  // Aquí el ID real
            "id_tipo_plaga": tipoPlaga.id_tipo,      // Aquí el ID real
            "fecha_aplicacion": nuevoTratamiento.fecha,
            "area_tratada": nuevoTratamiento.area,
            "id_mezcla": mezcla.id_mezcla,           // Aquí el ID real
            "costo_total": nuevoTratamiento.costo,
            "observaciones": txtObservacionesTratamiento.text,
            "realizado_por": 22  // Basado en tu tabla, usaremos el ID 22 (Luis)
        }
        
        console.log("Datos del tratamiento:", JSON.stringify(tratamientoData));
        var tratamientoDataJson = JSON.stringify(tratamientoData)
        
        if (agroquimicosModel.agregar_tratamiento(tratamientoDataJson)) {
            dialogNuevoTratamiento.close()
            showMessage("Tratamiento guardado correctamente")
        } else {
            showMessage("Error al guardar el tratamiento")
        }
    }   
    
    // Función para editar producto
    function editarProducto(idProducto) {
        for (var i = 0; i < agroquimicosModel.productos.length; i++) {
            if (agroquimicosModel.productos[i].id_producto === idProducto) {
                var producto = agroquimicosModel.productos[i];
                nuevoProducto = {
                    "id_producto": producto.id_producto,
                    "id_categoria": producto.id_categoria,
                    "nombre_comercial": producto.nombre_comercial,
                    "formulacion": producto.formulacion,
                    "unidad": producto.unidad,
                    "precio": producto.precio,
                    "stock": producto.stock,
                    "registro": producto.registro,
                    "notas": producto.notas,
                    "fecha_registro": producto.fecha_registro,
                    "activo": producto.activo
                };

                // Llenar los campos del diálogo con los datos existentes
                txtNombreComercial.text = nuevoProducto.nombre_comercial
                txtStock.text = nuevoProducto.stock.toString()
                txtPrecio.text = nuevoProducto.precio.toString()
                txtRegistro.text = nuevoProducto.registro
                txtNotas.text = nuevoProducto.notas || ""

                for (var i = 0; i < cmbCategoria.count; i++) {
                    if (agroquimicosModel.categorias[i].id_categoria === nuevoProducto.id_categoria) {
                        cmbCategoria.currentIndex = i
                        break
                    }
                }
                // Seleccionar la formulación correcta
                var formulaciones = ["Líquido", "Polvo", "Granulado", "Emulsión"]
                cmbFormulacion.currentIndex = formulaciones.indexOf(nuevoProducto.formulacion)

                // Seleccionar la unidad correcta
                var unidades = ["L", "Kg"]
                cmbUnidad.currentIndex = unidades.indexOf(nuevoProducto.unidad)

                chkActivo.checked = nuevoProducto.activo

                dialogNuevoProducto.title = "Editar Producto";
                dialogNuevoProducto.open();
                dialogNuevoProducto.modoEdicion = true
                break;
            }
        }
    }
    function editarCategoria(idCategoria) {
        for (var i = 0; i < agroquimicosModel.categorias.length; i++) {
            if (agroquimicosModel.categorias[i].id_categoria === idCategoria) {
                var categoria = agroquimicosModel.categorias[i];
                nuevaCategoria = {
                    "id_categoria": categoria.id_categoria,
                    "nombre": categoria.nombre,
                    "descripcion": categoria.descripcion,
                    "activo": categoria.activo
                };
                
                dialogNuevaCategoria.modoEdicion = true;
                dialogNuevaCategoria.title = "Editar Categoría";
                dialogNuevaCategoria.open();
                break;
            }
        }
    }

    // Función para editar mezcla - CORREGIDA
    function editarMezcla(mezclaId) {
        for (var i = 0; i < agroquimicosModel.mezclas.length; i++) {
            if (agroquimicosModel.mezclas[i].id_mezcla === mezclaId) {
                var mezcla = agroquimicosModel.mezclas[i];
                nuevaMezcla = {
                    "mezclaId": mezcla.id_mezcla,
                    "nombre": mezcla.nombre,
                    "objetivo": mezcla.objetivo,
                    "cantidadAgua": mezcla.cantidad_agua,
                    "areaAplicacion": mezcla.area_aplicacion,
                    "componentes": []
                };
                
                // Cargar componentes de la mezcla
                agroquimicosModel.cargar_detalles_mezcla(mezclaId);
                
                // Esperar a que se carguen los detalles y llenar componentes
                var timer = Qt.createQmlObject('import QtQuick 2.15; Timer { interval: 500; running: true; repeat: false }', agroquimicosRoot);
                timer.triggered.connect(function() {
                    if (agroquimicosModel.detalles_mezcla) {
                        nuevaMezcla.componentes = agroquimicosModel.detalles_mezcla;
                        dialogNuevaMezcla.title = "Editar Mezcla";
                        dialogNuevaMezcla.modoEdicion = true;
                        dialogNuevaMezcla.open();
                    }
                    timer.destroy();
                });
                break;
            }
        }
    }

    // Función para editar tratamiento - CORREGIDA
    function editarTratamiento(tratamientoId) {
        for (var i = 0; i < agroquimicosModel.tratamientos.length; i++) {
            if (agroquimicosModel.tratamientos[i].id_tratamiento === tratamientoId) {
                var tratamiento = agroquimicosModel.tratamientos[i];
                nuevoTratamiento = {
                    "tratamientoId": tratamiento.id_tratamiento,
                    "fecha": tratamiento.fecha_aplicacion,
                    "ciclo": tratamiento.id_ciclo,
                    "tipoPlaga": tratamiento.id_tipo_plaga,
                    "area": tratamiento.area_tratada,
                    "mezcla": tratamiento.id_mezcla,
                    "costo": tratamiento.costo_total,
                    "observaciones": tratamiento.observaciones
                };
                
                dialogNuevoTratamiento.title = "Editar Tratamiento";
                dialogNuevoTratamiento.modoEdicion = true;
                dialogNuevoTratamiento.open();
                break;
            }
        }
    }

    // Función para ver detalles de mezcla - CORREGIDA
    function verDetallesMezcla(mezclaId) {
        console.log("Viendo detalles de mezcla:", mezclaId)
        
        // Buscar mezcla
        var mezcla = null;
        for (var i = 0; i < agroquimicosModel.mezclas.length; i++) {
            if (agroquimicosModel.mezclas[i].id_mezcla === mezclaId) {
                mezcla = agroquimicosModel.mezclas[i];
                break;
            }
        }
        
        if (!mezcla) {
            console.log("No se encontró la mezcla con ID:", mezclaId)
            return;
        }
        
        // Cargar detalles de la mezcla desde el modelo
        agroquimicosModel.cargar_detalles_mezcla(mezclaId);
        
        // Asignar la mezcla al diálogo
        dialogDetallesMezcla.mezcla = mezcla;
        
        // Esperar un momento para que se carguen los detalles
        Qt.callLater(function() {
            dialogDetallesMezcla.detalles = agroquimicosModel.detalles_mezcla;
            dialogDetallesMezcla.open();
        });
    }

    // Función para ver detalles de tratamiento - CORREGIDA
    function verDetallesTratamiento(tratamientoId) {
        var tratamientoEncontrado = null;
        for (var i = 0; i < agroquimicosModel.tratamientos.length; i++) {
            if (agroquimicosModel.tratamientos[i].id_tratamiento === tratamientoId) {
                tratamientoEncontrado = agroquimicosModel.tratamientos[i];
                break;
            }
        }
        
        if (tratamientoEncontrado) {
            dialogDetallesTratamiento.tratamiento = tratamientoEncontrado;
            dialogDetallesTratamiento.open();
        } else {
            showMessage("No se encontró el tratamiento seleccionado");
        }
    }  
    
    // FUNCIONES DE UTILIDAD
    function obtenerFechaActual() {
        var today = new Date()
        var dd = String(today.getDate()).padStart(2, '0')
        var mm = String(today.getMonth() + 1).padStart(2, '0')
        var yyyy = today.getFullYear()
        return dd + '/' + mm + '/' + yyyy
    }
    
    function obtenerModeloCiclos() {
        var ciclos = ["Todos los ciclos"]
        if (agroquimicosModel.ciclos_activos) {
            for (var i = 0; i < agroquimicosModel.ciclos_activos.length; i++) {
                var ciclo = agroquimicosModel.ciclos_activos[i]
                ciclos.push(ciclo.variedad + " - " + ciclo.parcela)
            }
        }
        return ciclos
    }
    
    function calcularValorInventario() {
        var total = 0
        if (agroquimicosModel.productos) {
            for (var i = 0; i < agroquimicosModel.productos.length; i++) {
                total += agroquimicosModel.productos[i].precio * agroquimicosModel.productos[i].stock
            }
        }
        return "Bs. " + total.toFixed(2)
    }  
    function calcularStockCritico() {
        var count = 0
        if (agroquimicosModel.productos) {
            for (var i = 0; i < agroquimicosModel.productos.length; i++) {
                if (agroquimicosModel.productos[i].stock < 10) {  // Considerar stock crítico si es menor a 5
                    count++
                }
            }
        }
        return count.toString()
    }
    
    function calcularCategoriaMasUsada() {
        if (!agroquimicosModel.productos || agroquimicosModel.productos.length === 0) {
            return "-"
        }
        
        var categorias = {}
        for (var i = 0; i < agroquimicosModel.productos.length; i++) {
            var categoria = agroquimicosModel.productos[i].categoria || "Sin categoría"
            categorias[categoria] = (categorias[categoria] || 0) + 1
        }
        
        var maxCategoria = ""
        var maxCount = 0
        for (var cat in categorias) {
            if (categorias[cat] > maxCount) {
                maxCount = categorias[cat]
                maxCategoria = cat
            }
        }
        
        return maxCategoria || "-"
    }
    function buscarCategorias(texto) {
        if (!texto) {
            categoriasListView.model = agroquimicosModel.categorias
            return
        }
        
        var filtrados = []
        for (var i = 0; i < agroquimicosModel.categorias.length; i++) {
            var categoria = agroquimicosModel.categorias[i]
            if (categoria.nombre.toLowerCase().includes(texto.toLowerCase()) || 
                (categoria.descripcion && categoria.descripcion.toLowerCase().includes(texto.toLowerCase()))) {
                filtrados.push(categoria)
            }
        }
        
        categoriasListView.model = filtrados
    }
    
    function cambiarEstadoCategoria(categoriaId, nuevoEstado) {
        var categoriaData = {
            "activo": nuevoEstado
        }
        
        var categoriaDataJson = JSON.stringify(categoriaData)
        
        if (agroquimicosModel.actualizar_categoria(categoriaId, categoriaDataJson)) {
            showMessage("Estado de categoría actualizado")
        } else {
            showMessage("Error al actualizar el estado de la categoría")
        }
    }
    
    function actualizarCategoria() {
        var categoriaData = {
            "nombre": nuevaCategoria.nombre,
            "descripcion": nuevaCategoria.descripcion,
            "activo": nuevaCategoria.activo
        }
        
        var categoriaDataJson = JSON.stringify(categoriaData)
        
        if (agroquimicosModel.actualizar_categoria(nuevaCategoria.id_categoria, categoriaDataJson)) {
            dialogNuevaCategoria.close()
            showMessage("Categoría actualizada correctamente")
        } else {
            showMessage("Error al actualizar la categoría")
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
    
    // Función para mostrar mensajes
    function showMessage(message) {
        messageToast.text = message
        messageToast.visible = true
        messageToastTimer.restart()
    }
    function actualizarProducto() {
        var productoData = {
            "id_categoria": nuevoProducto.id_categoria,
            "nombre_comercial": nuevoProducto.nombre_comercial,
            "formulacion": nuevoProducto.formulacion,
            "unidad": nuevoProducto.unidad,
            "precio": nuevoProducto.precio,
            "stock": nuevoProducto.stock,
            "registro": nuevoProducto.registro,
            "notas": nuevoProducto.notas,
            "fecha_registro": nuevoProducto.fecha_registro,
            "activo": nuevoProducto.activo
        }
    
        var productoDataJson = JSON.stringify(productoData)
    
        if (agroquimicosModel.actualizar_producto(nuevoProducto.id_producto, productoDataJson)) {
           dialogNuevoProducto.close()
           showMessage("Producto actualizado correctamente")
        } else {
           showMessage("Error al actualizar el producto")
        }
    }

    function obtenerModeloCategorias() {
        var categorias = ["Todas las categorías"]
        if (agroquimicosModel.categorias) {
            for (var i = 0; i < agroquimicosModel.categorias.length; i++) {
                categorias.push(agroquimicosModel.categorias[i].nombre)
            }
        }
        return categorias
    }
    // Añadir después de la función obtenerModeloCategorias()
    function buscarProductos(texto) {
        if (!texto) {
            productosListView.model = agroquimicosModel.productos
            return
        }
        
        var filtrados = []
        for (var i = 0; i < agroquimicosModel.productos.length; i++) {
            var producto = agroquimicosModel.productos[i]
            if (producto.nombre_comercial.toLowerCase().includes(texto.toLowerCase()) || 
                producto.categoria.toLowerCase().includes(texto.toLowerCase())) {
                filtrados.push(producto)
            }
        }
        
        productosListView.model = filtrados
    }

    function filtrarProductosPorCategoria(index) {
        if (index === 0) {
            // Mostrar todos los productos
            productosListView.model = agroquimicosModel.productos
        } else {
            // Filtrar por categoría seleccionada
            var nombreCategoria = obtenerModeloCategorias()[index]
            var productosFiltrados = []
            
            for (var i = 0; i < agroquimicosModel.productos.length; i++) {
                if (agroquimicosModel.productos[i].categoria === nombreCategoria) {
                    productosFiltrados.push(agroquimicosModel.productos[i])
                }
            }
            
            productosListView.model = productosFiltrados
        }
    }

    function obtenerModeloObjetivos() {
        var objetivos = ["Todos los objetivos"]
        var objetivosUnicos = new Set()
        
        if (agroquimicosModel.mezclas) {
            for (var i = 0; i < agroquimicosModel.mezclas.length; i++) {
                if (agroquimicosModel.mezclas[i].objetivo) {
                    objetivosUnicos.add(agroquimicosModel.mezclas[i].objetivo)
                }
            }
        }
        
        // Convertir Set a Array
        objetivosUnicos.forEach(function(objetivo) {
            objetivos.push(objetivo)
        })
        
        return objetivos
    }

    function filtrarTratamientos() {
        var cicloSeleccionado = cmbFiltroCiclos.currentIndex
        var periodoSeleccionado = cmbFiltroPeriodo.currentIndex
        
        if (!agroquimicosModel.tratamientos) {
            return
        }
        
        var tratamientosFiltrados = []
        var fechaActual = new Date()
        
        for (var i = 0; i < agroquimicosModel.tratamientos.length; i++) {
            var tratamiento = agroquimicosModel.tratamientos[i]
            var fechaTratamiento = new Date(tratamiento.fecha_aplicacion)
            
            // Filtrar por ciclo
            if (cicloSeleccionado === 0 || obtenerModeloCiclos()[cicloSeleccionado] === (tratamiento.variedad + " - " + tratamiento.parcela)) {
                
                // Filtrar por periodo
                var mostrar = false
                
                switch (periodoSeleccionado) {
                    case 0: // Último mes
                        var unMesAtras = new Date(fechaActual)
                        unMesAtras.setMonth(unMesAtras.getMonth() - 1)
                        mostrar = fechaTratamiento >= unMesAtras
                        break
                        
                    case 1: // Últimos 3 meses
                        var tresMesesAtras = new Date(fechaActual)
                        tresMesesAtras.setMonth(tresMesesAtras.getMonth() - 3)
                        mostrar = fechaTratamiento >= tresMesesAtras
                        break
                        
                    case 2: // Último año
                        var unAnoAtras = new Date(fechaActual)
                        unAnoAtras.setFullYear(unAnoAtras.getFullYear() - 1)
                        mostrar = fechaTratamiento >= unAnoAtras
                        break
                        
                    case 3: // Todos
                        mostrar = true
                        break
                }
                
                if (mostrar) {
                    tratamientosFiltrados.push(tratamiento)
                }
            }
        }
        
        tratamientosListView.model = tratamientosFiltrados
    }
    function buscarTratamientos(texto) {
        if (!texto) {
            filtrarTratamientos() // Aplica los filtros actuales
            return
        }
        
        var filtrados = []
        for (var i = 0; i < agroquimicosModel.tratamientos.length; i++) {
            var tratamiento = agroquimicosModel.tratamientos[i]
            if (tratamiento.variedad.toLowerCase().includes(texto.toLowerCase()) || 
                tratamiento.parcela.toLowerCase().includes(texto.toLowerCase()) ||
                tratamiento.tipo_plaga.toLowerCase().includes(texto.toLowerCase()) ||
                tratamiento.mezcla.toLowerCase().includes(texto.toLowerCase())) {
                filtrados.push(tratamiento)
            }
        }
        
        tratamientosListView.model = filtrados
    }

    function filtrarMezclasPorObjetivo(index) {
        if (index === 0) {
            // Mostrar todas las mezclas
            gridMezclas.model = agroquimicosModel.mezclas
        } else {
            // Filtrar por objetivo seleccionado
            var objetivoSeleccionado = obtenerModeloObjetivos()[index]
            var mezclasFiltradas = []
            
            for (var i = 0; i < agroquimicosModel.mezclas.length; i++) {
                if (agroquimicosModel.mezclas[i].objetivo === objetivoSeleccionado) {
                    mezclasFiltradas.push(agroquimicosModel.mezclas[i])
                }
            }
            
            gridMezclas.model = mezclasFiltradas
        }
    }
    function buscarMezclas(texto) {
        if (!texto) {
            gridMezclas.model = agroquimicosModel.mezclas
            return
        }
        
        var filtrados = []
        for (var i = 0; i < agroquimicosModel.mezclas.length; i++) {
            var mezcla = agroquimicosModel.mezclas[i]
            if (mezcla.nombre.toLowerCase().includes(texto.toLowerCase()) || 
                (mezcla.objetivo && mezcla.objetivo.toLowerCase().includes(texto.toLowerCase()))) {
                filtrados.push(mezcla)
            }
        }
        
        gridMezclas.model = filtrados
    }
    function actualizarStockProducto(idProducto, nuevoStock) {
        var productoData = {
            "stock": nuevoStock
        }
        
        var productoDataJson = JSON.stringify(productoData)
        
        if (agroquimicosModel.actualizar_producto(idProducto, productoDataJson)) {
            showMessage("Stock actualizado correctamente")
        } else {
            showMessage("Error al actualizar el stock")
        }
    }
    // Función para agregar stock a un producto
    function agregarStockProducto(idProducto, nuevoStock) {
        var productoData = {
            "stock": nuevoStock
        }
        
        var productoDataJson = JSON.stringify(productoData)
        
        if (agroquimicosModel.actualizar_producto(idProducto, productoDataJson)) {
            showMessage("Stock actualizado correctamente")
        } else {
            showMessage("Error al actualizar el stock")
        }
    }
}