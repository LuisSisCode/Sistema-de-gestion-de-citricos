import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle{
    id: reportesRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    // Propiedad para controlar qué reporte está visible
    property string reporteActivo: ""

    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "GESTIÓN DE INFORMES Y ESTADISTICAS"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.centerIn: parent
        }       
    }

    // Panel principal
    ColumnLayout {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        spacing: 20
        
        // Panel de filtros
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
                
                Text {
                    text: "Tipo de Reporte:"
                    font.pixelSize: 14
                }
                
                ComboBox {
                    id: comboTipoReporte
                    Layout.preferredWidth: 250
                    model: [
                        "Producción por Ciclo", 
                        "Ventas por Cliente", 
                        "Costos de Insumos", 
                        "Rendimiento por Variedad",
                        "Inventario de Productos",
                        "Uso de Maquinaria",
                        "Análisis de Plagas",
                        "Balance Financiero",
                        "Predicción de Cosecha"
                    ]
                    implicitHeight: 36
                }
                
                Text {
                    text: "Período:"
                    font.pixelSize: 14
                }
                
                ComboBox {
                    Layout.preferredWidth: 200
                    model: ["Último mes", "Último trimestre", "Último año", "Personalizado"]
                    implicitHeight: 36
                }
                
                Button {
                    text: "Generar"
                    implicitHeight: 36
                    onClicked: {
                        // Mostrar el reporte seleccionado en el combo
                        let reporteSeleccionado = comboTipoReporte.currentText;
                        
                        if (reporteSeleccionado === "Producción por Ciclo") {
                            reportesRoot.reporteActivo = "produccionCiclo";
                        } else if (reporteSeleccionado === "Ventas por Cliente") {
                            reportesRoot.reporteAct
                            reportesRoot.reporteActivo = "ventasCliente";
                        } else if (reporteSeleccionado === "Costos de Insumos") {
                            reportesRoot.reporteActivo = "costosInsumos";
                        } else if (reporteSeleccionado === "Rendimiento por Variedad") {
                            reportesRoot.reporteActivo = "rendimientoVariedad";
                        } else if (reporteSeleccionado === "Inventario de Productos") {
                            reportesRoot.reporteActivo = "inventarioProductos";
                        } else if (reporteSeleccionado === "Uso de Maquinaria") {
                            reportesRoot.reporteActivo = "usoMaquinaria";
                        } else if (reporteSeleccionado === "Análisis de Plagas") {
                            reportesRoot.reporteActivo = "analisisPlagas";
                        } else if (reporteSeleccionado === "Balance Financiero") {
                            reportesRoot.reporteActivo = "balanceFinanciero";
                        } else if (reporteSeleccionado === "Predicción de Cosecha") {
                            reportesRoot.reporteActivo = "prediccionCosecha";
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Exportar PDF"
                    implicitHeight: 36
                }
                
                Button {
                    text: "Exportar Excel"
                    implicitHeight: 36
                }
            }
        }
        
        // Vista de cuadrícula o detalle según reporteActivo
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Grid de reportes disponibles (solo visible cuando no hay reporte activo)
            GridView {
                id: reportesGrid
                anchors.fill: parent
                visible: reportesRoot.reporteActivo === ""
                clip: true
                cellWidth: width / 3
                cellHeight: 150
                model: ListModel {
                    ListElement { 
                        titulo: "Producción por Ciclo" 
                        descripcion: "Analiza rendimiento y costos de cada ciclo productivo."
                        icono: "📊"
                        idReporte: "produccionCiclo"
                    }
                    ListElement { 
                        titulo: "Ventas por Cliente" 
                        descripcion: "Informe detallado de ventas agrupadas por cliente."
                        icono: "📈"
                        idReporte: "ventasCliente"
                    }
                    ListElement { 
                        titulo: "Costos de Insumos" 
                        descripcion: "Desglose de gastos en insumos agrícolas."
                        icono: "💰"
                        idReporte: "costosInsumos"
                    }
                    ListElement { 
                        titulo: "Rendimiento por Variedad" 
                        descripcion: "Compara el rendimiento entre diferentes variedades de cítricos."
                        icono: "🍊"
                        idReporte: "rendimientoVariedad"
                    }
                    ListElement { 
                        titulo: "Inventario de Productos" 
                        descripcion: "Estado actual del inventario de productos agroquímicos."
                        icono: "📦"
                        idReporte: "inventarioProductos"
                    }
                    ListElement { 
                        titulo: "Uso de Maquinaria" 
                        descripcion: "Estadísticas de uso y costos de mantenimiento de equipos."
                        icono: "🚜"
                        idReporte: "usoMaquinaria"
                    }
                    ListElement { 
                        titulo: "Análisis de Plagas" 
                        descripcion: "Incidencia de plagas y efectividad de tratamientos."
                        icono: "🐛"
                        idReporte: "analisisPlagas"
                    }
                    ListElement { 
                        titulo: "Balance Financiero" 
                        descripcion: "Resumen de ingresos, gastos y rentabilidad."
                        icono: "💹"
                        idReporte: "balanceFinanciero"
                    }
                    ListElement { 
                        titulo: "Predicción de Cosecha" 
                        descripcion: "Estimación de cosechas futuras basada en datos históricos."
                        icono: "🔮"
                        idReporte: "prediccionCosecha"
                    }
                }
                
                delegate: Rectangle {
                    width: reportesGrid.cellWidth - 20
                    height: reportesGrid.cellHeight - 20
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Al hacer clic, establecemos directamente la propiedad reporteActivo
                            reportesRoot.reporteActivo = idReporte;
                            console.log("Seleccionado reporte: " + idReporte);
                        }
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        // Icono del reporte
                        Text {
                            text: icono
                            font.pixelSize: 32
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        // Título del reporte
                        Text {
                            text: titulo
                            font.pixelSize: 16
                            font.bold: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        // Descripción
                        Text {
                            text: descripcion
                            font.pixelSize: 12
                            color: "#757575"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

            
        // Definición de los reportes

        // 1. REPORTE: PRODUCCIÓN POR CICLO
        Rectangle {
            id: reporteProduccionCiclo
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "produccionCiclo"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Producción por Ciclo"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Ciclo:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los ciclos", "Ciclo Norte 1", "Ciclo Este 2", "Ciclo Sur 3"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Variedad:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas las variedades", "Limón Persa", "Naranja Valencia", "Mandarina Clementina"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Contenido del reporte - Datos de resumen
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Total de producción
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Producción Total"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "28.450 kg"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Rendimiento promedio
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Rendimiento Promedio"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "3.2 ton/ha"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Costo total
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Costo Total"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 34.280"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Costo por kg
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Costo por Kilo"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 1.2"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { ciclo: "Ciclo Norte 1"; variedad: "Limón Persa"; area: "5.2"; produccion: "14.560"; rendimiento: "2.8"; costo: "16.240"; costoUnit: "1.1" }
                            ListElement { ciclo: "Ciclo Este 2"; variedad: "Naranja Valencia"; area: "3.8"; produccion: "9.120"; rendimiento: "2.4"; costo: "10.580"; costoUnit: "1.2" }
                            ListElement { ciclo: "Ciclo Sur 3"; variedad: "Mandarina Clementina"; area: "2.0"; produccion: "4.770"; rendimiento: "2.4"; costo: "7.460"; costoUnit: "1.6" }
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
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Ciclo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Variedad"
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Producción (kg)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Rend. (ton/ha)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Costo Total (Bs.)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Costo/kg (Bs.)"
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
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: ciclo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: variedad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: area
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: produccion
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: rendimiento
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: costo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: costoUnit
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                    }
                }
                
                // Gráfico de visualización simplificado
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Aquí se mostraría un gráfico comparativo de producción por ciclo"
                        font.pixelSize: 16
                        color: "#949393"
                    }
                }
            }
        }
        
        // 2. REPORTE: VENTAS POR CLIENTE
        Rectangle {
            id: reporteVentasCliente
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "ventasCliente"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Ventas por Cliente"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Cliente:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los clientes", "Mercadona S.A.", "Distribuidora Norte", "Frutas Frescas Inc."]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Producto:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los productos", "Limón Persa", "Naranja Valencia", "Mandarina Clementina"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Contenido del reporte similar a Producción por Ciclo
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Ventas totales
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Ventas Totales"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 112.480"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Cantidad total
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Cantidad Total"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "43.260 kg"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Cliente principal
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Cliente Principal"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Mercadona S.A."
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Margen promedio
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Margen Promedio"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "24%"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { cliente: "Mercadona S.A."; producto: "Limón Persa"; cantidad: "18.500"; precio: "2.2"; total: "40.700"; margen: "26%" }
                            ListElement { cliente: "Distribuidora Norte"; producto: "Naranja Valencia"; cantidad: "12.760"; precio: "1.8"; total: "22.968"; margen: "22%" }
                            ListElement { cliente: "Frutas Frescas Inc."; producto: "Mandarina Clementina"; cantidad: "12.000"; precio: "4.1"; total: "49.200"; margen: "25%" }
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
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: "Cliente"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: "Producto"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Cantidad (kg)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Precio (Bs./kg)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Total (Bs.)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Margen"
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
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: cliente
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: producto
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: cantidad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: precio
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: total
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: margen
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                    }
                }
                
                // Gráfico de visualización simplificado
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Aquí se mostraría un gráfico de ventas por cliente"
                        font.pixelSize: 16
                        color: "#757575"
                    }
                }
            }
        }
        // 3. REPORTE: COSTOS DE INSUMOS
        Rectangle {
            id: reporteCostosInsumos
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "costosInsumos"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Costos de Insumos"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Categoría:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas las categorías", "Fertilizantes", "Pesticidas", "Combustibles", "Otros"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Proveedor:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos los proveedores", "AgroSupply S.A.", "Chemicals Inc.", "Fertilab"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Contenido del reporte - Datos de resumen
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Costo Total
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Costo Total"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 42.850"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Mayor Gasto
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Mayor Gasto"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Fertilizantes"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Proveedor Principal
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Proveedor Principal"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "AgroSupply S.A."
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // % del Costo Total
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "% del Costo Total"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "28%"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { categoria: "Fertilizantes"; producto: "Nitrato de Amonio"; cantidad: "2.500"; precio: "4.2"; total: "10.500"; proveedor: "AgroSupply S.A." }
                            ListElement { categoria: "Pesticidas"; producto: "Insecticida Orgánico"; cantidad: "1.200"; precio: "8.3"; total: "9.960"; proveedor: "Chemicals Inc." }
                            ListElement { categoria: "Combustibles"; producto: "Diésel"; cantidad: "1.800"; precio: "3.5"; total: "6.300"; proveedor: "PetroDist" }
                            ListElement { categoria: "Fertilizantes"; producto: "Fosfato Natural"; cantidad: "2.200"; precio: "3.8"; total: "8.360"; proveedor: "Fertilab" }
                            ListElement { categoria: "Otros"; producto: "Herramientas de Poda"; cantidad: "45"; precio: "170"; total: "7.650"; proveedor: "GardenTools" }
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Categoría"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: "Producto"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Cantidad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Precio Unit."
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Total (Bs.)"
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: categoria
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: producto
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: cantidad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: precio
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: total
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: proveedor
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                    }
                }
                
                // Gráfico de visualización simplificado
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Aquí se mostraría un gráfico comparativo de costos por categoría"
                        font.pixelSize: 16
                        color: "#757575"
                    }
                }
            }
        }
        
        // 4. REPORTE: RENDIMIENTO POR VARIEDAD
        Rectangle {
            id: reporteRendimientoVariedad
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "rendimientoVariedad"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Rendimiento por Variedad"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Temporada:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas las temporadas", "2024-1", "2023-2", "2023-1"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Parcela:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas las parcelas", "Norte A", "Este B", "Sur C"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Contenido del reporte - Datos de resumen
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Mejor Rendimiento
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Mejor Rendimiento"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Valencia (3.8 ton/ha)"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Rend. Promedio
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Rend. Promedio"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "3.1 ton/ha"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Peor Rendimiento
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Peor Rendimiento"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Persa (2.5 ton/ha)"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Variedad Principal
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Variedad Principal"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Naranja Valencia"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { variedad: "Naranja Valencia"; temporada: "2024-1"; area: "6.2"; produccion: "23.560"; rendimiento: "3.8"; ingresos: "48.240"; rentabilidad: "42%" }
                            ListElement { variedad: "Limón Persa"; temporada: "2024-1"; area: "4.8"; produccion: "12.000"; rendimiento: "2.5"; ingresos: "34.800"; rentabilidad: "38%" }
                            ListElement { variedad: "Mandarina Clementina"; temporada: "2024-1"; area: "3.5"; produccion: "10.850"; rendimiento: "3.1"; ingresos: "32.550"; rentabilidad: "45%" }
                            ListElement { variedad: "Naranja Navel"; temporada: "2024-1"; area: "2.8"; produccion: "8.400"; rendimiento: "3.0"; ingresos: "25.200"; rentabilidad: "40%" }
                            ListElement { variedad: "Limón Tahití"; temporada: "2024-1"; area: "2.0"; produccion: "5.400"; rendimiento: "2.7"; ingresos: "16.200"; rentabilidad: "36%" }
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
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Variedad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Temporada"
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Producción (kg)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Rend. (ton/ha)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Ingresos (Bs.)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Rentabilidad"
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
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: variedad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: temporada
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: area
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: produccion
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: rendimiento
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: ingresos
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: rentabilidad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                    }
                }
                
                // Gráfico de visualización simplificado
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Aquí se mostraría un gráfico comparativo de rendimiento por variedad"
                        font.pixelSize: 16
                        color: "#757575"
                    }
                }
            }
        }
        // 5. REPORTE: INVENTARIO DE PRODUCTOS
        Rectangle {
            id: reporteInventarioProductos
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "inventarioProductos"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Inventario de Productos"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Categoría:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas", "Fertilizantes", "Pesticidas", "Herramientas", "Equipos"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Almacén:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos", "Principal", "Norte", "Sur"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Datos de resumen
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Total en Inventario
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Total en Inventario"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 86.420"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Productos Bajos
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Productos Bajos"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "8 productos"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#E53935"
                            }
                        }
                        
                        // Productos Totales
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Productos Totales"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "42 productos"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Mayor Stock
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Mayor Stock"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Fertilizantes"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { producto: "Fertilizante NPK 15-15-15"; categoria: "Fertilizantes"; stock: "1250"; unidad: "kg"; precio: "3.8"; total: "4.750"; estado: "Normal" }
                            ListElement { producto: "Insecticida Biológico"; categoria: "Pesticidas"; stock: "85"; unidad: "L"; precio: "42"; total: "3.570"; estado: "Bajo" }
                            ListElement { producto: "Tijeras de Poda Profesional"; categoria: "Herramientas"; stock: "12"; unidad: "unid"; precio: "350"; total: "4.200"; estado: "Normal" }
                            ListElement { producto: "Sulfato de Amonio"; categoria: "Fertilizantes"; stock: "980"; unidad: "kg"; precio: "4.2"; total: "4.116"; estado: "Normal" }
                            ListElement { producto: "Fungicida Orgánico"; categoria: "Pesticidas"; stock: "35"; unidad: "L"; precio: "85"; total: "2.975"; estado: "Bajo" }
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
                                    width: parent.width * 0.3
                                    height: parent.height
                                    text: "Producto"
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
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Stock"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Unidad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Precio Unit."
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Total (Bs.)"
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
                                    width: parent.width * 0.3
                                    height: parent.height
                                    text: producto
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: categoria
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: stock
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: unidad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: precio
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: total
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: estado
                                    color: estado === "Bajo" ? "#E53935" : "#212121"
                                    font.bold: estado === "Bajo"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 6. REPORTE: USO DE MAQUINARIA
        Rectangle {
            id: reporteUsoMaquinaria
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "usoMaquinaria"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Uso de Maquinaria"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Equipo:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos", "Tractor John Deere", "Fumigadora", "Cosechadora", "Arado"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Período:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Último mes", "Último trimestre", "Último año", "Todo"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Datos de resumen
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Horas Totales
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Horas Totales"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "1.284 hrs"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Equipo Más Usado
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Equipo Más Usado"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Tractor John Deere"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Costo Mant. Total
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Costo Mant. Total"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 18.450"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Costo por Hora
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Costo por Hora"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 14.4"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { equipo: "Tractor John Deere"; horasUso: "520"; costoHora: "22"; mantenimiento: "5.840"; combustible: "3.740"; estado: "Óptimo" }
                            ListElement { equipo: "Fumigadora Motorizada"; horasUso: "285"; costoHora: "14"; mantenimiento: "2.280"; combustible: "1.710"; estado: "Regular" }
                            ListElement { equipo: "Cosechadora"; horasUso: "180"; costoHora: "28"; mantenimiento: "4.320"; combustible: "2.520"; estado: "Óptimo" }
                            ListElement { equipo: "Arado Hidráulico"; horasUso: "210"; costoHora: "12"; mantenimiento: "1.680"; combustible: "1.050"; estado: "Mantenimiento" }
                            ListElement { equipo: "Sembradora"; horasUso: "89"; costoHora: "18"; mantenimiento: "890"; combustible: "534"; estado: "Óptimo" }
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
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: "Equipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Horas de Uso"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Costo/Hora (Bs.)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Mant. (Bs.)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Combustible (Bs.)"
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
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: equipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: horasUso
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: costoHora
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: mantenimiento
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: combustible
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: estado
                                    color: estado === "Mantenimiento" ? "#F57F17" : (estado === "Regular" ? "#FB8C00" : "#33691E")
                                    font.bold: estado !== "Óptimo"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                    }
                }
            }
        }
        // 7. REPORTE: ANÁLISIS DE PLAGAS
        Rectangle {
            id: reporteAnalisisPlagas
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "analisisPlagas"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Análisis de Plagas"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Tipo de Plaga:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas", "Insectos", "Hongos", "Bacterias", "Virus", "Nematodos"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Parcela:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas las parcelas", "Norte A", "Este B", "Sur C"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Contenido del reporte - Datos de resumen
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Casos Detectados
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Casos Detectados"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "84 casos"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Plaga Principal
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Plaga Principal"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Mosca de la fruta"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Efectividad Tratamiento
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Efectividad Tratamiento"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "78%"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Costo Tratamientos
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Costo Tratamientos"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 12.850"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { plaga: "Mosca de la fruta"; tipo: "Insectos"; parcela: "Este B"; variedad: "Naranja Valencia"; casos: "28"; impacto: "Alto"; tratamiento: "Trampas + Biocontrol"; efectividad: "72%"; costo: "3.640" }
                            ListElement { plaga: "Phytophthora"; tipo: "Hongos"; parcela: "Norte A"; variedad: "Limón Persa"; casos: "12"; impacto: "Medio"; tratamiento: "Fungicida sistémico"; efectividad: "85%"; costo: "2.450" }
                            ListElement { plaga: "Ácaros"; tipo: "Insectos"; parcela: "Sur C"; variedad: "Mandarina"; casos: "22"; impacto: "Medio"; tratamiento: "Acaricida orgánico"; efectividad: "65%"; costo: "1.980" }
                            ListElement { plaga: "Cancrosis"; tipo: "Bacterias"; parcela: "Norte A"; variedad: "Naranja Valencia"; casos: "8"; impacto: "Alto"; tratamiento: "Cobre + Poda"; efectividad: "90%"; costo: "2.760" }
                            ListElement { plaga: "Gomosis"; tipo: "Hongos"; parcela: "Este B"; variedad: "Limón Tahití"; casos: "14"; impacto: "Alto"; tratamiento: "Control químico"; efectividad: "80%"; costo: "2.020" }
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
                                    width: parent.width * 0.18
                                    height: parent.height
                                    text: "Plaga"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Tipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Parcela"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Variedad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.08
                                    height: parent.height
                                    text: "Casos"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.08
                                    height: parent.height
                                    text: "Impacto"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: "Tratamiento"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.08
                                    height: parent.height
                                    text: "Efectividad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.07
                                    height: parent.height
                                    text: "Costo (Bs.)"
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
                                    width: parent.width * 0.18
                                    height: parent.height
                                    text: plaga
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: tipo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: parcela
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: variedad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.08
                                    height: parent.height
                                    text: casos
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.08
                                    height: parent.height
                                    text: impacto
                                    color: impacto === "Alto" ? "#E53935" : (impacto === "Medio" ? "#FB8C00" : "#33691E")
                                    font.bold: impacto === "Alto"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    text: tratamiento
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    width: parent.width * 0.08
                                    height: parent.height
                                    text: efectividad
                                    color: parseInt(efectividad) > 80 ? "#33691E" : (parseInt(efectividad) > 70 ? "#FB8C00" : "#E53935")
                                    font.bold: parseInt(efectividad) > 80
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.07
                                    height: parent.height
                                    text: costo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                    }
                }
                
                // Gráfico de visualización simplificado
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Aquí se mostraría un gráfico de incidencia de plagas y efectividad de tratamientos"
                        font.pixelSize: 16
                        color: "#757575"
                    }
                }
            }
        }

        // 8. REPORTE: BALANCE FINANCIERO
        Rectangle {
            id: reporteBalanceFinanciero
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "balanceFinanciero"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Balance Financiero"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Período:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Año 2024", "Segundo Trimestre 2024", "Primer Trimestre 2024", "Año 2023"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Tipo:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todos", "Ingresos", "Gastos"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Contenido del reporte - Datos de resumen
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Ingresos Totales
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Ingresos Totales"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 248.650"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#2E7D32"
                            }
                        }
                        
                        // Gastos Totales
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Gastos Totales"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 184.320"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#C62828"
                            }
                        }
                        
                        // Beneficio Neto
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Beneficio Neto"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 64.330"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#1565C0"
                            }
                        }
                        
                        // Margen de Beneficio
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Margen de Beneficio"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "25.87%"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { concepto: "Ventas de Naranja Valencia"; tipo: "Ingreso"; trimestre: "Q1-2024"; monto: "89.450"; acumulado: "89.450"; porcentaje: "36%" }
                            ListElement { concepto: "Ventas de Limón Persa"; tipo: "Ingreso"; trimestre: "Q1-2024"; monto: "62.780"; acumulado: "152.230"; porcentaje: "25%" }
                            ListElement { concepto: "Ventas de Mandarina"; tipo: "Ingreso"; trimestre: "Q1-2024"; monto: "54.420"; acumulado: "206.650"; porcentaje: "22%" }
                            ListElement { concepto: "Otros ingresos"; tipo: "Ingreso"; trimestre: "Q1-2024"; monto: "42.000"; acumulado: "248.650"; porcentaje: "17%" }
                            ListElement { concepto: "Insumos agrícolas"; tipo: "Gasto"; trimestre: "Q1-2024"; monto: "64.850"; acumulado: "64.850"; porcentaje: "35%" }
                            ListElement { concepto: "Mano de obra"; tipo: "Gasto"; trimestre: "Q1-2024"; monto: "58.640"; acumulado: "123.490"; porcentaje: "32%" }
                            ListElement { concepto: "Maquinaria y equipos"; tipo: "Gasto"; trimestre: "Q1-2024"; monto: "24.780"; acumulado: "148.270"; porcentaje: "13%" }
                            ListElement { concepto: "Mantenimiento"; tipo: "Gasto"; trimestre: "Q1-2024"; monto: "18.450"; acumulado: "166.720"; porcentaje: "10%" }
                            ListElement { concepto: "Otros gastos"; tipo: "Gasto"; trimestre: "Q1-2024"; monto: "17.600"; acumulado: "184.320"; porcentaje: "10%" }
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
                                    width: parent.width * 0.3
                                    height: parent.height
                                    text: "Concepto"
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
                                    text: "Trimestre"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Monto (Bs.)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Acumulado (Bs.)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "% del Total"
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
                                    width: parent.width * 0.3
                                    height: parent.height
                                    text: concepto
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: tipo
                                    color: tipo === "Ingreso" ? "#2E7D32" : "#C62828"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: trimestre
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: monto
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: acumulado
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: porcentaje
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                    }
                }
                
                // Gráfico de visualización simplificado
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Aquí se mostraría un gráfico comparativo de ingresos y gastos"
                        font.pixelSize: 16
                        color: "#757575"
                    }
                }
            }
        }
        // 9. REPORTE: PREDICCIÓN DE COSECHA
        Rectangle {
            id: reportePrediccionCosecha
            anchors.fill: parent
            visible: reportesRoot.reporteActivo === "prediccionCosecha"
            color: "white"
            radius: 25
            border.color: "#EEEEEE"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Cabecera del reporte
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    Button {
                        text: "← Volver"
                        implicitHeight: 36
                        onClicked: reportesRoot.reporteActivo = ""
                    }
                    
                    Text {
                        text: "Predicción de Cosecha"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Imprimir"
                        implicitHeight: 36
                    }
                    
                    Button {
                        text: "Exportar"
                        implicitHeight: 36
                    }
                }
                
                // Filtros específicos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15
                        
                        Text {
                            text: "Período Futuro:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Próximo trimestre", "Próximo semestre", "Próximo año"]
                            implicitHeight: 36
                        }
                        
                        Text {
                            text: "Variedad:"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            Layout.preferredWidth: 200
                            model: ["Todas las variedades", "Naranja Valencia", "Limón Persa", "Mandarina Clementina"]
                            implicitHeight: 36
                        }
                        
                        Button {
                            text: "Aplicar Filtros"
                            implicitHeight: 36
                        }
                    }
                }
                
                // Contenido del reporte - Datos de resumen
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#FAFAFA"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20
                        
                        // Producción Estimada
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Producción Estimada"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "32.450 kg"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Variación vs Actual
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Variación vs Actual"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "+14%"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#2E7D32"
                            }
                        }
                        
                        // Confianza Predicción
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Confianza Predicción"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "82%"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                        
                        // Ingresos Estimados
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Ingresos Estimados"
                                font.pixelSize: 12
                                color: "#757575"
                            }
                            
                            Text {
                                text: "Bs. 94.780"
                                font.pixelSize: 22
                                font.bold: true
                            }
                        }
                    }
                }
                
                // Tabla de datos del reporte
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#EEEEEE"
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ListModel {
                            ListElement { variedad: "Naranja Valencia"; periodo: "Q2-2024"; produccionActual: "12.450"; produccionEstimada: "14.200"; variacion: "+14%"; confianza: "85%"; factores: "Clima favorable, manejo mejorado" }
                            ListElement { variedad: "Limón Persa"; periodo: "Q2-2024"; produccionActual: "8.240"; produccionEstimada: "9.800"; variacion: "+19%"; confianza: "78%"; factores: "Nuevas plantaciones, control plagas" }
                            ListElement { variedad: "Mandarina Clementina"; periodo: "Q2-2024"; produccionActual: "6.180"; produccionEstimada: "6.650"; variacion: "+8%"; confianza: "82%"; factores: "Reducción de estrés hídrico" }
                            ListElement { variedad: "Limón Tahití"; periodo: "Q2-2024"; produccionActual: "1.850"; produccionEstimada: "1.800"; variacion: "-3%"; confianza: "75%"; factores: "Incidencia de plagas" }
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Variedad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Período"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Producción Actual (kg)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Producción Est. (kg)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Variación"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Confianza"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: "Factores Relevantes"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                        }
                
                        // Delegado para cada fila
                        delegate: Rectangle {
                            width: parent.width
                            height: 60
                            color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"
                            
                            Row {
                                anchors.fill: parent
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: variedad
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: periodo
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: produccionActual
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: produccionEstimada
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    font.bold: true
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: variacion
                                    color: variacion.charAt(0) === "+" ? "#2E7D32" : "#C62828"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: confianza
                                    color: parseInt(confianza) > 80 ? "#2E7D32" : (parseInt(confianza) > 70 ? "#FB8C00" : "#C62828")
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: factores
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    wrapMode: Text.WordWrap
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                }
                            }
                        }
                    }
                }
                
                // Sección adicional: Recomendaciones y Gráfico
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    spacing: 15
                    
                    // Recomendaciones
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        color: "white"
                        border.color: "#EEEEEE"
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            Text {
                                text: "Recomendaciones"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1565C0"
                            }
                            
                            Text {
                                text: "• Mantener monitoreo de condiciones climáticas para el próximo trimestre."
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "• Reforzar el programa de control preventivo de plagas en la variedad Limón Tahití."
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "• Planificar capacidad de almacenamiento para el incremento esperado en Naranja Valencia."
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "• Contactar a clientes clave para gestionar demanda del incremento previsto de producción."
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    // Gráfico
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredWidth: 2
                        color: "white"
                        border.color: "#EEEEEE"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Aquí se mostraría un gráfico de tendencia de producción y predicciones"
                            font.pixelSize: 16
                            color: "#757575"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
} 
                