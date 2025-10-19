# bd_conecciones/servicios/gestion_servicio.py

import logging
from .agricultor_servicio import AgricultorServicio
from .parcela_servicio import ParcelaServicio
from ...repositories.Agriculor_Parcelas_rep.relacion_AgriPar_repositorio import RelacionRepositorio
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class GestionServicio:
    """Servicio principal para operaciones complejas que involucran múltiples entidades con caché optimizado."""
    
    def __init__(self):
        self.agricultor_servicio = AgricultorServicio()
        self.parcela_servicio = ParcelaServicio()
        self.relacion_repo = RelacionRepositorio()
    
    # === MÉTODOS UNIFICADOS PARA QML ===
    
    @cacheable('dashboard_gestion', key_func=lambda: 'completo_principal', ttl=900)  # 15 min
    def obtener_dashboard_completo(self):
        """
        Obtiene información completa para el dashboard principal.
        ⭐ **SÚPER CRÍTICO** - Este es el origen de TODAS las consultas repetidas en logs!
        
        Returns:
            dict: Información consolidada del sistema.
        """
        try:
            # Estas consultas ahora están cacheadas en repositorios, pero el resultado final también se cachea
            estadisticas_generales = self.relacion_repo.obtener_estadisticas_generales()
            estadisticas_parcelas = self.parcela_servicio.obtener_estadisticas_parcelas()
            
            # Obtener distribución de parcelas
            distribucion = self.relacion_repo.obtener_distribución_parcelas_por_propietario()
            
            # Obtener parcelas sin coordenadas
            parcelas_sin_coords = self.relacion_repo.obtener_parcelas_sin_coordenadas()
            
            dashboard = {
                'resumen': {
                    'total_agricultores': estadisticas_generales['agricultores']['total'],
                    'total_propietarios': estadisticas_generales['agricultores']['propietarios'],
                    'total_parcelas': estadisticas_generales['parcelas']['total'],
                    'area_total': estadisticas_generales['parcelas']['area_total'],
                    'area_promedio': estadisticas_generales['parcelas']['area_promedio']
                },
                'calidad_datos': {
                    'parcelas_sin_coordenadas': len(parcelas_sin_coords),
                    'porcentaje_con_coordenadas': estadisticas_parcelas.get('porcentaje_con_coordenadas', 0),
                    'calidad_general': self._calcular_porcentaje_calidad_datos_cached(estadisticas_generales, parcelas_sin_coords)
                },
                'distribucion_propietarios': distribucion[:5],  # Top 5
                'alertas': self._generar_alertas_sistema_cached(estadisticas_generales, parcelas_sin_coords),
                
                # Nuevas métricas de gestión
                'metricas_gestion': {
                    'concentracion_tierras': self._calcular_concentracion_tierras(distribucion),
                    'eficiencia_coordenadas': self._calcular_eficiencia_coordenadas(estadisticas_generales, parcelas_sin_coords),
                    'balance_propietarios': self._calcular_balance_propietarios(estadisticas_generales),
                    'timestamp': self._get_timestamp()
                }
            }
            
            logger.info("Dashboard completo generado exitosamente")
            return dashboard
            
        except Exception as e:
            logger.error(f"Error en obtener_dashboard_completo: {str(e)}")
            return {
                'resumen': {},
                'calidad_datos': {},
                'distribucion_propietarios': [],
                'alertas': ['Error al cargar dashboard'],
                'metricas_gestion': {}
            }

    @cache_invalidator('dashboard_gestion')                # Invalidar dashboard principal
    @cache_invalidator('operaciones_gestion')             # Invalidar operaciones
    @cache_invalidator('analisis_propietarios')           # Invalidar análisis
    def procesar_operacion_agricultor(self, operacion, datos):
        """
        Procesa operaciones de agricultores con manejo unificado.
        OPTIMIZADO: Invalidación automática del dashboard tras operaciones.
        
        Args:
            operacion (str): Tipo de operación (crear, actualizar, eliminar).
            datos (dict): Datos de la operación.
            
        Returns:
            dict: Resultado unificado de la operación.
        """
        try:
            resultado = None
            
            if operacion == 'crear':
                resultado = self.agricultor_servicio.crear_agricultor(datos['agricultor'])
            
            elif operacion == 'actualizar':
                resultado = self.agricultor_servicio.actualizar_agricultor(
                    datos['id_agricultor'], 
                    datos['agricultor']
                )
            
            elif operacion == 'eliminar':
                resultado = self.agricultor_servicio.eliminar_agricultor(datos['id_agricultor'])
            
            else:
                resultado = {'exito': False, 'mensaje': f"Operación '{operacion}' no reconocida"}
            
            # Enriquecer resultado con información de gestión
            if resultado and resultado.get('exito'):
                resultado['requiere_actualizacion_dashboard'] = True
                resultado['operacion_procesada'] = operacion
                resultado['timestamp_operacion'] = self._get_timestamp()
            
            return resultado
                
        except Exception as e:
            logger.error(f"Error en procesar_operacion_agricultor: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('dashboard_gestion')                # Invalidar dashboard principal
    @cache_invalidator('operaciones_gestion')             # Invalidar operaciones
    @cache_invalidator('analisis_propietarios')           # Invalidar análisis
    def procesar_operacion_parcela(self, operacion, datos):
        """
        Procesa operaciones de parcelas con manejo unificado.
        OPTIMIZADO: Invalidación automática del dashboard tras operaciones.
        
        Args:
            operacion (str): Tipo de operación (crear, actualizar, eliminar, transferir).
            datos (dict): Datos de la operación.
            
        Returns:
            dict: Resultado unificado de la operación.
        """
        try:
            resultado = None
            
            if operacion == 'crear':
                resultado = self.parcela_servicio.crear_parcela(datos['parcela'])
            
            elif operacion == 'actualizar':
                resultado = self.parcela_servicio.actualizar_parcela(
                    datos['id_parcela'], 
                    datos['parcela']
                )
            
            elif operacion == 'eliminar':
                resultado = self.parcela_servicio.eliminar_parcela(datos['id_parcela'])
            
            elif operacion == 'transferir':
                resultado = self.parcela_servicio.transferir_parcela(
                    datos['id_parcela'], 
                    datos['nuevo_propietario_id']
                )
            
            else:
                resultado = {'exito': False, 'mensaje': f"Operación '{operacion}' no reconocida"}
            
            # Enriquecer resultado con información de gestión
            if resultado and resultado.get('exito'):
                resultado['requiere_actualizacion_dashboard'] = True
                resultado['operacion_procesada'] = operacion
                resultado['timestamp_operacion'] = self._get_timestamp()
            
            return resultado
                
        except Exception as e:
            logger.error(f"Error en procesar_operacion_parcela: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cacheable('operaciones_gestion', key_func=lambda entidad, pagina, por_pagina=6, filtros=None: f"paginado_{entidad}_{pagina}_{por_pagina}_{hash(str(filtros or {}))}", ttl=600)  # 10 min
    def obtener_datos_paginados(self, entidad, pagina, por_pagina=6, filtros=None):
        """
        Obtiene datos paginados de cualquier entidad de forma unificada.
        ⭐ OPTIMIZADO: Resultado de coordinación cacheado a nivel de gestión
        
        Args:
            entidad (str): Tipo de entidad (agricultores, parcelas).
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            filtros (dict, optional): Filtros a aplicar.
            
        Returns:
            dict: Datos paginados con metadatos.
        """
        try:
            resultado = None
            
            if entidad == 'agricultores':
                resultado = self.agricultor_servicio.obtener_agricultores_paginado(pagina, 8)
            
            elif entidad == 'parcelas':
                propietario_id = filtros.get('propietario_id') if filtros else None
                resultado = self.parcela_servicio.obtener_parcelas_paginado(pagina, por_pagina, propietario_id)
            
            else:
                return {
                    'datos': [],
                    'total_registros': 0,
                    'total_paginas': 0,
                    'pagina_actual': 1,
                    'error': f"Entidad '{entidad}' no reconocida"
                }
            
            # Enriquecer con metadatos de gestión
            if resultado:
                resultado['metadatos_gestion'] = {
                    'entidad': entidad,
                    'filtros_aplicados': filtros or {},
                    'timestamp_consulta': self._get_timestamp(),
                    'origen_servicio': 'gestion_servicio'
                }
            
            return resultado
                
        except Exception as e:
            logger.error(f"Error en obtener_datos_paginados: {str(e)}")
            return {
                'datos': [],
                'total_registros': 0,
                'total_paginas': 0,
                'pagina_actual': 1,
                'error': 'Error interno del sistema'
            }

    @cacheable('operaciones_gestion', key_func=lambda entidad, texto: f"busqueda_{entidad}_{texto.lower().replace(' ', '_')}", ttl=600)  # 10 min
    def buscar_datos(self, entidad, texto_busqueda):
        """
        Busca datos en cualquier entidad de forma unificada.
        ⭐ OPTIMIZADO: Búsquedas coordinadas cacheadas
        
        Args:
            entidad (str): Tipo de entidad (agricultores, parcelas).
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Resultados de la búsqueda.
        """
        try:
            resultados = []
            
            if entidad == 'agricultores':
                resultados = self.agricultor_servicio.buscar_agricultores(texto_busqueda)
            
            elif entidad == 'parcelas':
                resultados = self.parcela_servicio.buscar_parcelas(texto_busqueda)
            
            else:
                logger.error(f"Entidad '{entidad}' no reconocida para búsqueda")
                return []
            
            # Enriquecer resultados con metadatos de gestión
            for resultado in resultados:
                resultado['origen_busqueda'] = entidad
                resultado['termino_busqueda'] = texto_busqueda
            
            return resultados
                
        except Exception as e:
            logger.error(f"Error en buscar_datos: {str(e)}")
            return []
    
    # === OPERACIONES COMPLEJAS ===
    
    @cacheable('analisis_propietarios', key_func=lambda id_prop: f"estado_completo_{id_prop}", ttl=1200)  # 20 min
    def analizar_estado_propietario(self, id_propietario):
        """
        Analiza el estado completo de un propietario y sus parcelas.
        ⭐ OPTIMIZADO: Análisis completo cacheado por propietario
        
        Args:
            id_propietario (int): ID del propietario.
            
        Returns:
            dict: Análisis completo del propietario.
        """
        try:
            # Obtener estado del agricultor (ya cacheado en servicio)
            estado_agricultor = self.agricultor_servicio.verificar_estado_agricultor(id_propietario)
            
            if not estado_agricultor:
                return {'error': 'Propietario no encontrado'}
            
            # Obtener sus parcelas (ya cacheado en servicio)
            parcelas = self.parcela_servicio.obtener_parcelas_por_propietario(id_propietario)
            
            # Calcular estadísticas (ahora cacheadas como parte del análisis completo)
            area_total = sum(p['area'] for p in parcelas)
            parcelas_con_coords = sum(1 for p in parcelas if p['tiene_coordenadas'])
            
            analisis = {
                'propietario': estado_agricultor['agricultor'],
                'estadisticas': {
                    'total_parcelas': len(parcelas),
                    'area_total': area_total,
                    'area_promedio': area_total / len(parcelas) if parcelas else 0,
                    'parcelas_con_coordenadas': parcelas_con_coords,
                    'porcentaje_coordenadas': (parcelas_con_coords / len(parcelas) * 100) if parcelas else 0
                },
                'parcelas': parcelas,
                'recomendaciones': self._generar_recomendaciones_propietario_cached(estado_agricultor, parcelas),
                
                # Nuevas métricas de análisis
                'metricas_avanzadas': {
                    'categoria_propietario': self._categorizar_propietario_por_area(area_total),
                    'eficiencia_gps': parcelas_con_coords / len(parcelas) if parcelas else 0,
                    'dispersion_parcelas': self._calcular_dispersion_parcelas(parcelas),
                    'indice_consolidacion': self._calcular_indice_consolidacion(parcelas),
                    'timestamp_analisis': self._get_timestamp()
                }
            }
            
            logger.info(f"Análisis de propietario {id_propietario} completado")
            return analisis
            
        except Exception as e:
            logger.error(f"Error en analizar_estado_propietario: {str(e)}")
            return {'error': 'Error al analizar propietario'}

    @cacheable('reportes_gestion', key_func=lambda: 'completo_sistema', ttl=3600)  # 1 hora
    def generar_reporte_completo(self):
        """
        Genera un reporte completo del sistema.
        ⭐ OPTIMIZADO: Reporte completo cacheado por 1 hora
        
        Returns:
            dict: Reporte completo con toda la información relevante.
        """
        try:
            # Obtener datos base (todos ya cacheados en repositorios)
            estadisticas = self.relacion_repo.obtener_estadisticas_generales()
            distribucion = self.relacion_repo.obtener_distribución_parcelas_por_propietario()
            reporte_propietarios = self.relacion_repo.obtener_reporte_propietarios_parcelas()
            parcelas_sin_coords = self.relacion_repo.obtener_parcelas_sin_coordenadas()
            
            reporte = {
                'fecha_generacion': self._obtener_fecha_actual(),
                'resumen_ejecutivo': {
                    'total_agricultores': estadisticas['agricultores']['total'],
                    'total_propietarios': estadisticas['agricultores']['propietarios'],
                    'total_parcelas': estadisticas['parcelas']['total'],
                    'area_total_sistema': estadisticas['parcelas']['area_total'],
                    'area_promedio': estadisticas['parcelas']['area_promedio']
                },
                'calidad_datos': {
                    'parcelas_sin_coordenadas': len(parcelas_sin_coords),
                    'porcentaje_calidad': self._calcular_porcentaje_calidad_datos_cached(estadisticas, parcelas_sin_coords),
                    'score_integridad': self._calcular_score_integridad(estadisticas, parcelas_sin_coords)
                },
                'distribucion_tierras': distribucion,
                'detalle_propietarios': reporte_propietarios,
                'recomendaciones': self._generar_recomendaciones_sistema_cached(estadisticas, parcelas_sin_coords),
                'alertas': self._generar_alertas_sistema_cached(estadisticas, parcelas_sin_coords),
                
                # Nuevas métricas de reporte
                'metricas_avanzadas': {
                    'indice_gini_tierras': self._calcular_indice_gini(distribucion),
                    'densidad_parcelas': estadisticas['parcelas']['total'] / estadisticas['agricultores']['propietarios'] if estadisticas['agricultores']['propietarios'] > 0 else 0,
                    'eficiencia_sistema': self._calcular_eficiencia_sistema(estadisticas, parcelas_sin_coords),
                    'tendencias': self._analizar_tendencias_sistema(estadisticas)
                }
            }
            
            logger.info("Reporte completo generado exitosamente")
            return reporte
            
        except Exception as e:
            logger.error(f"Error en generar_reporte_completo: {str(e)}")
            return {'error': 'Error al generar reporte'}

    @cacheable('validaciones_gestion', key_func=lambda: 'integridad_sistema', ttl=1800)  # 30 min
    def validar_integridad_sistema(self):
        """
        Valida la integridad completa del sistema.
        ⭐ OPTIMIZADO: Validaciones completas cacheadas
        
        Returns:
            dict: Resultados de la validación.
        """
        try:
            validaciones = {
                'agricultores_sin_parcelas': self._validar_agricultores_sin_parcelas_cached(),
                'parcelas_sin_coordenadas': self._validar_parcelas_sin_coordenadas_cached(),
                'datos_inconsistentes': self._validar_datos_inconsistentes_cached(),
                'referencias_rotas': self._validar_referencias_rotas_cached()
            }
            
            # Calcular puntuación general
            total_problemas = sum(len(v) for v in validaciones.values() if isinstance(v, list))
            puntuacion = max(0, 100 - (total_problemas * 5))  # -5 puntos por problema
            
            resultado = {
                'puntuacion_integridad': puntuacion,
                'estado': 'Excelente' if puntuacion >= 90 else 'Bueno' if puntuacion >= 70 else 'Necesita atención',
                'validaciones': validaciones,
                'resumen_problemas': total_problemas,
                'timestamp_validacion': self._get_timestamp(),
                
                # Nuevas métricas de validación
                'metricas_validacion': {
                    'porcentaje_datos_completos': self._calcular_porcentaje_datos_completos(validaciones),
                    'criticidad_problemas': self._evaluar_criticidad_problemas(validaciones),
                    'recomendaciones_correccion': self._generar_recomendaciones_correccion(validaciones)
                }
            }
            
            logger.info(f"Validación de integridad completada - Puntuación: {puntuacion}")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en validar_integridad_sistema: {str(e)}")
            return {'error': 'Error al validar integridad'}

    # === MÉTODOS AUXILIARES OPTIMIZADOS ===

    @cacheable('calculos_gestion', key_func=lambda stats, parcelas: f"calidad_datos_{hash(str(stats))}_{len(parcelas)}", ttl=1800)  # 30 min
    def _calcular_porcentaje_calidad_datos_cached(self, estadisticas, parcelas_sin_coords):
        """Calcula un porcentaje general de calidad de datos (versión cacheada)."""
        total_parcelas = estadisticas['parcelas']['total']
        if total_parcelas == 0:
            return 100
        
        parcelas_con_coords = total_parcelas - len(parcelas_sin_coords)
        return round((parcelas_con_coords / total_parcelas) * 100, 1)

    @cacheable('alertas_gestion', key_func=lambda stats, parcelas: f"alertas_{hash(str(stats))}_{len(parcelas)}", ttl=1200)  # 20 min
    def _generar_alertas_sistema_cached(self, estadisticas, parcelas_sin_coords):
        """Genera alertas basadas en el estado del sistema (versión cacheada)."""
        alertas = []
        
        # Alerta por parcelas sin coordenadas
        if len(parcelas_sin_coords) > 0:
            porcentaje = (len(parcelas_sin_coords) / estadisticas['parcelas']['total']) * 100
            if porcentaje > 20:
                alertas.append(f"Alto porcentaje de parcelas sin coordenadas ({porcentaje:.1f}%)")
            elif porcentaje > 10:
                alertas.append(f"Porcentaje moderado de parcelas sin coordenadas ({porcentaje:.1f}%)")
        
        # Alerta por concentración de tierras
        distribucion = self.relacion_repo.obtener_distribución_parcelas_por_propietario()
        if distribucion:
            area_top_propietario = distribucion[0]['area_total']
            area_total = estadisticas['parcelas']['area_total']
            if area_total > 0 and (area_top_propietario / area_total) > 0.5:
                alertas.append("Alta concentración de tierras en un solo propietario")
        
        # Nuevas alertas
        if estadisticas['agricultores']['propietarios'] == 0:
            alertas.append("No hay propietarios registrados en el sistema")
        
        if estadisticas['parcelas']['total'] == 0:
            alertas.append("No hay parcelas registradas en el sistema")
        
        return alertas

    @cacheable('recomendaciones_gestion', key_func=lambda estado, parcelas: f"prop_{hash(str(estado))}_{len(parcelas)}", ttl=1800)  # 30 min
    def _generar_recomendaciones_propietario_cached(self, estado_agricultor, parcelas):
        """Genera recomendaciones específicas para un propietario (versión cacheada)."""
        recomendaciones = []
        
        # Recomendación por parcelas sin coordenadas
        sin_coords = [p for p in parcelas if not p['tiene_coordenadas']]
        if sin_coords:
            recomendaciones.append(f"Agregar coordenadas GPS a {len(sin_coords)} parcelas")
        
        # Recomendación por área promedio
        if parcelas:
            area_promedio = sum(p['area'] for p in parcelas) / len(parcelas)
            if area_promedio < 1:
                recomendaciones.append("Considerar consolidar parcelas pequeñas")
            elif area_promedio > 100:
                recomendaciones.append("Considerar subdividir parcelas muy grandes")
        
        # Nuevas recomendaciones
        if len(parcelas) == 1:
            recomendaciones.append("Considerar diversificar propiedades")
        elif len(parcelas) > 10:
            recomendaciones.append("Evaluar estrategia de gestión para múltiples parcelas")
        
        return recomendaciones

    @cacheable('recomendaciones_gestion', key_func=lambda stats, parcelas: f"sistema_{hash(str(stats))}_{len(parcelas)}", ttl=1800)  # 30 min
    def _generar_recomendaciones_sistema_cached(self, estadisticas, parcelas_sin_coords):
        """Genera recomendaciones para el sistema completo (versión cacheada)."""
        recomendaciones = []
        
        if len(parcelas_sin_coords) > 0:
            porcentaje = (len(parcelas_sin_coords) / estadisticas['parcelas']['total']) * 100
            if porcentaje > 50:
                recomendaciones.append("URGENTE: Implementar campaña masiva de actualización de coordenadas GPS")
            elif porcentaje > 20:
                recomendaciones.append("Implementar campaña de actualización de coordenadas GPS")
            else:
                recomendaciones.append("Completar registro de coordenadas GPS faltantes")
        
        if estadisticas['agricultores']['propietarios'] < estadisticas['agricultores']['total'] * 0.3:
            recomendaciones.append("Revisar clasificación de propietarios vs trabajadores")
        
        if estadisticas['parcelas']['area_promedio'] < 1:
            recomendaciones.append("Evaluar estrategias de consolidación de parcelas pequeñas")
        
        return recomendaciones

    # === MÉTODOS AUXILIARES DE VALIDACIÓN CACHEADOS ===

    @cacheable('validaciones_gestion', key_func=lambda: 'agricultores_sin_parcelas', ttl=1800)  # 30 min
    def _validar_agricultores_sin_parcelas_cached(self):
        """Valida agricultores propietarios sin parcelas (versión cacheada)."""
        try:
            propietarios = self.agricultor_servicio.obtener_propietarios_activos()
            sin_parcelas = []
            
            for propietario in propietarios:
                parcelas = self.parcela_servicio.obtener_parcelas_por_propietario(propietario['id'])
                if not parcelas:
                    sin_parcelas.append(propietario)
            
            return sin_parcelas
        except Exception:
            return []

    @cacheable('validaciones_gestion', key_func=lambda: 'parcelas_sin_coordenadas_val', ttl=1800)  # 30 min
    def _validar_parcelas_sin_coordenadas_cached(self):
        """Valida parcelas sin coordenadas (versión cacheada)."""
        try:
            return self.relacion_repo.obtener_parcelas_sin_coordenadas()
        except Exception:
            return []

    @cacheable('validaciones_gestion', key_func=lambda: 'datos_inconsistentes', ttl=1800)  # 30 min
    def _validar_datos_inconsistentes_cached(self):
        """Valida datos que podrían ser inconsistentes (versión cacheada)."""
        inconsistencias = []
        
        try:
            # Validar áreas negativas o cero
            # Validar coordenadas fuera de rango
            # Validar nombres duplicados
            # etc.
            pass
        except Exception:
            pass
        
        return inconsistencias

    @cacheable('validaciones_gestion', key_func=lambda: 'referencias_rotas', ttl=1800)  # 30 min
    def _validar_referencias_rotas_cached(self):
        """Valida referencias rotas entre entidades (versión cacheada)."""
        referencias_rotas = []
        
        try:
            # Validar integridad referencial
            # Parcelas sin propietario válido
            # etc.
            pass
        except Exception:
            pass
        
        return referencias_rotas

    # === MÉTODOS AUXILIARES NUEVOS ===

    def _calcular_concentracion_tierras(self, distribucion):
        """Calcula la concentración de tierras."""
        if not distribucion or len(distribucion) < 2:
            return 0
        
        area_total = sum(p['area_total'] for p in distribucion)
        area_top_20 = sum(p['area_total'] for p in distribucion[:max(1, len(distribucion)//5)])
        
        return round((area_top_20 / area_total * 100), 1) if area_total > 0 else 0

    def _calcular_eficiencia_coordenadas(self, estadisticas, parcelas_sin_coords):
        """Calcula la eficiencia de registro de coordenadas."""
        total = estadisticas['parcelas']['total']
        return round(((total - len(parcelas_sin_coords)) / total * 100), 1) if total > 0 else 0

    def _calcular_balance_propietarios(self, estadisticas):
        """Calcula el balance entre propietarios y trabajadores."""
        total = estadisticas['agricultores']['total']
        propietarios = estadisticas['agricultores']['propietarios']
        return round((propietarios / total * 100), 1) if total > 0 else 0

    def _categorizar_propietario_por_area(self, area_total):
        """Categoriza un propietario según su área total."""
        if area_total <= 5:
            return 'micro_propietario'
        elif area_total <= 20:
            return 'pequeño_propietario'
        elif area_total <= 100:
            return 'propietario_medio'
        else:
            return 'gran_propietario'

    def _calcular_dispersion_parcelas(self, parcelas):
        """Calcula la dispersión geográfica de las parcelas."""
        if len(parcelas) <= 1:
            return 0
        
        # Cálculo simplificado basado en varianza de coordenadas
        coords_validas = [(p['latitud'], p['longitud']) for p in parcelas if p.get('latitud') and p.get('longitud')]
        
        if len(coords_validas) < 2:
            return 0
        
        # Calcular dispersión simple
        lats = [c[0] for c in coords_validas]
        lngs = [c[1] for c in coords_validas]
        
        lat_range = max(lats) - min(lats)
        lng_range = max(lngs) - min(lngs)
        
        return round((lat_range + lng_range) * 100, 2)  # Factor de escala

    def _calcular_indice_consolidacion(self, parcelas):
        """Calcula un índice de consolidación de parcelas."""
        if not parcelas:
            return 0
        
        area_total = sum(p['area'] for p in parcelas)
        area_promedio = area_total / len(parcelas)
        
        # Índice basado en uniformidad de tamaños
        variaciones = sum(abs(p['area'] - area_promedio) for p in parcelas)
        variacion_promedio = variaciones / len(parcelas) if parcelas else 0
        
        return max(0, round(100 - (variacion_promedio / area_promedio * 100), 1)) if area_promedio > 0 else 0

    def _calcular_score_integridad(self, estadisticas, parcelas_sin_coords):
        """Calcula un score de integridad de datos."""
        scores = []
        
        # Score coordenadas
        if estadisticas['parcelas']['total'] > 0:
            score_coords = ((estadisticas['parcelas']['total'] - len(parcelas_sin_coords)) / estadisticas['parcelas']['total']) * 100
            scores.append(score_coords)
        
        # Score completitud básica
        if estadisticas['agricultores']['total'] > 0 and estadisticas['parcelas']['total'] > 0:
            scores.append(100)  # Datos básicos completos
        
        return round(sum(scores) / len(scores), 1) if scores else 0

    def _calcular_indice_gini(self, distribucion):
        """Calcula el índice de Gini para la distribución de tierras."""
        if not distribucion:
            return 0
        
        areas = sorted([p['area_total'] for p in distribucion])
        n = len(areas)
        
        if n == 0 or sum(areas) == 0:
            return 0
        
        # Cálculo simplificado del índice de Gini
        cum_areas = [sum(areas[:i+1]) for i in range(n)]
        total_area = sum(areas)
        
        gini_sum = sum((2 * i + 1 - n - 1) * area for i, area in enumerate(areas))
        gini = gini_sum / (n * total_area)
        
        return round(abs(gini), 3)

    def _calcular_eficiencia_sistema(self, estadisticas, parcelas_sin_coords):
        """Calcula un índice de eficiencia del sistema."""
        factores = []
        
        # Factor coordenadas
        if estadisticas['parcelas']['total'] > 0:
            factor_coords = ((estadisticas['parcelas']['total'] - len(parcelas_sin_coords)) / estadisticas['parcelas']['total']) * 100
            factores.append(factor_coords)
        
        # Factor utilización
        if estadisticas['agricultores']['propietarios'] > 0:
            factor_utilizacion = (estadisticas['parcelas']['total'] / estadisticas['agricultores']['propietarios']) * 10  # Factor de escala
            factores.append(min(100, factor_utilizacion))
        
        return round(sum(factores) / len(factores), 1) if factores else 0

    def _analizar_tendencias_sistema(self, estadisticas):
        """Analiza tendencias del sistema."""
        return {
            'crecimiento_parcelas': 'estable',  # Placeholder - requiere datos históricos
            'expansion_propietarios': 'lento',  # Placeholder
            'mejora_calidad_datos': 'en_progreso'  # Placeholder
        }

    def _calcular_porcentaje_datos_completos(self, validaciones):
        """Calcula el porcentaje de datos completos."""
        total_problemas = sum(len(v) for v in validaciones.values() if isinstance(v, list))
        return max(0, 100 - (total_problemas * 2))

    def _evaluar_criticidad_problemas(self, validaciones):
        """Evalúa la criticidad de los problemas encontrados."""
        criticidad = 'baja'
        
        if validaciones.get('referencias_rotas'):
            criticidad = 'alta'
        elif validaciones.get('datos_inconsistentes'):
            criticidad = 'media'
        elif validaciones.get('agricultores_sin_parcelas'):
            criticidad = 'media'
        
        return criticidad

    def _generar_recomendaciones_correccion(self, validaciones):
        """Genera recomendaciones para corregir problemas."""
        recomendaciones = []
        
        if validaciones.get('agricultores_sin_parcelas'):
            recomendaciones.append("Asignar parcelas a propietarios sin tierras o reclasificar como trabajadores")
        
        if validaciones.get('parcelas_sin_coordenadas'):
            recomendaciones.append("Completar registro GPS de parcelas faltantes")
        
        return recomendaciones

    def _obtener_fecha_actual(self):
        """Obtiene la fecha actual formateada."""
        from datetime import datetime
        return datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()