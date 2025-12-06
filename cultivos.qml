import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15 
import "." as Local 
import "./components"


Rectangle {
    id: cultivosRoot
    anchors.fill: parent
    color: "#F8F9FA"

    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Tipos de Cultivo", "icon": "recursos/image/icons/tiposcultivo.png", "color": "#2E7D32"},
        {"text": "Variedades", "icon": "recursos/image/icons/variedades.png", "color": "#F57C00"},
        {"text": "Ciclos de Producción", "icon": "recursos/image/icons/cicloproduccion.png", "color": "#0288D1"},
        {"text": "Calendario de Cultivos", "icon": "recursos/image/icons/calendariocultivo.png", "color": "#9C27B0"}
    ]

    // Paginación para tipos de cultivo
    property int paginaActualTipos: 1
    property int totalPaginasTipos: 1
    property int tiposPorPagina: 6

    // Paginación para variedades
    property int paginaActualVariedades: 1
    property int totalPaginasVariedades: 1
    property int variedadesPorPagina: 8

    // Paginación para ciclos de producción
    property int paginaActualCiclos: 1
    property int totalPaginasCiclos: 1
    property int ciclosPorPagina: 10

    // Estados para edición
    property bool mostrarFilaEdicionTipo: false
    property var nuevoTipoCultivo: ({})
    property var nuevaVariedad: ({})
    property int tipoId: 0
    property int variedadId: 0
    property int cicloId: 0

    // Variables para filtros
    property bool filtrandoTexto: false
    property bool filtrandoEstado: false

    // Variables para el calendario
    property date fechaActual: new Date()
    property var eventosPorFecha: ({})

    Timer {
        id: calendarioTimer
        interval: 1000 // 1 segundo de espera
        repeat: false
        onTriggered: {
            console.log("Actualizando calendario después de cargar datos...")
            actualizarCalendarioAnual()
        }
    }

    // FUNCIONES

    // Función para formatear la fecha actual
    function getFormattedDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
    }

    // Función para obtener el nombre del mes
    function obtenerNombreMes(mes) {
        var meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
        return meses[mes];
    }

    // Función para obtener eventos para un día específico
    function getEventsForDay(day, month, year) {
        if (day <= 0) return [];
        
        // Filtrar por tipo de cultivo si está seleccionado
        const filtroTipo = filterCultivos.cmbFiltroCultivosCalendario > 0 ? 
                        cultivosFiltroModel.get(filterCultivos.cmbFiltroCultivosCalendario).text : null;
        
        const key = year + "-" + (month + 1) + "-" + day;
        
        // Si no tenemos eventos para este día, devolver un array vacío
        if (!eventosPorFecha[key]) {
            return [];
        }
        
        // Si hay un filtro de tipo, filtrar los eventos
        if (filtroTipo && filtroTipo !== "Todos los cultivos") {
            return eventosPorFecha[key].filter(function(evento) {
                return evento.text.includes(filtroTipo);
            });
        } else {
            return eventosPorFecha[key];
        }
    }

    // Función para actualizar el filtro de cultivos
    function actualizarCultivosFiltro() {
        console.log("=== DEBUG: actualizarCultivosFiltro INICIADO ===")
        console.log("- ciclosModel.count:", ciclosModel.count)
        
        // Preservar selección actual si existe
        const seleccionActual = filterCultivos.cmbFiltroCultivosCalendario > 0 ? cultivosFiltroModel.get(filterCultivos.cmbFiltroCultivosCalendario).text : null;
        
        // Limpiar modelo excepto el primer elemento
        while (cultivosFiltroModel.count > 1) {
            cultivosFiltroModel.remove(1);
        }
        
        console.log("=== DEBUG: Modelo limpiado, count actual:", cultivosFiltroModel.count)
        
        // Recopilar todos los tipos de cultivo usados en ciclos
        const tiposUsados = new Set();
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i);
            console.log("- DEBUG: Procesando ciclo", i, "- activo:", ciclo.activo, "- tipo:", ciclo.nombre_tipo_cultivo)
            if (ciclo.activo) {
                tiposUsados.add(ciclo.nombre_tipo_cultivo);
                console.log("  - Tipo añadido:", ciclo.nombre_tipo_cultivo)
            }
        }
        
        console.log("=== DEBUG: Tipos únicos encontrados:", Array.from(tiposUsados))
        console.log("=== DEBUG: Número de tipos únicos:", tiposUsados.size)
        
        // Añadir tipos usados al modelo
        var tiposArray = Array.from(tiposUsados);
        for (let i = 0; i < tiposArray.length; i++) {
            let nombreTipo = tiposArray[i];
            console.log("- DEBUG: Añadiendo al modelo:", nombreTipo)
            cultivosFiltroModel.append({
                text: nombreTipo,
                value: nombreTipo
            });
        }
        
        console.log("=== DEBUG: cultivosFiltroModel.count final:", cultivosFiltroModel.count)
        
        // Restaurar selección si posible
        if (seleccionActual) {
            console.log("=== DEBUG: Restaurando selección:", seleccionActual)
            for (let i = 0; i < cultivosFiltroModel.count; i++) {
                if (cultivosFiltroModel.get(i).text === seleccionActual) {
                    filterCultivos.cmbFiltroCultivosCalendario = i;
                    console.log("- DEBUG: Selección restaurada en índice:", i)
                    break;
                }
            }
        } else {
            console.log("=== DEBUG: No hay selección previa para restaurar")
        }
        
        console.log("=== DEBUG: actualizarCultivosFiltro FINALIZADO ===")
    }

    // Función para actualizar el combobox de tipos
    function actualizarTiposCombobox() {
        tiposVariedadModel.clear();
        
        for (let i = 0; i < tiposCultivoModel.count; i++) {
            const tipo = tiposCultivoModel.get(i);
            if (tipo.activo) {
                tiposVariedadModel.append({
                    text: tipo.nombre,
                    value: tipo.id_tipo_cultivo
                });
            }
        }
        
        // Seleccionar el primero si hay elementos
        if (tiposVariedadModel.count > 0) {
            cmbTipoCultivo.currentIndex = 0;
        }
    }

    function actualizarParcelasCombobox() {
        parcelasModel.clear();
        
        // Opción por defecto
        parcelasModel.append({"text": "Seleccione una parcela", "value": 0});
        
        try {
            // Verifica si la función existe antes de llamarla
            if (typeof cultivos.obtener_parcelas_activas === "function") {
                const parcelas = cultivos.obtener_parcelas_activas() || [];
                for (let i = 0; i < parcelas.length; i++) {
                    parcelasModel.append({
                        "text": parcelas[i].nombre,
                        "value": parcelas[i].id_parcela
                    });
                }
            } else {
                console.log("Error: obtener_parcelas_activas no está disponible");
                parcelasModel.append({"text": "Parcela 1", "value": 1});
                parcelasModel.append({"text": "Parcela 2", "value": 2});
            }
        } catch(e) {
            console.error("Error al cargar parcelas:", e);
        }
    }

    function cargarTiposCultivo() {
        console.log("Cargando tipos de cultivo con paginación...")
        
        var datosPagina = cultivos.obtener_tipos_cultivo_paginado(paginaActualTipos, tiposPorPagina)
        
        tiposCultivoModel.clear()
        
        if (datosPagina && datosPagina.tipos_cultivo) {
            var tipos = datosPagina.tipos_cultivo
            for (let i = 0; i < tipos.length; i++) {
                let tipo = tipos[i]
                tiposCultivoModel.append({
                    id_tipo_cultivo: tipo.id_tipo_cultivo,
                    nombre: tipo.nombre,
                    nombre_cientifico: tipo.nombre_cientifico || "",
                    tiempo_cosecha_min: tipo.tiempo_cosecha_min || 0,
                    tiempo_cosecha_max: tipo.tiempo_cosecha_max || 0,
                    descripcion: tipo.descripcion || "",
                    activo: tipo.activo
                })
            }
            
            // Actualizar información de paginación
            totalPaginasTipos = datosPagina.total_paginas || 1
            paginaActualTipos = datosPagina.pagina_actual || 1
            
            console.log(`Tipos cargados: ${tipos.length}, Página: ${paginaActualTipos}/${totalPaginasTipos}`)
        }
    }

    // Actualizar el modelo de variedades
    function cargarVariedades() {
        console.log("Cargando variedades con paginación...")
        
        var datosPagina = cultivos.obtener_variedades_paginado(paginaActualVariedades, variedadesPorPagina)
        
        variedadesModel.clear()
        
        if (datosPagina && datosPagina.variedades) {
            var variedades = datosPagina.variedades
            for (let i = 0; i < variedades.length; i++) {
                variedadesModel.append({
                    id_variedad: variedades[i].id_variedad,
                    id_tipo_cultivo: variedades[i].id_tipo_cultivo,
                    nombre: variedades[i].nombre,
                    tiempo_produccion: variedades[i].tiempo_produccion,
                    resistencia_zona: variedades[i].resistencia_zona,
                    activo: variedades[i].activo,
                    nombre_tipo_cultivo: variedades[i].nombre_tipo_cultivo
                })
            }
            
            totalPaginasVariedades = datosPagina.total_paginas || 1
            paginaActualVariedades = datosPagina.pagina_actual || 1
            
            console.log(`Variedades cargadas: ${variedades.length}, Página: ${paginaActualVariedades}/${totalPaginasVariedades}`)
        }
        
        actualizarTiposFiltro()
        actualizarTiposCombobox()
    }

    // Función para actualizar el combobox de variedades
    function actualizarVariedadesCombobox() {
        variedadesCicloModel.clear();
        
        for (let i = 0; i < variedadesModel.count; i++) {
            const variedad = variedadesModel.get(i);
            if (variedad.activo) {
                variedadesCicloModel.append({
                    text: variedad.nombre + " (" + variedad.nombre_tipo_cultivo + ")",
                    value: variedad.id_variedad
                });
            }
        }
        
        // Seleccionar el primero si hay elementos
        if (variedadesCicloModel.count > 0) {
            cmbVariedades.currentIndex = 0;
        }
    }

    // Función para obtener el color correspondiente a una resistencia
    function getResistenciaColor(resistencia) {
        switch (resistencia) {
            case "Alta": return "#4CAF50"; // Verde
            case "Media": return "#FF9800"; // Naranja
            case "Baja": return "#F44336"; // Rojo
            default: return "#FF9800"; // Naranja (por defecto)
        }
    }

    // Función para actualizar el calendario
    function actualizarCalendario() {
        try {
            // Asegurarse de que fechaActual es una fecha válida
            if (!(fechaActual instanceof Date) || isNaN(fechaActual.getTime())) {
                fechaActual = new Date(); // Restablecer a fecha actual si es inválida
            }
                
            // Calcular el primer día del mes
            var primerDia = new Date(fechaActual.getFullYear(), fechaActual.getMonth(), 1);
            var diaSemana = primerDia.getDay();
            if (diaSemana === 0) diaSemana = 7; // Domingo es 0, lo convertimos a 7
            diaSemana--; // Ajustamos para que lunes sea 0
                
            // Calcular el número de días en el mes actual
            var ultimoDia = new Date(fechaActual.getFullYear(), fechaActual.getMonth() + 1, 0);
            var diasEnMes = ultimoDia.getDate();
                
            // Obtener la fecha actual real
            var hoy = new Date();
                
            // Actualizar las celdas del calendario
            if (typeof calendarRepeater !== "undefined" && calendarRepeater) {
                for (var i = 0; i < 42; i++) {
                    var celda = calendarRepeater.itemAt(i);
                    if (celda) {
                        var diaMes = i - diaSemana;
                        celda.diaNumero = diaMes > 0 && diaMes <= diasEnMes ? diaMes : 0;
                        celda.esDiaMesActual = diaMes > 0 && diaMes <= diasEnMes;
                        celda.esDiaActual = celda.esDiaMesActual && 
                                        fechaActual.getMonth() === hoy.getMonth() && 
                                        fechaActual.getFullYear() === hoy.getFullYear() && 
                                        diaMes === hoy.getDate();
                    }
                }
                
                // Actualizar el texto que muestra el mes y año actual
                if (typeof txtFechaActual !== "undefined" && txtFechaActual) {
                    txtFechaActual.text = obtenerNombreMes(fechaActual.getMonth()) + " " + fechaActual.getFullYear();
                }
            }
                
            // Actualizar eventos del calendario
            cargarEventosCalendario();
            
            // Si estamos en el calendario anual, usar esa función
            if (typeof monthsRepeater !== "undefined" && monthsRepeater) {
                actualizarCalendarioAnual();
            }
        } catch (e) {
            console.error("Error al actualizar calendario:", e);
        }
    }

    // Función para cargar eventos del calendario desde los ciclos
    function cargarEventosCalendario() {
        console.log("=== DEBUG: cargarEventosCalendario INICIADO ===")
        console.log("- ciclosModel.count:", ciclosModel.count)
        
        // Si hay filtros activos, usar la versión con filtros
        if (filterCultivos.cmbFiltroCultivosCalendario > 0 ||
            filterEstados.currentIndex > 0 ||
            filterParcelas.currentIndex > 0 ||
            filterTipoEvento.currentIndex > 0) {
            console.log("=== DEBUG: Usando cargarEventosCalendarioConFiltros ===")
            cargarEventosCalendarioConFiltros();
            return;
        }
        
        console.log("=== DEBUG: Cargando eventos sin filtros ===")
        
        eventosPorFecha = {}
        
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i)
            console.log("- DEBUG: Procesando ciclo", i, "- ID:", ciclo.id_ciclo, "- activo:", ciclo.activo, "- variedad:", ciclo.nombre_variedad)
            if (!ciclo.activo) continue
            
            // Añadir evento de siembra
            if (ciclo.fecha_siembra && ciclo.fecha_siembra !== "") {
                console.log("  - DEBUG: Procesando fecha_siembra:", ciclo.fecha_siembra)
                const fechaSiembra = parseDBDate(ciclo.fecha_siembra)
                if (fechaSiembra) {
                    const key = fechaSiembra.getFullYear() + "-" + (fechaSiembra.getMonth() + 1) + "-" + fechaSiembra.getDate()
                    console.log("    - DEBUG: Fecha siembra parseada - key:", key)
                    if (!eventosPorFecha[key]) eventosPorFecha[key] = []
                    eventosPorFecha[key].push({
                        text: "Siembra " + ciclo.nombre_variedad,
                        color: "#2E7D32"
                    })
                    console.log("    - DEBUG: Evento siembra añadido")
                } else {
                    console.log("    - DEBUG: ERROR parseando fecha_siembra")
                }
            }
            
            // Añadir evento de cosecha estimada
            if (ciclo.fecha_cosecha_estimada && ciclo.fecha_cosecha_estimada !== "") {
                console.log("  - DEBUG: Procesando fecha_cosecha_estimada:", ciclo.fecha_cosecha_estimada)
                const fechaCosecha = parseDBDate(ciclo.fecha_cosecha_estimada)
                if (fechaCosecha) {
                    const key = fechaCosecha.getFullYear() + "-" + (fechaCosecha.getMonth() + 1) + "-" + fechaCosecha.getDate()
                    console.log("    - DEBUG: Fecha cosecha parseada - key:", key)
                    if (!eventosPorFecha[key]) eventosPorFecha[key] = []
                    eventosPorFecha[key].push({
                        text: "Cosecha " + ciclo.nombre_variedad,
                        color: "#FF9800"
                    })
                    console.log("    - DEBUG: Evento cosecha añadido")
                } else {
                    console.log("    - DEBUG: ERROR parseando fecha_cosecha_estimada")
                }
            }
            
            // Añadir evento de poda
            if (ciclo.fecha_poda && ciclo.fecha_poda !== "") {
                console.log("  - DEBUG: Procesando fecha_poda:", ciclo.fecha_poda)
                const fechaPoda = parseDBDate(ciclo.fecha_poda)
                if (fechaPoda) {
                    const key = fechaPoda.getFullYear() + "-" + (fechaPoda.getMonth() + 1) + "-" + fechaPoda.getDate()
                    console.log("    - DEBUG: Fecha poda parseada - key:", key)
                    if (!eventosPorFecha[key]) eventosPorFecha[key] = []
                    eventosPorFecha[key].push({
                        text: "Poda " + ciclo.nombre_variedad,
                        color: "#9C27B0"
                    })
                    console.log("    - DEBUG: Evento poda añadido")
                } else {
                    console.log("    - DEBUG: ERROR parseando fecha_poda")
                }
            }
            
            // Añadir evento de floración
            if (ciclo.fecha_floracion && ciclo.fecha_floracion !== "") {
                console.log("  - DEBUG: Procesando fecha_floracion:", ciclo.fecha_floracion)
                const fechaFloracion = parseDBDate(ciclo.fecha_floracion)
                if (fechaFloracion) {
                    const key = fechaFloracion.getFullYear() + "-" + (fechaFloracion.getMonth() + 1) + "-" + fechaFloracion.getDate()
                    console.log("    - DEBUG: Fecha floración parseada - key:", key)
                    if (!eventosPorFecha[key]) eventosPorFecha[key] = []
                    eventosPorFecha[key].push({
                        text: "Floración " + ciclo.nombre_variedad,
                        color: "#2196F3"
                    })
                    console.log("    - DEBUG: Evento floración añadido")
                } else {
                    console.log("    - DEBUG: ERROR parseando fecha_floracion")
                }
            }
            
            // Añadir evento de limpieza
            if (ciclo.fecha_limpieza && ciclo.fecha_limpieza !== "") {
                console.log("  - DEBUG: Procesando fecha_limpieza:", ciclo.fecha_limpieza)
                const fechaLimpieza = parseDBDate(ciclo.fecha_limpieza)
                if (fechaLimpieza) {
                    const key = fechaLimpieza.getFullYear() + "-" + (fechaLimpieza.getMonth() + 1) + "-" + fechaLimpieza.getDate()
                    console.log("    - DEBUG: Fecha limpieza parseada - key:", key)
                    if (!eventosPorFecha[key]) eventosPorFecha[key] = []
                    eventosPorFecha[key].push({
                        text: "Limpieza " + ciclo.nombre_variedad,
                        color: "#795548"
                    })
                    console.log("    - DEBUG: Evento limpieza añadido")
                } else {
                    console.log("    - DEBUG: ERROR parseando fecha_limpieza")
                }
            }
        }
        
        console.log("=== DEBUG: eventosPorFecha keys:", Object.keys(eventosPorFecha))
        console.log("=== DEBUG: Total eventos generados:", Object.keys(eventosPorFecha).length)
        console.log("=== DEBUG: cargarEventosCalendario FINALIZADO ===")
    }

    // Actualizar opciones de tipos para el filtro de variedades
    function actualizarTiposFiltro() {
        // Limpiar modelo excepto el primer elemento
            while (tiposFiltroModel.count > 1) {
                tiposFiltroModel.remove(1);
            }
            
            // Cargar tipos desde el modelo Python para asegurar datos actualizados
            var tipos = cultivos.tipos_cultivo;
            console.log("Actualizando filtros de tipo: " + tipos.length + " tipos disponibles");
            
            // Añadir tipos desde el modelo de tipos de cultivo
            for (let i = 0; i < tipos.length; i++) {
                const tipo = tipos[i];
                if (tipo.activo) {
                    tiposFiltroModel.append({
                        "text": tipo.nombre,
                        "value": tipo.id_tipo_cultivo
                    });
                    console.log("Añadido filtro: " + tipo.nombre + " (ID: " + tipo.id_tipo_cultivo + ")");
                }
            }
    }

    // Función para obtener el índice en el combobox de parcelas a partir del ID
    function getParcelaIndex(id_parcela) {
        for (let i = 0; i < parcelasModel.count; i++) {
            if (parcelasModel.get(i).value === id_parcela) {
                return i;
            }
        }
        return 0; // Por defecto, la primera
    }

    // Función para obtener el índice en el combobox de variedades a partir del ID
    function getVariedadIndex(id_variedad) {
        for (let i = 0; i < variedadesCicloModel.count; i++) {
            if (variedadesCicloModel.get(i).value === id_variedad) {
                return i;
            }
        }
        return 0; // Por defecto, la primera
    }

    // Función para obtener el índice en el combobox de estados a partir del nombre
    function getEstadoIndex(estado) {
        for (let i = 0; i < estadosModel.count; i++) {
            if (estadosModel.get(i).text === estado) {
                return i;
            }
        }
        return 0; // Por defecto, el primero
    }

    // Función para obtener el color del estado
    function getEstadoColor(estado) {
        switch(estado) {
            case "Planificado": return "#2196F3";
            case "En Preparación": return "#FF9800";
            case "Sembrado": return "#4CAF50";
            case "En Desarrollo": return "#8BC34A";
            case "En Cosecha": return "#FFC107";
            case "Finalizado": return "#9E9E9E";
            case "Cancelado": return "#F44336";
            default: return "#2196F3";
        }
    }

    // Función para formatear la fecha en formato DD/MM/YYYY
    function formatDate(dateString) {
        if (!dateString || dateString === "") return "No definida";
        
        // Verificar si ya está en formato DD/MM/YYYY
        if (dateString.includes("/")) return dateString;
        
        // Parsear formato YYYY-MM-DD
        var parts = dateString.split("-");
        if (parts.length === 3) {
            return parts[2].padStart(2, '0') + "/" + parts[1].padStart(2, '0') + "/" + parts[0];
        }
        return dateString;
    }

    // Función para parsear fecha desde la base de datos
    function parseDBDate(dateString) {
        if (!dateString || dateString === "") return null;
        
        try {
            // Formato esperado: YYYY-MM-DD
            var parts = dateString.split("-");
            if (parts.length === 3) {
                var year = parseInt(parts[0]);
                var month = parseInt(parts[1]) - 1; // Los meses empiezan en 0
                var day = parseInt(parts[2]);
                return new Date(year, month, day);
            }
            
            // Si no se puede parsear, retornar null
            return null;
        } catch(e) {
            console.error("Error parseando fecha:", e);
            return null;
        }
    }

    // Función para cargar ciclos de producción
    function cargarCiclosProduccion() {
        console.log("Cargando ciclos de producción con paginación...")
        
        var datosPagina = cultivos.obtener_ciclos_paginado(paginaActualCiclos, ciclosPorPagina)
        
        ciclosModel.clear()
        
        if (datosPagina && datosPagina.ciclos) {
            var ciclos = datosPagina.ciclos
            for (let i = 0; i < ciclos.length; i++) {
                let ciclo = ciclos[i]
                ciclosModel.append({
                    id_ciclo: ciclo.id_ciclo || 0,
                    id_parcela: ciclo.id_parcela || 0,
                    id_variedad: ciclo.id_variedad || 0,
                    fecha_siembra: ciclo.fecha_siembra || "",
                    fecha_cosecha_estimada: ciclo.fecha_cosecha_estimada || "",
                    fecha_cosecha_real: ciclo.fecha_cosecha_real || "",
                    area_sembrada: parseFloat(ciclo.area_sembrada || 0),
                    densidad_siembra: parseInt(ciclo.densidad_siembra || 0),
                    estado: ciclo.estado || "Planificado",
                    activo: Boolean(ciclo.activo),
                    fecha_floracion: ciclo.fecha_floracion || "",
                    fecha_poda: ciclo.fecha_poda || "",
                    fecha_limpieza: ciclo.fecha_limpieza || "",
                    frecuencia_limpieza: parseInt(ciclo.frecuencia_limpieza || 1),
                    nombre_parcela: ciclo.nombre_parcela || "Sin parcela",
                    nombre_variedad: ciclo.nombre_variedad || "Sin variedad",
                    nombre_tipo_cultivo: ciclo.nombre_tipo_cultivo || "Sin tipo"
                })
            }
            
            // Actualizar información de paginación
            totalPaginasCiclos = datosPagina.total_paginas || 1
            paginaActualCiclos = datosPagina.pagina_actual || 1
            
            console.log(`Ciclos cargados: ${ciclos.length}, Página: ${paginaActualCiclos}/${totalPaginasCiclos}`)
            
            // Actualizar filtros y calendario
            actualizarEstadosFiltro()
            actualizarCultivosFiltro()
            actualizarEstadosCalendario()
            actualizarParcelasCalendario()
            cargarEventosCalendario()
            calendarioTimer.restart()
        }
    }

    // Función para actualizar los estados del filtro
    function actualizarEstadosFiltro() {
        // Limpiar modelo excepto el primer elemento
        while (estadosFiltroModel.count > 1) {
            estadosFiltroModel.remove(1);
        }
        
        // Añadir estados únicos de los ciclos
        const estadosUsados = new Set();
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i);
            if (ciclo.activo && ciclo.estado) {
                estadosUsados.add(ciclo.estado);
            }
        }
        
        // Añadir al modelo
        var estadosArray = Array.from(estadosUsados);
        for (let i = 0; i < estadosArray.length; i++) {
            estadosFiltroModel.append({
                text: estadosArray[i],
                value: estadosArray[i]
            });
        }
    }

    // Filtrar tipos de cultivo por texto de búsqueda
    function filtrarTiposCultivo() {
        const textoBusqueda = txtBuscarTipoCultivo.text.toLowerCase().trim();
        
        // Si el texto está vacío, recargar todos
        if (textoBusqueda === "") {
            cargarTiposCultivo();
            return;
        }
        
        // Cargar datos frescos desde el backend
        cultivos.cargar_tipos_cultivo();
        const tiposBackend = cultivos.tipos_cultivo;
        
        // Aplicar filtro
        tiposCultivoModel.clear();
        for (let i = 0; i < tiposBackend.length; i++) {
            const tipo = tiposBackend[i];
            if ((tipo.nombre && tipo.nombre.toLowerCase().includes(textoBusqueda)) ||
                (tipo.nombre_cientifico && tipo.nombre_cientifico.toLowerCase().includes(textoBusqueda)) ||
                (tipo.descripcion && tipo.descripcion.toLowerCase().includes(textoBusqueda))) {
                
                tiposCultivoModel.append({
                    id_tipo_cultivo: tipo.id_tipo_cultivo,
                    nombre: tipo.nombre,
                    nombre_cientifico: tipo.nombre_cientifico || "",
                    tiempo_cosecha_min: tipo.tiempo_cosecha_min || 0,
                    tiempo_cosecha_max: tipo.tiempo_cosecha_max || 0,
                    descripcion: tipo.descripcion || "",
                    activo: Boolean(tipo.activo)
                });
            }
        }
        
        console.log("Filtrado de tipos completado: " + tiposCultivoModel.count + " tipos encontrados");
    }

    // Filtrar variedades por texto de búsqueda
    function filtrarVariedades() {
        const textoBusqueda = txtBuscarVariedad.text.toLowerCase().trim();
        
        // Limpiar filtro de tipo si se está buscando
        if (textoBusqueda !== "") {
            cmbFiltroTipos.currentIndex = 0;
        }
        
        // Si el texto está vacío, recargar todas
        if (textoBusqueda === "") {
            cargarVariedades();
            return;
        }
        
        // Cargar datos frescos desde el backend
        cultivos.cargar_variedades();
        const variedadesBackend = cultivos.variedades;
        
        // Aplicar filtro
        variedadesModel.clear();
        for (let i = 0; i < variedadesBackend.length; i++) {
            const variedad = variedadesBackend[i];
            if ((variedad.nombre && variedad.nombre.toLowerCase().includes(textoBusqueda)) ||
                (variedad.nombre_tipo_cultivo && variedad.nombre_tipo_cultivo.toLowerCase().includes(textoBusqueda)) ||
                (variedad.resistencia_zona && variedad.resistencia_zona.toLowerCase().includes(textoBusqueda))) {
                
                variedadesModel.append({
                    id_variedad: variedad.id_variedad,
                    id_tipo_cultivo: variedad.id_tipo_cultivo,
                    nombre: variedad.nombre,
                    tiempo_produccion: variedad.tiempo_produccion,
                    resistencia_zona: variedad.resistencia_zona,
                    activo: Boolean(variedad.activo),
                    nombre_tipo_cultivo: variedad.nombre_tipo_cultivo || ""
                });
            }
        }
        
        console.log("Filtrado completado: " + variedadesModel.count + " variedades encontradas");
    }

    // Filtrar variedades por tipo de cultivo
    function filtrarVariedadesPorTipo(valorFiltro) {
        console.log("Filtrando por tipo ID: " + valorFiltro);
        
        // Limpiar la búsqueda de texto para evitar conflictos
        txtBuscarVariedad.text = "";
        
        // Si está seleccionado "Todos los tipos", cargar todas las variedades
        if (valorFiltro === 0) {
            cultivos.cargar_variedades();
            cargarVariedades();
            return;
        }
        
        // Obtener variedades filtradas por tipo desde el backend
        cultivos.cargar_variedades_por_tipo(valorFiltro);
        
        // Actualizar el modelo
        variedadesModel.clear();
        const variedades = cultivos.variedades;
        for (let i = 0; i < variedades.length; i++) {
            variedadesModel.append({
                id_variedad: variedades[i].id_variedad,
                id_tipo_cultivo: variedades[i].id_tipo_cultivo,
                nombre: variedades[i].nombre,
                tiempo_produccion: variedades[i].tiempo_produccion,
                resistencia_zona: variedades[i].resistencia_zona,
                activo: variedades[i].activo,
                nombre_tipo_cultivo: variedades[i].nombre_tipo_cultivo
            });
        }
        
        console.log("Después de filtrar por tipo: " + variedadesModel.count + " variedades");
    }

    // Filtrar ciclos por texto de búsqueda
    function filtrarCiclos() {
        // Protección contra recursión
        if (filtrandoTexto) return;
        filtrandoTexto = true;
        
        try {
            const textoBusqueda = txtBuscarCiclo.text.toLowerCase().trim();
            
            // Cargar datos frescos desde el backend sin aplicar filtro de estado
            cultivos.cargar_ciclos_produccion();
            
            // Si no hay texto de búsqueda, mostrar todos
            if (textoBusqueda === "") {
                cargarCiclosProduccion();
                
                // Aplicar filtro de estado si hay uno seleccionado
                if (cmbFiltroEstados.currentIndex > 0) {
                    filtrarCiclosPorEstado();
                }
                return;
            }
            
            // Aplicar filtro por texto
            aplicarFiltroPorTexto(textoBusqueda);
        } finally {
            // Siempre restaurar la bandera
            filtrandoTexto = false;
        }
    }

    // Filtrar ciclos por estado
    function filtrarCiclosPorEstado() {
        // Protección contra recursión
        if (filtrandoEstado) return;
        filtrandoEstado = true;
        
        try {
            // Si está seleccionado "Todos los estados", recargar todos los ciclos
            if (cmbFiltroEstados.currentIndex === 0) {
                cultivos.cargar_ciclos_produccion();
                cargarCiclosProduccion();
                return;
            }
            
            // Obtener estado seleccionado
            const estado = cmbFiltroEstados.model.get(cmbFiltroEstados.currentIndex).text;
            
            // Recargar ciclos desde Python filtrando por estado
            cultivos.cargar_ciclos_por_estado(estado);
            cargarCiclosProduccion();
            
            // Aplicar filtro de texto si es necesario
            if (txtBuscarCiclo.text.trim() !== "") {
                const textoBusqueda = txtBuscarCiclo.text.toLowerCase().trim();
                aplicarFiltroPorTexto(textoBusqueda);
            }
        } finally {
            // Siempre restaurar la bandera
            filtrandoEstado = false;
        }
    }

    function aplicarFiltroPorTexto(textoBusqueda) {
        const ciclosBackend = cultivos.ciclos_produccion;
        
        ciclosModel.clear();
        for (let i = 0; i < ciclosBackend.length; i++) {
            const ciclo = ciclosBackend[i];
            if ((ciclo.nombre_parcela && ciclo.nombre_parcela.toLowerCase().includes(textoBusqueda)) ||
                (ciclo.nombre_variedad && ciclo.nombre_variedad.toLowerCase().includes(textoBusqueda)) ||
                (ciclo.nombre_tipo_cultivo && ciclo.nombre_tipo_cultivo.toLowerCase().includes(textoBusqueda)) ||
                (ciclo.estado && ciclo.estado.toLowerCase().includes(textoBusqueda))) {
                
                ciclosModel.append({
                    id_ciclo: ciclo.id_ciclo || 0,
                    id_parcela: ciclo.id_parcela || 0,
                    id_variedad: ciclo.id_variedad || 0,
                    fecha_siembra: ciclo.fecha_siembra || "",
                    fecha_cosecha_estimada: ciclo.fecha_cosecha_estimada || "",
                    fecha_cosecha_real: ciclo.fecha_cosecha_real || "",
                    area_sembrada: parseFloat(ciclo.area_sembrada || 0),
                    densidad_siembra: parseInt(ciclo.densidad_siembra || 0),
                    estado: ciclo.estado || "Planificado",
                    activo: Boolean(ciclo.activo),
                    fecha_floracion: ciclo.fecha_floracion || "",
                    fecha_poda: ciclo.fecha_poda || "",
                    fecha_limpieza: ciclo.fecha_limpieza || "",
                    frecuencia_limpieza: parseInt(ciclo.frecuencia_limpieza || 1),
                    nombre_parcela: ciclo.nombre_parcela || "Sin parcela",
                    nombre_variedad: ciclo.nombre_variedad || "Sin variedad",
                    nombre_tipo_cultivo: ciclo.nombre_tipo_cultivo || "Sin tipo"
                });
            }
        }
    }

    // Cargar detalles de un tipo de cultivo seleccionado
    function cargarDetallesTipoCultivo(tipo) {
        txtNombreTipo.text = tipo.nombre;
        txtNombreCientifico.text = tipo.nombre_cientifico || "";
        txtTiempoMin.text = (tipo.tiempo_cosecha_min || 0).toString();
        txtTiempoMax.text = (tipo.tiempo_cosecha_max || 0).toString();
        chkActivo.checked = tipo.activo;
        txtDescripcion.text = tipo.descripcion || "";
    }

    // Exportar ciclos a CSV
    function exportarCiclos() {
        let csv = "ID,Parcela,Variedad,Fecha Siembra,Fecha Cosecha Est.,Área (ha),Densidad,Estado\n";
        
        for (let i = 0; i < ciclosModel.count; i++) {
            const c = ciclosModel.get(i);
            csv += `${c.id_ciclo},${c.nombre_parcela},${c.nombre_variedad},${c.fecha_siembra || ""},${c.fecha_cosecha_estimada || ""},${c.area_sembrada},${c.densidad_siembra || 0},${c.estado}\n`;
        }
        
        console.log("Exportar ciclos a CSV:");
        console.log(csv);
        
        showMessage("Datos de ciclos exportados. Revise la consola para ver el resultado.");
    }

    function irPaginaAnteriorTipos() {
        if (paginaActualTipos > 1) {
            paginaActualTipos--
            cargarTiposCultivo()
        }
    }

    function irPaginaSiguienteTipos() {
        if (paginaActualTipos < totalPaginasTipos) {
            paginaActualTipos++
            cargarTiposCultivo()
        }
    }

    function irPaginaAnteriorVariedades() {
        if (paginaActualVariedades > 1) {
            paginaActualVariedades--
            cargarVariedades()
        }
    }

    function irPaginaSiguienteVariedades() {
        if (paginaActualVariedades < totalPaginasVariedades) {
            paginaActualVariedades++
            cargarVariedades()
        }
    }

    function irPaginaAnteriorCiclos() {
        if (paginaActualCiclos > 1) {
            paginaActualCiclos--
            cargarCiclosProduccion()
        }
    }

    function irPaginaSiguienteCiclos() {
        if (paginaActualCiclos < totalPaginasCiclos) {
            paginaActualCiclos++
            cargarCiclosProduccion()
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

    // Función de exportación de variedades
    function exportarVariedades() {
        var csv = "ID,Tipo,Nombre,Tiempo (días),Resistencia\n";
        
        for (let i = 0; i < variedadesModel.count; i++) {
            const v = variedadesModel.get(i);
            csv += `${v.id_variedad},${v.nombre_tipo_cultivo},${v.nombre},${v.tiempo_produccion || 0},${v.resistencia_zona}\n`;
        }
        
        showMessage("Datos de variedades exportados. Revise la consola para ver el resultado.");
        console.log(csv);
    }

    // FUNCIONES PARA TIPOS DE CULTIVO

    function guardarNuevoTipoCultivo() {
        // Validar campos requeridos
        if (!nuevoTipoCultivo.nombre || nuevoTipoCultivo.nombre.trim() === "") {
            showMessage("Error: El nombre del tipo de cultivo es requerido");
            return;
        }
        
        // Preparar datos
        const datos = {
            nombre: nuevoTipoCultivo.nombre,
            nombre_cientifico: nuevoTipoCultivo.nombre_cientifico || "",
            tiempo_cosecha_min: parseInt(nuevoTipoCultivo.tiempo_cosecha_min) || 0,
            tiempo_cosecha_max: parseInt(nuevoTipoCultivo.tiempo_cosecha_max) || 0,
            descripcion: nuevoTipoCultivo.descripcion || "",
            activo: nuevoTipoCultivo.activo !== false
        };
        
        // Llamar al backend
        const resultado = cultivos.agregar_tipo_cultivo(JSON.stringify(datos));
        
        if (resultado) {
            showMessage("Tipo de cultivo creado exitosamente");
            mostrarFilaEdicionTipo = false;
            cargarTiposCultivo();
            actualizarTiposFiltro();
            actualizarTiposCombobox();
        } else {
            showMessage("Error al crear el tipo de cultivo");
        }
    }

    function actualizarTipoCultivo() {
        if (tiposCultivoListView.currentIndex < 0) return;
        
        const tipo = tiposCultivoModel.get(tiposCultivoListView.currentIndex);
        
        // Validar campos requeridos
        if (!nuevoTipoCultivo.nombre || nuevoTipoCultivo.nombre.trim() === "") {
            showMessage("Error: El nombre del tipo de cultivo es requerido");
            return;
        }
        
        // Preparar datos
        const datos = {
            nombre: nuevoTipoCultivo.nombre,
            nombre_cientifico: nuevoTipoCultivo.nombre_cientifico || "",
            tiempo_cosecha_min: parseInt(nuevoTipoCultivo.tiempo_cosecha_min) || 0,
            tiempo_cosecha_max: parseInt(nuevoTipoCultivo.tiempo_cosecha_max) || 0,
            descripcion: nuevoTipoCultivo.descripcion || "",
            activo: nuevoTipoCultivo.activo !== false
        };
        
        // Llamar al backend
        const resultado = cultivos.actualizar_tipo_cultivo(tipo.id_tipo_cultivo, JSON.stringify(datos));
        
        if (resultado) {
            showMessage("Tipo de cultivo actualizado exitosamente");
            mostrarFilaEdicionTipo = false;
            cargarTiposCultivo();
            actualizarTiposFiltro();
            actualizarTiposCombobox();
        } else {
            showMessage("Error al actualizar el tipo de cultivo");
        }
    }

    function eliminarTipoCultivo(idTipo) {
        const resultado = cultivos.eliminar_tipo_cultivo(idTipo);
        
        if (resultado) {
            showMessage("Tipo de cultivo eliminado exitosamente");
            cargarTiposCultivo();
            actualizarTiposFiltro();
            actualizarTiposCombobox();
            mostrarFilaEdicionTipo = false;
        } else {
            showMessage("Error al eliminar el tipo de cultivo. Puede que tenga variedades asociadas.");
        }
    }

    // FUNCIONES PARA VARIEDADES

    function editarVariedad(variedad) {
        // Configurar el diálogo con los datos de la variedad
        dialogNuevaVariedad.modo = "editar";
        dialogNuevaVariedad.variedadId = variedad.id_variedad;
        
        // Cargar los datos en el diálogo
        dialogNuevaVariedad.cargarVariedad(variedad);
        
        // Abrir el diálogo
        dialogNuevaVariedad.open();
    }

    function eliminarVariedad(idVariedad) {
        const resultado = cultivos.eliminar_variedad(idVariedad);
        
        if (resultado) {
            showMessage("Variedad eliminada exitosamente");
            cargarVariedades();
            actualizarVariedadesCombobox();
        } else {
            showMessage("Error al eliminar la variedad. Puede que tenga ciclos asociados.");
        }
    }

    // FUNCIONES PARA EL CALENDARIO

    function actualizarCalendarioAnual() {
        console.log("=== DEBUG: actualizarCalendarioAnual INICIADO ===")
        
        // Verificar que el repeater de meses existe
        if (typeof monthsRepeater === "undefined" || !monthsRepeater) {
            console.log("=== DEBUG: monthsRepeater no disponible ===")
            return;
        }
        
        const year = fechaActual.getFullYear();
        console.log("- DEBUG: Año:", year)
        
        // Actualizar cada mes
        for (let mes = 0; mes < 12; mes++) {
            const mesItem = monthsRepeater.itemAt(mes);
            if (!mesItem) {
                console.log("- DEBUG: No se pudo obtener mesItem para mes:", mes)
                continue;
            }
            
            const monthGrid = mesItem.children[1]; // El GridLayout es el segundo hijo
            if (!monthGrid || !monthGrid.children) {
                console.log("- DEBUG: No se pudo obtener monthGrid para mes:", mes)
                continue;
            }
            
            // Actualizar cada celda del mes
            for (let i = 7; i < monthGrid.children.length; i++) { // Saltar los headers (7 primeros)
                const celda = monthGrid.children[i];
                if (celda && typeof celda.actualizarCelda === "function") {
                    celda.actualizarCelda();
                }
            }
        }
        
        console.log("=== DEBUG: actualizarCalendarioAnual FINALIZADO ===")
    }

    function obtenerDetallesEvento(day, month, year, evento) {
        try {
            // Buscar el ciclo correspondiente
            for (let i = 0; i < ciclosModel.count; i++) {
                const ciclo = ciclosModel.get(i);
                
                // Verificar si este ciclo corresponde al evento
                var fechaEvento = null;
                var tipoEvento = "";
                
                if (evento.text.includes("Siembra")) {
                    fechaEvento = parseDBDate(ciclo.fecha_siembra);
                    tipoEvento = "Siembra";
                } else if (evento.text.includes("Cosecha")) {
                    fechaEvento = parseDBDate(ciclo.fecha_cosecha_estimada);
                    tipoEvento = "Cosecha Estimada";
                } else if (evento.text.includes("Poda")) {
                    fechaEvento = parseDBDate(ciclo.fecha_poda);
                    tipoEvento = "Poda";
                } else if (evento.text.includes("Floración")) {
                    fechaEvento = parseDBDate(ciclo.fecha_floracion);
                    tipoEvento = "Floración";
                } else if (evento.text.includes("Limpieza")) {
                    fechaEvento = parseDBDate(ciclo.fecha_limpieza);
                    tipoEvento = "Limpieza";
                }
                
                if (fechaEvento && 
                    fechaEvento.getDate() === day && 
                    fechaEvento.getMonth() === month && 
                    fechaEvento.getFullYear() === year) {
                    
                    return {
                        idCiclo: ciclo.id_ciclo,
                        tipoEvento: tipoEvento,
                        nombreVariedad: ciclo.nombre_variedad,
                        nombreParcela: ciclo.nombre_parcela,
                        tipoCultivo: ciclo.nombre_tipo_cultivo,
                        areaSembrada: ciclo.area_sembrada.toString(),
                        estadoCiclo: ciclo.estado,
                        eventoColor: evento.color
                    };
                }
            }
            return null;
        } catch (e) {
            console.error("Error obteniendo detalles del evento:", e);
            return null;
        }
    }

    function resaltarCiclo(idCiclo) {
        // Buscar el índice del ciclo en el modelo
        for (let i = 0; i < ciclosModel.count; i++) {
            if (ciclosModel.get(i).id_ciclo === idCiclo) {
                ciclosListView.currentIndex = i;
                ciclosListView.positionViewAtIndex(i, ListView.Center);
                break;
            }
        }
    }

    // Función para actualizar filtro de estados del calendario
    function actualizarEstadosCalendario() {
        // Limpiar modelo excepto el primer elemento
        while (estadosCalendarioModel.count > 1) {
            estadosCalendarioModel.remove(1);
        }
        
        // Recopilar estados únicos de los ciclos
        const estadosUsados = new Set();
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i);
            if (ciclo.activo && ciclo.estado) {
                estadosUsados.add(ciclo.estado);
            }
        }
        
        // Añadir estados al modelo
        var estadosArray = Array.from(estadosUsados);
        for (let i = 0; i < estadosArray.length; i++) {
            estadosCalendarioModel.append({
                text: estadosArray[i],
                value: estadosArray[i]
            });
        }
    }

    // Función para actualizar filtro de parcelas del calendario
    function actualizarParcelasCalendario() {
        // Limpiar modelo excepto el primer elemento
        while (parcelasCalendarioModel.count > 1) {
            parcelasCalendarioModel.remove(1);
        }
        
        // Recopilar parcelas únicas de los ciclos
        const parcelasUsadas = new Set();
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i);
            if (ciclo.activo && ciclo.nombre_parcela) {
                parcelasUsadas.add(ciclo.nombre_parcela);
            }
        }
        
        // Añadir parcelas al modelo
        var parcelasArray = Array.from(parcelasUsadas);
        for (let i = 0; i < parcelasArray.length; i++) {
            parcelasCalendarioModel.append({
                text: parcelasArray[i],
                value: parcelasArray[i]
            });
        }
    }

    // FUNCIÓN PRINCIPAL: Aplicar todos los filtros al calendario
    function aplicarFiltrosCalendario() {
        // Recargar eventos con filtros aplicados
        cargarEventosCalendarioConFiltros();
        
        // Actualizar calendario anual
        actualizarCalendarioAnual();
    }

    function cargarEventosCalendarioConFiltros() {
        eventosPorFecha = {}
        
        // Obtener valores de filtros
        const filtroCultivo = filterCultivos.cmbFiltroCultivosCalendario > 0 ? 
                            cultivosFiltroModel.get(filterCultivos.cmbFiltroCultivosCalendario).text : null;
        const filtroEstado = filterEstados.currentIndex > 0 ? 
                            estadosCalendarioModel.get(filterEstados.currentIndex).text : null;
        const filtroParcela = filterParcelas.currentIndex > 0 ? 
                            parcelasCalendarioModel.get(filterParcelas.currentIndex).text : null;
        const filtroTipoEvento = filterTipoEvento.currentIndex > 0 ? 
                                tipoEventoModel.get(filterTipoEvento.currentIndex).value : null;
        
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i)
            if (!ciclo.activo) continue
            
            // Aplicar filtros
            if (filtroCultivo && filtroCultivo !== "Todos los cultivos" && 
                ciclo.nombre_tipo_cultivo !== filtroCultivo) continue;
                
            if (filtroEstado && filtroEstado !== "Todos los estados" && 
                ciclo.estado !== filtroEstado) continue;
                
            if (filtroParcela && filtroParcela !== "Todas las parcelas" && 
                ciclo.nombre_parcela !== filtroParcela) continue;
            
            // Añadir eventos según filtro de tipo de evento
            if (!filtroTipoEvento || filtroTipoEvento === "todos" || filtroTipoEvento === "siembra") {
                agregarEventoSiEsValido(ciclo.fecha_siembra, "Siembra " + ciclo.nombre_variedad, "#2E7D32");
            }
            
            if (!filtroTipoEvento || filtroTipoEvento === "todos" || filtroTipoEvento === "cosecha") {
                agregarEventoSiEsValido(ciclo.fecha_cosecha_estimada, "Cosecha " + ciclo.nombre_variedad, "#FF9800");
            }
            
            if (!filtroTipoEvento || filtroTipoEvento === "todos" || filtroTipoEvento === "poda") {
                agregarEventoSiEsValido(ciclo.fecha_poda, "Poda " + ciclo.nombre_variedad, "#9C27B0");
            }
            
            if (!filtroTipoEvento || filtroTipoEvento === "todos" || filtroTipoEvento === "floracion") {
                agregarEventoSiEsValido(ciclo.fecha_floracion, "Floración " + ciclo.nombre_variedad, "#2196F3");
            }
            
            if (!filtroTipoEvento || filtroTipoEvento === "todos" || filtroTipoEvento === "limpieza") {
                agregarEventoSiEsValido(ciclo.fecha_limpieza, "Limpieza " + ciclo.nombre_variedad, "#795548");
            }
        }
    }

    // Función auxiliar para agregar evento si es válido
    function agregarEventoSiEsValido(fecha, texto, color) {
        if (fecha && fecha !== "") {
            const fechaObj = parseDBDate(fecha);
            if (fechaObj) {
                const key = fechaObj.getFullYear() + "-" + (fechaObj.getMonth() + 1) + "-" + fechaObj.getDate();
                if (!eventosPorFecha[key]) eventosPorFecha[key] = [];
                eventosPorFecha[key].push({
                    text: texto,
                    color: color
                });
            }
        }
    }

    // Función para limpiar todos los filtros
    function limpiarFiltrosCalendario() {
        filterCultivos.cmbFiltroCultivosCalendario = 0;
        filterEstados.currentIndex = 0;
        filterParcelas.currentIndex = 0;
        filterTipoEvento.currentIndex = 0;
        
        // Recargar eventos sin filtros
        cargarEventosCalendario();
        actualizarCalendarioAnual();
    }

    // MODELOS DE DATOS

    // Modelo para tipos de cultivo
    ListModel { id: tiposCultivoModel }
    
    // Modelo para variedades
    ListModel { id: variedadesModel }
    
    // Modelo para ciclos de producción
    ListModel { id: ciclosModel }
    
    // Modelos para combos
    ListModel { 
        id: tiposVariedadModel 
    }
    
    ListModel { 
        id: variedadesCicloModel 
    }
    
    ListModel { 
        id: parcelasModel 
    }
    
    ListModel {
        id: estadosModel
        ListElement { text: "Planificado"; value: "Planificado" }
        ListElement { text: "En Preparación"; value: "En Preparación" }
        ListElement { text: "Sembrado"; value: "Sembrado" }
        ListElement { text: "En Desarrollo"; value: "En Desarrollo" }
        ListElement { text: "En Cosecha"; value: "En Cosecha" }
        ListElement { text: "Finalizado"; value: "Finalizado" }
        ListElement { text: "Cancelado"; value: "Cancelado" }
    }
    
    // Modelos para filtros
    ListModel { 
        id: tiposFiltroModel 
        ListElement { text: "Todos los tipos"; value: 0 }
    }
    
    ListModel { 
        id: estadosFiltroModel
        ListElement { text: "Todos los estados"; value: "" }
    }
    
    // Modelos para filtros del calendario
    ListModel {
        id: cultivosFiltroModel
        ListElement { text: "Todos los cultivos"; value: "todos" }
    }
    
    ListModel {
        id: estadosCalendarioModel
        ListElement { text: "Todos los estados"; value: "todos" }
    }
    
    ListModel {
        id: parcelasCalendarioModel
        ListElement { text: "Todas las parcelas"; value: "todas" }
    }
    
    ListModel {
        id: tipoEventoModel
        ListElement { text: "Todos los eventos"; value: "todos" }
        ListElement { text: "Siembra"; value: "siembra" }
        ListElement { text: "Cosecha"; value: "cosecha" }
        ListElement { text: "Poda"; value: "poda" }
        ListElement { text: "Floración"; value: "floracion" }
        ListElement { text: "Limpieza"; value: "limpieza" }
    }
    
    // Modelo para resistencias
    ListModel {
        id: resistenciasModel
        ListElement { text: "Alta"; value: "Alta" }
        ListElement { text: "Media"; value: "Media" }
        ListElement { text: "Baja"; value: "Baja" }
    }

    // Componente al iniciar
    Component.onCompleted: {
        console.log("cultivosRoot Component.onCompleted INICIADO")
        
        // Cargar datos iniciales
        cargarTiposCultivo()
        cargarVariedades()
        cargarCiclosProduccion()
        actualizarParcelasCombobox()
        actualizarVariedadesCombobox()
        
        console.log("cultivosRoot Component.onCompleted FINALIZADO")
    }

    // INTERFAZ DE USUARIO

    // Barra de título
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "transparent"
        anchors.top: parent.top
        anchors.topMargin: 10

        Text {
            text: "GESTIÓN DE TIPOS Y VARIEDADES DE CULTIVOS"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.centerIn: parent
        }
    }
    
    // Barra de pestañas
    Item {
        id: modernTabBar
        width: parent.width - 40
        height: 70
        anchors.top: titleBar.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        
        TabBarComponent {
            id: tabBar
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            tabsData: cultivosRoot.tabsInfo
            tabActiva: cultivosRoot.tabActiva
            
            onTabChanged: function(index) {
                cultivosRoot.tabActiva = index
            }
        }
    }

    // Contenedor de páginas de pestañas
    StackLayout {
        width: parent.width
        anchors.top: modernTabBar.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        currentIndex: cultivosRoot.tabActiva

        // PESTAÑA 1: Tipos de Cultivo
        Item {
            // Contenido principal con dos marcos
            RowLayout {
                anchors.fill: parent
                spacing: 20
                
                // Marco 1: Lista de tipos de cultivo
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.fillHeight: true
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
                                text: "Tipos de Cultivo"
                                font.pixelSize: 18
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                text: "Nuevo Cultivo"
                                icon.source: "recursos/image/icons/agregar.svg"
                                implicitHeight: 36
                                background: Rectangle {
                                    color: parent.hovered ? "#E65A00" : "#f5922f"
                                    radius: height / 2
                                }
                                contentItem: Row {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Image {
                                        width: 18
                                        height: 18
                                        source: "recursos/image/icons/agregar.svg"
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    
                                    Text {
                                        text: "Nuevo Cultivo"
                                        color: "white"
                                        font.bold: true
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                onClicked: {
                                    nuevoTipoCultivo = {
                                        "nombre": "",
                                        "nombre_cientifico": "",
                                        "tiempo_cosecha_min": 0,
                                        "tiempo_cosecha_max": 0,
                                        "descripcion": "",
                                        "activo": true
                                    }
                                    
                                    txtNombreTipo.text = "";
                                    txtNombreCientifico.text = "";
                                    txtTiempoMin.text = "0";
                                    txtTiempoMax.text = "0";
                                    chkActivo.checked = true;
                                    txtDescripcion.text = "";
                                    
                                    mostrarFilaEdicionTipo = true
                                    tiposCultivoListView.currentIndex = -1;
                                }
                            }
                        }
                        
                        // Campo de búsqueda
                        TextField {
                            id: txtBuscarTipoCultivo
                            Layout.fillWidth: true
                            placeholderText: "Buscar tipo de cultivo..."
                            implicitHeight: 28
                            leftPadding: 30 
                            background: Rectangle {
                                color: "#ffffff"
                                radius: height / 2
                                border.color: "#808080"
                                border.width: 1
                                Image {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: "recursos/image/icons/lupa.png"
                                    width: 16
                                    height: 16
                                }
                            }
                            onTextChanged: filtrarTiposCultivo()
                        }
                        
                        // Lista de tipos de cultivo
                        ListView {
                            id: tiposCultivoListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: tiposCultivoModel
                            spacing: 5
                            
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 60
                                color: ListView.isCurrentItem ? "#E8F5E9" : (index % 2 === 0 ? "#FFFFFF" : "#F5F5F5")
                                radius: 5
                                border.color: ListView.isCurrentItem ? "#4CAF50" : "transparent"
                                border.width: 2
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        tiposCultivoListView.currentIndex = index
                                        cargarDetallesTipoCultivo(model)
                                        mostrarFilaEdicionTipo = false
                                    }
                                }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: "#4CAF50"
                                        
                                        Image {
                                            anchors.centerIn: parent
                                            source: "recursos/image/icons/tiposcultivo.png"
                                            width: 24
                                            height: 24
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }
                                    
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        
                                        Text {
                                            text: nombre
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#212121"
                                        }
                                        
                                        Text {
                                            text: nombre_cientifico ? nombre_cientifico : "Sin nombre científico"
                                            font.pixelSize: 11
                                            font.italic: true
                                            color: "#757575"
                                        }
                                    }
                                    
                                    Rectangle {
                                        width: 60
                                        height: 24
                                        radius: 12
                                        color: activo ? "#4CAF50" : "#F44336"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: activo ? "Activo" : "Inactivo"
                                            font.pixelSize: 10
                                            color: "white"
                                        }
                                    }
                                }
                            }
                            
                            // Mensaje cuando no hay datos
                            Text {
                                anchors.centerIn: parent
                                text: "No hay tipos de cultivo registrados.\nHaga clic en 'Nuevo Cultivo' para agregar uno."
                                color: "#757575"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                visible: tiposCultivoModel.count === 0
                            }
                        }
                        
                        // Paginador
                        Paginator {
                            id: paginadorTipos
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            currentPage: paginaActualTipos
                            totalPages: totalPaginasTipos
                            
                            onPageChanged: {
                                paginaActualTipos = newPage
                                cargarTiposCultivo()
                            }
                        }
                    }
                }
                
                // Marco 2: Detalles/Edición
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        // Cabecera del panel de detalles
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: mostrarFilaEdicionTipo ? (tiposCultivoListView.currentIndex < 0 ? "Nuevo Tipo de Cultivo" : "Editar Tipo de Cultivo") : "Información del Cultivo"
                                font.pixelSize: 18
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // Botones en modo edición
                            Button {
                                text: "Eliminar"
                                implicitHeight: 32
                                visible: mostrarFilaEdicionTipo && tiposCultivoListView.currentIndex >= 0
                                background: Rectangle {
                                    color: "#F44336"
                                    radius: height / 2
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    if (tiposCultivoListView.currentIndex >= 0) {
                                        const tipo = tiposCultivoModel.get(tiposCultivoListView.currentIndex);
                                        confirmDeleteTipoDialog.tipoId = tipo.id_tipo_cultivo;
                                        confirmDeleteTipoDialog.nombreTipo = tipo.nombre;
                                        confirmDeleteTipoDialog.open();
                                    }
                                }
                            }
                            
                            Button {
                                text: "Cancelar"
                                implicitHeight: 32
                                visible: mostrarFilaEdicionTipo
                                background: Rectangle {
                                    color: "#9E9E9E"
                                    radius: height / 2
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    mostrarFilaEdicionTipo = false;
                                    if (tiposCultivoListView.currentIndex >= 0) {
                                        const tipo = tiposCultivoModel.get(tiposCultivoListView.currentIndex);
                                        cargarDetallesTipoCultivo(tipo);
                                    }
                                }
                            }
                            
                            Button {
                                text: mostrarFilaEdicionTipo ? "Guardar" : "Editar"
                                implicitHeight: 32
                                visible: mostrarFilaEdicionTipo || tiposCultivoListView.currentIndex >= 0
                                background: Rectangle {
                                    color: "#4CAF50"
                                    radius: height / 2
                                }
                                contentItem: Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    
                                    Image {
                                        width: 16
                                        height: 16
                                        source: mostrarFilaEdicionTipo ? "" : "recursos/image/icons/editar.svg"
                                        fillMode: Image.PreserveAspectFit
                                        visible: !mostrarFilaEdicionTipo
                                    }
                                    
                                    Text {
                                        text: parent.parent.text
                                        color: "white"
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                onClicked: {
                                    if (mostrarFilaEdicionTipo) {
                                        if (tiposCultivoListView.currentIndex < 0) {
                                            guardarNuevoTipoCultivo();
                                        } else {
                                            actualizarTipoCultivo();
                                        }
                                    } else {
                                        mostrarFilaEdicionTipo = true;
                                    }
                                }
                            }
                        }
                        
                        // Contenido dinámico: formulario de edición o información
                        StackLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            currentIndex: mostrarFilaEdicionTipo ? 0 : 1
                            
                            // Índice 0: Formulario de edición
                            Item {
                                ScrollView {
                                    anchors.fill: parent
                                    clip: true
                                    
                                    GridLayout {
                                        width: parent.width
                                        columns: 2
                                        rowSpacing: 15
                                        columnSpacing: 20
                                        
                                        // Nombre
                                        Text {
                                            text: "Nombre:"
                                            font.pixelSize: 14
                                        }
                                        
                                        TextField {
                                            id: txtNombreTipo
                                            Layout.fillWidth: true
                                            placeholderText: "Nombre del tipo de cultivo"
                                            onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.nombre = text
                                        }
                                        
                                        // Nombre Científico
                                        Text {
                                            text: "Nombre Científico:"
                                            font.pixelSize: 14
                                        }
                                        
                                        TextField {
                                            id: txtNombreCientifico
                                            Layout.fillWidth: true
                                            placeholderText: "Nombre científico"
                                            font.italic: true
                                            onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.nombre_cientifico = text
                                        }
                                        
                                        // Tiempo de Cosecha Mínimo
                                        Text {
                                            text: "Tiempo mín. hasta cosecha (días):"
                                            font.pixelSize: 14
                                        }
                                        
                                        TextField {
                                            id: txtTiempoMin
                                            Layout.fillWidth: true
                                            placeholderText: "Ej: 90"
                                            validator: IntValidator { bottom: 1; top: 10000 }
                                            onTextChanged: {
                                                if (mostrarFilaEdicionTipo && text.trim() !== "") {
                                                    nuevoTipoCultivo.tiempo_cosecha_min = parseInt(text)
                                                }
                                            }
                                        }
                                        
                                        // Tiempo de Cosecha Máximo
                                        Text {
                                            text: "Tiempo máx. hasta cosecha (días):"
                                            font.pixelSize: 14
                                        }
                                        
                                        TextField {
                                            id: txtTiempoMax
                                            Layout.fillWidth: true
                                            placeholderText: "Ej: 120"
                                            validator: IntValidator { bottom: 1; top: 10000 }
                                            onTextChanged: {
                                                if (mostrarFilaEdicionTipo && text.trim() !== "") {
                                                    nuevoTipoCultivo.tiempo_cosecha_max = parseInt(text)
                                                }
                                            }
                                        }
                                        
                                        // Activo
                                        Text {
                                            text: "Activo:"
                                            font.pixelSize: 14
                                        }
                                        
                                        CheckBox {
                                            id: chkActivo
                                            checked: true
                                            onCheckedChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.activo = checked
                                        }
                                        
                                        // Descripción
                                        Text {
                                            text: "Descripción:"
                                            font.pixelSize: 14
                                            Layout.alignment: Qt.AlignTop
                                        }
                                        
                                        ScrollView {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 100
                                            
                                            TextArea {
                                                id: txtDescripcion
                                                placeholderText: "Descripción del tipo de cultivo"
                                                wrapMode: TextArea.Wrap
                                                onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.descripcion = text
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Índice 1: Vista de información
                            Item {
                                visible: tiposCultivoListView.currentIndex >= 0
                                
                                ScrollView {
                                    anchors.fill: parent
                                    clip: true
                                    
                                    ColumnLayout {
                                        width: parent.width
                                        spacing: 20
                                        
                                        // Información básica
                                        GridLayout {
                                            Layout.fillWidth: true
                                            columns: 2
                                            rowSpacing: 15
                                            columnSpacing: 20
                                            
                                            Text {
                                                text: "Nombre:"
                                                font.pixelSize: 14
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: tiposCultivoListView.currentIndex >= 0 ? tiposCultivoModel.get(tiposCultivoListView.currentIndex).nombre : ""
                                                font.pixelSize: 14
                                            }
                                            
                                            Text {
                                                text: "Nombre Científico:"
                                                font.pixelSize: 14
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: tiposCultivoListView.currentIndex >= 0 && tiposCultivoModel.get(tiposCultivoListView.currentIndex).nombre_cientifico ? 
                                                      tiposCultivoModel.get(tiposCultivoListView.currentIndex).nombre_cientifico : "No especificado"
                                                font.pixelSize: 14
                                                font.italic: true
                                            }
                                            
                                            Text {
                                                text: "Tiempo de Cosecha:"
                                                font.pixelSize: 14
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: {
                                                    if (tiposCultivoListView.currentIndex >= 0) {
                                                        const tipo = tiposCultivoModel.get(tiposCultivoListView.currentIndex);
                                                        if (tipo.tiempo_cosecha_min && tipo.tiempo_cosecha_max) {
                                                            return tipo.tiempo_cosecha_min + " - " + tipo.tiempo_cosecha_max + " días";
                                                        } else if (tipo.tiempo_cosecha_min) {
                                                            return tipo.tiempo_cosecha_min + " días (mínimo)";
                                                        } else if (tipo.tiempo_cosecha_max) {
                                                            return tipo.tiempo_cosecha_max + " días (máximo)";
                                                        }
                                                    }
                                                    return "No especificado";
                                                }
                                                font.pixelSize: 14
                                            }
                                            
                                            Text {
                                                text: "Estado:"
                                                font.pixelSize: 14
                                                font.bold: true
                                            }
                                            
                                            Rectangle {
                                                width: 80
                                                height: 26
                                                radius: 13
                                                color: tiposCultivoListView.currentIndex >= 0 && tiposCultivoModel.get(tiposCultivoListView.currentIndex).activo ? "#4CAF50" : "#F44336"
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: tiposCultivoListView.currentIndex >= 0 && tiposCultivoModel.get(tiposCultivoListView.currentIndex).activo ? "Activo" : "Inactivo"
                                                    font.pixelSize: 12
                                                    color: "white"
                                                }
                                            }
                                            
                                            Text {
                                                text: "Descripción:"
                                                font.pixelSize: 14
                                                font.bold: true
                                                Layout.alignment: Qt.AlignTop
                                            }
                                            
                                            Text {
                                                text: tiposCultivoListView.currentIndex >= 0 && tiposCultivoModel.get(tiposCultivoListView.currentIndex).descripcion ? 
                                                      tiposCultivoModel.get(tiposCultivoListView.currentIndex).descripcion : "Sin descripción"
                                                font.pixelSize: 14
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                                
                                // Mensaje cuando no hay selección
                                Text {
                                    anchors.centerIn: parent
                                    text: "Seleccione un tipo de cultivo de la lista\npara ver sus detalles"
                                    color: "#757575"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: tiposCultivoListView.currentIndex < 0
                                }
                            }
                        }
                    }
                }
            }
        }

        // PESTAÑA 2: Variedades
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
                        spacing: 20
                        
                        Button {
                            text: "Nueva Variedad"
                            icon.source: "recursos/image/icons/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                // Inicializa los valores para la nueva variedad
                                nuevaVariedad = {
                                    "id_tipo_cultivo": tiposCultivoModel.count > 0 ? tiposCultivoModel.get(0).id_tipo_cultivo : 1,
                                    "nombre": "",
                                    "tiempo_produccion": 0,
                                    "resistencia_zona": "Media",
                                    "activo": true
                                }
                                
                                // Mostrar diálogo de nueva variedad
                                dialogNuevaVariedad.open()
                            }
                        }
                        
                        TextField {
                            id: txtBuscarVariedad
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar variedades..."
                            implicitWidth: 450
                            implicitHeight: 28
                            leftPadding: 30
                            
                            background: Rectangle {
                                color: "#ffffff"
                                radius: height / 2
                                border.color: "#808080"
                                border.width: 1
                                
                                Image {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: "recursos/image/icons/lupa.png"
                                    width: 16
                                    height: 16
                                }
                            }
                            onTextChanged: filtrarVariedades()
                        }

                        ComboBox {
                            id: cmbFiltroTipos
                            Layout.preferredWidth: 200
                            textRole: "text"
                            valueRole: "value"
                            model: tiposFiltroModel

                            onCurrentIndexChanged: {
                                if (currentIndex >= 0) {
                                    var valorFiltro = currentIndex > 0 ? model.get(currentIndex).value : 0;
                                    filtrarVariedadesPorTipo(valorFiltro);
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Exportar"
                            icon.source: "recursos/image/icons/exportacion-de-archivos.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: exportarVariedades()
                        }
                    }
                }
                
                // Tabla de variedades
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: variedadesListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: variedadesModel
                        headerPositioning: ListView.OverlayHeader
                        
                        // Cabecera de la tabla - SIN COLUMNA DE RENDIMIENTO
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
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Tipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    text: "Nombre de Variedad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Tiempo (días)"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    text: "Resistencia Zona"
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
                        
                        // Delegado para cada fila - SIN COLUMNA DE RENDIMIENTO
                        delegate: Rectangle {
                            width: cultivosRoot.width
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
                                        text: id_variedad
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Tipo
                                Rectangle {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombre_tipo_cultivo
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Nombre
                                Rectangle {
                                    width: parent.width * 0.25
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombre
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Tiempo Producción
                                Rectangle {
                                    width: parent.width * 0.15
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: tiempo_produccion || "No definido"
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Resistencia
                                Rectangle {
                                    width: parent.width * 0.2
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 80
                                        height: 24
                                        radius: 12
                                        color: getResistenciaColor(resistencia_zona)
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: resistencia_zona
                                            font.pixelSize: 12
                                            color: "white"
                                        }
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
                                            onClicked: editarVariedad(model)
                                        }
                                        
                                        Button {
                                            width: 36
                                            height: 36
                                            icon.source: "recursos/image/icons/basura.svg"
                                            flat: true
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: {
                                                confirmDeleteVariedadDialog.variedadId = id_variedad
                                                confirmDeleteVariedadDialog.nombreVariedad = nombre
                                                confirmDeleteVariedadDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay variedades registradas.\nHaga clic en 'Nueva Variedad' para agregar una."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: variedadesModel.count === 0
                        }
                    }
                }
                
                // Paginador
                Paginator {
                    id: paginadorVariedades
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    currentPage: paginaActualVariedades
                    totalPages: totalPaginasVariedades
                    
                    onPageChanged: {
                        paginaActualVariedades = newPage
                        cargarVariedades()
                    }
                }
            }
        }

        // PESTAÑA 3: Ciclos de Producción
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
                        spacing: 20
                        
                        Button {
                            text: "Nuevo Ciclo"
                            icon.source: "recursos/image/icons/agregar.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#f5922f"
                                radius: height / 2
                            }
                            onClicked: {
                                dialogCicloProduccion.modo = "nuevo";
                                dialogCicloProduccion.open();
                            }
                        }
                        
                        TextField {
                            id: txtBuscarCiclo
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar ciclos..."
                            implicitHeight: 28
                            leftPadding: 30
                            
                            background: Rectangle {
                                color: "#ffffff"
                                radius: height / 2
                                border.color: "#808080"
                                border.width: 1
                                
                                Image {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 10
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: "recursos/image/icons/lupa.png"
                                    width: 16
                                    height: 16
                                }
                            }
                            onTextChanged: filtrarCiclos()
                        }
                        
                        ComboBox {
                            id: cmbFiltroEstados
                            Layout.preferredWidth: 200
                            textRole: "text"
                            valueRole: "value"
                            model: estadosFiltroModel
                            implicitHeight: 36
                            onCurrentIndexChanged: {
                                if (currentIndex >= 0) {
                                    filtrarCiclosPorEstado();
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Exportar"
                            icon.source: "recursos/image/icons/exportacion-de-archivos.svg"
                            implicitHeight: 36
                            background: Rectangle {
                                color: parent.hovered ? "#00e654" : "#4CAF50"
                                radius: height / 2
                            }
                            onClicked: exportarCiclos()
                        }
                    }
                }
                
                // Tabla de ciclos de producción
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ListView {
                        id: ciclosListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: ciclosModel
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
                                    width: parent.width * 0.13
                                    height: parent.height
                                    text: "Parcela"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    text: "Variedad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Siembra"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Cosecha Est."
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
                                    width: parent.width * 0.1
                                    height: parent.height
                                    text: "Densidad"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.14
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
                            width: cultivosRoot.width
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
                                        text: id_ciclo
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Parcela
                                Rectangle {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombre_parcela
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Variedad
                                Rectangle {
                                    width: parent.width * 0.13
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: nombre_variedad
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Fecha Siembra
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: formatDate(fecha_siembra)
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Fecha Cosecha Estimada
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: formatDate(fecha_cosecha_estimada)
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Área sembrada
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: area_sembrada
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Densidad de siembra
                                Rectangle {
                                    width: parent.width * 0.1
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        text: densidad_siembra || "No definida"
                                        elide: Text.ElideRight
                                        width: parent.width - 20
                                    }
                                }
                                
                                // Estado
                                Rectangle {
                                    width: parent.width * 0.14
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 100
                                        height: 24
                                        radius: 12
                                        color: getEstadoColor(estado)
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: estado
                                            font.pixelSize: 11
                                            color: "white"
                                        }
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
                                                dialogCicloProduccion.modo = "editar";
                                                dialogCicloProduccion.cargarCiclo(id_ciclo);
                                                dialogCicloProduccion.open();
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
                                                confirmDeleteCicloDialog.cicloId = id_ciclo;
                                                confirmDeleteCicloDialog.nombreParcela = nombre_parcela;
                                                confirmDeleteCicloDialog.nombreVariedad = nombre_variedad;
                                                confirmDeleteCicloDialog.open();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay datos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay ciclos de producción registrados.\nHaga clic en 'Nuevo Ciclo' para agregar uno."
                            color: "#757575"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            visible: ciclosModel.count === 0
                        }
                    }
                }
                
                // Paginador
                Paginator {
                    id: paginadorCiclos
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    currentPage: paginaActualCiclos
                    totalPages: totalPaginasCiclos
                    
                    onPageChanged: {
                        paginaActualCiclos = newPage
                        cargarCiclosProduccion()
                    }
                }
            }
        }

        // PESTAÑA 4: Calendario de Cultivos
        Item {
            Rectangle {
                id: calendarContainer
                width: parent.width
                height: parent.height
                color: "white"
                radius: 5
                border.color: "#EEEEEE"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // Cabecera con controles
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Text {
                            id: txtTituloCalendario
                            text: "Calendario de Ciclos " + fechaActual.getFullYear()
                            font.pixelSize: 24
                            font.bold: true
                            color: "#9A6829"
                        }
                        
                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Filtros:"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        // Filtro por tipo de cultivo
                        ComboBox {
                            id: filterCultivos
                            Layout.preferredWidth: 150
                            textRole: "text"
                            valueRole: "value"
                            model: cultivosFiltroModel
                            property int cmbFiltroCultivosCalendario: currentIndex
                            onCurrentIndexChanged: {
                                cmbFiltroCultivosCalendario = currentIndex
                                aplicarFiltrosCalendario()
                            }
                        }
                        
                        // Filtro por estado
                        ComboBox {
                            id: filterEstados
                            Layout.preferredWidth: 150
                            textRole: "text"
                            valueRole: "value"
                            model: estadosCalendarioModel
                            onCurrentIndexChanged: aplicarFiltrosCalendario()
                        }
                        
                        // Filtro por parcela
                        ComboBox {
                            id: filterParcelas
                            Layout.preferredWidth: 150
                            textRole: "text"
                            valueRole: "value"
                            model: parcelasCalendarioModel
                            onCurrentIndexChanged: aplicarFiltrosCalendario()
                        }
                        
                        // Filtro por tipo de evento
                        ComboBox {
                            id: filterTipoEvento
                            Layout.preferredWidth: 150
                            textRole: "text"
                            valueRole: "value"
                            model: tipoEventoModel
                            onCurrentIndexChanged: aplicarFiltrosCalendario()
                        }
                        
                        Button {
                            text: "Limpiar Filtros"
                            implicitHeight: 32
                            background: Rectangle {
                                color: parent.hovered ? "#E0E0E0" : "#F5F5F5"
                                radius: height / 2
                            }
                            onClicked: limpiarFiltrosCalendario()
                        }
                    }
                    
                    // Leyenda de colores
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#F5F5F5"
                        radius: 5
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 20
                            
                            Text {
                                text: "Leyenda:"
                                font.pixelSize: 12
                                font.bold: true
                            }
                            
                            Row {
                                spacing: 5
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#2E7D32"
                                }
                                Text {
                                    text: "Siembra"
                                    font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            Row {
                                spacing: 5
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#FF9800"
                                }
                                Text {
                                    text: "Cosecha"
                                    font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            Row {
                                spacing: 5
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#9C27B0"
                                }
                                Text {
                                    text: "Poda"
                                    font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            Row {
                                spacing: 5
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#2196F3"
                                }
                                Text {
                                    text: "Floración"
                                    font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            Row {
                                spacing: 5
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#795548"
                                }
                                Text {
                                    text: "Limpieza"
                                    font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                    }
                    
                    // Calendario anual
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        GridLayout {
                            width: calendarContainer.width - 40
                            columns: 4
                            rowSpacing: 15
                            columnSpacing: 15
                            
                            Repeater {
                                id: monthsRepeater
                                model: 12
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 200
                                    color: "#FAFAFA"
                                    radius: 5
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                    
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 5
                                        
                                        // Nombre del mes
                                        Text {
                                            Layout.fillWidth: true
                                            text: obtenerNombreMes(index)
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#424242"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        // Grid del mes
                                        GridLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            columns: 7
                                            rowSpacing: 2
                                            columnSpacing: 2
                                            
                                            // Headers días de la semana
                                            Repeater {
                                                model: ["L", "M", "X", "J", "V", "S", "D"]
                                                
                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 20
                                                    text: modelData
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                    color: "#757575"
                                                }
                                            }
                                            
                                            // Días del mes
                                            Repeater {
                                                model: 35 // 5 semanas máximo
                                                
                                                Rectangle {
                                                    id: dayCellRect
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    color: {
                                                        if (!visible) return "transparent";
                                                        
                                                        const primerDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index, 1);
                                                        let diaSemana = primerDia.getDay();
                                                        if (diaSemana === 0) diaSemana = 7;
                                                        diaSemana--;
                                                        
                                                        const ultimoDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index + 1, 0);
                                                        const diasEnMes = ultimoDia.getDate();
                                                        
                                                        const diaNumero = index - diaSemana;
                                                        
                                                        if (diaNumero < 1 || diaNumero > diasEnMes) return "transparent";
                                                        
                                                        const eventos = getEventsForDay(diaNumero, parent.parent.parent.parent.index, fechaActual.getFullYear());
                                                        if (eventos.length > 0) {
                                                            return eventos[0].color + "40"; // Color con transparencia
                                                        }
                                                        
                                                        return "#FFFFFF";
                                                    }
                                                    radius: 3
                                                    border.color: {
                                                        const primerDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index, 1);
                                                        let diaSemana = primerDia.getDay();
                                                        if (diaSemana === 0) diaSemana = 7;
                                                        diaSemana--;
                                                        
                                                        const ultimoDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index + 1, 0);
                                                        const diasEnMes = ultimoDia.getDate();
                                                        
                                                        const diaNumero = index - diaSemana;
                                                        
                                                        if (diaNumero < 1 || diaNumero > diasEnMes) return "transparent";
                                                        
                                                        const eventos = getEventsForDay(diaNumero, parent.parent.parent.parent.index, fechaActual.getFullYear());
                                                        if (eventos.length > 0) {
                                                            return eventos[0].color;
                                                        }
                                                        
                                                        return "#E0E0E0";
                                                    }
                                                    border.width: 1
                                                    visible: {
                                                        const primerDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index, 1);
                                                        let diaSemana = primerDia.getDay();
                                                        if (diaSemana === 0) diaSemana = 7;
                                                        diaSemana--;
                                                        
                                                        const ultimoDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index + 1, 0);
                                                        const diasEnMes = ultimoDia.getDate();
                                                        
                                                        const diaNumero = index - diaSemana;
                                                        
                                                        return diaNumero >= 1 && diaNumero <= diasEnMes;
                                                    }
                                                    
                                                    function actualizarCelda() {
                                                        dayCellRect.color = Qt.binding(function() {
                                                            if (!visible) return "transparent";
                                                            
                                                            const primerDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index, 1);
                                                            let diaSemana = primerDia.getDay();
                                                            if (diaSemana === 0) diaSemana = 7;
                                                            diaSemana--;
                                                            
                                                            const ultimoDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index + 1, 0);
                                                            const diasEnMes = ultimoDia.getDate();
                                                            
                                                            const diaNumero = index - diaSemana;
                                                            
                                                            if (diaNumero < 1 || diaNumero > diasEnMes) return "transparent";
                                                            
                                                            const eventos = getEventsForDay(diaNumero, parent.parent.parent.parent.index, fechaActual.getFullYear());
                                                            if (eventos.length > 0) {
                                                                return eventos[0].color + "40";
                                                            }
                                                            
                                                            return "#FFFFFF";
                                                        });
                                                    }
                                                    
                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 2
                                                        spacing: 0
                                                        
                                                        Text {
                                                            text: {
                                                                const primerDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.parent.parent.index, 1);
                                                                let diaSemana = primerDia.getDay();
                                                                if (diaSemana === 0) diaSemana = 7;
                                                                diaSemana--;
                                                                
                                                                const ultimoDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.parent.parent.index + 1, 0);
                                                                const diasEnMes = ultimoDia.getDate();
                                                                
                                                                const diaNumero = index - diaSemana;
                                                                
                                                                if (diaNumero < 1 || diaNumero > diasEnMes) return "";
                                                                
                                                                return diaNumero;
                                                            }
                                                            font.pixelSize: 9
                                                            font.bold: true
                                                            color: "#424242"
                                                            horizontalAlignment: Text.AlignHCenter
                                                            Layout.fillWidth: true
                                                        }
                                                        
                                                        // Indicadores de eventos
                                                        Row {
                                                            Layout.fillWidth: true
                                                            Layout.alignment: Qt.AlignHCenter
                                                            spacing: 1
                                                            
                                                            Repeater {
                                                                model: {
                                                                    const primerDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.parent.parent.parent.index, 1);
                                                                    let diaSemana = primerDia.getDay();
                                                                    if (diaSemana === 0) diaSemana = 7;
                                                                    diaSemana--;
                                                                    
                                                                    const ultimoDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.parent.parent.parent.index + 1, 0);
                                                                    const diasEnMes = ultimoDia.getDate();
                                                                    
                                                                    const diaNumero = index - diaSemana;
                                                                    
                                                                    if (diaNumero < 1 || diaNumero > diasEnMes) return [];
                                                                    
                                                                    const eventos = getEventsForDay(diaNumero, parent.parent.parent.parent.parent.parent.parent.index, fechaActual.getFullYear());
                                                                    return Math.min(eventos.length, 3);
                                                                }
                                                                
                                                                Rectangle {
                                                                    width: 4
                                                                    height: 4
                                                                    radius: 2
                                                                    color: {
                                                                        const primerDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.parent.parent.parent.parent.index, 1);
                                                                        let diaSemana = primerDia.getDay();
                                                                        if (diaSemana === 0) diaSemana = 7;
                                                                        diaSemana--;
                                                                        
                                                                        const ultimoDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.parent.parent.parent.parent.index + 1, 0);
                                                                        const diasEnMes = ultimoDia.getDate();
                                                                        
                                                                        const diaNumero = parent.parent.parent.parent.parent.parent.index - diaSemana;
                                                                        
                                                                        if (diaNumero < 1 || diaNumero > diasEnMes) return "transparent";
                                                                        
                                                                        const eventos = getEventsForDay(diaNumero, parent.parent.parent.parent.parent.parent.parent.parent.index, fechaActual.getFullYear());
                                                                        if (index < eventos.length) {
                                                                            return eventos[index].color;
                                                                        }
                                                                        return "transparent";
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        
                                                        onEntered: {
                                                            const primerDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index, 1);
                                                            let diaSemana = primerDia.getDay();
                                                            if (diaSemana === 0) diaSemana = 7;
                                                            diaSemana--;
                                                            
                                                            const ultimoDia = new Date(fechaActual.getFullYear(), parent.parent.parent.parent.index + 1, 0);
                                                            const diasEnMes = ultimoDia.getDate();
                                                            
                                                            const diaNumero = index - diaSemana;
                                                            
                                                            if (diaNumero >= 1 && diaNumero <= diasEnMes) {
                                                                const eventos = getEventsForDay(diaNumero, parent.parent.parent.parent.index, fechaActual.getFullYear());
                                                                if (eventos.length > 0) {
                                                                    // Mostrar tooltip con los eventos
                                                                    const tooltipText = eventos.map(e => e.text).join("\n");
                                                                    parent.ToolTip.text = tooltipText;
                                                                    parent.ToolTip.visible = true;
                                                                }
                                                            }
                                                        }
                                                        
                                                        onExited: {
                                                            parent.ToolTip.visible = false;
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
                }
            }
        }
    }

    // DIÁLOGOS

    // Diálogo de confirmación para eliminar tipo de cultivo
    Dialog {
        id: confirmDeleteTipoDialog
        title: "Confirmar Eliminación"
        modal: true
        anchors.centerIn: parent
        
        property int tipoId: 0
        property string nombreTipo: ""
        
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "¿Está seguro que desea eliminar el tipo de cultivo '" + confirmDeleteTipoDialog.nombreTipo + "'?"
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 400
            }
            
            Text {
                text: "Esta acción no se puede deshacer."
                color: "#F44336"
                font.italic: true
            }
        }
        
        standardButtons: Dialog.Yes | Dialog.No
        
        onAccepted: {
            eliminarTipoCultivo(tipoId);
        }
    }

    // Diálogo de confirmación para eliminar variedad
    Dialog {
        id: confirmDeleteVariedadDialog
        title: "Confirmar Eliminación"
        modal: true
        anchors.centerIn: parent
        
        property int variedadId: 0
        property string nombreVariedad: ""
        
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "¿Está seguro que desea eliminar la variedad '" + confirmDeleteVariedadDialog.nombreVariedad + "'?"
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 400
            }
            
            Text {
                text: "Esta acción no se puede deshacer."
                color: "#F44336"
                font.italic: true
            }
        }
        
        standardButtons: Dialog.Yes | Dialog.No
        
        onAccepted: {
            eliminarVariedad(variedadId);
        }
    }

    // Diálogo de confirmación para eliminar ciclo
    Dialog {
        id: confirmDeleteCicloDialog
        title: "Confirmar Eliminación"
        modal: true
        anchors.centerIn: parent
        
        property int cicloId: 0
        property string nombreParcela: ""
        property string nombreVariedad: ""
        
        ColumnLayout {
            spacing: 20
            
            Text {
                text: "¿Está seguro que desea eliminar el ciclo de producción?"
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 400
                font.bold: true
            }
            
            Text {
                text: "Parcela: " + confirmDeleteCicloDialog.nombreParcela + "\nVariedad: " + confirmDeleteCicloDialog.nombreVariedad
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 400
            }
            
            Text {
                text: "Esta acción no se puede deshacer."
                color: "#F44336"
                font.italic: true
            }
        }
        
        standardButtons: Dialog.Yes | Dialog.No
        
        onAccepted: {
            const resultado = cultivos.eliminar_ciclo_produccion(cicloId);
            
            if (resultado) {
                showMessage("Ciclo de producción eliminado exitosamente");
                cargarCiclosProduccion();
            } else {
                showMessage("Error al eliminar el ciclo de producción");
            }
        }
    }

    // Diálogo para Nueva/Editar Variedad
    Dialog {
        id: dialogNuevaVariedad
        title: modo === "nuevo" ? "Nueva Variedad" : "Editar Variedad"
        modal: true
        width: 500
        height: 400
        anchors.centerIn: parent
        
        property string modo: "nuevo"
        property int variedadId: 0
        
        function cargarVariedad(variedad) {
            cmbTipoCultivo.currentIndex = getTipoIndex(variedad.id_tipo_cultivo);
            txtNombreVariedad.text = variedad.nombre;
            txtTiempoProduccion.text = variedad.tiempo_produccion.toString();
            cmbResistencia.currentIndex = getResistenciaIndex(variedad.resistencia_zona);
        }
        
        function getTipoIndex(id_tipo) {
            for (let i = 0; i < tiposVariedadModel.count; i++) {
                if (tiposVariedadModel.get(i).value === id_tipo) {
                    return i;
                }
            }
            return 0;
        }
        
        function getResistenciaIndex(resistencia) {
            for (let i = 0; i < resistenciasModel.count; i++) {
                if (resistenciasModel.get(i).value === resistencia) {
                    return i;
                }
            }
            return 1; // Media por defecto
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 15
                columnSpacing: 10
                
                Text {
                    text: "Tipo de Cultivo:"
                    font.pixelSize: 14
                }
                
                ComboBox {
                    id: cmbTipoCultivo
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: tiposVariedadModel
                }
                
                Text {
                    text: "Nombre de Variedad:"
                    font.pixelSize: 14
                }
                
                TextField {
                    id: txtNombreVariedad
                    Layout.fillWidth: true
                    placeholderText: "Nombre de la variedad"
                }
                
                Text {
                    text: "Tiempo de Producción (días):"
                    font.pixelSize: 14
                }
                
                TextField {
                    id: txtTiempoProduccion
                    Layout.fillWidth: true
                    placeholderText: "Ej: 120"
                    validator: IntValidator { bottom: 1; top: 10000 }
                }
                
                Text {
                    text: "Resistencia a la Zona:"
                    font.pixelSize: 14
                }
                
                ComboBox {
                    id: cmbResistencia
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: resistenciasModel
                    currentIndex: 1 // Media por defecto
                }
            }
        }
        
        standardButtons: Dialog.Save | Dialog.Cancel
        
        onAccepted: {
            // Validar campos requeridos
            if (!txtNombreVariedad.text || txtNombreVariedad.text.trim() === "") {
                showMessage("Error: El nombre de la variedad es requerido");
                return;
            }
            
            // Preparar datos
            const datos = {
                id_tipo_cultivo: tiposVariedadModel.get(cmbTipoCultivo.currentIndex).value,
                nombre: txtNombreVariedad.text,
                tiempo_produccion: parseInt(txtTiempoProduccion.text) || 0,
                resistencia_zona: resistenciasModel.get(cmbResistencia.currentIndex).value,
                activo: true
            };
            
            let resultado;
            if (modo === "nuevo") {
                resultado = cultivos.agregar_variedad_cultivo(JSON.stringify(datos));
            } else {
                resultado = cultivos.actualizar_variedad(variedadId, JSON.stringify(datos));
            }
            
            if (resultado) {
                showMessage(modo === "nuevo" ? "Variedad creada exitosamente" : "Variedad actualizada exitosamente");
                cargarVariedades();
                actualizarVariedadesCombobox();
            } else {
                showMessage("Error al guardar la variedad");
            }
        }
    }

    // Diálogo para Nuevo/Editar Ciclo de Producción
    Dialog {
        id: dialogCicloProduccion
        title: modo === "nuevo" ? "Nuevo Ciclo de Producción" : "Editar Ciclo de Producción"
        modal: true
        width: 600
        height: 500
        anchors.centerIn: parent
        
        property string modo: "nuevo"
        property int cicloId: 0
        
        function cargarCiclo(id) {
            cicloId = id;
            
            // Buscar el ciclo en el modelo
            for (let i = 0; i < ciclosModel.count; i++) {
                if (ciclosModel.get(i).id_ciclo === id) {
                    const ciclo = ciclosModel.get(i);
                    
                    cmbParcelas.currentIndex = getParcelaIndex(ciclo.id_parcela);
                    cmbVariedades.currentIndex = getVariedadIndex(ciclo.id_variedad);
                    txtAreaSembrada.text = ciclo.area_sembrada.toString();
                    txtDensidad.text = (ciclo.densidad_siembra || 0).toString();
                    cmbEstado.currentIndex = getEstadoIndex(ciclo.estado);
                    txtFechaSiembra.text = ciclo.fecha_siembra || "";
                    txtFechaCosechaEst.text = ciclo.fecha_cosecha_estimada || "";
                    
                    break;
                }
            }
        }
        
        ScrollView {
            anchors.fill: parent
            clip: true
            
            GridLayout {
                width: dialogCicloProduccion.width - 40
                columns: 2
                rowSpacing: 15
                columnSpacing: 10
                
                Text {
                    text: "Parcela:"
                    font.pixelSize: 14
                }
                
                ComboBox {
                    id: cmbParcelas
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: parcelasModel
                }
                
                Text {
                    text: "Variedad:"
                    font.pixelSize: 14
                }
                
                ComboBox {
                    id: cmbVariedades
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: variedadesCicloModel
                }
                
                Text {
                    text: "Área Sembrada (ha):"
                    font.pixelSize: 14
                }
                
                TextField {
                    id: txtAreaSembrada
                    Layout.fillWidth: true
                    placeholderText: "Ej: 2.5"
                    validator: DoubleValidator { bottom: 0.01; top: 10000.0; decimals: 2 }
                }
                
                Text {
                    text: "Densidad de Siembra:"
                    font.pixelSize: 14
                }
                
                TextField {
                    id: txtDensidad
                    Layout.fillWidth: true
                    placeholderText: "Plantas por hectárea"
                    validator: IntValidator { bottom: 1; top: 1000000 }
                }
                
                Text {
                    text: "Estado:"
                    font.pixelSize: 14
                }
                
                ComboBox {
                    id: cmbEstado
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: estadosModel
                }
                
                Text {
                    text: "Fecha de Siembra:"
                    font.pixelSize: 14
                }
                
                TextField {
                    id: txtFechaSiembra
                    Layout.fillWidth: true
                    placeholderText: "YYYY-MM-DD"
                }
                
                Text {
                    text: "Fecha Cosecha Estimada:"
                    font.pixelSize: 14
                }
                
                TextField {
                    id: txtFechaCosechaEst
                    Layout.fillWidth: true
                    placeholderText: "YYYY-MM-DD"
                }
            }
        }
        
        standardButtons: Dialog.Save | Dialog.Cancel
        
        onAccepted: {
            // Validar campos requeridos
            if (cmbParcelas.currentIndex <= 0) {
                showMessage("Error: Debe seleccionar una parcela");
                return;
            }
            
            if (!txtAreaSembrada.text || txtAreaSembrada.text.trim() === "") {
                showMessage("Error: El área sembrada es requerida");
                return;
            }
            
            // Preparar datos
            const datos = {
                id_parcela: parcelasModel.get(cmbParcelas.currentIndex).value,
                id_variedad: variedadesCicloModel.get(cmbVariedades.currentIndex).value,
                area_sembrada: parseFloat(txtAreaSembrada.text),
                densidad_siembra: parseInt(txtDensidad.text) || 0,
                estado: estadosModel.get(cmbEstado.currentIndex).value,
                fecha_siembra: txtFechaSiembra.text,
                fecha_cosecha_estimada: txtFechaCosechaEst.text,
                activo: true
            };
            
            let resultado;
            if (modo === "nuevo") {
                resultado = cultivos.agregar_ciclo_produccion(JSON.stringify(datos));
            } else {
                resultado = cultivos.actualizar_ciclo_produccion(cicloId, JSON.stringify(datos));
            }
            
            if (resultado) {
                showMessage(modo === "nuevo" ? "Ciclo creado exitosamente" : "Ciclo actualizado exitosamente");
                cargarCiclosProduccion();
            } else {
                showMessage("Error al guardar el ciclo de producción");
            }
        }
    }
}
