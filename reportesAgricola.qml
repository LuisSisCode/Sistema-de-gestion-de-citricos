import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Pdf 5.15
import Qt.labs.platform 1.1

Item {
    id: reportesRoot
    objectName: "reportesRoot"

    property var reportesModel: generador_pdf_agricola
    property bool mostrandoVistaPrevia: false

    readonly property color primaryColor: "#4CAF50"
    readonly property color successColor: "#27AE60"
    readonly property color dangerColor: "#E74C3C"
    readonly property color warningColor: "#F39C12"
    readonly property color lightGrayColor: "#ECF0F1"
    readonly property color textColor: "#2c3e50"
    readonly property color whiteColor: "#FFFFFF"
    readonly property color darkGrayColor: "#7F8C8D"
    readonly property color infoColor: "#34495E"
    readonly property color violetColor: "#8E44AD"
    readonly property color zebraColor: "#F8F9FA"
    
    property int vistaActual: 0
    property int tipoReporteSeleccionado: 0
    property string fechaDesde: ""
    property string fechaHasta: ""
    property bool reporteGenerado: false
    property var datosReporte: []
    property var resumenReporte: ({})
    property string mensajeError: ""
    property bool mostrarMensajeError: false

    property var tiposReportes: [
        {
            id: 0,
            nombre: "Seleccionar tipo de reporte...",
            modulo: "",
            icono: "📊", 
            descripcion: "Seleccione el tipo de reporte que desea generar",
            color: "#ECF0F1" 
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
            color: "#34495E"
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

    Rectangle {
        id: mensajeEmergente
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.8
        height: 70
        color: dangerColor
        radius: 8
        border.color: Qt.darker(dangerColor, 1.2)
        border.width: 2
        visible: mostrarMensajeError
        z: 1000
        
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 2
            anchors.leftMargin: 2
            color: "#40000000"
            radius: parent.radius
            z: -1
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            
            Rectangle {
                width: 40
                height: 40
                color: "white"
                radius: 20
                
                Label {
                    anchors.centerIn: parent
                    text: "⚠️"
                    font.pixelSize: 18
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Label {
                    text: "ADVERTENCIA"
                    font.pixelSize: 14
                    font.bold: true
                    color: whiteColor
                    font.family: "Segoe UI"
                }
                
                Label {
                    text: mensajeError
                    font.pixelSize: 12
                    color: whiteColor
                    font.family: "Segoe UI"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
            
            Button {
                text: "✕"
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                
                background: Rectangle {
                    color: parent.pressed ? "#40FFFFFF" : "transparent"
                    radius: 15
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
                    mostrarMensajeError = false
                    mensajeError = ""
                }
            }
        }
        
        Timer {
            id: timerOcultarMensaje
            interval: 8000
            onTriggered: {
                mostrarMensajeError = false
                mensajeError = ""
            }
        }
    }
    
    StackLayout {
        anchors.fill: parent
        currentIndex: vistaActual
        
        Item {
            id: vistaConfiguracion
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 20
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: whiteColor
                    radius: 8
                    border.color: lightGrayColor
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20
                        
                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            color: primaryColor
                            radius: 8
                            
                            Label {
                                anchors.centerIn: parent
                                text: "📊"
                                font.pixelSize: 28
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Label {
                                text: "Centro de Reportes Agrícolas"
                                font.pixelSize: 20
                                font.bold: true
                                color: textColor
                            }
                            
                            Label {
                                text: "Sistema de Gestión Agrícola AGROICHILO"
                                font.pixelSize: 12
                                color: darkGrayColor
                            }
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: whiteColor
                    radius: 8
                    border.color: lightGrayColor
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 25
                        spacing: 20
                        
                        Label {
                            text: "Configuración del Reporte"
                            font.pixelSize: 16
                            font.bold: true
                            color: textColor
                        }
                        
                        ColumnLayout {
                            spacing: 10
                            
                            Label {
                                text: "Tipo de Reporte"
                                font.pixelSize: 12
                                font.bold: true
                                color: textColor
                            }
                            
                            ComboBox {
                                id: tipoReporteCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 45
                                model: tiposReportes.map(r => r.nombre)
                                
                                onCurrentIndexChanged: {
                                    tipoReporteSeleccionado = currentIndex
                                }
                                
                                contentItem: Label {
                                    text: tipoReporteCombo.displayText
                                    color: textColor
                                    font.pixelSize: 12
                                    leftPadding: 15
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: whiteColor
                                    border.color: "#bdc3c7"
                                    border.width: 1
                                    radius: 6
                                }
                            }
                        }
                        
                        RowLayout {
                            spacing: 20
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                Label {
                                    text: "Fecha Desde"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: textColor
                                }
                                
                                TextField {
                                    id: fechaDesdeField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    placeholderText: "DD/MM/YYYY"
                                    color: textColor
                                    font.pixelSize: 12
                                    
                                    background: Rectangle {
                                        color: whiteColor
                                        border.color: "#bdc3c7"
                                        border.width: 1
                                        radius: 6
                                    }
                                    
                                    onEditingFinished: fechaDesde = text
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                Label {
                                    text: "Fecha Hasta"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: textColor
                                }
                                
                                TextField {
                                    id: fechaHastaField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    placeholderText: "DD/MM/YYYY"
                                    color: textColor
                                    font.pixelSize: 12
                                    
                                    background: Rectangle {
                                        color: whiteColor
                                        border.color: "#bdc3c7"
                                        border.width: 1
                                        radius: 6
                                    }
                                    
                                    onEditingFinished: fechaHasta = text
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                        
                        Button {
                            id: generarReporteBtn
                            text: "🔍 Generar Reporte"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            enabled: tipoReporteSeleccionado > 0 && fechaDesde && fechaHasta
                            
                            background: Rectangle {
                                color: parent.enabled ? 
                                       (parent.pressed ? Qt.darker(primaryColor, 1.2) : primaryColor) : 
                                       lightGrayColor
                                radius: 6
                                border.color: parent.enabled ? primaryColor : "#BDC3C7"
                                border.width: 1
                            }
                            
                            contentItem: Label {
                                text: parent.text
                                color: parent.enabled ? whiteColor : darkGrayColor
                                font.bold: true
                                font.pixelSize: 13
                                font.family: "Segoe UI"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: generarReporte()
                        }
                    }
                }
            }
        }
        
        Item {
            id: vistaResultados
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: primaryColor
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        
                        Button {
                            text: "← Volver"
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 100
                            
                            background: Rectangle {
                                color: parent.pressed ? "#40FFFFFF" : "transparent"
                                radius: 4
                                border.color: whiteColor
                                border.width: 1
                            }
                            
                            contentItem: Label {
                                text: parent.text
                                color: whiteColor
                                font.bold: true
                                font.pixelSize: 12
                                font.family: "Segoe UI"
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
                            spacing: 4
                            
                            Label {
                                text: "REPORTE: " + obtenerTituloReporte().replace("REPORTE DE ", "").replace("REPORTE ", "")
                                color: whiteColor
                                font.bold: true
                                font.pixelSize: 16
                                font.family: "Segoe UI"
                            }
                            
                            Label {
                                text: "Período: " + fechaDesde + " al " + fechaHasta + " • " + datosReporte.length + " registros"
                                color: "#E8F4FD"
                                font.pixelSize: 11
                                font.family: "Segoe UI"
                            }
                        }
                        
                        RowLayout {
                            spacing: 12
                            
                            Button {
                                text: "📥 Descargar PDF"
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 180
                                
                                background: Rectangle {
                                    color: parent.pressed ? Qt.darker(successColor, 1.2) : successColor
                                    radius: 6
                                }
                                
                                contentItem: Label {
                                    text: parent.text
                                    color: whiteColor
                                    font.bold: true
                                    font.pixelSize: 12
                                    font.family: "Segoe UI"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: descargarPDF()
                            }
                        }
                        
                        Button {
                            text: "×"
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 40
                            
                            background: Rectangle {
                                color: parent.pressed ? "#40FFFFFF" : "transparent"
                                radius: 20
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
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: whiteColor
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: zebraColor
                            radius: 4
                            border.color: "#E9ECEF"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15
                                
                                Label {
                                    text: "PERÍODO: " + fechaDesde + " al " + fechaHasta
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: textColor
                                    font.family: "Segoe UI"
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Label {
                                    text: "Fecha: " + Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                                    font.pixelSize: 12
                                    color: darkGrayColor
                                    font.family: "Segoe UI"
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: whiteColor
                            radius: 4
                            border.color: "#E0E6ED"
                            border.width: 1
                            
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 50
                                    color: primaryColor
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10
                                        
                                        Repeater {
                                            model: obtenerColumnasReporte()
                                            
                                            Rectangle {
                                                Layout.preferredWidth: modelData.width || 80
                                                Layout.fillHeight: true
                                                color: "transparent"
                                                
                                                Label {
                                                    anchors.fill: parent
                                                    anchors.margins: 5
                                                    text: modelData.titulo
                                                    color: whiteColor
                                                    font.bold: true
                                                    font.pixelSize: 11
                                                    horizontalAlignment: modelData.align || Text.AlignLeft
                                                    verticalAlignment: Text.AlignVCenter
                                                    wrapMode: Text.WordWrap
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                ListView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    
                                    model: datosReporte
                                    spacing: 0
                                    clip: true
                                    
                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 40
                                        color: index % 2 === 0 ? zebraColor : whiteColor
                                        border.color: "#E0E6ED"
                                        border.width: 1
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 10
                                            
                                            Repeater {
                                                model: obtenerColumnasReporte()
                                                
                                                Label {
                                                    Layout.preferredWidth: modelData.width || 80
                                                    Layout.fillHeight: true
                                                    text: obtenerValorColumna(index, modelData.campo)
                                                    color: textColor
                                                    font.pixelSize: 10
                                                    horizontalAlignment: modelData.align || Text.AlignLeft
                                                    verticalAlignment: Text.AlignVCenter
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45
                                    color: primaryColor
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10
                                        
                                        Label {
                                            Layout.fillWidth: true
                                            text: "TOTAL"
                                            color: whiteColor
                                            font.bold: true
                                            font.pixelSize: 11
                                        }
                                        
                                        Label {
                                            Layout.preferredWidth: 150
                                            text: "Bs " + calcularTotalReporte().toFixed(2)
                                            color: whiteColor
                                            font.bold: true
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignRight
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
    
    function generarReporte() {
        console.log("📊 Generando reporte...")
        
        mostrarMensajeError = false
        
        if (tipoReporteSeleccionado === 0) {
            mensajeError = "Debe seleccionar un tipo de reporte"
            mostrarMensajeError = true
            timerOcultarMensaje.restart()
            return
        }
        
        if (!fechaDesde || !fechaHasta) {
            mensajeError = "Complete ambas fechas"
            mostrarMensajeError = true
            timerOcultarMensaje.restart()
            return
        }
        
        datosReporte = generarDatosSimulados(tipoReporteSeleccionado)
        reportesModel.tipo_reporte = tipoReporteSeleccionado
        reportesModel.fecha_desde = fechaDesde
        reportesModel.fecha_hasta = fechaHasta
        reportesModel.datos_reporte = datosReporte
        
        if (datosReporte.length > 0) {
            reporteGenerado = true
            vistaActual = 1
            console.log("✅ Reporte generado con " + datosReporte.length + " registros")
        } else {
            mensajeError = "No hay datos para este período"
            mostrarMensajeError = true
            timerOcultarMensaje.restart()
        }
    }
    
    function descargarPDF() {
        console.log("📄 Generando PDF...")
        
        if (!reporteGenerado || !datosReporte || datosReporte.length === 0) {
            mensajeError = "No hay datos para descargar"
            mostrarMensajeError = true
            timerOcultarMensaje.restart()
            return
        }
        
        try {
            var datosJSON = JSON.stringify(datosReporte)
            var rutaArchivo = reportesModel.generar_reporte_pdf(datosJSON, tipoReporteSeleccionado, fechaDesde, fechaHasta)
            
            if (rutaArchivo && rutaArchivo.length > 0) {
                console.log("✅ PDF generado:", rutaArchivo)
                var nombreArchivo = rutaArchivo.split("/").pop().split("\\").pop()
                mostrarNotificacionDescarga(nombreArchivo)
                Qt.openUrlExternally("file:///" + rutaArchivo)
            } else {
                console.log("❌ Error generando PDF")
                mensajeError = "Error al generar el PDF"
                mostrarMensajeError = true
                timerOcultarMensaje.restart()
            }
        } catch (error) {
            console.log("❌ Error:", error)
            mensajeError = "Error inesperado"
            mostrarMensajeError = true
            timerOcultarMensaje.restart()
        }
    }
    
    function generarDatosSimulados(tipoReporte) {
        var datos = []
        for (var i = 0; i < 15; i++) {
            var fecha = new Date(2025, 0, 1 + i)
            var fechaFormato = Qt.formatDate(fecha, "dd/MM/yyyy")
            var registro = { fecha: fechaFormato }
            
            switch(tipoReporte) {
                case 1:
                    registro.cultivo = ["Maíz", "Trigo", "Soya"][i % 3]
                    registro.variedad = "Variedad A"
                    registro.cantidad = 50 + i
                    registro.unidad = "kg"
                    registro.valor = 1000 + (i * 100)
                    break
                case 2:
                    registro.producto = ["Fungicida", "Insecticida", "Herbicida"][i % 3]
                    registro.marca = "Marca C"
                    registro.stock = 100 + i
                    registro.precio_unitario = 50 + i
                    registro.valor_total = (100 + i) * (50 + i)
                    break
                case 3:
                    registro.cliente = "Cliente " + (i + 1)
                    registro.producto = "Producto A"
                    registro.cantidad = 5 + i
                    registro.precio_unitario = 100
                    registro.valor = (5 + i) * 100
                    break
                case 4:
                    registro.productor = "Productor " + (i + 1)
                    registro.parcela = "Parcela 1"
                    registro.cultivo = "Cultivo A"
                    registro.hectareas = 5
                    registro.estado = "Activa"
                    break
                case 5:
                    registro.equipo = ["Tractor", "Cosechadora"][i % 2]
                    registro.marca = "Marca A"
                    registro.modelo = "2020"
                    registro.año = "2020"
                    registro.estado = "Operativo"
                    registro.valor = 50000
                    break
                case 6:
                    registro.equipo = "Tractor"
                    registro.litros = 50 + i
                    registro.precio_unitario = 5.5
                    registro.costo_total = (50 + i) * 5.5
                    break
                case 7:
                    registro.equipo = "Tractor"
                    registro.tipo_mantenimiento = "Preventivo"
                    registro.descripcion = "Mantenimiento"
                    registro.costo = 500 + (i * 50)
                    break
                case 8:
                    registro.parcela = "Parcela 1"
                    registro.cultivo = "Cultivo A"
                    registro.producto = "Fungicida"
                    registro.dosis = "5 L/ha"
                    registro.costo = 200 + (i * 20)
                    break
                case 9:
                    registro.tipo = i % 2 === 0 ? "Ingreso" : "Egreso"
                    registro.descripcion = i % 2 === 0 ? "Venta" : "Gasto"
                    registro.valor = 5000 + (i * 500)
                    break
            }
            datos.push(registro)
        }
        return datos
    }
    
    function obtenerColumnasReporte() {
        switch(tipoReporteSeleccionado) {
            case 1: return [
                {titulo: "FECHA", campo: "fecha", width: 70},
                {titulo: "CULTIVO", campo: "cultivo", width: 100},
                {titulo: "VARIEDAD", campo: "variedad", width: 100},
                {titulo: "CANTIDAD", campo: "cantidad", width: 80},
                {titulo: "UNIDAD", campo: "unidad", width: 60},
                {titulo: "VALOR (Bs)", campo: "valor", width: 100, align: Text.AlignRight}
            ]
            case 2: return [
                {titulo: "FECHA", campo: "fecha", width: 70},
                {titulo: "PRODUCTO", campo: "producto", width: 100},
                {titulo: "MARCA", campo: "marca", width: 80},
                {titulo: "STOCK", campo: "stock", width: 70},
                {titulo: "PRECIO UNIT.", campo: "precio_unitario", width: 90},
                {titulo: "VALOR TOTAL (Bs)", campo: "valor_total", width: 100, align: Text.AlignRight}
            ]
            case 3: return [
                {titulo: "FECHA", campo: "fecha", width: 70},
                {titulo: "CLIENTE", campo: "cliente", width: 100},
                {titulo: "PRODUCTO", campo: "producto", width: 100},
                {titulo: "CANTIDAD", campo: "cantidad", width: 70},
                {titulo: "PRECIO UNIT.", campo: "precio_unitario", width: 90},
                {titulo: "TOTAL (Bs)", campo: "valor", width: 80, align: Text.AlignRight}
            ]
            case 4: return [
                {titulo: "PRODUCTOR", campo: "productor", width: 100},
                {titulo: "PARCELA", campo: "parcela", width: 80},
                {titulo: "CULTIVO", campo: "cultivo", width: 80},
                {titulo: "HECTÁREAS", campo: "hectareas", width: 70},
                {titulo: "ESTADO", campo: "estado", width: 100},
                {titulo: "", campo: "fecha", width: 50}
            ]
            case 5: return [
                {titulo: "EQUIPO", campo: "equipo", width: 100},
                {titulo: "MARCA", campo: "marca", width: 80},
                {titulo: "MODELO", campo: "modelo", width: 80},
                {titulo: "AÑO", campo: "año", width: 60},
                {titulo: "ESTADO", campo: "estado", width: 90},
                {titulo: "VALOR (Bs)", campo: "valor", width: 100, align: Text.AlignRight}
            ]
            case 6: return [
                {titulo: "FECHA", campo: "fecha", width: 70},
                {titulo: "EQUIPO", campo: "equipo", width: 100},
                {titulo: "LITROS", campo: "litros", width: 70},
                {titulo: "PRECIO UNIT.", campo: "precio_unitario", width: 90},
                {titulo: "COSTO TOTAL (Bs)", campo: "costo_total", width: 100},
                {titulo: "", campo: "", width: 30}
            ]
            case 7: return [
                {titulo: "FECHA", campo: "fecha", width: 70},
                {titulo: "EQUIPO", campo: "equipo", width: 100},
                {titulo: "TIPO", campo: "tipo_mantenimiento", width: 100},
                {titulo: "DESCRIPCIÓN", campo: "descripcion", width: 150},
                {titulo: "COSTO (Bs)", campo: "costo", width: 100, align: Text.AlignRight},
                {titulo: "", campo: "", width: 20}
            ]
            case 8: return [
                {titulo: "FECHA", campo: "fecha", width: 70},
                {titulo: "PARCELA", campo: "parcela", width: 80},
                {titulo: "CULTIVO", campo: "cultivo", width: 80},
                {titulo: "PRODUCTO", campo: "producto", width: 100},
                {titulo: "DOSIS", campo: "dosis", width: 80},
                {titulo: "COSTO (Bs)", campo: "costo", width: 100, align: Text.AlignRight}
            ]
            case 9: return [
                {titulo: "FECHA", campo: "fecha", width: 70},
                {titulo: "TIPO", campo: "tipo", width: 80},
                {titulo: "DESCRIPCIÓN", campo: "descripcion", width: 150},
                {titulo: "VALOR (Bs)", campo: "valor", width: 100, align: Text.AlignRight},
                {titulo: "", campo: "", width: 40},
                {titulo: "", campo: "", width: 20}
            ]
            default: return [{titulo: "DATOS", campo: "valor", width: 500}]
        }
    }
    
    function obtenerValorColumna(index, campo) {
        if (!datosReporte[index]) return "---"
        var registro = datosReporte[index]
        var valor = registro[campo]
        if (valor === undefined || valor === null) return "---"
        if (typeof valor === "number" && (campo.includes("valor") || campo.includes("precio") || campo.includes("costo"))) {
            return "Bs " + valor.toFixed(2)
        }
        return valor.toString()
    }
    
    function obtenerTituloReporte() {
        switch(tipoReporteSeleccionado) {
            case 1: return "REPORTE DE PRODUCCIÓN POR CULTIVOS"
            case 2: return "REPORTE DE INVENTARIO DE AGROQUÍMICOS"
            case 3: return "REPORTE DE VENTAS Y CLIENTES"
            case 4: return "REPORTE DE GESTIÓN DE PARCELAS"
            case 5: return "REPORTE DE MAQUINARIA Y EQUIPOS"
            case 6: return "REPORTE DE CONSUMO DE COMBUSTIBLE"
            case 7: return "REPORTE DE MANTENIMIENTO DE EQUIPOS"
            case 8: return "REPORTE DE TRATAMIENTOS FITOSANITARIOS"
            case 9: return "REPORTE FINANCIERO CONSOLIDADO"
            default: return "REPORTE GENERAL"
        }
    }
    
    function calcularTotalReporte() {
        var total = 0.0
        if (!datosReporte || datosReporte.length === 0) return 0.0
        for (var i = 0; i < datosReporte.length; i++) {
            var registro = datosReporte[i]
            var valor = 0.0
            if (registro.valor !== undefined) valor = parseFloat(registro.valor) || 0.0
            else if (registro.valor_total !== undefined) valor = parseFloat(registro.valor_total) || 0.0
            else if (registro.costo_total !== undefined) valor = parseFloat(registro.costo_total) || 0.0
            else if (registro.costo !== undefined) valor = parseFloat(registro.costo) || 0.0
            total += valor
        }
        return total
    }
    
    function mostrarNotificacionDescarga(nombreArchivo) {
        console.log("✅ PDF descargado:", nombreArchivo)
    }
    
    Component.onCompleted: {
        console.log("🌾 Módulo de Reportes Agrícolas inicializado")
        var hoy = new Date()
        var primerDiaMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1)
        fechaDesdeField.text = Qt.formatDate(primerDiaMes, "dd/MM/yyyy")
        fechaHastaField.text = Qt.formatDate(hoy, "dd/MM/yyyy")
        fechaDesde = fechaDesdeField.text
        fechaHasta = fechaHastaField.text
    }
}
