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

    Timer {
        id: calendarioTimer
        interval: 1000 // 1 segundo de espera
        repeat: false
        onTriggered: {
            console.log("Actualizando calendario después de cargar datos...")
            actualizarCalendarioAnual()
        }
    }

    // FUNCIONEES
    // Función para formatear la fecha actual
    function getFormattedDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); // Los meses empiezan en 0
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
                // Fallback: Usar parcelas simuladas o mostrar mensaje de error
                console.log("Error: obtener_parcelas_activas no está disponible");
                // Puedes añadir algunas parcelas de prueba como fallback
                parcelasModel.append({"text": "Parcela 1", "value": 1});
                parcelasModel.append({"text": "Parcela 2", "value": 2});
            }
        } catch(e) {
            console.error("Error al cargar parcelas:", e);
        }
    }

    function cargarTiposCultivo() {
        console.log("Cargando tipos de cultivo con paginación...")
        
        // Llamar al método paginado del modelo Python
        var datosPagina = cultivos.obtener_tipos_paginado(paginaActualTipos, tiposPorPagina)
        
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
                
            // Actualizar las celdas del calendario (si existe el repeater del calendario viejo)
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
        
        // Código original de cargarEventosCalendario aquí...
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
        console.log("=== DEBUG: eventosPorFecha completo:", JSON.stringify(eventosPorFecha))
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
        const estados = ["Planificado", "En Preparación", "Sembrado", "En Desarrollo", "En Cosecha", "Finalizado", "Cancelado"];
        const index = estados.indexOf(estado);
        return index >= 0 ? index : 0;
    }

    // Función para obtener el color correspondiente a un estado
    function getEstadoColor(estado) {
        switch (estado) {
            case "Planificado": return "#2196F3"; // Azul
            case "En Preparación": return "#FF9800"; // Naranja
            case "Sembrado": return "#4CAF50"; // Verde
            case "En Desarrollo": return "#8BC34A"; // Verde claro
            case "En Cosecha": return "#FFC107"; // Amarillo
            case "Finalizado": return "#9E9E9E"; // Gris
            case "Cancelado": return "#F44336"; // Rojo
            default: return "#2196F3"; // Azul (por defecto)
        }
    }
    // Funciones para cargar datos desde el modelo de Python
    function cargarCiclosProduccion() {
        console.log("=== DEBUG: cargarCiclosProduccion INICIADO ===")
        console.log("Cargando ciclos de producción con paginación...")
        
        var datosPagina = cultivos.obtener_ciclos_paginado(paginaActualCiclos, ciclosPorPagina)
        
        console.log("=== DEBUG: Datos recibidos del backend ===")
        console.log("- datosPagina existe:", !!datosPagina)
        console.log("- datosPagina.ciclos existe:", !!(datosPagina && datosPagina.ciclos))
        console.log("- Número de ciclos:", datosPagina && datosPagina.ciclos ? datosPagina.ciclos.length : "NINGUNO")
        
        ciclosModel.clear()
        
        if (datosPagina && datosPagina.ciclos) {
            var ciclos = datosPagina.ciclos
            console.log("=== DEBUG: Primer ciclo recibido ===", JSON.stringify(ciclos[0]))
            
            for (let i = 0; i < ciclos.length; i++) {
                const ciclo = ciclos[i]
                const cicloFormateado = {
                    id_ciclo: ciclo.id_ciclo || 0,
                    id_parcela: ciclo.id_parcela || 0,
                    id_variedad: ciclo.id_variedad || 0,
                    fecha_siembra: ciclo.fecha_siembra || "",
                    fecha_cosecha_estimada: ciclo.fecha_cosecha_estimada || "",
                    fecha_cosecha_real: ciclo.fecha_cosecha_real || "",
                    area_sembrada: parseFloat(ciclo.area_sembrada || 0),
                    densidad_siembra: parseInt(ciclo.densidad_siembra || 0),
                    estado: ciclo.estado || "Planificado",
                    activo: !!ciclo.activo,
                    fecha_floracion: ciclo.fecha_floracion || "",
                    fecha_poda: ciclo.fecha_poda || "",
                    fecha_limpieza: ciclo.fecha_limpieza || "",
                    frecuencia_limpieza: parseInt(ciclo.frecuencia_limpieza || 1),
                    nombre_parcela: ciclo.nombre_parcela || "Sin parcela",
                    nombre_variedad: ciclo.nombre_variedad || "Sin variedad",
                    nombre_tipo_cultivo: ciclo.nombre_tipo_cultivo || "Sin tipo"
                }
                ciclosModel.append(cicloFormateado)
            }
            
            totalPaginasCiclos = datosPagina.total_paginas || 1
            paginaActualCiclos = datosPagina.pagina_actual || 1
            
            console.log(`Ciclos cargados: ${ciclos.length}, Página: ${paginaActualCiclos}/${totalPaginasCiclos}`)
            console.log("=== DEBUG: ciclosModel.count después de cargar:", ciclosModel.count)
        } else {
            console.log("=== ERROR: No hay datosPagina o ciclos ===")
        }
        
        console.log("=== DEBUG: Ejecutando funciones relacionadas ===")
        actualizarEstadosFiltro()
        actualizarParcelasCombobox()
        actualizarVariedadesCombobox()
        actualizarCultivosFiltro()
        cargarEventosCalendario()
        actualizarEstadosCalendario()
        actualizarParcelasCalendario()
        console.log("=== DEBUG: Todas las funciones ejecutadas ===")
    }
    // Actualizar opciones de estados para el filtro de ciclos
    function actualizarEstadosFiltro() {
        // Preservar selección actual si existe
        const seleccionActual = cmbFiltroEstados.currentText;
        
        // Limpiar modelo excepto el primer elemento "Todos los estados"
        while (estadosFiltroModel.count > 1) {
            estadosFiltroModel.remove(1);
        }    
        // Añadir estados desde la lista de estados válidos
        const estados = ["Planificado", "En Preparación", "Sembrado", "En Desarrollo", "En Cosecha", "Finalizado", "Cancelado"];
        for (let i = 0; i < estados.length; i++) {
            estadosFiltroModel.append({
                text: estados[i],
                value: estados[i]
            });
        }
        
        // Restaurar selección si posible
        if (seleccionActual) {
            for (let i = 0; i < estadosFiltroModel.count; i++) {
                if (estadosFiltroModel.get(i).text === seleccionActual) {
                    cmbFiltroEstados.currentIndex = i;
                    break;
                }
            }
        }
    }
    
    

    // Función para parsear fechas de la base de datos (formato YYYY-MM-DD)
    function parseDBDate(dateStr) {
        // Si la fecha está en formato DD/MM/YYYY
        if (dateStr.includes('/')) {
            const parts = dateStr.split('/');
            if (parts.length === 3) {
                const day = parseInt(parts[0], 10);
                const month = parseInt(parts[1], 10) - 1; // Los meses en JS empiezan en 0
                const year = parseInt(parts[2], 10);
                return new Date(year, month, day);
            }
        } 
        // Si la fecha está en formato YYYY-MM-DD
        else if (dateStr.includes('-')) {
            const parts = dateStr.split('-');
            if (parts.length === 3) {
                const year = parseInt(parts[0], 10);
                const month = parseInt(parts[1], 10) - 1; // Los meses en JS empiezan en 0
                const day = parseInt(parts[2], 10);
                return new Date(year, month, day);
            }
        }
        
        return null;
    }
    // Funciones de interacción con la BD a través del modelo Python

    // Guardar nuevo tipo de cultivo
    function guardarNuevoTipoCultivo() {
        // Validar datos
        if (nuevoTipoCultivo.nombre.trim() === "") {
            showMessage("Por favor, ingrese al menos el nombre del tipo de cultivo");
            return;
        }
        
        // Convertir objeto a JSON para enviarlo al modelo Python
        const tipoJSON = JSON.stringify(nuevoTipoCultivo);
        
        // Llamar al método del modelo Python
        const success = cultivos.agregar_tipo_cultivo(tipoJSON);
        
        if (success) {
            // Recargar tipos de cultivo
            cultivos.cargar_tipos_cultivo();
            cargarTiposCultivo();
            
            // Ocultar formulario de edición
            mostrarFilaEdicionTipo = false;
            
            // Mensaje de éxito
            showMessage("Tipo de cultivo guardado correctamente");
        } else {
            showMessage("Error al guardar el tipo de cultivo");
        }
    }

    // Actualizar tipo de cultivo existente
    function actualizarTipoCultivo() {
        // Verificar que haya un tipo seleccionado
        if (tiposCultivoListView.currentIndex < 0) {
            showMessage("Por favor, seleccione un tipo de cultivo para actualizar");
            return;
        }
        
        // Obtener el ID del tipo seleccionado
        const tipo = tiposCultivoModel.get(tiposCultivoListView.currentIndex);
        const id_tipo = tipo.id_tipo_cultivo;
        
        // Crear objeto con los datos actualizados
        const datosActualizados = {
            nombre: txtNombreTipo.text,
            nombre_cientifico: txtNombreCientifico.text,
            tiempo_cosecha_min: spinTiempoMin.value,
            tiempo_cosecha_max: spinTiempoMax.value,
            descripcion: txtDescripcion.text,
            activo: chkActivo.checked
        };
        
        // Convertir objeto a JSON
        const tipoJSON = JSON.stringify(datosActualizados);
        
        // Llamar al método del modelo Python
        const success = cultivos.actualizar_tipo_cultivo(id_tipo, tipoJSON);
        
        if (success) {
            // Recargar tipos de cultivo
            cultivos.cargar_tipos_cultivo();
            cargarTiposCultivo();
            
            // Mensaje de éxito
            showMessage("Tipo de cultivo actualizado correctamente");
        } else {
            showMessage("Error al actualizar el tipo de cultivo");
        }
    }

    // Eliminar tipo de cultivo
    function eliminarTipoCultivo(id_tipo) {
        // Llamar al método del modelo Python
        const success = cultivos.eliminar_tipo_cultivo(id_tipo);
        
        if (success) {
            // Recargar tipos de cultivo
            cultivos.cargar_tipos_cultivo();
            cargarTiposCultivo();
            
            // Mensaje de éxito
            showMessage("Tipo de cultivo eliminado correctamente");
        } else {
            showMessage("No se puede eliminar el tipo de cultivo. Puede tener variedades asociadas.");
        }
    }

    // Desactivar tipo de cultivo
    function desactivarTipoCultivo(id_tipo) {
        // Llamar al método del modelo Python
        const success = cultivos.desactivar_tipo_cultivo(id_tipo);
        
        if (success) {
            // Recargar tipos de cultivo
            cultivos.cargar_tipos_cultivo();
            cargarTiposCultivo();
            
            // Mensaje de éxito
            showMessage("Tipo de cultivo desactivado correctamente");
        } else {
            showMessage("Error al desactivar el tipo de cultivo");
        }
    }

    // Guardar nueva variedad
    function guardarNuevaVariedad() {
        // Validaciones hechas en el botón Guardar del diálogo
        
        // Convertir objeto a JSON
        const variedadJSON = JSON.stringify(nuevaVariedad);
        
        // Llamar al método del modelo Python
        const success = cultivos.agregar_variedad_cultivo(variedadJSON);
        
        if (success) {
            // Recargar variedades
            cultivos.cargar_variedades();
            cargarVariedades();
            
            // Cerrar el diálogo
            dialogNuevaVariedad.close();
            
            // Mensaje de éxito
            showMessage("Variedad guardada correctamente");
        } else {
            mensajeValidacionVariedad.text = "Error al guardar la variedad";
        }
    }

    // Editar variedad existente
    function editarVariedad(variedad) {
        // Abrir diálogo con datos cargados
        dialogNuevaVariedad.title = "Editar Variedad";
        
        // Cargar datos de la variedad en los campos
        cmbTipoCultivo.currentIndex = getTipoIndex(variedad.id_tipo_cultivo);
        txtNombreVariedad.text = variedad.nombre;
        txtTiempoProduccion.text = (variedad.tiempo_produccion || 0).toString();
        cmbResistencia.currentIndex = getResistenciaIndex(variedad.resistencia_zona);
        
        // Guardar ID para actualización
        nuevaVariedad = {
            id_tipo_cultivo: variedad.id_tipo_cultivo,
            nombre: variedad.nombre,
            tiempo_produccion: variedad.tiempo_produccion || 0,
            resistencia_zona: variedad.resistencia_zona || "Media",
            activo: variedad.activo
        };
        
        // Variable para identificar que estamos en modo edición
        dialogNuevaVariedad.editing = true;
        dialogNuevaVariedad.variedadId = variedad.id_variedad;
        
        dialogNuevaVariedad.open();
    }

    // Función para obtener índice de tipo de cultivo en combobox
    function getTipoIndex(id_tipo_cultivo) {
        for (let i = 0; i < tiposVariedadModel.count; i++) {
            if (tiposVariedadModel.get(i).value === id_tipo_cultivo) {
                return i;
            }
        }
        return 0;
    }

    // Función para obtener índice de resistencia en combobox
    function getResistenciaIndex(resistencia) {
        const resistencias = ["Alta", "Media", "Baja"];
        const index = resistencias.indexOf(resistencia);
        return index >= 0 ? index : 1; // Por defecto "Media"
    }

    // Eliminar variedad
    function eliminarVariedad(id_variedad) {
        // Llamar al método del modelo Python
        const success = cultivos.eliminar_variedad_cultivo(id_variedad);
        
        if (success) {
            // Recargar variedades
            cultivos.cargar_variedades();
            cargarVariedades();
            
            // Mensaje de éxito
            showMessage("Variedad eliminada correctamente");
        } else {
            showMessage("No se puede eliminar la variedad. Puede tener ciclos de producción asociados.");
        }
    }

    // Guardar nuevo ciclo de producción
    function guardarNuevoCiclo() {
        // Validaciones hechas en el botón Guardar del diálogo
        
        // Convertir objeto a JSON
        const cicloJSON = JSON.stringify(nuevoCiclo);
        
        // Llamar al método del modelo Python
        const success = cultivos.agregar_ciclo_produccion(cicloJSON);
        
        if (success) {
            // Recargar ciclos
            cultivos.cargar_ciclos_produccion();
            cargarCiclosProduccion();
            
            // Cerrar el diálogo
            dialogCicloProduccion.close();
            
            // Mensaje de éxito
            showMessage("Ciclo de producción guardado correctamente");
        } else {
            mensajeValidacionCiclo.text = "Error al guardar el ciclo de producción";
        }
    }

    // Actualizar ciclo de producción existente
    function actualizarCiclo() {
        // Crear objeto con los datos actualizados
        const datosActualizados = {
            id_parcela: parcelasModel.get(cmbParcelas.currentIndex).value,
            id_variedad: variedadesCicloModel.get(cmbVariedades.currentIndex).value,
            fecha_siembra: txtFechaSiembra.text,
            fecha_cosecha_estimada: txtFechaCosechaEst.text,
            fecha_cosecha_real: txtFechaCosechaReal.text,
            area_sembrada: parseFloat(txtAreaSembrada.text),
            densidad_siembra: txtDensidad.value,
            estado: cmbEstado.currentText,
            activo: ciclo_chkActivo.checked,
            fecha_floracion: txtFechaFloracion.text,
            fecha_poda: txtFechaPoda.text,
            fecha_limpieza: txtFechaLimpieza.text,
            frecuencia_limpieza: txtFrecuenciaLimpieza.value
        };
        
        // Convertir objeto a JSON
        const cicloJSON = JSON.stringify(datosActualizados);
        
        // Llamar al método del modelo Python
        const success = cultivos.actualizar_ciclo_produccion(dialogCicloProduccion.cicloId, cicloJSON);
        
        if (success) {
            // Recargar ciclos
            cultivos.cargar_ciclos_produccion();
            cargarCiclosProduccion();
            
            // Cerrar el diálogo
            dialogCicloProduccion.close();
            
            // Mensaje de éxito
            showMessage("Ciclo de producción actualizado correctamente");
        } else {
            mensajeValidacionCiclo.text = "Error al actualizar el ciclo de producción";
        }
    }

    // Eliminar ciclo de producción
    function eliminarCiclo(id_ciclo) {
        // Llamar al método del modelo Python
        const success = cultivos.eliminar_ciclo_produccion(id_ciclo);
        
        if (success) {
            // Recargar ciclos
            cultivos.cargar_ciclos_produccion();
            cargarCiclosProduccion();
            
            // Mensaje de éxito
            showMessage("Ciclo de producción eliminado correctamente");
        } else {
            showMessage("Error al eliminar el ciclo de producción");
        }
    }

    // Funciones de filtrado

    // Filtrar tipos de cultivo por texto de búsqueda
    function filtrarTiposCultivo() {
        const textoBusqueda = txtBuscarTipoCultivo.text.toLowerCase().trim();
        
        // Siempre recargar todos los tipos primero para tener datos completos
        cultivos.cargar_tipos_cultivo();
        
        // Solo entonces cargar al modelo local
        tiposCultivoModel.clear();
        var tipos = cultivos.tipos_cultivo;
        
        // Si no hay texto de búsqueda, mostrar todos
        if (textoBusqueda === "") {
            for (let i = 0; i < tipos.length; i++) {
                let tipo = tipos[i];
                tiposCultivoModel.append({
                    id_tipo_cultivo: tipo.id_tipo_cultivo,
                    nombre: tipo.nombre,
                    nombre_cientifico: tipo.nombre_cientifico || "",
                    tiempo_cosecha_min: tipo.tiempo_cosecha_min || 0,
                    tiempo_cosecha_max: tipo.tiempo_cosecha_max || 0,
                    descripcion: tipo.descripcion || "",
                    activo: tipo.activo
                });
            }
            return;
        }
        
        // Filtrar por texto
        for (let i = 0; i < tipos.length; i++) {
            let tipo = tipos[i];
            if (tipo.nombre.toLowerCase().includes(textoBusqueda) ||
                (tipo.nombre_cientifico && tipo.nombre_cientifico.toLowerCase().includes(textoBusqueda)) ||
                (tipo.descripcion && tipo.descripcion.toLowerCase().includes(textoBusqueda))) {
                
                tiposCultivoModel.append({
                    id_tipo_cultivo: tipo.id_tipo_cultivo,
                    nombre: tipo.nombre,
                    nombre_cientifico: tipo.nombre_cientifico || "",
                    tiempo_cosecha_min: tipo.tiempo_cosecha_min || 0,
                    tiempo_cosecha_max: tipo.tiempo_cosecha_max || 0,
                    descripcion: tipo.descripcion || "",
                    activo: tipo.activo
                });
            }
        }
        
        console.log("Filtro aplicado, resultados encontrados: " + tiposCultivoModel.count);
    }

    // Filtrar variedades por texto de búsqueda
    function filtrarVariedades() {
        const textoBusqueda = txtBuscarVariedad.text.toLowerCase().trim();
        
        // Primero, obtener datos actualizados del backend de Python
        if (cmbFiltroTipos.currentIndex > 0) {
            var valorFiltro = cmbFiltroTipos.model.get(cmbFiltroTipos.currentIndex).value;
            cultivos.cargar_variedades_por_tipo(valorFiltro);
        } else {
            cultivos.cargar_variedades();
        }
        
        // Si no hay texto de búsqueda, mostrar todas las variedades
        if (textoBusqueda === "") {
            cargarVariedades();
            return;
        }
        
        // Obtener las variedades directamente del modelo Python
        const variedades = cultivos.variedades;
        
        // Limpiar el modelo QML actual
        variedadesModel.clear();
        
        // Filtrar y añadir cada variedad que coincida con la búsqueda
        for (let i = 0; i < variedades.length; i++) {
            const variedad = variedades[i];
            
            // Verificar coincidencia con el texto de búsqueda
            if ((variedad.nombre && variedad.nombre.toLowerCase().includes(textoBusqueda)) || 
                (variedad.nombre_tipo_cultivo && variedad.nombre_tipo_cultivo.toLowerCase().includes(textoBusqueda))) {
                
                // Crear un objeto con valores por defecto para cada propiedad
                variedadesModel.append({
                    id_variedad: variedad.id_variedad || 0,
                    id_tipo_cultivo: variedad.id_tipo_cultivo || 0,
                    nombre: variedad.nombre || "",
                    tiempo_produccion: variedad.tiempo_produccion || 0,
                    resistencia_zona: variedad.resistencia_zona || "Media",
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
            
            // Obtener estado seleccionado - Asegúrate de que sea texto
            const estado = cmbFiltroEstados.model.get(cmbFiltroEstados.currentIndex).text;
            
            // Recargar ciclos desde Python filtrando por estado
            cultivos.cargar_ciclos_por_estado(estado);
            cargarCiclosProduccion();
            
            // Aplicar filtro de texto si es necesario (sin llamar a filtrarCiclos)
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

        // Cargar estadísticas para este tipo de cultivo
        cargarEstadisticasCultivo(tipo.id_tipo_cultivo);
    }

    // Exportar ciclos a CSV
    function exportarCiclos() {
        // Implementación básica - En una aplicación real se usaría un diálogo de guardar
        let csv = "ID,Parcela,Variedad,Fecha Siembra,Fecha Cosecha Est.,Área (ha),Densidad,Estado\n";
        
        for (let i = 0; i < ciclosModel.count; i++) {
            const c = ciclosModel.get(i);
            csv += `${c.id_ciclo},${c.nombre_parcela},${c.nombre_variedad},${c.fecha_siembra || ""},${c.fecha_cosecha_estimada || ""},${c.area_sembrada},${c.densidad_siembra || 0},${c.estado}\n`;
        }
        
        // En una aplicación real, aquí guardaríamos el CSV a un archivo
        console.log("Exportar ciclos a CSV:");
        console.log(csv);
        
        showMessage("Función de exportación a CSV implementada. Revise la consola para ver el resultado.");
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
    // Función de exportación mejorada
    function exportarVariedades() {
        var csv = "ID,Tipo,Nombre,Tiempo (días),Rendimiento (ton/ha),Resistencia\n";
        
        for (let i = 0; i < variedadesModel.count; i++) {
            const v = variedadesModel.get(i);
            csv += `${v.id_variedad},${v.nombre_tipo_cultivo},${v.nombre},${v.tiempo_produccion || 0},${v.resistencia_zona}\n`;
        }
        
        // En lugar de usar clipboard, mostrar en una ventana emergente
        let dialog = Qt.createComponent("qrc:/qt-project.org/imports/QtQuick/Dialogs/SimpleDialog.qml").createObject(cultivosRoot, {
            text: "Copie los datos a continuación",
            detailedText: csv
        });
        
        if (dialog) {
            dialog.open();
        } else {
            // Alternativa si el diálogo no se puede crear
            showMessage("Datos exportados. Contenido guardado en la consola.");
            console.log(csv);
        }
    }
    function cargarCiclo(id) {
        cicloId = id;
        
        // Crear una variable temporal para almacenar el ciclo encontrado
        let cicloEncontrado = null;
        
        // Buscar el ciclo en el modelo
        for (let i = 0; i < ciclosModel.count; i++) {
            if (ciclosModel.get(i).id_ciclo === id) {
                cicloEncontrado = ciclosModel.get(i);
                break;
            }
        }
        
        // Si no encontramos el ciclo, salir
        if (!cicloEncontrado) return;
        
        // Usar callLater para evitar problemas de dependencia circular
        Qt.callLater(function() {
            cmbParcelas.currentIndex = getParcelaIndex(cicloEncontrado.id_parcela);
            cmbVariedades.currentIndex = getVariedadIndex(cicloEncontrado.id_variedad);
            txtAreaSembrada.text = cicloEncontrado.area_sembrada.toString();
            txtDensidad.text = (cicloEncontrado.densidad_siembra || 0).toString();
            cmbEstado.currentIndex = getEstadoIndex(cicloEncontrado.estado);
            ciclo_chkActivo.checked = cicloEncontrado.activo;
            
            // Fechas
            txtFechaSiembra.text = cicloEncontrado.fecha_siembra || "";
            txtFechaCosechaEst.text = cicloEncontrado.fecha_cosecha_estimada || "";
            txtFechaCosechaReal.text = cicloEncontrado.fecha_cosecha_real || "";
            txtFechaFloracion.text = cicloEncontrado.fecha_floracion || "";
            txtFechaPoda.text = cicloEncontrado.fecha_poda || "";
            txtFechaLimpieza.text = (cicloEncontrado.fecha_limpieza || 0).toString();
            txtFrecuenciaLimpieza.text = cicloEncontrado.frecuencia_limpieza || 1;
        });
    }

    // Función para cargar estadísticas del tipo de cultivo seleccionado
    function cargarEstadisticasCultivo(id_tipo_cultivo) {
        console.log("Cargando estadísticas para cultivo ID: " + id_tipo_cultivo);
        
        // Cargar estadísticas generales
        cultivos.cargar_estadisticas();
        
        // Contar variedades para este tipo
        let totalVariedades = 0;
        let totalCiclos = 0;
        let areaSembrada = 0;
        
        // Contar variedades activas para este tipo de cultivo
        for (let i = 0; i < variedadesModel.count; i++) {
            const variedad = variedadesModel.get(i);
            if (variedad.id_tipo_cultivo === id_tipo_cultivo && variedad.activo) {
                totalVariedades++;
            }
        }
        
        // Contar ciclos activos y área sembrada para las variedades de este tipo
        for (let i = 0; i < ciclosModel.count; i++) {
            const ciclo = ciclosModel.get(i);
            
            // Buscar si la variedad pertenece a este tipo
            for (let j = 0; j < variedadesModel.count; j++) {
                const variedad = variedadesModel.get(j);
                if (variedad.id_variedad === ciclo.id_variedad && 
                    variedad.id_tipo_cultivo === id_tipo_cultivo && 
                    ciclo.activo && 
                    ciclo.estado !== "Finalizado" && 
                    ciclo.estado !== "Cancelado") {
                    
                    totalCiclos++;
                    areaSembrada += ciclo.area_sembrada;
                    break;
                }
            }
        }
        
        // Actualizar los textos de estadísticas
        txtTotalVariedades.text = totalVariedades.toString();
        txtTotalCiclos.text = totalCiclos.toString();
        txtAreaSembradaTotal.text = areaSembrada.toFixed(2) + " ha";
        
        console.log("Estadísticas cargadas: Variedades=" + totalVariedades + 
                    ", Ciclos=" + totalCiclos + 
                    ", Área=" + areaSembrada.toFixed(2));
    }
    function actualizarVariedad() {
        // Crear objeto con datos actualizados
        const datosActualizados = {
            id_tipo_cultivo: tiposVariedadModel.get(cmbTipoCultivo.currentIndex).value,
            nombre: txtNombreVariedad.text,
            tiempo_produccion: spinTiempoProduccion.value,
            resistencia_zona: cmbResistencia.currentText,
            activo: true // Mantener activo por defecto
        };
        
        // Convertir a JSON
        const variedadJSON = JSON.stringify(datosActualizados);
        
        // Llamar al método del modelo Python
        const success = cultivos.actualizar_variedad_cultivo(dialogNuevaVariedad.variedadId, variedadJSON);
        
        if (success) {
            // Recargar variedades
            cultivos.cargar_variedades();
            cargarVariedades();
            
            // Cerrar el diálogo
            dialogNuevaVariedad.close();
            
        // Mensaje de éxito
        showMessage("Variedad actualizada correctamente");
        } else {
            mensajeValidacionVariedad.text = "Error al actualizar la variedad";
        }
    }
    
    // Propiedades para edición de tipos de cultivo
    property bool filtrandoEstado: false
    property bool filtrandoTexto: false

    property bool mostrarFilaEdicionTipo: false
    property var nuevoTipoCultivo: {
        "nombre": "", 
        "nombre_cientifico": "", 
        "tiempo_cosecha_min": 0,
        "tiempo_cosecha_max": 0,
        "descripcion": "",
        "activo": true
    }
    
    // Propiedades para edición de variedades
    property var nuevaVariedad: {
        "id_tipo_cultivo": 1,
        "nombre": "",
        "tiempo_produccion": 0,
        "resistencia_zona": "Media",
        "activo": true
    }

    property var nuevoCiclo: {
        "id_parcela": 1,
        "id_variedad": 1,
        "fecha_siembra": "",
        "fecha_cosecha_estimada": "",
        "fecha_cosecha_real": "",
        "area_sembrada": 0,
        "densidad_siembra": 0,
        "estado": "Planificado",
        "activo": true,
        "fecha_floracion": "",
        "fecha_poda": "",
        "fecha_limpieza": "",
        "frecuencia_limpieza": 1
    }
    
    // Propiedades para el calendario
    property var fechaActual: new Date()
    property var eventosPorFecha: ({})
    property var cicloSeleccionado: null

    // ListModels para filtros
    ListModel { id: cultivosFiltroModel }
    ListModel { id: estadosCalendarioModel }
    ListModel { id: parcelasCalendarioModel }
    ListModel {
        id: tipoEventoModel
        ListElement { text: "Todos los eventos"; value: "todos" }
        ListElement { text: "Solo Siembra"; value: "siembra" }
        ListElement { text: "Solo Cosecha"; value: "cosecha" }
        ListElement { text: "Solo Poda"; value: "poda" }
        ListElement { text: "Solo Floración"; value: "floracion" }
        ListElement { text: "Solo Limpieza"; value: "limpieza" }
    }
    Component.onCompleted: {
        console.log("Cargando datos desde el modelo Python...")
        cargarDatosIniciales()
    }

    function cargarDatosIniciales() {
        console.log("=== DEBUG: cargarDatosIniciales INICIADO ===")
        
        // Resetear paginación al inicio
        paginaActualTipos = 1
        paginaActualVariedades = 1
        paginaActualCiclos = 1
        
        // Primero cargar desde la base de datos
        cultivos.cargar_tipos_cultivo()
        cultivos.cargar_variedades()
        cultivos.cargar_ciclos_produccion()
        
        console.log("=== DEBUG: Datos cargados desde backend ===")
        
        // Luego actualizar los modelos locales con paginación
        cargarTiposCultivo()
        cargarVariedades()
        cargarCiclosProduccion()
        
        console.log("=== DEBUG: Modelos locales actualizados ===")
        
        // Usar un timer para darle tiempo a que los componentes del calendario se carguen
        calendarioTimer.start()
    }


    // Añade este Timer como propiedad en el componente principal
    Timer {
        id: cargarDatosTimer
        interval: 500 // 500 ms de retraso
        repeat: false
        onTriggered: {
            cargarTiposCultivo()
            cargarVariedades()
            cargarCiclosProduccion()
            actualizarCalendario()
        }
    }

    // Título de la página
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"
        

        Text {
            text: "GESTIÓN DE TIPOS Y VARIEDADES DE CULTIVOS"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.centerIn: parent
        }
    }
    
    // Barra de pestañas - TabBarComponent
    Item {
        id: modernTabBar
        width: parent.width - 40
        height: 90
        anchors.top: titleBar.bottom
        anchors.topMargin: 10
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

        // Página de Tipos de Cultivo
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
                                text: "Tipos de Cítricos"
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
                            model: ListModel { id: tiposCultivoModel }
                            spacing: 5
                            
                            delegate: Rectangle {
                                width: ListView.view.width
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
                                        text: nombre_cientifico || ""
                                        font.pixelSize: 12
                                        font.italic: true
                                        color: "#757575"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        tiposCultivoListView.currentIndex = index
                                        mostrarFilaEdicionTipo = false
                                        cargarDetallesTipoCultivo(model)
                                    }
                                }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "No hay tipos de cultivo registrados.\nHaga clic en 'Nuevo' para agregar uno."
                                color: "#757575"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                visible: tiposCultivoModel.count === 0
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: "transparent"
                            
                            Paginator {
                                id: paginadorTipos
                                width: Math.min(parent.width * 0.6, 400)
                                height: 40
                                anchors.centerIn: parent
                                currentPage: paginaActualTipos
                                totalPages: totalPaginasTipos
                                
                                onPageChanged: {
                                    paginaActualTipos = newPage
                                    cargarTiposCultivo()
                                }
                            }
                        }
                    }
                }
                
                // Marco 2: Detalles, información y formulario de edición
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 5
                    border.color: "#EEEEEE"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20
                        
                        // Cabecera con título y botones
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
                                            placeholderText: "Ej: 365"
                                            validator: IntValidator { bottom: 1; top: 10000 }
                                            onTextChanged: {
                                                if (mostrarFilaEdicionTipo && text.trim() !== "") {
                                                    nuevoTipoCultivo.tiempo_cosecha_max = parseInt(text)
                                                }
                                            }
                                        }
                                        
                                        // Estado
                                        Text {
                                            text: "Estado:"
                                            font.pixelSize: 14
                                        }
                                        
                                        CheckBox {
                                            id: chkActivo
                                            text: "Activo"
                                            checked: true
                                            onCheckedChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.activo = checked
                                        }
                                        
                                        // Descripción
                                        Text {
                                            text: "Descripción:"
                                            font.pixelSize: 14
                                        }
                                        
                                        TextArea {
                                            id: txtDescripcion
                                            Layout.fillWidth: true
                                            Layout.minimumHeight: 80
                                            placeholderText: "Descripción del tipo de cultivo"
                                            wrapMode: TextArea.Wrap
                                            onTextChanged: if (mostrarFilaEdicionTipo) nuevoTipoCultivo.descripcion = text
                                        }
                                    }
                                }
                            }
                            
                            // Índice 1: Vista de información y estadísticas
                            Item {
                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 20
                                    
                                    // Estadísticas de producción
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 150
                                        color: "#F5F5F5"
                                        radius: 5
                                        
                                        ColumnLayout{
                                            anchors.fill: parent
                                            anchors.margins: 15
                                            spacing: 10
                                            
                                            Text {
                                                text: "Estadísticas del Cultivo"
                                                font.bold: true
                                                font.pixelSize: 16
                                            }
                                            
                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                spacing: 15
                                                
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    color: "#E8F5E9"
                                                    radius: 5
                                                    
                                                    Column {
                                                        anchors.centerIn: parent
                                                        spacing: 5
                                                        
                                                        Text {
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            text: "Variedades"
                                                            font.pixelSize: 14
                                                        }
                                                        
                                                        Text {
                                                            id: txtTotalVariedades
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            text: "0"
                                                            font.pixelSize: 24
                                                            font.bold: true
                                                            color: "#4CAF50"
                                                        }
                                                    }
                                                }
                                                
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    color: "#E1F5FE"
                                                    radius: 5
                                                    
                                                    Column {
                                                        anchors.centerIn: parent
                                                        spacing: 5
                                                        
                                                        Text {
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            text: "Ciclos Activos"
                                                            font.pixelSize: 14
                                                        }
                                                        
                                                        Text {
                                                            id: txtTotalCiclos
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            text: "0"
                                                            font.pixelSize: 24
                                                            font.bold: true
                                                            color: "#2196F3"
                                                        }
                                                    }
                                                }
                                                
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    color: "#FFF8E1"
                                                    radius: 5
                                                    
                                                    Column {
                                                        anchors.centerIn: parent
                                                        spacing: 5
                                                        
                                                        Text {
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            text: "Área Sembrada"
                                                            font.pixelSize: 14
                                                        }
                                                        
                                                        Text {
                                                            id: txtAreaSembradaTotal
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            text: "0 ha"
                                                            font.pixelSize: 24
                                                            font.bold: true
                                                            color: "#FF9800"
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Item { Layout.fillHeight: true }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Página de Variedades
        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: 20
                // Barra de acción
                Rectangle {
                    //id: variedades  nose que poner
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
                                    source: "recursos/image/icons/lupa.png" // Cambia por tu ruta
                                    width: 16
                                    height: 16
                                }
                            }
                            onTextChanged: filtrarVariedades()
                        }

                        ComboBox {
                            id: cmbFiltroTipos
                            Layout.preferredWidth: 200
                            textRole: "text" // Asegurar que se usa la propiedad correcta
                            valueRole: "value"
                            model: ListModel { 
                                id: tiposFiltroModel 
                                ListElement { text: "Todos los tipos"; value: 0 }
                            }

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
                        model: ListModel { id: variedadesModel }
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
                                    text: "Tipo"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.2
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
                                    width: parent.width * 0.15
                                    height: parent.height
                                    text: "Rendimiento"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                
                                Text {
                                    width: parent.width * 0.15
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
                        
                        // Delegado para cada fila
                        delegate: Rectangle {
                            width: cultivosRoot.width
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
                                        text: id_variedad
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                // Tipo
                                Rectangle {
                                    width: parent.width * 0.15
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
                                    width: parent.width * 0.2
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
                                
                                // Rendimiento
                                
                                // Resistencia
                                Rectangle {
                                    width: parent.width * 0.15
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
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "transparent"
                    
                    Paginator {
                        id: paginadorVariedades
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaActualVariedades
                        totalPages: totalPaginasVariedades
                        
                        onPageChanged: {
                            paginaActualVariedades = newPage
                            cargarVariedades()
                        }
                    }
                }
            }
        }

        // Página de Ciclos de Producción
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
                                dialogCicloProduccion.modo = "crear";
                                dialogCicloProduccion.open();
                            }
                        }
                        
                        TextField {
                            id: txtBuscarCiclo
                            Layout.preferredWidth: 250
                            placeholderText: "Buscar ciclos..."
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
                                    source: "recursos/image/icons/lupa.png" // Cambia por tu ruta
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
                            model: ListModel { 
                                id: estadosFiltroModel
                                ListElement { text: "Todos los estados"; value: "" }
                                // Otros elementos se añadirán dinámicamente
                            }
                            implicitHeight: 36
                            onCurrentIndexChanged: {
                                // Evitar procesamiento durante la carga inicial
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
                        model: ListModel { id: ciclosModel }
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
                                        text: fecha_siembra || "No definida"
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
                                        text: fecha_cosecha_estimada || "No definida"
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
                                                // Abrir el diálogo de edición con los datos del ciclo seleccionado
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
                                                // Mostrar diálogo de confirmación
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
                // NAVEGACIÓN DE CICLOS - Agregar después del ListView ciclosListView
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "transparent"
                    
                    Paginator {
                        id: paginadorCiclos
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaActualCiclos
                        totalPages: totalPaginasCiclos
                        
                        onPageChanged: {
                            paginaActualCiclos = newPage
                            cargarCiclosProduccion()
                        }
                    }
                }
            }
        }
        // Página de Calendario de Cultivos
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
                            color: "#9A6829"
                        }
                        
                        // Filtro Cultivos
                        Rectangle {
                            id: filterCultivos
                            Layout.preferredWidth: 180
                            height: 40
                            radius: 6
                            color: "#FAFAFA"
                            border.color: "#CCCCCC"
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (popupCultivos.visible) popupCultivos.close()
                                    else popupCultivos.open()
                                }
                                onEntered: parent.border.color = "#999999"
                                onExited: {
                                    if (!popupCultivos.visible) parent.border.color = "#CCCCCC"
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8
                                
                                Text {
                                    id: textCultivos
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: cultivosFiltroModel.count > 0 ? cultivosFiltroModel.get(filterCultivos.cmbFiltroCultivosCalendario).text : "Todos los cultivos"
                                    color: "#333333"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    width: parent.width - 40
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: popupCultivos.visible ? "▲" : "▼"
                                    color: "#666666"
                                    font.pixelSize: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            property int cmbFiltroCultivosCalendario: 0
                            
                            Popup {
                                id: popupCultivos
                                width: filterCultivos.width
                                height: Math.min(cultivosFiltroModel.count * 38, 300)
                                y: filterCultivos.height + 2
                                x: 0
                                padding: 0
                                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                                
                                background: Rectangle {
                                    color: "white"
                                    radius: 6
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                }
                                
                                contentItem: ListView {
                                    anchors.fill: parent
                                    clip: true
                                    model: cultivosFiltroModel
                                    
                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 38
                                        color: index === filterCultivos.cmbFiltroCultivosCalendario ? "#5C6BC0" : 
                                              (delegateMA.containsMouse ? "#E8EAF6" : "white")
                                        
                                        MouseArea {
                                            id: delegateMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            
                                            onClicked: {
                                                filterCultivos.cmbFiltroCultivosCalendario = index
                                                aplicarFiltrosCalendario()
                                                popupCultivos.close()
                                            }
                                        }
                                        
                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            text: model.text
                                            color: index === filterCultivos.cmbFiltroCultivosCalendario ? "white" : "#333333"
                                            font.pixelSize: 12
                                            font.bold: index === filterCultivos.cmbFiltroCultivosCalendario
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                    
                                    ScrollBar.vertical: ScrollBar {
                                        width: 6
                                        policy: cultivosFiltroModel.count * 38 > 300 ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                                        background: Rectangle { color: "transparent" }
                                        contentItem: Rectangle {
                                            color: "#C0C0C0"
                                            radius: 3
                                        }
                                    }
                                }
                            }
                            
                            Component.onCompleted: {
                                cultivosFiltroModel.clear()
                                cultivosFiltroModel.append({text: "Todos los cultivos", value: "todos"})
                                actualizarCultivosFiltro()
                            }
                        }
                        
                        // Filtro Estados
                        Rectangle {
                            id: filterEstados
                            Layout.preferredWidth: 150
                            height: 40
                            radius: 6
                            color: "#FAFAFA"
                            border.color: "#CCCCCC"
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (popupEstados.visible) popupEstados.close()
                                    else popupEstados.open()
                                }
                                onEntered: parent.border.color = "#999999"
                                onExited: {
                                    if (!popupEstados.visible) parent.border.color = "#CCCCCC"
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: estadosCalendarioModel.count > 0 ? estadosCalendarioModel.get(filterEstados.currentIndex).text : "Todos los estados"
                                    color: "#333333"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    width: parent.width - 40
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: popupEstados.visible ? "▲" : "▼"
                                    color: "#666666"
                                    font.pixelSize: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            property int currentIndex: 0
                            
                            Popup {
                                id: popupEstados
                                width: filterEstados.width
                                height: Math.min(estadosCalendarioModel.count * 38, 300)
                                y: filterEstados.height + 2
                                x: 0
                                padding: 0
                                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                                
                                background: Rectangle {
                                    color: "white"
                                    radius: 6
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                }
                                
                                contentItem: ListView {
                                    anchors.fill: parent
                                    clip: true
                                    model: estadosCalendarioModel
                                    
                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 38
                                        color: index === filterEstados.currentIndex ? "#5C6BC0" : 
                                              (delegateMA2.containsMouse ? "#E8EAF6" : "white")
                                        
                                        MouseArea {
                                            id: delegateMA2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            
                                            onClicked: {
                                                filterEstados.currentIndex = index
                                                aplicarFiltrosCalendario()
                                                popupEstados.close()
                                            }
                                        }
                                        
                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            text: model.text
                                            color: index === filterEstados.currentIndex ? "white" : "#333333"
                                            font.pixelSize: 12
                                            font.bold: index === filterEstados.currentIndex
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                            
                            Component.onCompleted: {
                                estadosCalendarioModel.clear()
                                estadosCalendarioModel.append({text: "Todos los estados", value: "todos"})
                                actualizarEstadosCalendario()
                            }
                        }
                        
                        // Filtro Parcelas
                        Rectangle {
                            id: filterParcelas
                            Layout.preferredWidth: 150
                            height: 40
                            radius: 6
                            color: "#FAFAFA"
                            border.color: "#CCCCCC"
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (popupParcelas.visible) popupParcelas.close()
                                    else popupParcelas.open()
                                }
                                onEntered: parent.border.color = "#999999"
                                onExited: {
                                    if (!popupParcelas.visible) parent.border.color = "#CCCCCC"
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: parcelasCalendarioModel.count > 0 ? parcelasCalendarioModel.get(filterParcelas.currentIndex).text : "Todas las parcelas"
                                    color: "#333333"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    width: parent.width - 40
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: popupParcelas.visible ? "▲" : "▼"
                                    color: "#666666"
                                    font.pixelSize: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            property int currentIndex: 0
                            
                            Popup {
                                id: popupParcelas
                                width: filterParcelas.width
                                height: Math.min(parcelasCalendarioModel.count * 38, 300)
                                y: filterParcelas.height + 2
                                x: 0
                                padding: 0
                                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                                
                                background: Rectangle {
                                    color: "white"
                                    radius: 6
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                }
                                
                                contentItem: ListView {
                                    anchors.fill: parent
                                    clip: true
                                    model: parcelasCalendarioModel
                                    
                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 38
                                        color: index === filterParcelas.currentIndex ? "#5C6BC0" : 
                                              (delegateMA3.containsMouse ? "#E8EAF6" : "white")
                                        
                                        MouseArea {
                                            id: delegateMA3
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            
                                            onClicked: {
                                                filterParcelas.currentIndex = index
                                                aplicarFiltrosCalendario()
                                                popupParcelas.close()
                                            }
                                        }
                                        
                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            text: model.text
                                            color: index === filterParcelas.currentIndex ? "white" : "#333333"
                                            font.pixelSize: 12
                                            font.bold: index === filterParcelas.currentIndex
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                            
                            Component.onCompleted: {
                                parcelasCalendarioModel.clear()
                                parcelasCalendarioModel.append({text: "Todas las parcelas", value: "todas"})
                                actualizarParcelasCalendario()
                            }
                        }
                        
                        // Filtro Tipo Evento
                        Rectangle {
                            id: filterTipoEvento
                            Layout.preferredWidth: 150
                            height: 40
                            radius: 6
                            color: "#FAFAFA"
                            border.color: "#CCCCCC"
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (popupTipoEvento.visible) popupTipoEvento.close()
                                    else popupTipoEvento.open()
                                }
                                onEntered: parent.border.color = "#999999"
                                onExited: {
                                    if (!popupTipoEvento.visible) parent.border.color = "#CCCCCC"
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8
                                
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: filterTipoEvento.currentIndex < tipoEventoModel.count ? tipoEventoModel.get(filterTipoEvento.currentIndex).text : "Todos los eventos"
                                    color: "#333333"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    width: parent.width - 40
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: popupTipoEvento.visible ? "▲" : "▼"
                                    color: "#666666"
                                    font.pixelSize: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            property int currentIndex: 0
                            
                            Popup {
                                id: popupTipoEvento
                                width: filterTipoEvento.width
                                height: Math.min(tipoEventoModel.count * 38, 300)
                                y: filterTipoEvento.height + 2
                                x: 0
                                padding: 0
                                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                                
                                background: Rectangle {
                                    color: "white"
                                    radius: 6
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                }
                                
                                contentItem: ListView {
                                    anchors.fill: parent
                                    clip: true
                                    model: tipoEventoModel
                                    
                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 38
                                        color: index === filterTipoEvento.currentIndex ? "#5C6BC0" : 
                                              (delegateMA4.containsMouse ? "#E8EAF6" : "white")
                                        
                                        MouseArea {
                                            id: delegateMA4
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            
                                            onClicked: {
                                                filterTipoEvento.currentIndex = index
                                                aplicarFiltrosCalendario()
                                                popupTipoEvento.close()
                                            }
                                        }
                                        
                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            text: model.text
                                            color: index === filterTipoEvento.currentIndex ? "white" : "#333333"
                                            font.pixelSize: 12
                                            font.bold: index === filterTipoEvento.currentIndex
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "Limpiar Filtros"
                            icon.source: "recursos/image/icons/restaurar.png"
                            implicitHeight: 32
                            background: Rectangle {
                                color: parent.hovered ? "#E65A00" : "#FF9800"
                                radius: height / 2
                            }
                            contentItem: Row {
                                anchors.centerIn: parent
                                spacing: 6
                                
                                Image {
                                    width: 16
                                    height: 16
                                    source: "recursos/image/icons/restaurar.png"
                                    fillMode: Image.PreserveAspectFit
                                }
                                
                                Text {
                                    text: "Limpiar Filtros"
                                    color: "white"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            onClicked: limpiarFiltrosCalendario()
                        }
                    
                    }
                    
                    // Selector de mes y año
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: "#F5F5F5"
                        radius: 5
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15
                            
                            Button {
                                text: ""
                                icon.source: "recursos/image/icons/flechaizquierda.png"
                                implicitHeight: 30
                                implicitWidth: 40
                                background: Rectangle {
                                    color: parent.hovered ? "#7A5020" : "#9A6829"
                                    radius: height / 2
                                }
                                contentItem: Image {
                                    anchors.centerIn: parent
                                    width: 18
                                    height: 18
                                    source: "recursos/image/icons/flechaizquierda.png"
                                    fillMode: Image.PreserveAspectFit
                                }
                                onClicked: {
                                    // Restar un año
                                    var nuevaFecha = new Date(fechaActual);
                                    nuevaFecha.setFullYear(nuevaFecha.getFullYear() - 1);
                                    fechaActual = nuevaFecha;
                                    txtTituloCalendario.text = "Calendario de Ciclos " + fechaActual.getFullYear();
                                    actualizarCalendarioAnual();
                                }
                            }
                            Item { Layout.fillWidth: true }

                            Text {
                                text: "Año " + fechaActual.getFullYear()
                                font.pixelSize: 18
                                font.bold: true
                                color: "#9A6829"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                text: ""
                                icon.source: "recursos/image/icons/flechaderecha.png"
                                implicitHeight: 30
                                implicitWidth: 40
                                background: Rectangle {
                                    color: parent.hovered ? "#7A5020" : "#9A6829"
                                    radius: height / 2
                                }
                                contentItem: Image {
                                    anchors.centerIn: parent
                                    width: 18
                                    height: 18
                                    source: "recursos/image/icons/flechaderecha.png"
                                    fillMode: Image.PreserveAspectFit
                                }
                                onClicked: {
                                    // Sumar un año
                                    var nuevaFecha = new Date(fechaActual);
                                    nuevaFecha.setFullYear(nuevaFecha.getFullYear() + 1);
                                    fechaActual = nuevaFecha;
                                    txtTituloCalendario.text = "Calendario de Ciclos " + fechaActual.getFullYear();
                                    actualizarCalendarioAnual();
                                }
                            }
                        }
                    }
                    
                    // Grid de 12 meses (4 filas x 3 columnas)
                    Grid {
                        Layout.fillWidth: true
                        columns: 7
                        spacing: 1
                    }

                    // Grid de 12 meses (4 filas x 3 columnas)
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        Grid {
                            id: yearGrid
                            width: calendarContainer.width - 30
                            columns: 3
                            spacing: 8
                            
                            // Repetir para 12 meses
                            Repeater {
                                id: monthsRepeater
                                model: 12
                                
                                // Componente de mes individual
                                Rectangle {
                                    width: (yearGrid.width - 16) / 3  // 3 columnas con spacing
                                    height: 200
                                    color: "white"
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                    radius: 4
                                    
                                    property int monthIndex: index
                                    property string monthName: obtenerNombreMes(index)
                                    
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        spacing: 2
                                        
                                        // Cabecera del mes
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 25
                                            color: "#9A6829"
                                            radius: 2
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: parent.parent.parent.monthName
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: "white"
                                            }
                                        }
                                        
                                        // Días de la semana (pequeños)
                                        Grid {
                                            Layout.fillWidth: true
                                            columns: 7
                                            spacing: 1
                                            
                                            Repeater {
                                                model: ["L", "M", "X", "J", "V", "S", "D"]
                                                
                                                Rectangle {
                                                    width: (parent.parent.parent.width - 18) / 7
                                                    height: 15
                                                    color: "#E8F5E9"
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData
                                                        font.pixelSize: 8
                                                        font.bold: true
                                                        color: "#333"
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Días del mes
                                        Grid {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            columns: 7
                                            spacing: 1
                                            
                                            Repeater {
                                                id: daysRepeater
                                                model: 42  // 6 semanas máximo
                                                
                                                Rectangle {
                                                    width: (parent.parent.parent.width - 18) / 7
                                                    height: 18
                                                    border.width: 0.5
                                                    border.color: "#E0E0E0"
                                                    
                                                    property int dayNumber: 0
                                                    property bool isCurrentMonth: false
                                                    property bool isToday: false
                                                    property var dayEvents: []
                                                    
                                                    // Color de fondo basado en eventos y estado
                                                    color: {
                                                        if (dayNumber <= 0 || !isCurrentMonth) return "#F8F8F8";
                                                        if (isToday) return "#FFF8E1";
                                                        if (dayEvents.length > 0) {
                                                            // Si hay eventos, usar el color del primer evento (prioridad)
                                                            return dayEvents[0].color;
                                                        }
                                                        return "white";
                                                    }
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: parent.dayNumber > 0 && parent.isCurrentMonth ? parent.dayNumber : ""
                                                        font.pixelSize: 10
                                                        font.bold: parent.isToday
                                                        color: {
                                                            if (parent.dayNumber <= 0 || !parent.isCurrentMonth) return "#BDBDBD";
                                                            if (parent.dayEvents.length > 0) return "white";
                                                            if (parent.isToday) return "#9A6829";
                                                            return "#333333";
                                                        }
                                                    }
                                                    
                                                    // Indicadores de múltiples eventos
                                                    Row {
                                                        anchors.bottom: parent.bottom
                                                        anchors.right: parent.right
                                                        anchors.margins: 1
                                                        spacing: 1
                                                        
                                                        Repeater {
                                                            model: Math.min(parent.parent.dayEvents.length, 3)
                                                            
                                                            Rectangle {
                                                                width: 3
                                                                height: 3
                                                                radius: 1.5
                                                                color: parent.parent.parent.dayEvents[index] ? parent.parent.parent.dayEvents[index].color : "transparent"
                                                                visible: parent.parent.parent.dayEvents.length > 1
                                                            }
                                                        }
                                                    }
                                                    
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        onClicked: {
                                                            if (parent.dayNumber > 0 && parent.isCurrentMonth && parent.dayEvents.length > 0) {
                                                                // Abrir diálogo con detalles de eventos
                                                                mostrarDetallesEventos(parent.dayNumber, parent.parent.parent.parent.parent.monthIndex, fechaActual.getFullYear(), parent.dayEvents);
                                                            }
                                                        }
                                                        onEntered: {
                                                            if (parent.dayEvents.length > 0) {
                                                                parent.border.width = 2;
                                                                parent.border.color = "#9A6829";
                                                            }
                                                        }
                                                        onExited: {
                                                            parent.border.width = 0.5;
                                                            parent.border.color = "#E0E0E0";
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Component.onCompleted: {
                                        updateMonthCalendar(monthIndex);
                                    }
                                }
                            }
                        }
                    }
                    
                    // Leyenda de colores
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        color: "#F5F5F5"
                        radius: 5
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 20
                            
                            Repeater {
                                model: [
                                    {text: "Siembra", color: "#2E7D32"},
                                    {text: "Cosecha", color: "#FF9800"},
                                    {text: "Poda", color: "#9C27B0"},
                                    {text: "Floración", color: "#2196F3"},
                                    {text: "Limpieza", color: "#795548"}
                                ]
                                
                                Row {
                                    spacing: 4
                                    
                                    Rectangle {
                                        width: 12
                                        height: 12
                                        radius: 6
                                        color: modelData.color
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Text {
                                        text: modelData.text
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
        // DIÁLOGO DE NUEVA VARIEDAD
        Dialog {
            id: dialogNuevaVariedad
            title: "Nueva Variedad"
            modal: true
            width: 500
            height: 600
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            property bool editing: false
            property int variedadId: -1
            
            // Contenido del diálogo
            contentItem: Rectangle {
                color: "white"
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // Título
                    Text {
                        text: "Agregar Nueva Variedad"
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
                        
                        // Tipo de cultivo
                        Text {
                            text: "Tipo de cultivo:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        ComboBox {
                            id: cmbTipoCultivo
                            Layout.fillWidth: true
                            model: ListModel { id: tiposVariedadModel }
                            textRole: "text"
                            valueRole: "value"
                            Component.onCompleted: actualizarTiposCombobox()
                            onCurrentIndexChanged: {
                                if (currentIndex >= 0) {
                                    nuevaVariedad.id_tipo_cultivo = model.get(currentIndex).value
                                }
                            }
                        }
                        
                        // Nombre de variedad
                        Text {
                            text: "Nombre de variedad:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtNombreVariedad
                            placeholderText: "Ingrese nombre de variedad"
                            Layout.fillWidth: true
                            onTextChanged: nuevaVariedad.nombre = text
                        }
                        
                        // Tiempo de producción
                        Text {
                            text: "Tiempo de producción (días):"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtTiempoProduccion
                            Layout.fillWidth: true
                            placeholderText: "Ej: 120"
                            validator: IntValidator { bottom: 0; top: 500 }
                            onTextChanged: {
                                if (text.trim() !== "") {
                                    nuevaVariedad.tiempo_produccion = parseInt(text)
                                }
                            }
                        }
                        
                        // Rendimiento
                        Text {
                            text: "Rendimiento (ton/ha):"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        // Resistencia
                        Text {
                            text: "Resistencia:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        ComboBox {
                            id: cmbResistencia
                            Layout.fillWidth: true
                            model: ["Alta", "Media", "Baja"]
                            currentIndex: 1 // Media por defecto
                            onCurrentTextChanged: {
                                nuevaVariedad.resistencia_zona = currentText
                            }
                        }
                        
                        // Fecha de registro
                        Text {
                            text: "Fecha de registro:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextField {
                            id: txtFechaRegistro
                            placeholderText: "DD/MM/AAAA"
                            Layout.fillWidth: true
                            readOnly: true
                            text: getFormattedDate() // Llamamos a la función para obtener la fecha formateada
                        }
                        
                        // Descripción
                        Text {
                            text: "Descripción:"
                            Layout.alignment: Qt.AlignRight
                        }
                        
                        TextArea {
                            id: txtDescripcionVariedad
                            placeholderText: "Descripción de la variedad (opcional)"
                            Layout.fillWidth: true
                            Layout.rowSpan: 3
                            Layout.minimumHeight: 80
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
                        id: mensajeValidacionVariedad
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
                    onClicked: dialogNuevaVariedad.close()
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
                        if (txtNombreVariedad.text === "" || cmbTipoCultivo.currentIndex < 0) {
                            mensajeValidacionVariedad.text = "Por favor, complete todos los campos obligatorios";
                            return;
                        }
                        
                        // Validar que haya tipos de cultivo disponibles
                        if (tiposVariedadModel.count === 0) {
                            mensajeValidacionVariedad.text = "Debe crear al menos un tipo de cultivo primero";
                            return;
                        }
                        
                        // Determinar si estamos en modo edición o creación
                        if (dialogNuevaVariedad.editing) {
                            actualizarVariedad();
                        } else {
                            guardarNuevaVariedad();
                        }
                    }
                }
            }
            
            // Resetea el formulario al cerrar
            onClosed: {
                txtNombreVariedad.text = ""
                txtRendimiento.text = ""
                spinTiempoProduccion.value = 0
                cmbResistencia.currentIndex = 1
                txtDescripcionVariedad.text = ""
                mensajeValidacionVariedad.text = ""
                editing = false // Resetear modo edición
                variedadId = -1 // Resetear ID de variedad
            }
        }
    
        // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR VARIEDAD
        Dialog {
            id: confirmDeleteVariedadDialog
            title: "Confirmar eliminación"
            modal: true
            width: 400
            height: 180
            
            property int variedadId: -1
            property string nombreVariedad: ""
            
            contentItem: Item {
                implicitWidth: 400
                implicitHeight: 100
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    Text {
                        width: parent.width
                        text: "¿Está seguro que desea eliminar la variedad '" + confirmDeleteVariedadDialog.nombreVariedad + "'?"
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
                eliminarVariedad(variedadId)
            }
        }
        // DIÁLOGO DE CICLO DE PRODUCCIÓN
        // DIÁLOGO DE CICLO DE PRODUCCIÓN MEJORADO
        Dialog {
            id: dialogCicloProduccion
            title: modo === "crear" ? "Nuevo Ciclo de Producción" : "Editar Ciclo de Producción"
            modal: true
            width: 700
            height: 650
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            
            property string modo: "crear" // "crear" o "editar"
            property int cicloId: -1

            function cargarCiclo(id) {
                dialogCicloProduccion.cicloId = id;
                
                // Buscar el ciclo en el modelo
                let cicloEncontrado = null;
                for (let i = 0; i < ciclosModel.count; i++) {
                    if (ciclosModel.get(i).id_ciclo === id) {
                        cicloEncontrado = ciclosModel.get(i);
                        break;
                    }
                }
                
                // Si no encontramos el ciclo, salir
                if (!cicloEncontrado) return;
                
                // Cargar datos en los campos
                cmbParcelas.currentIndex = getParcelaIndex(cicloEncontrado.id_parcela);
                cmbVariedades.currentIndex = getVariedadIndex(cicloEncontrado.id_variedad);
                txtAreaSembrada.text = cicloEncontrado.area_sembrada.toString();
                txtDensidad.text = cicloEncontrado.densidad_siembra || 0;
                cmbEstado.currentIndex = getEstadoIndex(cicloEncontrado.estado);
                ciclo_chkActivo.checked = cicloEncontrado.activo;
                
                // Fechas
                txtFechaSiembra.text = cicloEncontrado.fecha_siembra || "";
                txtFechaCosechaEst.text = cicloEncontrado.fecha_cosecha_estimada || "";
                txtFechaCosechaReal.text = cicloEncontrado.fecha_cosecha_real || "";
                txtFechaFloracion.text = cicloEncontrado.fecha_floracion || "";
                txtFechaPoda.text = cicloEncontrado.fecha_poda || "";
                txtFechaLimpieza.text = cicloEncontrado.fecha_limpieza || "";
                txtFrecuenciaLimpieza.text = (cicloEncontrado.frecuencia_limpieza || 1).toString();
            }

            // Contenido del diálogo
            contentItem: Rectangle {
                color: "white"
                
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 15
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 15
                        
                        // Título
                        Text {
                            text: dialogCicloProduccion.modo === "crear" ? "Crear Nuevo Ciclo de Producción" : "Editar Ciclo de Producción"
                            font.pixelSize: 18
                            font.bold: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        // Formulario principal
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 15
                            rowSpacing: 15
                            
                            // Sección 1: Información básica
                            Text {
                                text: "Información Básica"
                                font.bold: true
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                Layout.columnSpan: 2
                                topPadding: 10
                                bottomPadding: 5
                            }
                            
                            // Parcela
                            Text {
                                text: "Parcela:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            ComboBox {
                                id: cmbParcelas
                                Layout.fillWidth: true
                                model: ListModel { id: parcelasModel }
                                textRole: "text"
                                valueRole: "value"
                                Component.onCompleted: actualizarParcelasCombobox()
                                onCurrentIndexChanged: {
                                    if (dialogCicloProduccion.modo === "crear" && currentIndex >= 0) {
                                        nuevoCiclo.id_parcela = model.get(currentIndex).value
                                    }
                                }
                            }
                            
                            // Variedad
                            Text {
                                text: "Variedad:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            ComboBox {
                                id: cmbVariedades
                                Layout.fillWidth: true
                                model: ListModel { id: variedadesCicloModel }
                                textRole: "text"
                                valueRole: "value"
                                Component.onCompleted: actualizarVariedadesCombobox()
                                onCurrentIndexChanged: {
                                    if (dialogCicloProduccion.modo === "crear" && currentIndex >= 0) {
                                        nuevoCiclo.id_variedad = model.get(currentIndex).value
                                    }
                                }
                            }
                            
                            // Estado
                            Text {
                                text: "Estado:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            ComboBox {
                                id: cmbEstado
                                Layout.fillWidth: true
                                model: ["Planificado", "En Preparación", "Sembrado", "En Desarrollo", "En Cosecha", "Finalizado", "Cancelado"]
                                currentIndex: 0
                                onCurrentTextChanged: {
                                    if (dialogCicloProduccion.modo === "crear") {
                                        nuevoCiclo.estado = currentText;
                                    }
                                }
                            }
                            
                            // Activo
                            Text {
                                text: "Activo:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            CheckBox {
                                id: ciclo_chkActivo
                                checked: true
                                onCheckedChanged: {
                                    if (dialogCicloProduccion.modo === "crear") {
                                        nuevoCiclo.activo = checked;
                                    }
                                }
                            }
                            
                            // Área sembrada
                            Text {
                                text: "Área sembrada (ha):"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            TextField {
                                id: txtAreaSembrada
                                Layout.fillWidth: true
                                validator: DoubleValidator { bottom: 0.01 }
                                placeholderText: "Ej: 2.5"
                                onTextChanged: {
                                    if (dialogCicloProduccion.modo === "crear" && text.trim() !== "") {
                                        nuevoCiclo.area_sembrada = parseFloat(text);
                                    }
                                }
                            }
                            
                            // Densidad de siembra
                            Text {
                                text: "Densidad (plantas/ha):"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            TextField {
                                id: txtDensidad
                                Layout.fillWidth: true
                                placeholderText: "Ej: 1000"
                                validator: IntValidator { bottom: 0; top: 10000 }
                                onTextChanged: {
                                    if (dialogCicloProduccion.modo === "crear" && text.trim() !== "") {
                                        nuevoCiclo.densidad_siembra = parseInt(text);
                                    }
                                }
                            }
                            
                            // Separador
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.columnSpan: 2
                                height: 1
                                color: "#EEEEEE"
                                Layout.topMargin: 10
                                Layout.bottomMargin: 5
                            }
                            
                            // Sección 2: Fechas importantes
                            Text {
                                text: "Fechas importantes"
                                font.bold: true
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                Layout.columnSpan: 2
                            }
                            
                            // Función para crear campos de fecha
                            function createDateField(parent, fieldId, placeholder) {
                                var component = Qt.createComponent("DateField.qml");
                                if (component.status === Component.Ready) {
                                    var field = component.createObject(parent, {
                                        placeholderText: placeholder
                                    });
                                    return field;
                                } else {
                                    console.error("Error creando componente:", component.errorString());
                                    return null;
                                }
                            }
                            
                            // Fecha de siembra
                            Text {
                                text: "Fecha de siembra:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                TextField {
                                    id: txtFechaSiembra
                                    Layout.fillWidth: true
                                    placeholderText: "DD/MM/AAAA"
                                    inputMask: "99/99/9999"
                                    selectByMouse: true
                                }
                                
                                Button {
                                    text: "Hoy"
                                    onClicked: {
                                        txtFechaSiembra.text = Qt.formatDate(new Date(), "dd/MM/yyyy");
                                        if (dialogCicloProduccion.modo === "crear") {
                                            nuevoCiclo.fecha_siembra = txtFechaSiembra.text;
                                        }
                                    }
                                }
                            }
                            
                            // Fecha de cosecha estimada
                            Text {
                                text: "Cosecha estimada:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                TextField {
                                    id: txtFechaCosechaEst
                                    Layout.fillWidth: true
                                    placeholderText: "DD/MM/AAAA"
                                    inputMask: "99/99/9999"
                                    selectByMouse: true
                                }
                                
                                Button {
                                    text: "Hoy"
                                    onClicked: {
                                        txtFechaCosechaEst.text = Qt.formatDate(new Date(), "dd/MM/yyyy");
                                        if (dialogCicloProduccion.modo === "crear") {
                                            nuevoCiclo.fecha_cosecha_estimada = txtFechaCosechaEst.text;
                                        }
                                    }
                                }
                            }
                            
                            // Fecha de cosecha real
                            Text {
                                text: "Cosecha real:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                TextField {
                                    id: txtFechaCosechaReal
                                    Layout.fillWidth: true
                                    placeholderText: "DD/MM/AAAA"
                                    inputMask: "99/99/9999"
                                    selectByMouse: true
                                }
                                
                                Button {
                                    text: "Hoy"
                                    onClicked: {
                                        txtFechaCosechaReal.text = Qt.formatDate(new Date(), "dd/MM/yyyy");
                                        if (dialogCicloProduccion.modo === "crear") {
                                            nuevoCiclo.fecha_cosecha_real = txtFechaCosechaReal.text;
                                        }
                                    }
                                }
                            }
                            
                            // Fecha de floración
                            Text {
                                text: "Fecha de floración:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                TextField {
                                    id: txtFechaFloracion
                                    Layout.fillWidth: true
                                    placeholderText: "DD/MM/AAAA"
                                    inputMask: "99/99/9999"
                                    selectByMouse: true
                                }
                                
                                Button {
                                    text: "Hoy"
                                    onClicked: {
                                        txtFechaFloracion.text = Qt.formatDate(new Date(), "dd/MM/yyyy");
                                        if (dialogCicloProduccion.modo === "crear") {
                                            nuevoCiclo.fecha_floracion = txtFechaFloracion.text;
                                        }
                                    }
                                }
                            }
                            
                            // Fecha de poda
                            Text {
                                text: "Fecha de poda:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                TextField {
                                    id: txtFechaPoda
                                    Layout.fillWidth: true
                                    placeholderText: "DD/MM/AAAA"
                                    inputMask: "99/99/9999"
                                    selectByMouse: true
                                }
                                
                                Button {
                                    text: "Hoy"
                                    onClicked: {
                                        txtFechaPoda.text = Qt.formatDate(new Date(), "dd/MM/yyyy");
                                        if (dialogCicloProduccion.modo === "crear") {
                                            nuevoCiclo.fecha_poda = txtFechaPoda.text;
                                        }
                                    }
                                }
                            }
                            
                            // Fecha última limpieza
                            Text {
                                text: "Fecha limpieza:"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                TextField {
                                    id: txtFechaLimpieza
                                    Layout.fillWidth: true
                                    placeholderText: "DD/MM/AAAA"
                                    inputMask: "99/99/9999"
                                    selectByMouse: true
                                }
                                
                                Button {
                                    text: "Hoy"
                                    onClicked: {
                                        txtFechaLimpieza.text = Qt.formatDate(new Date(), "dd/MM/yyyy");
                                        if (dialogCicloProduccion.modo === "crear") {
                                            nuevoCiclo.fecha_limpieza = txtFechaLimpieza.text;
                                        }
                                    }
                                }
                            }
                            
                            // Frecuencia de limpieza
                            Text {
                                text: "Frecuencia limpieza (meses):"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                            
                            TextField {
                                id: txtFrecuenciaLimpieza
                                Layout.fillWidth: true
                                placeholderText: "Ej: 3"
                                validator: IntValidator { bottom: 1; top: 12 }
                                onTextChanged: {
                                    if (dialogCicloProduccion.modo === "crear" && text.trim() !== "") {
                                        nuevoCiclo.frecuencia_limpieza = parseInt(text);
                                    }
                                }
                            }
                        }
                        
                        // Espacio adicional
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                        
                        // Mensaje de validación
                        Text {
                            id: mensajeValidacionCiclo
                            Layout.fillWidth: true
                            text: ""
                            color: "red"
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14
                        }
                    }
                }
            }
            
            footer: DialogButtonBox {
                Button {
                    text: "Cancelar"
                    DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                    onClicked: dialogCicloProduccion.close()
                }
                
                Button {
                    text: dialogCicloProduccion.modo === "crear" ? "Guardar" : "Actualizar"
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
                        if (txtAreaSembrada.text === "" || parseFloat(txtAreaSembrada.text) <= 0) {
                            mensajeValidacionCiclo.text = "Por favor, ingrese un área sembrada válida";
                            return;
                        }
                        
                        if (dialogCicloProduccion.modo === "crear") {
                            guardarNuevoCiclo();
                        } else {
                            actualizarCiclo();
                        }
                    }
                }
            }
            
            // Resetea el formulario al cerrar
            onClosed: {
                mensajeValidacionCiclo.text = "";
            }
            
            onOpened: {
                if (modo === "crear") {
                    // Resetear valores para un nuevo ciclo
                    cmbParcelas.currentIndex = 0;
                    cmbVariedades.currentIndex = 0;
                    txtAreaSembrada.text = "";
                    txtDensidad.text = "0";
                    cmbEstado.currentIndex = 0;
                    ciclo_chkActivo.checked = true;
                    
                    // Fechas
                    txtFechaSiembra.text = "";
                    txtFechaCosechaEst.text = "";
                    txtFechaCosechaReal.text = "";
                    txtFechaFloracion.text = "";
                    txtFechaPoda.text = "";
                    txtFechaLimpieza.text = "";
                    txtFrecuenciaLimpieza.text = "1";
                }
            }
        }
        // DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR CICLO
        Dialog {
            id: confirmDeleteCicloDialog
            title: "Confirmar eliminación"
            modal: true
            width: 400
            height: 180
            
            property int cicloId: -1
            property string nombreParcela: ""
            property string nombreVariedad: ""
            
            contentItem: Item {
                implicitWidth: 400
                implicitHeight: 100
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    Text {
                        width: parent.width
                        text: "¿Está seguro que desea eliminar el ciclo de producción '" + 
                            confirmDeleteCicloDialog.nombreVariedad + "' en parcela '" + 
                            confirmDeleteCicloDialog.nombreParcela + "'?"
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
                eliminarCiclo(cicloId);
            }
        }
        // AÑADE este diálogo debajo de tus otros diálogos
        Dialog {
            id: confirmDeleteTipoDialog
            title: "Confirmar eliminación"
            modal: true
            width: 400
            height: 180
            
            property int tipoId: -1
            property string nombreTipo: ""
            
            contentItem: Item {
                implicitWidth: 400
                implicitHeight: 100
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    Text {
                        width: parent.width
                        text: "¿Está seguro que desea eliminar el tipo de cultivo '" + 
                            confirmDeleteTipoDialog.nombreTipo + "'?"
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
                eliminarTipoCultivo(tipoId);
            }
        } // Hata aquiiiiiiiiiiiiiii
    }
    // =================================================================
    // PASO 4: SISTEMA DE DETALLES DE EVENTOS
    // =================================================================

    // DIÁLOGO PARA MOSTRAR DETALLES DE EVENTOS (AGREGAR EN LA SECCIÓN DE DIÁLOGOS)
    Dialog {
        id: dialogDetallesEventos
        title: "Detalles de Eventos"
        modal: true
        width: 600
        height: 500
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        
        property string fechaSeleccionada: ""
        property var eventosDelDia: []
        
        contentItem: Rectangle {
            color: "white"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Título con fecha
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "#9A6829"
                    radius: 5
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Eventos del " + dialogDetallesEventos.fechaSeleccionada
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                    }
                }
                
                // Lista de eventos
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ListView {
                        id: listEventos
                        model: ListModel { id: eventosDetallsModel }
                        spacing: 10
                        
                        delegate: Rectangle {
                            width: listEventos.width
                            height: 120
                            color: "#F8F9FA"
                            radius: 8
                            border.color: eventoColor
                            border.width: 3
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 8
                                
                                // Cabecera del evento
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: eventoColor
                                    }
                                    
                                    Text {
                                        text: tipoEvento
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#2E7D32"
                                        Layout.fillWidth: true
                                    }
                                    
                                    Rectangle {
                                        Layout.preferredWidth: 80
                                        height: 25
                                        radius: 12
                                        color: getEstadoColor(estadoCiclo)
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: estadoCiclo
                                            font.pixelSize: 10
                                            color: "white"
                                            font.bold: true
                                        }
                                    }
                                }
                                
                                // Detalles del evento
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 15
                                    rowSpacing: 5
                                    
                                    Text {
                                        text: "Variedad:"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#555"
                                    }
                                    Text {
                                        text: nombreVariedad
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: "Parcela:"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#555"
                                    }
                                    Text {
                                        text: nombreParcela
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: "Área:"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#555"
                                    }
                                    Text {
                                        text: areaSembrada + " ha"
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: "Tipo Cultivo:"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#555"
                                    }
                                    Text {
                                        text: tipoCultivo
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // Ir a la sección de ciclos y resaltar este ciclo
                                    tabBar.currentIndex = 2; // Cambiar a pestaña Ciclos
                                    resaltarCiclo(idCiclo);
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay eventos
                        Text {
                            anchors.centerIn: parent
                            text: "No hay eventos para esta fecha"
                            color: "#757575"
                            font.pixelSize: 14
                            visible: listEventos.count === 0
                        }
                    }
                }
                
                // Estadísticas del día
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#E8F5E9"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 20
                        
                        Column {
                            spacing: 2
                            Text {
                                text: "Total Eventos"
                                font.pixelSize: 12
                                color: "#555"
                            }
                            Text {
                                text: eventosDetallsModel.count.toString()
                                font.pixelSize: 18
                                font.bold: true
                                color: "#2E7D32"
                            }
                        }
                        
                        Column {
                            spacing: 2
                            Text {
                                text: "Área Total"
                                font.pixelSize: 12
                                color: "#555"
                            }
                            Text {
                                id: txtAreaTotal
                                text: "0 ha"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#2E7D32"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Cerrar"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: dialogDetallesEventos.close()
            }
            
            Button {
                text: "Ver en Ciclos"
                DialogButtonBox.buttonRole: DialogButtonBox.ActionRole
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
                    tabBar.currentIndex = 2; // Cambiar a pestaña Ciclos
                    dialogDetallesEventos.close();
                }
            }
        }
    }   
    function actualizarCalendarioAnual() {
        try {
            // Asegurarse de que fechaActual es una fecha válida
            if (!(fechaActual instanceof Date) || isNaN(fechaActual.getTime())) {
                fechaActual = new Date(); // Restablecer a fecha actual si es inválida
            }
            
            // Actualizar eventos del calendario
            cargarEventosCalendario();
            
            // Usar un pequeño delay para asegurar que los componentes están listos
            Qt.callLater(function() {
                // Actualizar cada mes en el grid
                for (var month = 0; month < 12; month++) {
                    updateMonthCalendar(month);
                }
                console.log("Calendario anual actualizado para el año:", fechaActual.getFullYear());
            });
        } catch (e) {
            console.error("Error al actualizar calendario anual:", e);
        }
    }
    // Función para actualizar un mes específico en el calendario anual
    function updateMonthCalendar(monthIndex) {
        try {
            // Usar setTimeout para asegurar que los componentes estén completamente cargados
            Qt.callLater(function() {
                var monthComponent = monthsRepeater.itemAt(monthIndex);
                if (!monthComponent) {
                    console.log("No se pudo encontrar el componente del mes:", monthIndex);
                    return;
                }
                
                var year = fechaActual.getFullYear();
                
                // Calcular el primer día del mes
                var primerDia = new Date(year, monthIndex, 1);
                var diaSemana = primerDia.getDay();
                if (diaSemana === 0) diaSemana = 7; // Domingo es 0, lo convertimos a 7
                diaSemana--; // Ajustamos para que lunes sea 0
                
                // Calcular el número de días en el mes
                var ultimoDia = new Date(year, monthIndex + 1, 0);
                var diasEnMes = ultimoDia.getDate();
                
                // Obtener fecha actual real para comparar
                var hoy = new Date();
                var esAnoActual = year === hoy.getFullYear();
                var esMesActual = monthIndex === hoy.getMonth() && esAnoActual;
                
                // Intentar encontrar el repeater de días de manera más directa
                var daysRepeater = null;
                try {
                    // Navegar por la estructura del mes: Rectangle -> ColumnLayout -> Grid -> Repeater
                    var columnLayout = monthComponent.children[0];
                    if (columnLayout && columnLayout.children) {
                        // El grid de días debería ser el último hijo (índice 2)
                        var daysGrid = columnLayout.children[2];
                        if (daysGrid && daysGrid.children) {
                            daysRepeater = daysGrid.children[0]; // El Repeater dentro del Grid
                        }
                    }
                } catch (e) {
                    console.error("Error navegando estructura del mes:", e);
                    return;
                }
                
                if (!daysRepeater || typeof daysRepeater.itemAt !== "function") {
                    console.log("No se pudo encontrar el repeater de días para el mes:", monthIndex);
                    return;
                }
                
                // Actualizar cada día del mes
                for (var i = 0; i < 42; i++) {
                    try {
                        var dayItem = daysRepeater.itemAt(i);
                        if (dayItem) {
                            var diaMes = i - diaSemana + 1;
                            
                            dayItem.dayNumber = diaMes > 0 && diaMes <= diasEnMes ? diaMes : 0;
                            dayItem.isCurrentMonth = diaMes > 0 && diaMes <= diasEnMes;
                            dayItem.isToday = esMesActual && diaMes === hoy.getDate();
                            
                            // Obtener eventos para este día
                            if (dayItem.isCurrentMonth) {
                                dayItem.dayEvents = getEventsForDay(diaMes, monthIndex, year);
                            } else {
                                dayItem.dayEvents = [];
                            }
                        }
                    } catch (dayError) {
                        console.error("Error actualizando día", i, "del mes", monthIndex, ":", dayError);
                    }
                }
                
                console.log("Mes", monthIndex, "actualizado correctamente");
            });
        } catch (e) {
            console.error("Error al actualizar mes", monthIndex, ":", e);
        }
    }
    // Función auxiliar para encontrar el repeater de días en un componente de mes
    function findDaysRepeater(monthComponent) {
        try {
            // Navegar por la estructura para encontrar el repeater de días
            var columnLayout = monthComponent.children[0]; // ColumnLayout principal
            if (!columnLayout) return null;
            
            var daysGrid = null;
            // Buscar el Grid que contiene los días (debería ser el último elemento)
            for (var i = columnLayout.children.length - 1; i >= 0; i--) {
                var child = columnLayout.children[i];
                if (child && child.children && child.children.length > 0) {
                    // Buscar el Repeater dentro del Grid
                    for (var j = 0; j < child.children.length; j++) {
                        if (child.children[j] && typeof child.children[j].itemAt === "function") {
                            daysGrid = child.children[j];
                            break;
                        }
                    }
                    if (daysGrid) break;
                }
            }
            
            return daysGrid;
        } catch (e) {
            console.error("Error al buscar repeater de días:", e);
            return null;
        }
    }
    // Función para mostrar detalles de eventos de un día específico
    function mostrarDetallesEventos(day, month, year, events) {
        if (events.length === 0) return;
        
        // Establecer fecha seleccionada
        dialogDetallesEventos.fechaSeleccionada = day + " de " + obtenerNombreMes(month) + " de " + year;
        
        // Limpiar modelo de eventos
        eventosDetallsModel.clear();
        
        var areaTotal = 0;
        
        // Procesar cada evento para obtener detalles completos
        for (let i = 0; i < events.length; i++) {
            const evento = events[i];
            const detallesEvento = obtenerDetallesEvento(evento, day, month, year);
            
            if (detallesEvento) {
                eventosDetallsModel.append(detallesEvento);
                areaTotal += parseFloat(detallesEvento.areaSembrada || 0);
            }
        }
        
        // Actualizar área total
        txtAreaTotal.text = areaTotal.toFixed(2) + " ha";
        
        // Abrir diálogo
        dialogDetallesEventos.open();
    }
    function obtenerDetallesEvento(evento, day, month, year) {
        try {
            // Buscar el ciclo correspondiente al evento
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
}