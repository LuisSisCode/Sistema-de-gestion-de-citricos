# bd_conecciones/servicios/tipo_cultivo_servicio.py

import logging
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

class TipoCultivoServicio:
    """Servicio para lógica de negocio de tipos de cultivo con caché optimizado."""
    
    def __init__(self):
        self.tipo_repo = TipoCultivoRepositorio()
        self.relacion_repo = RelacionCultivoRepositorio()
    
    @cacheable('cultivos', ttl=get_ttl('cultivos'))
    def obtener_tipos_cultivo(self):
        """
        Obtiene todos los tipos de cultivo de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada tipo de cultivo.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_tipo_cultivo, nombre, nombre_cientifico, descripcion, 
                       tiempo_cosecha_min, tiempo_cosecha_max, activo
                FROM TiposCultivo
                ORDER BY nombre
                """
                
                cursor.execute(query)
                tipos_cultivo = []
                
                for row in cursor.fetchall():
                    tipo = {
                        'id_tipo_cultivo': row.id_tipo_cultivo,
                        'nombre': row.nombre,
                        'nombre_cientifico': row.nombre_cientifico,
                        'descripcion': row.descripcion,
                        'tiempo_cosecha_min': row.tiempo_cosecha_min,
                        'tiempo_cosecha_max': row.tiempo_cosecha_max,
                        'activo': bool(row.activo)
                    }
                    tipos_cultivo.append(tipo)
                
                logger.info(f"Se obtuvieron {len(tipos_cultivo)} tipos de cultivo de la base de datos.")
                return tipos_cultivo
        except Exception as e:
            logger.error(f"Error al obtener tipos de cultivo: {str(e)}")
            return []
    
    @cacheable('servicio_tipos_cultivo', key_func=lambda pagina, por_pagina=8: f"paginado_{pagina}_{por_pagina}", ttl=900)  # 15 min
    def obtener_tipos_cultivo_paginado(self, pagina, por_pagina=8):
        """
        Obtiene tipos de cultivo con paginación y lógica de negocio aplicada.
        ⭐ MUY OPTIMIZADO: Resultado enriquecido completo cacheado para evitar N+1 queries
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Resultado con tipos de cultivo y metadatos.
        """
        try:
            resultado = self.tipo_repo.obtener_paginado(pagina, por_pagina)
            
            # Enriquecer datos con información adicional (OPTIMIZADO: resultado completo cacheado)
            tipos_enriquecidos = []
            for tipo in resultado['tipos_cultivo']:
                tipo_enriquecido = tipo.copy()
                
                # Obtener datos adicionales (estos métodos ya están cacheados en repositorios)
                tipo_enriquecido['total_variedades'] = self._contar_variedades_cached(tipo['id_tipo_cultivo'])
                tipo_enriquecido['total_ciclos'] = self._contar_ciclos_cached(tipo['id_tipo_cultivo'])
                tipo_enriquecido['puede_eliminar'] = self._puede_eliminar_tipo_cached(tipo['id_tipo_cultivo'])
                
                # Agregar metadatos de negocio
                tipo_enriquecido['esta_en_uso'] = tipo_enriquecido['total_ciclos'] > 0
                tipo_enriquecido['popularidad'] = self._categorizar_popularidad(
                    tipo_enriquecido['total_variedades'], 
                    tipo_enriquecido['total_ciclos']
                )
                tipo_enriquecido['completitud_datos'] = self._evaluar_completitud_datos(tipo)
                
                # Información de tiempo de cosecha más detallada
                tipo_enriquecido['info_tiempo_cosecha'] = self._enriquecer_tiempo_cosecha(tipo)
                
                tipos_enriquecidos.append(tipo_enriquecido)
            
            # Actualizar resultado con datos enriquecidos
            resultado['tipos_cultivo'] = tipos_enriquecidos
            resultado['estadisticas_pagina'] = self._calcular_estadisticas_pagina_cached(tipos_enriquecidos)
            resultado['metadatos_servicio'] = {
                'timestamp': self._get_timestamp(),
                'total_con_variedades': sum(1 for t in tipos_enriquecidos if t['total_variedades'] > 0),
                'total_en_uso': sum(1 for t in tipos_enriquecidos if t['esta_en_uso']),
                'promedio_variedades': sum(t['total_variedades'] for t in tipos_enriquecidos) / len(tipos_enriquecidos) if tipos_enriquecidos else 0
            }
            
            logger.info(f"Servicio: página {pagina} procesada con {len(resultado['tipos_cultivo'])} tipos de cultivo")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_tipos_cultivo_paginado: {str(e)}")
            raise
    @cacheable('estadisticas_cultivos', ttl=600)  # 10 minutos
    def obtener_estadisticas_cultivos(self):
        """
        Obtiene estadísticas generales de cultivos y producción.
        
        Returns:
            dict: Diccionario con diversas estadísticas de cultivos.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Total de tipos de cultivo activos
                cursor.execute("SELECT COUNT(*) FROM TiposCultivo WHERE activo = 1")
                total_tipos = cursor.fetchone()[0]
                
                # Total de variedades activas
                cursor.execute("SELECT COUNT(*) FROM VariedadesCultivo WHERE activo = 1")
                total_variedades = cursor.fetchone()[0]
                
                # Ciclos activos por estado
                cursor.execute("""
                    SELECT estado, COUNT(*) as total
                    FROM CiclosProduccion
                    WHERE activo = 1
                    GROUP BY estado
                    ORDER BY COUNT(*) DESC
                """)
                
                ciclos_por_estado = {}
                for row in cursor.fetchall():
                    ciclos_por_estado[row[0]] = row[1]
                
                # Área total sembrada actualmente
                cursor.execute("""
                    SELECT SUM(area_sembrada) 
                    FROM CiclosProduccion 
                    WHERE activo = 1 AND estado NOT IN ('Finalizado', 'Cancelado')
                """)
                area_sembrada = cursor.fetchone()[0]
                area_sembrada = float(area_sembrada) if area_sembrada else 0
                
                # Tipos de cultivo más utilizados
                cursor.execute("""
                    SELECT t.nombre, COUNT(c.id_ciclo) as total_ciclos
                    FROM TiposCultivo t
                    JOIN VariedadesCultivo v ON t.id_tipo_cultivo = v.id_tipo_cultivo
                    JOIN CiclosProduccion c ON v.id_variedad = c.id_variedad
                    WHERE c.activo = 1
                    GROUP BY t.nombre
                    ORDER BY total_ciclos DESC
                """)
                
                cultivos_populares = {}
                for row in cursor.fetchall():
                    cultivos_populares[row[0]] = row[1]
                
                estadisticas = {
                    'total_tipos_cultivo': total_tipos,
                    'total_variedades': total_variedades,
                    'ciclos_por_estado': ciclos_por_estado,
                    'area_sembrada_activa': area_sembrada,
                    'cultivos_populares': cultivos_populares
                }
                
                logger.info("Estadísticas de cultivos generadas correctamente")
                return estadisticas
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de cultivos: {str(e)}")
            return {}

    @cache_invalidator('servicio_tipos_cultivo', pattern='paginado_')     # Invalidar paginación
    @cache_invalidator('servicio_tipos_cultivo', pattern='busqueda_')    # Invalidar búsquedas
    @cache_invalidator('validaciones_tipos')                             # Invalidar validaciones
    @cache_invalidator('estadisticas_tipos_servicio')                    # Invalidar estadísticas
    def crear_tipo_cultivo(self, datos_tipo):
        """
        Crea un nuevo tipo de cultivo con validaciones de negocio.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_tipo (dict): Datos del tipo de cultivo.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio adicionales
            self._validar_reglas_negocio_creacion_cached(datos_tipo)
            
            # Normalizar y enriquecer datos
            datos_normalizados = self._normalizar_datos_tipo_cultivo(datos_tipo)
            
            # Crear tipo de cultivo
            exito, id_tipo_cultivo = self.tipo_repo.crear(datos_normalizados)
            
            if exito:
                # Obtener información del tipo creado
                tipo_creado = self.tipo_repo.obtener_por_id(id_tipo_cultivo)
                
                resultado = {
                    'exito': True,
                    'id_tipo_cultivo': id_tipo_cultivo,
                    'mensaje': f"Tipo de cultivo '{datos_normalizados['nombre']}' creado exitosamente",
                    'tipo_cultivo': tipo_creado,
                    'tiene_tiempo_cosecha': bool(datos_normalizados.get('tiempo_cosecha_min')),
                    'requiere_actualizacion_listas': True,
                    'categoria_nueva': self._categorizar_tipo_por_tiempo(datos_normalizados)
                }
                
                logger.info(f"Servicio: tipo de cultivo creado con ID {id_tipo_cultivo}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear tipo de cultivo'}
                
        except (ErrorValidacion, RegistroYaExiste) as e:
            logger.error(f"Error de validación en crear_tipo_cultivo: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_tipo_cultivo: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_tipos_cultivo', pattern='paginado_')     # Invalidar paginación
    @cache_invalidator('servicio_tipos_cultivo', pattern='busqueda_')    # Invalidar búsquedas
    @cache_invalidator('validaciones_tipos')                             # Invalidar validaciones
    @cache_invalidator('estadisticas_tipos_servicio')                    # Invalidar estadísticas
    def actualizar_tipo_cultivo(self, id_tipo_cultivo, datos_tipo):
        """
        Actualiza un tipo de cultivo con validaciones de negocio.
        OPTIMIZADO: Invalidación específica del tipo actualizado.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            datos_tipo (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales para comparación
            tipo_actual = self.tipo_repo.obtener_por_id(id_tipo_cultivo)
            
            # Validar cambios críticos
            self._validar_cambios_criticos(tipo_actual, datos_tipo)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_tipo_cultivo(datos_tipo)
            
            # Actualizar tipo de cultivo
            exito = self.tipo_repo.actualizar(id_tipo_cultivo, datos_normalizados)
            
            if exito:
                # Verificar cambios importantes
                cambio_tiempo_cosecha = self._verificar_cambio_tiempo_cosecha(tipo_actual, datos_normalizados)
                cambio_nombre = 'nombre' in datos_normalizados and tipo_actual['nombre'] != datos_normalizados['nombre']
                
                resultado = {
                    'exito': True,
                    'mensaje': f"Tipo de cultivo '{tipo_actual['nombre']}' actualizado exitosamente",
                    'cambio_tiempo_cosecha': cambio_tiempo_cosecha,
                    'cambio_nombre': cambio_nombre,
                    'requiere_actualizacion_listas': True,
                    'impacto_variedades': self._evaluar_impacto_en_variedades(id_tipo_cultivo, datos_normalizados)
                }
                
                logger.info(f"Servicio: tipo de cultivo {id_tipo_cultivo} actualizado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar tipo de cultivo'}
                
        except (ErrorValidacion, RegistroNoEncontrado, RegistroYaExiste) as e:
            logger.error(f"Error en actualizar_tipo_cultivo: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_tipo_cultivo: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_tipos_cultivo', pattern='paginado_')     # Invalidar paginación
    @cache_invalidator('servicio_tipos_cultivo', pattern='busqueda_')    # Invalidar búsquedas
    @cache_invalidator('validaciones_tipos')                             # Invalidar validaciones
    @cache_invalidator('estadisticas_tipos_servicio')                    # Invalidar estadísticas
    def eliminar_tipo_cultivo(self, id_tipo_cultivo):
        """
        Elimina un tipo de cultivo verificando dependencias y reglas de negocio.
        OPTIMIZADO: Invalidación completa ya que afecta listas y estadísticas.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            dict: Resultado detallado de la operación.
        """
        try:
            # Obtener información del tipo de cultivo
            tipo = self.tipo_repo.obtener_por_id(id_tipo_cultivo)
            
            # Verificar dependencias usando RelacionCultivoRepositorio (ya cacheado)
            dependencias = self.relacion_repo.verificar_dependencias_tipo_cultivo(id_tipo_cultivo)
            
            # Si tiene dependencias, no se puede eliminar
            if not dependencias['puede_eliminar']:
                return {
                    'exito': False,
                    'mensaje': f"No se puede eliminar '{tipo['nombre']}'",
                    'razon': 'Tiene variedades y/o ciclos asociados',
                    'dependencias': dependencias,
                    'tipo_error': 'dependencias'
                }
            
            # Proceder con eliminación
            exito = self.tipo_repo.desactivar(id_tipo_cultivo)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Tipo de cultivo '{tipo['nombre']}' eliminado exitosamente",
                    'nombre_eliminado': tipo['nombre'],
                    'tenia_tiempo_cosecha': tipo['tiene_tiempo_cosecha'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: tipo de cultivo {id_tipo_cultivo} eliminado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al eliminar tipo de cultivo'}
                
        except RegistroTieneDependencias as e:
            logger.error(f"No se puede eliminar tipo de cultivo: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'razon': 'Tiene dependencias',
                'dependencias': {'total': e.cantidad_dependencias},
                'tipo_error': 'dependencias'
            }
        except RegistroNoEncontrado as e:
            logger.error(f"Tipo de cultivo no encontrado: {str(e)}")
            return {'exito': False, 'mensaje': str(e), 'tipo_error': 'no_encontrado'}
        except Exception as e:
            logger.error(f"Error en servicio eliminar_tipo_cultivo: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema', 'tipo_error': 'interno'}
        
    @cache_invalidator('cultivos')
    @cache_invalidator('variedades')
    def desactivar_tipo_cultivo(self, id_tipo_cultivo):
        """
        Desactiva un tipo de cultivo en lugar de eliminarlo físicamente.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo a desactivar.
            
        Returns:
            bool: True si se desactivó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "UPDATE TiposCultivo SET activo = 0 WHERE id_tipo_cultivo = ?"
                cursor.execute(query, (id_tipo_cultivo,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Tipo de cultivo desactivado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al desactivar tipo de cultivo: {str(e)}")
            return False

    @cacheable('servicio_tipos_cultivo', key_func=lambda texto: f"busqueda_{texto.lower().replace(' ', '_')}", ttl=600)  # 10 min
    def buscar_tipos_cultivo(self, texto_busqueda):
        """
        Busca tipos de cultivo con lógica de negocio aplicada.
        ⭐ OPTIMIZADO: Resultado enriquecido completo cacheado para evitar N+1 queries
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de tipos encontrados con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return []
            
            tipos = self.tipo_repo.buscar_por_nombre(texto_busqueda.strip())
            
            # Enriquecer resultados (OPTIMIZADO: resultado completo cacheado)
            tipos_enriquecidos = []
            for tipo in tipos:
                tipo_enriquecido = tipo.copy()
                
                # Agregar información adicional (métodos ya cacheados en repositorios)
                tipo_enriquecido['total_variedades'] = self._contar_variedades_cached(tipo['id_tipo_cultivo'])
                tipo_enriquecido['total_ciclos'] = self._contar_ciclos_cached(tipo['id_tipo_cultivo'])
                tipo_enriquecido['puede_eliminar'] = self._puede_eliminar_tipo_cached(tipo['id_tipo_cultivo'])
                
                # Metadatos de negocio
                tipo_enriquecido['esta_en_uso'] = tipo_enriquecido['total_ciclos'] > 0
                tipo_enriquecido['popularidad'] = self._categorizar_popularidad(
                    tipo_enriquecido['total_variedades'], 
                    tipo_enriquecido['total_ciclos']
                )
                tipo_enriquecido['relevancia_busqueda'] = self._calcular_relevancia_busqueda(tipo, texto_busqueda)
                
                tipos_enriquecidos.append(tipo_enriquecido)
            
            # Ordenar por relevancia
            tipos_enriquecidos.sort(key=lambda x: x['relevancia_busqueda'], reverse=True)
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(tipos_enriquecidos)} tipos")
            return tipos_enriquecidos
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_tipos_cultivo: {str(e)}")
            return []

    @cacheable('servicio_tipos_cultivo', key_func=lambda: 'lista_completa_activos', ttl=1800)  # 30 min
    def obtener_tipos_cultivo_activos(self):
        """
        Obtiene la lista completa de tipos de cultivo activos.
        ⭐ OPTIMIZADO: Cacheado a nivel de servicio para formularios y selects
        
        Returns:
            list: Lista de tipos activos con información básica.
        """
        try:
            tipos = self.tipo_repo.obtener_todos()
            
            # Enriquecer con información mínima para formularios
            for tipo in tipos:
                tipo['valor'] = tipo['id_tipo_cultivo']  # Para compatibilidad con selects
                tipo['texto'] = tipo['nombre']           # Para visualización
                tipo['tiene_variedades'] = self._contar_variedades_cached(tipo['id_tipo_cultivo']) > 0
            
            return tipos
        except Exception as e:
            logger.error(f"Error en servicio obtener_tipos_cultivo_activos: {str(e)}")
            return []

    @cacheable('servicio_tipos_tiempo', key_func=lambda tiempo_min, tiempo_max: f"filtro_{tiempo_min}_{tiempo_max}", ttl=1200)  # 20 min
    def obtener_tipos_por_tiempo_cosecha(self, tiempo_min=None, tiempo_max=None):
        """
        Obtiene tipos de cultivo filtrados por tiempo de cosecha con información enriquecida.
        
        Args:
            tiempo_min (int, optional): Tiempo mínimo de cosecha en días.
            tiempo_max (int, optional): Tiempo máximo de cosecha en días.
            
        Returns:
            list: Lista de tipos que coinciden con el criterio.
        """
        try:
            tipos = self.tipo_repo.obtener_por_tiempo_cosecha(tiempo_min, tiempo_max)
            
            # Enriquecer con información adicional
            for tipo in tipos:
                tipo['categoria_tiempo'] = self._categorizar_tipo_por_tiempo(tipo)
                tipo['apto_para_rotacion'] = self._evaluar_aptitud_rotacion(tipo)
                tipo['total_variedades'] = self._contar_variedades_cached(tipo['id_tipo_cultivo'])
            
            logger.info(f"Filtro por tiempo de cosecha: {len(tipos)} tipos encontrados")
            return tipos
            
        except Exception as e:
            logger.error(f"Error en obtener_tipos_por_tiempo_cosecha: {str(e)}")
            return []

    @cacheable('estadisticas_tipos_servicio', key_func=lambda: 'completas_servicio', ttl=1800)  # 30 min
    def obtener_estadisticas_tipos_cultivo(self):
        """
        Obtiene estadísticas completas de tipos de cultivo a nivel de servicio.
        ⭐ MUY OPTIMIZADO: Múltiples consultas a repositorios ahora cacheadas como conjunto
        
        Returns:
            dict: Estadísticas detalladas con métricas de negocio.
        """
        try:
            # Estos métodos ya están cacheados en repositorios, pero el resultado final también se cachea
            estadisticas_basicas = self.tipo_repo.obtener_estadisticas()
            top_tipos = self.relacion_repo.obtener_tipos_cultivo_mas_utilizados(5)
            
            # Estadísticas enriquecidas de servicio
            estadisticas = {
                **estadisticas_basicas,
                'top_tipos_utilizados': top_tipos,
                'distribucion_tiempo_cosecha': self._analizar_distribucion_tiempo_cosecha(),
                
                # Nuevas métricas de servicio
                'metricas_servicio': {
                    'tipos_sin_variedades': self._contar_tipos_sin_variedades(),
                    'tipos_muy_populares': len([t for t in top_tipos if t['total_ciclos'] >= 10]),
                    'tiempo_cosecha_promedio_sistema': self._calcular_tiempo_promedio_sistema(),
                    'diversidad_cultivos': self._evaluar_diversidad_cultivos(estadisticas_basicas),
                    'timestamp': self._get_timestamp()
                }
            }
            
            logger.info(f"Estadísticas completas de tipos de cultivo calculadas: {estadisticas_basicas.get('total_tipos', 0)} tipos")
            return estadisticas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_tipos_cultivo: {str(e)}")
            return {}

    @cacheable('estados_tipos', key_func=lambda id_tipo: f"estado_completo_{id_tipo}", ttl=1200)  # 20 min
    def verificar_estado_tipo_cultivo(self, id_tipo_cultivo):
        """
        Verifica el estado completo de un tipo de cultivo.
        ⭐ OPTIMIZADO: Estado completo cacheado para evitar múltiples consultas
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            dict: Estado completo del tipo de cultivo.
        """
        try:
            # Estos métodos ya están cacheados en repositorios
            tipo = self.tipo_repo.obtener_por_id(id_tipo_cultivo)
            total_variedades = self._contar_variedades_cached(id_tipo_cultivo)
            total_ciclos = self._contar_ciclos_cached(id_tipo_cultivo)
            
            estado = {
                'tipo_cultivo': tipo,
                'total_variedades': total_variedades,
                'total_ciclos': total_ciclos,
                'puede_eliminar': total_variedades == 0 and total_ciclos == 0,
                'esta_en_uso': total_ciclos > 0,
                'tiene_variedades': total_variedades > 0,
                'timestamp_verificacion': self._get_timestamp(),
                
                # Información adicional de negocio
                'popularidad': self._categorizar_popularidad(total_variedades, total_ciclos),
                'categoria_tiempo': self._categorizar_tipo_por_tiempo(tipo),
                'completitud_datos': self._evaluar_completitud_datos(tipo),
                'recomendaciones': self._generar_recomendaciones_tipo(tipo, total_variedades, total_ciclos)
            }
            
            return estado
            
        except RegistroNoEncontrado as e:
            logger.error(f"Tipo de cultivo no encontrado: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Error en servicio verificar_estado_tipo_cultivo: {str(e)}")
            return None

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('conteos_tipos', key_func=lambda id_tipo: f"variedades_{id_tipo}", ttl=1200)  # 20 min
    def _contar_variedades_cached(self, id_tipo_cultivo):
        """
        Cuenta variedades de un tipo de cultivo (versión cacheada).
        ⭐ OPTIMIZADO: Evita consultar repetidamente el mismo conteo
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            int: Número de variedades activas.
        """
        try:
            return self.relacion_repo._contar_variedades_por_tipo(id_tipo_cultivo)
        except Exception:
            return 0

    @cacheable('conteos_tipos', key_func=lambda id_tipo: f"ciclos_{id_tipo}", ttl=900)  # 15 min
    def _contar_ciclos_cached(self, id_tipo_cultivo):
        """
        Cuenta ciclos de producción de un tipo de cultivo (versión cacheada).
        ⭐ OPTIMIZADO: Evita consultar repetidamente el mismo conteo
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            int: Número de ciclos activos.
        """
        try:
            return self.relacion_repo._contar_ciclos_por_tipo(id_tipo_cultivo)
        except Exception:
            return 0

    @cacheable('validaciones_tipos', key_func=lambda id_tipo: f"puede_eliminar_{id_tipo}", ttl=900)  # 15 min
    def _puede_eliminar_tipo_cached(self, id_tipo_cultivo):
        """
        Verifica si un tipo de cultivo puede ser eliminado (versión cacheada).
        ⭐ OPTIMIZADO: Evita consultar repetidamente la misma validación
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            bool: True si puede eliminarse.
        """
        try:
            variedades = self._contar_variedades_cached(id_tipo_cultivo)
            ciclos = self._contar_ciclos_cached(id_tipo_cultivo)
            return variedades == 0 and ciclos == 0
        except Exception:
            return False

    @cacheable('validaciones_tipos', key_func=lambda datos: f"reglas_negocio_{hash(str(sorted(datos.items())))}", ttl=3600)  # 1 hora
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
        # Regla: Nombres de tipos de cultivo deben ser únicos y descriptivos
        nombre = datos.get('nombre', '').strip()
        if len(nombre) < 3:
            raise ErrorValidacion("El nombre del tipo de cultivo debe tener al menos 3 caracteres")
        
        # Regla: Si se especifica tiempo de cosecha, debe ser realista
        tiempo_min = datos.get('tiempo_cosecha_min')
        tiempo_max = datos.get('tiempo_cosecha_max')
        
        if tiempo_min is not None and tiempo_min < 7:
            raise ErrorValidacion("El tiempo mínimo de cosecha debe ser al menos 7 días")
            
        if tiempo_max is not None and tiempo_max > 1095:  # 3 años
            raise ErrorValidacion("El tiempo máximo de cosecha no puede exceder 3 años (1095 días)")
        
        return True

    @cacheable('calculos_tipos', key_func=lambda tipos: f"stats_pagina_{len(tipos)}_{hash(str([t['id_tipo_cultivo'] for t in tipos]))}", ttl=1800)  # 30 min
    def _calcular_estadisticas_pagina_cached(self, tipos):
        """
        Calcula estadísticas de la página actual (versión cacheada).
        
        Args:
            tipos (list): Lista de tipos de cultivo.
            
        Returns:
            dict: Estadísticas de la página.
        """
        if not tipos:
            return {'total_con_tiempo': 0, 'total_en_uso': 0, 'popularidad_promedio': 0}
        
        con_tiempo = sum(1 for t in tipos if t.get('tiene_tiempo_cosecha'))
        en_uso = sum(1 for t in tipos if t.get('esta_en_uso'))
        total_variedades = sum(t.get('total_variedades', 0) for t in tipos)
        
        return {
            'tipos_con_tiempo_cosecha': con_tiempo,
            'tipos_en_uso': en_uso,
            'total_variedades_pagina': total_variedades,
            'promedio_variedades_por_tipo': round(total_variedades / len(tipos), 1),
            'porcentaje_con_tiempo': round((con_tiempo / len(tipos)) * 100, 1),
            'porcentaje_en_uso': round((en_uso / len(tipos)) * 100, 1)
        }

    @cacheable('resumen_tipos', key_func=lambda: 'dashboard_tipos', ttl=1800)  # 30 min
    def obtener_resumen_tipos_cultivo(self):
        """
        Obtiene un resumen completo de tipos de cultivo para dashboard.
        ⭐ NUEVO: Método optimizado para dashboard
        
        Returns:
            dict: Resumen completo de tipos de cultivo.
        """
        try:
            # Obtener datos base (ya cacheados)
            estadisticas = self.obtener_estadisticas_tipos_cultivo()
            
            # Calcular métricas adicionales
            resumen = {
                'totales': {
                    'tipos_cultivo': estadisticas.get('total_tipos', 0),
                    'con_tiempo_cosecha': estadisticas.get('con_tiempo_cosecha', 0),
                    'tiempo_promedio': estadisticas.get('tiempo_promedio_cosecha', 0)
                },
                'uso': {
                    'tipos_con_variedades': estadisticas['metricas_servicio']['tipos_sin_variedades'],
                    'tipos_populares': estadisticas['metricas_servicio']['tipos_muy_populares'],
                    'diversidad': estadisticas['metricas_servicio']['diversidad_cultivos']
                },
                'top_tipos': estadisticas.get('top_tipos_utilizados', [])[:3],  # Top 3
                'distribucion': estadisticas.get('distribucion_tiempo_cosecha', {}),
                'timestamp': self._get_timestamp()
            }
            
            logger.info(f"Resumen de tipos de cultivo generado: {resumen['totales']['tipos_cultivo']} total")
            return resumen
            
        except Exception as e:
            logger.error(f"Error generando resumen de tipos de cultivo: {str(e)}")
            return {}

    # ==================== MÉTODOS AUXILIARES PRIVADOS ====================
    
    def _normalizar_datos_tipo_cultivo(self, datos):
        """Normaliza y limpia los datos del tipo de cultivo."""
        datos_normalizados = datos.copy()
        
        # Limpiar espacios en strings
        for campo in ['nombre', 'nombre_cientifico', 'descripcion']:
            if campo in datos_normalizados and datos_normalizados[campo]:
                datos_normalizados[campo] = datos_normalizados[campo].strip()
        
        # Normalizar nombre científico
        if datos_normalizados.get('nombre_cientifico'):
            # Capitalizar correctamente (Primera letra mayúscula, resto minúscula)
            datos_normalizados['nombre_cientifico'] = datos_normalizados['nombre_cientifico'].title()
        
        # Validar y normalizar tiempos
        for campo in ['tiempo_cosecha_min', 'tiempo_cosecha_max']:
            if campo in datos_normalizados and datos_normalizados[campo] is not None:
                datos_normalizados[campo] = int(datos_normalizados[campo])
        
        return datos_normalizados
    
    def _validar_cambios_criticos(self, tipo_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Validar cambios en tiempos de cosecha si ya tiene variedades
        if ('tiempo_cosecha_min' in datos_nuevos or 'tiempo_cosecha_max' in datos_nuevos):
            total_variedades = self._contar_variedades_cached(tipo_actual['id_tipo_cultivo'])
            if total_variedades > 0:
                logger.warning(f"Cambiando tiempos de cosecha en tipo con {total_variedades} variedades")
    
    def _verificar_cambio_tiempo_cosecha(self, tipo_actual, datos_nuevos):
        """Verifica si cambiaron los tiempos de cosecha."""
        return ('tiempo_cosecha_min' in datos_nuevos and 
                tipo_actual['tiempo_cosecha_min'] != datos_nuevos.get('tiempo_cosecha_min')) or \
               ('tiempo_cosecha_max' in datos_nuevos and 
                tipo_actual['tiempo_cosecha_max'] != datos_nuevos.get('tiempo_cosecha_max'))
    
    def _evaluar_impacto_en_variedades(self, id_tipo_cultivo, datos_nuevos):
        """Evalúa el impacto de los cambios en las variedades asociadas."""
        total_variedades = self._contar_variedades_cached(id_tipo_cultivo)
        
        if total_variedades == 0:
            return 'sin_impacto'
        elif 'nombre' in datos_nuevos:
            return 'cambio_menor'  # Solo cambio visual
        elif 'tiempo_cosecha_min' in datos_nuevos or 'tiempo_cosecha_max' in datos_nuevos:
            return 'cambio_significativo'  # Puede afectar planificación
        else:
            return 'cambio_menor'
    
    def _categorizar_popularidad(self, total_variedades, total_ciclos):
        """Categoriza la popularidad de un tipo de cultivo."""
        if total_ciclos >= 20:
            return 'muy_popular'
        elif total_ciclos >= 10:
            return 'popular'
        elif total_ciclos >= 3:
            return 'moderado'
        elif total_variedades > 0:
            return 'con_potencial'
        else:
            return 'sin_uso'
    
    def _evaluar_completitud_datos(self, tipo):
        """Evalúa qué tan completos están los datos del tipo."""
        puntos = 0
        total_puntos = 5
        
        if tipo.get('nombre'):
            puntos += 1
        if tipo.get('nombre_cientifico'):
            puntos += 1
        if tipo.get('descripcion'):
            puntos += 1
        if tipo.get('tiempo_cosecha_min'):
            puntos += 1
        if tipo.get('tiempo_cosecha_max'):
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
    
    def _enriquecer_tiempo_cosecha(self, tipo):
        """Enriquece la información de tiempo de cosecha."""
        tiempo_min = tipo.get('tiempo_cosecha_min')
        tiempo_max = tipo.get('tiempo_cosecha_max')
        
        if not tiempo_min and not tiempo_max:
            return {
                'categoria': 'sin_datos',
                'descripcion': 'Tiempo de cosecha no especificado',
                'recomendacion': 'Agregar información de tiempo de cosecha'
            }
        
        # Categorizar por duración
        tiempo_promedio = tipo.get('tiempo_promedio')
        if tiempo_promedio:
            if tiempo_promedio <= 60:
                categoria = 'rapido'
                descripcion = 'Cultivo de ciclo rápido'
            elif tiempo_promedio <= 180:
                categoria = 'medio'
                descripcion = 'Cultivo de ciclo medio'
            else:
                categoria = 'largo'
                descripcion = 'Cultivo de ciclo largo'
        else:
            categoria = 'variable'
            descripcion = 'Tiempo de cosecha variable'
        
        return {
            'categoria': categoria,
            'descripcion': descripcion,
            'recomendacion': self._generar_recomendacion_tiempo(categoria)
        }
    
    def _categorizar_tipo_por_tiempo(self, tipo):
        """Categoriza un tipo de cultivo por su tiempo de cosecha."""
        tiempo_promedio = tipo.get('tiempo_promedio')
        if not tiempo_promedio:
            return 'sin_clasificar'
        
        if tiempo_promedio <= 60:
            return 'ciclo_corto'
        elif tiempo_promedio <= 180:
            return 'ciclo_medio'
        else:
            return 'ciclo_largo'
    
    def _evaluar_aptitud_rotacion(self, tipo):
        """Evalúa si un tipo es apto para rotación de cultivos."""
        tiempo_promedio = tipo.get('tiempo_promedio')
        if not tiempo_promedio:
            return 'indeterminado'
        
        # Cultivos de ciclo corto son mejores para rotación
        if tiempo_promedio <= 90:
            return 'excelente'
        elif tiempo_promedio <= 180:
            return 'bueno'
        else:
            return 'limitado'
    
    def _calcular_relevancia_busqueda(self, tipo, termino_busqueda):
        """Calcula la relevancia de un tipo en una búsqueda."""
        relevancia = 0
        termino = termino_busqueda.lower()
        
        # Coincidencia exacta en nombre (mayor peso)
        if termino in tipo['nombre'].lower():
            relevancia += 10
        
        # Coincidencia en nombre científico
        if tipo.get('nombre_cientifico') and termino in tipo['nombre_cientifico'].lower():
            relevancia += 8
        
        # Coincidencia en descripción
        if tipo.get('descripcion') and termino in tipo['descripcion'].lower():
            relevancia += 5
        
        # Bonus por popularidad
        total_variedades = self._contar_variedades_cached(tipo['id_tipo_cultivo'])
        relevancia += min(total_variedades, 5)  # Máximo 5 puntos extra
        
        return relevancia
    
    def _analizar_distribucion_tiempo_cosecha(self):
        """Analiza la distribución de tiempos de cosecha."""
        try:
            tipos = self.tipo_repo.obtener_todos()
            distribucion = {
                'ciclo_corto': 0,    # <= 60 días
                'ciclo_medio': 0,    # 61-180 días
                'ciclo_largo': 0,    # > 180 días
                'sin_datos': 0
            }
            
            for tipo in tipos:
                categoria = self._categorizar_tipo_por_tiempo(tipo)
                if categoria == 'ciclo_corto':
                    distribucion['ciclo_corto'] += 1
                elif categoria == 'ciclo_medio':
                    distribucion['ciclo_medio'] += 1
                elif categoria == 'ciclo_largo':
                    distribucion['ciclo_largo'] += 1
                else:
                    distribucion['sin_datos'] += 1
            
            return distribucion
        except Exception:
            return {'ciclo_corto': 0, 'ciclo_medio': 0, 'ciclo_largo': 0, 'sin_datos': 0}
    
    def _contar_tipos_sin_variedades(self):
        """Cuenta tipos de cultivo que no tienen variedades."""
        try:
            tipos = self.tipo_repo.obtener_todos()
            return sum(1 for tipo in tipos if self._contar_variedades_cached(tipo['id_tipo_cultivo']) == 0)
        except Exception:
            return 0
    
    def _calcular_tiempo_promedio_sistema(self):
        """Calcula el tiempo promedio de cosecha de todo el sistema."""
        try:
            estadisticas = self.tipo_repo.obtener_estadisticas()
            return estadisticas.get('tiempo_promedio_cosecha', 0)
        except Exception:
            return 0
    
    def _evaluar_diversidad_cultivos(self, estadisticas):
        """Evalúa la diversidad de cultivos en el sistema."""
        total_tipos = estadisticas.get('total_tipos', 0)
        
        if total_tipos >= 20:
            return 'muy_alta'
        elif total_tipos >= 10:
            return 'alta'
        elif total_tipos >= 5:
            return 'media'
        else:
            return 'baja'
    
    def _generar_recomendaciones_tipo(self, tipo, total_variedades, total_ciclos):
        """Genera recomendaciones específicas para un tipo de cultivo."""
        recomendaciones = []
        
        if total_variedades == 0:
            recomendaciones.append("Agregar variedades para este tipo de cultivo")
        elif total_variedades == 1:
            recomendaciones.append("Considerar agregar más variedades para diversificar")
        
        if not tipo.get('descripcion'):
            recomendaciones.append("Completar la descripción del tipo de cultivo")
        
        if not tipo.get('nombre_cientifico'):
            recomendaciones.append("Agregar el nombre científico")
        
        if not tipo.get('tiempo_cosecha_min'):
            recomendaciones.append("Especificar tiempos de cosecha para mejor planificación")
        
        if total_ciclos == 0 and total_variedades > 0:
            recomendaciones.append("Tipo con variedades disponibles - listo para iniciar ciclos")
        
        return recomendaciones
    
    def _generar_recomendacion_tiempo(self, categoria):
        """Genera recomendaciones basadas en la categoría de tiempo."""
        recomendaciones = {
            'rapido': 'Ideal para rotación rápida y múltiples cosechas anuales',
            'medio': 'Equilibrio entre productividad y rotación',
            'largo': 'Requiere planificación a largo plazo',
            'variable': 'Verificar tiempos específicos por variedad'
        }
        return recomendaciones.get(categoria, 'Evaluar tiempos de cosecha')
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()