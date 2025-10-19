# bd_conecciones/servicios/variedad_cultivo_servicio.py

import logging
from ...repositories.CultivosRepositorio.variedad_cultivo_repositorio import VariedadCultivoRepositorio
from ...repositories.CultivosRepositorio.tipo_cultivo_repositorio import TipoCultivoRepositorio
from ...repositories.CultivosRepositorio.relacion_cultivo_repositorio import RelacionCultivoRepositorio
from ...core.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste,
    RegistroTieneDependencias
)
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class VariedadCultivoServicio:
    """Servicio para lógica de negocio de variedades de cultivo con caché optimizado."""
    
    def __init__(self):
        self.variedad_repo = VariedadCultivoRepositorio()
        self.tipo_repo = TipoCultivoRepositorio()
        self.relacion_repo = RelacionCultivoRepositorio()

    @cacheable('variedades', key_func=lambda id_tipo=None: f"variedades_{id_tipo or 'todas'}", ttl=get_ttl('variedades'))
    def obtener_variedades_cultivo(self, id_tipo_cultivo=None):
        """
        Obtiene las variedades de cultivo, opcionalmente filtradas por tipo de cultivo.
        
        Args:
            id_tipo_cultivo (int, optional): ID del tipo de cultivo para filtrar. Si es None, 
                                            se obtienen todas las variedades.
        
        Returns:
            list: Lista de diccionarios con la información de cada variedad.
        """
        try:
            if id_tipo_cultivo:
                return self.variedad_repo.obtener_por_tipo_cultivo(id_tipo_cultivo)
            else:
                return self.variedad_repo.obtener_todas()
        except Exception as e:
            logger.error(f"Error al obtener variedades de cultivo: {str(e)}")
            return []
    
    @cacheable('servicio_variedades', key_func=lambda pagina, por_pagina=8, tipo_id=None: f"paginado_{pagina}_{por_pagina}_{tipo_id or 'all'}", ttl=900)  # 15 min
    def obtener_variedades_paginado(self, pagina, por_pagina=8, id_tipo_cultivo=None):
        """
        Obtiene variedades con paginación y lógica de negocio aplicada.
        ⭐ MUY OPTIMIZADO: Resultado enriquecido completo cacheado para evitar N+1 queries
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            id_tipo_cultivo (int, optional): Filtro por tipo de cultivo.
            
        Returns:
            dict: Resultado con variedades y metadatos.
        """
        try:
            resultado = self.variedad_repo.obtener_paginado(pagina, por_pagina, id_tipo_cultivo)
            
            # Enriquecer datos con información adicional (OPTIMIZADO: resultado completo cacheado)
            variedades_enriquecidas = []
            for variedad in resultado['variedades']:
                variedad_enriquecida = variedad.copy()
                
                # Obtener datos adicionales (estos métodos ya están cacheados en repositorios)
                variedad_enriquecida['total_ciclos'] = self._contar_ciclos_cached(variedad['id_variedad'])
                variedad_enriquecida['puede_eliminar'] = self._puede_eliminar_variedad_cached(variedad['id_variedad'])
                
                # Agregar metadatos de negocio
                variedad_enriquecida['esta_en_uso'] = variedad_enriquecida['total_ciclos'] > 0
                variedad_enriquecida['categoria_uso'] = self._categorizar_uso_variedad(variedad_enriquecida['total_ciclos'])
                variedad_enriquecida['nivel_rendimiento'] = self._categorizar_nivel_rendimiento(variedad['rendimiento_esperado'])
                variedad_enriquecida['completitud_datos'] = self._evaluar_completitud_variedad(variedad)
                
                # Información de productividad
                variedad_enriquecida['info_productividad'] = self._analizar_productividad_variedad(variedad)
                variedad_enriquecida['recomendacion_uso'] = self._generar_recomendacion_uso(variedad, variedad_enriquecida['total_ciclos'])
                
                variedades_enriquecidas.append(variedad_enriquecida)
            
            # Actualizar resultado con datos enriquecidos
            resultado['variedades'] = variedades_enriquecidas
            resultado['filtro_tipo'] = id_tipo_cultivo
            resultado['estadisticas_pagina'] = self._calcular_estadisticas_pagina_cached(variedades_enriquecidas)
            resultado['metadatos_servicio'] = {
                'timestamp': self._get_timestamp(),
                'total_en_uso': sum(1 for v in variedades_enriquecidas if v['esta_en_uso']),
                'total_con_rendimiento': sum(1 for v in variedades_enriquecidas if v['tiene_rendimiento']),
                'rendimiento_promedio_pagina': self._calcular_rendimiento_promedio_pagina(variedades_enriquecidas)
            }
            
            logger.info(f"Servicio: página {pagina} procesada con {len(resultado['variedades'])} variedades")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_variedades_paginado: {str(e)}")
            raise
        
    def agregar_variedad_cultivo(self, variedad_data):
        """
        Agrega una nueva variedad de cultivo a la base de datos.
        
        Args:
            variedad_data (dict): Datos de la variedad de cultivo a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID de la variedad agregada o None en caso de error.
        """
        try:
            return self.variedad_repo.crear(variedad_data)
        except Exception as e:
            logger.error(f"Error al agregar variedad de cultivo: {str(e)}")
            return False, None
    
    @cache_invalidator('servicio_variedades', pattern='paginado_')       # Invalidar paginación
    @cache_invalidator('servicio_variedades', pattern='busqueda_')      # Invalidar búsquedas
    @cache_invalidator('servicio_variedades', pattern='tipo_')          # Invalidar por tipo
    @cache_invalidator('validaciones_variedades')                       # Invalidar validaciones
    @cache_invalidator('estadisticas_variedades_servicio')              # Invalidar estadísticas
    def crear_variedad(self, datos_variedad):
        """
        Crea una nueva variedad con validaciones de negocio.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_variedad (dict): Datos de la variedad.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio adicionales
            self._validar_reglas_negocio_creacion_cached(datos_variedad)
            
            # Validar que el tipo de cultivo exista y esté activo
            tipo_cultivo = self._validar_tipo_cultivo_cached(datos_variedad['id_tipo_cultivo'])
            
            # Normalizar y enriquecer datos
            datos_normalizados = self._normalizar_datos_variedad(datos_variedad)
            
            # Crear variedad
            exito, id_variedad = self.variedad_repo.crear(datos_normalizados)
            
            if exito:
                # Obtener información de la variedad creada
                variedad_creada = self.variedad_repo.obtener_por_id(id_variedad)
                
                resultado = {
                    'exito': True,
                    'id_variedad': id_variedad,
                    'mensaje': f"Variedad '{datos_normalizados['nombre']}' creada exitosamente",
                    'variedad': variedad_creada,
                    'tipo_cultivo': tipo_cultivo['nombre'],
                    'tiene_rendimiento': bool(datos_normalizados.get('rendimiento_esperado')),
                    'categoria_rendimiento': self._categorizar_nivel_rendimiento(datos_normalizados.get('rendimiento_esperado')),
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: variedad creada con ID {id_variedad}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear variedad'}
                
        except (ErrorValidacion, RegistroYaExiste, RegistroNoEncontrado) as e:
            logger.error(f"Error de validación en crear_variedad: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_variedad: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_variedades', pattern='paginado_')       # Invalidar paginación
    @cache_invalidator('servicio_variedades', pattern='busqueda_')      # Invalidar búsquedas
    @cache_invalidator('servicio_variedades', pattern='tipo_')          # Invalidar por tipo
    @cache_invalidator('validaciones_variedades')                       # Invalidar validaciones
    @cache_invalidator('estadisticas_variedades_servicio')              # Invalidar estadísticas
    def actualizar_variedad(self, id_variedad, datos_variedad):
        """
        Actualiza una variedad con validaciones de negocio.
        OPTIMIZADO: Invalidación específica de la variedad actualizada.
        
        Args:
            id_variedad (int): ID de la variedad.
            datos_variedad (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales para comparación
            variedad_actual = self.variedad_repo.obtener_por_id(id_variedad)
            
            # Validar cambios críticos
            self._validar_cambios_criticos(variedad_actual, datos_variedad)
            
            # Validar nuevo tipo de cultivo si cambió
            if 'id_tipo_cultivo' in datos_variedad:
                tipo_cultivo = self._validar_tipo_cultivo_cached(datos_variedad['id_tipo_cultivo'])
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_variedad(datos_variedad)
            
            # Actualizar variedad
            exito = self.variedad_repo.actualizar(id_variedad, datos_normalizados)
            
            if exito:
                # Verificar cambios importantes
                cambio_tipo = self._verificar_cambio_tipo(variedad_actual, datos_normalizados)
                cambio_rendimiento = self._verificar_cambio_rendimiento(variedad_actual, datos_normalizados)
                cambio_nombre = 'nombre' in datos_normalizados and variedad_actual['nombre'] != datos_normalizados['nombre']
                
                resultado = {
                    'exito': True,
                    'mensaje': f"Variedad '{variedad_actual['nombre']}' actualizada exitosamente",
                    'cambio_tipo_cultivo': cambio_tipo,
                    'cambio_rendimiento': cambio_rendimiento,
                    'cambio_nombre': cambio_nombre,
                    'requiere_actualizacion_listas': True,
                    'impacto_ciclos': self._evaluar_impacto_en_ciclos(id_variedad, datos_normalizados)
                }
                
                logger.info(f"Servicio: variedad {id_variedad} actualizada")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar variedad'}
                
        except (ErrorValidacion, RegistroNoEncontrado, RegistroYaExiste) as e:
            logger.error(f"Error en actualizar_variedad: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_variedad: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_variedades', pattern='paginado_')       # Invalidar paginación
    @cache_invalidator('servicio_variedades', pattern='busqueda_')      # Invalidar búsquedas
    @cache_invalidator('servicio_variedades', pattern='tipo_')          # Invalidar por tipo
    @cache_invalidator('validaciones_variedades')                       # Invalidar validaciones
    @cache_invalidator('estadisticas_variedades_servicio')              # Invalidar estadísticas
    def eliminar_variedad(self, id_variedad):
        """
        Elimina una variedad verificando dependencias y reglas de negocio.
        OPTIMIZADO: Invalidación completa ya que afecta listas y estadísticas.
        
        Args:
            id_variedad (int): ID de la variedad.
            
        Returns:
            dict: Resultado detallado de la operación.
        """
        try:
            # Obtener información de la variedad
            variedad = self.variedad_repo.obtener_por_id(id_variedad)
            
            # Verificar dependencias usando RelacionCultivoRepositorio (ya cacheado)
            dependencias = self.relacion_repo.verificar_dependencias_variedad(id_variedad)
            
            # Si tiene dependencias, no se puede eliminar
            if not dependencias['puede_eliminar']:
                return {
                    'exito': False,
                    'mensaje': f"No se puede eliminar '{variedad['nombre']}'",
                    'razon': 'Tiene ciclos de producción asociados',
                    'dependencias': dependencias,
                    'tipo_error': 'dependencias'
                }
            
            # Proceder con eliminación
            exito = self.variedad_repo.desactivar(id_variedad)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Variedad '{variedad['nombre']}' eliminada exitosamente",
                    'nombre_eliminado': variedad['nombre'],
                    'tipo_cultivo': variedad['nombre_tipo_cultivo'],
                    'tenia_rendimiento': variedad['tiene_rendimiento'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: variedad {id_variedad} eliminada")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al eliminar variedad'}
                
        except RegistroTieneDependencias as e:
            logger.error(f"No se puede eliminar variedad: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'razon': 'Tiene dependencias',
                'dependencias': {'ciclos': e.cantidad_dependencias},
                'tipo_error': 'dependencias'
            }
        except RegistroNoEncontrado as e:
            logger.error(f"Variedad no encontrada: {str(e)}")
            return {'exito': False, 'mensaje': str(e), 'tipo_error': 'no_encontrado'}
        except Exception as e:
            logger.error(f"Error en servicio eliminar_variedad: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema', 'tipo_error': 'interno'}

    @cache_invalidator('variedades')
    def desactivar_variedad_cultivo(self, id_variedad):
        """
        Desactiva una variedad de cultivo en lugar de eliminarla físicamente.
        
        Args:
            id_variedad (int): ID de la variedad de cultivo a desactivar.
            
        Returns:
            bool: True si se desactivó correctamente, False en caso contrario.
        """
        try:
            return self.variedad_repo.desactivar(id_variedad)
        except Exception as e:
            logger.error(f"Error al desactivar variedad de cultivo: {str(e)}")
            return False

    @cacheable('servicio_variedades', key_func=lambda texto: f"busqueda_{texto.lower().replace(' ', '_')}", ttl=600)  # 10 min
    def buscar_variedades(self, texto_busqueda):
        """
        Busca variedades con lógica de negocio aplicada.
        ⭐ OPTIMIZADO: Resultado enriquecido completo cacheado
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de variedades encontradas con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return []
            
            variedades = self.variedad_repo.buscar_por_nombre(texto_busqueda.strip())
            
            # Enriquecer resultados (OPTIMIZADO: resultado completo cacheado)
            variedades_enriquecidas = []
            for variedad in variedades:
                variedad_enriquecida = variedad.copy()
                
                # Agregar información adicional (métodos ya cacheados en repositorios)
                variedad_enriquecida['total_ciclos'] = self._contar_ciclos_cached(variedad['id_variedad'])
                variedad_enriquecida['puede_eliminar'] = self._puede_eliminar_variedad_cached(variedad['id_variedad'])
                
                # Metadatos de negocio
                variedad_enriquecida['esta_en_uso'] = variedad_enriquecida['total_ciclos'] > 0
                variedad_enriquecida['categoria_uso'] = self._categorizar_uso_variedad(variedad_enriquecida['total_ciclos'])
                variedad_enriquecida['nivel_rendimiento'] = self._categorizar_nivel_rendimiento(variedad['rendimiento_esperado'])
                variedad_enriquecida['relevancia_busqueda'] = self._calcular_relevancia_busqueda_variedad(variedad, texto_busqueda)
                
                variedades_enriquecidas.append(variedad_enriquecida)
            
            # Ordenar por relevancia
            variedades_enriquecidas.sort(key=lambda x: x['relevancia_busqueda'], reverse=True)
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(variedades_enriquecidas)} variedades")
            return variedades_enriquecidas
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_variedades: {str(e)}")
            return []

    @cacheable('servicio_variedades', key_func=lambda tipo_id: f"tipo_{tipo_id}", ttl=1200)  # 20 min
    def obtener_variedades_por_tipo(self, id_tipo_cultivo):
        """
        Obtiene variedades de un tipo de cultivo específico con información enriquecida.
        ⭐ OPTIMIZADO: Resultado enriquecido cacheado por tipo
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            list: Lista de variedades del tipo con información adicional.
        """
        try:
            if id_tipo_cultivo == 0:
                variedades = self.variedad_repo.obtener_todas()
            else:
                variedades = self.variedad_repo.obtener_por_tipo_cultivo(id_tipo_cultivo)
            
            # Enriquecer datos (OPTIMIZADO: resultado completo cacheado)
            variedades_enriquecidas = []
            for variedad in variedades:
                variedad_enriquecida = variedad.copy()
                
                # Agregar información adicional
                variedad_enriquecida['total_ciclos'] = self._contar_ciclos_cached(variedad['id_variedad'])
                variedad_enriquecida['esta_en_uso'] = variedad_enriquecida['total_ciclos'] > 0
                variedad_enriquecida['categoria_uso'] = self._categorizar_uso_variedad(variedad_enriquecida['total_ciclos'])
                variedad_enriquecida['nivel_rendimiento'] = self._categorizar_nivel_rendimiento(variedad['rendimiento_esperado'])
                variedad_enriquecida['info_productividad'] = self._analizar_productividad_variedad(variedad)
                
                variedades_enriquecidas.append(variedad_enriquecida)
            
            return variedades_enriquecidas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_variedades_por_tipo: {str(e)}")
            return []

    @cacheable('servicio_variedades', key_func=lambda rendimiento_min: f"rendimiento_{rendimiento_min}", ttl=1200)  # 20 min
    def obtener_variedades_alto_rendimiento(self, rendimiento_minimo=10.0):
        """
        Obtiene variedades con alto rendimiento esperado.
        
        Args:
            rendimiento_minimo (float): Rendimiento mínimo esperado.
            
        Returns:
            list: Lista de variedades de alto rendimiento.
        """
        try:
            variedades = self.variedad_repo.obtener_por_rendimiento(rendimiento_minimo)
            
            # Enriquecer con análisis de rendimiento
            for variedad in variedades:
                variedad['total_ciclos'] = self._contar_ciclos_cached(variedad['id_variedad'])
                variedad['popularidad'] = self._categorizar_uso_variedad(variedad['total_ciclos'])
                variedad['eficiencia_estimada'] = self._calcular_eficiencia_estimada(variedad)
                variedad['recomendacion_cultivo'] = self._generar_recomendacion_cultivo(variedad)
            
            # Ordenar por rendimiento y popularidad
            variedades.sort(key=lambda x: (x['rendimiento_esperado'], x['total_ciclos']), reverse=True)
            
            logger.info(f"Variedades con rendimiento ≥ {rendimiento_minimo}: {len(variedades)} encontradas")
            return variedades
            
        except Exception as e:
            logger.error(f"Error en obtener_variedades_alto_rendimiento: {str(e)}")
            return []

    @cacheable('estadisticas_variedades_servicio', key_func=lambda: 'completas_servicio', ttl=1800)  # 30 min
    def obtener_estadisticas_variedades(self):
        """
        Obtiene estadísticas completas de variedades a nivel de servicio.
        ⭐ MUY OPTIMIZADO: Múltiples consultas a repositorios ahora cacheadas como conjunto
        
        Returns:
            dict: Estadísticas detalladas con métricas de negocio.
        """
        try:
            # Estos métodos ya están cacheados en repositorios, pero el resultado final también se cachea
            estadisticas_basicas = self.variedad_repo.obtener_estadisticas()
            top_variedades = self.relacion_repo.obtener_variedades_mejor_rendimiento(5)
            ranking_rendimiento = self.variedad_repo.obtener_ranking_por_rendimiento(10)
            
            # Estadísticas enriquecidas de servicio
            estadisticas = {
                **estadisticas_basicas,
                'top_variedades_rendimiento': top_variedades,
                'ranking_completo': ranking_rendimiento,
                'distribucion_rendimiento': self._analizar_distribucion_rendimiento(),
                'analisis_resistencia': self._analizar_resistencia_por_zona(),
                
                # Nuevas métricas de servicio
                'metricas_servicio': {
                    'variedades_sin_uso': self._contar_variedades_sin_uso(),
                    'variedades_populares': len([v for v in top_variedades if v['total_ciclos'] >= 5]),
                    'rendimiento_promedio_sistema': estadisticas_basicas.get('rendimiento_promedio', 0),
                    'diversidad_por_tipo': self._calcular_diversidad_por_tipo(),
                    'cobertura_resistencia': self._evaluar_cobertura_resistencia(),
                    'timestamp': self._get_timestamp()
                }
            }
            
            logger.info(f"Estadísticas completas de variedades calculadas: {estadisticas_basicas.get('total_variedades', 0)} variedades")
            return estadisticas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_variedades: {str(e)}")
            return {}

    @cacheable('estados_variedades', key_func=lambda id_variedad: f"estado_completo_{id_variedad}", ttl=1200)  # 20 min
    def verificar_estado_variedad(self, id_variedad):
        """
        Verifica el estado completo de una variedad.
        ⭐ OPTIMIZADO: Estado completo cacheado para evitar múltiples consultas
        
        Args:
            id_variedad (int): ID de la variedad.
            
        Returns:
            dict: Estado completo de la variedad.
        """
        try:
            # Estos métodos ya están cacheados en repositorios
            variedad = self.variedad_repo.obtener_por_id(id_variedad)
            total_ciclos = self._contar_ciclos_cached(id_variedad)
            
            estado = {
                'variedad': variedad,
                'total_ciclos': total_ciclos,
                'puede_eliminar': total_ciclos == 0,
                'esta_en_uso': total_ciclos > 0,
                'tipo_cultivo_info': self._obtener_info_tipo_cached(variedad['id_tipo_cultivo']),
                'timestamp_verificacion': self._get_timestamp(),
                
                # Información adicional de negocio
                'categoria_uso': self._categorizar_uso_variedad(total_ciclos),
                'nivel_rendimiento': self._categorizar_nivel_rendimiento(variedad['rendimiento_esperado']),
                'completitud_datos': self._evaluar_completitud_variedad(variedad),
                'productividad': self._analizar_productividad_variedad(variedad),
                'recomendaciones': self._generar_recomendaciones_variedad(variedad, total_ciclos)
            }
            
            return estado
            
        except RegistroNoEncontrado as e:
            logger.error(f"Variedad no encontrada: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Error en servicio verificar_estado_variedad: {str(e)}")
            return None

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('conteos_variedades', key_func=lambda id_variedad: f"ciclos_{id_variedad}", ttl=900)  # 15 min
    def _contar_ciclos_cached(self, id_variedad):
        """
        Cuenta ciclos de producción de una variedad (versión cacheada).
        ⭐ OPTIMIZADO: Evita consultar repetidamente el mismo conteo
        
        Args:
            id_variedad (int): ID de la variedad.
            
        Returns:
            int: Número de ciclos activos.
        """
        try:
            return self.relacion_repo._contar_registros(
                "CiclosProduccion", 
                "id_variedad = ? AND activo = 1", 
                (id_variedad,)
            )
        except Exception:
            return 0

    @cacheable('validaciones_variedades', key_func=lambda id_variedad: f"puede_eliminar_{id_variedad}", ttl=900)  # 15 min
    def _puede_eliminar_variedad_cached(self, id_variedad):
        """
        Verifica si una variedad puede ser eliminada (versión cacheada).
        ⭐ OPTIMIZADO: Evita consultar repetidamente la misma validación
        
        Args:
            id_variedad (int): ID de la variedad.
            
        Returns:
            bool: True si puede eliminarse.
        """
        try:
            total_ciclos = self._contar_ciclos_cached(id_variedad)
            return total_ciclos == 0
        except Exception:
            return False

    @cacheable('validaciones_variedades', key_func=lambda id_tipo: f"tipo_valido_{id_tipo}", ttl=1800)  # 30 min
    def _validar_tipo_cultivo_cached(self, id_tipo_cultivo):
        """
        Valida que el tipo de cultivo existe y está activo (versión cacheada).
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            dict: Información del tipo de cultivo.
            
        Raises:
            RegistroNoEncontrado: Si el tipo no existe.
        """
        try:
            return self.tipo_repo.obtener_por_id(id_tipo_cultivo)
        except RegistroNoEncontrado:
            raise ErrorValidacion("El tipo de cultivo seleccionado no existe o está inactivo")

    @cacheable('validaciones_variedades', key_func=lambda datos: f"reglas_creacion_{hash(str(sorted(datos.items())))}", ttl=3600)  # 1 hora
    def _validar_reglas_negocio_creacion_cached(self, datos):
        """
        Valida reglas de negocio específicas para creación (versión cacheada).
        
        Args:
            datos (dict): Datos a validar.
            
        Returns:
            bool: True si pasa todas las validaciones.
            
        Raises:
            ErrorValidacion: Si alguna regla falla.
        """
        # Regla: Nombres de variedades deben ser únicos por tipo
        nombre = datos.get('nombre', '').strip()
        if len(nombre) < 2:
            raise ErrorValidacion("El nombre de la variedad debe tener al menos 2 caracteres")
        
        # Regla: Rendimiento esperado debe ser realista
        rendimiento = datos.get('rendimiento_esperado')
        if rendimiento is not None:
            if rendimiento < 0:
                raise ErrorValidacion("El rendimiento esperado debe ser positivo")
            elif rendimiento > 200:  # 200 ton/ha es extremadamente alto
                raise ErrorValidacion("El rendimiento esperado parece demasiado alto (máximo 200 ton/ha)")
        
        # Regla: Tiempo de producción debe ser razonable
        tiempo_produccion = datos.get('tiempo_produccion')
        if tiempo_produccion is not None:
            if tiempo_produccion < 1:
                raise ErrorValidacion("El tiempo de producción debe ser al menos 1 día")
            elif tiempo_produccion > 1095:  # 3 años
                raise ErrorValidacion("El tiempo de producción no puede exceder 3 años")
        
        return True

    @cacheable('calculos_variedades', key_func=lambda variedades: f"stats_pagina_{len(variedades)}_{hash(str([v['id_variedad'] for v in variedades]))}", ttl=1800)  # 30 min
    def _calcular_estadisticas_pagina_cached(self, variedades):
        """
        Calcula estadísticas de la página actual (versión cacheada).
        
        Args:
            variedades (list): Lista de variedades.
            
        Returns:
            dict: Estadísticas de la página.
        """
        if not variedades:
            return {'total_en_uso': 0, 'total_con_rendimiento': 0, 'rendimiento_promedio': 0}
        
        en_uso = sum(1 for v in variedades if v.get('esta_en_uso'))
        con_rendimiento = sum(1 for v in variedades if v.get('tiene_rendimiento'))
        
        rendimientos = [v['rendimiento_esperado'] for v in variedades if v.get('rendimiento_esperado')]
        rendimiento_promedio = sum(rendimientos) / len(rendimientos) if rendimientos else 0
        
        return {
            'variedades_en_uso': en_uso,
            'variedades_con_rendimiento': con_rendimiento,
            'rendimiento_promedio_pagina': round(rendimiento_promedio, 2),
            'porcentaje_en_uso': round((en_uso / len(variedades)) * 100, 1),
            'porcentaje_con_rendimiento': round((con_rendimiento / len(variedades)) * 100, 1)
        }

    @cacheable('info_tipos_variedades', key_func=lambda id_tipo: f"info_tipo_{id_tipo}", ttl=1800)  # 30 min
    def _obtener_info_tipo_cached(self, id_tipo_cultivo):
        """
        Obtiene información básica del tipo de cultivo (versión cacheada).
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            dict: Información básica del tipo.
        """
        try:
            tipo = self.tipo_repo.obtener_por_id(id_tipo_cultivo)
            return {
                'nombre': tipo['nombre'],
                'nombre_cientifico': tipo.get('nombre_cientifico', ''),
                'tiempo_cosecha_rango': tipo.get('tiempo_cosecha_rango', 'No especificado')
            }
        except Exception:
            return {'nombre': 'Tipo desconocido', 'nombre_cientifico': '', 'tiempo_cosecha_rango': ''}

    @cacheable('resumen_variedades', key_func=lambda: 'dashboard_variedades', ttl=1800)  # 30 min
    def obtener_resumen_variedades(self):
        """
        Obtiene un resumen completo de variedades para dashboard.
        ⭐ NUEVO: Método optimizado para dashboard
        
        Returns:
            dict: Resumen completo de variedades.
        """
        try:
            # Obtener datos base (ya cacheados)
            estadisticas = self.obtener_estadisticas_variedades()
            
            # Calcular métricas adicionales
            resumen = {
                'totales': {
                    'variedades': estadisticas.get('total_variedades', 0),
                    'tipos_con_variedades': estadisticas.get('tipos_cultivo_con_variedades', 0),
                    'con_rendimiento': estadisticas.get('con_rendimiento_esperado', 0)
                },
                'rendimiento': {
                    'promedio_sistema': estadisticas.get('rendimiento_promedio', 0),
                    'top_variedades': estadisticas.get('top_variedades_rendimiento', [])[:3],  # Top 3
                    'distribucion': estadisticas.get('distribucion_rendimiento', {})
                },
                'uso': {
                    'variedades_populares': estadisticas['metricas_servicio']['variedades_populares'],
                    'sin_uso': estadisticas['metricas_servicio']['variedades_sin_uso'],
                    'diversidad': estadisticas['metricas_servicio']['diversidad_por_tipo']
                },
                'resistencia': estadisticas.get('analisis_resistencia', {}),
                'timestamp': self._get_timestamp()
            }
            
            logger.info(f"Resumen de variedades generado: {resumen['totales']['variedades']} total")
            return resumen
            
        except Exception as e:
            logger.error(f"Error generando resumen de variedades: {str(e)}")
            return {}

    # ==================== MÉTODOS AUXILIARES PRIVADOS ====================
    
    def _normalizar_datos_variedad(self, datos):
        """Normaliza y limpia los datos de la variedad."""
        datos_normalizados = datos.copy()
        
        # Limpiar espacios en strings
        for campo in ['nombre', 'resistencia_zona']:
            if campo in datos_normalizados and datos_normalizados[campo]:
                datos_normalizados[campo] = datos_normalizados[campo].strip()
        
        # Normalizar rendimiento esperado
        if 'rendimiento_esperado' in datos_normalizados and datos_normalizados['rendimiento_esperado'] is not None:
            datos_normalizados['rendimiento_esperado'] = round(float(datos_normalizados['rendimiento_esperado']), 2)
        
        # Normalizar tiempo de producción
        if 'tiempo_produccion' in datos_normalizados and datos_normalizados['tiempo_produccion'] is not None:
            datos_normalizados['tiempo_produccion'] = int(datos_normalizados['tiempo_produccion'])
        
        return datos_normalizados
    
    def _validar_cambios_criticos(self, variedad_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Validar cambio de tipo de cultivo si ya tiene ciclos
        if 'id_tipo_cultivo' in datos_nuevos and datos_nuevos['id_tipo_cultivo'] != variedad_actual['id_tipo_cultivo']:
            total_ciclos = self._contar_ciclos_cached(variedad_actual['id_variedad'])
            if total_ciclos > 0:
                raise ErrorValidacion(f"No se puede cambiar el tipo de cultivo. La variedad tiene {total_ciclos} ciclos asociados")
    
    def _verificar_cambio_tipo(self, variedad_actual, datos_nuevos):
        """Verifica si cambió el tipo de cultivo."""
        return ('id_tipo_cultivo' in datos_nuevos and 
                variedad_actual['id_tipo_cultivo'] != datos_nuevos['id_tipo_cultivo'])
    
    def _verificar_cambio_rendimiento(self, variedad_actual, datos_nuevos):
        """Verifica si cambió el rendimiento esperado."""
        return ('rendimiento_esperado' in datos_nuevos and 
                variedad_actual['rendimiento_esperado'] != datos_nuevos.get('rendimiento_esperado'))
    
    def _evaluar_impacto_en_ciclos(self, id_variedad, datos_nuevos):
        """Evalúa el impacto de los cambios en los ciclos asociados."""
        total_ciclos = self._contar_ciclos_cached(id_variedad)
        
        if total_ciclos == 0:
            return 'sin_impacto'
        elif 'rendimiento_esperado' in datos_nuevos:
            return 'impacto_planificacion'  # Puede afectar proyecciones
        elif 'tiempo_produccion' in datos_nuevos:
            return 'impacto_cronograma'  # Puede afectar tiempos
        else:
            return 'impacto_menor'
    
    def _categorizar_uso_variedad(self, total_ciclos):
        """Categoriza el uso de una variedad según sus ciclos."""
        if total_ciclos >= 15:
            return 'muy_popular'
        elif total_ciclos >= 8:
            return 'popular'
        elif total_ciclos >= 3:
            return 'moderado'
        elif total_ciclos >= 1:
            return 'poco_usado'
        else:
            return 'sin_uso'
    
    def _categorizar_nivel_rendimiento(self, rendimiento):
        """Categoriza el nivel de rendimiento de una variedad."""
        if rendimiento is None:
            return 'sin_datos'
        elif rendimiento >= 30:
            return 'excelente'
        elif rendimiento >= 20:
            return 'muy_bueno'
        elif rendimiento >= 10:
            return 'bueno'
        elif rendimiento >= 5:
            return 'aceptable'
        else:
            return 'bajo'
    
    def _evaluar_completitud_variedad(self, variedad):
        """Evalúa qué tan completos están los datos de la variedad."""
        puntos = 0
        total_puntos = 5
        
        if variedad.get('nombre'):
            puntos += 1
        if variedad.get('rendimiento_esperado'):
            puntos += 1
        if variedad.get('tiempo_produccion'):
            puntos += 1
        if variedad.get('resistencia_zona'):
            puntos += 1
        if variedad.get('nombre_tipo_cultivo'):
            puntos += 1
        
        porcentaje = (puntos / total_puntos) * 100
        
        if porcentaje >= 80:
            return 'completo'
        elif porcentaje >= 60:
            return 'bueno'
        elif porcentaje >= 40:
            return 'basico'
        else:
            return 'incompleto'
    
    def _analizar_productividad_variedad(self, variedad):
        """Analiza la productividad de una variedad."""
        rendimiento = variedad.get('rendimiento_esperado')
        tiempo = variedad.get('tiempo_produccion')
        
        if not rendimiento:
            return {
                'categoria': 'sin_datos',
                'descripcion': 'Rendimiento no especificado',
                'eficiencia': 0
            }
        
        # Calcular eficiencia (rendimiento por día)
        if tiempo and tiempo > 0:
            eficiencia = round(rendimiento / tiempo * 30, 3)  # Rendimiento por mes
        else:
            eficiencia = 0
        
        # Categorizar productividad
        if rendimiento >= 20 and eficiencia >= 5:
            categoria = 'alta_productividad'
            descripcion = 'Variedad altamente productiva'
        elif rendimiento >= 10 and eficiencia >= 2:
            categoria = 'buena_productividad'
            descripcion = 'Variedad con buena productividad'
        elif rendimiento >= 5:
            categoria = 'productividad_moderada'
            descripcion = 'Variedad con productividad moderada'
        else:
            categoria = 'baja_productividad'
            descripcion = 'Variedad de baja productividad'
        
        return {
            'categoria': categoria,
            'descripcion': descripcion,
            'eficiencia': eficiencia,
            'rendimiento_por_mes': eficiencia
        }
    
    def _generar_recomendacion_uso(self, variedad, total_ciclos):
        """Genera recomendaciones de uso para una variedad."""
        if total_ciclos == 0:
            if variedad.get('rendimiento_esperado', 0) >= 15:
                return "Variedad prometedora - considerar para próximos ciclos"
            else:
                return "Evaluar viabilidad antes de usar en producción"
        elif total_ciclos >= 10:
            return "Variedad probada y confiable para producción"
        elif total_ciclos >= 3:
            return "Variedad con experiencia positiva - expandir uso"
        else:
            return "Variedad en evaluación - monitorear resultados"
    
    def _calcular_relevancia_busqueda_variedad(self, variedad, termino_busqueda):
        """Calcula la relevancia de una variedad en una búsqueda."""
        relevancia = 0
        termino = termino_busqueda.lower()
        
        # Coincidencia exacta en nombre (mayor peso)
        if termino in variedad['nombre'].lower():
            relevancia += 10
        
        # Coincidencia en tipo de cultivo
        if variedad.get('nombre_tipo_cultivo') and termino in variedad['nombre_tipo_cultivo'].lower():
            relevancia += 8
        
        # Coincidencia en resistencia
        if variedad.get('resistencia_zona') and termino in variedad['resistencia_zona'].lower():
            relevancia += 5
        
        # Bonus por uso y rendimiento
        total_ciclos = self._contar_ciclos_cached(variedad['id_variedad'])
        relevancia += min(total_ciclos, 5)  # Máximo 5 puntos por uso
        
        if variedad.get('rendimiento_esperado', 0) >= 15:
            relevancia += 3  # Bonus por alto rendimiento
        
        return relevancia
    
    def _calcular_rendimiento_promedio_pagina(self, variedades):
        """Calcula el rendimiento promedio de las variedades en la página."""
        rendimientos = [v['rendimiento_esperado'] for v in variedades if v.get('rendimiento_esperado')]
        return round(sum(rendimientos) / len(rendimientos), 2) if rendimientos else 0
    
    def _analizar_distribucion_rendimiento(self):
        """Analiza la distribución de rendimientos en el sistema."""
        try:
            variedades = self.variedad_repo.obtener_todas()
            distribucion = {
                'bajo': 0,        # < 5 ton/ha
                'aceptable': 0,   # 5-10 ton/ha
                'bueno': 0,       # 10-20 ton/ha
                'muy_bueno': 0,   # 20-30 ton/ha
                'excelente': 0,   # >= 30 ton/ha
                'sin_datos': 0
            }
            
            for variedad in variedades:
                categoria = self._categorizar_nivel_rendimiento(variedad.get('rendimiento_esperado'))
                if categoria == 'sin_datos':
                    distribucion['sin_datos'] += 1
                elif categoria == 'bajo':
                    distribucion['bajo'] += 1
                elif categoria == 'aceptable':
                    distribucion['aceptable'] += 1
                elif categoria == 'bueno':
                    distribucion['bueno'] += 1
                elif categoria == 'muy_bueno':
                    distribucion['muy_bueno'] += 1
                elif categoria == 'excelente':
                    distribucion['excelente'] += 1
            
            return distribucion
        except Exception:
            return {'bajo': 0, 'aceptable': 0, 'bueno': 0, 'muy_bueno': 0, 'excelente': 0, 'sin_datos': 0}
    
    def _analizar_resistencia_por_zona(self):
        """Analiza la resistencia por zona de las variedades."""
        try:
            variedades = self.variedad_repo.obtener_todas()
            zonas = {}
            sin_resistencia = 0
            
            for variedad in variedades:
                resistencia = variedad.get('resistencia_zona', '').strip()
                if resistencia:
                    if resistencia not in zonas:
                        zonas[resistencia] = 0
                    zonas[resistencia] += 1
                else:
                    sin_resistencia += 1
            
            return {
                'zonas_cubiertas': list(zonas.keys()),
                'distribucion_zonas': zonas,
                'total_zonas': len(zonas),
                'variedades_sin_resistencia': sin_resistencia
            }
        except Exception:
            return {'zonas_cubiertas': [], 'distribucion_zonas': {}, 'total_zonas': 0, 'variedades_sin_resistencia': 0}
    
    def _contar_variedades_sin_uso(self):
        """Cuenta variedades que no han sido usadas en ciclos."""
        try:
            variedades = self.variedad_repo.obtener_todas()
            return sum(1 for variedad in variedades if self._contar_ciclos_cached(variedad['id_variedad']) == 0)
        except Exception:
            return 0
    
    def _calcular_diversidad_por_tipo(self):
        """Calcula el promedio de variedades por tipo de cultivo."""
        try:
            estadisticas = self.variedad_repo.obtener_estadisticas()
            total_variedades = estadisticas.get('total_variedades', 0)
            tipos_con_variedades = estadisticas.get('tipos_cultivo_con_variedades', 1)
            return round(total_variedades / tipos_con_variedades, 1) if tipos_con_variedades > 0 else 0
        except Exception:
            return 0
    
    def _evaluar_cobertura_resistencia(self):
        """Evalúa qué tan bien cubiertas están las zonas de resistencia."""
        try:
            analisis = self._analizar_resistencia_por_zona()
            total_zonas = analisis['total_zonas']
            
            if total_zonas >= 5:
                return 'excelente'
            elif total_zonas >= 3:
                return 'buena'
            elif total_zonas >= 1:
                return 'basica'
            else:
                return 'sin_cobertura'
        except Exception:
            return 'sin_datos'
    
    def _calcular_eficiencia_estimada(self, variedad):
        """Calcula la eficiencia estimada de una variedad."""
        rendimiento = variedad.get('rendimiento_esperado', 0)
        tiempo = variedad.get('tiempo_produccion', 180)  # Default 6 meses
        
        if tiempo > 0:
            return round((rendimiento / tiempo) * 30, 3)  # Rendimiento por mes
        else:
            return 0
    
    def _generar_recomendacion_cultivo(self, variedad):
        """Genera recomendaciones específicas para cultivar una variedad."""
        rendimiento = variedad.get('rendimiento_esperado', 0)
        tiempo = variedad.get('tiempo_produccion')
        resistencia = variedad.get('resistencia_zona', '')
        
        recomendaciones = []
        
        if rendimiento >= 20:
            recomendaciones.append("Alta productividad - ideal para maximizar ingresos")
        
        if tiempo and tiempo <= 90:
            recomendaciones.append("Ciclo rápido - permite múltiples cosechas anuales")
        
        if resistencia:
            recomendaciones.append(f"Resistente en zona: {resistencia}")
        
        if not recomendaciones:
            recomendaciones.append("Evaluar condiciones específicas antes del cultivo")
        
        return "; ".join(recomendaciones)
    
    def _generar_recomendaciones_variedad(self, variedad, total_ciclos):
        """Genera recomendaciones específicas para una variedad."""
        recomendaciones = []
        
        if total_ciclos == 0:
            if variedad.get('rendimiento_esperado', 0) >= 15:
                recomendaciones.append("Variedad prometedora - iniciar ciclo de prueba")
            else:
                recomendaciones.append("Completar datos de rendimiento antes de usar")
        
        if not variedad.get('resistencia_zona'):
            recomendaciones.append("Especificar resistencia por zona")
        
        if not variedad.get('tiempo_produccion'):
            recomendaciones.append("Agregar tiempo de producción para planificación")
        
        if variedad.get('rendimiento_esperado', 0) < 5:
            recomendaciones.append("Evaluar viabilidad económica del rendimiento")
        
        return recomendaciones
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()