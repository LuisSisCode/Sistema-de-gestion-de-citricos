# bd_conecciones/servicios/parcela_servicio.py

import logging
from ...repositories.Productor_Parcelas_rep.parcela_repositorio import ParcelaRepositorio
from ...repositories.Productor_Parcelas_rep.relacion_AgriPar_repositorio import RelacionRepositorio
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
        self.relacion_repo = RelacionRepositorio()
        self.productor_repo = ProductorRepositorio()

    @cacheable('servicio_parcelas', key_func=lambda pagina, por_pagina=5, prop_id=None: f"paginado_{pagina}_{por_pagina}_{prop_id or 'all'}", ttl=900)  # 15 min
    def obtener_parcelas_paginado(self, pagina, por_pagina=5, propietario_id=None):
        """
        Obtiene parcelas con paginación y lógica de negocio aplicada.
        ⭐ MUY OPTIMIZADO: Resultado enriquecido completo cacheado para evitar recálculos
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            propietario_id (int, optional): Filtro por propietario.
            
        Returns:
            dict: Resultado con parcelas y metadatos.
        """
        try:
            resultado = self.parcela_repo.obtener_paginado(pagina, por_pagina, propietario_id)
            
            # Enriquecer datos con información adicional (OPTIMIZADO: resultado completo cacheado)
            parcelas_enriquecidas = []
            for parcela in resultado['parcelas']:
                parcela_enriquecida = parcela.copy()
                
                # Agregar metadatos calculados (ahora cacheados a nivel de servicio)
                parcela_enriquecida['tiene_coordenadas'] = bool(parcela['latitud'] and parcela['longitud'])
                parcela_enriquecida['area_hectareas_texto'] = f"{parcela['area']} ha"
                parcela_enriquecida['estado_coordenadas'] = self._evaluar_estado_coordenadas_cached(parcela)
                
                # Información adicional de negocio
                parcela_enriquecida['categoria_tamaño'] = self._categorizar_parcela_por_tamaño(parcela['area'])
                parcela_enriquecida['requiere_atencion'] = self._requiere_atencion_parcela(parcela)
                
                parcelas_enriquecidas.append(parcela_enriquecida)
            
            # Agregar metadatos adicionales
            resultado['parcelas'] = parcelas_enriquecidas
            resultado['filtro_propietario'] = propietario_id
            resultado['estadisticas_pagina'] = self._calcular_estadisticas_pagina_cached(parcelas_enriquecidas)
            resultado['metadatos_servicio'] = {
                'timestamp': self._get_timestamp(),
                'total_con_coordenadas': sum(1 for p in parcelas_enriquecidas if p['tiene_coordenadas']),
                'area_total_pagina': sum(p['area'] for p in parcelas_enriquecidas)
            }
            
            logger.info(f"Servicio: página {pagina} de parcelas procesada con {len(resultado['parcelas'])} registros")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_parcelas_paginado: {str(e)}")
            raise

    @cache_invalidator('servicio_parcelas', pattern='paginado_')     # Invalidar paginación
    @cache_invalidator('servicio_parcelas', pattern='busqueda_')    # Invalidar búsquedas
    @cache_invalidator('servicio_parcelas', pattern='propietario_') # Invalidar por propietario
    @cache_invalidator('estadisticas_parcelas')                     # Invalidar estadísticas
    @cache_invalidator('validaciones_parcelas')                     # Invalidar validaciones
    def crear_parcela(self, datos_parcela):
        """
        Crea una nueva parcela con validaciones de negocio.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_parcela (dict): Datos de la parcela.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio específicas (ahora cacheadas)
            self._validar_reglas_negocio_creacion_cached(datos_parcela)
            
            # Normalizar y enriquecer datos
            datos_normalizados = self._normalizar_datos_parcela(datos_parcela)
            
            # Validar propietario (ahora cacheado)
            self._validar_propietario_cached(datos_normalizados['propietarioId'])
            
            # Crear parcela
            exito, id_parcela = self.parcela_repo.crear(datos_normalizados)
            
            if exito:
                # Obtener información de la parcela creada
                parcela_creada = self.parcela_repo.obtener_por_id(id_parcela)
                
                resultado = {
                    'exito': True,
                    'id_parcela': id_parcela,
                    'mensaje': f"Parcela '{datos_normalizados['nombre']}' creada exitosamente",
                    'parcela': parcela_creada,
                    'tiene_coordenadas': bool(datos_normalizados.get('latitud')),
                    'requiere_actualizacion_listas': True,
                    'requiere_actualizacion_mapa': bool(datos_normalizados.get('latitud'))
                }
                
                logger.info(f"Servicio: parcela creada con ID {id_parcela}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear parcela'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error de validación en crear_parcela: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_parcela: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_parcelas', pattern='paginado_')     # Invalidar paginación
    @cache_invalidator('servicio_parcelas', pattern='busqueda_')    # Invalidar búsquedas
    @cache_invalidator('servicio_parcelas', pattern='propietario_') # Invalidar por propietario
    @cache_invalidator('estadisticas_parcelas')                     # Invalidar estadísticas
    @cache_invalidator('validaciones_parcelas')                     # Invalidar validaciones
    def actualizar_parcela(self, id_parcela, datos_parcela):
        """
        Actualiza una parcela con validaciones de negocio.
        OPTIMIZADO: Invalidación específica y general.
        
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
            
            # Validar nuevo propietario si cambió (ahora cacheado)
            if 'propietarioId' in datos_normalizados:
                self._validar_propietario_cached(datos_normalizados['propietarioId'])
            
            # Actualizar parcela
            exito = self.parcela_repo.actualizar(id_parcela, datos_normalizados)
            
            if exito:
                # Verificar cambios importantes
                cambio_propietario = self._verificar_cambio_propietario(parcela_actual, datos_normalizados)
                cambio_coordenadas = self._verificar_cambio_coordenadas(parcela_actual, datos_normalizados)
                
                resultado = {
                    'exito': True,
                    'mensaje': f"Parcela '{parcela_actual['nombre']}' actualizada exitosamente",
                    'cambio_propietario': cambio_propietario,
                    'cambio_coordenadas': cambio_coordenadas,
                    'requiere_actualizacion_mapa': cambio_coordenadas,
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: parcela {id_parcela} actualizada")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar parcela'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en actualizar_parcela: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_parcela: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_parcelas', pattern='paginado_')     # Invalidar paginación
    @cache_invalidator('servicio_parcelas', pattern='busqueda_')    # Invalidar búsquedas
    @cache_invalidator('servicio_parcelas', pattern='propietario_') # Invalidar por propietario
    @cache_invalidator('estadisticas_parcelas')                     # Invalidar estadísticas
    @cache_invalidator('validaciones_parcelas')                     # Invalidar validaciones
    def eliminar_parcela(self, id_parcela):
        """
        Elimina una parcela con validaciones de negocio.
        OPTIMIZADO: Invalidación completa ya que afecta todas las listas.
        
        Args:
            id_parcela (int): ID de la parcela.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener información de la parcela
            parcela = self.parcela_repo.obtener_por_id(id_parcela)
            
            # Validar si se puede eliminar (reglas de negocio futuras)
            self._validar_eliminacion_parcela(parcela)
            
            # Proceder con eliminación
            exito = self.parcela_repo.desactivar(id_parcela)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Parcela '{parcela['nombre']}' eliminada exitosamente",
                    'propietario': parcela['propietario'],
                    'area': parcela['area'],
                    'tenia_coordenadas': bool(parcela.get('latitud')),
                    'requiere_actualizacion_mapa': bool(parcela.get('latitud')),
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: parcela {id_parcela} eliminada")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al eliminar parcela'}
                
        except RegistroNoEncontrado as e:
            logger.error(f"Parcela no encontrada: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except ErrorValidacion as e:
            logger.error(f"No se puede eliminar parcela: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio eliminar_parcela: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cacheable('servicio_parcelas', key_func=lambda texto: f"busqueda_{texto.lower().replace(' ', '_')}", ttl=600)  # 10 min
    def buscar_parcelas(self, texto_busqueda):
        """
        Busca parcelas con lógica de negocio aplicada.
        ⭐ OPTIMIZADO: Resultado enriquecido completo cacheado
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de parcelas encontradas con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return []
            
            parcelas = self.parcela_repo.buscar_por_nombre(texto_busqueda.strip())
            
            # Enriquecer resultados (OPTIMIZADO: resultado completo cacheado)
            parcelas_enriquecidas = []
            for parcela in parcelas:
                parcela_enriquecida = parcela.copy()
                
                # Agregar información adicional
                parcela_enriquecida['tiene_coordenadas'] = bool(parcela['latitud'] and parcela['longitud'])
                parcela_enriquecida['area_hectareas_texto'] = f"{parcela['area']} ha"
                parcela_enriquecida['estado_coordenadas'] = self._evaluar_estado_coordenadas_cached(parcela)
                parcela_enriquecida['categoria_tamaño'] = self._categorizar_parcela_por_tamaño(parcela['area'])
                
                parcelas_enriquecidas.append(parcela_enriquecida)
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(parcelas_enriquecidas)} parcelas")
            return parcelas_enriquecidas
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_parcelas: {str(e)}")
            return []

    @cacheable('estadisticas_parcelas', key_func=lambda: 'completas_servicio', ttl=1800)  # 30 min
    def obtener_estadisticas_parcelas(self):
        """
        Obtiene estadísticas completas de parcelas.
        ⭐ MUY OPTIMIZADO: Múltiples consultas a repositorios ahora cacheadas como conjunto
        
        Returns:
            dict: Estadísticas detalladas.
        """
        try:
            # Estos métodos ya están cacheados en repositorios, pero el resultado final también se cachea
            estadisticas_basicas = self.parcela_repo.obtener_estadisticas_basicas()
            parcelas_sin_coords = self.relacion_repo.obtener_parcelas_sin_coordenadas()
            distribucion = self.relacion_repo.obtener_distribución_parcelas_por_propietario()
            
            # Estadísticas enriquecidas de servicio
            estadisticas = {
                **estadisticas_basicas,
                'parcelas_sin_coordenadas': len(parcelas_sin_coords),
                'distribucion_por_propietario': distribucion,
                'porcentaje_con_coordenadas': self._calcular_porcentaje_coordenadas(estadisticas_basicas, parcelas_sin_coords),
                
                # Nuevas métricas de servicio
                'metricas_servicio': {
                    'area_promedio_por_propietario': self._calcular_area_promedio_por_propietario(distribucion),
                    'propietarios_con_parcelas': len([p for p in distribucion if p['cantidad_parcelas'] > 0]),
                    'concentracion_parcelas': self._calcular_concentracion_parcelas(distribucion),
                    'timestamp': self._get_timestamp()
                }
            }
            
            logger.info(f"Estadísticas completas de parcelas calculadas: {estadisticas_basicas.get('total_parcelas', 0)} parcelas")
            return estadisticas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_parcelas: {str(e)}")
            return {}

    @cacheable('servicio_parcelas', key_func=lambda prop_id: f"propietario_{prop_id}", ttl=1200)  # 20 min
    def obtener_parcelas_por_propietario(self, propietario_id):
        """
        Obtiene parcelas de un propietario específico con información enriquecida.
        ⭐ OPTIMIZADO: Resultado enriquecido cacheado por propietario
        
        Args:
            propietario_id (int): ID del propietario.
            
        Returns:
            list: Lista de parcelas del propietario.
        """
        try:
            if propietario_id == 0:
                parcelas = self.parcela_repo.obtener_todas()
            else:
                parcelas = self.parcela_repo.obtener_por_propietario(propietario_id)
            
            # Enriquecer datos (OPTIMIZADO: resultado completo cacheado)
            parcelas_enriquecidas = []
            for parcela in parcelas:
                parcela_enriquecida = parcela.copy()
                
                # Agregar información adicional
                parcela_enriquecida['tiene_coordenadas'] = bool(parcela['latitud'] and parcela['longitud'])
                parcela_enriquecida['area_hectareas_texto'] = f"{parcela['area']} ha"
                parcela_enriquecida['estado_coordenadas'] = self._evaluar_estado_coordenadas_cached(parcela)
                parcela_enriquecida['categoria_tamaño'] = self._categorizar_parcela_por_tamaño(parcela['area'])
                
                parcelas_enriquecidas.append(parcela_enriquecida)
            
            return parcelas_enriquecidas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_parcelas_por_propietario: {str(e)}")
            return []

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('validaciones_parcelas', key_func=lambda datos: f"reglas_creacion_{hash(str(sorted(datos.items())))}", ttl=3600)  # 1 hora
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
        # Regla: Área mínima
        if datos.get('area', 0) < 0.1:
            raise ErrorValidacion("El área mínima de una parcela debe ser 0.1 hectáreas")
        
        # Regla: Área máxima razonable
        if datos.get('area', 0) > 10000:
            raise ErrorValidacion("El área máxima permitida es 10,000 hectáreas")
        
        return True

    @cacheable('validaciones_parcelas', key_func=lambda prop_id: f"propietario_valido_{prop_id}", ttl=1800)  # 30 min
    def _validar_propietario_cached(self, propietario_id):
        """
        Valida que el propietario existe y es válido (versión cacheada).
        
        Args:
            propietario_id (int): ID del propietario.
            
        Returns:
            bool: True si es válido.
            
        Raises:
            ErrorValidacion: Si no es válido.
        """
        try:
            agricultor = self.productor_repo.obtener_por_id(propietario_id)
            if not agricultor['esPropietario']:
                raise ErrorValidacion("El agricultor seleccionado no está marcado como propietario")
            return True
        except RegistroNoEncontrado:
            raise ErrorValidacion("El propietario seleccionado no existe")

    @cacheable('evaluaciones', key_func=lambda parcela: f"coords_{hash(str(parcela.get('latitud', 0)))}{hash(str(parcela.get('longitud', 0)))}", ttl=3600)  # 1 hora
    def _evaluar_estado_coordenadas_cached(self, parcela):
        """
        Evalúa el estado de las coordenadas de una parcela (versión cacheada).
        
        Args:
            parcela (dict): Datos de la parcela.
            
        Returns:
            str: Estado de las coordenadas.
        """
        if not parcela['latitud'] or not parcela['longitud']:
            return 'sin_coordenadas'
        
        # Verificar si las coordenadas están dentro de Bolivia
        lat, lng = parcela['latitud'], parcela['longitud']
        if -25 <= lat <= -9 and -70 <= lng <= -57:
            return 'coordenadas_validas'
        else:
            return 'coordenadas_sospechosas'

    @cacheable('calculos', key_func=lambda parcelas: f"stats_pagina_{len(parcelas)}_{hash(str([p['area'] for p in parcelas]))}", ttl=1800)  # 30 min
    def _calcular_estadisticas_pagina_cached(self, parcelas):
        """
        Calcula estadísticas de la página actual (versión cacheada).
        
        Args:
            parcelas (list): Lista de parcelas.
            
        Returns:
            dict: Estadísticas de la página.
        """
        if not parcelas:
            return {'area_total_pagina': 0, 'area_promedio_pagina': 0}
        
        area_total = sum(p['area'] for p in parcelas)
        area_promedio = area_total / len(parcelas)
        
        return {
            'area_total_pagina': round(area_total, 2),
            'area_promedio_pagina': round(area_promedio, 2),
            'parcelas_con_coordenadas': sum(1 for p in parcelas if p.get('tiene_coordenadas')),
            'porcentaje_con_coordenadas_pagina': round((sum(1 for p in parcelas if p.get('tiene_coordenadas')) / len(parcelas)) * 100, 1)
        }

    @cacheable('resumen_parcelas', key_func=lambda: 'dashboard_parcelas', ttl=1800)  # 30 min
    def obtener_resumen_parcelas(self):
        """
        Obtiene un resumen completo de parcelas para dashboard.
        ⭐ NUEVO: Método optimizado para dashboard
        
        Returns:
            dict: Resumen completo de parcelas.
        """
        try:
            # Obtener datos base (ya cacheados)
            estadisticas = self.obtener_estadisticas_parcelas()
            
            # Calcular métricas adicionales
            resumen = {
                'totales': {
                    'parcelas': estadisticas.get('total_parcelas', 0),
                    'area_total': estadisticas.get('area_total', 0),
                    'propietarios_distintos': estadisticas.get('propietarios_distintos', 0)
                },
                'coordenadas': {
                    'con_coordenadas': estadisticas.get('total_parcelas', 0) - estadisticas.get('parcelas_sin_coordenadas', 0),
                    'sin_coordenadas': estadisticas.get('parcelas_sin_coordenadas', 0),
                    'porcentaje_completo': estadisticas.get('porcentaje_con_coordenadas', 0)
                },
                'distribucion': estadisticas.get('distribucion_por_propietario', [])[:5],  # Top 5
                'metricas_servicio': estadisticas.get('metricas_servicio', {}),
                'timestamp': self._get_timestamp()
            }
            
            logger.info(f"Resumen de parcelas generado: {resumen['totales']['parcelas']} total")
            return resumen
            
        except Exception as e:
            logger.error(f"Error generando resumen de parcelas: {str(e)}")
            return {}

    # ==================== MÉTODOS AUXILIARES PRIVADOS ====================

    def _validar_cambios_criticos(self, parcela_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Validar reducción drástica de área
        if 'area' in datos_nuevos:
            area_nueva = datos_nuevos['area']
            area_actual = parcela_actual['area']
            
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
        for campo in ['nombre', 'ubicacion', 'tipoSuelo', 'fuenteAgua']:
            if campo in datos_normalizados and datos_normalizados[campo]:
                datos_normalizados[campo] = datos_normalizados[campo].strip()
        
        # Normalizar área
        if 'area' in datos_normalizados:
            datos_normalizados['area'] = round(float(datos_normalizados['area']), 2)
        
        # Normalizar coordenadas
        if 'latitud' in datos_normalizados and datos_normalizados['latitud']:
            datos_normalizados['latitud'] = round(float(datos_normalizados['latitud']), 6)
        
        if 'longitud' in datos_normalizados and datos_normalizados['longitud']:
            datos_normalizados['longitud'] = round(float(datos_normalizados['longitud']), 6)
        
        return datos_normalizados

    def _verificar_cambio_propietario(self, parcela_actual, datos_nuevos):
        """Verifica si cambió el propietario."""
        return ('propietarioId' in datos_nuevos and 
                parcela_actual['propietarioId'] != datos_nuevos['propietarioId'])

    def _verificar_cambio_coordenadas(self, parcela_actual, datos_nuevos):
        """Verifica si cambiaron las coordenadas."""
        return (('latitud' in datos_nuevos and parcela_actual['latitud'] != datos_nuevos.get('latitud')) or
                ('longitud' in datos_nuevos and parcela_actual['longitud'] != datos_nuevos.get('longitud')))

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
        # Parcelas sin coordenadas
        if not parcela.get('latitud') or not parcela.get('longitud'):
            return True
        
        # Parcelas con coordenadas sospechosas
        estado_coords = self._evaluar_estado_coordenadas_cached(parcela)
        if estado_coords == 'coordenadas_sospechosas':
            return True
        
        return False

    def _calcular_porcentaje_coordenadas(self, estadisticas_basicas, parcelas_sin_coords):
        """Calcula el porcentaje de parcelas con coordenadas."""
        total = estadisticas_basicas.get('total_parcelas', 0)
        sin_coords = len(parcelas_sin_coords)
        
        if total == 0:
            return 0
        
        return round(((total - sin_coords) / total) * 100, 1)

    def _calcular_area_promedio_por_propietario(self, distribucion):
        """Calcula el área promedio por propietario."""
        if not distribucion:
            return 0
        
        propietarios_con_parcelas = [p for p in distribucion if p['cantidad_parcelas'] > 0]
        if not propietarios_con_parcelas:
            return 0
        
        area_total = sum(p['area_total'] for p in propietarios_con_parcelas)
        return round(area_total / len(propietarios_con_parcelas), 2)

    def _calcular_concentracion_parcelas(self, distribucion):
        """Calcula la concentración de parcelas (índice Gini simplificado)."""
        if not distribucion:
            return 0
        
        areas = sorted([p['area_total'] for p in distribucion if p['cantidad_parcelas'] > 0])
        if len(areas) < 2:
            return 0
        
        # Cálculo simplificado de concentración
        area_total = sum(areas)
        n = len(areas)
        
        # Top 20% vs resto
        top_20_percent = max(1, int(n * 0.2))
        area_top_20 = sum(areas[-top_20_percent:])
        
        return round((area_top_20 / area_total) * 100, 1) if area_total > 0 else 0

    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()