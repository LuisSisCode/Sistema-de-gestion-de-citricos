import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Rectangle {
    id: dashboardRoot
    anchors.fill: parent
    color: "#f8fafc"
    
    // Propiedades del modelo
    property bool modelDisponible: dashboardModel !== undefined && dashboardModel !== null
    property bool datosCargados: false
    
    // Propiedades para almacenar datos de tendencias - MODIFICADO PARA SER REACTIVO
    property var tendenciaProduccionData: []
    property var tendenciaVentasData: []
    
    // Propiedades responsive
    property bool isMobile: width < 768
    property bool isTablet: width >= 768 && width < 1024
    property bool isDesktop: width >= 1024
    
    // Breakpoints para responsive
    property int breakpointMobile: 768
    property int breakpointTablet: 1024

    // Funciones para manejar la visibilidad - NUEVAS FUNCIONES
    function toggleProduccionVisibility(variedad) {
        console.log("🔄 Cambiando visibilidad producción:", variedad);
        for (var i = 0; i < tendenciaProduccionData.length; i++) {
            if (tendenciaProduccionData[i].variedad === variedad) {
                tendenciaProduccionData[i].visible = !tendenciaProduccionData[i].visible;
                console.log("✅ Nueva visibilidad para", variedad + ":", tendenciaProduccionData[i].visible);
                
                // Forzar actualización reactiva
                var temp = tendenciaProduccionData.slice();
                tendenciaProduccionData = [];
                tendenciaProduccionData = temp;
                
                produccionCanvas.requestPaint();
                break;
            }
        }
    }
    
    function toggleVentasVisibility(variedad) {
        console.log("🔄 Cambiando visibilidad ventas:", variedad);
        for (var i = 0; i < tendenciaVentasData.length; i++) {
            if (tendenciaVentasData[i].variedad === variedad) {
                tendenciaVentasData[i].visible = !tendenciaVentasData[i].visible;
                console.log("✅ Nueva visibilidad para", variedad + ":", tendenciaVentasData[i].visible);
                
                // Forzar actualización reactiva
                var temp = tendenciaVentasData.slice();
                tendenciaVentasData = [];
                tendenciaVentasData = temp;
                
                ventasCanvas.requestPaint();
                break;
            }
        }
    }
    
    // Función para verificar el modelo
    function verificarModelo() {
        console.log("🔍 Verificando dashboardModel...");
        
        if (modelDisponible) {
            console.log("✅ dashboardModel disponible");
            dashboardModel.dataChanged.connect(actualizarUI);
            dashboardModel.errorOccurred.connect(manejarError);
            dashboardModel.loadAllData();
        } else {
            console.error("❌ dashboardModel no disponible");
            dashboardRoot.datosCargados = false;
        }
    }
    
    function actualizarUI() {
        console.log("✅ Datos actualizados desde el modelo");
        dashboardRoot.datosCargados = true;
        
        // Actualizar datos locales de forma segura
        if (modelDisponible) {
            // Inicializar datos con visibilidad true por defecto
            var prodData = dashboardModel.tendenciaProduccionVariedades || [];
            for (var i = 0; i < prodData.length; i++) {
                if (prodData[i].visible === undefined) {
                    prodData[i].visible = true;
                }
            }
            tendenciaProduccionData = prodData;
            
            var ventasData = dashboardModel.tendenciaVentasVariedades || [];
            for (var j = 0; j < ventasData.length; j++) {
                if (ventasData[j].visible === undefined) {
                    ventasData[j].visible = true;
                }
            }
            tendenciaVentasData = ventasData;
            
            // Cargar próximos mantenimientos para las alertas
            var mantenimientos = dashboardModel.getProximosMantenimientos() || [];
            console.log("🔧 Próximos mantenimientos:", mantenimientos.length, "registros");
            
            if (mantenimientos.length > 0) {
                console.log("🔧 Primer mantenimiento:", mantenimientos[0].nombre, "- Fecha:", mantenimientos[0].fecha);
            }
            
            // Logs de depuración
            console.log("📊 Datos Producción recibidos:", tendenciaProduccionData.length, "series");
            console.log("💰 Datos Ventas recibidos:", tendenciaVentasData.length, "series");
            
            if (tendenciaProduccionData.length > 0) {
                console.log("📈 Primera serie producción:", tendenciaProduccionData[0].variedad, "- Visible:", tendenciaProduccionData[0].visible);
            }
            
            if (tendenciaVentasData.length > 0) {
                console.log("💵 Primera serie ventas:", tendenciaVentasData[0].variedad, "- Visible:", tendenciaVentasData[0].visible);
            }
        } else {
            tendenciaProduccionData = [];
            tendenciaVentasData = [];
        }
        
        // Forzar repintado de los canvas
        if (produccionCanvas) {
            produccionCanvas.requestPaint();
        }
        if (ventasCanvas) {
            ventasCanvas.requestPaint();
        }
    }
    
    function getTotalAlertasCompleto() {
        if (!modelDisponible) return 0;
        
        var alertasSistema = dashboardModel.listaAlertas ? dashboardModel.listaAlertas.length : 0;
        
        console.log("🔔 Debug Alertas - Sistema:", alertasSistema);
        
        return alertasSistema;
    }
        
    function manejarError(mensaje) {
        console.error("❌ Error:", mensaje);
        dashboardRoot.datosCargados = false;
    }
    
    function formatearNumero(numero) {
        var num = parseFloat(numero);
        if (isNaN(num)) return "0.00";
        
        var partes = num.toFixed(2).split(".");
        partes[0] = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return partes.join(".");
    }
    
    function formatearMoneda(valor) {
        var num = parseFloat(valor);
        if (isNaN(num)) return "Bs 0.00";
        
        if (num >= 1000000) {
            return "Bs " + (num / 1000000).toFixed(1) + "M";
        } else if (num >= 1000) {
            return "Bs " + (num / 1000).toFixed(1) + "K";
        } else {
            return "Bs " + num.toFixed(2);
        }
    }

    // FUNCIONES CORREGIDAS PARA GRÁFICAS
    function procesarDatosTendencia(datosTendencia) {
        if (!datosTendencia || datosTendencia.length === 0) {
            console.log("⚠️ procesarDatosTendencia: No hay datos");
            return [];
        }
        
        console.log("🔄 Procesando", datosTendencia.length, "series de datos");
        
        var series = [];
        var todosLosAnios = new Set();
        
        // Recopilar todos los años únicos
        for (var i = 0; i < datosTendencia.length; i++) {
            var variedad = datosTendencia[i];
            
            if (variedad.datos && variedad.datos.length > 0) {
                for (var j = 0; j < variedad.datos.length; j++) {
                    todosLosAnios.add(variedad.datos[j].anio);
                }
            }
        }
        
        // Convertir Set a Array y ordenar
        var aniosArray = Array.from(todosLosAnios);
        aniosArray.sort(function(a, b) { return a - b; });
        
        console.log("📅 Años encontrados:", aniosArray.join(", "));
        
        // Para cada variedad, asegurarse de que tenga datos para todos los años
        for (var k = 0; k < datosTendencia.length; k++) {
            var variedadActual = datosTendencia[k];
            var serie = {
                variedad: variedadActual.variedad,
                color: variedadActual.color,
                visible: variedadActual.visible, // MANTENER LA VISIBILIDAD ACTUAL
                datos: []
            };
            
            for (var l = 0; l < aniosArray.length; l++) {
                var anioActual = aniosArray[l];
                var valor = 0;
                
                // Buscar si existe dato para este año
                if (variedadActual.datos) {
                    for (var m = 0; m < variedadActual.datos.length; m++) {
                        if (variedadActual.datos[m].anio === anioActual) {
                            valor = variedadActual.datos[m].valor;
                            break;
                        }
                    }
                }
                
                serie.datos.push({
                    anio: anioActual,
                    valor: valor
                });
            }
            
            series.push(serie);
            console.log("  ✅ Serie procesada:", serie.variedad, "-", serie.datos.length, "puntos", "- Visible:", serie.visible);
        }
        
        return series;
    }

    function dibujarGrafica(ctx, datosProcesados, width, height, esMoneda) {
        console.log("🎨 Dibujando gráfica - Width:", width, "Height:", height, "Series:", datosProcesados.length);
        
        if (!datosProcesados || datosProcesados.length === 0) {
            console.log("⚠️ No hay datos para dibujar");
            ctx.fillStyle = "#64748b";
            ctx.font = "14px Arial";
            ctx.textAlign = "center";
            ctx.fillText("No hay datos disponibles", width / 2, height / 2);
            return;
        }
        
        var padding = { top: 40, right: 30, bottom: 50, left: 60 };
        var chartWidth = width - padding.left - padding.right;
        var chartHeight = height - padding.top - padding.bottom;
        
        // Validar dimensiones mínimas
        if (chartWidth <= 0 || chartHeight <= 0) {
            console.log("⚠️ Dimensiones insuficientes para dibujar");
            return;
        }
        
        // Encontrar valor máximo para escalado - SOLO DE SERIES VISIBLES
        var maxValor = 1;
        var todosLosAnios = new Set();
        var seriesVisibles = 0;
        
        for (var i = 0; i < datosProcesados.length; i++) {
            var serie = datosProcesados[i];
            if (!serie.visible) {
                console.log("  ⏭️ Serie no visible en cálculo de máximo:", serie.variedad);
                continue;
            }
            seriesVisibles++;
            
            for (var j = 0; j < serie.datos.length; j++) {
                if (serie.datos[j].valor > maxValor) {
                    maxValor = serie.datos[j].valor;
                }
                todosLosAnios.add(serie.datos[j].anio);
            }
        }
        
        if (maxValor === 0) maxValor = 1;
        
        console.log("📊 Series visibles:", seriesVisibles, "de", datosProcesados.length);
        console.log("📈 Valor máximo:", maxValor);
        
        // Si no hay series visibles, mostrar mensaje
        if (seriesVisibles === 0) {
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = "#64748b";
            ctx.font = "14px Arial";
            ctx.textAlign = "center";
            ctx.fillText("Todas las series están ocultas", width / 2, height / 2);
            return;
        }
        
        // Convertir Set a Array y ordenar
        var aniosUnicos = Array.from(todosLosAnios).sort();
        var numPuntos = aniosUnicos.length;
        
        console.log("📊 Años únicos encontrados:", aniosUnicos.join(", "));
        
        // Limpiar canvas
        ctx.clearRect(0, 0, width, height);
        
        // Dibujar fondo de la gráfica
        ctx.fillStyle = "#f8fafc";
        ctx.fillRect(padding.left, padding.top, chartWidth, chartHeight);
        
        // Dibujar ejes
        ctx.strokeStyle = "#e2e8f0";
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(padding.left, padding.top);
        ctx.lineTo(padding.left, padding.top + chartHeight);
        ctx.lineTo(padding.left + chartWidth, padding.top + chartHeight);
        ctx.stroke();
        
        // Dibujar líneas de grid horizontales
        ctx.strokeStyle = "#f1f5f9";
        ctx.lineWidth = 1;
        for (var n = 0; n <= 5; n++) {
            var y = padding.top + chartHeight - (chartHeight * (n / 5));
            ctx.beginPath();
            ctx.moveTo(padding.left, y);
            ctx.lineTo(padding.left + chartWidth, y);
            ctx.stroke();
        }
        
        // LIMPIAR puntos anteriores
        for (var k = 0; k < datosProcesados.length; k++) {
            datosProcesados[k].puntos = [];
        }
        
        // Dibujar líneas para cada serie - SOLO LAS VISIBLES
        for (var k = 0; k < datosProcesados.length; k++) {
            var serieActual = datosProcesados[k];
            
            if (!serieActual.visible) {
                console.log("  ⏭️ Saltando serie no visible:", serieActual.variedad);
                continue;
            }
            
            ctx.strokeStyle = serieActual.color;
            ctx.lineWidth = 3;
            ctx.beginPath();
            
            var puntos = [];
            var tienePuntosValidos = false;
            var primerPunto = true;
            
            for (var l = 0; l < aniosUnicos.length; l++) {
                var anioActual = aniosUnicos[l];
                var valor = 0;
                
                // Buscar valor para este año
                for (var m = 0; m < serieActual.datos.length; m++) {
                    if (serieActual.datos[m].anio === anioActual) {
                        valor = serieActual.datos[m].valor;
                        break;
                    }
                }
                
                var x = padding.left + (chartWidth * (l / Math.max(numPuntos - 1, 1)));
                var y = padding.top + chartHeight - (chartHeight * (valor / maxValor));
                
                puntos.push({x: x, y: y, valor: valor, anio: anioActual});
                
                if (primerPunto && valor > 0) {
                    ctx.moveTo(x, y);
                    primerPunto = false;
                    tienePuntosValidos = true;
                } else if (!primerPunto) {
                    ctx.lineTo(x, y);
                }
                
                if (valor > 0) tienePuntosValidos = true;
            }
            
            // Solo dibujar línea si hay más de un punto y valores válidos
            if (puntos.length > 1 && tienePuntosValidos) {
                ctx.stroke();
                console.log("  ✅ Línea dibujada para:", serieActual.variedad);
            } else {
                console.log("  ⏭️ No se dibuja línea para:", serieActual.variedad, "- Sin puntos válidos");
            }
            
            // Dibujar puntos y almacenar información para interactividad
            for (var p = 0; p < puntos.length; p++) {
                var punto = puntos[p];
                
                // Solo dibujar puntos con valores > 0
                if (punto.valor > 0) {
                    ctx.fillStyle = serieActual.color;
                    ctx.beginPath();
                    ctx.arc(punto.x, punto.y, 6, 0, Math.PI * 2);
                    ctx.fill();
                    
                    // Borde blanco para mejor visibilidad
                    ctx.strokeStyle = "white";
                    ctx.lineWidth = 2;
                    ctx.stroke();
                }
            }
            
            // Almacenar puntos para interactividad
            serieActual.puntos = puntos;
        }
        
        // Etiquetas de años
        ctx.fillStyle = "#64748b";
        ctx.font = "12px Arial";
        ctx.textAlign = "center";
        
        for (var a = 0; a < aniosUnicos.length; a++) {
            var anioLabel = aniosUnicos[a];
            var xLabel = padding.left + (chartWidth * (a / Math.max(numPuntos - 1, 1)));
            var yLabel = padding.top + chartHeight + 20;
            ctx.fillText(anioLabel.toString(), xLabel, yLabel);
        }
        
        // Etiquetas de valores (5 niveles)
        ctx.textAlign = "right";
        ctx.fillStyle = "#64748b";
        ctx.font = "11px Arial";
        
        for (var v = 0; v <= 5; v++) {
            var valorEtiqueta = maxValor * (v / 5);
            var yEtiqueta = padding.top + chartHeight - (chartHeight * (v / 5));
            
            var textoValor = "";
            if (esMoneda) {
                textoValor = formatearMonetaCompacta(valorEtiqueta);
            } else {
                if (valorEtiqueta >= 1000) {
                    textoValor = (valorEtiqueta / 1000).toFixed(1) + "K";
                } else {
                    textoValor = valorEtiqueta.toFixed(0);
                }
            }
            
            ctx.fillText(textoValor, padding.left - 8, yEtiqueta + 4);
        }
        
        console.log("✅ Gráfica dibujada correctamente");
    }

    function formatearMonetaCompacta(valor) {
        var num = parseFloat(valor);
        if (isNaN(num)) return "Bs 0";
        
        if (num >= 1000000) {
            return "Bs " + (num / 1000000).toFixed(1) + "M";
        } else if (num >= 1000) {
            return "Bs " + (num / 1000).toFixed(1) + "K";
        } else {
            return "Bs " + num.toFixed(0);
        }
    }

    function encontrarPuntoCercano(mouseX, mouseY, datosProcesados) {
        if (!datosProcesados || datosProcesados.length === 0) return null
        
        var distanciaMinima = 25 // Radio de tolerancia en píxeles
        var puntoCercano = null
        
        for (var i = 0; i < datosProcesados.length; i++) {
            var serie = datosProcesados[i]
            if (!serie.visible || !serie.puntos) continue
            
            for (var j = 0; j < serie.puntos.length; j++) {
                var punto = serie.puntos[j]
                // Considerar todos los puntos, no solo los con valor > 0
                var distancia = Math.sqrt(
                    Math.pow(mouseX - punto.x, 2) + 
                    Math.pow(mouseY - punto.y, 2)
                )
                
                if (distancia < distanciaMinima) {
                    distanciaMinima = distancia
                    puntoCercano = {
                        x: punto.x,
                        y: punto.y,
                        valor: punto.valor,
                        anio: punto.anio,
                        variedad: serie.variedad,
                        color: serie.color
                    }
                }
            }
        }
        
        return puntoCercano
    }

    // Panel de carga
    Rectangle {
        id: loadingPanel
        anchors.fill: parent
        color: "#f8fafc"
        visible: !dashboardRoot.datosCargados
        z: 10
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            
            Text {
                text: "⏳"
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Cargando Dashboard..."
                font.pixelSize: 18
                font.weight: Font.Medium
                color: "#6c757d"
                Layout.alignment: Qt.AlignHCenter
            }
            
            ProgressBar {
                Layout.preferredWidth: 200
                indeterminate: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Contenido principal - MODIFICADO PARA OCUPAR TODO EL ANCHO
    ScrollView {
        anchors.fill: parent
        visible: dashboardRoot.datosCargados
        clip: true
        
        Column {
            width: dashboardRoot.width  // Usar el ancho completo del dashboardRoot
            spacing: 0

            // Título del dashboard CON BOTÓN ACTUALIZAR - ANCHO COMPLETO
            Rectangle {
                width: parent.width
                height: isMobile ? 80 : 90
                color: "transparent"
                
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: isMobile ? 20 : 30
                    anchors.rightMargin: isMobile ? 20 : 30
                    spacing: 10
                    
                    Column {
                        width: parent.width - (isMobile ? 100 : 120) // Dejamos espacio para el botón
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: isMobile ? 4 : 6
                        
                        Text {
                            text: "🌱 Gestión Agrícola"
                            font.pixelSize: isMobile ? 20 : 24
                            font.weight: Font.Bold
                            color: "#1e293b"
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignLeft
                        }
                        
                        Text {
                            text: "Resumen completo de operaciones y métricas"
                            font.pixelSize: isMobile ? 12 : 14
                            color: "#64748b"
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                    
                    Button {
                        anchors.verticalCenter: parent.verticalCenter
                        width: isMobile ? 90 : 100
                        height: isMobile ? 36 : 40
                        text: "🔄 Actualizar"
                        background: Rectangle {
                            radius: 6
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#4f46e5" }
                                GradientStop { position: 1.0; color: "#7c3aed" }
                            }
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: isMobile ? 11 : 12
                            font.weight: Font.Medium
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            if (modelDisponible) {
                                dashboardModel.refresh();
                            } else {
                                verificarModelo();
                            }
                        }
                    }
                }
            }
            
            // Layout principal - ANCHO COMPLETO
            Column {
                width: parent.width  // Usar el ancho completo del padre
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16
                padding: isMobile ? 10 : 20  // Padding lateral para evitar que el contenido toque los bordes
                
                // PRIMERA FILA DE MÉTRICAS - ANCHO COMPLETO
                Grid {
                    width: parent.width - (isMobile ? 20 : 40)  // Ajustar para el padding
                    columns: isMobile ? 1 : 3
                    rowSpacing: 12
                    columnSpacing: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    // Tarjeta Productores - COLOR AZUL CLARO
                    Rectangle {
                        width: isMobile ? parent.width : (parent.width - 24) / 3
                        height: isMobile ? 160 : 180
                        color: "#e0f2fe"  // Azul muy claro
                        radius: 8
                        border.color: "#bae6fd"
                        border.width: 1
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 10
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#4f46e5" }
                                        GradientStop { position: 1.0; color: "#7c3aed" }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "👨‍🌾"
                                        font.pixelSize: 20
                                    }
                                }
                                
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    
                                    Text {
                                        text: "Productores"
                                        font.pixelSize: 13
                                        color: "#1e40af"  // Azul oscuro para contraste
                                    }
                                    
                                    Text {
                                        text: modelDisponible ? dashboardModel.totalProductores + " Activos" : "0 Activos"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: "#1e3a8a"  // Azul más oscuro
                                    }
                                }
                            }
                            
                            ScrollView {
                                width: parent.width
                                height: isMobile ? 60 : 80
                                clip: true
                                
                                Column {
                                    width: parent.width
                                    spacing: 2
                                    
                                    Repeater {
                                        model: modelDisponible ? dashboardModel.listaProductores : []
                                        
                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 18
                                            color: "transparent"
                                            
                                            Text {
                                                text: "• " + modelData
                                                font.pixelSize: 10
                                                color: "#1e40af"  // Azul oscuro
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Tarjeta Parcelas - COLOR VERDE CLARO
                    Rectangle {
                        width: isMobile ? parent.width : (parent.width - 24) / 3
                        height: isMobile ? 160 : 180
                        color: "#dcfce7"  // Verde muy claro
                        radius: 8
                        border.color: "#bbf7d0"
                        border.width: 1
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 10
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#0d9488" }
                                        GradientStop { position: 1.0; color: "#10b981" }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "🌳"
                                        font.pixelSize: 20
                                    }
                                }
                                
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    
                                    Text {
                                        text: "Parcelas"
                                        font.pixelSize: 13
                                        color: "#166534"  // Verde oscuro para contraste
                                    }
                                    
                                    Text {
                                        text: modelDisponible ? dashboardModel.totalParcelas + " En producción" : "0 En producción"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: "#14532d"  // Verde más oscuro
                                    }
                                }
                            }
                            
                            ScrollView {
                                width: parent.width
                                height: isMobile ? 60 : 80
                                clip: true
                                
                                Column {
                                    width: parent.width
                                    spacing: 2
                                    
                                    Repeater {
                                        model: modelDisponible ? dashboardModel.listaParcelas : []
                                        
                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 18
                                            color: "transparent"
                                            
                                            Text {
                                                text: "• " + modelData
                                                font.pixelSize: 10
                                                color: "#166534"  // Verde oscuro
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Tarjeta Ciclos Activos - COLOR LILA CLARO
                    Rectangle {
                        width: isMobile ? parent.width : (parent.width - 24) / 3
                        height: isMobile ? 160 : 180
                        color: "#f3e8ff"  // Lila muy claro
                        radius: 8
                        border.color: "#e9d5ff"
                        border.width: 1
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 10
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#7c3aed" }
                                        GradientStop { position: 1.0; color: "#a855f7" }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "📅"
                                        font.pixelSize: 20
                                    }
                                }
                                
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    
                                    Text {
                                        text: "Ciclos Activos"
                                        font.pixelSize: 13
                                        color: "#6b21a8"  // Púrpura oscuro para contraste
                                    }
                                    
                                    Text {
                                        text: (modelDisponible ? dashboardModel.ciclosActivos : "0") + " • " + 
                                              (modelDisponible ? dashboardModel.hectareasCultivo.toFixed(1) : "0.0") + " Ha"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: "#581c87"  // Púrpura más oscuro
                                    }
                                }
                            }
                            
                            ScrollView {
                                width: parent.width
                                height: isMobile ? 60 : 80
                                clip: true
                                
                                Column {
                                    width: parent.width
                                    spacing: 2
                                    
                                    Repeater {
                                        model: modelDisponible ? dashboardModel.listaCiclos : []
                                        
                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 18
                                            color: "transparent"
                                            
                                            Row {
                                                width: parent.width
                                                spacing: 6
                                                anchors.verticalCenter: parent.verticalCenter
                                                
                                                Text {
                                                    text: "• " + modelData.name
                                                    font.pixelSize: 10
                                                    color: "#6b21a8"  // Púrpura oscuro
                                                    width: parent.width * 0.7
                                                    elide: Text.ElideRight
                                                }
                                                
                                                Text {
                                                    text: modelData.area
                                                    font.pixelSize: 10
                                                    color: "#7e22ce"  // Púrpura medio
                                                    width:parent.width * 0.3
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
                
                // SEGUNDA FILA DE MÉTRICAS - ANCHO COMPLETO
                Grid {
                    width: parent.width - (isMobile ? 20 : 40)  // Ajustar para el padding
                    columns: isMobile ? 1 : 3
                    rowSpacing: 12
                    columnSpacing: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    // Tarjeta Ventas - COLOR AMARILLO CLARO
                    Rectangle {
                        width: isMobile ? parent.width : (parent.width - 24) / 3
                        height: isMobile ? 160 : 180
                        color: "#fef9c3"  // Amarillo muy claro
                        radius: 8
                        border.color: "#fef08a"
                        border.width: 1
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 10
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#f59e0b" }
                                        GradientStop { position: 1.0; color: "#fbbf24" }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "💰"
                                        font.pixelSize: 20
                                    }
                                }
                                
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    
                                    Text {
                                        text: "Ventas Actuales"
                                        font.pixelSize: 13
                                        color: "#854d0e"  // Amarillo oscuro para contraste
                                    }
                                    
                                    Text {
                                        text: formatearMoneda(modelDisponible ? dashboardModel.ventasTotales : 0)
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: "#713f12"  // Amarillo más oscuro
                                    }
                                }
                            }
                            
                            ScrollView {
                                width: parent.width
                                height: isMobile ? 60 : 80
                                clip: true
                                
                                Column {
                                    width: parent.width
                                    spacing: 2
                                    
                                    Repeater {
                                        model: modelDisponible ? dashboardModel.listaVentas : []
                                        
                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 18
                                            color: "transparent"
                                            
                                            Row {
                                                width: parent.width
                                                spacing: 6
                                                anchors.verticalCenter: parent.verticalCenter
                                                
                                                Text {
                                                    text: "• " + modelData.product
                                                    font.pixelSize: 10
                                                    color: "#854d0e"  // Amarillo oscuro
                                                    width: parent.width * 0.7
                                                    elide: Text.ElideRight
                                                }
                                                
                                                Text {
                                                    text: modelData.amount
                                                    font.pixelSize: 10
                                                    color: "#a16207"  // Amarillo medio
                                                    width: parent.width * 0.3
                                                    horizontalAlignment: Text.AlignRight
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Tarjeta Próximas Cosechas - COLOR CELESTE CLARO
                    Rectangle {
                        width: isMobile ? parent.width : (parent.width - 24) / 3
                        height: isMobile ? 160 : 180
                        color: "#e0f2fe"  // Celeste muy claro
                        radius: 8
                        border.color: "#bae6fd"
                        border.width: 1
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 10
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#0ea5e9" }
                                        GradientStop { position: 1.0; color: "#3b82f6" }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "📦"
                                        font.pixelSize: 20
                                    }
                                }
                                
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    
                                    Text {
                                        text: "Próximas Cosechas"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: "#1e40af"  // Azul oscuro
                                    }
                                    
                                    Text {
                                        text: (modelDisponible ? dashboardModel.proximasCosechas : "0") + " en 30 días"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: "#1e3a8a"  // Azul más oscuro
                                    }
                                }
                            }
                            
                            ScrollView {
                                width: parent.width
                                height: isMobile ? 60 : 80
                                clip: true
                                
                                Column {
                                    width: parent.width
                                    spacing: 2
                                    
                                    Repeater {
                                        model: modelDisponible ? dashboardModel.listaCosechas : []
                                        
                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 18
                                            color: "transparent"
                                            
                                            Row {
                                                width: parent.width
                                                spacing: 6
                                                anchors.verticalCenter: parent.verticalCenter
                                                
                                                Text {
                                                    text: "• " + modelData.name
                                                    font.pixelSize: 10
                                                    font.weight: Font.Medium
                                                    color: "#1e40af"  // Azul oscuro
                                                    width: parent.width * 0.6
                                                    elide: Text.ElideRight
                                                }
                                                
                                                Text {
                                                    text: modelData.quantity
                                                    font.pixelSize: 10
                                                    color: "#3b82f6"  // Azul medio
                                                    width: parent.width * 0.4
                                                    horizontalAlignment: Text.AlignRight
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Tarjeta Alerta - COLOR ROSA CLARO
                    Rectangle {
                        width: isMobile ? parent.width : (parent.width - 24) / 3
                        height: isMobile ? 160 : 180
                        color: "#ffe4e6"  // Rosa muy claro
                        radius: 8
                        border.color: "#fecdd3"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 10
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#ef4444" }
                                        GradientStop { position: 1.0; color: "#f97316" }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🔔"
                                        font.pixelSize: 20
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Alertas Mantenimientos"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: "#991b1b"  // Rojo oscuro para contraste
                                    }

                                    Text {
                                        text: getTotalAlertasCompleto() + " alertas"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: "#7f1d1d"  // Rojo más oscuro
                                    }
                                }
                            }

                            ScrollView {
                                width: parent.width
                                height: isMobile ? 80 : 100
                                clip: true

                                Column {
                                    width: parent.width
                                    spacing: 4

                                    // Mostrar alertas del sistema
                                    Repeater {
                                        model: modelDisponible ? dashboardModel.listaAlertas : []

                                        // En la tarjeta de alertas, dentro del Repeater que muestra las alertas del sistema
                                        Rectangle {
                                            width: parent.width
                                            height: 18
                                            color: "transparent"

                                            Row {
                                                width: parent.width
                                                spacing: 6
                                                anchors.verticalCenter: parent.verticalCenter

                                                Rectangle {
                                                    width: 12
                                                    height: 12
                                                    radius: 6
                                                    color: "#fef3c7"  // Color amarillo para mantenimiento
                                                    anchors.verticalCenter: parent.verticalCenter

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "🔧"  // Ícono de mantenimiento
                                                        font.pixelSize: 8
                                                        font.weight: Font.Bold
                                                        color: "#d97706"
                                                    }
                                                }

                                                Text {
                                                    text: modelData
                                                    font.pixelSize: 10
                                                    color: "#991b1b"  // Rojo oscuro
                                                    width: parent.width - 18
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }
                                    }

                                    // Mensaje cuando no hay alertas
                                    Rectangle {
                                        width: parent.width
                                        height: 18
                                        color: "transparent"
                                        visible: (!modelDisponible || dashboardModel.listaAlertas.length === 0)

                                        Text {
                                            text: "No hay alertas activas - Todo en orden"
                                            font.pixelSize: 10
                                            color: "#dc2626"  // Rojo medio
                                            font.italic: true
                                            anchors.centerIn: parent
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // SECCIÓN DE GRÁFICAS DE TENDENCIAS - ANCHO COMPLETO
                Rectangle {
                    width: parent.width - (isMobile ? 20 : 40)  // Ajustar para el padding
                    height: childrenRect.height
                    color: "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Column {
                        width: parent.width
                        spacing: 16
                        
                        // Título de la sección
                        Text {
                            text: "📈 Análisis de Tendencias Anuales"
                            font.pixelSize: isMobile ? 18 : 20
                            font.weight: Font.Bold
                            color: "#1e293b"
                        }
                        
                        Text {
                            text: "Evolución de la producción y ventas a lo largo del tiempo"
                            font.pixelSize: isMobile ? 12 : 14
                            color: "#64748b"
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        
                        // Grid de gráficas - ANCHO COMPLETO
                        Grid {
                            width: parent.width
                            columns: isMobile ? 1 : 2
                            rowSpacing: 16
                            columnSpacing: 16
                            
                            // Gráfica de Tendencia de Producción
                            Rectangle {
                                width: isMobile ? parent.width : (parent.width - 16) / 2
                                height: isMobile ? 350 : 380
                                color: "white"
                                radius: 12
                                border.color: "#e2e8f0"
                                border.width: 1
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12
                                    
                                    Text {
                                        text: "🌾 Tendencia de Producción"
                                        font.pixelSize: isMobile ? 16 : 18
                                        font.weight: Font.Bold
                                        color: "#1e293b"
                                    }
                                    
                                    Text {
                                        text: "Unidades en toneladas"
                                        font.pixelSize: 12
                                        color: "#64748b"
                                    }
                                    
                                    // Gráfica de líneas para producción
                                    Item {
                                        width: parent.width
                                        height: Math.max(parent.height - 120, 200)
                                        
                                        Canvas {
                                            id: produccionCanvas
                                            anchors.fill: parent
                                            
                                            property var datosProcesados: []
                                            
                                            Component.onCompleted: {
                                                console.log("🎨 Canvas Producción creado - Width:", width, "Height:", height);
                                            }
                                            
                                            onWidthChanged: {
                                                if (width > 0 && height > 0) {
                                                    requestPaint();
                                                }
                                            }
                                            
                                            onHeightChanged: {
                                                if (width > 0 && height > 0) {
                                                    requestPaint();
                                                }
                                            }
                                            
                                            onPaint: {
                                                console.log("🖌️ Pintando canvas producción...");
                                                console.log("📊 Datos tendencia producción:", tendenciaProduccionData.length, "series");
                                                
                                                var ctx = getContext("2d");
                                                
                                                if (!ctx) {
                                                    console.error("❌ No se pudo obtener contexto 2D");
                                                    return;
                                                }
                                                
                                                datosProcesados = procesarDatosTendencia(tendenciaProduccionData);
                                                console.log("📈 Datos procesados:", datosProcesados.length, "series");
                                                
                                                dibujarGrafica(ctx, datosProcesados, width, height, false);
                                            }
                                        }

                                        // MouseArea para interactividad - PRODUCCIÓN
                                        MouseArea {
                                            id: tooltipMouseAreaProduccion
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            acceptedButtons: Qt.NoButton
                                            
                                            property var puntoSeleccionado: null
                                            property point mousePos: Qt.point(0, 0)
                                            
                                            onPositionChanged: (mouse) => {
                                                mousePos = Qt.point(mouse.x, mouse.y)
                                                puntoSeleccionado = encontrarPuntoCercano(mouse.x, mouse.y, produccionCanvas.datosProcesados)
                                                produccionCanvas.requestPaint()
                                            }
                                            
                                            onExited: {
                                                puntoSeleccionado = null
                                                produccionCanvas.requestPaint()
                                            }
                                        }

                                        // Tooltip para mostrar valores - PRODUCCIÓN
                                        Rectangle {
                                            id: tooltipProduccion
                                            visible: tooltipMouseAreaProduccion.puntoSeleccionado !== null
                                            width: tooltipContentProduccion.width + 20
                                            height: tooltipContentProduccion.height + 15
                                            color: "white"
                                            border.color: "#cbd5e1"
                                            border.width: 1
                                            radius: 6
                                            x: Math.min(tooltipMouseAreaProduccion.mousePos.x + 10, parent.width - width - 10)
                                            y: Math.max(tooltipMouseAreaProduccion.mousePos.y - height - 10, 10)
                                            z: 10
                                            
                                            Column {
                                                id: tooltipContentProduccion
                                                anchors.centerIn: parent
                                                spacing: 2
                                                padding: 5
                                                
                                                Text {
                                                    text: tooltipMouseAreaProduccion.puntoSeleccionado ? tooltipMouseAreaProduccion.puntoSeleccionado.variedad : ""
                                                    font.bold: true
                                                    font.pixelSize: 12
                                                    color: tooltipMouseAreaProduccion.puntoSeleccionado ? tooltipMouseAreaProduccion.puntoSeleccionado.color : "black"
                                                }
                                                
                                                Text {
                                                    text: tooltipMouseAreaProduccion.puntoSeleccionado ? "Año: " + tooltipMouseAreaProduccion.puntoSeleccionado.anio : ""
                                                    font.pixelSize: 11
                                                    color: "#64748b"
                                                }
                                                
                                                Text {
                                                    text: {
                                                        if (!tooltipMouseAreaProduccion.puntoSeleccionado) return ""
                                                        var valor = tooltipMouseAreaProduccion.puntoSeleccionado.valor
                                                        return "Valor: " + formatearNumero(valor) + " ton"
                                                    }
                                                    font.pixelSize: 11
                                                    color: "#1e293b"
                                                    font.bold: true
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Leyenda de variedades - MODIFICADA PARA USAR LAS NUEVAS FUNCIONES
                                    Flow {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Repeater {
                                            model: tendenciaProduccionData
                                            
                                            delegate: MouseArea {
                                                width: legendRowProduccion.width + 8
                                                height: legendRowProduccion.height + 4
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                
                                                onClicked: {
                                                    // Usar la nueva función para cambiar visibilidad
                                                    toggleProduccionVisibility(modelData.variedad)
                                                }
                                                
                                                Row {
                                                    id: legendRowProduccion
                                                    spacing: 6
                                                    anchors.centerIn: parent
                                                    
                                                    Rectangle {
                                                        width: 16
                                                        height: 16
                                                        radius: 4
                                                        color: modelData.color
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        border.color: modelData.visible ? "#1e293b" : "#94a3b8"
                                                        border.width: modelData.visible ? 2 : 1
                                                        
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: modelData.visible ? "✓" : "✗"
                                                            font.pixelSize: 8
                                                            font.weight: Font.Bold
                                                            color: modelData.visible ? "white" : "#94a3b8"
                                                        }
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.variedad
                                                        font.pixelSize: 10
                                                        color: modelData.visible ? "#64748b" : "#94a3b8"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        font.strikeout: !modelData.visible
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Gráfica de Tendencia de Ventas
                            Rectangle {
                                width: isMobile ? parent.width : (parent.width - 16) / 2
                                height: isMobile ? 350 : 380
                                color: "white"
                                radius: 12
                                border.color: "#e2e8f0"
                                border.width: 1
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12
                                    
                                    Text {
                                        text: "💰 Tendencia de Ventas"
                                        font.pixelSize: isMobile ? 16 : 18
                                        font.weight: Font.Bold
                                        color: "#1e293b"
                                    }
                                    
                                    Text {
                                        text: "Unidades en Bolivianos (Bs)"
                                        font.pixelSize: 12
                                        color: "#64748b"
                                    }
                                    
                                    // Gráfica de líneas para ventas
                                    Item {
                                        width: parent.width
                                        height: Math.max(parent.height - 120, 200)
                                        
                                        Canvas {
                                            id: ventasCanvas
                                            anchors.fill: parent
                                            
                                            property var datosProcesados: []
                                            
                                            Component.onCompleted: {
                                                console.log("🎨 Canvas Ventas creado - Width:", width, "Height:", height);
                                            }
                                            
                                            onWidthChanged: {
                                                if (width > 0 && height > 0) {
                                                    requestPaint();
                                                }
                                            }
                                            
                                            onHeightChanged: {
                                                if (width > 0 && height > 0) {
                                                    requestPaint();
                                                }
                                            }
                                            
                                            onPaint: {
                                                console.log("🖌️ Pintando canvas ventas...");
                                                console.log("💰 Datos tendencia ventas:", tendenciaVentasData.length, "series");
                                                
                                                var ctx = getContext("2d");
                                                
                                                if (!ctx) {
                                                    console.error("❌ No se pudo obtener contexto 2D");
                                                    return;
                                                }
                                                
                                                datosProcesados = procesarDatosTendencia(tendenciaVentasData);
                                                console.log("💵 Datos procesados:", datosProcesados.length, "series");
                                                
                                                dibujarGrafica(ctx, datosProcesados, width, height, true);
                                            }
                                        }

                                        // MouseArea para interactividad - VENTAS
                                        MouseArea {
                                            id: tooltipMouseAreaVentas
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            acceptedButtons: Qt.NoButton
                                            
                                            property var puntoSeleccionado: null
                                            property point mousePos: Qt.point(0, 0)
                                            
                                            onPositionChanged: (mouse) => {
                                                mousePos = Qt.point(mouse.x, mouse.y)
                                                puntoSeleccionado = encontrarPuntoCercano(mouse.x, mouse.y, ventasCanvas.datosProcesados)
                                                ventasCanvas.requestPaint()
                                            }
                                            
                                            onExited: {
                                                puntoSeleccionado = null
                                                ventasCanvas.requestPaint()
                                            }
                                        }

                                        // Tooltip para mostrar valores - VENTAS
                                        Rectangle {
                                            id: tooltipVentas
                                            visible: tooltipMouseAreaVentas.puntoSeleccionado !== null
                                            width: tooltipContentVentas.width + 20
                                            height: tooltipContentVentas.height + 15
                                            color: "white"
                                            border.color: "#cbd5e1"
                                            border.width: 1
                                            radius: 6
                                            x: Math.min(tooltipMouseAreaVentas.mousePos.x + 10, parent.width - width - 10)
                                            y: Math.max(tooltipMouseAreaVentas.mousePos.y - height - 10, 10)
                                            z: 10
                                            
                                            Column {
                                                id: tooltipContentVentas
                                                anchors.centerIn: parent
                                                spacing: 2
                                                padding: 5
                                                
                                                Text {
                                                    text: tooltipMouseAreaVentas.puntoSeleccionado ? tooltipMouseAreaVentas.puntoSeleccionado.variedad : ""
                                                    font.bold: true
                                                    font.pixelSize: 12
                                                    color: tooltipMouseAreaVentas.puntoSeleccionado ? tooltipMouseAreaVentas.puntoSeleccionado.color : "black"
                                                }
                                                
                                                Text {
                                                    text: tooltipMouseAreaVentas.puntoSeleccionado ? "Año: " + tooltipMouseAreaVentas.puntoSeleccionado.anio : ""
                                                    font.pixelSize: 11
                                                    color: "#64748b"
                                                }
                                                
                                                Text {
                                                    text: {
                                                        if (!tooltipMouseAreaVentas.puntoSeleccionado) return ""
                                                        var valor = tooltipMouseAreaVentas.puntoSeleccionado.valor
                                                        return "Valor: " + formatearMoneda(valor)
                                                    }
                                                    font.pixelSize: 11
                                                    color: "#1e293b"
                                                    font.bold: true
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Leyenda de variedades - MODIFICADA PARA USAR LAS NUEVAS FUNCIONES
                                    Flow {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Repeater {
                                            model: tendenciaVentasData
                                            
                                            delegate: MouseArea {
                                                width: legendRowVentas.width + 8
                                                height: legendRowVentas.height + 4
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                
                                                onClicked: {
                                                    // Usar la nueva función para cambiar visibilidad
                                                    toggleVentasVisibility(modelData.variedad)
                                                }
                                                
                                                Row {
                                                    id: legendRowVentas
                                                    spacing: 6
                                                    anchors.centerIn: parent
                                                    
                                                    Rectangle {
                                                        width: 16
                                                        height: 16
                                                        radius: 4
                                                        color: modelData.color
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        border.color: modelData.visible ? "#1e293b" : "#94a3b8"
                                                        border.width: modelData.visible ? 2 : 1
                                                        
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: modelData.visible ? "✓" : "✗"
                                                            font.pixelSize: 8
                                                            font.weight: Font.Bold
                                                            color: modelData.visible ? "white" : "#94a3b8"
                                                        }
                                                    }
                                                    
                                                    Text {
                                                        text: modelData.variedad
                                                        font.pixelSize: 10
                                                        color: modelData.visible ? "#64748b" : "#94a3b8"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        font.strikeout: !modelData.visible
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Resumen de estadísticas anuales - ANCHO COMPLETO
                        Grid {
                            width: parent.width
                            columns: isMobile ? 1 : 3
                            rowSpacing: 12
                            columnSpacing: 12
                            
                            // Estadística: Crecimiento Producción - COLOR AZUL CLARO
                            Rectangle {
                                width: isMobile ? parent.width : (parent.width - 24) / 3
                                height: 120
                                color: "#e0f2fe"  // Azul muy claro
                                radius: 8
                                border.color: "#bae6fd"
                                border.width: 1
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    
                                    Text {
                                        text: "📈 Crecimiento Producción"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: "#1e40af"  // Azul oscuro
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: modelDisponible ? dashboardModel.crecimientoProduccion.toFixed(1) + "%" : "0%"
                                        font.pixelSize: 24
                                        font.weight: Font.Bold
                                        color: {
                                            if (!modelDisponible) return "#1e40af";
                                            return dashboardModel.crecimientoProduccion >= 0 ? "#166534" : "#dc2626"; // Verde o rojo
                                        }
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "vs año anterior"
                                        font.pixelSize: 10
                                        color: "#1e40af"  // Azul oscuro
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            // Estadística: Crecimiento Ventas - COLOR VERDE CLARO
                            Rectangle {
                                width: isMobile ? parent.width : (parent.width - 24) / 3
                                height: 120
                                color: "#dcfce7"  // Verde muy claro
                                radius: 8
                                border.color: "#bbf7d0"
                                border.width: 1
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    
                                    Text {
                                        text: "💹 Crecimiento Ventas"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: "#166534"  // Verde oscuro
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: modelDisponible ? dashboardModel.crecimientoVentas.toFixed(1) + "%" : "0%"
                                        font.pixelSize: 24
                                        font.weight: Font.Bold
                                        color: {
                                            if (!modelDisponible) return "#166534";
                                            return dashboardModel.crecimientoVentas >= 0 ? "#166534" : "#dc2626"; // Verde o rojo
                                        }
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "vs año anterior"
                                        font.pixelSize: 10
                                        color: "#166534"  // Verde oscuro
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            // Estadística: Años de Operación - COLOR LILA CLARO
                            Rectangle {
                                width: isMobile ? parent.width : (parent.width - 24) / 3
                                height: 120
                                color: "#f3e8ff"  // Lila muy claro
                                radius: 8
                                border.color: "#e9d5ff"
                                border.width: 1
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    
                                    Text {
                                        text: "🏭 Años de Operación"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: "#6b21a8"  // Púrpura oscuro
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: modelDisponible ? dashboardModel.anosOperacion : "0"
                                        font.pixelSize: 24
                                        font.weight: Font.Bold
                                        color: "#6b21a8"  // Púrpura oscuro
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "años en funcionamiento"
                                        font.pixelSize: 10
                                        color: "#6b21a8"  // Púrpura oscuro
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Footer
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: modelDisponible ? "#10b981" : "#ef4444"
                    }
                    
                    Text {
                        text: modelDisponible ? "Conectado - Datos en tiempo real" : "Error de conexión"
                        font.pixelSize: isMobile ? 10 : 12
                        color: modelDisponible ? "#10b981" : "#ef4444"
                        font.weight: Font.Medium
                    }
                }
            }
            
            Item {
                width: parent.width
                height: 20
            }
        }
    }
    
    // Timer para inicialización
    Timer {
        id: initTimer
        interval: 100
        repeat: false
        onTriggered: verificarModelo()
    }
    
    Component.onCompleted: {
        console.log("🚀 Dashboard inicializado");
        console.log("📱 Dispositivo: isMobile =", isMobile, "| isTablet =", isTablet, "| isDesktop =", isDesktop);
        initTimer.start();
    }
}