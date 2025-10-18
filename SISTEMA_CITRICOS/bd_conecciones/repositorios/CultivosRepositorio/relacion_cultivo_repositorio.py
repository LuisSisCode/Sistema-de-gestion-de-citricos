# bd_conecciones/repositorios/relacion_cultivo_repositorio.py

import logging
from datetime import datetime, date
from ...nucleo.repositorio_base import RepositorioBase
from ...nucleo.excepciones_bd import RegistroNoEncontrado, RegistroTieneDependencias, ErrorValidacion
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class RelacionCultivoRepositorio(RepositorioBase):
    """Repositorio para consultas complejas entre entidades de cultivos con caché optimizado."""
    
    # ==================== VALIDACIONES DE DEPENDENCIAS ====================
    
    @cacheable('dependencias_cultivos', key_func=lambda id_tipo: f"tipo_{id_tipo}", ttl=1200)  # 20 min
    def verificar_dependencias_tipo_cultivo(self, id_tipo_cultivo):
        """
        Verifica todas las dependencias de un tipo de cultivo antes de eliminarlo.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            dict: Información detallada de dependencias.
            
        Raises:
            RegistroTieneDependencias: Si tiene dependencias que impiden la eliminación.
        """
        # Contar variedades asociadas
        variedades = self._contar_variedades_por_tipo(id_tipo_cultivo)
        
        # Contar ciclos de producción a través de variedades
        ciclos = self._contar_ciclos_por_tipo(id_tipo_cultivo)
        
        total_dependencias = variedades + ciclos
        
        dependencias = {
            'variedades': variedades,
            'ciclos_produccion': ciclos,
            'total_dependencias': total_dependencias,
            'puede_eliminar': total_dependencias == 0
        }
        
        if not dependencias['puede_eliminar']:
            mensaje = f"No se puede eliminar el tipo de cultivo. Tiene {variedades} variedades y {ciclos} ciclos asociados."
            raise RegistroTieneDependencias(mensaje, total_dependencias)
        
        logger.info(f"Tipo de cultivo {id_tipo_cultivo} puede ser eliminado - sin dependencias")
        return dependencias
    
    @cacheable('dependencias_cultivos', key_func=lambda id_variedad: f"variedad_{id_variedad}", ttl=1200)  # 20 min
    def verificar_dependencias_variedad(self, id_variedad):
        """
        Verifica las dependencias de una variedad antes de eliminarla.
        
        Args:
            id_variedad (int): ID de la variedad.
            
        Returns:
            dict: Información de dependencias.
            
        Raises:
            RegistroTieneDependencias: Si tiene ciclos asociados.
        """
        ciclos = self._contar_registros(
            "CiclosProduccion", 
            "id_variedad = ? AND activo = 1", 
            (id_variedad,)
        )
        
        dependencias = {
            'ciclos_produccion': ciclos,
            'puede_eliminar': ciclos == 0
        }
        
        if not dependencias['puede_eliminar']:
            mensaje = f"No se puede eliminar la variedad. Tiene {ciclos} ciclos de producción asociados."
            raise RegistroTieneDependencias(mensaje, ciclos)
        
        logger.info(f"Variedad {id_variedad} puede ser eliminada - sin dependencias")
        return dependencias
    
    # ==================== ESTADÍSTICAS Y ANÁLISIS CRUZADOS ====================
    
    @cacheable('estadisticas_cultivos', key_func=lambda *args: 'generales_completas', ttl=1800)
    def obtener_estadisticas_generales(self):
        """
        Obtiene estadísticas generales completas del sistema de cultivos.
        
        Returns:
            dict: Estadísticas completas del sistema de cultivos.
        """
        query = """
        SELECT 
            (SELECT COUNT(*) FROM TiposCultivo WHERE activo = 1) as total_tipos,
            (SELECT COUNT(*) FROM VariedadesCultivo v 
             JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo 
             WHERE v.activo = 1 AND t.activo = 1) as total_variedades,
            (SELECT COUNT(*) FROM CiclosProduccion c 
             JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
             JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
             WHERE c.activo = 1 AND v.activo = 1 AND t.activo = 1) as total_ciclos,
            (SELECT COUNT(*) FROM CiclosProduccion c 
             JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
             WHERE c.activo = 1 AND v.activo = 1 
             AND c.estado IN ('Planificado', 'En Preparación', 'Sembrado', 'En Desarrollo', 'En Cosecha')) as ciclos_activos,
            (SELECT COALESCE(SUM(area_sembrada), 0) FROM CiclosProduccion c 
             JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
             WHERE c.activo = 1 AND v.activo = 1) as area_total_sembrada,
            (SELECT COUNT(DISTINCT c.id_parcela) FROM CiclosProduccion c 
             JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
             WHERE c.activo = 1 AND v.activo = 1) as parcelas_con_cultivos
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        estadisticas = {
            'tipos_cultivo': {
                'total': row.total_tipos,
                'promedio_variedades_por_tipo': round(row.total_variedades / row.total_tipos, 1) if row.total_tipos > 0 else 0
            },
            'variedades': {
                'total': row.total_variedades,
                'promedio_ciclos_por_variedad': round(row.total_ciclos / row.total_variedades, 1) if row.total_variedades > 0 else 0
            },
            'ciclos_produccion': {
                'total': row.total_ciclos,
                'activos': row.ciclos_activos,
                'finalizados_cancelados': row.total_ciclos - row.ciclos_activos,
                'porcentaje_activos': round((row.ciclos_activos / row.total_ciclos * 100), 1) if row.total_ciclos > 0 else 0
            },
            'area_produccion': {
                'total_sembrada': float(row.area_total_sembrada),
                'parcelas_involucradas': row.parcelas_con_cultivos,
                'area_promedio_por_ciclo': float(row.area_total_sembrada / row.total_ciclos) if row.total_ciclos > 0 else 0
            }
        }
        
        logger.info(f"Estadísticas generales de cultivos calculadas: {estadisticas}")
        return estadisticas
    
    @cacheable('rankings_cultivos', key_func=lambda limite=10: f'tipos_mas_utilizados_{limite}', ttl=1800)  # 30 min
    def obtener_tipos_cultivo_mas_utilizados(self, limite=10):
        """
        Obtiene los tipos de cultivo más utilizados basado en ciclos de producción.
        
        Args:
            limite (int): Número máximo de tipos a retornar.
            
        Returns:
            list: Lista de tipos ordenados por uso.
        """
        query = """
        SELECT TOP (?)
            t.id_tipo_cultivo,
            t.nombre,
            t.nombre_cientifico,
            COUNT(DISTINCT v.id_variedad) as total_variedades,
            COUNT(c.id_ciclo) as total_ciclos,
            COALESCE(SUM(c.area_sembrada), 0) as area_total,
            COUNT(DISTINCT c.id_parcela) as parcelas_utilizadas,
            COUNT(CASE WHEN c.estado IN ('Planificado', 'En Preparación', 'Sembrado', 'En Desarrollo', 'En Cosecha') THEN 1 END) as ciclos_activos
        FROM TiposCultivo t
        JOIN VariedadesCultivo v ON t.id_tipo_cultivo = v.id_tipo_cultivo
        JOIN CiclosProduccion c ON v.id_variedad = c.id_variedad
        WHERE t.activo = 1 AND v.activo = 1 AND c.activo = 1
        GROUP BY t.id_tipo_cultivo, t.nombre, t.nombre_cientifico
        ORDER BY total_ciclos DESC, area_total DESC
        """
        
        rows = self._ejecutar_consulta(query, (limite,))
        tipos_populares = []
        
        for i, row in enumerate(rows, 1):
            tipo = {
                'ranking': i,
                'id_tipo_cultivo': row.id_tipo_cultivo,
                'nombre': row.nombre,
                'nombre_cientifico': row.nombre_cientifico,
                'total_variedades': row.total_variedades,
                'total_ciclos': row.total_ciclos,
                'area_total': float(row.area_total),
                'parcelas_utilizadas': row.parcelas_utilizadas,
                'ciclos_activos': row.ciclos_activos,
                'eficiencia': round(float(row.area_total) / row.total_ciclos, 2) if row.total_ciclos > 0 else 0
            }
            tipos_populares.append(tipo)
        
        logger.info(f"Top {len(tipos_populares)} tipos de cultivo más utilizados")
        return tipos_populares
    
    @cacheable('rankings_cultivos', key_func=lambda limite=10: f'variedades_mejor_rendimiento_{limite}', ttl=1800)  # 30 min
    def obtener_variedades_mejor_rendimiento(self, limite=10):
        """
        Obtiene las variedades con mejor rendimiento esperado.
        
        Args:
            limite (int): Número máximo de variedades a retornar.
            
        Returns:
            list: Lista de variedades ordenadas por rendimiento.
        """
        query = """
        SELECT TOP (?)
            v.id_variedad,
            v.nombre as nombre_variedad,
            v.rendimiento_esperado,
            v.tiempo_produccion,
            t.nombre as nombre_tipo_cultivo,
            COUNT(c.id_ciclo) as total_ciclos,
            COALESCE(SUM(c.area_sembrada), 0) as area_total,
            COUNT(CASE WHEN c.estado = 'Finalizado' THEN 1 END) as ciclos_finalizados
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        LEFT JOIN CiclosProduccion c ON v.id_variedad = c.id_variedad AND c.activo = 1
        WHERE v.activo = 1 AND t.activo = 1 AND v.rendimiento_esperado IS NOT NULL
        GROUP BY v.id_variedad, v.nombre, v.rendimiento_esperado, v.tiempo_produccion, t.nombre
        ORDER BY v.rendimiento_esperado DESC, total_ciclos DESC
        """
        
        rows = self._ejecutar_consulta(query, (limite,))
        variedades_top = []
        
        for i, row in enumerate(rows, 1):
            variedad = {
                'ranking': i,
                'id_variedad': row.id_variedad,
                'nombre_variedad': row.nombre_variedad,
                'nombre_tipo_cultivo': row.nombre_tipo_cultivo,
                'nombre_completo': f"{row.nombre_tipo_cultivo} - {row.nombre_variedad}",
                'rendimiento_esperado': float(row.rendimiento_esperado),
                'tiempo_produccion': row.tiempo_produccion,
                'total_ciclos': row.total_ciclos,
                'area_total': float(row.area_total),
                'ciclos_finalizados': row.ciclos_finalizados,
                'popularidad': 'alta' if row.total_ciclos >= 5 else 'media' if row.total_ciclos >= 2 else 'baja'
            }
            variedades_top.append(variedad)
        
        logger.info(f"Top {len(variedades_top)} variedades por rendimiento")
        return variedades_top
    
    @cacheable('analisis_cultivos', key_func=lambda *args: 'productividad_por_propietario', ttl=2400)  # 40 min
    def obtener_productividad_por_propietario(self):
        """
        Obtiene análisis de productividad de cultivos por propietario.
        
        Returns:
            list: Lista de propietarios con métricas de cultivos.
        """
        query = """
        SELECT 
            a.id_agricultor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            COUNT(DISTINCT c.id_ciclo) as total_ciclos,
            COUNT(DISTINCT c.id_variedad) as variedades_utilizadas,
            COUNT(DISTINCT t.id_tipo_cultivo) as tipos_cultivados,
            COALESCE(SUM(c.area_sembrada), 0) as area_total_sembrada,
            COUNT(CASE WHEN c.estado = 'Finalizado' THEN 1 END) as ciclos_completados,
            COUNT(CASE WHEN c.estado IN ('Planificado', 'En Preparación', 'Sembrado', 'En Desarrollo', 'En Cosecha') THEN 1 END) as ciclos_activos,
            AVG(v.rendimiento_esperado) as rendimiento_promedio_esperado
        FROM Agricultores a
        JOIN Parcelas p ON a.id_agricultor = p.id_agricultor
        JOIN CiclosProduccion c ON p.id_parcela = c.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE a.activo = 1 AND p.activo = 1 AND c.activo = 1 AND v.activo = 1 AND t.activo = 1
        GROUP BY a.id_agricultor, a.nombre, a.apellido
        ORDER BY area_total_sembrada DESC, total_ciclos DESC
        """
        
        rows = self._ejecutar_consulta(query)
        productividad = []
        
        for row in rows:
            propietario = {
                'id_agricultor': row.id_agricultor,
                'nombre_propietario': row.nombre_propietario,
                'total_ciclos': row.total_ciclos,
                'variedades_utilizadas': row.variedades_utilizadas,
                'tipos_cultivados': row.tipos_cultivados,
                'area_total_sembrada': float(row.area_total_sembrada),
                'ciclos_completados': row.ciclos_completados,
                'ciclos_activos': row.ciclos_activos,
                'rendimiento_promedio_esperado': float(row.rendimiento_promedio_esperado) if row.rendimiento_promedio_esperado else 0,
                
                # Métricas calculadas
                'tasa_completacion': round((row.ciclos_completados / row.total_ciclos * 100), 1) if row.total_ciclos > 0 else 0,
                'diversidad_cultivos': round((row.tipos_cultivados / row.total_ciclos), 2) if row.total_ciclos > 0 else 0,
                'area_promedio_por_ciclo': round(float(row.area_total_sembrada) / row.total_ciclos, 2) if row.total_ciclos > 0 else 0,
                'categoria_productor': self._categorizar_productor(row.total_ciclos, float(row.area_total_sembrada))
            }
            productividad.append(propietario)
        
        logger.info(f"Análisis de productividad para {len(productividad)} propietarios")
        return productividad
    
    @cacheable('analisis_cultivos', key_func=lambda: 'estacionalidad_siembras', ttl=3600)  # 1 hora
    def obtener_analisis_estacionalidad(self):
        """
        Obtiene análisis de estacionalidad de siembras por mes.
        
        Returns:
            dict: Distribución de siembras por mes y tipo de cultivo.
        """
        query = """
        SELECT 
            MONTH(c.fecha_siembra) as mes,
            DATENAME(MONTH, c.fecha_siembra) as nombre_mes,
            t.nombre as tipo_cultivo,
            COUNT(c.id_ciclo) as total_siembras,
            COALESCE(SUM(c.area_sembrada), 0) as area_sembrada
        FROM CiclosProduccion c
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE c.activo = 1 AND v.activo = 1 AND t.activo = 1 
        AND c.fecha_siembra IS NOT NULL
        GROUP BY MONTH(c.fecha_siembra), DATENAME(MONTH, c.fecha_siembra), t.nombre
        ORDER BY mes, total_siembras DESC
        """
        
        rows = self._ejecutar_consulta(query)
        
        # Organizar datos por mes
        estacionalidad = {}
        for row in rows:
            mes = row.mes
            if mes not in estacionalidad:
                estacionalidad[mes] = {
                    'mes_numero': mes,
                    'nombre_mes': row.nombre_mes,
                    'total_siembras': 0,
                    'area_total': 0,
                    'tipos_cultivo': []
                }
            
            estacionalidad[mes]['total_siembras'] += row.total_siembras
            estacionalidad[mes]['area_total'] += float(row.area_sembrada)
            estacionalidad[mes]['tipos_cultivo'].append({
                'tipo': row.tipo_cultivo,
                'siembras': row.total_siembras,
                'area': float(row.area_sembrada)
            })
        
        # Convertir a lista ordenada
        resultado = {
            'por_mes': list(estacionalidad.values()),
            'mes_mas_activo': max(estacionalidad.values(), key=lambda x: x['total_siembras'])['nombre_mes'] if estacionalidad else None,
            'mes_mayor_area': max(estacionalidad.values(), key=lambda x: x['area_total'])['nombre_mes'] if estacionalidad else None
        }
        
        logger.info(f"Análisis de estacionalidad calculado para {len(estacionalidad)} meses")
        return resultado
    
    # ==================== MÉTRICAS AVANZADAS ====================
    
    @cacheable('metricas_cultivos', key_func=lambda *args: 'eficiencia_ciclos', ttl=1800)  # 30 min
    def obtener_metricas_eficiencia(self):
        """
        Obtiene métricas de eficiencia de ciclos de producción.
        
        Returns:
            dict: Métricas de eficiencia del sistema.
        """
        query = """
        SELECT 
            COUNT(*) as total_ciclos,
            COUNT(CASE WHEN estado = 'Finalizado' THEN 1 END) as ciclos_finalizados,
            COUNT(CASE WHEN estado = 'Cancelado' THEN 1 END) as ciclos_cancelados,
            AVG(CASE WHEN fecha_cosecha_real IS NOT NULL AND fecha_siembra IS NOT NULL 
                THEN DATEDIFF(DAY, fecha_siembra, fecha_cosecha_real) END) as duracion_promedio_real,
            AVG(CASE WHEN fecha_cosecha_estimada IS NOT NULL AND fecha_siembra IS NOT NULL 
                THEN DATEDIFF(DAY, fecha_siembra, fecha_cosecha_estimada) END) as duracion_promedio_estimada,
            AVG(area_sembrada) as area_promedio_por_ciclo
        FROM CiclosProduccion c
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        WHERE c.activo = 1 AND v.activo = 1
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        # Calcular métricas de rendimiento por estado
        rendimiento_query = """
        SELECT 
            estado,
            COUNT(*) as cantidad,
            AVG(area_sembrada) as area_promedio,
            SUM(area_sembrada) as area_total
        FROM CiclosProduccion c
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        WHERE c.activo = 1 AND v.activo = 1
        GROUP BY estado
        ORDER BY 
            CASE estado 
                WHEN 'Planificado' THEN 1
                WHEN 'En Preparación' THEN 2
                WHEN 'Sembrado' THEN 3
                WHEN 'En Desarrollo' THEN 4
                WHEN 'En Cosecha' THEN 5
                WHEN 'Finalizado' THEN 6
                WHEN 'Cancelado' THEN 7
            END
        """
        
        rendimiento_rows = self._ejecutar_consulta(rendimiento_query)
        distribucion_estados = {}
        for r in rendimiento_rows:
            distribucion_estados[r.estado] = {
                'cantidad': r.cantidad,
                'area_promedio': float(r.area_promedio),
                'area_total': float(r.area_total)
            }
        
        metricas = {
            'eficiencia_general': {
                'total_ciclos': row.total_ciclos,
                'tasa_finalizacion': round((row.ciclos_finalizados / row.total_ciclos * 100), 1) if row.total_ciclos > 0 else 0,
                'tasa_cancelacion': round((row.ciclos_cancelados / row.total_ciclos * 100), 1) if row.total_ciclos > 0 else 0,
                'tasa_exito': round(((row.total_ciclos - row.ciclos_cancelados) / row.total_ciclos * 100), 1) if row.total_ciclos > 0 else 0
            },
            'tiempos': {
                'duracion_promedio_real': float(row.duracion_promedio_real) if row.duracion_promedio_real else None,
                'duracion_promedio_estimada': float(row.duracion_promedio_estimada) if row.duracion_promedio_estimada else None,
                'precision_estimacion': None  # Se calcula si hay ambos datos
            },
            'areas': {
                'area_promedio_por_ciclo': float(row.area_promedio_por_ciclo) if row.area_promedio_por_ciclo else 0
            },
            'distribucion_estados': distribucion_estados
        }
        
        # Calcular precisión de estimación si hay datos
        if metricas['tiempos']['duracion_promedio_real'] and metricas['tiempos']['duracion_promedio_estimada']:
            diferencia = abs(metricas['tiempos']['duracion_promedio_real'] - metricas['tiempos']['duracion_promedio_estimada'])
            precision = max(0, 100 - (diferencia / metricas['tiempos']['duracion_promedio_estimada'] * 100))
            metricas['tiempos']['precision_estimacion'] = round(precision, 1)
        
        logger.info(f"Métricas de eficiencia calculadas: {metricas['eficiencia_general']['tasa_exito']}% éxito")
        return metricas
    
    @cacheable('dashboard_cultivos', key_func=lambda *args: 'resumen_completo', ttl=900)  # 15 min
    def obtener_resumen_dashboard(self):
        """
        Obtiene resumen completo para dashboard de cultivos.
        
        Returns:
            dict: Resumen completo del sistema de cultivos.
        """
        try:
            # Combinar todas las métricas importantes
            estadisticas = self.obtener_estadisticas_generales()
            top_tipos = self.obtener_tipos_cultivo_mas_utilizados(5)
            top_variedades = self.obtener_variedades_mejor_rendimiento(5)
            metricas_eficiencia = self.obtener_metricas_eficiencia()
            
            # Obtener alertas del sistema
            alertas = self._generar_alertas_sistema()
            
            resumen = {
                'estadisticas_generales': estadisticas,
                'top_tipos_cultivo': top_tipos,
                'top_variedades': top_variedades,
                'eficiencia': metricas_eficiencia,
                'alertas': alertas,
                'timestamp': self._get_timestamp(),
                
                # Métricas de dashboard
                'kpis_principales': {
                    'tipos_activos': estadisticas['tipos_cultivo']['total'],
                    'ciclos_en_proceso': estadisticas['ciclos_produccion']['activos'],
                    'area_total_cultivo': estadisticas['area_produccion']['total_sembrada'],
                    'tasa_exito': metricas_eficiencia['eficiencia_general']['tasa_exito'],
                    'parcelas_productivas': estadisticas['area_produccion']['parcelas_involucradas']
                }
            }
            
            logger.info("Resumen de dashboard de cultivos generado exitosamente")
            return resumen
            
        except Exception as e:
            logger.error(f"Error generando resumen de dashboard: {str(e)}")
            return {
                'error': 'Error al generar resumen',
                'estadisticas_generales': {},
                'alertas': ['Error al cargar datos de cultivos']
            }
    
    # ==================== CONSULTAS DE BÚSQUEDA COMBINADAS ====================
    
    @cacheable('busquedas_cultivos', key_func=lambda texto: f"busqueda_global_{texto.lower().replace(' ', '_')}", ttl=600)  # 10 min
    def buscar_en_todo_sistema_cultivos(self, texto_busqueda):
        """
        Busca en todo el sistema de cultivos (tipos, variedades, ciclos).
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            dict: Resultados organizados por entidad.
        """
        patron = f"%{texto_busqueda}%"
        
        # Buscar en tipos de cultivo
        tipos_query = """
        SELECT 'tipo' as entidad, id_tipo_cultivo as id, nombre, 
               nombre_cientifico as descripcion, NULL as info_adicional
        FROM TiposCultivo
        WHERE activo = 1 AND (nombre LIKE ? OR nombre_cientifico LIKE ? OR descripcion LIKE ?)
        """
        
        # Buscar en variedades
        variedades_query = """
        SELECT 'variedad' as entidad, v.id_variedad as id, v.nombre,
               t.nombre as descripcion, 
               CONCAT('Rendimiento: ', ISNULL(CAST(v.rendimiento_esperado AS VARCHAR), 'N/A'), ' ton/ha') as info_adicional
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE v.activo = 1 AND t.activo = 1 
        AND (v.nombre LIKE ? OR t.nombre LIKE ? OR v.resistencia_zona LIKE ?)
        """
        
        # Buscar en ciclos (por parcela o estado)
        ciclos_query = """
        SELECT 'ciclo' as entidad, c.id_ciclo as id, 
               CONCAT(t.nombre, ' - ', v.nombre) as nombre,
               CONCAT('Parcela: ', p.nombre) as descripcion,
               CONCAT('Estado: ', c.estado, ' | Área: ', c.area_sembrada, ' ha') as info_adicional
        FROM CiclosProduccion c
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        WHERE c.activo = 1 AND v.activo = 1 AND t.activo = 1 AND p.activo = 1
        AND (p.nombre LIKE ? OR c.estado LIKE ? OR t.nombre LIKE ?)
        """
        
        # Ejecutar búsquedas
        tipos_results = self._ejecutar_consulta(tipos_query, (patron, patron, patron))
        variedades_results = self._ejecutar_consulta(variedades_query, (patron, patron, patron))
        ciclos_results = self._ejecutar_consulta(ciclos_query, (patron, patron, patron))
        
        # Organizar resultados
        resultados = {
            'tipos_cultivo': [self._construir_resultado_busqueda(row) for row in tipos_results],
            'variedades': [self._construir_resultado_busqueda(row) for row in variedades_results],
            'ciclos_produccion': [self._construir_resultado_busqueda(row) for row in ciclos_results],
            'total_resultados': len(tipos_results) + len(variedades_results) + len(ciclos_results),
            'termino_busqueda': texto_busqueda
        }
        
        logger.info(f"Búsqueda global '{texto_busqueda}': {resultados['total_resultados']} resultados")
        return resultados
    
    # ==================== MÉTODOS AUXILIARES ====================
    
    def _contar_variedades_por_tipo(self, id_tipo_cultivo):
        """Cuenta variedades activas de un tipo de cultivo."""
        return self._contar_registros(
            "VariedadesCultivo", 
            "id_tipo_cultivo = ? AND activo = 1", 
            (id_tipo_cultivo,)
        )
    
    def _contar_ciclos_por_tipo(self, id_tipo_cultivo):
        """Cuenta ciclos de producción activos de un tipo de cultivo."""
        query = """
        SELECT COUNT(*)
        FROM CiclosProduccion c
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        WHERE v.id_tipo_cultivo = ? AND c.activo = 1 AND v.activo = 1
        """
        return self._ejecutar_consulta_escalar(query, (id_tipo_cultivo,))
    
    def _categorizar_productor(self, total_ciclos, area_total):
        """Categoriza un productor según su actividad."""
        if total_ciclos >= 10 and area_total >= 50:
            return 'gran_productor'
        elif total_ciclos >= 5 and area_total >= 20:
            return 'productor_medio'
        elif total_ciclos >= 2 and area_total >= 5:
            return 'pequeño_productor'
        else:
            return 'productor_inicial'
    
    def _generar_alertas_sistema(self):
        """Genera alertas basadas en el estado del sistema de cultivos."""
        alertas = []
        
        try:
            # Verificar tipos sin variedades
            tipos_sin_variedades = self._ejecutar_consulta_escalar("""
                SELECT COUNT(*)
                FROM TiposCultivo t
                LEFT JOIN VariedadesCultivo v ON t.id_tipo_cultivo = v.id_tipo_cultivo AND v.activo = 1
                WHERE t.activo = 1 AND v.id_variedad IS NULL
            """)
            
            if tipos_sin_variedades > 0:
                alertas.append(f"{tipos_sin_variedades} tipos de cultivo sin variedades registradas")
            
            # Verificar variedades sin ciclos
            variedades_sin_uso = self._ejecutar_consulta_escalar("""
                SELECT COUNT(*)
                FROM VariedadesCultivo v
                JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
                LEFT JOIN CiclosProduccion c ON v.id_variedad = c.id_variedad AND c.activo = 1
                WHERE v.activo = 1 AND t.activo = 1 AND c.id_ciclo IS NULL
            """)
            
            if variedades_sin_uso > 5:
                alertas.append(f"{variedades_sin_uso} variedades sin usar en ciclos de producción")
            
            # Verificar ciclos en riesgo (muy antiguos sin finalizar)
            ciclos_retrasados = self._ejecutar_consulta_escalar("""
                SELECT COUNT(*)
                FROM CiclosProduccion c
                WHERE c.activo = 1 
                AND c.estado IN ('Sembrado', 'En Desarrollo', 'En Cosecha')
                AND DATEDIFF(DAY, c.fecha_siembra, GETDATE()) > 365
            """)
            
            if ciclos_retrasados > 0:
                alertas.append(f"{ciclos_retrasados} ciclos con más de 1 año sin finalizar")
                
        except Exception as e:
            logger.error(f"Error generando alertas: {str(e)}")
            alertas.append("Error al verificar estado del sistema")
        
        return alertas
    
    def _construir_resultado_busqueda(self, row):
        """Construye un resultado de búsqueda unificado."""
        return {
            'entidad': row.entidad,
            'id': row.id,
            'nombre': row.nombre or '',
            'descripcion': row.descripcion or '',
            'info_adicional': row.info_adicional or ''
        }
    
    # Metodos nuevos implementados
    @cacheable('rentabilidad_cultivos', key_func=lambda id_ciclo: f"rentabilidad_ciclo_{id_ciclo}", ttl=1800)
    def obtener_rentabilidad_por_ciclo(self, id_ciclo):
        """Obtiene análisis de rentabilidad de un ciclo específico."""
        query = """
        SELECT 
            c.id_ciclo,
            c.area_sembrada,
            c.fecha_siembra,
            c.fecha_cosecha_real,
            v.nombre as variedad,
            t.nombre as tipo_cultivo,
            p.nombre as parcela,
            
            -- Datos de cosecha
            COALESCE(SUM(l.cantidad_cosechada), 0) as cantidad_cosechada,
            COALESCE(AVG(l.rendimiento_por_hectarea), 0) as rendimiento_promedio,
            
            -- Ingresos (desde ventas)
            COALESCE(SUM(dv.cantidad * dv.precio_unitario), 0) as ingresos_total,
            COALESCE(AVG(dv.precio_unitario), 0) as precio_promedio,
            
            -- Costos estimados
            COALESCE(SUM(cp.costo_total), 0) as costos_produccion,
            
            -- ROI calculado
            CASE 
                WHEN SUM(cp.costo_total) > 0 THEN
                    ((SUM(dv.cantidad * dv.precio_unitario) - SUM(cp.costo_total)) / SUM(cp.costo_total)) * 100
                ELSE 0
            END as roi_porcentaje
            
        FROM CiclosProduccion c
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        LEFT JOIN LotesCosecha l ON c.id_ciclo = l.id_ciclo AND l.activo = 1
        LEFT JOIN DetallesVenta dv ON l.id_lote = dv.id_lote
        LEFT JOIN CostosProduccion cp ON c.id_ciclo = cp.id_ciclo
        
        WHERE c.id_ciclo = ? AND c.activo = 1 AND c.estado = 'Finalizado'
        GROUP BY c.id_ciclo, c.area_sembrada, c.fecha_siembra, c.fecha_cosecha_real,
                v.nombre, t.nombre, p.nombre
        """
        
        rows = self._ejecutar_consulta(query, (id_ciclo,))
        if not rows:
            return None
        
        row = rows[0]
        return {
            'id_ciclo': row.id_ciclo,
            'cultivo_completo': f"{row.tipo_cultivo} - {row.variedad}",
            'parcela': row.parcela,
            'area_sembrada': float(row.area_sembrada),
            'cantidad_cosechada': float(row.cantidad_cosechada),
            'rendimiento_promedio': float(row.rendimiento_promedio),
            'ingresos_total': float(row.ingresos_total),
            'costos_total': float(row.costos_produccion),
            'ganancia_neta': float(row.ingresos_total) - float(row.costos_produccion),
            'roi_porcentaje': float(row.roi_porcentaje),
            'precio_promedio': float(row.precio_promedio),
            'duracion_dias': (row.fecha_cosecha_real - row.fecha_siembra).days if row.fecha_cosecha_real and row.fecha_siembra else 0,
            'rentabilidad_por_hectarea': (float(row.ingresos_total) - float(row.costos_produccion)) / float(row.area_sembrada) if row.area_sembrada > 0 else 0
        }

    @cacheable('rentabilidad_cultivos', key_func=lambda: 'comparativo_variedades', ttl=1800)  
    def comparar_rentabilidad_variedades(self):
        """Compara rentabilidad entre diferentes variedades."""
        query = """
        SELECT 
            t.nombre as tipo_cultivo,
            v.nombre as variedad,
            COUNT(c.id_ciclo) as total_ciclos,
            AVG(c.area_sembrada) as area_promedio,
            
            -- Promedios de rendimiento
            AVG(l.rendimiento_por_hectarea) as rendimiento_promedio,
            
            -- Análisis financiero
            AVG(dv.precio_unitario) as precio_promedio,
            SUM(dv.cantidad * dv.precio_unitario) / COUNT(c.id_ciclo) as ingreso_promedio_ciclo,
            SUM(cp.costo_total) / COUNT(c.id_ciclo) as costo_promedio_ciclo,
            
            -- ROI promedio
            AVG(
                CASE 
                    WHEN cp.costo_total > 0 THEN
                        ((dv.cantidad * dv.precio_unitario - cp.costo_total) / cp.costo_total) * 100
                    ELSE 0
                END
            ) as roi_promedio
            
        FROM CiclosProduccion c
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN LotesCosecha l ON c.id_ciclo = l.id_ciclo AND l.activo = 1
        JOIN DetallesVenta dv ON l.id_lote = dv.id_lote
        LEFT JOIN CostosProduccion cp ON c.id_ciclo = cp.id_ciclo
        
        WHERE c.activo = 1 AND c.estado = 'Finalizado'
        GROUP BY t.nombre, v.nombre
        HAVING COUNT(c.id_ciclo) >= 1
        ORDER BY roi_promedio DESC
        """
        
        rows = self._ejecutar_consulta(query)
        comparativo = []
        
        for i, row in enumerate(rows, 1):
            comparativo.append({
                'ranking': i,
                'tipo_cultivo': row.tipo_cultivo,
                'variedad': row.variedad,
                'cultivo_completo': f"{row.tipo_cultivo} - {row.variedad}",
                'total_ciclos': row.total_ciclos,
                'area_promedio': round(float(row.area_promedio), 2),
                'rendimiento_promedio': round(float(row.rendimiento_promedio), 2),
                'precio_promedio': round(float(row.precio_promedio), 2),
                'ingreso_promedio_ciclo': round(float(row.ingreso_promedio_ciclo), 2),
                'costo_promedio_ciclo': round(float(row.costo_promedio_ciclo), 2),
                'roi_promedio': round(float(row.roi_promedio), 1),
                'categoria_rentabilidad': self._categorizar_roi(float(row.roi_promedio))
            })
        
        return comparativo

    @cacheable('rentabilidad_cultivos', key_func=lambda: 'comparativo_parcelas', ttl=1800)
    def analizar_performance_parcelas(self):
        """Analiza performance de rentabilidad por parcelas."""
        query = """
        SELECT 
            p.nombre as parcela,
            p.area_total,
            COUNT(DISTINCT c.id_ciclo) as total_ciclos,
            COUNT(DISTINCT v.id_variedad) as variedades_utilizadas,
            
            -- Utilización de área
            AVG(c.area_sembrada) as area_promedio_ciclo,
            SUM(c.area_sembrada) / COUNT(c.id_ciclo) as utilizacion_promedio,
            
            -- Performance financiera
            AVG(
                CASE 
                    WHEN cp.costo_total > 0 THEN
                        ((dv.cantidad * dv.precio_unitario - cp.costo_total) / cp.costo_total) * 100
                    ELSE 0
                END
            ) as roi_promedio,
            
            AVG(l.rendimiento_por_hectarea) as rendimiento_promedio,
            SUM(dv.cantidad * dv.precio_unitario) / COUNT(c.id_ciclo) as ingreso_promedio_ciclo
            
        FROM Parcelas p
        JOIN CiclosProduccion c ON p.id_parcela = c.id_parcela AND c.activo = 1 AND c.estado = 'Finalizado'
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN LotesCosecha l ON c.id_ciclo = l.id_ciclo AND l.activo = 1
        JOIN DetallesVenta dv ON l.id_lote = dv.id_lote
        LEFT JOIN CostosProduccion cp ON c.id_ciclo = cp.id_ciclo
        
        WHERE p.activo = 1
        GROUP BY p.id_parcela, p.nombre, p.area_total
        HAVING COUNT(c.id_ciclo) >= 1
        ORDER BY roi_promedio DESC
        """
        
        rows = self._ejecutar_consulta(query)
        analisis = []
        
        for i, row in enumerate(rows, 1):
            utilizacion_porcentaje = (float(row.utilizacion_promedio) / float(row.area_total)) * 100 if row.area_total > 0 else 0
            
            analisis.append({
                'ranking': i,
                'parcela': row.parcela,
                'area_total': float(row.area_total),
                'total_ciclos': row.total_ciclos,
                'variedades_utilizadas': row.variedades_utilizadas,
                'area_promedio_ciclo': round(float(row.area_promedio_ciclo), 2),
                'utilizacion_porcentaje': round(utilizacion_porcentaje, 1),
                'roi_promedio': round(float(row.roi_promedio), 1),
                'rendimiento_promedio': round(float(row.rendimiento_promedio), 2),
                'ingreso_promedio_ciclo': round(float(row.ingreso_promedio_ciclo), 2),
                'eficiencia_parcela': self._categorizar_eficiencia_parcela(float(row.roi_promedio), utilizacion_porcentaje),
                'diversidad_cultivos': row.variedades_utilizadas
            })
        
        return analisis

    @cacheable('rentabilidad_cultivos', key_func=lambda: 'ranking_rentabilidad', ttl=1800)
    def obtener_ranking_rentabilidad_completo(self):
        """Obtiene ranking completo de rentabilidad por combinación variedad-parcela."""
        query = """
        SELECT 
            t.nombre as tipo_cultivo,
            v.nombre as variedad,
            p.nombre as parcela,
            COUNT(c.id_ciclo) as total_ciclos,
            
            -- Métricas promedio
            AVG(c.area_sembrada) as area_promedio,
            AVG(l.rendimiento_por_hectarea) as rendimiento_promedio,
            AVG(dv.precio_unitario) as precio_promedio,
            
            -- ROI promedio para esta combinación
            AVG(
                CASE 
                    WHEN cp.costo_total > 0 THEN
                        ((dv.cantidad * dv.precio_unitario - cp.costo_total) / cp.costo_total) * 100
                    ELSE 0
                END
            ) as roi_promedio,
            
            -- Mejor y peor ciclo
            MAX(
                CASE 
                    WHEN cp.costo_total > 0 THEN
                        ((dv.cantidad * dv.precio_unitario - cp.costo_total) / cp.costo_total) * 100
                    ELSE 0
                END
            ) as mejor_roi,
            
            MIN(
                CASE 
                    WHEN cp.costo_total > 0 THEN
                        ((dv.cantidad * dv.precio_unitario - cp.costo_total) / cp.costo_total) * 100
                    ELSE 0
                END
            ) as peor_roi
            
        FROM CiclosProduccion c
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN LotesCosecha l ON c.id_ciclo = l.id_ciclo AND l.activo = 1
        JOIN DetallesVenta dv ON l.id_lote = dv.id_lote
        LEFT JOIN CostosProduccion cp ON c.id_ciclo = cp.id_ciclo
        
        WHERE c.activo = 1 AND c.estado = 'Finalizado' AND p.activo = 1 AND v.activo = 1 AND t.activo = 1
        GROUP BY t.nombre, v.nombre, p.nombre
        HAVING COUNT(c.id_ciclo) >= 1
        ORDER BY roi_promedio DESC
        """
        
        rows = self._ejecutar_consulta(query)
        ranking = []
        
        for i, row in enumerate(rows, 1):
            consistencia = abs(float(row.mejor_roi) - float(row.peor_roi)) if row.mejor_roi and row.peor_roi else 0
            
            ranking.append({
                'ranking': i,
                'combinacion': f"{row.tipo_cultivo} - {row.variedad} en {row.parcela}",
                'tipo_cultivo': row.tipo_cultivo,
                'variedad': row.variedad,
                'parcela': row.parcela,
                'total_ciclos': row.total_ciclos,
                'area_promedio': round(float(row.area_promedio), 2),
                'rendimiento_promedio': round(float(row.rendimiento_promedio), 2),
                'precio_promedio': round(float(row.precio_promedio), 2),
                'roi_promedio': round(float(row.roi_promedio), 1),
                'mejor_roi': round(float(row.mejor_roi), 1) if row.mejor_roi else 0,
                'peor_roi': round(float(row.peor_roi), 1) if row.peor_roi else 0,
                'consistencia': round(consistencia, 1),
                'categoria_rentabilidad': self._categorizar_roi(float(row.roi_promedio)),
                'recomendacion': self._generar_recomendacion_combinacion(float(row.roi_promedio), row.total_ciclos, consistencia)
            })
        
        return ranking

    # Métodos auxiliares para rentabilidad
    def _categorizar_roi(self, roi):
        """Categoriza el ROI según rangos."""
        if roi >= 100:
            return 'excelente'
        elif roi >= 50:
            return 'muy_bueno'
        elif roi >= 25:
            return 'bueno'
        elif roi >= 10:
            return 'aceptable'
        elif roi >= 0:
            return 'marginal'
        else:
            return 'perdida'

    def _categorizar_eficiencia_parcela(self, roi, utilizacion):
        """Categoriza la eficiencia de una parcela."""
        if roi >= 50 and utilizacion >= 60:
            return 'alta_eficiencia'
        elif roi >= 25 and utilizacion >= 40:
            return 'eficiencia_media'
        elif roi >= 10:
            return 'eficiencia_baja'
        else:
            return 'requiere_mejora'

    def _generar_recomendacion_combinacion(self, roi, ciclos, consistencia):
        """Genera recomendación para una combinación específica."""
        if roi >= 50 and ciclos >= 3 and consistencia <= 20:
            return 'Replicar - Combinación muy exitosa y consistente'
        elif roi >= 25 and ciclos >= 2:
            return 'Expandir - Buen potencial de rentabilidad'
        elif roi >= 10:
            return 'Optimizar - Revisar prácticas para mejorar ROI'
        else:
            return 'Evaluar - Considerar cambio de estrategia'
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()