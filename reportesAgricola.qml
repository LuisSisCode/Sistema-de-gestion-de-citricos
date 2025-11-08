import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Pdf 5.15
import Qt.labs.platform 1.1

Item {
    id: reportesRoot
    objectName: "reportesRoot"
    
    // Colores del tema agrícola
    readonly property color primaryColor: "#4CAF50"  // Verde principal
    readonly property color successColor: "#27ae60"
    readonly property color dangerColor: "#E74C3C"
    readonly property color warningColor: "#f39c12"
    readonly property color lightGrayColor: "#ECF0F1"
    readonly property color textColor: "#2c3e50"
    readonly property color whiteColor: "#FFFFFF"
    readonly property color darkGrayColor: "#7f8c8d"
    readonly property color infoColor: "#17a2b8"
    readonly property color violetColor: "#9b59b6"
    
    // Estados del módulo
    property int vistaActual: 0  // 0: Configuración, 1: Resultados
    property int tipoReporteSeleccionado: 0
    property string fechaDesde: ""
    property string fechaHasta: ""
    property bool reporteGenerado: false
    property bool mostrandoVistaPrevia: false
    property var datosReporte: []
    property var resumenReporte: ({})
    
    // Tipos de reportes disponibles para sistema agrícola
    property var tiposReportes: [
        {
            id: 0,
            nombre: "Seleccionar tipo de reporte...",
            modulo: "",
            icono: "📊",
            descripcion: "Seleccione el tipo de reporte que desea generar",
            color: lightGrayColor
        },
        {
            id: 1,
            nombre: "Producción por Cultivos",
            modulo: "cultivos",
            icono: "🌾",
            descripcion: "Reporte detallado de producción por tipo de cultivo y variedad",
            color: successColor
        },
        {
            id: 2,
            nombre: "Inventario de Agroquímicos",
            modulo: "agroquimicos",
            icono: "🧪",
            descripcion: "Estado actual del inventario de productos fitosanitarios",
            color: infoColor
        },
        {
            id: 3,
            nombre: "Ventas y Clientes",
            modulo: "ventas",
            icono: "💰",
            descripcion: "Historial de ventas realizadas a clientes",
            color: "#e67e22"
        },
        {
            id: 4,
            nombre: "Gestión de Parcelas",
            modulo: "parcelas",
            icono: "🏡",
            descripcion: "Información de parcelas y productores registrados",
            color: primaryColor
        },
        {
            id: 5,
            nombre: "Maquinaria y Equipos",
            modulo: "maquinaria",
            icono: "🚜",
            descripcion: "Estado y gestión de equipos agrícolas",
            color: "#e91e63"
        },
        {
            id: 6,
            nombre: "Consumo de Combustible",
            modulo: "combustible",
            icono: "⛽",
            descripcion: "Análisis del consumo de combustible por equipo",
            color: dangerColor
        },
        {
            id: 7,
            nombre: "Mantenimiento de Equipos",
            modulo: "mantenimiento",
            icono: "🔧",
            descripcion: "Historial de mantenimientos preventivos y correctivos",
            color: violetColor
        },
        {
            id: 8,
            nombre: "Tratamientos Fitosanitarios",
            modulo: "tratamientos",
            icono: "💉",
            descripcion: "Registro de aplicaciones de productos fitosanitarios",
            color: "#34495e"
        },
        {
            id: 9,
            nombre: "Reporte Financiero Consolidado",
            modulo: "consolidado",
            icono: "📈",
            descripcion: "Resumen financiero de todas las operaciones agrícolas",
            color: "#2c3e50"
        }
    ]
    
    StackLayout {
        anchors.fill: parent
        currentIndex: vistaActual
        
        // VISTA 0: CONFIGURACIÓN INICIAL
        Item {
            id: vistaConfiguracion
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 32
                
                // Header del módulo
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: whiteColor
                    radius: 20
                    border.color: "#e0e0e0"
                    border.width: 1
                    
                    // Sombra sutil
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 3
                        anchors.leftMargin: 3
                        color: "#10000000"
                        radius: parent.radius
                        z: -1
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 30
                        spacing: 24
                        
                        Rectangle {
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 70
                            color: primaryColor
                            radius: 12
                            
                            Label {
                                anchors.centerIn: parent
                                text: "📊"
                                color: whiteColor
                                font.pixelSize: 28
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Label {
                                text: "Centro de Reportes Agrícolas"
                                font.pixelSize: 26
                                font.bold: true
                                color: textColor
                            }
                            
                            Label {
                                text: "Generación de reportes y análisis estadísticos del sistema AGROICHILO"
                                font.pixelSize: 14
                                color: darkGrayColor
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Rectangle {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 60
                            color: "#f8f9fa"
                            radius: 12
                            border.color: "#dee2e6"
                            border.width: 1
                            
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                Label {
                                    text: "Estado del Sistema"
                                    font.pixelSize: 11
                                    color: darkGrayColor
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                
                                Label {
                                    text: "🟢 Todos los módulos operativos"
                                    font.pixelSize: 12
                                    color: successColor
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
                
                // Sección de configuración del reporte
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    color: whiteColor
                    radius: 16
                    border.color: "#e0e0e0"
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 20
                        
                        // Título de sección
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Rectangle {
                                width: 4
                                height: 24
                                color: primaryColor
                                radius: 2
                            }
                            
                            Label {
                                text: "Configuración del Reporte"
                                font.pixelSize: 18
                                font.bold: true
                                color: textColor
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                text: "🧹 Limpiar"
                                Layout.preferredHeight: 32
                                visible: tipoReporteSeleccionado > 0
                                
                                background: Rectangle {
                                    color: parent.pressed ? Qt.darker(lightGrayColor, 1.2) : lightGrayColor
                                    radius: 6
                                    border.color: darkGrayColor
                                    border.width: 1
                                }
                                
                                contentItem: Label {
                                    text: parent.text
                                    color: textColor
                                    font.bold: true
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: limpiarFormulario()
                            }
                        }
                        
                        // Formulario de configuración
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: 20
                            rowSpacing: 16
                            
                            // Tipo de Reporte
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                Label {
                                    text: "Tipo de Reporte:"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: textColor
                                }
                                
                                ComboBox {
                                    id: tipoReporteCombo
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45
                                    
                                    model: ListModel {
                                        id: tiposReportesModel
                                        Component.onCompleted: {
                                            for (var i = 0; i < tiposReportes.length; i++) {
                                                append(tiposReportes[i])
                                            }
                                        }
                                    }
                                    
                                    textRole: "nombre"
                                    
                                    background: Rectangle {
                                        color: whiteColor
                                        border.color: parent.activeFocus ? primaryColor : "#dee2e6"
                                        border.width: parent.activeFocus ? 2 : 1
                                        radius: 8
                                    }
                                    
                                    contentItem: RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 8
                                        
                                        Label {
                                            text: tipoReporteCombo.currentIndex >= 0 ? 
                                                  tiposReportesModel.get(tipoReporteCombo.currentIndex).icono : "📊"
                                            font.pixelSize: 16
                                        }
                                        
                                        Label {
                                            Layout.fillWidth: true
                                            text: tipoReporteCombo.displayText
                                            font.pixelSize: 13
                                            color: textColor
                                            elide: Text.ElideRight
                                        }
                                    }
                                    
                                    onCurrentIndexChanged: {
                                        if (currentIndex >= 0) {
                                            tipoReporteSeleccionado = currentIndex
                                        }
                                    }
                                }
                            }
                            
                            // Fecha Desde
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                Label {
                                    text: "Fecha Desde:"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: textColor
                                }
                                
                                TextField {
                                    id: fechaDesdeField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45
                                    placeholderText: "DD/MM/YYYY"
                                    font.pixelSize: 13
                                    
                                    background: Rectangle {
                                        color: whiteColor
                                        border.color: parent.activeFocus ? primaryColor : "#dee2e6"
                                        border.width: parent.activeFocus ? 2 : 1
                                        radius: 8
                                    }
                                    
                                    onTextChanged: {
                                        fechaDesde = text
                                    }
                                }
                            }
                            
                            // Fecha Hasta
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                Label {
                                    text: "Fecha Hasta:"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: textColor
                                }
                                
                                TextField {
                                    id: fechaHastaField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45
                                    placeholderText: "DD/MM/YYYY"
                                    font.pixelSize: 13
                                    
                                    background: Rectangle {
                                        color: whiteColor
                                        border.color: parent.activeFocus ? primaryColor : "#dee2e6"
                                        border.width: parent.activeFocus ? 2 : 1
                                        radius: 8
                                    }
                                    
                                    onTextChanged: {
                                        fechaHasta = text
                                    }
                                }
                            }
                        }
                        
                        // Descripción del reporte seleccionado
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            color: tipoReporteSeleccionado > 0 ? "#f8f9fa" : "#fafafa"
                            radius: 8
                            border.color: "#e9ecef"
                            border.width: 1
                            visible: tipoReporteSeleccionado > 0
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12
                                
                                Rectangle {
                                    width: 28
                                    height: 28
                                    color: tipoReporteSeleccionado > 0 ? 
                                           tiposReportes[tipoReporteSeleccionado].color : lightGrayColor
                                    radius: 6
                                    
                                    Label {
                                        anchors.centerIn: parent
                                        text: tipoReporteSeleccionado > 0 ? 
                                              tiposReportes[tipoReporteSeleccionado].icono : "📊"
                                        font.pixelSize: 14
                                        color: whiteColor
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    
                                    Label {
                                        text: tipoReporteSeleccionado > 0 ? 
                                              tiposReportes[tipoReporteSeleccionado].nombre : "Sin selección"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: textColor
                                    }
                                    
                                    Label {
                                        text: tipoReporteSeleccionado > 0 ? 
                                              tiposReportes[tipoReporteSeleccionado].descripcion : ""
                                        font.pixelSize: 12
                                        color: darkGrayColor
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                        
                        // Botón de acción principal
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                id: generarReporteBtn
                                text: "📊 Generar Reporte"
                                Layout.preferredHeight: 45
                                Layout.preferredWidth: 180
                                enabled: tipoReporteSeleccionado > 0 && fechaDesde && fechaHasta
                                
                                background: Rectangle {
                                    color: parent.enabled ? 
                                           (parent.pressed ? Qt.darker(primaryColor, 1.2) : primaryColor) : 
                                           lightGrayColor
                                    radius: 8
                                    border.color: parent.enabled ? primaryColor : darkGrayColor
                                    border.width: 1
                                }
                                
                                contentItem: Label {
                                    text: parent.text
                                    color: parent.enabled ? whiteColor : darkGrayColor
                                    font.bold: true
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: generarReporte()
                            }
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
        }
        
        // VISTA 1: RESULTADOS DEL REPORTE
        Item {
            id: vistaResultados
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Header de navegación mejorado
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: primaryColor
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        
                        Button {
                            text: "← Volver"
                            Layout.preferredHeight: 35
                            Layout.preferredWidth: 90
                            
                            background: Rectangle {
                                color: parent.pressed ? "#40FFFFFF" : "transparent"
                                radius: 6
                                border.color: whiteColor
                                border.width: 1
                            }
                            
                            contentItem: Label {
                                text: parent.text
                                color: whiteColor
                                font.bold: true
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                vistaActual = 0
                                mostrandoVistaPrevia = false
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Label {
                                text: "Reporte: " + obtenerTituloReporte().replace("REPORTE DE ", "").replace("REPORTE ", "")
                                color: whiteColor
                                font.bold: true
                                font.pixelSize: 16
                            }
                            
                            Label {
                                text: "Período: " + fechaDesde + " al " + fechaHasta + " • " + datosReporte.length + " registros"
                                color: "#E8F4FD"
                                font.pixelSize: 11
                            }
                        }
                        
                        RowLayout {
                            spacing: 8
                            
                            Button {
                                text: mostrandoVistaPrevia ? "📊 Ver Datos" : "👁️ Vista Previa"
                                Layout.preferredHeight: 35
                                Layout.preferredWidth: 110
                                
                                background: Rectangle {
                                    color: parent.pressed ? Qt.darker(infoColor, 1.2) : infoColor
                                    radius: 6
                                }
                                
                                contentItem: Label {
                                    text: parent.text
                                    color: whiteColor
                                    font.bold: true
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    mostrandoVistaPrevia = !mostrandoVistaPrevia
                                }
                            }
                            
                            Button {
                                text: "📄 Descargar PDF"
                                Layout.preferredHeight: 35
                                Layout.preferredWidth: 120
                                
                                background: Rectangle {
                                    color: parent.pressed ? Qt.darker(successColor, 1.2) : successColor
                                    radius: 6
                                }
                                
                                contentItem: Label {
                                    text: parent.text
                                    color: whiteColor
                                    font.bold: true
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: descargarPDF()
                            }
                        }
                        
                        Button {
                            text: "×"
                            Layout.preferredHeight: 35
                            Layout.preferredWidth: 35
                            
                            background: Rectangle {
                                color: parent.pressed ? "#40FFFFFF" : "transparent"
                                radius: 17
                            }
                            
                            contentItem: Label {
                                text: parent.text
                                color: whiteColor
                                font.bold: true
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                vistaActual = 0
                                mostrandoVistaPrevia = false
                                reporteGenerado = false
                            }
                        }
                    }
                }

                // Contenido principal (tabla o vista previa)
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: mostrandoVistaPrevia ? 1 : 0
                    
                    // Vista de tabla de datos
                    Rectangle {
                        color: whiteColor
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15
                            
                            // Información del período
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "transparent"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 10
                                    
                                    Label {
                                        text: "PERÍODO: " + fechaDesde + " al " + fechaHasta
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: textColor
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                    
                                    Label {
                                        text: "Fecha: " + Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                                        font.pixelSize: 12
                                        color: textColor
                                    }
                                }
                                
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 1
                                    color: textColor
                                }
                            }
                            
                            // Tabla de datos con scroll
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: whiteColor
                                border.color: "#e0e0e0"
                                border.width: 1
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    
                                    // Encabezados de la tabla
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#f0f0f0"
                                        border.color: textColor
                                        border.width: 1
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 5
                                            
                                            Repeater {
                                                model: obtenerColumnasReporte()
                                                
                                                Label {
                                                    Layout.preferredWidth: modelData.width
                                                    text: modelData.titulo
                                                    font.bold: true
                                                    font.pixelSize: 11
                                                    color: textColor
                                                    horizontalAlignment: modelData.align || Text.AlignLeft
                                                    verticalAlignment: Text.AlignVCenter
                                                    
                                                    Rectangle {
                                                        anchors.right: parent.right
                                                        width: 1
                                                        height: parent.height
                                                        color: "#ccc"
                                                        visible: index < obtenerColumnasReporte().length - 1
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Área de datos con scroll
                                    ScrollView {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        
                                        ColumnLayout {
                                            width: parent.width
                                            spacing: 0
                                            
                                            // Filas de datos
                                            Repeater {
                                                model: datosReporte.length
                                                
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 35
                                                    color: index % 2 === 0 ? whiteColor : "#f8f8f8"
                                                    border.color: "#e0e0e0"
                                                    border.width: 0.5
                                                    
                                                    property int rowIndex: index
                                                    
                                                    RowLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 8
                                                        spacing: 5
                                                        
                                                        Repeater {
                                                            model: obtenerColumnasReporte()
                                                            
                                                            Label {
                                                                Layout.preferredWidth: modelData.width
                                                                text: obtenerValorColumna(parent.parent.rowIndex, modelData.campo)
                                                                font.pixelSize: 10
                                                                color: textColor
                                                                horizontalAlignment: modelData.align || Text.AlignLeft
                                                                verticalAlignment: Text.AlignVCenter
                                                                elide: Text.ElideRight
                                                                font.bold: modelData.campo === "valor" || modelData.campo === "total"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Fila de total
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#f0f0f0"
                                        border.color: textColor
                                        border.width: 1
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 5
                                            
                                            Item {
                                                Layout.fillWidth: true
                                                
                                                Label {
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: "TOTAL GENERAL:"
                                                    font.bold: true
                                                    font.pixelSize: 12
                                                    color: textColor
                                                }
                                            }
                                            
                                            Label {
                                                Layout.preferredWidth: 120
                                                text: "Bs " + (resumenReporte.totalValor || 0).toFixed(2)
                                                font.bold: true
                                                font.pixelSize: 12
                                                color: resumenReporte.totalValor >= 0 ? successColor : dangerColor
                                                horizontalAlignment: Text.AlignRight
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Resumen inferior
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "transparent"
                                
                                Rectangle {
                                    anchors.top: parent.top
                                    width: parent.width
                                    height: 1
                                    color: textColor
                                }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: 10
                                    spacing: 40
                                    
                                    ColumnLayout {
                                        spacing: 4
                                        
                                        Label {
                                            text: "Total de Registros: " + datosReporte.length
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: textColor
                                        }
                                        
                                        Label {
                                            text: "Valor Total: Bs " + (resumenReporte.totalValor || 0).toFixed(2)
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: resumenReporte.totalValor >= 0 ? successColor : dangerColor
                                        }
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                    
                                    Label {
                                        text: "Sistema de Gestión Agrícola - AGROICHILO"
                                        font.pixelSize: 10
                                        color: darkGrayColor
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                    
                    // Vista previa del PDF
                    Rectangle {
                        color: "#f5f6fa"
                        
                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            
                            Rectangle {
                                width: Math.max(850, parent.width)
                                height: Math.max(600, contentColumn.implicitHeight + 60)
                                color: whiteColor
                                border.color: "#cccccc"
                                border.width: 1
                                
                                ColumnLayout {
                                    id: contentColumn
                                    anchors.fill: parent
                                    anchors.margins: 30
                                    spacing: 20
                                    
                                    // Encabezado simple y directo
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 10
                                        
                                        // Título principal
                                        Label {
                                            text: obtenerTituloReporte()
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: textColor
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        // Línea separadora
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 2
                                            color: textColor
                                        }
                                        
                                        // Información del período
                                        RowLayout {
                                            Layout.fillWidth: true
                                            
                                            Label {
                                                text: "PERÍODO: " + fechaDesde + " al " + fechaHasta
                                                font.pixelSize: 11
                                                color: textColor
                                                font.bold: true
                                            }
                                            
                                            Item { Layout.fillWidth: true }
                                            
                                            Label {
                                                text: "Fecha: " + Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                                                font.pixelSize: 11
                                                color: textColor
                                            }
                                        }
                                        
                                        // Línea separadora
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 2
                                            color: textColor
                                        }
                                    }
                                    
                                    // Tabla principal de datos (igual que la vista anterior)
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        
                                        // Encabezados de tabla
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 35
                                            color: "#f0f0f0"
                                            border.color: textColor
                                            border.width: 1
                                            
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 6
                                                spacing: 2
                                                
                                                Repeater {
                                                    model: obtenerColumnasReporte()
                                                    
                                                    Rectangle {
                                                        Layout.preferredWidth: modelData.width
                                                        Layout.fillHeight: true
                                                        color: "transparent"
                                                        border.color: "#ccc"
                                                        border.width: index > 0 ? 1 : 0
                                                        
                                                        Label {
                                                            anchors.centerIn: parent
                                                            anchors.margins: 4
                                                            text: modelData.titulo
                                                            font.bold: true
                                                            font.pixelSize: 10
                                                            color: textColor
                                                            horizontalAlignment: modelData.align || Text.AlignLeft
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Filas de datos
                                        Repeater {
                                            model: datosReporte.length
                                            
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 28
                                                color: index % 2 === 0 ? whiteColor : "#f8f8f8"
                                                border.color: "#e0e0e0"
                                                border.width: 0.5
                                                
                                                property int rowIndex: index
                                                
                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 6
                                                    spacing: 2
                                                    
                                                    Repeater {
                                                        model: obtenerColumnasReporte()
                                                        
                                                        Rectangle {
                                                            Layout.preferredWidth: modelData.width
                                                            Layout.fillHeight: true
                                                            color: "transparent"
                                                            border.color: "#e0e0e0"
                                                            border.width: index > 0 ? 1 : 0
                                                            
                                                            Label {
                                                                anchors.centerIn: parent
                                                                anchors.margins: 3
                                                                text: obtenerValorColumna(parent.parent.parent.rowIndex, modelData.campo)
                                                                font.pixelSize: 9
                                                                color: textColor
                                                                horizontalAlignment: modelData.align || Text.AlignLeft
                                                                elide: Text.ElideRight
                                                                font.bold: modelData.campo === "valor" || modelData.campo === "total"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Fila de total
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 35
                                            color: "#f0f0f0"
                                            border.color: textColor
                                            border.width: 1
                                            
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 8
                                                spacing: 0
                                                
                                                Item {
                                                    Layout.fillWidth: true
                                                    
                                                    Label {
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: "TOTAL GENERAL:"
                                                        font.bold: true
                                                        font.pixelSize: 12
                                                        color: textColor
                                                    }
                                                }
                                                
                                                Label {
                                                    Layout.preferredWidth: 120
                                                    text: "Bs " + (resumenReporte.totalValor || 0).toFixed(2)
                                                    font.bold: true
                                                    font.pixelSize: 12
                                                    color: resumenReporte.totalValor >= 0 ? successColor : dangerColor
                                                    horizontalAlignment: Text.AlignRight
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Resumen final
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 8
                                        Layout.topMargin: 20
                                        
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 1
                                            color: textColor
                                        }
                                        
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 40
                                            
                                            Label {
                                                text: "Total de Registros: " + datosReporte.length
                                                font.pixelSize: 11
                                                color: textColor
                                                font.bold: true
                                            }
                                            
                                            Item { Layout.fillWidth: true }
                                            
                                            Label {
                                                text: "Valor Total: Bs " + (resumenReporte.totalValor || 0).toFixed(2)
                                                font.pixelSize: 11
                                                color: resumenReporte.totalValor >= 0 ? successColor : dangerColor
                                                font.bold: true
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }
                                        
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 1
                                            color: textColor
                                        }
                                        
                                        Label {
                                            text: "Sistema de Gestión Agrícola - AGROICHILO"
                                            font.pixelSize: 10
                                            color: darkGrayColor
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignHCenter
                                            Layout.topMargin: 10
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ===== FUNCIONES DE LÓGICA DE NEGOCIO =====
    
    function limpiarFormulario() {
        tipoReporteCombo.currentIndex = 0
        fechaDesdeField.text = ""
        fechaHastaField.text = ""
        tipoReporteSeleccionado = 0
        fechaDesde = ""
        fechaHasta = ""
        reporteGenerado = false
        mostrandoVistaPrevia = false
        datosReporte = []
        resumenReporte = {}
    }
    
    function generarReporte() {
        console.log("🌾 Generando reporte agrícola tipo:", tipoReporteSeleccionado)
        console.log("📅 Período:", fechaDesde, "al", fechaHasta)
        
        // Limpiar datos anteriores
        datosReporte = []
        
        // Generar datos según el tipo de reporte
        switch(tipoReporteSeleccionado) {
            case 1: generarReporteProduccion(); break
            case 2: generarReporteInventarioAgroquimicos(); break
            case 3: generarReporteVentas(); break
            case 4: generarReporteParcelas(); break
            case 5: generarReporteMaquinaria(); break
            case 6: generarReporteCombustible(); break
            case 7: generarReporteMantenimiento(); break
            case 8: generarReporteTratamientos(); break
            case 9: generarReporteConsolidado(); break
            default:
                console.log("❌ Tipo de reporte no reconocido")
                return
        }
        
        reporteGenerado = true
        vistaActual = 1 // Cambiar a vista de resultados
        
        console.log("✅ Reporte agrícola generado con", datosReporte.length, "registros")
    }
    
    // ===== FUNCIONES DE GENERACIÓN DE DATOS AGRÍCOLAS =====
    
    function generarReporteProduccion() {
        var produccionEjemplo = [
            {fecha: "15/06/2025", tipo: "Arroz", variedad: "INIA Tacuarí", hectareas: 25.5, produccion: 153.0, rendimiento: 6.0, valor: 1989.00},
            {fecha: "16/06/2025", tipo: "Soya", variedad: "Don Mario", hectareas: 40.0, produccion: 120.0, rendimiento: 3.0, valor: 1560.00},
            {fecha: "17/06/2025", tipo: "Maíz", variedad: "Pioneer", hectareas: 30.0, produccion: 135.0, rendimiento: 4.5, valor: 1755.00},
            {fecha: "18/06/2025", tipo: "Frijol", variedad: "Negro Santa Cruz", hectareas: 15.0, produccion: 30.0, rendimiento: 2.0, valor: 750.00},
            {fecha: "19/06/2025", tipo: "Quinua", variedad: "Real", hectareas: 8.0, produccion: 14.4, rendimiento: 1.8, valor: 720.00},
            {fecha: "20/06/2025", tipo: "Cítricos", variedad: "Naranja Valencia", hectareas: 12.0, produccion: 180.0, rendimiento: 15.0, valor: 2340.00}
        ]
        
        datosReporte = produccionEjemplo
        
        var totalValor = 0
        var totalHectareas = 0
        var totalProduccion = 0
        
        for (var i = 0; i < datosReporte.length; i++) {
            totalValor += datosReporte[i].valor
            totalHectareas += datosReporte[i].hectareas
            totalProduccion += datosReporte[i].produccion
        }
        
        resumenReporte = {
            totalValor: totalValor,
            totalRegistros: datosReporte.length,
            totalHectareas: totalHectareas,
            totalProduccion: totalProduccion
        }
    }
    
    function generarReporteInventarioAgroquimicos() {
        var inventarioEjemplo = [
            {fecha: "09/07/2025", producto: "Cipertrina 25EC", categoria: "Insecticida", stock: 30, unidad: "L", precioUnitario: 85.00, valor: 2550.00},
            {fecha: "09/07/2025", producto: "Cobrestar WP", categoria: "Fungicida", stock: 45, unidad: "Kg", precioUnitario: 70.00, valor: 3150.00},
            {fecha: "09/07/2025", producto: "Glifosato 48SL", categoria: "Herbicida", stock: 47, unidad: "L", precioUnitario: 110.00, valor: 5170.00},
            {fecha: "09/07/2025", producto: "CitroMag", categoria: "Fertilizante", stock: 400, unidad: "Kg", precioUnitario: 90.00, valor: 36000.00},
            {fecha: "09/07/2025", producto: "Bioestimulante Foliar", categoria: "Bioestimulante", stock: 25, unidad: "L", precioUnitario: 120.00, valor: 3000.00}
        ]
        
        datosReporte = inventarioEjemplo
        
        var totalValor = 0
        for (var i = 0; i < datosReporte.length; i++) {
            totalValor += datosReporte[i].valor
        }
        
        resumenReporte = {
            totalValor: totalValor,
            totalRegistros: datosReporte.length
        }
    }
    
    function generarReporteVentas() {
        var ventasEjemplo = [
            {fecha: "05/07/2025", codigo: "V-0001", cliente: "Distribuidora Frutal S.A.", producto: "Cítricos del Valle", cantidad: 5000, precioUnitario: 15.00, total: 75000.00},
            {fecha: "06/07/2025", codigo: "V-0002", cliente: "Mercado Central Yapacaní", producto: "Arroz Blanco", cantidad: 4000, precioUnitario: 12.50, total: 50000.00},
            {fecha: "07/07/2025", codigo: "V-0003", cliente: "Exportadora Boliviana", producto: "Quinua Real", cantidad: 1000, precioUnitario: 50.00, total: 50000.00},
            {fecha: "08/07/2025", codigo: "V-0004", cliente: "Industrias Alimentarias", producto: "Soya en Grano", cantidad: 10000, precioUnitario: 15.00, total: 150000.00}
        ]
        
        datosReporte = ventasEjemplo
        
        var totalValor = 0
        for (var i = 0; i < datosReporte.length; i++) {
            totalValor += datosReporte[i].total
        }
        
        resumenReporte = {
            totalValor: totalValor,
            totalRegistros: datosReporte.length
        }
    }
    
    function generarReporteParcelas() {
        var parcelasEjemplo = [
            {fecha: "01/07/2025", parcela: "Finca Los Limones", agricultor: "Juan Carlos Mendoza", area: 10.5, cultivo: "Cítricos", estado: "En Producción", valor: 1575.00},
            {fecha: "01/07/2025", parcela: "Parcela El Edén", agricultor: "María Elena Torres", area: 15.0, cultivo: "Arroz", estado: "Cosechado", valor: 2250.00},
            {fecha: "01/07/2025", parcela: "Lote El Progreso", agricultor: "Pedro Antonio Silva", area: 30.0, cultivo: "Soya", estado: "En Desarrollo", valor: 4500.00},
            {fecha: "01/07/2025", parcela: "Campo Dorado", agricultor: "Carmen Rosa López", area: 20.0, cultivo: "Maíz", estado: "Sembrado", valor: 3000.00}
        ]
        
        datosReporte = parcelasEjemplo
        
        var totalValor = 0
        var totalArea = 0
        for (var i = 0; i < datosReporte.length; i++) {
            totalValor += datosReporte[i].valor
            totalArea += datosReporte[i].area
        }
        
        resumenReporte = {
            totalValor: totalValor,
            totalRegistros: datosReporte.length,
            totalArea: totalArea
        }
    }
    
    function generarReporteMaquinaria() {
        var maquinariaEjemplo = [
            {fecha: "09/07/2025", equipo: "Tractor John Deere 6110M", tipo: "Tractor", marca: "John Deere", estado: "Operativo", horasUso: 1245, valor: 125000.00},
            {fecha: "09/07/2025", equipo: "Fumigadora de mochila motorizada", tipo: "Fumigadora", marca: "Stihl", estado: "Operativo", horasUso: 245, valor: 8500.00},
            {fecha: "09/07/2025", equipo: "Compresora 150 PSI", tipo: "Herramienta", marca: "DeWalt", estado: "Operativo", horasUso: 156, valor: 4200.00},
            {fecha: "09/07/2025", equipo: "Rosadora", tipo: "Otro", marca: "STIHL", estado: "Fuera de servicio", horasUso: 89, valor: 2800.00}
        ]
        
        datosReporte = maquinariaEjemplo
        
        var totalValor = 0
        for (var i = 0; i < datosReporte.length; i++) {
            totalValor += datosReporte[i].valor
        }
        
        resumenReporte = {
            totalValor: totalValor,
            totalRegistros: datosReporte.length
        }
    }
    
    function generarReporteCombustible() {
        var combustibleEjemplo = [
            {fecha: "13/07/2025", tipo: "Gasolina", cantidad: 50.00, precioUnitario: 5.00, total: 250.00, proveedor: "Surtidor Coca"},
            {fecha: "13/07/2025", tipo: "Diésel", cantidad: 800.00, precioUnitario: 3.00, total: 2400.00, proveedor: "Surtidor Coca"},
            {fecha: "13/07/2025", tipo: "Gasolina", cantidad: 1000.00, precioUnitario: 3.00, total: 3000.00, proveedor: "Surtidor San Salvador"},
            {fecha: "13/07/2025", tipo: "Gasolina", cantidad: 500.00, precioUnitario: 3.50, total: 1750.00, proveedor: "Surtidor San Carlos"}
        ]
        
        datosReporte = combustibleEjemplo
        
        var totalValor = 0
        for (var i = 0; i < datosReporte.length; i++) {
            totalValor += datosReporte[i].total
        }
        
        resumenReporte = {
            totalValor: totalValor,
            totalRegistros: datosReporte.length
        }
    }
    
    function generarReporteMantenimiento() {
        var mantenimientoEjemplo = [
            {fecha: "30/07/2025", equipo: "Fumigadora de mochila motorizada", tipo: "Preventivo", descripcion: "Revisión general", costo: 500.00, estado: "Completado"},
            {fecha: "28/07/2025", equipo: "Rosadora", tipo: "Preventivo", descripcion: "Revisión general", costo: 0.00, estado: "Programado"},
            {fecha: "13/07/2025", equipo: "Fumigadora de mochila motorizada", tipo: "Correctivo", descripcion: "Cambio de filtro", costo: 250.00, estado: "Completado"}
        ]
        
        datosReporte = mantenimientoEjemplo
        
        var totalValor = 0
        for (var i = 0; i < datosReporte.length; i++) {
            totalValor += datosReporte[i].costo
        }
        
        resumenReporte = {
            totalValor: totalValor,
            totalRegistros: datosReporte.length
        }
    }
    
    function generarReporteTratamientos() {
        var tratamientosEjemplo = [
            {fecha: "13/07/2025", ciclo: "Santa Cruz - Finca Los L...", tipoPlaga: "Piojillo volador", area: 50, mezcla: "Caldo para piojillo", costo: 2500.00}
        ]
        
        datosReporte = tratamientosEjemplo
        
        var totalValor = 0
        for (var i = 0; i < datosReporte.length; i++) {
            totalValor += datosReporte[i].costo
        }
        
        resumenReporte = {
            totalValor: totalValor,
            totalRegistros: datosReporte.length
        }
    }
    
    function generarReporteConsolidado() {
        var consolidadoEjemplo = [
            {fecha: "09/07/2025", modulo: "Ventas", descripcion: "Ingresos por ventas de productos", cantidad: 4, valor: 325000.00, tipo: "INGRESO"},
            {fecha: "09/07/2025", modulo: "Producción", descripcion: "Costos de producción agrícola", cantidad: 6, valor: 9114.00, tipo: "INGRESO"},
            {fecha: "09/07/2025", modulo: "Agroquímicos", descripcion: "Inventario valorizado", cantidad: 5, valor: 49870.00, tipo: "ACTIVO"},
            {fecha: "09/07/2025", modulo: "Combustible", descripcion: "Gastos en combustible", cantidad: 4, valor: -7400.00, tipo: "EGRESO"},
            {fecha: "09/07/2025", modulo: "Mantenimiento", descripcion: "Gastos en mantenimiento", cantidad: 3, valor: -750.00, tipo: "EGRESO"},
            {fecha: "09/07/2025", modulo: "Tratamientos", descripcion: "Gastos en tratamientos fitosanitarios", cantidad: 1, valor: -2500.00, tipo: "EGRESO"}
        ]
        
        datosReporte = consolidadoEjemplo
        
        var totalIngresos = 0
        var totalEgresos = 0
        
        for (var i = 0; i < datosReporte.length; i++) {
            if (datosReporte[i].valor > 0) {
                totalIngresos += datosReporte[i].valor
            } else {
                totalEgresos += Math.abs(datosReporte[i].valor)
            }
        }
        
        resumenReporte = {
            totalValor: totalIngresos - totalEgresos,
            totalIngresos: totalIngresos,
            totalEgresos: totalEgresos,
            totalRegistros: datosReporte.length
        }
    }
    
    // ===== FUNCIONES AUXILIARES PARA REPORTES =====
    
    function obtenerTituloReporte() {
        if (tipoReporteSeleccionado <= 0) return "REPORTE GENERAL AGRÍCOLA"
        
        switch(tipoReporteSeleccionado) {
            case 1: return "REPORTE DE PRODUCCIÓN POR CULTIVOS"
            case 2: return "REPORTE DE INVENTARIO DE AGROQUÍMICOS"
            case 3: return "REPORTE DE VENTAS Y CLIENTES"
            case 4: return "REPORTE DE GESTIÓN DE PARCELAS"
            case 5: return "REPORTE DE MAQUINARIA Y EQUIPOS"
            case 6: return "REPORTE DE CONSUMO DE COMBUSTIBLE"
            case 7: return "REPORTE DE MANTENIMIENTO DE EQUIPOS"
            case 8: return "REPORTE DE TRATAMIENTOS FITOSANITARIOS"
            case 9: return "REPORTE FINANCIERO CONSOLIDADO AGRÍCOLA"
            default: return "REPORTE GENERAL AGRÍCOLA"
        }
    }
    
    function obtenerColumnasReporte() {
        if (tipoReporteSeleccionado <= 0) {
            return [
                {titulo: "FECHA", campo: "fecha", width: 80},
                {titulo: "DESCRIPCIÓN", campo: "descripcion", width: 300},
                {titulo: "CANTIDAD", campo: "cantidad", width: 80, align: Text.AlignRight},
                {titulo: "VALOR (Bs)", campo: "valor", width: 120, align: Text.AlignRight}
            ]
        }
        
        switch(tipoReporteSeleccionado) {
            case 1: // Producción
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "TIPO", campo: "tipo", width: 100},
                    {titulo: "VARIEDAD", campo: "variedad", width: 140},
                    {titulo: "HECTÁREAS", campo: "hectareas", width: 80, align: Text.AlignRight},
                    {titulo: "PRODUCCIÓN (Tn)", campo: "produccion", width: 90, align: Text.AlignRight},
                    {titulo: "RENDIMIENTO", campo: "rendimiento", width: 80, align: Text.AlignRight},
                    {titulo: "VALOR (Bs)", campo: "valor", width: 120, align: Text.AlignRight}
                ]
                
            case 2: // Inventario Agroquímicos
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "PRODUCTO", campo: "producto", width: 180},
                    {titulo: "CATEGORÍA", campo: "categoria", width: 100},
                    {titulo: "STOCK", campo: "stock", width: 70, align: Text.AlignRight},
                    {titulo: "UNIDAD", campo: "unidad", width: 60},
                    {titulo: "P.U. (Bs)", campo: "precioUnitario", width: 80, align: Text.AlignRight},
                    {titulo: "VALOR (Bs)", campo: "valor", width: 120, align: Text.AlignRight}
                ]
                
            case 3: // Ventas
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "CÓDIGO", campo: "codigo", width: 80},
                    {titulo: "CLIENTE", campo: "cliente", width: 160},
                    {titulo: "PRODUCTO", campo: "producto", width: 140},
                    {titulo: "CANTIDAD", campo: "cantidad", width: 80, align: Text.AlignRight},
                    {titulo: "P.U. (Bs)", campo: "precioUnitario", width: 80, align: Text.AlignRight},
                    {titulo: "TOTAL (Bs)", campo: "total", width: 120, align: Text.AlignRight}
                ]
                
            case 4: // Parcelas
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "PARCELA", campo: "parcela", width: 150},
                    {titulo: "AGRICULTOR", campo: "agricultor", width: 150},
                    {titulo: "ÁREA (Ha)", campo: "area", width: 80, align: Text.AlignRight},
                    {titulo: "CULTIVO", campo: "cultivo", width: 100},
                    {titulo: "ESTADO", campo: "estado", width: 100},
                    {titulo: "VALOR (Bs)", campo: "valor", width: 120, align: Text.AlignRight}
                ]
                
            case 5: // Maquinaria
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "EQUIPO", campo: "equipo", width: 200},
                    {titulo: "TIPO", campo: "tipo", width: 100},
                    {titulo: "MARCA", campo: "marca", width: 100},
                    {titulo: "ESTADO", campo: "estado", width: 100},
                    {titulo: "HORAS USO", campo: "horasUso", width: 80, align: Text.AlignRight},
                    {titulo: "VALOR (Bs)", campo: "valor", width: 120, align: Text.AlignRight}
                ]
                
            case 6: // Combustible
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "TIPO", campo: "tipo", width: 100},
                    {titulo: "CANTIDAD (L)", campo: "cantidad", width: 90, align: Text.AlignRight},
                    {titulo: "P.U. (Bs)", campo: "precioUnitario", width: 80, align: Text.AlignRight},
                    {titulo: "TOTAL (Bs)", campo: "total", width: 100, align: Text.AlignRight},
                    {titulo: "PROVEEDOR", campo: "proveedor", width: 150}
                ]
                
            case 7: // Mantenimiento
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "EQUIPO", campo: "equipo", width: 200},
                    {titulo: "TIPO", campo: "tipo", width: 100},
                    {titulo: "DESCRIPCIÓN", campo: "descripcion", width: 160},
                    {titulo: "COSTO (Bs)", campo: "costo", width: 100, align: Text.AlignRight},
                    {titulo: "ESTADO", campo: "estado", width: 100}
                ]
                
            case 8: // Tratamientos
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "CICLO", campo: "ciclo", width: 160},
                    {titulo: "TIPO PLAGA", campo: "tipoPlaga", width: 120},
                    {titulo: "ÁREA (Ha)", campo: "area", width: 80, align: Text.AlignRight},
                    {titulo: "MEZCLA", campo: "mezcla", width: 140},
                    {titulo: "COSTO (Bs)", campo: "costo", width: 120, align: Text.AlignRight}
                ]
                
            case 9: // Consolidado
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "MÓDULO", campo: "modulo", width: 120},
                    {titulo: "DESCRIPCIÓN", campo: "descripcion", width: 220},
                    {titulo: "REGISTROS", campo: "cantidad", width: 80, align: Text.AlignRight},
                    {titulo: "TIPO", campo: "tipo", width: 80},
                    {titulo: "VALOR (Bs)", campo: "valor", width: 120, align: Text.AlignRight}
                ]
                
            default:
                return [
                    {titulo: "FECHA", campo: "fecha", width: 80},
                    {titulo: "DESCRIPCIÓN", campo: "descripcion", width: 300},
                    {titulo: "CANTIDAD", campo: "cantidad", width: 80, align: Text.AlignRight},
                    {titulo: "VALOR (Bs)", campo: "valor", width: 120, align: Text.AlignRight}
                ]
        }
    }
    
    function obtenerValorColumna(index, campo) {
        if (!datosReporte[index]) return "---"
        
        var registro = datosReporte[index]
        
        switch(campo) {
            case "fecha":
                return registro.fecha || "---"
            case "tipo":
                return registro.tipo || "---"
            case "variedad":
                return registro.variedad || "---"
            case "hectareas":
                return registro.hectareas ? registro.hectareas.toFixed(1) : "0.0"
            case "area":
                return registro.area ? registro.area.toFixed(1) : "0.0"
            case "produccion":
                return registro.produccion ? registro.produccion.toFixed(1) : "0.0"
            case "rendimiento":
                return registro.rendimiento ? registro.rendimiento.toFixed(1) : "0.0"
            case "producto":
                return registro.producto || "---"
            case "categoria":
                return registro.categoria || "---"
            case "stock":
                return (registro.stock || 0).toString()
            case "unidad":
                return registro.unidad || "---"
            case "precioUnitario":
                return registro.precioUnitario ? registro.precioUnitario.toFixed(2) : "0.00"
            case "valor":
                return registro.valor ? registro.valor.toFixed(2) : "0.00"
            case "codigo":
                return registro.codigo || "---"
            case "cliente":
                return registro.cliente || "---"
            case "cantidad":
                return registro.cantidad ? registro.cantidad.toFixed(2) : "0.00"
            case "total":
                return registro.total ? registro.total.toFixed(2) : "0.00"
            case "parcela":
                return registro.parcela || "---"
            case "agricultor":
                return registro.agricultor || "---"
            case "cultivo":
                return registro.cultivo || "---"
            case "estado":
                return registro.estado || "---"
            case "equipo":
                return registro.equipo || "---"
            case "marca":
                return registro.marca || "---"
            case "horasUso":
                return (registro.horasUso || 0).toString()
            case "descripcion":
                return registro.descripcion || "---"
            case "costo":
                return registro.costo ? registro.costo.toFixed(2) : "0.00"
            case "proveedor":
                return registro.proveedor || "---"
            case "ciclo":
                return registro.ciclo || "---"
            case "tipoPlaga":
                return registro.tipoPlaga || "---"
            case "mezcla":
                return registro.mezcla || "---"
            case "modulo":
                return registro.modulo || "---"
            default:
                return registro[campo] || "---"
        }
    }
    
    // FUNCIÓN DE DESCARGA PDF (igual que la original)
    function descargarPDF() {
        console.log("📄 Iniciando generación de PDF agrícola...")
        
        var nombreArchivo = "reporte_agricola_" + 
                        (tipoReporteSeleccionado > 0 ? tiposReportes[tipoReporteSeleccionado].modulo : "general") + "_" +
                        fechaDesde.replace(/\//g, "") + "_" +
                        fechaHasta.replace(/\//g, "") + ".pdf"
        
        var htmlContent = generarHTMLCompleto()
        
        try {
            var pdfDocument = Qt.createQmlObject(`
                import QtQuick 2.15
                import QtQuick.PDF 5.15
                
                PDFDocument {
                    id: pdfDoc
                    property string htmlContent: ""
                    
                    Component.onCompleted: {
                        generateFromHtml(htmlContent)
                    }
                    
                    onStatusChanged: {
                        if (status === PDFDocument.Ready) {
                            console.log("PDF agrícola generado con éxito")
                            saveAs("${nombreArchivo}")
                        } else if (status === PDFDocument.Error) {
                            console.log("Error al generar PDF:", error)
                            mostrarNotificacionError()
                        }
                    }
                    
                    function saveAs(filename) {
                        var saver = Qt.createQmlObject('
                            import QtQuick 2.15
                            import Qt.labs.platform 1.1
                            
                            FileDialog {
                                id: fileDialog
                                fileMode: FileDialog.SaveFile
                                defaultSuffix: "pdf"
                                nameFilters: ["PDF files (*.pdf)"]
                                selectedFile: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/${nombreArchivo}"
                                
                                onAccepted: {
                                    pdfDoc.save(fileDialog.selectedFile)
                                    console.log("PDF guardado en:", fileDialog.selectedFile)
                                    mostrarNotificacionDescarga("${nombreArchivo}")
                                }
                                onRejected: {
                                    console.log("Guardado de PDF cancelado")
                                }
                            }
                        ', pdfDoc)
                        fileDialog.open()
                    }
                }
            `, reportesRoot)
            
            pdfDocument.htmlContent = htmlContent
            
        } catch (error) {
            console.log("❌ Error al generar PDF:", error)
            mostrarNotificacionError()
        }
    }
    
    function generarHTMLCompleto() {
        var tituloReporte = obtenerTituloReporte()
        var fechaActual = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
        var columnasReporte = obtenerColumnasReporte()
        
        var html = `
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${tituloReporte}</title>
    <style>
        @page {
            size: A4;
            margin: 15mm;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            font-size: 11px;
            line-height: 1.3;
            color: #000;
            background: white;
        }
        
        .header {
            text-align: center;
            margin-bottom: 15px;
        }
        
        .title {
            font-size: 14px;
            font-weight: bold;
            margin-bottom: 8px;
        }
        
        .separator {
            border-bottom: 2px solid #000;
            margin: 8px 0;
        }
        
        .period-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 10px;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        
        .data-table th {
            background: #f0f0f0;
            border: 1px solid #000;
            padding: 6px 4px;
            text-align: left;
            font-weight: bold;
            font-size: 10px;
        }
        
        .data-table td {
            border: 0.5px solid #ccc;
            padding: 4px;
            font-size: 9px;
        }
        
        .data-table tbody tr:nth-child(even) {
            background: #f8f8f8;
        }
        
        .text-right {
            text-align: right;
        }
        
        .text-center {
            text-align: center;
        }
        
        .total-row {
            background: #f0f0f0 !important;
            border: 1px solid #000;
        }
        
        .total-row td {
            font-weight: bold;
            border: 1px solid #000;
        }
        
        .summary {
            margin-top: 20px;
            border-top: 1px solid #000;
            padding-top: 10px;
        }
        
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 4px;
            font-size: 10px;
        }
        
        .summary-label {
            font-weight: bold;
        }
        
        .footer {
            margin-top: 30px;
            text-align: center;
            font-size: 9px;
            color: #666;
            border-top: 1px solid #000;
            padding-top: 10px;
        }
        
        @media print {
            body { font-size: 10px; }
            .no-print { display: none; }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="title">${tituloReporte}</div>
        <div class="separator"></div>
        <div class="period-info">
            <span>PERÍODO: ${fechaDesde} al ${fechaHasta}</span>
            <span>Fecha: ${fechaActual}</span>
        </div>
        <div class="separator"></div>
    </div>

    <table class="data-table">
        <thead>
            <tr>
`
        
        // Generar encabezados dinámicos
        for (var col = 0; col < columnasReporte.length; col++) {
            var columna = columnasReporte[col]
            var alignClass = columna.align === Text.AlignRight ? "text-right" : 
                           columna.align === Text.AlignHCenter ? "text-center" : ""
            html += `                <th class="${alignClass}" style="width: ${columna.width}px;">${columna.titulo}</th>\n`
        }
        
        html += `            </tr>
        </thead>
        <tbody>
`
        
        // Generar filas de datos
        for (var i = 0; i < datosReporte.length; i++) {
            html += `            <tr>\n`
            
            for (var col = 0; col < columnasReporte.length; col++) {
                var columna = columnasReporte[col]
                var valor = obtenerValorColumna(i, columna.campo)
                var alignClass = columna.align === Text.AlignRight ? "text-right" : 
                               columna.align === Text.AlignHCenter ? "text-center" : ""
                
                // Formatear valores monetarios
                if (columna.campo === "valor" || columna.campo === "total" || columna.campo === "costo" || columna.campo === "precioUnitario") {
                    if (parseFloat(valor) < 0) {
                        valor = "-" + Math.abs(parseFloat(valor)).toFixed(2)
                    } else {
                        valor = parseFloat(valor).toFixed(2)
                    }
                }
                
                html += `                <td class="${alignClass}">${valor}</td>\n`
            }
            
            html += `            </tr>\n`
        }
        
        html += `        </tbody>
        <tfoot>
            <tr class="total-row">
`
        
        // Fila de total
        for (var col = 0; col < columnasReporte.length; col++) {
            var columna = columnasReporte[col]
            var alignClass = columna.align === Text.AlignRight ? "text-right" : 
                           columna.align === Text.AlignHCenter ? "text-center" : ""
            
            if (col === columnasReporte.length - 2) {
                html += `                <td class="text-right"><strong>TOTAL GENERAL:</strong></td>\n`
            } else if (col === columnasReporte.length - 1) {
                html += `                <td class="text-right"><strong>${(resumenReporte.totalValor || 0).toFixed(2)}</strong></td>\n`
            } else {
                html += `                <td class="${alignClass}"></td>\n`
            }
        }
        
        html += `            </tr>
        </tfoot>
    </table>

    <div class="summary">
        <div class="summary-row">
            <span class="summary-label">Total de Registros:</span>
            <span>${datosReporte.length}</span>
        </div>
        <div class="summary-row">
            <span class="summary-label">Valor Total:</span>
            <span>Bs ${(resumenReporte.totalValor || 0).toFixed(2)}</span>
        </div>
    </div>

    <div class="footer">
        <p>Sistema de Gestión Agrícola - AGROICHILO</p>
        <p>Villa Yapacaní, Santa Cruz - Bolivia</p>
        <p>Documento generado automáticamente el ${Qt.formatDateTime(new Date(), "dd/MM/yyyy hh:mm:ss")}</p>
    </div>
</body>
</html>
`
        
        return html
    }
    
    // Funciones de notificación (iguales que el original)
    function mostrarNotificacionDescarga(nombreArchivo) {
        var notificacion = Qt.createQmlObject(`
            import QtQuick 2.15
            import QtQuick.Controls 2.15
            import QtQuick.Layouts 1.15
            
            Rectangle {
                id: notification
                width: 400
                height: 80
                color: "${successColor}"
                radius: 10
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                z: 1000
                
                opacity: 0
                Component.onCompleted: {
                    opacity = 1
                    timer.start()
                }
                
                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12
                    
                    Label {
                        text: "✅"
                        font.pixelSize: 24
                        color: "${whiteColor}"
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Label {
                            text: "PDF Generado Exitosamente"
                            font.bold: true
                            font.pixelSize: 14
                            color: "${whiteColor}"
                        }
                        
                        Label {
                            text: "Archivo: ${nombreArchivo}"
                            font.pixelSize: 11
                            color: "${whiteColor}"
                            opacity: 0.9
                        }
                    }
                    
                    Button {
                        text: "×"
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        
                        background: Rectangle {
                            color: parent.pressed ? "${whiteColor}" : "transparent"
                            radius: 15
                            opacity: parent.pressed ? 0.3 : 0.1
                        }
                        
                        contentItem: Label {
                            text: parent.text
                            color: "${whiteColor}"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: notification.destroy()
                    }
                }
                
                Timer {
                    id: timer
                    interval: 5000
                    onTriggered: {
                        notification.opacity = 0
                        Qt.callLater(function() { notification.destroy() })
                    }
                }
            }
        `, reportesRoot)
    }
    
    function mostrarNotificacionError() {
        var notificacion = Qt.createQmlObject(`
            import QtQuick 2.15
            import QtQuick.Controls 2.15
            import QtQuick.Layouts 1.15
            
            Rectangle {
                id: errorNotification
                width: 400
                height: 80
                color: "${dangerColor}"
                radius: 10
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                z: 1000
                
                opacity: 0
                Component.onCompleted: {
                    opacity = 1
                    timer.start()
                }
                
                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12
                    
                    Label {
                        text: "❌"
                        font.pixelSize: 24
                        color: "${whiteColor}"
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Label {
                            text: "Error al Generar PDF"
                            font.bold: true
                            font.pixelSize: 14
                            color: "${whiteColor}"
                        }
                        
                        Label {
                            text: "Intente nuevamente o contacte al administrador"
                            font.pixelSize: 11
                            color: "${whiteColor}"
                            opacity: 0.9
                        }
                    }
                    
                    Button {
                        text: "×"
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        
                        background: Rectangle {
                            color: parent.pressed ? "${whiteColor}" : "transparent"
                            radius: 15
                            opacity: parent.pressed ? 0.3 : 0.1
                        }
                        
                        contentItem: Label {
                            text: parent.text
                            color: "${whiteColor}"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: errorNotification.destroy()
                    }
                }
                
                Timer {
                    id: timer
                    interval: 5000
                    onTriggered: {
                        errorNotification.opacity = 0
                        Qt.callLater(function() { errorNotification.destroy() })
                    }
                }
            }
        `, reportesRoot)
    }
    
    Component.onCompleted: {
        console.log("🌾 Módulo de Reportes Agrícolas inicializado completamente")
        console.log("📋 Tipos de reportes disponibles:", tiposReportes.length)
        
        // Establecer fechas por defecto
        var hoy = new Date()
        var primerDiaMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1)
        
        fechaDesdeField.text = Qt.formatDate(primerDiaMes, "dd/MM/yyyy")
        fechaHastaField.text = Qt.formatDate(hoy, "dd/MM/yyyy")
        
        fechaDesde = fechaDesdeField.text
        fechaHasta = fechaHastaField.text
    }
}