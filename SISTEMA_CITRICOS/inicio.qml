import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Este archivo SOLO contiene el contenido del dashboard (pantalla de inicio)
Item {
    id: inicioContent
    anchors.fill: parent

    // Componente: Tarjeta de resumen
    component SummaryCard: Rectangle {
        radius: 10
        color: "#FFFFFF"

        property string title: ""
        property string value: ""
        property string valueUnit: ""
        property string icon: ""
        property color iconColor: "#2E7D32"
        property string trend: ""
        property bool trendPositive: true

        // Sombra alternativa
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -3
            radius: 13
            color: "#20000000"
            opacity: 0.5
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 5

            // Título
            Text {
                text: title
                font.family: "Arial"
                font.pixelSize: 14
                color: "#757575"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Valor principal y unidad
            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: value
                    font.family: "Arial"
                    font.pixelSize: 30
                    color: "#424242"
                }

                Text {
                    text: valueUnit
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: "#757575"
                    visible: valueUnit !== ""
                    Layout.alignment: Qt.AlignBottom
                }
            }

            // Tendencia
            Text {
                text: trend
                font.family: "Arial"
                font.pixelSize: 12
                color: trendPositive ? "#4CAF50" : "#F44336"
                visible: trend !== ""
            }

            Item { Layout.fillHeight: true }

            // Ícono
            Text {
                text: icon
                font.pixelSize: 24
                color: iconColor
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            }
        }
    }

    // Componente: Celda de encabezado de tabla
    component TableHeaderCell: Rectangle {
        height: parent.height
        color: "transparent"

        property string text: ""

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: parent.text
            font.family: "Arial"
            font.pixelSize: 12
            color: "#757575"
        }
    }

    // Componente: Gráfico circular de progreso
    component PieChart: Item {
        property real value: 0.5 // Valor entre 0 y 1
        property color color: "#2E7D32"
        property string text: ""
        property string subtext: ""

        Canvas {
            id: canvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d");
                var centerX = width / 2;
                var centerY = height / 2;
                var radius = Math.min(width, height) / 2 - 10;

                // Fondo gris claro
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
                ctx.lineWidth = 15;
                ctx.strokeStyle = "#E0E0E0";
                ctx.stroke();

                // Arco de progreso
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, -Math.PI / 2, (2 * Math.PI * value) - Math.PI / 2, false);
                ctx.lineWidth = 15;
                ctx.strokeStyle = color;
                ctx.stroke();
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.text
                font.family: "Arial"
                font.pixelSize: 20
                color: "#424242"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.subtext
                font.family: "Arial"
                font.pixelSize: 12
                color: "#757575"
            }
        }
    }

    // Datos de ejemplo para listados
    ListModel {
        id: alertasModel
        
        ListElement {
            tipo: "urgente"
            texto: "Nivel bajo de fungicida. Revisar inventario."
            fecha: "Hoy, 10:25"
            icono: "⚠️"
        }
        ListElement {
            tipo: "importante"
            texto: "Próxima cosecha en Parcela 3 en 5 días."
            fecha: "Hoy, 09:15"
            icono: "🍊"
        }
        ListElement {
            tipo: "normal"
            texto: "Reporte mensual de ventas disponible."
            fecha: "Ayer, 15:30"
            icono: "📊"
        }
    }
    
    Component {
        id: alertasDelegate
        
        Rectangle {
            width: ListView.view.width
            height: 70
            color: index % 2 == 0 ? "#FAFAFA" : "#FFFFFF"
            
            Rectangle {
                width: 3
                height: parent.height - 16
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color: tipo === "urgente" ? "#F44336" : tipo === "importante" ? "#FFC107" : "#2196F3"
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15
                
                Text {
                    text: icono
                    font.pixelSize: 24
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: texto
                        font.family: "Arial"
                        font.pixelSize: 14
                        color: "#424242"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        text: fecha
                        font.family: "Arial"
                        font.pixelSize: 12
                        color: "#757575"
                    }
                }
            }
        }
    }
    
    ListModel {
        id: tratamientosModel
        
        ListElement {
            fecha: "12/04/2025"
            parcela: "Parcela 5 - Naranjas"
            tipo: "Fertilización"
            producto: "NPK Premium"
            estado: "Programado"
        }
        ListElement {
            fecha: "15/04/2025"
            parcela: "Parcela 2 - Limones"
            tipo: "Fumigación"
            producto: "Protector Plus"
            estado: "Pendiente"
        }
        ListElement {
            fecha: "18/04/2025"
            parcela: "Parcela 8 - Mandarinas"
            tipo: "Poda"
            producto: "-"
            estado: "Programado"
        }
        ListElement {
            fecha: "20/04/2025"
            parcela: "Parcela 1 - Naranjas"
            tipo: "Riego"
            producto: "-"
            estado: "Pendiente"
        }
    }
    
    Component {
        id: tratamientosDelegate
        
        Rectangle {
            width: ListView.view.width
            height: 40
            color: index % 2 == 0 ? "#FAFAFA" : "#FFFFFF"
            
            Row {
                anchors.fill: parent
                
                Rectangle {
                    width: parent.width * 0.15
                    height: parent.height
                    color: "transparent"
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: fecha
                        font.family: "Arial"
                        font.pixelSize: 13
                        color: "#424242"
                    }
                }
                
                Rectangle {
                    width: parent.width * 0.25
                    height: parent.height
                    color: "transparent"
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: parcela
                        font.family: "Arial"
                        font.pixelSize: 13
                        color: "#424242"
                    }
                }
                
                Rectangle {
                    width: parent.width * 0.25
                    height: parent.height
                    color: "transparent"
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: tipo
                        font.family: "Arial"
                        font.pixelSize: 13
                        color: "#424242"
                    }
                }
                
                Rectangle {
                    width: parent.width * 0.20
                    height: parent.height
                    color: "transparent"
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: producto
                        font.family: "Arial"
                        font.pixelSize: 13
                        color: "#424242"
                    }
                }
                
                Rectangle {
                    width: parent.width * 0.15
                    height: parent.height
                    color: "transparent"
                    
                    Rectangle {
                        width: 80
                        height: 24
                        radius: 12
                        color: estado === "Programado" ? "#E8F5E9" : "#FFF8E1"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            anchors.centerIn: parent
                            text: estado
                            font.family: "Arial"
                            font.pixelSize: 12
                            color: estado === "Programado" ? "#2E7D32" : "#FF8F00"
                        }
                    }
                }
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        Flickable {
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: dashboardContainer.height + 40

            // Contenedor del Dashboard
            Item {
                id: dashboardContainer
                width: parent.width
                height: childrenRect.height

                // Título del Dashboard
                Text {
                    id: dashboardTitle
                    text: "ESTADISTICA GENERAL"
                    font.family: "Arial"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#2E7D32"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 30
                    anchors.topMargin: 30
                }

                // Fecha actual
                Text {
                    text: "Última actualización: " + new Date().toLocaleDateString()
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: "#757575"
                    anchors.left: dashboardTitle.left
                    anchors.top: dashboardTitle.bottom
                    anchors.topMargin: 5
                }

                // Grid de tarjetas de resumen
                GridLayout {
                    id: summaryGrid
                    anchors.top: dashboardTitle.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 40
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    columns: 3
                    columnSpacing: 20
                    rowSpacing: 20

                    // Tarjeta 1: Ciclos Activos
                    SummaryCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        title: "Ciclos de Producción Activos"
                        value: "18"
                        icon: "🌱"
                        iconColor: "#2E7D32"
                        trend: "+2 este mes"
                        trendPositive: true
                    }

                    // Tarjeta 2: Parcelas Cultivadas
                    SummaryCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        title: "Parcelas Cultivadas"
                        value: "45"
                        valueUnit: "hectáreas"
                        icon: "🌳"
                        iconColor: "#FF9800"
                        trend: "85% del total"
                        trendPositive: true
                    }

                    // Tarjeta 3: Próximas Cosechas
                    SummaryCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        title: "Próximas Cosechas"
                        value: "5"
                        valueUnit: "en 30 días"
                        icon: "🍊"
                        iconColor: "#FFEB3B"
                        trend: "3.2 tons estimadas"
                        trendPositive: true
                    }

                    // Gráfica: Producción por variedad (versión simplificada)
                    Rectangle {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Layout.preferredHeight: 300
                        color: "#FFFFFF"
                        radius: 10

                        // Sombra alternativa
                        Rectangle {
                            z: -1
                            anchors.fill: parent
                            anchors.margins: -3
                            radius: 13
                            color: "#20000000"
                            opacity: 0.5
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            // Título
                            Text {
                                text: "Producción por Variedad de Cítrico"
                                font.family: "Arial"
                                font.pixelSize: 16
                                color: "#424242"
                            }

                            // Separador
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#EEEEEE"
                            }

                            // Representación simplificada de gráfico de barras
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                // Barras de ejemplo
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 30

                                    // Limón
                                    Column {
                                        spacing: 5

                                        Rectangle {
                                            width: 40
                                            height: 90
                                            color: "#2E7D32"

                                            Rectangle {
                                                width: parent.width
                                                height: 70
                                                color: "#FF9800"
                                                anchors.bottom: parent.bottom
                                            }
                                        }

                                        Text {
                                            text: "Limón"
                                            font.family: "Arial"
                                            font.pixelSize: 12
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }

                                    // Naranja
                                    Column {
                                        spacing: 5

                                        Rectangle {
                                            width: 40
                                            height: 150
                                            color: "#2E7D32"

                                            Rectangle {
                                                width: parent.width
                                                height: 120
                                                color: "#FF9800"
                                                anchors.bottom: parent.bottom
                                            }
                                        }

                                        Text {
                                            text: "Naranja"
                                            font.family: "Arial"
                                            font.pixelSize: 12
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }

                                    // Mandarina
                                    Column {
                                        spacing: 5

                                        Rectangle {
                                            width: 40
                                            height: 120
                                            color: "#2E7D32"

                                            Rectangle {
                                                width: parent.width
                                                height: 95
                                                color: "#FF9800"
                                                anchors.bottom: parent.bottom
                                            }
                                        }

                                        Text {
                                            text: "Mandarina"
                                            font.family: "Arial"
                                            font.pixelSize: 12
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }

                                    // Toronja
                                    Column {
                                        spacing: 5

                                        Rectangle {
                                            width: 40
                                            height: 60
                                            color: "#2E7D32"

                                            Rectangle {
                                                width: parent.width
                                                height: 40
                                                color: "#FF9800"
                                                anchors.bottom: parent.bottom
                                            }
                                        }

                                        Text {
                                            text: "Toronja"
                                            font.family: "Arial"
                                            font.pixelSize: 12
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }

                                    // Lima
                                    Column {
                                        spacing: 5

                                        Rectangle {
                                            width: 40
                                            height: 40
                                            color: "#2E7D32"

                                            Rectangle {
                                                width: parent.width
                                                height: 25
                                                color: "#FF9800"
                                                anchors.bottom: parent.bottom
                                            }
                                        }

                                        Text {
                                            text: "Lima"
                                            font.family: "Arial"
                                            font.pixelSize: 12
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }

                                // Leyenda
                                Row {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    Row {
                                        spacing: 5

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            color: "#2E7D32"
                                        }

                                        Text {
                                            text: "Último Año"
                                            font.family: "Arial"
                                            font.pixelSize: 12
                                            color: "#757575"
                                        }
                                    }

                                    Row {
                                        spacing: 5

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            color: "#FF9800"
                                        }

                                        Text {
                                            text: "Año Actual"
                                            font.family: "Arial"
                                            font.pixelSize: 12
                                            color: "#757575"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Lista: Alertas y notificaciones
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 300
                        radius: 10
                        color: "#FFFFFF"

                        // Sombra alternativa
                        Rectangle {
                            z: -1
                            anchors.fill: parent
                            anchors.margins: -3
                            radius: 13
                            color: "#20000000"
                            opacity: 0.5
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            // Título
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Alertas y Notificaciones"
                                    font.family: "Arial"
                                    font.pixelSize: 16
                                    color: "#424242"
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: "Ver todas"
                                    font.family: "Arial"
                                    font.pixelSize: 12
                                    color: "#2196F3"

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            // Lógica para ver todas las alertas
                                        }
                                    }
                                }
                            }

                            // Separador
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#EEEEEE"
                            }

                            // Lista de alertas
                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: alertasModel
                                delegate: alertasDelegate
                                spacing: 8
                            }
                        }
                    }

                    // Próximos tratamientos
                    Rectangle {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Layout.preferredHeight: 250
                        radius: 10
                        color: "#FFFFFF"

                        // Sombra alternativa
                        Rectangle {
                            z: -1
                            anchors.fill: parent
                            anchors.margins: -3
                            radius: 13
                            color: "#20000000"
                            opacity: 0.5
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            // Título
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Próximos Tratamientos"
                                    font.family: "Arial"
                                    font.pixelSize: 16
                                    color: "#424242"
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: "Ver calendario completo"
                                    font.family: "Arial"
                                    font.pixelSize: 12
                                    color: "#2196F3"

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            // Lógica para ver calendario
                                        }
                                    }
                                }
                            }

                            // Separador
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#EEEEEE"
                            }

                            // Tabla de tratamientos
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"

                                // Encabezados
                                Row {
                                    id: tableHeader
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 30

                                    TableHeaderCell { width: parent.width * 0.15; text: "Fecha" }
                                    TableHeaderCell { width: parent.width * 0.25; text: "Parcela" }
                                    TableHeaderCell { width: parent.width * 0.25; text: "Tipo" }
                                    TableHeaderCell { width: parent.width * 0.20; text: "Producto" }
                                    TableHeaderCell { width: parent.width * 0.15; text: "Estado" }
                                }

                                // Contenido de la tabla
                                ListView {
                                    anchors.top: tableHeader.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    clip: true
                                    model: tratamientosModel
                                    delegate: tratamientosDelegate
                                }
                            }
                        }
                    }

                    // Ventas recientes (con gráfico circular simplificado)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 250
                        radius: 10
                        color: "#FFFFFF"

                        // Sombra alternativa
                        Rectangle {
                            z: -1
                            anchors.fill: parent
                            anchors.margins: -3
                            radius: 13
                            color: "#20000000"
                            opacity: 0.5
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            // Título
                            Text {
                                text: "Ventas Recientes"
                                font.family: "Arial"
                                font.pixelSize: 16
                                color: "#424242"
                            }

                            // Separador
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#EEEEEE"
                            }

                            // Gráfico circular simplificado
                            PieChart {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                value: 0.68
                                color: "#2E7D32"
                                text: "1.800.600 Bs."
                                subtext: "68% del objetivo mensual"
                            }
                        }
                    }
                }
            }
        }
    }
}