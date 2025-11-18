# bd_conecciones/servicios/parcela_servicio.py

import logging
from ...repositories.Productor_Parcelas_rep.parcela_repositorio import ParcelaRepositorio
from ...repositories.Productor_Parcelas_rep.productor_repositorio import ProductorRepositorio
from ...core.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste
)
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class ParcelaServicio:
    """Servicio para lógica de negocio de parcelas con caché optimizado."""
    
    def __init__(self):
        self.parcela_repo = ParcelaRepositorio()
        self.productor_repo = ProductorRepositorio()

    @cacheable('servicio_parcelas', key_func=lambda pagina, por_pagina=5, prop_id=None: f"paginado_{pagina}_{por_pagina}_{prop_id or 'all'}", ttl=900)
    def obtener_parcelas_paginado(self, pagina, por_pagina=5, propietario_id=None):
        """
        Obtiene parcelas con paginación y lógica de negocio aplicada.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            propietario_id (int, optional): Filtro por propietario.
            
        Returns:
            dict: Resultado con parcelas y metadatos.
        """
        try:
            resultado = self.parcela_repo.obtener_paginado(pagina, por_pagina, propietario_id)
            
            # Enriquecer datos con información adicional
            parcelas_enriquecidas = []
            for parcela in resultado['parcelas']:
                parcela_enriquecida = parcela.copy()
                
                # Agregar metadatos calculados
                parcela_enriquecida['tiene_coordenadas'] = self._tiene_coordenadas_validas(parcela)
                parcela_enriquecida['area_hectareas_texto'] = f"{parcela['area']} ha"
                parcela_enriquecida['estado_coordenadas'] = self._evaluar_estado_coordenadas_cached(parcela)
                parcela_enriquecida['categoria_tamaño'] = self._categorizar_parcela_por_tamaño(parcela['area'])
                parcela_enriquecida['requiere_atencion'] = self._requiere_atencion_parcela(parcela)
                
                parcelas_enriquecidas.append(parcela_enriquecida)
            
            resultado['parcelas'] = parcelas_enriquecidas
            resultado['metadatos'] = {
                'timestamp': self._get_timestamp(),
                'filtro_propietario': propietario_id,
                'total_con_coordenadas': sum(1 for p in parcelas_enriquecidas if p['tiene_coordenadas']),
                'area_total_pagina': sum(p['area'] for p in parcelas_enriquecidas)
            }
            
            logger.info(f"Servicio: página {pagina} de parcelas procesada con {len(resultado['parcelas'])} registros")
            
            return {
                'exito': True,
                'mensaje': f'Página {pagina} de parcelas obtenida',
                'datos': resultado,
                'metadatos': resultado['metadatos']
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_parcelas_paginado: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener parcelas',
                'datos': None
            }

    @cache_invalidator('servicio_parcelas', pattern='paginado_')
    @cache_invalidator('servicio_parcelas', pattern='busqueda_')
    @cache_invalidator('servicio_parcelas', pattern='propietario_')
    @cache_invalidator('estadisticas_parcelas')
    @cache_invalidator('reportes_parcelas')
    def crear_parcela(self, datos_parcela):
        """
        Crea una nueva parcela con validaciones de negocio.
        
        Args:
            datos_parcela (dict): Datos de la parcela.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio específicas
            self._validar_reglas_negocio_creacion(datos_parcela)
            
            # Normalizar y enriquecer datos
            datos_normalizados = self._normalizar_datos_parcela(datos_parcela)
            
            # Validar propietario
            self._validar_propietario_cached(datos_normalizados['id_productor'])
            
            # Crear parcela
            exito, id_parcela = self.parcela_repo.crear(datos_normalizados)
            
            if exito:
                # Obtener información de la parcela creada
                parcela_creada = self.parcela_repo.obtener_por_id(id_parcela)
                
                resultado = {
                    'exito': True,
                    'mensaje': f"Parcela '{datos_normalizados['nombre']}' creada exitosamente",
                    'datos': {
                        'id_parcela': id_parcela,
                        'parcela': parcela_creada,
                        'tiene_coordenadas': self._tiene_coordenadas_validas(parcela_creada)
                    },
                    'metadatos': {
                        'timestamp': self._get_timestamp(),
                        'requiere_actualizacion_listas': True,
                        'requiere_actualizacion_mapa': self._tiene_coordenadas_validas(parcela_creada)
                    }
                }
                
                logger.info(f"Servicio: parcela creada con ID {id_parcela}")
                return resultado
            else:
                return {
                    'exito': False,
                    'mensaje': 'Error al crear parcela',
                    'datos': None
                }
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error de validación en crear_parcela: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except Exception as e:
            logger.error(f"Error en servicio crear_parcela: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'datos': None
            }

    @cache_invalidator('servicio_parcelas', pattern='paginado_')
    @cache_invalidator('servicio_parcelas', pattern='busqueda_')
    @cache_invalidator('servicio_parcelas', pattern='propietario_')
    @cache_invalidator('servicio_parcelas', pattern='id_')
    @cache_invalidator('estadisticas_parcelas')
    @cache_invalidator('reportes_parcelas')
    def actualizar_parcela(self, id_parcela, datos_parcela):
        """
        Actualiza una parcela con validaciones de negocio.
        
        Args:
            id_parcela (int): ID de la parcela.
            datos_parcela (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales
            parcela_actual = self.parcela_repo.obtener_por_id(id_parcela)
            
            # Validar cambios críticos
            self._validar_cambios_criticos(parcela_actual, datos_parcela)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_parcela(datos_parcela)
            
            # Validar nuevo propietario si cambió
            if 'id_productor' in datos_normalizados:
                self._validar_propietario_cached(datos_normalizados['id_productor'])
            
            # Actualizar parcela
            exito = self.parcela_repo.actualizar(id_parcela, datos_normalizados)
            
            if exito:
                # Verificar cambios importantes
                cambio_propietario = self._verificar_cambio_propietario(parcela_actual, datos_normalizados)
                cambio_coordenadas = self._verificar_cambio_coordenadas(parcela_actual, datos_normalizados)
                
                resultado = {
                    'exito': True,
                    'mensaje': f"Parcela '{parcela_actual['nombre']}' actualizada exitosamente",
                    'datos': {
                        'id_parcela': id_parcela,
                        'cambios': datos_normalizados,
                        'cambio_propietario': cambio_propietario,
                        'cambio_coordenadas': cambio_coordenadas
                    },
                    'metadatos': {
                        'timestamp': self._get_timestamp(),
                        'requiere_actualizacion_mapa': cambio_coordenadas,
                        'requiere_actualizacion_listas': True
                    }
                }
                
                logger.info(f"Servicio: parcela {id_parcela} actualizada")
                return resultado
            else:
                return {
                    'exito': False,
                    'mensaje': 'Error al actualizar parcela',
                    'datos': None
                }
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en actualizar_parcela: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except Exception as e:
            logger.error(f"Error en servicio actualizar_parcela: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'datos': None
            }

    @cache_invalidator('servicio_parcelas', pattern='paginado_')
    @cache_invalidator('servicio_parcelas', pattern='busqueda_')
    @cache_invalidator('servicio_parcelas', pattern='propietario_')
    @cache_invalidator('servicio_parcelas', pattern='id_')
    @cache_invalidator('estadisticas_parcelas')
    @cache_invalidator('reportes_parcelas')
    def eliminar_parcela(self, id_parcela):
        """
        Elimina una parcela con validaciones de negocio.
        
        Args:
            id_parcela (int): ID de la parcela.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener información de la parcela
            parcela = self.parcela_repo.obtener_por_id(id_parcela)
            
            # Validar si se puede eliminar
            self._validar_eliminacion_parcela(parcela)
            
            # Proceder con eliminación
            exito = self.parcela_repo.desactivar(id_parcela)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Parcela '{parcela['nombre']}' eliminada exitosamente",
                    'datos': {
                        'parcela_eliminada': parcela,
                        'propietario': parcela['productor'],
                        'area': parcela['area'],
                        'tenia_coordenadas': self._tiene_coordenadas_validas(parcela)
                    },
                    'metadatos': {
                        'timestamp': self._get_timestamp(),
                        'requiere_actualizacion_mapa': self._tiene_coordenadas_validas(parcela),
                        'requiere_actualizacion_listas': True
                    }
                }
                
                logger.info(f"Servicio: parcela {id_parcela} eliminada")
                return resultado
            else:
                return {
                    'exito': False,
                    'mensaje': 'Error al eliminar parcela',
                    'datos': None
                }
                
        except RegistroNoEncontrado as e:
            logger.error(f"Parcela no encontrada: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except ErrorValidacion as e:
            logger.error(f"No se puede eliminar parcela: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except Exception as e:
            logger.error(f"Error en servicio eliminar_parcela: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'datos': None
            }

    @cacheable('servicio_parcelas', key_func=lambda texto: f"busqueda_{texto.lower().replace(' ', '_')}", ttl=600)
    def buscar_parcelas(self, texto_busqueda):
        """
        Busca parcelas con lógica de negocio aplicada.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            dict: Lista de parcelas encontradas con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return {
                    'exito': True,
                    'mensaje': 'Texto de búsqueda muy corto',
                    'datos': [],
                    'metadatos': {'total_resultados': 0}
                }
            
            parcelas = self.parcela_repo.buscar_por_nombre(texto_busqueda.strip())
            
            # Enriquecer resultados
            parcelas_enriquecidas = []
            for parcela in parcelas:
                parcela_enriquecida = parcela.copy()
                
                # Agregar información adicional
                parcela_enriquecida['tiene_coordenadas'] = self._tiene_coordenadas_validas(parcela)
                parcela_enriquecida['area_hectareas_texto'] = f"{parcela['area']} ha"
                parcela_enriquecida['estado_coordenadas'] = self._evaluar_estado_coordenadas_cached(parcela)
                parcela_enriquecida['categoria_tamaño'] = self._categorizar_parcela_por_tamaño(parcela['area'])
                
                parcelas_enriquecidas.append(parcela_enriquecida)
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(parcelas_enriquecidas)} parcelas")
            
            return {
                'exito': True,
                'mensaje': f'Búsqueda completada con {len(parcelas_enriquecidas)} resultados',
                'datos': parcelas_enriquecidas,
                'metadatos': {
                    'total_resultados': len(parcelas_enriquecidas),
                    'termino_busqueda': texto_busqueda,
                    'timestamp': self._get_timestamp()
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_parcelas: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error en la búsqueda',
                'datos': [],
                'metadatos': {'total_resultados': 0}
            }

    @cacheable('servicio_parcelas', key_func=lambda id_parc: f"id_{id_parc}", ttl=1200)
    def obtener_parcela_por_id(self, id_parcela):
        """
        Obtiene una parcela específica con información enriquecida.
        
        Args:
            id_parcela (int): ID de la parcela.
            
        Returns:
            dict: Información completa de la parcela.
        """
        try:
            parcela = self.parcela_repo.obtener_por_id(id_parcela)
            
            # Enriquecer con información adicional
            parcela['tiene_coordenadas'] = self._tiene_coordenadas_validas(parcela)
            parcela['estado_coordenadas'] = self._evaluar_estado_coordenadas_cached(parcela)
            parcela['categoria_tamaño'] = self._categorizar_parcela_por_tamaño(parcela['area'])
            parcela['requiere_atencion'] = self._requiere_atencion_parcela(parcela)
            
            return {
                'exito': True,
                'mensaje': 'Parcela obtenida exitosamente',
                'datos': parcela,
                'metadatos': {
                    'timestamp': self._get_timestamp(),
                    'tiene_coordenadas': parcela['tiene_coordenadas']
                }
            }
            
        except RegistroNoEncontrado as e:
            logger.error(f"Parcela no encontrada: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except Exception as e:
            logger.error(f"Error en servicio obtener_parcela_por_id: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener parcela',
                'datos': None
            }

    @cacheable('servicio_parcelas', key_func=lambda prop_id: f"propietario_{prop_id}", ttl=1200)
    def obtener_parcelas_por_propietario(self, propietario_id):
        """
        Obtiene parcelas de un propietario específico con información enriquecida.
        
        Args:
            propietario_id (int): ID del propietario.
            
        Returns:
            dict: Lista de parcelas del propietario.
        """
        try:
            if propietario_id == 0:
                parcelas = self.parcela_repo.obtener_todas()
            else:
                parcelas = self.parcela_repo.obtener_por_productor(propietario_id)
            
            # Enriquecer datos
            parcelas_enriquecidas = []
            for parcela in parcelas:
                parcela_enriquecida = parcela.copy()
                
                # Agregar información adicional
                parcela_enriquecida['tiene_coordenadas'] = self._tiene_coordenadas_validas(parcela)
                parcela_enriquecida['area_hectareas_texto'] = f"{parcela['area']} ha"
                parcela_enriquecida['estado_coordenadas'] = self._evaluar_estado_coordenadas_cached(parcela)
                parcela_enriquecida['categoria_tamaño'] = self._categorizar_parcela_por_tamaño(parcela['area'])
                
                parcelas_enriquecidas.append(parcela_enriquecida)
            
            return {
                'exito': True,
                'mensaje': f'{len(parcelas_enriquecidas)} parcelas del propietario {propietario_id}',
                'datos': parcelas_enriquecidas,
                'metadatos': {
                    'propietario_id': propietario_id,
                    'total_parcelas': len(parcelas_enriquecidas),
                    'con_coordenadas': sum(1 for p in parcelas_enriquecidas if p['tiene_coordenadas']),
                    'timestamp': self._get_timestamp()
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_parcelas_por_propietario: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener parcelas del propietario',
                'datos': [],
                'metadatos': {'propietario_id': propietario_id, 'total_parcelas': 0}
            }

    # ==================== ESTADÍSTICAS Y REPORTES ====================

    @cacheable('estadisticas_parcelas', key_func=lambda: 'completas', ttl=1800)
    def obtener_estadisticas_parcelas(self):
        """
        Obtiene estadísticas completas de parcelas.
        
        Returns:
            dict: Estadísticas detalladas de parcelas.
        """
        try:
            # Obtener estadísticas básicas
            estadisticas_basicas = self.parcela_repo.obtener_estadisticas_basicas()
            
            # Obtener distribución por propietario
            distribucion = self.productor_repo.obtener_distribucion_parcelas_por_productor()
            
            # Calcular métricas adicionales
            total_parcelas = estadisticas_basicas.get('total_parcelas', 0)
            area_total = estadisticas_basicas.get('area_total', 0)
            
            # Calcular parcelas con coordenadas (estimación)
            # En un sistema real, esto vendría de una consulta específica
            parcelas_con_coords_estimado = int(total_parcelas * 0.7)  # Estimación del 70%
            
            estadisticas = {
                'totales': {
                    'parcelas': total_parcelas,
                    'area_total': area_total,
                    'area_promedio': estadisticas_basicas.get('area_promedio', 0),
                    'propietarios_distintos': estadisticas_basicas.get('productores_distintos', 0)
                },
                'coordenadas': {
                    'con_coordenadas': parcelas_con_coords_estimado,
                    'sin_coordenadas': total_parcelas - parcelas_con_coords_estimado,
                    'porcentaje_con_coordenadas': round((parcelas_con_coords_estimado / total_parcelas * 100), 1) if total_parcelas > 0 else 0
                },
                'distribucion': {
                    'total_propietarios': len(distribucion),
                    'propietarios_con_parcelas': len([p for p in distribucion if p['cantidad_parcelas'] > 0]),
                    'concentracion_parcelas': self._calcular_concentracion_parcelas(distribucion)
                }
            }
            
            return {
                'exito': True,
                'mensaje': 'Estadísticas de parcelas generadas',
                'datos': estadisticas,
                'metadatos': {
                    'timestamp': self._get_timestamp(),
                    'total_calculos': len(estadisticas)
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_parcelas: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al generar estadísticas',
                'datos': {},
                'metadatos': {}
            }

    @cacheable('estadisticas_parcelas', key_func=lambda: 'generales_sistema', ttl=1800)
    def obtener_estadisticas_generales(self):
        """
        Obtiene estadísticas generales del sistema.
        
        Returns:
            dict: Estadísticas completas del sistema.
        """
        try:
            estadisticas = self.parcela_repo.obtener_estadisticas_generales()
            
            return {
                'exito': True,
                'mensaje': 'Estadísticas generales del sistema',
                'datos': estadisticas,
                'metadatos': {
                    'timestamp': self._get_timestamp(),
                    'origen': 'sistema_completo'
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_generales: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener estadísticas generales',
                'datos': {},
                'metadatos': {}
            }

    @cacheable('reportes_parcelas', key_func=lambda: 'resumen_completo', ttl=1800)
    def obtener_resumen_parcelas(self):
        """
        Obtiene un resumen completo de parcelas para dashboard.
        
        Returns:
            dict: Resumen completo de parcelas.
        """
        try:
            # Obtener datos base
            estadisticas = self.obtener_estadisticas_parcelas()['datos']
            distribucion = self.productor_repo.obtener_distribucion_parcelas_por_productor()
            
            resumen = {
                'totales': {
                    'parcelas': estadisticas['totales']['parcelas'],
                    'area_total': estadisticas['totales']['area_total'],
                    'propietarios_distintos': estadisticas['totales']['propietarios_distintos']
                },
                'coordenadas': estadisticas['coordenadas'],
                'distribucion': distribucion[:5],  # Top 5
                'metricas_avanzadas': {
                    'concentracion_tierras': estadisticas['distribucion']['concentracion_parcelas'],
                    'eficiencia_registro': estadisticas['coordenadas']['porcentaje_con_coordenadas'],
                    'distribucion_tamaños': self._calcular_distribucion_tamaños(distribucion)
                }
            }
            
            logger.info(f"Resumen de parcelas generado: {resumen['totales']['parcelas']} total")
            
            return {
                'exito': True,
                'mensaje': 'Resumen de parcelas generado',
                'datos': resumen,
                'metadatos': {
                    'timestamp': self._get_timestamp(),
                    'total_metricas': len(resumen['metricas_avanzadas'])
                }
            }
            
        except Exception as e:
            logger.error(f"Error generando resumen de parcelas: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al generar resumen',
                'datos': {},
                'metadatos': {}
            }

    @cacheable('reportes_parcelas', key_func=lambda: 'parcelas_sin_coordenadas', ttl=3600)
    def obtener_parcelas_sin_coordenadas(self):
        """
        Obtiene parcelas que no tienen coordenadas registradas.
        
        Returns:
            dict: Lista de parcelas sin coordenadas.
        """
        try:
            # En un sistema real, esto consultaría la base de datos
            # Por ahora, simulamos obteniendo todas y filtrando
            todas_parcelas = self.parcela_repo.obtener_todas()
            parcelas_sin_coords = [p for p in todas_parcelas if not self._tiene_coordenadas_validas(p)]
            
            return {
                'exito': True,
                'mensaje': f'{len(parcelas_sin_coords)} parcelas sin coordenadas',
                'datos': parcelas_sin_coords,
                'metadatos': {
                    'timestamp': self._get_timestamp(),
                    'total_sin_coordenadas': len(parcelas_sin_coords),
                    'porcentaje_sin_coordenadas': round((len(parcelas_sin_coords) / len(todas_parcelas) * 100), 1) if todas_parcelas else 0
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_parcelas_sin_coordenadas: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener parcelas sin coordenadas',
                'datos': [],
                'metadatos': {'total_sin_coordenadas': 0}
            }

    # ==================== VALIDACIONES Y GESTIÓN ESPECIALIZADA ====================

    @cacheable('validaciones_parcelas', key_func=lambda id_parcela, nuevo_prod: f"transfer_{id_parcela}_{nuevo_prod}", ttl=300)
    def validar_transferencia_parcela(self, id_parcela, nuevo_productor_id):
        """
        Valida si se puede transferir una parcela a un nuevo productor.
        
        Args:
            id_parcela (int): ID de la parcela.
            nuevo_productor_id (int): ID del nuevo productor.
            
        Returns:
            dict: Información de validación.
        """
        try:
            validacion = self.parcela_repo.validar_transferencia_parcela(id_parcela, nuevo_productor_id)
            
            return {
                'exito': True,
                'mensaje': 'Validación de transferencia completada',
                'datos': validacion,
                'metadatos': {
                    'timestamp': self._get_timestamp(),
                    'parcela_id': id_parcela,
                    'nuevo_productor_id': nuevo_productor_id
                }
            }
            
        except (RegistroNoEncontrado, ErrorValidacion) as e:
            logger.error(f"Error en validar_transferencia_parcela: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except Exception as e:
            logger.error(f"Error en servicio validar_transferencia_parcela: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error interno en validación',
                'datos': None
            }

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('validaciones_parcelas', key_func=lambda datos: f"reglas_creacion_{hash(str(sorted(datos.items())))}", ttl=3600)
    def _validar_reglas_negocio_creacion_cached(self, datos):
        """Valida reglas de negocio específicas para creación (versión cacheada)."""
        if not datos.get('nombre') or not datos.get('nombre').strip():
            raise ErrorValidacion("El nombre de la parcela es obligatorio")
            
        if not datos.get('id_productor'):
            raise ErrorValidacion("El productor es obligatorio")
        
        if not datos.get('area_total') or datos.get('area_total') <= 0:
            raise ErrorValidacion("El área total debe ser mayor a 0")
        
        # Regla: Área mínima
        if datos.get('area_total', 0) < 0.1:
            raise ErrorValidacion("El área mínima de una parcela debe ser 0.1 hectáreas")
        
        return True

    @cacheable('validaciones_parcelas', key_func=lambda prop_id: f"propietario_valido_{prop_id}", ttl=1800)
    def _validar_propietario_cached(self, propietario_id):
        """Valida que el propietario existe y es válido (versión cacheada)."""
        try:
            productor = self.productor_repo.obtener_por_id(propietario_id)
            # Nota: En el sistema actual no hay campo esPropietario, pero se podría agregar
            return True
        except RegistroNoEncontrado:
            raise ErrorValidacion("El propietario seleccionado no existe")

    @cacheable('evaluaciones', key_func=lambda parcela: f"coords_{hash(str(parcela))}", ttl=3600)
    def _evaluar_estado_coordenadas_cached(self, parcela):
        """Evalúa el estado de las coordenadas de una parcela (versión cacheada)."""
        if not self._tiene_coordenadas_validas(parcela):
            return 'sin_coordenadas'
        
        # En un sistema real, aquí se verificaría si las coordenadas están dentro de Bolivia
        # Por ahora, asumimos que todas las coordenadas existentes son válidas
        return 'coordenadas_validas'

    def _validar_reglas_negocio_creacion(self, datos):
        """Valida reglas de negocio específicas para creación."""
        return self._validar_reglas_negocio_creacion_cached(datos)

    def _validar_cambios_criticos(self, parcela_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Validar reducción drástica de área
        if 'area_total' in datos_nuevos:
            area_nueva = datos_nuevos['area_total']
            area_actual = parcela_actual['area_total']
            
            if area_nueva < area_actual * 0.1:  # Reducción mayor al 90%
                raise ErrorValidacion("No se puede reducir el área en más del 90% de una sola vez")

    def _validar_eliminacion_parcela(self, parcela):
        """Valida si una parcela puede ser eliminada."""
        # En el futuro, verificar cultivos activos, contratos, etc.
        # Por ahora, todas las parcelas pueden eliminarse
        pass

    def _normalizar_datos_parcela(self, datos):
        """Normaliza y limpia los datos de la parcela."""
        datos_normalizados = datos.copy()
        
        # Limpiar espacios en strings
        for campo in ['nombre', 'ubicacion']:
            if campo in datos_normalizados and datos_normalizados[campo]:
                datos_normalizados[campo] = datos_normalizados[campo].strip()
        
        # Normalizar área
        if 'area_total' in datos_normalizados:
            datos_normalizados['area_total'] = round(float(datos_normalizados['area_total']), 2)
        
        return datos_normalizados

    def _verificar_cambio_propietario(self, parcela_actual, datos_nuevos):
        """Verifica si cambió el propietario."""
        return ('id_productor' in datos_nuevos and 
                parcela_actual['id_productor'] != datos_nuevos['id_productor'])

    def _verificar_cambio_coordenadas(self, parcela_actual, datos_nuevos):
        """Verifica si cambiaron las coordenadas."""
        # En el sistema actual no hay coordenadas, pero se deja para futura implementación
        return False

    def _tiene_coordenadas_validas(self, parcela):
        """Verifica si la parcela tiene coordenadas válidas."""
        # En el sistema actual no hay coordenadas, pero se deja para futura implementación
        return False

    def _categorizar_parcela_por_tamaño(self, area):
        """Categoriza una parcela según su área."""
        if area <= 1:
            return 'muy_pequeña'
        elif area <= 5:
            return 'pequeña'
        elif area <= 20:
            return 'mediana'
        elif area <= 100:
            return 'grande'
        else:
            return 'muy_grande'

    def _requiere_atencion_parcela(self, parcela):
        """Determina si una parcela requiere atención especial."""
        # Parcelas sin coordenadas (cuando se implementen)
        if not self._tiene_coordenadas_validas(parcela):
            return True
        
        # Parcelas con coordenadas sospechosas
        estado_coords = self._evaluar_estado_coordenadas_cached(parcela)
        if estado_coords == 'coordenadas_sospechosas':
            return True
        
        return False

    def _calcular_concentracion_parcelas(self, distribucion):
        """Calcula la concentración de parcelas."""
        if not distribucion:
            return 0
        
        areas = sorted([p['area_total'] for p in distribucion if p['cantidad_parcelas'] > 0])
        if len(areas) < 2:
            return 0
        
        # Top 20% vs resto
        top_20_percent = max(1, int(len(areas) * 0.2))
        area_top_20 = sum(areas[-top_20_percent:])
        area_total = sum(areas)
        
        return round((area_top_20 / area_total) * 100, 1) if area_total > 0 else 0

    def _calcular_distribucion_tamaños(self, distribucion):
        """Calcula la distribución de tamaños de parcelas."""
        # Esta es una implementación simplificada
        # En un sistema real, se consultarían las parcelas individuales
        areas = [p['area_total'] for p in distribucion if p['area_total'] > 0]
        
        if not areas:
            return {}
        
        return {
            'muy_pequeñas': len([a for a in areas if a <= 1]),
            'pequeñas': len([a for a in areas if 1 < a <= 5]),
            'medianas': len([a for a in areas if 5 < a <= 20]),
            'grandes': len([a for a in areas if 20 < a <= 100]),
            'muy_grandes': len([a for a in areas if a > 100])
        }

    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()