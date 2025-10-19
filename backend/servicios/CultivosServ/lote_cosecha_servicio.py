# bd_conecciones/servicios/CultivosServ/lote_cosecha_servicio.py

import logging
from datetime import datetime, date, timedelta
from ...repositories.CultivosRepositorio.lote_cosecha_repositorio import LoteCosechaRepositorio
from ...repositories.CultivosRepositorio.ciclo_produccion_repositorio import CicloProduccionRepositorio
from ...repositories.CultivosRepositorio.variedad_cultivo_repositorio import VariedadCultivoRepositorio
from ...core.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste
)
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class LoteCosechaServicio:
    """Servicio para lógica de negocio de lotes de cosecha con caché optimizado."""
    
    def __init__(self):
        self.lote_repo = LoteCosechaRepositorio()
        self.ciclo_repo = CicloProduccionRepositorio()
        self.variedad_repo = VariedadCultivoRepositorio()
    
    @cacheable('servicio_lotes', key_func=lambda pagina, por_pagina=8, filtros=None: f"paginado_{pagina}_{por_pagina}_{hash(str(filtros or {}))}", ttl=600)  # 10 min
    def obtener_lotes_paginado(self, pagina, por_pagina=8, filtros=None):
        """
        Obtiene lotes de cosecha con paginación y lógica de negocio aplicada.
        ⭐ OPTIMIZADO: Resultado enriquecido completo cacheado
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            filtros (dict, optional): Filtros (categoria, fecha_desde, fecha_hasta, disponible).
            
        Returns:
            dict: Resultado con lotes y metadatos.
        """
        try:
            # Para este ejemplo, obtenemos todos y paginamos en memoria
            # En producción, implementarías paginación en el repositorio
            todos_lotes = self.lote_repo.obtener_todos()
            
            # Aplicar filtros
            if filtros:
                todos_lotes = self._aplicar_filtros(todos_lotes, filtros)
            
            # Paginación en memoria
            inicio = (pagina - 1) * por_pagina
            fin = inicio + por_pagina
            lotes_pagina = todos_lotes[inicio:fin]
            
            # Enriquecer datos con información adicional
            lotes_enriquecidos = []
            for lote in lotes_pagina:
                lote_enriquecido = lote.copy()
                
                # Agregar metadatos de negocio
                lote_enriquecido['estado_comercial'] = self._evaluar_estado_comercial(lote)
                lote_enriquecido['recomendacion_precio'] = self._generar_recomendacion_precio(lote)
                lote_enriquecido['alertas'] = self._generar_alertas_lote(lote)
                lote_enriquecido['disponibilidad'] = self._calcular_disponibilidad_cached(lote['id_lote'])
                
                # Información de rendimiento vs esperado
                lote_enriquecido['analisis_rendimiento'] = self._analizar_rendimiento_vs_esperado(lote)
                lote_enriquecido['categoria_rentabilidad'] = self._categorizar_rentabilidad(lote)
                
                lotes_enriquecidos.append(lote_enriquecido)
            
            # Calcular metadatos de la página
            total_registros = len(todos_lotes)
            total_paginas = (total_registros + por_pagina - 1) // por_pagina
            
            resultado = {
                'lotes': lotes_enriquecidos,
                'total_registros': total_registros,
                'total_paginas': total_paginas,
                'pagina_actual': pagina,
                'filtros_aplicados': filtros or {},
                'estadisticas_pagina': self._calcular_estadisticas_pagina(lotes_enriquecidos),
                'metadatos_servicio': {
                    'timestamp': self._get_timestamp(),
                    'total_disponibles': sum(1 for l in lotes_enriquecidos if l['disponibilidad']['disponible']),
                    'valor_total_pagina': sum(l['valor_total_estimado'] for l in lotes_enriquecidos)
                }
            }
            
            logger.info(f"Servicio: página {pagina} procesada con {len(lotes_enriquecidos)} lotes")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_lotes_paginado: {str(e)}")
            raise

    @cache_invalidator('servicio_lotes', pattern='paginado_')       # Invalidar paginación
    @cache_invalidator('servicio_lotes', pattern='disponibles_')   # Invalidar disponibles
    @cache_invalidator('estadisticas_lotes_servicio')              # Invalidar estadísticas
    def registrar_cosecha(self, id_ciclo, datos_cosecha, id_usuario):
        """
        Registra una nueva cosecha para un ciclo de producción.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            id_ciclo (int): ID del ciclo de producción.
            datos_cosecha (dict): Datos de la cosecha.
            id_usuario (int): ID del usuario que registra.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validar que el ciclo existe y está listo para cosecha
            ciclo = self._validar_ciclo_listo_cosecha(id_ciclo)
            
            # Validar datos de cosecha
            self._validar_datos_cosecha_negocio(datos_cosecha, ciclo)
            
            # Preparar datos del lote
            datos_lote = self._preparar_datos_lote(datos_cosecha, id_ciclo, id_usuario, ciclo)
            
            # Crear lote de cosecha
            exito, id_lote = self.lote_repo.crear(datos_lote)
            
            if exito:
                # Actualizar estado del ciclo a 'Finalizado'
                self._finalizar_ciclo_automaticamente(id_ciclo, datos_cosecha['fecha_cosecha'])
                
                # Obtener información del lote creado
                lote_creado = self.lote_repo.obtener_por_id(id_lote)
                
                # Analizar rendimiento
                analisis_rendimiento = self._analizar_rendimiento_vs_esperado(lote_creado)
                
                resultado = {
                    'exito': True,
                    'id_lote': id_lote,
                    'codigo_lote': lote_creado['codigo_lote'],
                    'mensaje': f"Cosecha registrada exitosamente. Lote: {lote_creado['codigo_lote']}",
                    'lote_creado': lote_creado,
                    'ciclo_finalizado': True,
                    'analisis_rendimiento': analisis_rendimiento,
                    'recomendaciones': self._generar_recomendaciones_post_cosecha(lote_creado, analisis_rendimiento),
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: cosecha registrada con ID {id_lote} para ciclo {id_ciclo}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al registrar cosecha'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error de validación en registrar_cosecha: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio registrar_cosecha: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_lotes', pattern='paginado_')       # Invalidar paginación
    @cache_invalidator('servicio_lotes', pattern='disponibles_')   # Invalidar disponibles
    @cache_invalidator('estadisticas_lotes_servicio')              # Invalidar estadísticas
    def actualizar_lote(self, id_lote, datos_actualizacion):
        """
        Actualiza un lote de cosecha con validaciones de negocio.
        
        Args:
            id_lote (int): ID del lote.
            datos_actualizacion (dict): Datos a actualizar.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales
            lote_actual = self.lote_repo.obtener_por_id(id_lote)
            
            # Validar cambios críticos
            self._validar_cambios_criticos_lote(lote_actual, datos_actualizacion)
            
            # Actualizar lote
            exito = self.lote_repo.actualizar(id_lote, datos_actualizacion)
            
            if exito:
                # Evaluar impacto de cambios
                impacto = self._evaluar_impacto_cambios(lote_actual, datos_actualizacion)
                
                resultado = {
                    'exito': True,
                    'mensaje': f"Lote '{lote_actual['codigo_lote']}' actualizado exitosamente",
                    'impacto_cambios': impacto,
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: lote {id_lote} actualizado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar lote'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en actualizar_lote: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_lote: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cacheable('servicio_lotes', key_func=lambda: 'disponibles_venta', ttl=300)  # 5 min
    def obtener_lotes_disponibles_venta(self):
        """
        Obtiene lotes disponibles para venta con información enriquecida.
        ⭐ OPTIMIZADO: Cacheado frecuentemente para ventas
        
        Returns:
            list: Lista de lotes disponibles con información adicional.
        """
        try:
            lotes_disponibles = self.lote_repo.obtener_disponibles_para_venta()
            
            # Enriquecer con información para ventas
            lotes_enriquecidos = []
            for lote in lotes_disponibles:
                lote_enriquecido = lote.copy()
                
                # Información específica para ventas
                lote_enriquecido['precio_recomendado'] = self._calcular_precio_recomendado(lote)
                lote_enriquecido['urgencia_venta'] = self._evaluar_urgencia_venta(lote)
                lote_enriquecido['calidad_descripcion'] = self._obtener_descripcion_calidad(lote)
                lote_enriquecido['informacion_cultivo'] = self._preparar_info_cultivo_venta(lote)
                
                # Alertas específicas para ventas
                lote_enriquecido['alertas_venta'] = self._generar_alertas_venta(lote)
                
                lotes_enriquecidos.append(lote_enriquecido)
            
            # Ordenar por urgencia y calidad
            lotes_enriquecidos.sort(key=lambda x: (x['urgencia_venta'], -x['precio_recomendado']))
            
            logger.info(f"Lotes disponibles para venta: {len(lotes_enriquecidos)}")
            return lotes_enriquecidos
            
        except Exception as e:
            logger.error(f"Error en obtener_lotes_disponibles_venta: {str(e)}")
            return []

    @cacheable('estadisticas_lotes_servicio', key_func=lambda: 'completas_servicio', ttl=900)  # 15 min
    def obtener_estadisticas_lotes(self):
        """
        Obtiene estadísticas completas de lotes de cosecha a nivel de servicio.
        
        Returns:
            dict: Estadísticas detalladas con métricas de negocio.
        """
        try:
            # Estadísticas básicas del repositorio
            estadisticas_basicas = self.lote_repo.obtener_estadisticas()
            
            # Estadísticas enriquecidas de servicio
            estadisticas = {
                **estadisticas_basicas,
                'analisis_rendimiento': self._analizar_rendimiento_general(),
                'analisis_precios': self._analizar_precios_mercado(),
                'eficiencia_cosecha': self._calcular_eficiencia_cosecha(),
                
                # Métricas de servicio
                'metricas_servicio': {
                    'lotes_disponibles_venta': len(self.obtener_lotes_disponibles_venta()),
                    'valor_inventario': self._calcular_valor_inventario(),
                    'rendimiento_promedio_real': self._calcular_rendimiento_promedio_real(),
                    'margen_promedio': self._calcular_margen_promedio(),
                    'rotacion_inventario': self._calcular_rotacion_inventario(),
                    'timestamp': self._get_timestamp()
                }
            }
            
            logger.info(f"Estadísticas completas de lotes calculadas: {estadisticas_basicas.get('total_lotes', 0)} lotes")
            return estadisticas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_lotes: {str(e)}")
            return {}

    @cacheable('analisis_lotes', key_func=lambda id_ciclo: f"rendimiento_ciclo_{id_ciclo}", ttl=1800)  # 30 min
    def analizar_rendimiento_ciclo(self, id_ciclo):
        """
        Analiza el rendimiento de todos los lotes de un ciclo.
        
        Args:
            id_ciclo (int): ID del ciclo de producción.
            
        Returns:
            dict: Análisis completo del rendimiento del ciclo.
        """
        try:
            lotes_ciclo = self.lote_repo.obtener_por_ciclo(id_ciclo)
            ciclo = self.ciclo_repo.obtener_por_id(id_ciclo)
            
            if not lotes_ciclo:
                return {'error': 'No hay lotes registrados para este ciclo'}
            
            # Calcular métricas del ciclo
            cantidad_total = sum(l['cantidad_cosechada'] for l in lotes_ciclo)
            valor_total = sum(l['valor_total_estimado'] for l in lotes_ciclo)
            rendimiento_real = cantidad_total / ciclo['area_sembrada'] if ciclo['area_sembrada'] > 0 else 0
            
            # Obtener rendimiento esperado
            variedad = self.variedad_repo.obtener_por_id(ciclo['id_variedad'])
            rendimiento_esperado = variedad.get('rendimiento_esperado', 0)
            
            # Calcular eficiencia
            eficiencia = (rendimiento_real / rendimiento_esperado * 100) if rendimiento_esperado > 0 else 0
            
            analisis = {
                'ciclo_info': {
                    'id_ciclo': id_ciclo,
                    'area_sembrada': ciclo['area_sembrada'],
                    'nombre_cultivo': ciclo['cultivo_completo']
                },
                'rendimiento': {
                    'real': round(rendimiento_real, 2),
                    'esperado': rendimiento_esperado,
                    'eficiencia': round(eficiencia, 1),
                    'categoria': self._categorizar_eficiencia_rendimiento(eficiencia)
                },
                'produccion': {
                    'cantidad_total': cantidad_total,
                    'valor_total': valor_total,
                    'lotes_generados': len(lotes_ciclo),
                    'promedio_por_lote': round(cantidad_total / len(lotes_ciclo), 2)
                },
                'calidad': self._analizar_calidad_lotes(lotes_ciclo),
                'recomendaciones': self._generar_recomendaciones_ciclo(eficiencia, lotes_ciclo)
            }
            
            return analisis
            
        except Exception as e:
            logger.error(f"Error analizando rendimiento del ciclo {id_ciclo}: {str(e)}")
            return {'error': str(e)}

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('disponibilidad_lotes', key_func=lambda id_lote: f"disponib_{id_lote}", ttl=300)  # 5 min
    def _calcular_disponibilidad_cached(self, id_lote):
        """
        Calcula la disponibilidad de un lote (versión cacheada).
        
        Args:
            id_lote (int): ID del lote.
            
        Returns:
            dict: Información de disponibilidad.
        """
        try:
            # Obtener lote con información de ventas
            lotes_disponibles = self.lote_repo.obtener_disponibles_para_venta()
            lote_info = next((l for l in lotes_disponibles if l['id_lote'] == id_lote), None)
            
            if lote_info:
                return {
                    'disponible': True,
                    'cantidad_disponible': lote_info['cantidad_disponible'],
                    'cantidad_vendida': lote_info['cantidad_vendida'],
                    'porcentaje_disponible': round((lote_info['cantidad_disponible'] / lote_info['cantidad_cosechada']) * 100, 1)
                }
            else:
                # Buscar el lote original para verificar si existe
                lote = self.lote_repo.obtener_por_id(id_lote)
                return {
                    'disponible': False,
                    'cantidad_disponible': 0,
                    'cantidad_vendida': lote['cantidad_cosechada'],
                    'porcentaje_disponible': 0
                }
        except Exception:
            return {'disponible': False, 'cantidad_disponible': 0, 'cantidad_vendida': 0, 'porcentaje_disponible': 0}

    # ==================== MÉTODOS AUXILIARES PRIVADOS ====================
    
    def _validar_ciclo_listo_cosecha(self, id_ciclo):
        """Valida que el ciclo esté listo para cosecha."""
        try:
            ciclo = self.ciclo_repo.obtener_por_id(id_ciclo)
            
            if ciclo['estado'] not in ['En Cosecha', 'En Desarrollo']:
                raise ErrorValidacion(f"El ciclo debe estar en estado 'En Cosecha' o 'En Desarrollo'. Estado actual: '{ciclo['estado']}'")
            
            return ciclo
        except RegistroNoEncontrado:
            raise ErrorValidacion("El ciclo de producción especificado no existe")
    
    def _validar_datos_cosecha_negocio(self, datos, ciclo):
        """Valida datos de cosecha con reglas de negocio."""
        if not datos.get('cantidad_cosechada') or datos['cantidad_cosechada'] <= 0:
            raise ErrorValidacion("La cantidad cosechada debe ser mayor a 0")
        
        if not datos.get('fecha_cosecha'):
            raise ErrorValidacion("La fecha de cosecha es obligatoria")
        
        # Validar que la cantidad sea realista para el área
        rendimiento_por_ha = datos['cantidad_cosechada'] / ciclo['area_sembrada']
        if rendimiento_por_ha > 500:  # 500 ton/ha es extremadamente alto
            raise ErrorValidacion("La cantidad cosechada parece demasiado alta para el área sembrada")
    
    def _preparar_datos_lote(self, datos_cosecha, id_ciclo, id_usuario, ciclo):
        """Prepara los datos del lote con valores calculados."""
        datos_lote = datos_cosecha.copy()
        datos_lote['id_ciclo'] = id_ciclo
        datos_lote['registrado_por'] = id_usuario
        
        # Calcular precio sugerido si no se proporciona
        if not datos_lote.get('precio_unitario_sugerido'):
            datos_lote['precio_unitario_sugerido'] = self._calcular_precio_sugerido(datos_cosecha, ciclo)
        
        # Establecer unidad de medida por defecto
        if not datos_lote.get('unidad_medida'):
            datos_lote['unidad_medida'] = 'kg'
        
        return datos_lote
    
    def _finalizar_ciclo_automaticamente(self, id_ciclo, fecha_cosecha):
        """Finaliza automáticamente el ciclo al registrar cosecha."""
        try:
            self.ciclo_repo.actualizar(id_ciclo, {
                'estado': 'Finalizado',
                'fecha_cosecha_real': fecha_cosecha
            })
        except Exception as e:
            logger.warning(f"No se pudo finalizar automáticamente el ciclo {id_ciclo}: {str(e)}")
    
    def _aplicar_filtros(self, lotes, filtros):
        """Aplica filtros a la lista de lotes."""
        lotes_filtrados = lotes
        
        if filtros.get('categoria'):
            lotes_filtrados = [l for l in lotes_filtrados if l['categoria_calidad'] == filtros['categoria']]
        
        if filtros.get('fecha_desde'):
            fecha_desde = datetime.strptime(filtros['fecha_desde'], '%Y-%m-%d').date()
            lotes_filtrados = [l for l in lotes_filtrados 
                             if datetime.strptime(l['fecha_cosecha'], '%Y-%m-%d').date() >= fecha_desde]
        
        if filtros.get('fecha_hasta'):
            fecha_hasta = datetime.strptime(filtros['fecha_hasta'], '%Y-%m-%d').date()
            lotes_filtrados = [l for l in lotes_filtrados 
                             if datetime.strptime(l['fecha_cosecha'], '%Y-%m-%d').date() <= fecha_hasta]
        
        if filtros.get('disponible') is True:
            # Solo lotes disponibles para venta
            lotes_disponibles_ids = {l['id_lote'] for l in self.lote_repo.obtener_disponibles_para_venta()}
            lotes_filtrados = [l for l in lotes_filtrados if l['id_lote'] in lotes_disponibles_ids]
        
        return lotes_filtrados
    
    def _evaluar_estado_comercial(self, lote):
        """Evalúa el estado comercial del lote."""
        disponibilidad = self._calcular_disponibilidad_cached(lote['id_lote'])
        
        if disponibilidad['disponible']:
            dias_desde_cosecha = lote.get('dias_desde_cosecha', 0)
            if dias_desde_cosecha <= 7:
                return 'fresco'
            elif dias_desde_cosecha <= 30:
                return 'bueno'
            elif dias_desde_cosecha <= 90:
                return 'normal'
            else:
                return 'urgente'
        else:
            return 'vendido'
    
    def _generar_recomendacion_precio(self, lote):
        """Genera recomendación de precio basada en calidad y mercado."""
        precio_base = lote.get('precio_unitario_sugerido', 0)
        categoria = lote.get('categoria_calidad', '').lower()
        
        if 'premium' in categoria or 'primera' in categoria:
            factor = 1.2
        elif 'segunda' in categoria or 'buena' in categoria:
            factor = 1.0
        else:
            factor = 0.8
        
        precio_recomendado = precio_base * factor
        
        return {
            'precio_recomendado': round(precio_recomendado, 2),
            'factor_aplicado': factor,
            'justificacion': f"Ajuste por calidad: {categoria}"
        }
    
    def _generar_alertas_lote(self, lote):
        """Genera alertas específicas para un lote."""
        alertas = []
        
        dias_desde_cosecha = lote.get('dias_desde_cosecha', 0)
        if dias_desde_cosecha > 60:
            alertas.append("Lote con más de 60 días - considerar venta urgente")
        
        if lote.get('precio_unitario_sugerido', 0) == 0:
            alertas.append("Sin precio sugerido - definir precio de venta")
        
        disponibilidad = self._calcular_disponibilidad_cached(lote['id_lote'])
        if disponibilidad['disponible'] and disponibilidad['porcentaje_disponible'] < 20:
            alertas.append("Stock bajo - menos del 20% disponible")
        
        return alertas
    
    def _analizar_rendimiento_vs_esperado(self, lote):
        """Analiza el rendimiento real vs esperado."""
        try:
            # Obtener información del ciclo y variedad
            ciclo = self.ciclo_repo.obtener_por_id(lote['id_ciclo'])
            variedad = self.variedad_repo.obtener_por_id(ciclo['id_variedad'])
            
            rendimiento_real = lote['rendimiento_por_hectarea']
            rendimiento_esperado = variedad.get('rendimiento_esperado', 0)
            
            if rendimiento_esperado > 0:
                eficiencia = (rendimiento_real / rendimiento_esperado) * 100
                
                if eficiencia >= 110:
                    categoria = 'excelente'
                elif eficiencia >= 90:
                    categoria = 'bueno'
                elif eficiencia >= 70:
                    categoria = 'aceptable'
                else:
                    categoria = 'bajo'
                
                return {
                    'rendimiento_real': rendimiento_real,
                    'rendimiento_esperado': rendimiento_esperado,
                    'eficiencia': round(eficiencia, 1),
                    'categoria': categoria,
                    'diferencia': round(rendimiento_real - rendimiento_esperado, 2)
                }
            else:
                return {
                    'rendimiento_real': rendimiento_real,
                    'rendimiento_esperado': 0,
                    'categoria': 'sin_referencia'
                }
        except Exception:
            return {'categoria': 'error', 'rendimiento_real': lote['rendimiento_por_hectarea']}
    
    def _categorizar_rentabilidad(self, lote):
        """Categoriza la rentabilidad del lote."""
        margen = lote.get('margen_estimado', 0)
        
        if margen >= 50:
            return 'muy_alta'
        elif margen >= 30:
            return 'alta'
        elif margen >= 15:
            return 'media'
        elif margen >= 5:
            return 'baja'
        else:
            return 'muy_baja'
    
    def _calcular_estadisticas_pagina(self, lotes):
        """Calcula estadísticas de la página actual."""
        if not lotes:
            return {}
        
        return {
            'total_cantidad': sum(l['cantidad_cosechada'] for l in lotes),
            'valor_total': sum(l['valor_total_estimado'] for l in lotes),
            'rendimiento_promedio': sum(l['rendimiento_por_hectarea'] for l in lotes) / len(lotes),
            'lotes_disponibles': sum(1 for l in lotes if l['disponibilidad']['disponible']),
            'categorias_calidad': list(set(l['categoria_calidad'] for l in lotes))
        }
    
    def _calcular_precio_sugerido(self, datos_cosecha, ciclo):
        """Calcula un precio sugerido basado en costos y mercado."""
        # Precio base simple (en producción sería más complejo)
        costo_base = datos_cosecha.get('costo_produccion_unitario', 10)
        margen_objetivo = 1.3  # 30% de margen
        return round(costo_base * margen_objetivo, 2)
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        return datetime.now().isoformat()
    
    # Métodos placeholder para mantener la estructura completa
    def _validar_cambios_criticos_lote(self, lote_actual, datos_nuevos):
        pass
    
    def _evaluar_impacto_cambios(self, lote_actual, datos_nuevos):
        return 'menor'
    
    def _calcular_precio_recomendado(self, lote):
        return lote.get('precio_unitario_sugerido', 0)
    
    def _evaluar_urgencia_venta(self, lote):
        dias = lote.get('dias_desde_cosecha', 0)
        return 'alta' if dias > 60 else 'media' if dias > 30 else 'baja'
    
    def _obtener_descripcion_calidad(self, lote):
        return lote.get('categoria_calidad', 'Estándar')
    
    def _preparar_info_cultivo_venta(self, lote):
        return {
            'cultivo': lote['cultivo_completo'],
            'origen': lote['nombre_parcela'],
            'agricultor': lote['nombre_agricultor']
        }
    
    def _generar_alertas_venta(self, lote):
        return []
    
    def _analizar_rendimiento_general(self):
        return {}
    
    def _analizar_precios_mercado(self):
        return {}
    
    def _calcular_eficiencia_cosecha(self):
        return {}
    
    def _calcular_valor_inventario(self):
        return 0
    
    def _calcular_rendimiento_promedio_real(self):
        return 0
    
    def _calcular_margen_promedio(self):
        return 0
    
    def _calcular_rotacion_inventario(self):
        return 0
    
    def _categorizar_eficiencia_rendimiento(self, eficiencia):
        if eficiencia >= 90:
            return 'excelente'
        elif eficiencia >= 70:
            return 'bueno'
        else:
            return 'mejorable'
    
    def _analizar_calidad_lotes(self, lotes):
        categorias = {}
        for lote in lotes:
            cat = lote['categoria_calidad']
            if cat not in categorias:
                categorias[cat] = 0
            categorias[cat] += 1
        return categorias
    
    def _generar_recomendaciones_ciclo(self, eficiencia, lotes):
        recomendaciones = []
        if eficiencia < 70:
            recomendaciones.append("Revisar prácticas de cultivo para mejorar rendimiento")
        if len(lotes) > 5:
            recomendaciones.append("Considerar optimizar tamaño de lotes")
        return recomendaciones
    
    def _generar_recomendaciones_post_cosecha(self, lote, analisis):
        recomendaciones = []
        if analisis.get('categoria') == 'excelente':
            recomendaciones.append("Excelente rendimiento - replicar prácticas")
        elif analisis.get('categoria') == 'bajo':
            recomendaciones.append("Analizar causas del bajo rendimiento")
        
        if lote['precio_unitario_sugerido'] > 0:
            recomendaciones.append("Precio sugerido calculado automáticamente")
        
        return recomendaciones