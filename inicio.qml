import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

// Dashboard mejorado para sistema agrícola generalizado
Item {
    id: inicioContent
    anchors.fill: parent

    // ========================================
    // MODELOS DE DATOS DINÁMICOS
    // ========================================
    
    // Datos financieros
    QtObject {
        id: datosFinancieros
        property real ventasMesActual: 85420.50
        property real ventasMesAnterior: 72350.00
        property real ingresosPendientes: 23150.75
        property real costosMes: 45200.30
        property real presupuestoMes: 50000.00
        property real margenGanancia: 22.5
    }
    
    // Datos de producción
    QtObject {
        id: datosProduccion
        property real hectareasActivas: 18.5
        property real hectareasTotal: 24.7
        property int proximasCosechas: 7
        property int ciclosCompletados: 12
        property real rendimientoPromedio: 14.8
    }
    
    // Datos de inventario
    QtObject {
        id: datosInventario
        property real totalInventarioKg: 2450.5
        property real valorTotalInventario: 18720.40
        property int productosListos: 8
        property int productosStockBajo: 3
    }
    
    // Datos de alertas
    QtObject {
        id: datosAlertas
        property int tratamientosPendientes: 5
        property int mantenimientosVencidos: 2
        property int pagosPorVencer: 3
        property int parcelasAtencion: 1
    }

    // Modelo para cultivos y su producción
    ListModel {
        id: cultivosProduccionModel
        ListElement {
            tipoCultivo: "Arroz"
            cantidadActual: 850
            cantidadAnterior: 720
            valorActual: 25500
            valorAnterior: 21600
            unidad: "qq"
            color: "#4CAF50"
        }
        ListElement {
            tipoCultivo: "Soya"
            cantidadActual: 680
            cantidadAnterior: 590
            valorActual: 20400
            valorAnterior: 17700
            unidad: "qq"
            color: "#FF9800"
        }
        ListElement {
            tipoCultivo: "Cítricos"
            cantidadActual: 1200
            cantidadAnterior: 980
            valorActual: 12000
            valorAnterior: 9800
            unidad: "kg"
            color: "#FFC107"
        }
        ListElement {
            tipoCultivo: "Maíz"
            cantidadActual: 520
            cantidadAnterior: 450
            valorActual: 15600
            valorAnterior: 13500
            unidad: "qq"
            color: "#9C27B0"
        }
        ListElement {
            tipoCultivo: "Quinua"
            cantidadActual: 180
            cantidadAnterior: 140
            valorActual: 9000
            valorAnterior: 7000
            unidad: "qq"
            color: "#607D8B"
        }
    }

    // Modelo para rentabilidad por hectárea
    ListModel {
        id: rentabilidadModel
        ListElement {
            cultivo: "Soya"
            rentabilidad: 2800
            color: "#4CAF50"
        }
        ListElement {
            cultivo: "Quinua"
            rentabilidad: 2400
            color: "#FF9800"
        }
        ListElement {
            cultivo: "Arroz"
            rentabilidad: 1950
            color: "#2196F3"
        }
        ListElement {
            cultivo: "Maíz"
            rentabilidad: 1650
            color: "#9C27B0"
        }
        ListElement {
            cultivo: "Cítricos"
            rentabilidad: 1200
            color: "#FFC107"
        }
    }

    // Modelo para calendario de campo
    ListModel {
        id: calendarioCampoModel
        ListElement {
            fecha: "15/04/2025"
            actividad: "Siembra Arroz"
            parcela: "Parcela Norte 3"
            hectareas: "5.2"
            estado: "Programado"
        }
        ListElement {
            fecha: "18/04/2025"
            actividad: "Fertilización"
            parcela: "Parcela Sur 1"
            hectareas: "3.8"
            estado: "Pendiente"
        }
        ListElement {
            fecha: "22/04/2025"
            actividad: "Cosecha Soya"
            parcela: "Parcela Este 2"
            hectareas: "4.5"
            estado: "Programado"
        }
        ListElement {
            fecha: "25/04/2025"
            actividad: "Tratamiento"
            parcela: "Parcela Oeste 1"
            hectareas: "2.3"
            estado: "Programado"
        }
    }

    // Modelo para calendario comercial
    ListModel {
        id: calendarioComercialModel
        ListElement {
            fecha: "16/04/2025"
            actividad: "Entrega EMAPA"
            producto: "Arroz - 180 qq"
            cliente: "EMAPA Ichilo"
            estado: "Confirmado"
        }
        ListElement {
            fecha: "20/04/2025"
            actividad: "Reunión Comercial"
            producto: "Quinua Premium"
            cliente: "Exportadora Andes"
            estado: "Pendiente"
        }
        ListElement {
            fecha: "24/04/2025"
            actividad: "Renovar Contrato"
            producto: "Soya Integral"
            cliente: "Industrias La Paz"
            estado: "Por Negociar"
        }
    }

    // ========================================
    // COMPONENTES REUTILIZABLES
    // ========================================

    // Componente: Tarjeta métrica mejorada
    component MetricCard: Rectangle {
        radius: 12
        color: "#FFFFFF"
        
        property string title: ""
        property string mainValue: ""
        property string unit: ""
        property string subtitle: ""
        property string trend: ""
        property bool trendPositive: true
        property color accentColor: "#2E7D32"
        property string icon: ""
        
        // Sombra
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -2
            radius: 14
            color: "#15000000"
            opacity: 0.8
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            
            // Encabezado con ícono y título
            RowLayout {
                Layout.fillWidth: true
                
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: accentColor
                    opacity: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: icon
                        font.pixelSize: 18
                        font.bold: true
                        color: accentColor
                    }
                }
                
                Text {
                    text: title
                    font.family: "Arial"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#666666"
                    Layout.fillWidth: true
                }
            }
            
            // Valor principal
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: mainValue
                    font.family: "Arial"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#2C2C2C"
                }
                
                Text {
                    text: unit
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: "#999999"
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 4
                }
            }
            
            // Subtítulo
            Text {
                text: subtitle
                font.family: "Arial"
                font.pixelSize: 12
                color: "#777777"
                visible: text !== ""
            }
            
            Item { Layout.fillHeight: true }
            
            // Tendencia
            Rectangle {
                Layout.fillWidth: true
                height: 24
                radius: 12
                color: trendPositive ? "#E8F5E9" : "#FFEBEE"
                visible: trend !== ""
                
                Text {
                    anchors.centerIn: parent
                    text: trend
                    font.family: "Arial"
                    font.pixelSize: 12
                    font.bold: true
                    color: trendPositive ? "#2E7D32" : "#C62828"
                }
            }
        }
    }

    // Componente: Gráfico de barras comparativo mejorado
    component ComparativeBarChart: Rectangle {
        radius: 12
        color: "#FFFFFF"
        
        property string title: "Producción por Cultivo"
        property string subtitle: "Comparativa año actual vs anterior"
        
        // Sombra
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -2
            radius: 14
            color: "#15000000"
            opacity: 0.8
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Título
            Text {
                text: title
                font.family: "Arial"
                font.pixelSize: 18
                font.bold: true
                color: "#2C2C2C"
            }
            
            Text {
                text: subtitle
                font.family: "Arial"
                font.pixelSize: 12
                color: "#777777"
            }
            
            // Leyenda
            RowLayout {
                Layout.fillWidth: true
                
                Item { Layout.fillWidth: true }
                
                RowLayout {
                    spacing: 15
                    
                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 12
                            height: 3
                            color: "#4CAF50"
                        }
                        Text {
                            text: "2025 (Actual)"
                            font.family: "Arial"
                            font.pixelSize: 10
                            color: "#666666"
                        }
                    }
                    
                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 12
                            height: 3
                            color: "#E0E0E0"
                        }
                        Text {
                            text: "2024 (Anterior)"
                            font.family: "Arial"
                            font.pixelSize: 10
                            color: "#666666"
                        }
                    }
                }
            }
            
            // Gráfico
            Canvas {
                id: prodChart
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 200
                
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    var margin = 40;
                    var chartWidth = width - 2 * margin;
                    var chartHeight = height - 2 * margin;
                    var maxValue = 1300; // Valor máximo para escalar
                    
                    // Dibujar barras para cada cultivo
                    for (var i = 0; i < cultivosProduccionModel.count; i++) {
                        var item = cultivosProduccionModel.get(i);
                        var barWidth = chartWidth / (cultivosProduccionModel.count * 2.5);
                        var x = margin + (i * chartWidth / cultivosProduccionModel.count) + (barWidth * 0.2);
                        
                        // Barra del año anterior (fondo)
                        var heightAnterior = (item.cantidadAnterior / maxValue) * chartHeight;
                        var yAnterior = margin + chartHeight - heightAnterior;
                        
                        ctx.fillStyle = "#E0E0E0";
                        ctx.fillRect(x + barWidth * 0.1, yAnterior, barWidth * 0.8, heightAnterior);
                        
                        // Barra del año actual (primer plano)
                        var heightActual = (item.cantidadActual / maxValue) * chartHeight;
                        var yActual = margin + chartHeight - heightActual;
                        
                        ctx.fillStyle = item.color;
                        ctx.fillRect(x + barWidth * 0.2, yActual, barWidth * 0.6, heightActual);
                        
                        // Etiqueta del cultivo
                        ctx.fillStyle = "#333333";
                        ctx.font = "10px Arial";
                        ctx.textAlign = "center";
                        ctx.fillText(item.tipoCultivo, x + barWidth/2, height - 10);
                        
                        // Valor actual sobre la barra
                        ctx.fillStyle = "#333333";
                        ctx.font = "bold 9px Arial";
                        ctx.fillText(item.cantidadActual + " " + item.unidad, x + barWidth/2, yActual - 5);
                        
                        // Porcentaje de crecimiento
                        var crecimiento = ((item.cantidadActual - item.cantidadAnterior) / item.cantidadAnterior * 100).toFixed(0);
                        ctx.fillStyle = crecimiento > 0 ? "#4CAF50" : "#F44336";
                        ctx.font = "bold 8px Arial";
                        ctx.fillText((crecimiento > 0 ? "+" : "") + crecimiento + "%", x + barWidth/2, yActual - 18);
                    }
                }
            }
        }
    }

    // Componente: Gráfico de rentabilidad
    component ProfitabilityChart: Rectangle {
        radius: 12
        color: "#FFFFFF"
        
        property string title: "Rentabilidad por Hectárea"
        property string subtitle: "Bs/ha - Últimos 12 meses"
        
        // Sombra
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -2
            radius: 14
            color: "#15000000"
            opacity: 0.8
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            Text {
                text: title
                font.family: "Arial"
                font.pixelSize: 18
                font.bold: true
                color: "#2C2C2C"
            }
            
            Text {
                text: subtitle
                font.family: "Arial"
                font.pixelSize: 12
                color: "#777777"
            }
            
            Canvas {
                id: rentChart
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 180
                
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    var margin = 30;
                    var chartWidth = width - 2 * margin;
                    var chartHeight = height - 2 * margin;
                    var maxRent = 3000;
                    
                    for (var i = 0; i < rentabilidadModel.count; i++) {
                        var item = rentabilidadModel.get(i);
                        var barHeight = 20;
                        var y = margin + (i * (chartHeight / rentabilidadModel.count)) + (chartHeight / rentabilidadModel.count - barHeight) / 2;
                        var barWidth = (item.rentabilidad / maxRent) * chartWidth;
                        
                        // Barra de fondo
                        ctx.fillStyle = "#F5F5F5";
                        ctx.fillRect(margin, y, chartWidth, barHeight);
                        
                        // Barra de progreso
                        ctx.fillStyle = item.color;
                        ctx.fillRect(margin, y, barWidth, barHeight);
                        
                        // Etiqueta del cultivo
                        ctx.fillStyle = "#333333";
                        ctx.font = "12px Arial";
                        ctx.textAlign = "left";
                        ctx.fillText(item.cultivo, margin - 25, y + barHeight/2 + 4);
                        
                        // Valor
                        ctx.fillStyle = "#333333";
                        ctx.font = "bold 11px Arial";
                        ctx.textAlign = "right";
                        ctx.fillText("Bs " + item.rentabilidad, width - margin + 20, y + barHeight/2 + 4);
                    }
                }
            }
        }
    }

    // Componente: Tabla de calendario mejorada
    component CalendarTable: Rectangle {
        radius: 12
        color: "#FFFFFF"
        
        property string title: ""
        property string linkText: ""
        property alias model: tableList.model
        property alias delegate: tableList.delegate
        property color headerColor: "#F8F9FA"
        property var headers: []
        
        // Sombra
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -2
            radius: 14
            color: "#15000000"
            opacity: 0.8
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Encabezado
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: title
                    font.family: "Arial"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2C2C2C"
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: linkText
                    font.family: "Arial"
                    font.pixelSize: 12
                    color: "#2196F3"
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Navegar a calendario completo")
                        }
                    }
                }
            }
            
            // Separador
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E0E0E0"
            }
            
            // Tabla
            ListView {
                id: tableList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                header: Rectangle {
                    width: parent.width
                    height: 35
                    color: headerColor
                    
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        
                        Repeater {
                            model: headers
                            
                            Text {
                                width: (parent.width - 10) / headers.length
                                height: parent.height
                                text: modelData.text
                                font.family: "Arial"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#666666"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                            }
                        }
                    }
                }
            }
        }
    }

    // ========================================
    // LAYOUT PRINCIPAL
    // ========================================

    ScrollView {
        anchors.fill: parent
        clip: true
        
        Rectangle {
            anchors.fill: parent
            color: "#F8F9FA"
            z: -2
        }

        Flickable {
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: mainContainer.height + 50
            
            Item {
                id: mainContainer
                width: parent.width
                height: childrenRect.height + 50

                // ========================================
                // TÍTULO PRINCIPAL
                // ========================================
                Text {
                    id: dashboardTitle
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.topMargin: 24
                    text: "DASHBOARD AGRÍCOLA"
                    font.family: "Arial"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#1B5E20"
                }

                // ========================================
                // SECCIÓN 1: MÉTRICAS CLAVE (4 TARJETAS)
                // ========================================
                GridLayout {
                    id: metricsGrid
                    anchors.top: dashboardTitle.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    anchors.topMargin: 20
                    columns: 4
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    // Tarjeta 1: Resumen Financiero
                    MetricCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        title: "Resumen Financiero"
                        mainValue: "Bs " + (datosFinancieros.ventasMesActual / 1000).toFixed(0) + "K"
                        unit: ""
                        subtitle: "Ventas del mes"
                        trend: "+" + (((datosFinancieros.ventasMesActual - datosFinancieros.ventasMesAnterior) / datosFinancieros.ventasMesAnterior) * 100).toFixed(1) + "% vs mes anterior"
                        trendPositive: true
                        accentColor: "#4CAF50"
                        icon: "💰"
                    }
                    
                    // Tarjeta 2: Estado de Producción
                    MetricCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        title: "Estado de Producción"
                        mainValue: datosProduccion.hectareasActivas.toString()
                        unit: "ha"
                        subtitle: "Hectáreas en producción"
                        trend: datosProduccion.proximasCosechas + " cosechas próximos 30 días"
                        trendPositive: true
                        accentColor: "#FF9800"
                        icon: "🌾"
                    }
                    
                    // Tarjeta 3: Inventario General
                    MetricCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        title: "Inventario General"
                        mainValue: (datosInventario.totalInventarioKg / 1000).toFixed(1)
                        unit: "t"
                        subtitle: "Total en almacén"
                        trend: datosInventario.productosListos + " productos listos para venta"
                        trendPositive: true
                        accentColor: "#2196F3"
                        icon: "📦"
                    }
                    
                    // Tarjeta 4: Alertas y Tareas
                    MetricCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        title: "Alertas y Tareas"
                        mainValue: (datosAlertas.tratamientosPendientes + datosAlertas.mantenimientosVencidos).toString()
                        unit: ""
                        subtitle: "Tareas pendientes"
                        trend: datosAlertas.parcelasAtencion + " parcela requiere atención"
                        trendPositive: datosAlertas.parcelasAtencion === 0
                        accentColor: "#F44336"
                        icon: "⚠️"
                    }
                }

                // ========================================
                // SECCIÓN 2: GRÁFICOS ESTRATÉGICOS
                // ========================================
                GridLayout {
                    id: chartsGrid
                    anchors.top: metricsGrid.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    anchors.topMargin: 24
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    // Gráfico 1: Producción por Cultivo
                    ComparativeBarChart {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 300
                        title: "Producción por Tipo de Cultivo"
                        subtitle: "Cantidad cosechada - Comparativa anual"
                    }
                    
                    // Gráfico 2: Rentabilidad por Hectárea
                    ProfitabilityChart {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 300
                        title: "Rentabilidad por Hectárea"
                        subtitle: "Ingresos netos Bs/ha - Últimos 12 meses"
                    }
                }

                // ========================================
                // SECCIÓN 3: CALENDARIOS OPERATIVOS
                // ========================================
                GridLayout {
                    id: calendarsGrid
                    anchors.top: chartsGrid.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    anchors.topMargin: 24
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    // Calendario de Campo
                    CalendarTable {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 280
                        title: "Calendario de Campo"
                        linkText: "Ver calendario completo"
                        headerColor: "#E8F5E9"
                        headers: [
                            {text: "Fecha"},
                            {text: "Actividad"},
                            {text: "Parcela"},
                            {text: "Ha"},
                            {text: "Estado"}
                        ]
                        //
                        delegate: Rectangle {
                            width: parent.width
                            height: 45
                            color: index % 2 == 0 ? "#FAFAFA" : "#FFFFFF"
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                
                                Text {
                                    width: (parent.width - 10) / 5
                                    height: parent.height
                                    text: fecha
                                    font.family: "Arial"
                                    font.pixelSize: 12
                                    color: "#424242"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                
                                Text {
                                    width: (parent.width - 10) / 5
                                    height: parent.height
                                    text: actividad
                                    font.family: "Arial"
                                    font.pixelSize: 12
                                    color: "#424242"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                
                                Text {
                                    width: (parent.width - 10) / 5
                                    height: parent.height
                                    text: parcela
                                    font.family: "Arial"
                                    font.pixelSize: 12
                                    color: "#424242"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                
                                Text {
                                    width: (parent.width - 10) / 5
                                    height: parent.height
                                    text: hectareas + " ha"
                                    font.family: "Arial"
                                    font.pixelSize: 12
                                    color: "#424242"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                
                                Rectangle {
                                    width: (parent.width - 10) / 5
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 80
                                        height: 24
                                        radius: 12
                                        color: estado === "Programado" ? "#E8F5E9" : 
                                            estado === "Confirmado" ? "#E3F2FD" : "#FFF8E1"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: estado
                                            font.family: "Arial"
                                            font.pixelSize: 10
                                            color: estado === "Programado" ? "#2E7D32" : 
                                                estado === "Confirmado" ? "#1565C0" : "#E65100"
                                        }
                                    }
                                }
                            }
                        }
                        
                        model: calendarioCampoModel
                    }

                    // Calendario Comercial
                    CalendarTable {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 280
                        title: "Calendario Comercial"
                        linkText: "Ver agenda completa"
                        headerColor: "#E3F2FD"
                        headers: [
                            {text: "Fecha"},
                            {text: "Actividad"},
                            {text: "Producto/Cliente"},
                            {text: "Estado"}
                        ]
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 45
                            color: index % 2 == 0 ? "#F3F8FF" : "#FFFFFF"
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                
                                Text {
                                    width: (parent.width - 10) / 4
                                    height: parent.height
                                    text: fecha
                                    font.family: "Arial"
                                    font.pixelSize: 12
                                    color: "#424242"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                
                                Text {
                                    width: (parent.width - 10) / 4
                                    height: parent.height
                                    text: actividad
                                    font.family: "Arial"
                                    font.pixelSize: 12
                                    color: "#424242"
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }
                                
                                Column {
                                    width: (parent.width - 10) / 4
                                    height: parent.height
                                    spacing: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    leftPadding: 8
                                    
                                    Text {
                                        text: producto
                                        font.family: "Arial"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "#424242"
                                    }
                                    
                                    Text {
                                        text: cliente
                                        font.family: "Arial"
                                        font.pixelSize: 10
                                        color: "#666666"
                                    }
                                }
                                
                                Rectangle {
                                    width: (parent.width - 10) / 4
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 90
                                        height: 24
                                        radius: 12
                                        color: estado === "Confirmado" ? "#E8F5E9" : 
                                               estado === "Pendiente" ? "#FFF8E1" : "#FFEBEE"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: estado
                                            font.family: "Arial"
                                            font.pixelSize: 10
                                            color: estado === "Confirmado" ? "#2E7D32" : 
                                                   estado === "Pendiente" ? "#E65100" : "#C62828"
                                        }
                                    }
                                }
                            }
                        }
                        
                        model: calendarioComercialModel
                    }
                }

                // ========================================
                // SECCIÓN 4: RESUMEN RÁPIDO ADICIONAL
                // ========================================
                Rectangle {
                    id: quickSummary
                    anchors.top: calendarsGrid.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    anchors.topMargin: 24
                    height: 120
                    radius: 12
                    color: "#1B5E20"
                    
                    // Gradiente de fondo
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#1B5E20" }
                            GradientStop { position: 1.0; color: "#2E7D32" }
                        }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 32
                        
                        // Información general
                        ColumnLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "Resumen General del Sistema"
                                font.family: "Arial"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#FFFFFF"
                            }
                            
                            Text {
                                text: "Sistema Agrícola Provincia Ichilo - Datos actualizados en tiempo real"
                                font.family: "Arial"
                                font.pixelSize: 12
                                color: "#C8E6C9"
                            }
                        }
                        
                        // Estadísticas rápidas
                        GridLayout {
                            columns: 4
                            columnSpacing: 24
                            
                            // Total Agricultores
                            ColumnLayout {
                                spacing: 4
                                
                                Text {
                                    text: "24"
                                    font.family: "Arial"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Agricultores"
                                    font.family: "Arial"
                                    font.pixelSize: 10
                                    color: "#C8E6C9"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                            }
                            
                            // Total Fincas
                            ColumnLayout {
                                spacing: 4
                                
                                Text {
                                    text: "18"
                                    font.family: "Arial"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Fincas"
                                    font.family: "Arial"
                                    font.pixelSize: 10
                                    color: "#C8E6C9"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                            }
                            
                            // Ciclos Activos
                            ColumnLayout {
                                spacing: 4
                                
                                Text {
                                    text: "35"
                                    font.family: "Arial"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Ciclos Activos"
                                    font.family: "Arial"
                                    font.pixelSize: 10
                                    color: "#C8E6C9"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                            }
                            
                            // Valor Total
                            ColumnLayout {
                                spacing: 4
                                
                                Text {
                                    text: "Bs 892K"
                                    font.family: "Arial"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#FFFFFF"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: "Valor Total"
                                    font.family: "Arial"
                                    font.pixelSize: 10
                                    color: "#C8E6C9"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

                // ========================================
                // FUNCIONES JAVASCRIPT PARA CÁLCULOS
                // ========================================
                
                // Timer para actualizar datos en tiempo real (simulación)
                Timer {
                    id: dataUpdateTimer
                    interval: 30000 // 30 segundos
                    running: true
                    repeat: true
                    onTriggered: {
                        // Simular pequeños cambios en los datos
                        datosFinancieros.ventasMesActual += Math.random() * 100 - 50;
                        datosInventario.totalInventarioKg += Math.random() * 10 - 5;
                        
                        // Forzar repintado de gráficos
                        prodChart.requestPaint();
                        rentChart.requestPaint();
                    }
                }
                
                // Función para calcular el crecimiento porcentual
                function calculateGrowth(current, previous) {
                    if (previous === 0) return 0;
                    return ((current - previous) / previous * 100).toFixed(1);
                }
                
                // Función para formatear montos
                function formatCurrency(amount) {
                    if (amount >= 1000000) {
                        return "Bs " + (amount / 1000000).toFixed(1) + "M";
                    } else if (amount >= 1000) {
                        return "Bs " + (amount / 1000).toFixed(0) + "K";
                    } else {
                        return "Bs " + amount.toFixed(0);
                    }
                }
                
                // Función para determinar el color de tendencia
                function getTrendColor(isPositive) {
                    return isPositive ? "#4CAF50" : "#F44336";
                }
                
                // Conexión con backend (placeholder)
                Connections {
                    target: mainApp // Conexión con el objeto Python principal
                    
                    function onDataUpdated(newData) {
                        // Actualizar modelos con datos del backend
                        console.log("Datos actualizados desde Python:", newData);
                    }
                }
                Connections {
                    target: someModel
                    function onSomeValidSignal() {  // ← Usar una señal que exista
                        // código
                    }
                }

            }
        }
    }   
}           