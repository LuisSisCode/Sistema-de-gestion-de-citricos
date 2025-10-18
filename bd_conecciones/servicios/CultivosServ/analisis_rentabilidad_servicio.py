# bd_conecciones/servicios/CultivosServ/analisis_rentabilidad_servicio.py

import logging
from datetime import datetime, date, timedelta
from ...repositorios.CultivosRepositorio.relacion_cultivo_repositorio import RelacionCultivoRepositorio
from ...repositorios.CultivosRepositorio.ciclo_produccion_repositorio import CicloProduccionRepositorio
from ...repositorios.CultivosRepositorio.lote_cosecha_repositorio import LoteCosechaRepositorio
from ...nucleo.excepciones_bd import ErrorValidacion, RegistroNoEncontrado
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class AnalisisRentabilidadServicio:
    """Servicio especializado en análisis de rentabilidad y ROI del sistema de cultivos."""
    
    def __init__(self):
        self.relacion_repo = RelacionCultivoRepositorio()
        self.ciclo_repo = CicloProduccionRepositorio()
        self.lote_repo = LoteCosechaRepositorio()
    
    # ==================== ANÁLISIS PRINCIPALES DE RENTABILIDAD ====================
    
    @cacheable('analisis_rentabilidad', key_func=lambda: 'ranking_completo_sistema', ttl=1800)  # 30 min
    def obtener_ranking_completo(self):
        """
        Obtiene ranking completo de rentabilidad del sistema.
        
        Returns:
            list: Ranking ordenado por ROI con análisis detallado.
        """
        try:
            # Obtener ranking base del repositorio
            ranking_base = self.relacion_repo.obtener_ranking_rentabilidad_completo()
            
            # Enriquecer con análisis adicional
            ranking_enriquecido = []
            for item in ranking_base:
                item_enriquecido = item.copy()
                
                # Análisis de tendencia temporal
                item_enriquecido['tendencia_temporal'] = self._analizar_tendencia_temporal_combinacion(
                    item['tipo_cultivo'], item['variedad'], item['parcela']
                )
                
                # Score de sostenibilidad
                item_enriquecido['score_sostenibilidad'] = self._calcular_score_sostenibilidad(
                    item['roi_promedio'], item['consistencia'], item['total_ciclos']
                )
                
                # Potencial de escalamiento
                item_enriquecido['potencial_escalamiento'] = self._evaluar_potencial_escalamiento(item)
                
                # Factores de riesgo identificados
                item_enriquecido['factores_riesgo'] = self._identificar_factores_riesgo_combinacion(item)
                
                ranking_enriquecido.append(item_enriquecido)
            
            logger.info(f"Ranking de rentabilidad generado: {len(ranking_enriquecido)} combinaciones")
            return ranking_enriquecido
            
        except Exception as e:
            logger.error(f"Error obteniendo ranking completo: {str(e)}")
            return []
    
    @cacheable('analisis_rentabilidad', key_func=lambda: 'comparativo_variedades', ttl=1800)  # 30 min
    def obtener_analisis_variedades(self):
        """
        Análisis detallado de rentabilidad por variedades.
        
        Returns:
            dict: Análisis completo con rankings, tendencias y recomendaciones.
        """
        try:
            # Obtener datos base
            comparativo = self.relacion_repo.comparar_rentabilidad_variedades()
            
            # Análisis estadístico
            rois = [v['roi_promedio'] for v in comparativo if v.get('roi_promedio')]
            
            analisis = {
                'resumen_estadistico': {
                    'total_variedades': len(comparativo),
                    'roi_promedio_sistema': round(sum(rois) / len(rois), 1) if rois else 0,
                    'roi_maximo': max(rois) if rois else 0,
                    'roi_minimo': min(rois) if rois else 0,
                    'desviacion_estandar': self._calcular_desviacion_estandar(rois),
                    'variedades_rentables': len([r for r in rois if r > 20])
                },
                'categorias_rentabilidad': self._categorizar_variedades_por_rentabilidad(comparativo),
                'top_performers': comparativo[:5] if comparativo else [],
                'necesitan_atencion': [v for v in comparativo if v.get('roi_promedio', 0) < 15],
                'analisis_por_tipo_cultivo': self._analizar_por_tipo_cultivo(comparativo),
                'recomendaciones_estrategicas': self._generar_recomendaciones_variedades(comparativo),
                'oportunidades_mejora': self._identificar_oportunidades_mejora_variedades(comparativo)
            }
            
            return analisis
            
        except Exception as e:
            logger.error(f"Error en análisis de variedades: {str(e)}")
            return {}
    
    @cacheable('analisis_rentabilidad', key_func=lambda: 'performance_parcelas', ttl=1800)  # 30 min
    def obtener_analisis_parcelas(self):
        """
        Análisis detallado de performance de parcelas.
        
        Returns:
            dict: Análisis completo de eficiencia y rentabilidad por parcelas.
        """
        try:
            # Obtener datos base
            performance = self.relacion_repo.analizar_performance_parcelas()
            
            # Análisis de eficiencia
            analisis = {
                'resumen_general': {
                    'total_parcelas': len(performance),
                    'parcelas_eficientes': len([p for p in performance if p.get('roi_promedio', 0) > 30]),
                    'utilizacion_promedio': round(sum(p.get('utilizacion_porcentaje', 0) for p in performance) / len(performance), 1) if performance else 0,
                    'roi_promedio_parcelas': round(sum(p.get('roi_promedio', 0) for p in performance) / len(performance), 1) if performance else 0
                },
                'ranking_eficiencia': performance,
                'analisis_utilizacion': self._analizar_utilizacion_parcelas(performance),
                'potencial_expansion': self._identificar_potencial_expansion(performance),
                'parcelas_problematicas': [p for p in performance if p.get('roi_promedio', 0) < 20],
                'recomendaciones_optimizacion': self._generar_recomendaciones_parcelas(performance),
                'matriz_eficiencia': self._crear_matriz_eficiencia_parcelas(performance)
            }
            
            return analisis
            
        except Exception as e:
            logger.error(f"Error en análisis de parcelas: {str(e)}")
            return {}
    
    # ==================== ANÁLISIS PREDICTIVO DE RENTABILIDAD ====================
    
    @cacheable('predicciones_rentabilidad', key_func=lambda: 'proyecciones_roi', ttl=3600)  # 1 hora
    def generar_proyecciones_rentabilidad(self):
        """
        Genera proyecciones de rentabilidad basadas en tendencias históricas.
        
        Returns:
            dict: Proyecciones y escenarios de rentabilidad futura.
        """
        try:
            # Obtener datos históricos
            ranking_actual = self.obtener_ranking_completo()
            
            # Proyecciones por horizonte
            proyecciones = {
                'escenario_conservador': self._proyectar_escenario_conservador(ranking_actual),
                'escenario_optimista': self._proyectar_escenario_optimista(ranking_actual),
                'escenario_pesimista': self._proyectar_escenario_pesimista(ranking_actual)
            }
            
            # Factores de impacto
            factores_impacto = self._identificar_factores_impacto_futuro()
            
            # Recomendaciones estratégicas
            estrategias_futuro = self._generar_estrategias_futuro(proyecciones, factores_impacto)
            
            resultado = {
                'proyecciones_escenarios': proyecciones,
                'factores_impacto': factores_impacto,
                'estrategias_recomendadas': estrategias_futuro,
                'indicadores_seguimiento': self._definir_indicadores_seguimiento_rentabilidad(),
                'alertas_tempranas': self._configurar_alertas_tempranas(),
                'timestamp_proyeccion': self._get_timestamp()
            }
            
            return resultado
            
        except Exception as e:
            logger.error(f"Error generando proyecciones: {str(e)}")
            return {}
    
    # ==================== BENCHMARKING Y COMPARACIONES ====================
    
    def generar_benchmark_industria(self, sector="agricultura_general"):
        """
        Genera benchmark comparativo con estándares de la industria.
        
        Args:
            sector (str): Sector de comparación.
            
        Returns:
            dict: Análisis comparativo con benchmarks industriales.
        """
        try:
            # Obtener métricas actuales del sistema
            ranking_actual = self.obtener_ranking_completo()
            analisis_variedades = self.obtener_analisis_variedades()
            
            # Benchmarks de industria (valores de referencia)
            benchmarks_industria = self._obtener_benchmarks_industria(sector)
            
            # Comparación con benchmarks
            comparacion = {
                'posicion_relativa': self._calcular_posicion_relativa(analisis_variedades, benchmarks_industria),
                'gaps_identificados': self._identificar_gaps_performance(ranking_actual, benchmarks_industria),
                'fortalezas_competitivas': self._identificar_fortalezas_competitivas(ranking_actual, benchmarks_industria),
                'areas_mejora_criticas': self._identificar_areas_mejora_criticas(ranking_actual, benchmarks_industria),
                'roadmap_mejora': self._generar_roadmap_mejora(ranking_actual, benchmarks_industria)
            }
            
            return {
                'benchmark_utilizado': sector,
                'fecha_referencia': benchmarks_industria['fecha_referencia'],
                'analisis_comparativo': comparacion,
                'recomendaciones_benchmark': self._generar_recomendaciones_benchmark(comparacion),
                'metas_sugeridas': self._definir_metas_benchmark(comparacion)
            }
            
        except Exception as e:
            logger.error(f"Error generando benchmark: {str(e)}")
            return {}
    
    # ==================== REPORTES ESPECIALIZADOS ====================
    
    def generar_reporte_ejecutivo_rentabilidad(self, periodo_analisis=None):
        """
        Genera reporte ejecutivo completo de rentabilidad.
        
        Args:
            periodo_analisis (dict, optional): Período específico de análisis.
            
        Returns:
            dict: Reporte ejecutivo detallado.
        """
        try:
            # Datos principales
            ranking = self.obtener_ranking_completo()
            analisis_variedades = self.obtener_analisis_variedades()
            analisis_parcelas = self.obtener_analisis_parcelas()
            proyecciones = self.generar_proyecciones_rentabilidad()
            
            # Construir reporte ejecutivo
            reporte = {
                'resumen_ejecutivo': {
                    'roi_promedio_sistema': analisis_variedades['resumen_estadistico']['roi_promedio_sistema'],
                    'mejor_combinacion': ranking[0] if ranking else None,
                    'total_combinaciones_analizadas': len(ranking),
                    'combinaciones_altamente_rentables': len([r for r in ranking if r.get('roi_promedio', 0) > 50]),
                    'tendencia_general': self._determinar_tendencia_general_rentabilidad(ranking)
                },
                
                'analisis_detallado': {
                    'performance_variedades': analisis_variedades,
                    'eficiencia_parcelas': analisis_parcelas,
                    'ranking_completo': ranking[:10],  # Top 10
                    'distribuciones_roi': self._calcular_distribuciones_roi(ranking)
                },
                
                'proyecciones_futuro': proyecciones,
                
                'recomendaciones_estrategicas': {
                    'acciones_inmediatas': self._generar_acciones_inmediatas(ranking, analisis_variedades),
                    'inversiones_recomendadas': self._recomendar_inversiones(ranking, analisis_parcelas),
                    'optimizaciones_sugeridas': self._sugerir_optimizaciones(ranking),
                    'diversificacion_estrategica': self._evaluar_diversificacion_estrategica(ranking)
                },
                
                'anexos': {
                    'metodologia': self._describir_metodologia_analisis(),
                    'limitaciones': self._describir_limitaciones_analisis(),
                    'glosario_terminos': self._generar_glosario_rentabilidad()
                },
                
                'metadata': {
                    'fecha_generacion': self._get_timestamp(),
                    'periodo_analizado': periodo_analisis or 'historico_completo',
                    'version_reporte': '1.0',
                    'responsable_analisis': 'Sistema Automatizado'
                }
            }
            
            logger.info("Reporte ejecutivo de rentabilidad generado exitosamente")
            return reporte
            
        except Exception as e:
            logger.error(f"Error generando reporte ejecutivo: {str(e)}")
            return {'error': str(e)}
    
    # ==================== MÉTODOS AUXILIARES ====================
    
    def _analizar_tendencia_temporal_combinacion(self, tipo_cultivo, variedad, parcela):
        """Analiza tendencia temporal de una combinación específica."""
        # Placeholder - implementación simplificada
        return {
            'direccion': 'estable',
            'magnitud': 0.05,
            'confianza': 0.7,
            'periodo_analisis': '12_meses'
        }
    
    def _calcular_score_sostenibilidad(self, roi, consistencia, total_ciclos):
        """Calcula score de sostenibilidad de una combinación."""
        base_score = min(roi, 100)  # ROI máximo 100 para score
        consistencia_bonus = max(0, 20 - consistencia)  # Menos variabilidad = más bonus
        experiencia_bonus = min(total_ciclos * 2, 10)  # Máximo 10 puntos por experiencia
        
        return round(base_score + consistencia_bonus + experiencia_bonus, 1)
    
    def _evaluar_potencial_escalamiento(self, item):
        """Evalúa potencial de escalamiento de una combinación."""
        roi = item.get('roi_promedio', 0)
        ciclos = item.get('total_ciclos', 0)
        consistencia = item.get('consistencia', 0)
        
        if roi > 50 and ciclos >= 3 and consistencia < 15:
            return 'alto'
        elif roi > 30 and ciclos >= 2 and consistencia < 25:
            return 'medio'
        elif roi > 15:
            return 'bajo'
        else:
            return 'no_recomendado'
    
    def _identificar_factores_riesgo_combinacion(self, item):
        """Identifica factores de riesgo para una combinación."""
        riesgos = []
        
        if item.get('consistencia', 0) > 30:
            riesgos.append('alta_variabilidad')
        
        if item.get('total_ciclos', 0) < 3:
            riesgos.append('experiencia_limitada')
        
        if item.get('roi_promedio', 0) < 20:
            riesgos.append('rentabilidad_marginal')
        
        return riesgos
    
    def _calcular_desviacion_estandar(self, valores):
        """Calcula desviación estándar de una lista de valores."""
        if len(valores) < 2:
            return 0
        
        promedio = sum(valores) / len(valores)
        varianza = sum((x - promedio) ** 2 for x in valores) / len(valores)
        return round(varianza ** 0.5, 2)
    
    def _categorizar_variedades_por_rentabilidad(self, comparativo):
        """Categoriza variedades según su rentabilidad."""
        categorias = {
            'muy_alta': [v for v in comparativo if v.get('roi_promedio', 0) >= 50],
            'alta': [v for v in comparativo if 30 <= v.get('roi_promedio', 0) < 50],
            'media': [v for v in comparativo if 15 <= v.get('roi_promedio', 0) < 30],
            'baja': [v for v in comparativo if 5 <= v.get('roi_promedio', 0) < 15],
            'muy_baja': [v for v in comparativo if v.get('roi_promedio', 0) < 5]
        }
        
        return {cat: len(vars) for cat, vars in categorias.items()}
    
    def _analizar_por_tipo_cultivo(self, comparativo):
        """Analiza rentabilidad agrupada por tipo de cultivo."""
        tipos = {}
        for variedad in comparativo:
            tipo = variedad.get('tipo_cultivo', 'Desconocido')
            if tipo not in tipos:
                tipos[tipo] = []
            tipos[tipo].append(variedad['roi_promedio'])
        
        return {
            tipo: {
                'roi_promedio': round(sum(rois) / len(rois), 1),
                'cantidad_variedades': len(rois),
                'mejor_roi': max(rois),
                'peor_roi': min(rois)
            }
            for tipo, rois in tipos.items()
        }
    
    def _obtener_benchmarks_industria(self, sector):
        """Obtiene benchmarks de la industria para comparación."""
        # Valores de referencia típicos de la industria
        benchmarks = {
            'agricultura_general': {
                'roi_promedio': 25.0,
                'roi_excelente': 50.0,
                'roi_minimo_viable': 15.0,
                'utilizacion_tierra_optima': 80.0,
                'fecha_referencia': '2024'
            },
            'agricultura_intensiva': {
                'roi_promedio': 35.0,
                'roi_excelente': 70.0,
                'roi_minimo_viable': 20.0,
                'utilizacion_tierra_optima': 90.0,
                'fecha_referencia': '2024'
            }
        }
        
        return benchmarks.get(sector, benchmarks['agricultura_general'])
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        return datetime.now().isoformat()
    
    # Placeholders para métodos complejos (implementación simplificada)
    def _generar_recomendaciones_variedades(self, comparativo):
        return ["Enfocarse en variedades con ROI > 30%", "Diversificar portfolio de cultivos"]
    
    def _identificar_oportunidades_mejora_variedades(self, comparativo):
        return ["Optimizar variedades con ROI 15-25%", "Eliminar variedades con ROI < 10%"]
    
    def _analizar_utilizacion_parcelas(self, performance):
        return {'utilizacion_promedio': 75, 'parcelas_subutilizadas': 3}
    
    def _crear_matriz_eficiencia_parcelas(self, performance):
        return {'alta_eficiencia': 2, 'media_eficiencia': 3, 'baja_eficiencia': 1}