# backend/services/AgroquimicosServ/tratamiento_service.py
"""
Servicio de Tratamientos Fitosanitarios
Contiene la lógica de negocio para gestión de tratamientos
"""

import logging
from datetime import date, datetime, timedelta
from typing import List, Dict, Optional, Tuple
from backend.repositories.AgroquimicosRep.tratamiento_repositorio import TratamientoRepositorio
from backend.repositories.AgroquimicosRep.mezcla_repositorio import MezclaRepositorio
from backend.core.repositorio_base import ErrorConsulta

logger = logging.getLogger(__name__)


class TratamientoService:
    """Servicio con lógica de negocio para Tratamientos Fitosanitarios"""
    
    def __init__(self):
        self.tratamiento_repo = TratamientoRepositorio()
        self.mezcla_repo = MezclaRepositorio()
        logger.info("TratamientoService inicializado")
    
    # ==================== CONSULTAS ====================
    
    def obtener_todos_tratamientos(self) -> List[Dict]:
        """
        Obtiene todos los tratamientos fitosanitarios
        
        Returns:
            List[Dict]: Lista de tratamientos
        """
        try:
            return self.tratamiento_repo.obtener_todos()
        except Exception as e:
            logger.error(f"Error al obtener tratamientos: {str(e)}")
            raise ErrorConsulta(f"Error al obtener tratamientos: {str(e)}")
    
    def obtener_tratamiento(self, id_tratamiento: int) -> Optional[Dict]:
        """
        Obtiene un tratamiento específico
        
        Args:
            id_tratamiento: ID del tratamiento
            
        Returns:
            Dict: Datos del tratamiento o None
        """
        try:
            return self.tratamiento_repo.obtener_por_id(id_tratamiento)
        except Exception as e:
            logger.error(f"Error al obtener tratamiento {id_tratamiento}: {str(e)}")
            raise ErrorConsulta(f"Error al obtener tratamiento: {str(e)}")
    
    def obtener_tratamientos_por_ciclo(self, id_ciclo: int) -> List[Dict]:
        """
        Obtiene todos los tratamientos de un ciclo específico
        
        Args:
            id_ciclo: ID del ciclo de producción
            
        Returns:
            List[Dict]: Lista de tratamientos del ciclo
        """
        try:
            return self.tratamiento_repo.obtener_por_ciclo(id_ciclo)
        except Exception as e:
            logger.error(f"Error al obtener tratamientos por ciclo {id_ciclo}: {str(e)}")
            return []
    
    def obtener_tratamientos_por_rango_fechas(self, fecha_inicio: date, fecha_fin: date) -> List[Dict]:
        """
        Obtiene tratamientos dentro de un rango de fechas
        
        Args:
            fecha_inicio: Fecha inicial
            fecha_fin: Fecha final
            
        Returns:
            List[Dict]: Lista de tratamientos en el rango
        """
        try:
            # Validar rango
            if fecha_inicio > fecha_fin:
                logger.warning(f"Fecha inicio ({fecha_inicio}) es mayor a fecha fin ({fecha_fin})")
                return []
            
            return self.tratamiento_repo.obtener_por_rango_fechas(fecha_inicio, fecha_fin)
        except Exception as e:
            logger.error(f"Error al obtener tratamientos por rango de fechas: {str(e)}")
            return []
    
    def obtener_tipos_plagas(self) -> List[Dict]:
        """
        Obtiene todos los tipos de plagas y malezas
        
        Returns:
            List[Dict]: Lista de tipos de plagas
        """
        try:
            return self.tratamiento_repo.obtener_tipos_plagas()
        except Exception as e:
            logger.error(f"Error al obtener tipos de plagas: {str(e)}")
            return []
    
    def obtener_ciclos_activos(self) -> List[Dict]:
        """
        Obtiene los ciclos de producción activos
        
        Returns:
            List[Dict]: Lista de ciclos activos
        """
        try:
            return self.tratamiento_repo.obtener_ciclos_activos()
        except Exception as e:
            logger.error(f"Error al obtener ciclos activos: {str(e)}")
            return []
    
    # ==================== CREACIÓN ====================
    
    def crear_tratamiento(self, datos: Dict) -> Tuple[bool, Optional[int], str]:
        """
        Crea un nuevo tratamiento fitosanitario con validaciones
        
        Args:
            datos: Diccionario con los datos del tratamiento
                - id_ciclo (int): ID del ciclo de producción
                - id_tipo_plaga (int, optional): ID del tipo de plaga
                - fecha_aplicacion (date): Fecha de aplicación
                - area_tratada (float): Área tratada en hectáreas
                - metodo_aplicacion (str, optional): Método usado
                - id_mezcla (int, optional): ID de la mezcla utilizada
                - cantidad_agua (float, optional): Cantidad de agua en litros
                - costo_total (float, optional): Costo total
                - realizado_por (int/str): ID del empleado o nombre
                - observaciones (str, optional): Observaciones
            
        Returns:
            Tuple[bool, Optional[int], str]: (Éxito, ID del tratamiento, Mensaje)
        """
        try:
            # Validaciones
            validacion = self._validar_datos_tratamiento(datos, es_actualizacion=False)
            if not validacion[0]:
                return False, None, validacion[1]
            
            # Si se especifica una mezcla, verificar que exista
            if datos.get('id_mezcla'):
                if not self.mezcla_repo.existe(datos['id_mezcla']):
                    return False, None, "La mezcla especificada no existe"
            
            # Crear el tratamiento
            exito, id_tratamiento = self.tratamiento_repo.crear(datos)
            
            if exito:
                logger.info(f"Tratamiento creado con ID: {id_tratamiento} para ciclo {datos['id_ciclo']}")
                return True, id_tratamiento, "Tratamiento creado exitosamente"
            else:
                return False, None, "Error al crear el tratamiento en la base de datos"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al crear tratamiento: {str(e)}")
            return False, None, str(e)
        except Exception as e:
            logger.error(f"Error al crear tratamiento: {str(e)}")
            return False, None, f"Error al crear tratamiento: {str(e)}"
    
    # ==================== ACTUALIZACIÓN ====================
    
    def actualizar_tratamiento(self, id_tratamiento: int, datos: Dict) -> Tuple[bool, str]:
        """
        Actualiza un tratamiento existente con validaciones
        
        Args:
            id_tratamiento: ID del tratamiento a actualizar
            datos: Datos a actualizar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que el tratamiento exista
            if not self.tratamiento_repo.existe(id_tratamiento):
                return False, "El tratamiento no existe"
            
            # Validaciones
            validacion = self._validar_datos_tratamiento(datos, es_actualizacion=True)
            if not validacion[0]:
                return False, validacion[1]
            
            # Si se está cambiando la mezcla, verificar que exista
            if 'id_mezcla' in datos and datos['id_mezcla']:
                if not self.mezcla_repo.existe(datos['id_mezcla']):
                    return False, "La mezcla especificada no existe"
            
            # Actualizar
            exito = self.tratamiento_repo.actualizar(id_tratamiento, datos)
            
            if exito:
                logger.info(f"Tratamiento {id_tratamiento} actualizado exitosamente")
                return True, "Tratamiento actualizado exitosamente"
            else:
                return False, "Error al actualizar el tratamiento"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al actualizar tratamiento: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error al actualizar tratamiento {id_tratamiento}: {str(e)}")
            return False, f"Error: {str(e)}"
    
    # ==================== ELIMINACIÓN ====================
    
    def eliminar_tratamiento(self, id_tratamiento: int) -> Tuple[bool, str]:
        """
        Elimina un tratamiento de la base de datos
        
        Args:
            id_tratamiento: ID del tratamiento a eliminar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            if not self.tratamiento_repo.existe(id_tratamiento):
                return False, "El tratamiento no existe"
            
            exito = self.tratamiento_repo.eliminar(id_tratamiento)
            
            if exito:
                logger.info(f"Tratamiento {id_tratamiento} eliminado")
                return True, "Tratamiento eliminado exitosamente"
            else:
                return False, "Error al eliminar el tratamiento"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al eliminar tratamiento: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error al eliminar tratamiento {id_tratamiento}: {str(e)}")
            return False, f"Error: {str(e)}"
    
    # ==================== ANÁLISIS Y ESTADÍSTICAS ====================
    
    def obtener_estadisticas_ciclo(self, id_ciclo: int) -> Dict:
        """
        Obtiene estadísticas de tratamientos de un ciclo
        
        Args:
            id_ciclo: ID del ciclo
            
        Returns:
            Dict: Estadísticas del ciclo
        """
        try:
            tratamientos = self.tratamiento_repo.obtener_por_ciclo(id_ciclo)
            
            if not tratamientos:
                return {
                    'total_tratamientos': 0,
                    'area_total_tratada': 0,
                    'costo_total': 0,
                    'costo_promedio': 0
                }
            
            total_tratamientos = len(tratamientos)
            area_total_tratada = sum(t['area_tratada'] for t in tratamientos)
            costo_total = sum(t['costo_total'] for t in tratamientos)
            
            return {
                'total_tratamientos': total_tratamientos,
                'area_total_tratada': round(area_total_tratada, 2),
                'costo_total': round(costo_total, 2),
                'costo_promedio': round(costo_total / total_tratamientos, 2) if total_tratamientos > 0 else 0
            }
            
        except Exception as e:
            logger.error(f"Error al obtener estadísticas del ciclo {id_ciclo}: {str(e)}")
            return {
                'total_tratamientos': 0,
                'area_total_tratada': 0,
                'costo_total': 0,
                'costo_promedio': 0
            }
    
    def obtener_resumen_tratamientos(self, fecha_inicio: Optional[date] = None, fecha_fin: Optional[date] = None) -> Dict:
        """
        Obtiene un resumen general de tratamientos
        
        Args:
            fecha_inicio: Fecha inicial del rango (opcional)
            fecha_fin: Fecha final del rango (opcional)
            
        Returns:
            Dict: Resumen de tratamientos
        """
        try:
            # Si se especifican fechas, filtrar por rango
            if fecha_inicio and fecha_fin:
                tratamientos = self.tratamiento_repo.obtener_por_rango_fechas(fecha_inicio, fecha_fin)
            else:
                tratamientos = self.tratamiento_repo.obtener_todos()
            
            total_tratamientos = len(tratamientos)
            
            if total_tratamientos == 0:
                return {
                    'total_tratamientos': 0,
                    'area_total_tratada': 0,
                    'costo_total': 0,
                    'costo_promedio': 0
                }
            
            area_total = sum(t['area_tratada'] for t in tratamientos)
            costo_total = sum(t['costo_total'] for t in tratamientos)
            
            return {
                'total_tratamientos': total_tratamientos,
                'area_total_tratada': round(area_total, 2),
                'costo_total': round(costo_total, 2),
                'costo_promedio': round(costo_total / total_tratamientos, 2)
            }
            
        except Exception as e:
            logger.error(f"Error al obtener resumen de tratamientos: {str(e)}")
            return {
                'total_tratamientos': 0,
                'area_total_tratada': 0,
                'costo_total': 0,
                'costo_promedio': 0
            }
    
    def obtener_tratamientos_recientes(self, limite: int = 10) -> List[Dict]:
        """
        Obtiene los tratamientos más recientes
        
        Args:
            limite: Número máximo de tratamientos a retornar
            
        Returns:
            List[Dict]: Lista de tratamientos recientes
        """
        try:
            tratamientos = self.tratamiento_repo.obtener_todos()
            
            # Ordenar por fecha de aplicación descendente y tomar los primeros N
            tratamientos_ordenados = sorted(
                tratamientos,
                key=lambda t: t.get('fecha_aplicacion', ''),
                reverse=True
            )
            
            return tratamientos_ordenados[:limite]
            
        except Exception as e:
            logger.error(f"Error al obtener tratamientos recientes: {str(e)}")
            return []
    
    def obtener_plagas_mas_tratadas(self, top: int = 5) -> List[Dict]:
        """
        Obtiene las plagas más frecuentemente tratadas
        
        Args:
            top: Número de plagas a retornar
            
        Returns:
            List[Dict]: Lista de plagas con conteo
        """
        try:
            tratamientos = self.tratamiento_repo.obtener_todos()
            
            # Contar plagas
            plagas_conteo = {}
            for tratamiento in tratamientos:
                if tratamiento.get('nombre_plaga'):
                    plaga = tratamiento['nombre_plaga']
                    if plaga not in plagas_conteo:
                        plagas_conteo[plaga] = {
                            'nombre': plaga,
                            'categoria': tratamiento.get('categoria_plaga', 'N/A'),
                            'cantidad_tratamientos': 0
                        }
                    plagas_conteo[plaga]['cantidad_tratamientos'] += 1
            
            # Ordenar por cantidad y tomar top N
            plagas_ordenadas = sorted(
                plagas_conteo.values(),
                key=lambda p: p['cantidad_tratamientos'],
                reverse=True
            )
            
            return plagas_ordenadas[:top]
            
        except Exception as e:
            logger.error(f"Error al obtener plagas más tratadas: {str(e)}")
            return []
    
    def calcular_efectividad_periodo(self, id_ciclo: int) -> Dict:
        """
        Calcula métricas de efectividad para un ciclo
        
        Args:
            id_ciclo: ID del ciclo
            
        Returns:
            Dict: Métricas de efectividad
        """
        try:
            tratamientos = self.tratamiento_repo.obtener_por_ciclo(id_ciclo)
            
            if not tratamientos:
                return {
                    'tiene_tratamientos': False,
                    'total_aplicaciones': 0,
                    'frecuencia_promedio': 0
                }
            
            # Calcular frecuencia de tratamientos
            fechas = [t['fecha_aplicacion'] for t in tratamientos if t.get('fecha_aplicacion')]
            
            if len(fechas) < 2:
                frecuencia_promedio = 0
            else:
                # Ordenar fechas
                fechas_ordenadas = sorted(fechas)
                
                # Calcular días entre tratamientos
                dias_entre_tratamientos = []
                for i in range(1, len(fechas_ordenadas)):
                    fecha_actual = fechas_ordenadas[i]
                    fecha_anterior = fechas_ordenadas[i-1]
                    
                    # Convertir a objetos date si son strings
                    if isinstance(fecha_actual, str):
                        fecha_actual = date.fromisoformat(fecha_actual)
                    if isinstance(fecha_anterior, str):
                        fecha_anterior = date.fromisoformat(fecha_anterior)
                    
                    dias = (fecha_actual - fecha_anterior).days
                    dias_entre_tratamientos.append(dias)
                
                frecuencia_promedio = sum(dias_entre_tratamientos) / len(dias_entre_tratamientos) if dias_entre_tratamientos else 0
            
            return {
                'tiene_tratamientos': True,
                'total_aplicaciones': len(tratamientos),
                'frecuencia_promedio_dias': round(frecuencia_promedio, 1) if frecuencia_promedio > 0 else 0,
                'area_promedio_tratada': round(sum(t['area_tratada'] for t in tratamientos) / len(tratamientos), 2)
            }
            
        except Exception as e:
            logger.error(f"Error al calcular efectividad del período: {str(e)}")
            return {
                'tiene_tratamientos': False,
                'total_aplicaciones': 0,
                'frecuencia_promedio': 0
            }
    
    # ==================== VALIDACIONES ====================
    
    def _validar_datos_tratamiento(self, datos: Dict, es_actualizacion: bool = False) -> Tuple[bool, str]:
        """
        Valida los datos de un tratamiento antes de crear/actualizar
        
        Args:
            datos: Datos del tratamiento a validar
            es_actualizacion: Si es una actualización
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error si aplica)
        """
        try:
            if not es_actualizacion:
                # Campos requeridos para creación
                campos_requeridos = ['id_ciclo', 'fecha_aplicacion', 'area_tratada', 'realizado_por']
                
                for campo in campos_requeridos:
                    if campo not in datos or datos[campo] is None:
                        return False, f"El campo '{campo}' es obligatorio"
            
            # Validar área tratada
            if 'area_tratada' in datos:
                try:
                    area = float(datos['area_tratada'])
                    if area <= 0:
                        return False, "El área tratada debe ser mayor a cero"
                    if area > 10000:  # Límite razonable
                        return False, "El área tratada excede el límite permitido (10,000 ha)"
                except (ValueError, TypeError):
                    return False, "El área tratada debe ser un número válido"
            
            # Validar fecha de aplicación
            if 'fecha_aplicacion' in datos:
                if isinstance(datos['fecha_aplicacion'], date):
                    if datos['fecha_aplicacion'] > date.today():
                        return False, "La fecha de aplicación no puede ser futura"
            
            # Validar persona que realizó
            if not es_actualizacion:
                if not datos.get('realizado_por'):
                    return False, "Debe especificar quién realizó el tratamiento"
            
            # Validar cantidad de agua si está presente
            if 'cantidad_agua' in datos and datos['cantidad_agua'] is not None:
                try:
                    cantidad = float(datos['cantidad_agua'])
                    if cantidad < 0:
                        return False, "La cantidad de agua no puede ser negativa"
                except (ValueError, TypeError):
                    return False, "La cantidad de agua debe ser un número válido"
            
            # Validar costo si está presente
            if 'costo_total' in datos and datos['costo_total'] is not None:
                try:
                    costo = float(datos['costo_total'])
                    if costo < 0:
                        return False, "El costo total no puede ser negativo"
                except (ValueError, TypeError):
                    return False, "El costo total debe ser un número válido"
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error al validar datos de tratamiento: {str(e)}")
            return False, f"Error en validación: {str(e)}"
    
    # ==================== UTILIDADES ====================
    
    def contar_tratamientos(self, id_ciclo: Optional[int] = None) -> int:
        """
        Cuenta el total de tratamientos
        
        Args:
            id_ciclo: Si se especifica, cuenta solo tratamientos de ese ciclo
            
        Returns:
            int: Cantidad de tratamientos
        """
        try:
            return self.tratamiento_repo.contar_tratamientos(id_ciclo)
        except Exception as e:
            logger.error(f"Error al contar tratamientos: {str(e)}")
            return 0
    
    def calcular_costo_total_ciclo(self, id_ciclo: int) -> float:
        """
        Calcula el costo total de tratamientos de un ciclo
        
        Args:
            id_ciclo: ID del ciclo
            
        Returns:
            float: Costo total
        """
        try:
            return self.tratamiento_repo.calcular_costo_total_ciclo(id_ciclo)
        except Exception as e:
            logger.error(f"Error al calcular costo total del ciclo: {str(e)}")
            return 0.0