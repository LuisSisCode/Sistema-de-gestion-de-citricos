import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: agroquimicosRoot
    anchors.fill: parent
    color: "#F8F9FA"

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
                                        text: id_producto // Cambiado de productId a id_producto
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
                                        text: nombre_comercial // Cambiado de nombreComercial a nombre_comercial
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Categoría - Aquí necesitarás obtener el nombre de la categoría, no solo el ID
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: obtenerNombreCategoria(id_categoria) // Función auxiliar que deberías implementar
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Formulación (en lugar de Ingrediente Activo)
                                Rectangle {
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: formulacion // Nuevo campo de la tabla
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
                                        // Si deseas mantener el color según nivel de stock:
                                        // Asumiendo que tienes un campo para stockMinimo o lo calculas
                                        color: stock < (stockMinimo || 0) ? "#F44336" : "#424242"
                                        font.bold: stock < (stockMinimo || 0)
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
                                        text: "Bs. " + precio // Cambiado de precioUnitario a precio
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Registro (en lugar de Período Carencia)
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: registro // Cambiado a campo de registro
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
                                        text: notas // Nuevo campo para notas
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
                                                // Aquí podrías abrir un diálogo para agregar stock
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
                                            onClicked: {
                                                // Aquí podrías abrir un diálogo para editar
                                                showMessage("Función para editar producto no implementada")
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
                                                confirmDeleteProductoDialog.productoId = id_producto
                                                confirmDeleteProductoDialog.nombreProducto = nombre_comercial
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
                                color: "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para la nueva categoría
                                nuevaCategoria = {
                                    "id_categoria": "",
                                    "nombre": "",
                                    "descripcion": "",
                                    "activo": true
                                }
                                
                                // Mostrar diálogo de nueva categoría
                                dialogNuevaCategoria.open()
                            }
                        }
                        
                        TextField {
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar categoría..."
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#b2c4c9"
                                radius: height / 2
                            }
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
                        model: categoriasModel
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
                                    width: parent.width * 0.10
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: id_categoria
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
                                        text: nombre
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
                                        text: descripcion
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
                                        text: activo ? "Activo" : "Inactivo"
                                        color: activo ? "#4CAF50" : "#F44336"
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
                                            icon.source: "Image/Image_UI_interfaz/Inconos/editar.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: {
                                                // Aquí podrías abrir un diálogo para editar la categoría
                                                editarCategoria(id_categoria);
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
                                                confirmDeleteCategoriaDialog.categoriaId = id_categoria;
                                                confirmDeleteCategoriaDialog.nombreCategoria = nombre;
                                                confirmDeleteCategoriaDialog.open();
                                            }
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: activo ? "Image/Image_UI_interfaz/Inconos/check.svg" : "Image/Image_UI_interfaz/Inconos/close.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: activo ? "Desactivar" : "Activar"
                                            onClicked: {
                                                cambiarEstadoCategoria(id_categoria, !activo);
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
                            visible: categoriasModel.count === 0
                        }
                    }
                }
            }
            
            // Función para editar categoría
            function editarCategoria(categoriaId) {
                // Buscar la categoría en el modelo
                for (let i = 0; i < categoriasModel.count; i++) {
                    if (categoriasModel.get(i).id_categoria === categoriaId) {
                        // Cargar datos en el objeto nuevaCategoria para edición
                        nuevaCategoria = {
                            "id_categoria": categoriasModel.get(i).id_categoria,
                            "nombre": categoriasModel.get(i).nombre,
                            "descripcion": categoriasModel.get(i).descripcion,
                            "activo": categoriasModel.get(i).activo
                        };
                        
                        // Abrir diálogo en modo edición
                        dialogNuevaCategoria.title = "Editar Categoría";
                        dialogNuevaCategoria.modoEdicion = true;
                        dialogNuevaCategoria.open();
                        break;
                    }
                }
            }
            
            // Función para cambiar el estado de una categoría
            function cambiarEstadoCategoria(categoriaId, nuevoEstado) {
                // Buscar la categoría en el modelo
                for (let i = 0; i < categoriasModel.count; i++) {
                    if (categoriasModel.get(i).id_categoria === categoriaId) {
                        // En una aplicación real, aquí harías una actualización en la base de datos
                        
                        // Por ahora, solo actualizamos el modelo local
                        categoriasModel.setProperty(i, "activo", nuevoEstado);
                        
                        showMessage("Estado de categoría actualizado");
                        break;
                    }
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
                // En una aplicación real, aquí harías una eliminación en la base de datos
                
                // Eliminar del modelo local
                for (let i = 0; i < categoriasModel.count; i++) {
                    if (categoriasModel.get(i).id_categoria === categoriaId) {
                        categoriasModel.remove(i);
                        break;
                    }
                }
                
                showMessage("Categoría eliminada correctamente");
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
        height: 700
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
                        onTextChanged: nuevoProducto.nombre_comercial = text
                    }
                    
                    // Categoría
                    Text {
                        text: "Categoría:"
                        Layout.alignment: Qt.AlignRight
                    }
                    
                    ComboBox {
                        id: cmbCategoria
                        Layout.fillWidth: true
                        model: categoriasModel
                        textRole: "nombre"
                        valueRole: "id_categoria"
                        onCurrentIndexChanged: {
                            if (currentIndex >= 0) {
                                nuevoProducto.id_categoria = currentValue
                            }
                        }
                    }
                    
                    // Formulación (en lugar de Ingrediente Activo)
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
                            model: ["L", "Kg"]
                            onCurrentTextChanged: nuevoProducto.unidad = currentText
                        }
                    }
                    
                    // Precio Unitario
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
                    
                    // Registro 
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
                        onTextChanged: nuevoProducto.fecha_registro = text
                    }
                    
                    // Estado
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
                    
                    // Notas (en lugar de Observaciones)
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
                    if (txtNombreComercial.text === "" || cmbCategoria.currentIndex < 0) {
                        mensajeValidacionProducto.text = "Por favor, complete el nombre comercial y seleccione una categoría";
                        return;
                    }
                    
                    guardarNuevoProducto();
                }
            }
        }
        
        // Resetea el formulario al cerrar
        onClosed: {
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
        // Crear un objeto con toda la información del producto según la estructura de la tabla
        var datosProducto = {
            id_producto: productosModel.count + 1,  // ID temporal (normalmente generado por la BD)
            id_categoria: nuevoProducto.id_categoria,
            nombre_comercial: nuevoProducto.nombre_comercial,
            formulacion: nuevoProducto.formulacion || cmbFormulacion.currentText,
            unidad: nuevoProducto.unidad,
            precio: nuevoProducto.precio,
            stock: nuevoProducto.stock,
            registro: nuevoProducto.registro || txtRegistro.text || "PENDIENTE",
            notas: nuevoProducto.notas,
            fecha_registro: nuevoProducto.fecha_registro,
            activo: nuevoProducto.activo
        };
        
        console.log("Guardando producto:", JSON.stringify(datosProducto));
        
        // Aquí iría el código para insertar en la base de datos SQL Server
        // Por ahora, solo añadimos al modelo local
        productosModel.append(datosProducto)
        
        // Cerrar el diálogo
        dialogNuevoProducto.close()
        
        // Mensaje de éxito
        showMessage("Producto guardado correctamente")
    }
    
    // Función para guardar nueva categoría
    function guardarNuevaCategoria() {
        var datosCategoria = {
            id_categoria: categoriasModel.count + 1,  // ID temporal (en producción lo generaría la BD)
            nombre: nuevaCategoria.nombre,
            descripcion: nuevaCategoria.descripcion || "",
            activo: nuevaCategoria.activo
        };
        
        console.log("Guardando categoría:", JSON.stringify(datosCategoria));
        categoriasModel.append(datosCategoria)
        // Cerrar el diálogo
        dialogNuevaCategoria.close()
     
        // Mensaje de éxito
        showMessage("Categoría guardada correctamente")
    }
    
    // Función para guardar nueva mezcla
    function guardarNuevaMezcla() {
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
        mezclasModel.append(datosMezcla)
        dialogNuevaMezcla.close()
        
        // Mensaje de éxito
        showMessage("Mezcla guardada correctamente")
    }
    
    // Función para guardar nuevo tratamiento
    function guardarNuevoTratamiento() {
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