"""
Servicio de Combustible
Contiene la lógica de negocio para la gestión de compras de combustible.
"""

import logging
from typing import List, Dict, Optional, Tuple
from datetime import datetime, timedelta
from backend.repositories.MaquinariaRep.compra_combustible_repositorio import CompraCombustibleRepositorio
from backend.core.repositorio_base import ErrorConsulta

logger = logging.getLogger(__name__)


class CombustibleService:
    """
    Servicio para gestión de compras de combustible.
    Implementa la lógica de negocio y validaciones.
    """
    
    def __init__(self):
        self.combustible_repo = CompraCombustibleRepositorio()
        logger.info("CombustibleService inicializado")
    
    def obtener_compras(self, filtros: Optional[Dict] = None) -> List[Dict]:
        """
        Obtiene la lista de compras de combustible.
        
        Args:
            filtros: Diccionario opcional con filtros
            
        Returns:
            Lista de compras
        """
        try:
            return self.combustible_repo.obtener_todos(filtros)
        except Exception as e:
            logger.error(f"Error en servicio al obtener compras: {str(e)}")
            raise ErrorConsulta(f"Error al obtener compras: {str(e)}")
    
    def obtener_compra_por_id(self, id_compra: int) -> Optional[Dict]:
        """
        Obtiene una compra específica.
        
        Args:
            id_compra: ID de la compra
            
        Returns:
            Diccionario con datos de la compra o None
        """
        try:
            return self.combustible_repo.obtener_por_id(id_compra)
        except Exception as e:
            logger.error(f"Error en servicio al obtener compra por ID: {str(e)}")
            raise ErrorConsulta(f"Error al obtener compra: {str(e)}")
    
    def validar_datos_compra(self, datos: Dict, es_actualizacion: bool = False) -> Tuple[bool, str]:
        """
        Valida los datos de compra antes de crear/actualizar.
        
        Args:
            datos: Diccionario con datos a validar
            es_actualizacion: Si es una actualización
            
        Returns:
            Tupla (es_válido, mensaje_error)
        """
        try:
            if not es_actualizacion:
                # Campos requeridos para creación
                if 'tipo_combustible' not in datos or not datos['tipo_combustible']:
                    return False, "El tipo de combustible es requerido"
                
                if 'fecha_compra' not in datos or not datos['fecha_compra']:
                    return False, "La fecha de compra es requerida"
                
                if 'cantidad' not in datos or datos['cantidad'] is None:
                    return False, "La cantidad es requerida"
                
                if 'unidad_medida' not in datos or not datos['unidad_medida']:
                    return False, "La unidad de medida es requerida"
                
                if 'precio_unitario' not in datos or datos['precio_unitario'] is None:
                    return False, "El precio unitario es requerido"
                
                if 'responsable' not in datos or not datos['responsable']:
                    return False, "El responsable es requerido"
            
            # Validar cantidad
            if 'cantidad' in datos:
                try:
                    cantidad = float(datos['cantidad'])
                    if cantidad <= 0:
                        return False, "La cantidad debe ser mayor a 0"
                except (ValueError, TypeError):
                    return False, "La cantidad debe ser un número válido"
            
            # Validar precio unitario
            if 'precio_unitario' in datos:
                try:
                    precio = float(datos['precio_unitario'])
                    if precio <= 0:
                        return False, "El precio unitario debe ser mayor a 0"
                except (ValueError, TypeError):
                    return False, "El precio unitario debe ser un número válido"
            
            # Validar tipo de combustible
            tipos_validos = ['Diesel', 'Gasolina', 'Gas', 'Biodiesel']
            if 'tipo_combustible' in datos and datos['tipo_combustible'] not in tipos_validos:
                logger.warning(f"Tipo de combustible no estándar: {datos['tipo_combustible']}")
            
            # Validar unidad de medida
            unidades_validas = ['Litros', 'Galones', 'm³', 'Barriles']
            if 'unidad_medida' in datos and datos['unidad_medida'] not in unidades_validas:
                logger.warning(f"Unidad de medida no estándar: {datos['unidad_medida']}")
            
            # Validar fecha no futura
            if 'fecha_compra' in datos:
                try:
                    fecha_compra = datetime.strptime(datos['fecha_compra'], '%Y-%m-%d')
                    if fecha_compra > datetime.now():
                        return False, "La fecha de compra no puede ser futura"
                except (ValueError, TypeError):
                    return False, "Formato de fecha inválido (use YYYY-MM-DD)"
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error al validar datos de compra: {str(e)}")
            return False, f"Error en validación: {str(e)}"
    
    def registrar_compra(self, datos: Dict) -> Tuple[bool, int, str]:
        """
        Registra una nueva compra de combustible con validaciones.
        
        Args:
            datos: Diccionario con datos de la compra
            
        Returns:
            Tupla (éxito, id_generado, mensaje)
        """
        try:
            # Validar datos
            es_valido, mensaje = self.validar_datos_compra(datos)
            if not es_valido:
                return False, 0, mensaje
            
            # Crear la compra
            exito, id_generado = self.combustible_repo.crear(datos)
            
            if exito:
                precio_total = float(datos['cantidad']) * float(datos['precio_unitario'])
                logger.info(f"Compra registrada: ID {id_generado}, Total: ${precio_total:.2f}")
                return True, id_generado, "Compra registrada exitosamente"
            else:
                return False, 0, "Error al registrar la compra"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al registrar compra: {str(e)}")
            return False, 0, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al registrar compra: {str(e)}")
            return False, 0, f"Error al registrar compra: {str(e)}"
    
    def actualizar_compra(self, id_compra: int, datos: Dict) -> Tuple[bool, str]:
        """
        Actualiza una compra de combustible con validaciones.
        
        Args:
            id_compra: ID de la compra a actualizar
            datos: Diccionario con campos a actualizar
            
        Returns:
            Tupla (éxito, mensaje)
        """
        try:
            # Verificar que la compra existe
            if not self.combustible_repo.obtener_por_id(id_compra):
                return False, f"No existe compra con ID: {id_compra}"
            
            # Validar datos
            es_valido, mensaje = self.validar_datos_compra(datos, es_actualizacion=True)
            if not es_valido:
                return False, mensaje
            
            # Actualizar
            exito = self.combustible_repo.actualizar(id_compra, datos)
            
            if exito:
                logger.info(f"Compra actualizada: ID {id_compra}")
                return True, "Compra actualizada exitosamente"
            else:
                return False, "No se pudo actualizar la compra"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al actualizar compra: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al actualizar compra: {str(e)}")
            return False, f"Error al actualizar compra: {str(e)}"
    
    def eliminar_compra(self, id_compra: int) -> Tuple[bool, str]:
        """
        Elimina una compra de combustible.
        
        Args:
            id_compra: ID de la compra a eliminar
            
        Returns:
            Tupla (éxito, mensaje)
        """
        try:
            # Verificar que existe
            if not self.combustible_repo.obtener_por_id(id_compra):
                return False, f"No existe compra con ID: {id_compra}"
            
            # Eliminar
            exito = self.combustible_repo.eliminar(id_compra)
            
            if exito:
                logger.info(f"Compra eliminada: ID {id_compra}")
                return True, "Compra eliminada exitosamente"
            else:
                return False, "Error al eliminar la compra"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al eliminar compra: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al eliminar compra: {str(e)}")
            return False, f"Error al eliminar compra: {str(e)}"
    
    def obtener_resumen(self, periodo: str = 'mes') -> Dict:
        """
        Obtiene un resumen de combustible por período.
        
        Args:
            periodo: Período ('mes', 'trimestre', 'año')
            
        Returns:
            Diccionario con resumen
        """
        try:
            return self.combustible_repo.obtener_resumen(periodo)
        except Exception as e:
            logger.error(f"Error al obtener resumen: {str(e)}")
            raise ErrorConsulta(f"Error al obtener resumen: {str(e)}")
    
    def obtener_estadisticas(self) -> Dict:
        """
        Obtiene estadísticas generales de combustible.
        
        Returns:
            Diccionario con estadísticas
        """
        try:
            return self.combustible_repo.obtener_estadisticas()
        except Exception as e:
            logger.error(f"Error al obtener estadísticas: {str(e)}")
            raise ErrorConsulta(f"Error al obtener estadísticas: {str(e)}")
    
    def calcular_consumo_promedio_diario(self, tipo_combustible: Optional[str] = None, dias: int = 30) -> float:
        """
        Calcula el consumo promedio diario de combustible.
        
        Args:
            tipo_combustible: Tipo específico (opcional)
            dias: Número de días a considerar
            
        Returns:
            Consumo promedio diario
        """
        try:
            fecha_desde = (datetime.now() - timedelta(days=dias)).strftime('%Y-%m-%d')
            fecha_hasta = datetime.now().strftime('%Y-%m-%d')
            
            filtros = {
                'fecha_desde': fecha_desde,
                'fecha_hasta': fecha_hasta
            }
            
            if tipo_combustible:
                filtros['tipo_combustible'] = tipo_combustible
            
            compras = self.combustible_repo.obtener_todos(filtros)
            
            total_cantidad = sum(c['cantidad'] for c in compras)
            promedio_diario = total_cantidad / dias if dias > 0 else 0
            
            logger.info(f"Consumo promedio diario calculado: {promedio_diario:.2f} (últimos {dias} días)")
            return promedio_diario
            
        except Exception as e:
            logger.error(f"Error al calcular consumo promedio: {str(e)}")
            return 0
    
    def proyectar_necesidad_combustible(self, tipo_combustible: str, dias_proyeccion: int = 30) -> Dict:
        """
        Proyecta la necesidad de combustible basándose en consumo histórico.
        
        Args:
            tipo_combustible: Tipo de combustible a proyectar
            dias_proyeccion: Días a proyectar
            
        Returns:
            Diccionario con proyección
        """
        try:
            # Calcular consumo promedio de los últimos 30 días
            consumo_promedio = self.calcular_consumo_promedio_diario(tipo_combustible, 30)
            
            # Proyectar
            cantidad_proyectada = consumo_promedio * dias_proyeccion
            
            # Obtener precio promedio reciente
            compras_recientes = self.combustible_repo.obtener_todos({
                'tipo_combustible': tipo_combustible,
                'fecha_desde': (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
            })
            
            if compras_recientes:
                precio_promedio = sum(c['precio_unitario'] for c in compras_recientes) / len(compras_recientes)
            else:
                precio_promedio = 0
            
            costo_proyectado = cantidad_proyectada * precio_promedio
            
            proyeccion = {
                'tipo_combustible': tipo_combustible,
                'dias_proyeccion': dias_proyeccion,
                'consumo_promedio_diario': consumo_promedio,
                'cantidad_proyectada': cantidad_proyectada,
                'precio_promedio': precio_promedio,
                'costo_proyectado': costo_proyectado,
                'fecha_calculo': datetime.now().isoformat()
            }
            
            logger.info(f"Proyección generada para {tipo_combustible}: {cantidad_proyectada:.2f} unidades")
            return proyeccion
            
        except Exception as e:
            logger.error(f"Error al proyectar necesidad: {str(e)}")
            return {}
    
    def analizar_variacion_precios(self, tipo_combustible: str, meses: int = 6) -> Dict:
        """
        Analiza la variación de precios de un tipo de combustible.
        
        Args:
            tipo_combustible: Tipo de combustible
            meses: Número de meses a analizar
            
        Returns:
            Diccionario con análisis de precios
        """
        try:
            fecha_desde = (datetime.now() - timedelta(days=meses*30)).strftime('%Y-%m-%d')
            
            compras = self.combustible_repo.obtener_todos({
                'tipo_combustible': tipo_combustible,
                'fecha_desde': fecha_desde
            })
            
            if not compras:
                return {
                    'tipo_combustible': tipo_combustible,
                    'mensaje': 'No hay datos suficientes para el análisis'
                }
            
            precios = [c['precio_unitario'] for c in compras]
            
            precio_min = min(precios)
            precio_max = max(precios)
            precio_promedio = sum(precios) / len(precios)
            variacion = precio_max - precio_min
            porcentaje_variacion = (variacion / precio_min * 100) if precio_min > 0 else 0
            
            # Precio actual (última compra)
            precio_actual = compras[0]['precio_unitario']
            
            # Tendencia (comparar primera mitad vs segunda mitad)
            mitad = len(precios) // 2
            precio_primera_mitad = sum(precios[:mitad]) / mitad if mitad > 0 else 0
            precio_segunda_mitad = sum(precios[mitad:]) / (len(precios) - mitad) if len(precios) - mitad > 0 else 0
            
            if precio_segunda_mitad > precio_primera_mitad:
                tendencia = "Alza"
            elif precio_segunda_mitad < precio_primera_mitad:
                tendencia = "Baja"
            else:
                tendencia = "Estable"
            
            analisis = {
                'tipo_combustible': tipo_combustible,
                'periodo_analizado_meses': meses,
                'num_compras': len(compras),
                'precio_min': precio_min,
                'precio_max': precio_max,
                'precio_promedio': precio_promedio,
                'precio_actual': precio_actual,
                'variacion_absoluta': variacion,
                'variacion_porcentual': porcentaje_variacion,
                'tendencia': tendencia,
                'fecha_analisis': datetime.now().isoformat()
            }
            
            logger.info(f"Análisis de precios completado para {tipo_combustible}")
            return analisis
            
        except Exception as e:
            logger.error(f"Error al analizar variación de precios: {str(e)}")
            return {}
    
    def generar_reporte_combustible(self, fecha_desde: str, fecha_hasta: str) -> Dict:
        """
        Genera un reporte completo de combustible para un período.
        
        Args:
            fecha_desde: Fecha inicial YYYY-MM-DD
            fecha_hasta: Fecha final YYYY-MM-DD
            
        Returns:
            Diccionario con reporte detallado
        """
        try:
            # Obtener compras del período
            compras = self.combustible_repo.obtener_todos({
                'fecha_desde': fecha_desde,
                'fecha_hasta': fecha_hasta
            })
            
            # Calcular totales
            gasto_total = sum(c['precio_total'] for c in compras)
            cantidad_total = sum(c['cantidad'] for c in compras)
            
            # Agrupar por tipo
            por_tipo = {}
            for c in compras:
                tipo = c['tipo_combustible']
                if tipo not in por_tipo:
                    por_tipo[tipo] = {
                        'cantidad': 0,
                        'gasto': 0,
                        'num_compras': 0,
                        'precio_promedio': 0
                    }
                por_tipo[tipo]['cantidad'] += c['cantidad']
                por_tipo[tipo]['gasto'] += c['precio_total']
                por_tipo[tipo]['num_compras'] += 1
            
            # Calcular promedios
            for tipo in por_tipo:
                if por_tipo[tipo]['cantidad'] > 0:
                    por_tipo[tipo]['precio_promedio'] = por_tipo[tipo]['gasto'] / por_tipo[tipo]['cantidad']
            
            # Agrupar por proveedor
            por_proveedor = {}
            for c in compras:
                prov = c['proveedor_nombre']
                if prov not in por_proveedor:
                    por_proveedor[prov] = {'num_compras': 0, 'gasto': 0}
                por_proveedor[prov]['num_compras'] += 1
                por_proveedor[prov]['gasto'] += c['precio_total']
            
            reporte = {
                'fecha_desde': fecha_desde,
                'fecha_hasta': fecha_hasta,
                'total_compras': len(compras),
                'gasto_total': gasto_total,
                'cantidad_total': cantidad_total,
                'gasto_promedio_compra': gasto_total / len(compras) if compras else 0,
                'por_tipo': por_tipo,
                'por_proveedor': por_proveedor,
                'compras': compras
            }
            
            logger.info(f"Reporte generado: {len(compras)} compras en el período")
            return reporte
            
        except Exception as e:
            logger.error(f"Error al generar reporte de combustible: {str(e)}")
            return {}
    
    def obtener_alertas_combustible(self) -> List[Dict]:
        """
        Genera alertas sobre el consumo de combustible.
        
        Returns:
            Lista de alertas
        """
        try:
            alertas = []
            
            # Alerta por alto consumo (comparar último mes vs promedio de 3 meses anteriores)
            tipos_combustible = ['Diesel', 'Gasolina', 'Gas']
            
            for tipo in tipos_combustible:
                # Último mes
                consumo_ultimo_mes = self.calcular_consumo_promedio_diario(tipo, 30) * 30
                
                # 3 meses anteriores
                compras_3_meses = self.combustible_repo.obtener_todos({
                    'tipo_combustible': tipo,
                    'fecha_desde': (datetime.now() - timedelta(days=120)).strftime('%Y-%m-%d'),
                    'fecha_hasta': (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
                })
                
                if compras_3_meses:
                    consumo_3_meses = sum(c['cantidad'] for c in compras_3_meses)
                    promedio_mensual_anterior = consumo_3_meses / 3
                    
                    # Si el consumo del último mes es 20% mayor
                    if consumo_ultimo_mes > promedio_mensual_anterior * 1.2:
                        alertas.append({
                            'tipo': 'ALTO_CONSUMO',
                            'combustible': tipo,
                            'mensaje': f'Consumo de {tipo} aumentó más del 20%',
                            'consumo_actual': consumo_ultimo_mes,
                            'promedio_anterior': promedio_mensual_anterior,
                            'aumento_porcentual': ((consumo_ultimo_mes / promedio_mensual_anterior) - 1) * 100
                        })
            
            logger.info(f"Se generaron {len(alertas)} alertas de combustible")
            return alertas
            
        except Exception as e:
            logger.error(f"Error al generar alertas: {str(e)}")
            return []