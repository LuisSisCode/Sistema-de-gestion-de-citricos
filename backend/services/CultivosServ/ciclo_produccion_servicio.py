# bd_conecciones/servicios/ciclo_produccion_servicio.py

import logging
from datetime import datetime, date, timedelta
from ...repositories.CultivosRepositorio.ciclo_produccion_repositorio import CicloProduccionRepositorio
from ...repositories.CultivosRepositorio.variedad_cultivo_repositorio import VariedadCultivoRepositorio
from ...repositories.Productor_Parcelas_rep.parcela_repositorio import ParcelaRepositorio
from ...repositories.CultivosRepositorio.relacion_cultivo_repositorio import RelacionCultivoRepositorio
from ...core.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste,
    RegistroTieneDependencias
)
from ...repositories.CultivosRepositorio.lote_cosecha_repositorio import LoteCosechaRepositorio
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class CicloProduccionServicio:
    """Servicio para lógica de negocio de ciclos de producción con caché optimizado."""
    
    # Estados válidos y sus transiciones permitidas
    ESTADOS_VALIDOS = [
        'Planificado', 'En Preparación', 'Sembrado', 
        'En Desarrollo', 'En Cosecha', 'Finalizado', 'Cancelado'
    ]
    
    TRANSICIONES_VALIDAS = {
        'Planificado': ['En Preparación', 'Cancelado'],
        'En Preparación': ['Sembrado', 'Cancelado'],
        'Sembrado': ['En Desarrollo', 'Cancelado'],
        'En Desarrollo': ['En Cosecha', 'Cancelado'],
        'En Cosecha': ['Finalizado', 'Cancelado'],
        'Finalizado': [],  # Estado final
        'Cancelado': []    # Estado final
    }
    
    def __init__(self):
        self.ciclo_repo = CicloProduccionRepositorio()
        self.variedad_repo = VariedadCultivoRepositorio()
        self.parcela_repo = ParcelaRepositorio()
        self.relacion_repo = RelacionCultivoRepositorio()
        self.lote_repo = LoteCosechaRepositorio()
    
    @cacheable('servicio_ciclos', key_func=lambda pagina, por_pagina=8, filtros=None: f"paginado_{pagina}_{por_pagina}_{hash(str(filtros or {}))}", ttl=600)  # 10 min
    def obtener_ciclos_paginado(self, pagina, por_pagina=8, filtros=None):
        """
        Obtiene ciclos de producción con paginación y lógica de negocio aplicada.
        ⭐ MUY OPTIMIZADO: Resultado enriquecido completo cacheado para evitar N+1 queries
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            filtros (dict, optional): Filtros (estado, parcela, fecha_desde, fecha_hasta).
            
        Returns:
            dict: Resultado con ciclos y metadatos.
        """
        try:
            resultado = self.ciclo_repo.obtener_paginado(pagina, por_pagina, filtros)
            
            # Enriquecer datos con información adicional (OPTIMIZADO: resultado completo cacheado)
            ciclos_enriquecidos = []
            for ciclo in resultado['ciclos']:
                ciclo_enriquecido = ciclo.copy()
                
                # Agregar metadatos de negocio calculados
                ciclo_enriquecido['puede_avanzar'] = self._puede_avanzar_estado_cached(ciclo)
                ciclo_enriquecido['siguiente_estado'] = self._obtener_siguiente_estado(ciclo['estado'])
                ciclo_enriquecido['alertas'] = self._generar_alertas_ciclo(ciclo)
                
                # Análisis de fechas y tiempos
                ciclo_enriquecido['analisis_fechas'] = self._analizar_fechas_ciclo(ciclo)
                ciclo_enriquecido['eficiencia_temporal'] = self._calcular_eficiencia_temporal(ciclo)
                
                # Información de área y productividad
                ciclo_enriquecido['analisis_area'] = self._analizar_area_ciclo_cached(ciclo)
                
                # Recomendaciones específicas
                ciclo_enriquecido['recomendaciones'] = self._generar_recomendaciones_ciclo(ciclo)
                ciclo_enriquecido['acciones_disponibles'] = self._obtener_acciones_disponibles(ciclo)
                
                ciclos_enriquecidos.append(ciclo_enriquecido)
            
            # Actualizar resultado con datos enriquecidos
            resultado['ciclos'] = ciclos_enriquecidos
            resultado['filtros_aplicados'] = filtros or {}
            resultado['estadisticas_pagina'] = self._calcular_estadisticas_pagina_cached(ciclos_enriquecidos)
            resultado['metadatos_servicio'] = {
                'timestamp': self._get_timestamp(),
                'total_activos': sum(1 for c in ciclos_enriquecidos if c['es_activo']),
                'total_con_alertas': sum(1 for c in ciclos_enriquecidos if c['alertas']),
                'area_total_pagina': sum(c['area_sembrada'] for c in ciclos_enriquecidos),
                'estados_representados': list(set(c['estado'] for c in ciclos_enriquecidos))
            }
            
            logger.info(f"Servicio: página {pagina} procesada con {len(resultado['ciclos'])} ciclos")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_ciclos_paginado: {str(e)}")
            raise

    @cache_invalidator('servicio_ciclos', pattern='paginado_')           # Invalidar paginación
    @cache_invalidator('servicio_ciclos', pattern='busqueda_')          # Invalidar búsquedas
    @cache_invalidator('servicio_ciclos', pattern='estado_')            # Invalidar por estado
    @cache_invalidator('servicio_ciclos', pattern='parcela_')           # Invalidar por parcela
    @cache_invalidator('validaciones_ciclos')                           # Invalidar validaciones
    @cache_invalidator('estadisticas_ciclos_servicio')                  # Invalidar estadísticas
    def crear_ciclo_produccion(self, datos_ciclo):
        """
        Crea un nuevo ciclo de producción con validaciones de negocio.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_ciclo (dict): Datos del ciclo de producción.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio adicionales
            self._validar_reglas_negocio_creacion_cached(datos_ciclo)
            
            # Validar entidades relacionadas
            parcela = self._validar_parcela_cached(datos_ciclo['id_parcela'])
            variedad = self._validar_variedad_cached(datos_ciclo['id_variedad'])
            
            # Validar área disponible en la parcela
            self._validar_area_disponible_cached(datos_ciclo['id_parcela'], datos_ciclo['area_sembrada'])
            
            # Normalizar y enriquecer datos
            datos_normalizados = self._normalizar_datos_ciclo(datos_ciclo)
            
            # Calcular fecha de cosecha estimada si no se proporciona
            if not datos_normalizados.get('fecha_cosecha_estimada') and datos_normalizados.get('fecha_siembra'):
                datos_normalizados['fecha_cosecha_estimada'] = self._calcular_fecha_cosecha_estimada(
                    datos_normalizados['fecha_siembra'], 
                    variedad
                )
            
            # Crear ciclo
            exito, id_ciclo = self.ciclo_repo.crear(datos_normalizados)
            
            if exito:
                # Obtener información del ciclo creado
                ciclo_creado = self.ciclo_repo.obtener_por_id(id_ciclo)
                
                resultado = {
                    'exito': True,
                    'id_ciclo': id_ciclo,
                    'mensaje': f"Ciclo de producción creado exitosamente",
                    'ciclo': ciclo_creado,
                    'parcela': parcela['nombre'],
                    'variedad': f"{variedad['nombre_tipo_cultivo']} - {variedad['nombre']}",
                    'area_sembrada': datos_normalizados['area_sembrada'],
                    'fecha_cosecha_estimada': datos_normalizados.get('fecha_cosecha_estimada'),
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: ciclo de producción creado con ID {id_ciclo}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear ciclo de producción'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error de validación en crear_ciclo_produccion: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_ciclo_produccion: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
        
    def agregar_ciclo_produccion(self, ciclo_data):
        """
        Agrega un nuevo ciclo de producción a la base de datos.
        
        Args:
            ciclo_data (dict): Datos del ciclo de producción a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del ciclo agregado o None en caso de error.
        """
        try:
            return self.ciclo_repo.crear(ciclo_data)
        except Exception as e:
            logger.error(f"Error al agregar ciclo de producción: {str(e)}")
            return False, None

    @cache_invalidator('servicio_ciclos', pattern='paginado_')           # Invalidar paginación
    @cache_invalidator('servicio_ciclos', pattern='busqueda_')          # Invalidar búsquedas
    @cache_invalidator('servicio_ciclos', pattern='estado_')            # Invalidar por estado
    @cache_invalidator('servicio_ciclos', pattern='parcela_')           # Invalidar por parcela
    @cache_invalidator('validaciones_ciclos')                           # Invalidar validaciones
    @cache_invalidator('estadisticas_ciclos_servicio')                  # Invalidar estadísticas
    def actualizar_ciclo_produccion(self, id_ciclo, datos_ciclo):
        """
        Actualiza un ciclo de producción con validaciones de negocio.
        OPTIMIZADO: Invalidación específica del ciclo actualizado.
        
        Args:
            id_ciclo (int): ID del ciclo.
            datos_ciclo (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales para comparación
            ciclo_actual = self.ciclo_repo.obtener_por_id(id_ciclo)
            
            # Validar cambios críticos según el estado actual
            self._validar_cambios_criticos(ciclo_actual, datos_ciclo)
            
            # Validar nuevas entidades si cambiaron
            if 'id_parcela' in datos_ciclo:
                parcela = self._validar_parcela_cached(datos_ciclo['id_parcela'])
            if 'id_variedad' in datos_ciclo:
                variedad = self._validar_variedad_cached(datos_ciclo['id_variedad'])
            
            # Validar nueva área si cambió
            if 'area_sembrada' in datos_ciclo:
                self._validar_cambio_area(ciclo_actual, datos_ciclo['area_sembrada'])
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_ciclo(datos_ciclo)
            
            # Actualizar ciclo
            exito = self.ciclo_repo.actualizar(id_ciclo, datos_normalizados)
            
            if exito:
                # Analizar cambios importantes
                cambios_detectados = self._analizar_cambios_ciclo(ciclo_actual, datos_normalizados)
                
                resultado = {
                    'exito': True,
                    'mensaje': f"Ciclo de producción actualizado exitosamente",
                    'cambios_detectados': cambios_detectados,
                    'requiere_actualizacion_listas': True,
                    'impacto_planificacion': self._evaluar_impacto_planificacion(cambios_detectados)
                }
                
                logger.info(f"Servicio: ciclo {id_ciclo} actualizado - {len(cambios_detectados)} cambios")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar ciclo de producción'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en actualizar_ciclo_produccion: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_ciclo_produccion: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ciclos', pattern='estado_')            # Invalidar por estado
    @cache_invalidator('servicio_ciclos', key='ciclos_activos')         # Invalidar activos
    @cache_invalidator('estadisticas_ciclos_servicio')                  # Invalidar estadísticas
    def avanzar_estado_ciclo(self, id_ciclo, nuevo_estado=None, datos_adicionales=None):
        """
        Avanza el estado de un ciclo de producción con validaciones de flujo de trabajo.
        OPTIMIZADO: Invalidación específica por estado.
        
        Args:
            id_ciclo (int): ID del ciclo.
            nuevo_estado (str, optional): Estado destino. Si no se proporciona, avanza al siguiente.
            datos_adicionales (dict, optional): Datos adicionales según el estado.
            
        Returns:
            dict: Resultado de la transición.
        """
        try:
            # Obtener ciclo actual
            ciclo_actual = self.ciclo_repo.obtener_por_id(id_ciclo)
            
            # Determinar estado destino
            if not nuevo_estado:
                nuevo_estado = self._obtener_siguiente_estado(ciclo_actual['estado'])
                if not nuevo_estado:
                    return {
                        'exito': False,
                        'mensaje': f"El ciclo ya está en estado final: {ciclo_actual['estado']}"
                    }
            
            # Validar transición de estado
            self._validar_transicion_estado(ciclo_actual['estado'], nuevo_estado)
            
            # Validar requisitos específicos del estado
            self._validar_requisitos_estado(ciclo_actual, nuevo_estado, datos_adicionales)
            
            # Preparar datos de actualización según el estado
            datos_actualizacion = self._preparar_datos_transicion(ciclo_actual, nuevo_estado, datos_adicionales)
            
            # Ejecutar cambio de estado
            exito = self.ciclo_repo.cambiar_estado(id_ciclo, nuevo_estado)
            
            if exito and datos_actualizacion:
                # Actualizar datos adicionales si es necesario
                self.ciclo_repo.actualizar(id_ciclo, datos_actualizacion)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Estado cambiado de '{ciclo_actual['estado']}' a '{nuevo_estado}' exitosamente",
                    'estado_anterior': ciclo_actual['estado'],
                    'estado_nuevo': nuevo_estado,
                    'siguiente_estado_disponible': self._obtener_siguiente_estado(nuevo_estado),
                    'acciones_siguientes': self._obtener_acciones_siguiente_estado(nuevo_estado),
                    'progreso_estimado': self._calcular_progreso_por_estado(nuevo_estado),
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: ciclo {id_ciclo} avanzó de '{ciclo_actual['estado']}' a '{nuevo_estado}'")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al cambiar estado del ciclo'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en avanzar_estado_ciclo: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio avanzar_estado_ciclo: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ciclos', pattern='paginado_')           # Invalidar paginación
    @cache_invalidator('servicio_ciclos', pattern='busqueda_')          # Invalidar búsquedas
    @cache_invalidator('servicio_ciclos', pattern='estado_')            # Invalidar por estado
    @cache_invalidator('servicio_ciclos', pattern='parcela_')           # Invalidar por parcela
    @cache_invalidator('estadisticas_ciclos_servicio')                  # Invalidar estadísticas
    def finalizar_ciclo_produccion(self, id_ciclo, datos_finalizacion):
        """
        Finaliza un ciclo de producción registrando datos de finalización.
        
        Args:
            id_ciclo (int): ID del ciclo.
            datos_finalizacion (dict): Datos de finalización (rendimiento_real, etc.).
            
        Returns:
            dict: Resultado de la finalización.
        """
        try:
            # Obtener ciclo actual
            ciclo_actual = self.ciclo_repo.obtener_por_id(id_ciclo)
            
            # Validar que esté en estado que permita finalización
            if ciclo_actual['estado'] not in ['En Cosecha']:
                return {
                    'exito': False,
                    'mensaje': f"Solo se pueden finalizar ciclos en estado 'En Cosecha'. Estado actual: {ciclo_actual['estado']}"
                }
            
            # NOTA: Se removieron las referencias a (campo eliminado de BD).
            # Evitar validaciones o actualizaciones que dependan de ese campo.

            # Preparar datos de actualización
            datos_actualizacion = {
                'estado': 'Finalizado'
            }
            
            # Agregar datos opcionales si se proporcionan
            if 'rendimiento_real' in datos_finalizacion:
                datos_actualizacion['rendimiento_real'] = datos_finalizacion['rendimiento_real']
            
            # Actualizar ciclo
            exito = self.ciclo_repo.actualizar(id_ciclo, datos_actualizacion)
            
            if exito:
                # No se calculan métricas que dependan aquí.
                metricas = {}
                
                resultado = {
                    'exito': True,
                    'mensaje': 'Ciclo finalizado exitosamente',
                    'metricas_finalizacion': metricas,
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: ciclo {id_ciclo} finalizado exitosamente")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al finalizar ciclo'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en finalizar_ciclo_produccion: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio finalizar_ciclo_produccion: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
    
    def eliminar_ciclo_produccion(self, id_ciclo):
        """
        Elimina un ciclo de producción de la base de datos.
        
        Args:
            id_ciclo (int): ID del ciclo de producción a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            return self.ciclo_repo.eliminar_ciclo_produccion(id_ciclo)  # Usar desactivar en lugar de eliminar
        except Exception as e:
            logger.error(f"Error al eliminar ciclo de producción: {str(e)}")
            return False

    @cacheable('servicio_ciclos', key_func=lambda estado: f"estado_{estado}", ttl=600)  # 10 min
    def obtener_ciclos_por_estado(self, estado):
        """
        Obtiene ciclos filtrados por estado con información enriquecida.
        
        Args:
            estado (str): Estado del ciclo.
            
        Returns:
            list: Lista de ciclos en el estado especificado.
        """
        try:
            ciclos = self.ciclo_repo.obtener_por_estado(estado)
            
            # Enriquecer con información específica del estado
            for ciclo in ciclos:
                ciclo['acciones_disponibles'] = self._obtener_acciones_por_estado(estado)
                ciclo['tiempo_en_estado'] = self._calcular_tiempo_en_estado(ciclo, estado)
                ciclo['alerta_tiempo'] = self._evaluar_alerta_tiempo_estado(ciclo, estado)
                
                if estado == 'En Desarrollo':
                    ciclo['porcentaje_desarrollo'] = self._estimar_porcentaje_desarrollo(ciclo)
                elif estado == 'En Cosecha':
                    ciclo['ventana_cosecha'] = self._calcular_ventana_cosecha(ciclo)
                elif estado in ['Finalizado']:
                    ciclo['metricas_resultado'] = self._calcular_metricas_resultado(ciclo)
            
            logger.info(f"Ciclos en estado '{estado}': {len(ciclos)} encontrados")
            return ciclos
            
        except Exception as e:
            logger.error(f"Error en obtener_ciclos_por_estado: {str(e)}")
            return []

    def cambiar_estado_ciclo(self, id_ciclo, nuevo_estado):
        """
        Cambia el estado de un ciclo de producción.
        
        Args:
            id_ciclo (int): ID del ciclo de producción.
            nuevo_estado (str): Nuevo estado del ciclo ('Planificado', 'En Preparación', 'Sembrado', 
                              'En Desarrollo', 'En Cosecha', 'Finalizado', 'Cancelado').
            
        Returns:
            bool: True si se cambió correctamente, False en caso contrario.
        """
        try:
            return self.ciclo_repo.cambiar_estado(id_ciclo, nuevo_estado)
        except Exception as e:
            logger.error(f"Error al cambiar estado del ciclo: {str(e)}")
            return False

    @cacheable('servicio_ciclos', key_func=lambda: 'ciclos_activos_servicio', ttl=600)  # 10 min
    def obtener_ciclos_activos_enriquecidos(self):
        """
        Obtiene ciclos activos con información enriquecida para monitoreo.
        
        Returns:
            dict: Ciclos activos organizados por estado con alertas.
        """
        try:
            ciclos_activos = self.ciclo_repo.obtener_ciclos_activos()
            
            # Organizar por estado y enriquecer
            ciclos_por_estado = {}
            alertas_sistema = []
            
            for ciclo in ciclos_activos:
                estado = ciclo['estado']
                if estado not in ciclos_por_estado:
                    ciclos_por_estado[estado] = []
                
                # Enriquecer ciclo
                ciclo_enriquecido = ciclo.copy()
                ciclo_enriquecido['alertas'] = self._generar_alertas_ciclo(ciclo)
                ciclo_enriquecido['prioridad'] = self._calcular_prioridad_atencion(ciclo)
                ciclo_enriquecido['tiempo_desde_inicio'] = self._calcular_tiempo_desde_inicio(ciclo)
                
                # Agregar alertas del sistema
                if ciclo_enriquecido['alertas']:
                    alertas_sistema.extend(ciclo_enriquecido['alertas'])
                
                ciclos_por_estado[estado].append(ciclo_enriquecido)
            
            # Ordenar por prioridad dentro de cada estado
            for estado in ciclos_por_estado:
                ciclos_por_estado[estado].sort(key=lambda x: x['prioridad'], reverse=True)
            
            resultado = {
                'ciclos_por_estado': ciclos_por_estado,
                'total_ciclos_activos': len(ciclos_activos),
                'estados_activos': list(ciclos_por_estado.keys()),
                'alertas_sistema': list(set(alertas_sistema)),  # Eliminar duplicados
                'resumen_estados': {estado: len(ciclos) for estado, ciclos in ciclos_por_estado.items()},
                'timestamp': self._get_timestamp()
            }
            
            logger.info(f"Ciclos activos obtenidos: {len(ciclos_activos)} total, {len(alertas_sistema)} alertas")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en obtener_ciclos_activos_enriquecidos: {str(e)}")
            return {'ciclos_por_estado': {}, 'alertas_sistema': [], 'total_ciclos_activos': 0}

    @cacheable('estadisticas_ciclos_servicio', key_func=lambda: 'completas_servicio', ttl=900)  # 15 min
    def obtener_estadisticas_ciclos(self):
        """
        Obtiene estadísticas completas de ciclos de producción a nivel de servicio.
        ⭐ MUY OPTIMIZADO: Múltiples consultas a repositorios ahora cacheadas como conjunto
        
        Returns:
            dict: Estadísticas detalladas con métricas de negocio.
        """
        try:
            # Estos métodos ya están cacheados en repositorios, pero el resultado final también se cachea
            estadisticas_basicas = self.ciclo_repo.obtener_estadisticas()
            metricas_eficiencia = self.relacion_repo.obtener_metricas_eficiencia()
            analisis_estacionalidad = self.relacion_repo.obtener_analisis_estacionalidad()
            
            # Estadísticas enriquecidas de servicio
            estadisticas = {
                **estadisticas_basicas,
                'eficiencia': metricas_eficiencia,
                'estacionalidad': analisis_estacionalidad,
                'alertas_sistema': self._generar_alertas_sistema_ciclos(),
                
                # Nuevas métricas de servicio
                'metricas_servicio': {
                    'ciclos_retrasados': self._contar_ciclos_retrasados(),
                    'eficiencia_planificacion': self._calcular_eficiencia_planificacion(),
                    'utilizacion_parcelas': self._calcular_utilizacion_parcelas(),
                    'rendimiento_promedio_sistema': self._calcular_rendimiento_promedio_sistema(),
                    'diversidad_cultivos_activos': self._evaluar_diversidad_cultivos_activos(),
                    'prediction_cosechas_mes': self._predecir_cosechas_proximo_mes(),
                    'timestamp': self._get_timestamp()
                }
            }
            
            logger.info(f"Estadísticas completas de ciclos calculadas: {estadisticas_basicas.get('total_ciclos', 0)} ciclos")
            return estadisticas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_ciclos: {str(e)}")
            return {}

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('validaciones_ciclos', key_func=lambda ciclo: f"puede_avanzar_{ciclo['id_ciclo']}_{ciclo['estado']}", ttl=600)  # 10 min
    def _puede_avanzar_estado_cached(self, ciclo):
        """
        Verifica si un ciclo puede avanzar al siguiente estado (versión cacheada).
        
        Args:
            ciclo (dict): Datos del ciclo.
            
        Returns:
            bool: True si puede avanzar.
        """
        estado_actual = ciclo['estado']
        return bool(self.TRANSICIONES_VALIDAS.get(estado_actual, []))

    @cacheable('validaciones_ciclos', key_func=lambda id_parcela, area: f"area_disponible_{id_parcela}_{area}", ttl=900)  # 15 min
    def _validar_area_disponible_cached(self, id_parcela, area_sembrada):
        """
        Valida que haya área disponible en la parcela (versión cacheada).
        
        Args:
            id_parcela (int): ID de la parcela.
            area_sembrada (float): Área que se quiere sembrar.
            
        Raises:
            ErrorValidacion: Si no hay área suficiente.
        """
        try:
            parcela = self.parcela_repo.obtener_por_id(id_parcela)
            area_total_parcela = parcela['area_total']
            
            # Calcular área ya utilizada en ciclos activos
            ciclos_activos = self.ciclo_repo.obtener_por_parcela(id_parcela)
            area_utilizada = sum(
                c['area_sembrada'] for c in ciclos_activos 
                if c['es_activo']  # Solo ciclos no finalizados
            )
            
            area_disponible = area_total_parcela - area_utilizada
            
            if area_sembrada > area_disponible:
                raise ErrorValidacion(
                    f"Área insuficiente. Disponible: {area_disponible:.2f} ha, "
                    f"Solicitada: {area_sembrada:.2f} ha"
                )
            
            return True
        except RegistroNoEncontrado:
            raise ErrorValidacion("La parcela especificada no existe")

    @cacheable('analisis_ciclos', key_func=lambda ciclo: f"area_analisis_{ciclo['id_parcela']}_{ciclo['area_sembrada']}", ttl=1200)  # 20 min
    def _analizar_area_ciclo_cached(self, ciclo):
        """
        Analiza el uso de área del ciclo en relación a la parcela (versión cacheada).
        
        Args:
            ciclo (dict): Datos del ciclo.
            
        Returns:
            dict: Análisis de área.
        """
        try:
            parcela = self.parcela_repo.obtener_por_id(ciclo['id_parcela'])
            area_total = parcela['area_total']
            area_sembrada = ciclo['area_sembrada']
            
            porcentaje_uso = (area_sembrada / area_total) * 100
            
            # Categorizar uso
            if porcentaje_uso >= 90:
                categoria = 'uso_intensivo'
            elif porcentaje_uso >= 60:
                categoria = 'uso_alto'
            elif porcentaje_uso >= 30:
                categoria = 'uso_moderado'
            else:
                categoria = 'uso_bajo'
            
            return {
                'area_total_parcela': area_total,
                'area_sembrada': area_sembrada,
                'porcentaje_uso': round(porcentaje_uso, 1),
                'categoria_uso': categoria,
                'area_restante': round(area_total - area_sembrada, 2)
            }
        except Exception:
            return {
                'porcentaje_uso': 0,
                'categoria_uso': 'sin_datos',
                'area_restante': 0
            }

    @cacheable('validaciones_ciclos', key_func=lambda id_parcela: f"parcela_valida_{id_parcela}", ttl=1800)  # 30 min
    def _validar_parcela_cached(self, id_parcela):
        """
        Valida que la parcela existe y está activa (versión cacheada).
        
        Args:
            id_parcela (int): ID de la parcela.
            
        Returns:
            dict: Información de la parcela.
            
        Raises:
            ErrorValidacion: Si la parcela no existe.
        """
        try:
            return self.parcela_repo.obtener_por_id(id_parcela)
        except RegistroNoEncontrado:
            raise ErrorValidacion("La parcela seleccionada no existe o está inactiva")

    @cacheable('validaciones_ciclos', key_func=lambda id_variedad: f"variedad_valida_{id_variedad}", ttl=1800)  # 30 min
    def _validar_variedad_cached(self, id_variedad):
        """
        Valida que la variedad existe y está activa (versión cacheada).
        
        Args:
            id_variedad (int): ID de la variedad.
            
        Returns:
            dict: Información de la variedad.
            
        Raises:
            ErrorValidacion: Si la variedad no existe.
        """
        try:
            return self.variedad_repo.obtener_por_id(id_variedad)
        except RegistroNoEncontrado:
            raise ErrorValidacion("La variedad seleccionada no existe o está inactiva")

    # ==================== MÉTODOS AUXILIARES PRIVADOS ====================
    
    def _validar_reglas_negocio_creacion_cached(self, datos):
        """Valida reglas de negocio específicas para creación."""
        # Regla: Área sembrada debe ser positiva y realista
        area = datos.get('area_sembrada', 0)
        if area <= 0:
            raise ErrorValidacion("El área sembrada debe ser mayor a 0")
        elif area > 1000:  # 1000 hectáreas es muy grande para un ciclo
            raise ErrorValidacion("El área sembrada parece demasiado grande (máximo 1000 ha)")
        
        # Regla: Fecha de siembra no puede ser muy futura
        fecha_siembra = datos.get('fecha_siembra')
        if fecha_siembra:
            if isinstance(fecha_siembra, str):
                fecha_siembra = datetime.strptime(fecha_siembra, '%Y-%m-%d').date()
            
            fecha_limite = date.today() + timedelta(days=90)  # Máximo 3 meses a futuro
            if fecha_siembra > fecha_limite:
                raise ErrorValidacion("La fecha de siembra no puede ser más de 3 meses en el futuro")
        
        # Regla: Densidad de siembra debe ser razonable
        densidad = datos.get('densidad_siembra')
        if densidad is not None and densidad <= 0:
            raise ErrorValidacion("La densidad de siembra debe ser positiva")
        
        return True
    
    def _normalizar_datos_ciclo(self, datos):
        """Normaliza y limpia los datos del ciclo."""
        datos_normalizados = datos.copy()
        
        # Normalizar área
        if 'area_sembrada' in datos_normalizados:
            datos_normalizados['area_sembrada'] = round(float(datos_normalizados['area_sembrada']), 2)
        
        # Normalizar densidad
        if 'densidad_siembra' in datos_normalizados and datos_normalizados['densidad_siembra'] is not None:
            datos_normalizados['densidad_siembra'] = round(float(datos_normalizados['densidad_siembra']), 2)
        
        # Asegurar estado válido
        estado = datos_normalizados.get('estado', 'Planificado')
        if estado not in self.ESTADOS_VALIDOS:
            datos_normalizados['estado'] = 'Planificado'
        
        return datos_normalizados
    
    def _calcular_fecha_cosecha_estimada(self, fecha_siembra, variedad):
        """Calcula la fecha estimada de cosecha basada en la variedad."""
        try:
            if isinstance(fecha_siembra, str):
                fecha_siembra = datetime.strptime(fecha_siembra, '%Y-%m-%d').date()
            
            tiempo_produccion = variedad.get('tiempo_produccion', 120)  # Default 4 meses
            fecha_cosecha = fecha_siembra + timedelta(days=tiempo_produccion)
            
            return fecha_cosecha.strftime('%Y-%m-%d')
        except Exception:
            return None
    
    def _obtener_siguiente_estado(self, estado_actual):
        """Obtiene el siguiente estado lógico en el flujo."""
        transiciones = self.TRANSICIONES_VALIDAS.get(estado_actual, [])
        # Retorna el primer estado que no sea 'Cancelado'
        return next((estado for estado in transiciones if estado != 'Cancelado'), None)
    
    def _validar_transicion_estado(self, estado_actual, nuevo_estado):
        """Valida que la transición de estado sea permitida."""
        estados_permitidos = self.TRANSICIONES_VALIDAS.get(estado_actual, [])
        if nuevo_estado not in estados_permitidos:
            raise ErrorValidacion(
                f"No se puede cambiar de '{estado_actual}' a '{nuevo_estado}'. "
                f"Estados permitidos: {', '.join(estados_permitidos)}"
            )
    
    def _validar_cambios_criticos(self, ciclo_actual, datos_nuevos):
        """Valida cambios que podrían ser problemáticos según el estado."""
        estado = ciclo_actual['estado']
        
        # No permitir cambios de entidades básicas en estados avanzados
        if estado in ['En Desarrollo', 'En Cosecha', 'Finalizado']:
            if 'id_parcela' in datos_nuevos or 'id_variedad' in datos_nuevos:
                raise ErrorValidacion(f"No se pueden cambiar parcela o variedad en estado '{estado}'")
        
        # No permitir reducción drástica de área en estados activos
        if estado in ['Sembrado', 'En Desarrollo', 'En Cosecha']:
            if 'area_sembrada' in datos_nuevos:
                area_actual = ciclo_actual['area_sembrada']
                area_nueva = datos_nuevos['area_sembrada']
                if area_nueva < area_actual * 0.5:  # Reducción mayor al 50%
                    raise ErrorValidacion("No se puede reducir el área en más del 50% en estado activo")
    
    def _validar_cambio_area(self, ciclo_actual, nueva_area):
        """Valida el cambio de área sembrada."""
        diferencia_area = nueva_area - ciclo_actual['area_sembrada']
        if diferencia_area > 0:
            # Si aumenta, verificar disponibilidad
            self._validar_area_disponible_cached(ciclo_actual['id_parcela'], diferencia_area)
    
    def _analizar_cambios_ciclo(self, ciclo_actual, datos_nuevos):
        """Analiza los cambios realizados en un ciclo."""
        cambios = []
        
        campos_importantes = [
            'id_parcela', 'id_variedad', 'area_sembrada', 'estado',
            'fecha_siembra', 'fecha_cosecha_estimada'
        ]
        
        for campo in campos_importantes:
            if campo in datos_nuevos and ciclo_actual.get(campo) != datos_nuevos[campo]:
                cambios.append({
                    'campo': campo,
                    'valor_anterior': ciclo_actual.get(campo),
                    'valor_nuevo': datos_nuevos[campo],
                    'impacto': self._evaluar_impacto_cambio(campo, ciclo_actual.get(campo), datos_nuevos[campo])
                })
        
        return cambios
    
    def _evaluar_impacto_cambio(self, campo, valor_anterior, valor_nuevo):
        """Evalúa el impacto de un cambio específico."""
        if campo == 'area_sembrada':
            return 'alto' if abs(float(valor_nuevo) - float(valor_anterior)) > 1 else 'medio'
        elif campo in ['id_parcela', 'id_variedad']:
            return 'muy_alto'
        elif campo == 'estado':
            return 'alto'
        elif campo in ['fecha_siembra', 'fecha_cosecha_estimada']:
            return 'medio'
        else:
            return 'bajo'
    
    def _evaluar_impacto_planificacion(self, cambios):
        """Evalúa el impacto general de los cambios en la planificación."""
        if not cambios:
            return 'sin_impacto'
        
        impactos = [cambio['impacto'] for cambio in cambios]
        
        if 'muy_alto' in impactos:
            return 'replantear_estrategia'
        elif 'alto' in impactos:
            return 'ajustar_planificacion'
        elif 'medio' in impactos:
            return 'revisar_cronograma'
        else:
            return 'cambios_menores'
    
    def _validar_requisitos_estado(self, ciclo, nuevo_estado, datos_adicionales):
        """Valida requisitos específicos para cada estado."""
        if nuevo_estado == 'Sembrado':
            if not ciclo.get('fecha_siembra'):
                raise ErrorValidacion("Se requiere fecha de siembra para pasar a estado 'Sembrado'")
        
        elif nuevo_estado == 'Finalizado':
            if not datos_adicionales:
                raise ErrorValidacion("Se requiere fecha de cosecha real para finalizar el ciclo")
    
    def _preparar_datos_transicion(self, ciclo, nuevo_estado, datos_adicionales):
        """Prepara datos adicionales según la transición de estado."""
        datos = {}
        
        if nuevo_estado == 'Sembrado' and not ciclo.get('fecha_siembra'):
            datos['fecha_siembra'] = date.today().strftime('%Y-%m-%d')
        
        return datos if datos else None
    
    def _generar_alertas_ciclo(self, ciclo):
        """Genera alertas específicas para un ciclo."""
        alertas = []
        
        # Alerta por tiempo excesivo en estado
        dias_desde_siembra = ciclo.get('dias_desde_siembra', 0)
        estado = ciclo['estado']
        
        if estado == 'Planificado' and dias_desde_siembra > 30:
            alertas.append("Ciclo planificado por más de 30 días sin iniciar")
        
        elif estado == 'En Preparación' and dias_desde_siembra > 45:
            alertas.append("Preparación prolongada - considerar sembrar")
        
        elif estado == 'En Desarrollo' and dias_desde_siembra > 365:
            alertas.append("Ciclo en desarrollo por más de 1 año")
        
        # Alerta por fechas
        if ciclo.get('fecha_cosecha_estimada'):
            try:
                fecha_estimada = datetime.strptime(ciclo['fecha_cosecha_estimada'], '%Y-%m-%d').date()
                if fecha_estimada < date.today() and estado not in ['Finalizado', 'Cancelado']:
                    alertas.append("Fecha de cosecha estimada vencida")
            except:
                pass
        
        return alertas
    
    def _analizar_fechas_ciclo(self, ciclo):
        """Analiza las fechas del ciclo y su coherencia."""
        analisis = {
            'fechas_completas': True,
            'coherencia': True,
            'alertas_fechas': []
        }
        
        fechas = ['fecha_siembra', 'fecha_cosecha_estimada']
        fechas_presentes = [f for f in fechas if ciclo.get(f)]
        
        analisis['fechas_completas'] = len(fechas_presentes) >= 2
        
        # Verificar coherencia temporal
        try:
            if ciclo.get('fecha_siembra') and ciclo.get('fecha_cosecha_estimada'):
                siembra = datetime.strptime(ciclo['fecha_siembra'], '%Y-%m-%d').date()
                cosecha_est = datetime.strptime(ciclo['fecha_cosecha_estimada'], '%Y-%m-%d').date()
                
                if cosecha_est <= siembra:
                    analisis['coherencia'] = False
                    analisis['alertas_fechas'].append("Fecha de cosecha estimada anterior o igual a fecha de siembra")
        except Exception:
            analisis['coherencia'] = False
            analisis['alertas_fechas'].append("Error en formato de fechas")
        
        return analisis
    
    def _calcular_eficiencia_temporal(self, ciclo):
        """Calcula la eficiencia temporal del ciclo."""
        if not ciclo.get('fecha_siembra') or not ciclo.get('fecha_cosecha_estimada'):
            return {'eficiencia': 0, 'categoria': 'sin_datos'}
        
        try:
            siembra = datetime.strptime(ciclo['fecha_siembra'], '%Y-%m-%d').date()
            cosecha_est = datetime.strptime(ciclo['fecha_cosecha_estimada'], '%Y-%m-%d').date()
            
            dias_estimados = (cosecha_est - siembra).days
            dias_desde_siembra = ciclo.get('dias_desde_siembra', 0)
            
            # Usar progreso actual como proxy de eficiencia (válido también para Finalizado cuando
            # la fecha real ya no se registra en la BD)
            progreso = (dias_desde_siembra / dias_estimados) * 100 if dias_estimados > 0 else 0
            eficiencia = min(100, progreso)
            
            if eficiencia >= 90:
                categoria = 'excelente'
            elif eficiencia >= 80:
                categoria = 'buena'
            elif eficiencia >= 70:
                categoria = 'aceptable'
            else:
                categoria = 'deficiente'
            
            return {'eficiencia': round(eficiencia, 1), 'categoria': categoria}
        except:
            return {'eficiencia': 0, 'categoria': 'error'}
    
    def _generar_recomendaciones_ciclo(self, ciclo):
        """Genera recomendaciones específicas para un ciclo."""
        recomendaciones = []
        estado = ciclo['estado']
        
        if estado == 'Planificado':
            recomendaciones.append("Definir fecha de inicio y preparar la parcela")
        elif estado == 'En Preparación':
            recomendaciones.append("Verificar condiciones del suelo y proceder con la siembra")
        elif estado == 'Sembrado':
            recomendaciones.append("Monitorear germinación y aplicar cuidados iniciales")
        elif estado == 'En Desarrollo':
            dias = ciclo.get('dias_desde_siembra', 0)
            if dias > 180:
                recomendaciones.append("Evaluar punto de cosecha - ciclo prolongado")
            else:
                recomendaciones.append("Continuar monitoreo y mantenimiento")
        elif estado == 'En Cosecha':
            recomendaciones.append("Proceder con cosecha y registrar rendimiento real")
        
        # Recomendaciones por alertas
        alertas = self._generar_alertas_ciclo(ciclo)
        if alertas:
            recomendaciones.append("Atender alertas identificadas")
        
        return recomendaciones
    
    def _obtener_acciones_disponibles(self, ciclo):
        """Obtiene las acciones disponibles para un ciclo según su estado."""
        estado = ciclo['estado']
        acciones = ['ver_detalle', 'editar']
        
        if self._puede_avanzar_estado_cached(ciclo):
            acciones.append('avanzar_estado')
        
        if estado not in ['Finalizado', 'Cancelado']:
            acciones.append('cancelar')
        
        if estado == 'En Cosecha':
            acciones.append('finalizar')
        
        return acciones
    
    def _obtener_acciones_siguiente_estado(self, estado):
        """Obtiene las acciones recomendadas para el siguiente estado."""
        acciones = {
            'Planificado': ['Preparar parcela', 'Verificar insumos'],
            'En Preparación': ['Iniciar siembra', 'Verificar condiciones'],
            'Sembrado': ['Monitorear germinación', 'Aplicar cuidados'],
            'En Desarrollo': ['Continuar mantenimiento', 'Evaluar progreso'],
            'En Cosecha': ['Proceder con cosecha', 'Registrar rendimiento'],
            'Finalizado': ['Analizar resultados', 'Planificar siguiente ciclo'],
            'Cancelado': ['Analizar causas', 'Recuperar parcela']
        }
        return acciones.get(estado, [])
    
    def _calcular_progreso_por_estado(self, estado):
        """Calcula el progreso estimado según el estado."""
        progresos = {
            'Planificado': 0,
            'En Preparación': 15,
            'Sembrado': 30,
            'En Desarrollo': 70,
            'En Cosecha': 90,
            'Finalizado': 100,
            'Cancelado': 0
        }
        return progresos.get(estado, 0)
    
    def _calcular_metricas_finalizacion(self, ciclo, datos_finalizacion):
        """Calcula métricas al finalizar un ciclo ."""
        metricas = {}
        
        try:
            if ciclo.get('fecha_siembra') and datos_finalizacion.get('fecha_cosecha'):
                # Parsear fechas si vienen como string
                if isinstance(ciclo['fecha_siembra'], str):
                    siembra = datetime.strptime(ciclo['fecha_siembra'], '%Y-%m-%d').date()
                else:
                    siembra = ciclo['fecha_siembra']
                
                fecha_cosecha = datos_finalizacion['fecha_cosecha']
                if isinstance(fecha_cosecha, str):
                    fecha_cosecha = datetime.strptime(fecha_cosecha, '%Y-%m-%d').date()
                
                duracion = (fecha_cosecha - siembra).days
                metricas['duracion_real_dias'] = duracion
                
                # Eficiencia temporal vs estimado (si existe fecha estimada)
                if ciclo.get('fecha_cosecha_estimada'):
                    try:
                        cosecha_est = datetime.strptime(ciclo['fecha_cosecha_estimada'], '%Y-%m-%d').date()
                        duracion_estimada = (cosecha_est - siembra).days
                        eficiencia = (duracion_estimada / duracion) * 100 if duracion > 0 else 0
                        metricas['eficiencia_temporal'] = round(eficiencia, 1)
                    except Exception:
                        # Ignorar formato inválido de fecha estimada
                        pass
        except Exception:
            # En caso de cualquier error devolver métricas vacías
            pass
        
        return metricas
    
    def _calcular_estadisticas_pagina_cached(self, ciclos):
        """Calcula estadísticas de la página actual (versión cacheada)."""
        if not ciclos:
            return {}
        
        estados = [c['estado'] for c in ciclos]
        area_total = sum(c['area_sembrada'] for c in ciclos)
        
        return {
            'total_ciclos_pagina': len(ciclos),
            'estados_unicos': len(set(estados)),
            'area_total_pagina': round(area_total, 2),
            'area_promedio': round(area_total / len(ciclos), 2),
            'ciclos_activos_pagina': sum(1 for c in ciclos if c['es_activo']),
            'distribucion_estados': {estado: estados.count(estado) for estado in set(estados)}
        }
    
    def _generar_alertas_sistema_ciclos(self):
        """Genera alertas a nivel de sistema para ciclos."""
        alertas = []
        
        try:
            # Ciclos retrasados
            ciclos_retrasados = self._contar_ciclos_retrasados()
            if ciclos_retrasados > 0:
                alertas.append(f"{ciclos_retrasados} ciclos con retraso en cronograma")
            
            # Ciclos sin actividad reciente
            # Otros análisis del sistema
            
        except Exception as e:
            logger.error(f"Error generando alertas del sistema: {str(e)}")
            alertas.append("Error al verificar estado del sistema")
        
        return alertas
    
    def _contar_ciclos_retrasados(self):
        """Cuenta ciclos que están retrasados según su cronograma."""
        try:
            ciclos_activos = self.ciclo_repo.obtener_ciclos_activos()
            retrasados = 0
            
            for ciclo in ciclos_activos:
                if ciclo.get('fecha_cosecha_estimada'):
                    try:
                        fecha_estimada = datetime.strptime(ciclo['fecha_cosecha_estimada'], '%Y-%m-%d').date()
                        if fecha_estimada < date.today() and ciclo['estado'] not in ['Finalizado', 'Cancelado']:
                            retrasados += 1
                    except:
                        continue
            
            return retrasados
        except Exception:
            return 0
    
    def _calcular_eficiencia_planificacion(self):
        """Calcula la eficiencia general de planificación."""
        try:
            estadisticas = self.ciclo_repo.obtener_estadisticas()
            total = estadisticas.get('total_ciclos', 0)
            finalizados = estadisticas.get('ciclos_finalizados', 0)
            cancelados = estadisticas.get('ciclos_cancelados', 0)
            
            if total == 0:
                return 0
            
            exito = total - cancelados
            return round((exito / total) * 100, 1)
        except Exception:
            return 0
    
    def _calcular_utilizacion_parcelas(self):
        """Calcula el porcentaje de utilización de parcelas."""
        try:
            # Esta sería una consulta compleja que cruza parcelas y ciclos
            return 75.0  # Placeholder
        except Exception:
            return 0
    
    def _calcular_rendimiento_promedio_sistema(self):
        """Calcula el rendimiento promedio del sistema."""
        try:
            # Basado en variedades utilizadas y sus rendimientos esperados
            return 12.5  # Placeholder
        except Exception:
            return 0
    
    def _evaluar_diversidad_cultivos_activos(self):
        """Evalúa la diversidad de cultivos en ciclos activos."""
        try:
            ciclos_activos = self.ciclo_repo.obtener_ciclos_activos()
            tipos_unicos = set()
            
            for ciclo in ciclos_activos:
                tipos_unicos.add(ciclo.get('nombre_tipo_cultivo', ''))
            
            return len(tipos_unicos)
        except Exception:
            return 0
    
    def _predecir_cosechas_proximo_mes(self):
        """Predice cuántas cosechas habrá el próximo mes."""
        try:
            fecha_limite = date.today() + timedelta(days=30)
            ciclos_activos = self.ciclo_repo.obtener_ciclos_activos()
            
            cosechas_programadas = 0
            for ciclo in ciclos_activos:
                if ciclo.get('fecha_cosecha_estimada'):
                    try:
                        fecha_est = datetime.strptime(ciclo['fecha_cosecha_estimada'], '%Y-%m-%d').date()
                        if fecha_est <= fecha_limite:
                            cosechas_programadas += 1
                    except:
                        continue
            
            return cosechas_programadas
        except Exception:
            return 0
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        return datetime.now().isoformat()
    
    # ==================== NUEVO MÉTODO PRINCIPAL ====================
    
    @cache_invalidator('servicio_ciclos', pattern='paginado_')
    @cache_invalidator('servicio_ciclos', pattern='activos_')
    @cache_invalidator('servicio_lotes', pattern='paginado_')        # Invalidar lotes también
    @cache_invalidator('estadisticas_ciclos_servicio')
    def finalizar_ciclo_con_cosecha(self, id_ciclo, datos_cosecha):
        """
        Finaliza un ciclo de producción registrando la cosecha.
        MÉTODO PRINCIPAL para el flujo Ciclo → Cosecha → Lote → Venta
        
        Args:
            id_ciclo (int): ID del ciclo de producción
            datos_cosecha (dict): Datos de la cosecha {
                'cantidad_cosechada': float,
                'fecha_cosecha': str/date,
                'unidad_medida': str (opcional),
                'precio_unitario_sugerido': float (opcional),
                'costo_produccion_unitario': float (opcional),
                'observaciones': str (opcional),
                'registrado_por': int
            }
            
        Returns:
            dict: Resultado completo de la operación {
                'exito': bool,
                'mensaje': str,
                'id_lote': int,
                'codigo_lote': str,
                'ciclo_finalizado': bool,
                'datos_analisis': dict,
                'recomendaciones': list
            }
        """
        try:
            # 1. Validar que el ciclo esté listo para cosecha
            ciclo = self._validar_ciclo_para_cosecha(id_ciclo)
            
            # 2. Validar datos de cosecha con reglas de negocio
            self._validar_datos_cosecha_completos(datos_cosecha, ciclo)
            
            # 3. Preparar datos del lote con información del ciclo
            datos_lote = self._preparar_datos_lote_desde_ciclo(datos_cosecha, ciclo)
            
            # 4. Crear lote de cosecha (transacción)
            exito_lote, id_lote = self.lote_repo.crear(datos_lote)
            
            if not exito_lote:
                return {
                    'exito': False,
                    'mensaje': 'Error al crear el lote de cosecha'
                }
            
            # 5. Actualizar ciclo a estado "Finalizado"
            exito_ciclo = self._finalizar_ciclo_estado(id_ciclo, datos_cosecha['fecha_cosecha'])
            
            if not exito_ciclo:
                # Rollback: eliminar lote si no se pudo finalizar ciclo
                self.lote_repo.desactivar(id_lote)
                return {
                    'exito': False,
                    'mensaje': 'Error al finalizar el ciclo. Operación revertida.'
                }
            
            # 6. Obtener información completa del lote creado
            lote_creado = self.lote_repo.obtener_por_id(id_lote)
            
            # 8. Generar recomendaciones
            recomendaciones = self._generar_recomendaciones_finalizacion(ciclo, lote_creado, analisis_rendimiento)
            
            # 9. Crear respuesta completa
            resultado = {
                'exito': True,
                'mensaje': f"Ciclo finalizado exitosamente. Lote '{lote_creado['codigo_lote']}' creado.",
                'id_lote': id_lote,
                'codigo_lote': lote_creado['codigo_lote'],
                'ciclo_finalizado': True,
                'ciclo_info': {
                    'id_ciclo': id_ciclo,
                    'estado_anterior': ciclo['estado'],
                    'estado_nuevo': 'Finalizado',
                    'fecha_finalizacion': datos_cosecha['fecha_cosecha']
                },
                'lote_info': {
                    'cantidad_cosechada': lote_creado['cantidad_cosechada'],
                    'rendimiento_por_hectarea': lote_creado['rendimiento_por_hectarea'],
                },
                'recomendaciones': recomendaciones,
                'requiere_actualizacion': {
                    'ciclos': True,
                    'lotes': True,
                    'estadisticas': True,
                    'dashboard': True
                }
            }
            
            logger.info(f"Ciclo {id_ciclo} finalizado con cosecha. Lote creado: {id_lote}")
            return resultado
            
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error de validación en finalizar_ciclo_con_cosecha: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'tipo_error': 'validacion'
            }
        except Exception as e:
            logger.error(f"Error interno en finalizar_ciclo_con_cosecha: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'tipo_error': 'interno'
            }
    
    # ==================== MÉTODOS DE VALIDACIÓN ESPECÍFICOS ====================
    
    def _validar_ciclo_para_cosecha(self, id_ciclo):
        """
        Valida que el ciclo esté en condiciones de ser cosechado.
        
        Args:
            id_ciclo (int): ID del ciclo
            
        Returns:
            dict: Información del ciclo validado
            
        Raises:
            RegistroNoEncontrado: Si el ciclo no existe
            ErrorValidacion: Si el ciclo no está en estado válido
        """
        try:
            ciclo = self.ciclo_repo.obtener_por_id(id_ciclo)
        except RegistroNoEncontrado:
            raise ErrorValidacion(f"El ciclo con ID {id_ciclo} no existe")
        
        # Validar estado del ciclo
        estados_validos = ['En Cosecha', 'En Desarrollo']
        if ciclo['estado'] not in estados_validos:
            raise ErrorValidacion(
                f"El ciclo debe estar en estado '{' o '.join(estados_validos)}'. "
                f"Estado actual: '{ciclo['estado']}'"
            )
        
        # Validar que no esté ya finalizado
        if ciclo['estado'] == 'Finalizado':
            raise ErrorValidacion("El ciclo ya está finalizado")
        
        # Validar que no esté cancelado
        if ciclo['estado'] == 'Cancelado':
            raise ErrorValidacion("No se puede cosechar un ciclo cancelado")
        
        # Verificar si ya tiene lotes de cosecha
        lotes_existentes = self.lote_repo.obtener_por_ciclo(id_ciclo)
        if lotes_existentes:
            logger.warning(f"El ciclo {id_ciclo} ya tiene {len(lotes_existentes)} lotes registrados")
        
        return ciclo
    
    def _validar_datos_cosecha_completos(self, datos_cosecha, ciclo):
        """
        Valida datos de cosecha con reglas de negocio específicas.
        
        Args:
            datos_cosecha (dict): Datos de cosecha
            ciclo (dict): Información del ciclo
            
        Raises:
            ErrorValidacion: Si los datos no son válidos
        """
        # Validaciones básicas
        if not datos_cosecha.get('cantidad_cosechada'):
            raise ErrorValidacion("La cantidad cosechada es obligatoria")
        
        if datos_cosecha['cantidad_cosechada'] <= 0:
            raise ErrorValidacion("La cantidad cosechada debe ser mayor a 0")
        
        if not datos_cosecha.get('fecha_cosecha'):
            raise ErrorValidacion("La fecha de cosecha es obligatoria")
        
        if not datos_cosecha.get('registrado_por'):
            raise ErrorValidacion("El usuario que registra es obligatorio")
        
        # Validaciones de negocio
        area_sembrada = ciclo.get('area_sembrada', 0)
        if area_sembrada <= 0:
            raise ErrorValidacion("El ciclo no tiene área sembrada definida")
        
        # Validar rendimiento realista
        rendimiento_por_ha = datos_cosecha['cantidad_cosechada'] / area_sembrada
        
        # Rendimiento máximo realista: 100 ton/ha para la mayoría de cultivos
        if rendimiento_por_ha > 100:
            raise ErrorValidacion(
                f"El rendimiento calculado ({rendimiento_por_ha:.1f} ton/ha) "
                f"parece demasiado alto. Verificar cantidad y área."
            )
        
        # Rendimiento mínimo realista: 0.1 ton/ha
        if rendimiento_por_ha < 0.1:
            raise ErrorValidacion(
                f"El rendimiento calculado ({rendimiento_por_ha:.1f} ton/ha) "
                f"parece demasiado bajo. Verificar datos."
            )
        
        # Validar fecha de cosecha
        from datetime import datetime, date
        
        if isinstance(datos_cosecha['fecha_cosecha'], str):
            try:
                fecha_cosecha = datetime.strptime(datos_cosecha['fecha_cosecha'], '%Y-%m-%d').date()
            except ValueError:
                raise ErrorValidacion("Formato de fecha inválido. Use YYYY-MM-DD")
        else:
            fecha_cosecha = datos_cosecha['fecha_cosecha']
        
        # No permitir fechas futuras
        if fecha_cosecha > date.today():
            raise ErrorValidacion("La fecha de cosecha no puede ser futura")
        
        # Validar fecha vs fecha de siembra
        if ciclo.get('fecha_siembra'):
            if isinstance(ciclo['fecha_siembra'], str):
                fecha_siembra = datetime.strptime(ciclo['fecha_siembra'], '%Y-%m-%d').date()
            else:
                fecha_siembra = ciclo['fecha_siembra']
            
            if fecha_cosecha <= fecha_siembra:
                raise ErrorValidacion("La fecha de cosecha debe ser posterior a la fecha de siembra")
            
            # Tiempo mínimo entre siembra y cosecha (30 días)
            dias_transcurridos = (fecha_cosecha - fecha_siembra).days
            if dias_transcurridos < 30:
                raise ErrorValidacion(
                    f"Tiempo muy corto entre siembra y cosecha ({dias_transcurridos} días). "
                    f"Mínimo recomendado: 30 días"
                )
        
        # Validar precios si se proporcionan
        if datos_cosecha.get('precio_unitario_sugerido') is not None:
            if datos_cosecha['precio_unitario_sugerido'] < 0:
                raise ErrorValidacion("El precio unitario no puede ser negativo")
        
        if datos_cosecha.get('costo_produccion_unitario') is not None:
            if datos_cosecha['costo_produccion_unitario'] < 0:
                raise ErrorValidacion("El costo de producción no puede ser negativo")
    
    def _preparar_datos_lote_desde_ciclo(self, datos_cosecha, ciclo):
        """
        Prepara los datos del lote enriquecidos con información del ciclo.
        
        Args:
            datos_cosecha (dict): Datos de cosecha
            ciclo (dict): Información del ciclo
            
        Returns:
            dict: Datos completos para crear el lote
        """
        datos_lote = datos_cosecha.copy()
        
        # Agregar ID del ciclo
        datos_lote['id_ciclo'] = ciclo['id_ciclo']
        
        # Generar código de lote si no se proporciona
        if not datos_lote.get('codigo_lote'):
            datos_lote['codigo_lote'] = self._generar_codigo_lote_avanzado(ciclo)
        
        # Establecer unidad de medida por defecto
        if not datos_lote.get('unidad_medida'):
            datos_lote['unidad_medida'] = 'kg'
        
        # Calcular precio sugerido si no se proporciona
        if not datos_lote.get('precio_unitario_sugerido'):
            datos_lote['precio_unitario_sugerido'] = self._calcular_precio_sugerido_avanzado(ciclo, datos_cosecha)
        
        # Calcular costo de producción estimado si no se proporciona
        if not datos_lote.get('costo_produccion_unitario'):
            datos_lote['costo_produccion_unitario'] = self._estimar_costo_produccion(ciclo, datos_cosecha)
        
        # Agregar observaciones automáticas si están vacías
        if not datos_lote.get('observaciones'):
            datos_lote['observaciones'] = f"Lote generado automáticamente al finalizar ciclo {ciclo['id_ciclo']}"
        
        return datos_lote
    
    def _finalizar_ciclo_estado(self, id_ciclo, fecha_cosecha):
        """
        Actualiza el estado del ciclo a 'Finalizado'.
        
        Args:
            id_ciclo (int): ID del ciclo
            fecha_cosecha: Fecha de cosecha
            
        Returns:
            bool: True si fue exitoso
        """
        try:
            datos_actualizacion = {
                'estado': 'Finalizado'
            }
            
            return self.ciclo_repo.actualizar(id_ciclo, datos_actualizacion)
            
        except Exception as e:
            logger.error(f"Error al finalizar estado del ciclo {id_ciclo}: {str(e)}")
            return False
    
    # ==================== MÉTODOS DE ANÁLISIS ====================
    
    def _generar_recomendaciones_finalizacion(self, ciclo, lote, analisis):
        """
        Genera recomendaciones post-cosecha.
        
        Args:
            ciclo (dict): Información del ciclo
            lote (dict): Información del lote
            analisis (dict): Análisis de rendimiento
            
        Returns:
            list: Lista de recomendaciones
        """
        recomendaciones = []
        
        # Recomendaciones basadas en rendimiento
        categoria_rendimiento = analisis.get('categoria', '')
        
        if categoria_rendimiento == 'excelente':
            recomendaciones.append({
                'tipo': 'felicitacion',
                'mensaje': 'Excelente rendimiento obtenido. Documentar prácticas utilizadas para replicar.',
                'prioridad': 'info'
            })
        elif categoria_rendimiento == 'bajo':
            recomendaciones.append({
                'tipo': 'mejora',
                'mensaje': 'Analizar factores que afectaron el rendimiento: riego, fertilización, plagas.',
                'prioridad': 'media'
            })
        elif categoria_rendimiento == 'muy_bajo':
            recomendaciones.append({
                'tipo': 'urgente',
                'mensaje': 'Rendimiento crítico. Revisar todas las prácticas de cultivo antes del próximo ciclo.',
                'prioridad': 'alta'
            })
        else:
            recomendaciones.append({
                'tipo': 'precio',
                'mensaje': 'Definir precio de venta basado en costos de producción y mercado.',
                'prioridad': 'alta'
            })
        
        # Recomendaciones de timing
        dias_ciclo = analisis.get('dias_ciclo', 0)
        if dias_ciclo > 0:
            tiempo_esperado = self._obtener_tiempo_esperado_cultivo(ciclo)
            if tiempo_esperado and dias_ciclo > tiempo_esperado * 1.2:
                recomendaciones.append({
                    'tipo': 'timing',
                    'mensaje': f'Ciclo extendido ({dias_ciclo} días). Evaluar optimización de tiempos.',
                    'prioridad': 'baja'
                })
        
        # Recomendación de próximos pasos
        recomendaciones.append({
            'tipo': 'siguiente_paso',
            'mensaje': 'Lote disponible para venta. Registrar en sistema de comercialización.',
            'prioridad': 'info'
        })
        
        return recomendaciones
    
    # ==================== MÉTODOS AUXILIARES ====================
    
    def _generar_codigo_lote_avanzado(self, ciclo):
        """
        Genera código de lote más descriptivo.
        
        Args:
            ciclo (dict): Información del ciclo
            
        Returns:
            str: Código único del lote
        """
        from datetime import datetime
        
        fecha_actual = datetime.now()
        
        # Formato: L{id_ciclo}-{YYYYMMDD}-{HHMM}
        codigo_base = f"L{ciclo['id_ciclo']}-{fecha_actual.strftime('%Y%m%d')}-{fecha_actual.strftime('%H%M')}"
        
        # Agregar secuencial si ya existen lotes del mismo ciclo
        lotes_existentes = self.lote_repo.obtener_por_ciclo(ciclo['id_ciclo'])
        if lotes_existentes:
            secuencial = len(lotes_existentes) + 1
            codigo_base += f"-{secuencial:02d}"
        
        return codigo_base
    
    def _calcular_precio_sugerido_avanzado(self, ciclo, datos_cosecha):
        """
        Calcula precio sugerido basado en múltiples factores.
        
        Args:
            ciclo (dict): Información del ciclo
            datos_cosecha (dict): Datos de cosecha
            
        Returns:
            float: Precio sugerido
        """
        # Precio base simple (en producción sería más complejo)
        precio_base = 15.0  # Precio base por kg
        
        # Ajuste por cantidad (descuento por volumen inverso)
        cantidad = datos_cosecha.get('cantidad_cosechada', 0)
        if cantidad > 10000:  # Más de 10 toneladas
            factor_volumen = 0.95
        elif cantidad > 5000:  # Más de 5 toneladas
            factor_volumen = 0.98
        else:
            factor_volumen = 1.0
        
        precio_sugerido = precio_base  * factor_volumen
        
        return round(precio_sugerido, 2)
    
    def _estimar_costo_produccion(self, ciclo, datos_cosecha):
        """
        Estima costo de producción unitario.
        
        Args:
            ciclo (dict): Información del ciclo
            datos_cosecha (dict): Datos de cosecha
            
        Returns:
            float: Costo estimado por unidad
        """
        # Costo base estimado (en producción sería calculado desde costos reales)
        costo_base_por_hectarea = 8000.0  # Costo base por hectárea
        area_sembrada = ciclo.get('area_sembrada', 1)
        cantidad_cosechada = datos_cosecha.get('cantidad_cosechada', 1)
        
        costo_total_estimado = costo_base_por_hectarea * area_sembrada
        costo_unitario = costo_total_estimado / cantidad_cosechada
        
        return round(costo_unitario, 2)
    
    def _calcular_dias_ciclo(self, ciclo, fecha_cosecha):
        """
        Calcula los días transcurridos del ciclo.
        
        Args:
            ciclo (dict): Información del ciclo
            fecha_cosecha: Fecha de cosecha
            
        Returns:
            int: Días del ciclo
        """
        try:
            if not ciclo.get('fecha_siembra'):
                return 0
            
            from datetime import datetime
            
            if isinstance(ciclo['fecha_siembra'], str):
                fecha_siembra = datetime.strptime(ciclo['fecha_siembra'], '%Y-%m-%d').date()
            else:
                fecha_siembra = ciclo['fecha_siembra']
            
            if isinstance(fecha_cosecha, str):
                fecha_cosecha = datetime.strptime(fecha_cosecha, '%Y-%m-%d').date()
            
            return (fecha_cosecha - fecha_siembra).days
            
        except Exception:
            return 0
    
    def _obtener_tiempo_esperado_cultivo(self, ciclo):
        """
        Obtiene tiempo esperado del cultivo según la variedad.
        
        Args:
            ciclo (dict): Información del ciclo
            
        Returns:
            int: Días esperados o None
        """
        try:
            variedad = self.variedad_repo.obtener_por_id(ciclo['id_variedad'])
            return variedad.get('tiempo_produccion', None)
        except Exception:
            return None
