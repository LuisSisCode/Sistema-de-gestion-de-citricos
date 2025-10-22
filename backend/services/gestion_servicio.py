# bd_c/servicios/gestion_servicio.py

import logging
from .agricultor_servicio import AgricultorServicio
from .parcela_servicio import ParcelaServicio
from ..repositories.relacion_repositorio import RelacionRepositorio

logger = logging.getLogger(__name__)

class GestionServicio:
    """Servicio principal para operaciones complejas que involucran múltiples entidades."""
    
    def __init__(self):
        self.agricultor_servicio = AgricultorServicio()
        self.parcela_servicio = ParcelaServicio()
        self.relacion_repo = RelacionRepositorio()
    
    # === MÉTODOS UNIFICADOS PARA QML ===
    
    def obtener_dashboard_completo(self):
        """
        Obtiene información completa para el dashboard principal.
        
        Returns:
            dict: Información consolidada del sistema.
        """
        try:
            # Obtener estadísticas generales
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
                    'porcentaje_con_coordenadas': estadisticas_parcelas.get('porcentaje_con_coordenadas', 0)
                },
                'distribucion_propietarios': distribucion[:5],  # Top 5
                'alertas': self._generar_alertas_sistema(estadisticas_generales, parcelas_sin_coords)
            }
            
            logger.info("Dashboard completo generado exitosamente")
            return dashboard
            
        except Exception as e:
            logger.error(f"Error en obtener_dashboard_completo: {str(e)}")
            return {
                'resumen': {},
                'calidad_datos': {},
                'distribucion_propietarios': [],
                'alertas': ['Error al cargar dashboard']
            }
    
    def procesar_operacion_agricultor(self, operacion, datos):
        """
        Procesa operaciones de agricultores con manejo unificado.
        
        Args:
            operacion (str): Tipo de operación (crear, actualizar, eliminar).
            datos (dict): Datos de la operación.
            
        Returns:
            dict: Resultado unificado de la operación.
        """
        try:
            if operacion == 'crear':
                return self.agricultor_servicio.crear_agricultor(datos['agricultor'])
            
            elif operacion == 'actualizar':
                return self.agricultor_servicio.actualizar_agricultor(
                    datos['id_agricultor'], 
                    datos['agricultor']
                )
            
            elif operacion == 'eliminar':
                return self.agricultor_servicio.eliminar_agricultor(datos['id_agricultor'])
            
            else:
                return {'exito': False, 'mensaje': f"Operación '{operacion}' no reconocida"}
                
        except Exception as e:
            logger.error(f"Error en procesar_operacion_agricultor: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
    
    def procesar_operacion_parcela(self, operacion, datos):
        """
        Procesa operaciones de parcelas con manejo unificado.
        
        Args:
            operacion (str): Tipo de operación (crear, actualizar, eliminar, transferir).
            datos (dict): Datos de la operación.
            
        Returns:
            dict: Resultado unificado de la operación.
        """
        try:
            if operacion == 'crear':
                return self.parcela_servicio.crear_parcela(datos['parcela'])
            
            elif operacion == 'actualizar':
                return self.parcela_servicio.actualizar_parcela(
                    datos['id_parcela'], 
                    datos['parcela']
                )
            
            elif operacion == 'eliminar':
                return self.parcela_servicio.eliminar_parcela(datos['id_parcela'])
            
            elif operacion == 'transferir':
                return self.parcela_servicio.transferir_parcela(
                    datos['id_parcela'], 
                    datos['nuevo_propietario_id']
                )
            
            else:
                return {'exito': False, 'mensaje': f"Operación '{operacion}' no reconocida"}
                
        except Exception as e:
            logger.error(f"Error en procesar_operacion_parcela: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
    
    def obtener_datos_paginados(self, entidad, pagina, por_pagina = 6, filtros=None):
        """
        Obtiene datos paginados de cualquier entidad de forma unificada.
        
        Args:
            entidad (str): Tipo de entidad (agricultores, parcelas).
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            filtros (dict, optional): Filtros a aplicar.
            
        Returns:
            dict: Datos paginados con metadatos.
        """
        try:
            if entidad == 'agricultores':
                return self.agricultor_servicio.obtener_agricultores_paginado(pagina, 8) # Aqui solo se modifica la cantidad de agricultores que queremos ver
            
            elif entidad == 'parcelas':
                propietario_id = filtros.get('propietario_id') if filtros else None
                return self.parcela_servicio.obtener_parcelas_paginado(pagina, por_pagina, propietario_id)
            
            else:
                return {
                    'datos': [],
                    'total_registros': 0,
                    'total_paginas': 0,
                    'pagina_actual': 1,
                    'error': f"Entidad '{entidad}' no reconocida"
                }
                
        except Exception as e:
            logger.error(f"Error en obtener_datos_paginados: {str(e)}")
            return {
                'datos': [],
                'total_registros': 0,
                'total_paginas': 0,
                'pagina_actual': 1,
                'error': 'Error interno del sistema'
            }
    
    def buscar_datos(self, entidad, texto_busqueda):
        """
        Busca datos en cualquier entidad de forma unificada.
        
        Args:
            entidad (str): Tipo de entidad (agricultores, parcelas).
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Resultados de la búsqueda.
        """
        try:
            if entidad == 'agricultores':
                return self.agricultor_servicio.buscar_agricultores(texto_busqueda)
            
            elif entidad == 'parcelas':
                
                return self.parcela_servicio.buscar_parcelas(texto_busqueda)
            
            else:
                logger.error(f"Entidad '{entidad}' no reconocida para búsqueda")
                return []
                
        except Exception as e:
            logger.error(f"Error en buscar_datos: {str(e)}")
            return []
    
    # === OPERACIONES COMPLEJAS ===
    
    def analizar_estado_propietario(self, id_propietario):
        """
        Analiza el estado completo de un propietario y sus parcelas.
        
        Args:
            id_propietario (int): ID del propietario.
            
        Returns:
            dict: Análisis completo del propietario.
        """
        try:
            # Obtener estado del agricultor
            estado_agricultor = self.agricultor_servicio.verificar_estado_agricultor(id_propietario)
            
            if not estado_agricultor:
                return {'error': 'Propietario no encontrado'}
            
            # Obtener sus parcelas
            parcelas = self.parcela_servicio.obtener_parcelas_por_propietario(id_propietario)
            
            # Calcular estadísticas
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
                'recomendaciones': self._generar_recomendaciones_propietario(estado_agricultor, parcelas)
            }
            
            logger.info(f"Análisis de propietario {id_propietario} completado")
            return analisis
            
        except Exception as e:
            logger.error(f"Error en analizar_estado_propietario: {str(e)}")
            return {'error': 'Error al analizar propietario'}
    
    def generar_reporte_completo(self):
        """
        Genera un reporte completo del sistema.
        
        Returns:
            dict: Reporte completo con toda la información relevante.
        """
        try:
            # Obtener datos base
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
                    'porcentaje_calidad': self._calcular_porcentaje_calidad_datos(estadisticas, parcelas_sin_coords)
                },
                'distribucion_tierras': distribucion,
                'detalle_propietarios': reporte_propietarios,
                'recomendaciones': self._generar_recomendaciones_sistema(estadisticas, parcelas_sin_coords),
                'alertas': self._generar_alertas_sistema(estadisticas, parcelas_sin_coords)
            }
            
            logger.info("Reporte completo generado exitosamente")
            return reporte
            
        except Exception as e:
            logger.error(f"Error en generar_reporte_completo: {str(e)}")
            return {'error': 'Error al generar reporte'}
    
    def validar_integridad_sistema(self):
        """
        Valida la integridad completa del sistema.
        
        Returns:
            dict: Resultados de la validación.
        """
        try:
            validaciones = {
                'agricultores_sin_parcelas': self._validar_agricultores_sin_parcelas(),
                'parcelas_sin_coordenadas': self._validar_parcelas_sin_coordenadas(),
                'datos_inconsistentes': self._validar_datos_inconsistentes(),
                'referencias_rotas': self._validar_referencias_rotas()
            }
            
            # Calcular puntuación general
            total_problemas = sum(len(v) for v in validaciones.values() if isinstance(v, list))
            puntuacion = max(0, 100 - (total_problemas * 5))  # -5 puntos por problema
            
            resultado = {
                'puntuacion_integridad': puntuacion,
                'estado': 'Excelente' if puntuacion >= 90 else 'Bueno' if puntuacion >= 70 else 'Necesita atención',
                'validaciones': validaciones,
                'resumen_problemas': total_problemas
            }
            
            logger.info(f"Validación de integridad completada - Puntuación: {puntuacion}")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en validar_integridad_sistema: {str(e)}")
            return {'error': 'Error al validar integridad'}
    
    # === MÉTODOS AUXILIARES ===
    
    def _generar_alertas_sistema(self, estadisticas, parcelas_sin_coords):
        """Genera alertas basadas en el estado del sistema."""
        alertas = []
        
        # Alerta por parcelas sin coordenadas
        if len(parcelas_sin_coords) > 0:
            porcentaje = (len(parcelas_sin_coords) / estadisticas['parcelas']['total']) * 100
            if porcentaje > 20:
                alertas.append(f"Alto porcentaje de parcelas sin coordenadas ({porcentaje:.1f}%)")
        
        # Alerta por concentración de tierras
        distribucion = self.relacion_repo.obtener_distribución_parcelas_por_propietario()
        if distribucion:
            area_top_propietario = distribucion[0]['area_total']
            area_total = estadisticas['parcelas']['area_total']
            if area_total > 0 and (area_top_propietario / area_total) > 0.5:
                alertas.append("Alta concentración de tierras en un solo propietario")
        
        return alertas
    
    def _generar_recomendaciones_propietario(self, estado_agricultor, parcelas):
        """Genera recomendaciones específicas para un propietario."""
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
        
        return recomendaciones
    
    def _generar_recomendaciones_sistema(self, estadisticas, parcelas_sin_coords):
        """Genera recomendaciones para el sistema completo."""
        recomendaciones = []
        
        if len(parcelas_sin_coords) > 0:
            recomendaciones.append("Implementar campaña de actualización de coordenadas GPS")
        
        if estadisticas['agricultores']['propietarios'] < estadisticas['agricultores']['total'] * 0.3:
            recomendaciones.append("Revisar clasificación de propietarios vs trabajadores")
        
        return recomendaciones
    
    def _calcular_porcentaje_calidad_datos(self, estadisticas, parcelas_sin_coords):
        """Calcula un porcentaje general de calidad de datos."""
        total_parcelas = estadisticas['parcelas']['total']
        if total_parcelas == 0:
            return 100
        
        parcelas_con_coords = total_parcelas - len(parcelas_sin_coords)
        return round((parcelas_con_coords / total_parcelas) * 100, 1)
    
    def _validar_agricultores_sin_parcelas(self):
        """Valida agricultores propietarios sin parcelas."""
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
    
    def _validar_parcelas_sin_coordenadas(self):
        """Valida parcelas sin coordenadas."""
        try:
            return self.relacion_repo.obtener_parcelas_sin_coordenadas()
        except Exception:
            return []
    
    def _validar_datos_inconsistentes(self):
        """Valida datos que podrían ser inconsistentes."""
        # Implementar validaciones específicas según reglas de negocio
        return []
    
    def _validar_referencias_rotas(self):
        """Valida referencias rotas entre entidades."""
        # Implementar validación de integridad referencial
        return []
    
    def _obtener_fecha_actual(self):
        """Obtiene la fecha actual formateada."""
        from datetime import datetime
        return datetime.now().strftime('%Y-%m-%d %H:%M:%S')