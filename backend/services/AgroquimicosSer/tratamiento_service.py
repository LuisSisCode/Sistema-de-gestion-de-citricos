# backend/services/AgroquimicosServ/tratamiento_service.py
"""
Servicio de Tratamientos Fitosanitarios
Contiene la lógica de negocio para gestión de tratamientos
"""

import logging
from datetime import date
from typing import List, Dict, Optional, Tuple
from backend.repositories.AgroquimicosRep.tratamiento_repositorio import TratamientoRepositorio
from backend.repositories.AgroquimicosRep.mezcla_repositorio import MezclaRepositorio

logger = logging.getLogger(__name__)


class TratamientoService:
    """Servicio con lógica de negocio para Tratamientos Fitosanitarios"""
    
    def __init__(self):
        self.tratamiento_repo = TratamientoRepositorio()
        self.mezcla_repo = MezclaRepositorio()
    
    # ==================== CONSULTAS ====================
    
    def obtener_todos_tratamientos(self) -> List[Dict]:
        """
        Obtiene todos los tratamientos fitosanitarios
        
        Returns:
            List[Dict]: Lista de tratamientos
        """
        return self.tratamiento_repo.obtener_todos()
    
    def obtener_tratamiento(self, id_tratamiento: int) -> Optional[Dict]:
        """
        Obtiene un tratamiento específico
        
        Args:
            id_tratamiento: ID del tratamiento
            
        Returns:
            Dict: Datos del tratamiento o None
        """
        return self.tratamiento_repo.obtener_por_id(id_tratamiento)
    
    def obtener_tratamientos_por_ciclo(self, id_ciclo: int) -> List[Dict]:
        """
        Obtiene todos los tratamientos de un ciclo específico
        
        Args:
            id_ciclo: ID del ciclo de producción
            
        Returns:
            List[Dict]: Lista de tratamientos del ciclo
        """
        return self.tratamiento_repo.obtener_por_ciclo(id_ciclo)
    
    def obtener_tratamientos_por_rango_fechas(self, fecha_inicio: date, fecha_fin: date) -> List[Dict]:
        """
        Obtiene tratamientos dentro de un rango de fechas
        
        Args:
            fecha_inicio: Fecha inicial
            fecha_fin: Fecha final
            
        Returns:
            List[Dict]: Lista de tratamientos en el rango
        """
        # Validar rango
        if fecha_inicio > fecha_fin:
            logger.warning(f"Fecha inicio ({fecha_inicio}) es mayor a fecha fin ({fecha_fin})")
            return []
        
        return self.tratamiento_repo.obtener_por_rango_fechas(fecha_inicio, fecha_fin)
    
    def obtener_tipos_plagas(self) -> List[Dict]:
        """
        Obtiene todos los tipos de plagas y malezas
        
        Returns:
            List[Dict]: Lista de tipos de plagas
        """
        return self.tratamiento_repo.obtener_tipos_plagas()
    
    def obtener_ciclos_activos(self) -> List[Dict]:
        """
        Obtiene los ciclos de producción activos
        
        Returns:
            List[Dict]: Lista de ciclos activos
        """
        return self.tratamiento_repo.obtener_ciclos_activos()
    
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
                - condiciones_climaticas (str, optional): Condiciones del clima
                - id_mezcla (int, optional): ID de la mezcla utilizada
                - cantidad_agua (float, optional): Cantidad de agua en litros
                - costo_total (float, optional): Costo total
                - realizado_por (str): Persona que realizó
                - observaciones (str, optional): Observaciones
            
        Returns:
            Tuple[bool, Optional[int], str]: (Éxito, ID del tratamiento, Mensaje)
        """
        # Validaciones
        validacion = self._validar_datos_tratamiento(datos)
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
        # Verificar que el tratamiento exista
        if not self.tratamiento_repo.existe(id_tratamiento):
            return False, "El tratamiento no existe"
        
        # Validaciones parciales
        if 'area_tratada' in datos:
            if datos['area_tratada'] <= 0:
                return False, "El área tratada debe ser mayor a cero"
        
        if 'cantidad_agua' in datos:
            if datos['cantidad_agua'] < 0:
                return False, "La cantidad de agua no puede ser negativa"
        
        if 'costo_total' in datos:
            if datos['costo_total'] < 0:
                return False, "El costo total no puede ser negativo"
        
        # Si se está cambiando la mezcla, verificar que exista
        if 'id_mezcla' in datos and datos['id_mezcla']:
            if not self.mezcla_repo.existe(datos['id_mezcla']):
                return False, "La mezcla especificada no existe"
        
        # Actualizar
        exito = self.tratamiento_repo.actualizar(id_tratamiento, datos)
        
        if exito:
            logger.info(f"Tratamiento {id_tratamiento} actualizado")
            return True, "Tratamiento actualizado exitosamente"
        else:
            return False, "Error al actualizar el tratamiento"
    
    # ==================== ELIMINACIÓN ====================
    
    def eliminar_tratamiento(self, id_tratamiento: int) -> Tuple[bool, str]:
        """
        Elimina un tratamiento de la base de datos
        
        Args:
            id_tratamiento: ID del tratamiento a eliminar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        if not self.tratamiento_repo.existe(id_tratamiento):
            return False, "El tratamiento no existe"
        
        exito = self.tratamiento_repo.eliminar(id_tratamiento)
        
        if exito:
            logger.info(f"Tratamiento {id_tratamiento} eliminado")
            return True, "Tratamiento eliminado exitosamente"
        else:
            return False, "Error al eliminar el tratamiento"
    
    # ==================== ANÁLISIS Y ESTADÍSTICAS ====================
    
    def obtener_estadisticas_ciclo(self, id_ciclo: int) -> Dict:
        """
        Obtiene estadísticas de tratamientos de un ciclo
        
        Args:
            id_ciclo: ID del ciclo
            
        Returns:
            Dict: Estadísticas del ciclo
        """
        tratamientos = self.tratamiento_repo.obtener_por_ciclo(id_ciclo)
        
        total_tratamientos = len(tratamientos)
        area_total_tratada = sum(t['area_tratada'] for t in tratamientos)
        costo_total = self.tratamiento_repo.calcular_costo_total_ciclo(id_ciclo)
        
        # Método más usado
        metodo_mas_usado = "N/A"
        if tratamientos:
            metodos = [t['metodo_aplicacion'] for t in tratamientos if t.get('metodo_aplicacion')]
            if metodos:
                metodo_mas_usado = max(set(metodos), key=metodos.count)
        
        # Plaga más tratada
        plaga_mas_tratada = "N/A"
        if tratamientos:
            plagas = [t['nombre_plaga'] for t in tratamientos if t.get('nombre_plaga')]
            if plagas:
                plaga_mas_tratada = max(set(plagas), key=plagas.count)
        
        return {
            'total_tratamientos': total_tratamientos,
            'area_total_tratada': round(area_total_tratada, 2),
            'costo_total': round(costo_total, 2),
            'costo_promedio': round(costo_total / total_tratamientos, 2) if total_tratamientos > 0 else 0,
            'metodo_mas_usado': metodo_mas_usado,
            'plaga_mas_tratada': plaga_mas_tratada
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
    
    def obtener_tratamientos_recientes(self, limite: int = 10) -> List[Dict]:
        """
        Obtiene los tratamientos más recientes
        
        Args:
            limite: Número máximo de tratamientos a retornar
            
        Returns:
            List[Dict]: Lista de tratamientos recientes
        """
        tratamientos = self.tratamiento_repo.obtener_todos()
        
        # Ordenar por fecha de aplicación descendente y tomar los primeros N
        tratamientos_ordenados = sorted(
            tratamientos,
            key=lambda t: t.get('fecha_aplicacion', ''),
            reverse=True
        )
        
        return tratamientos_ordenados[:limite]
    
    def obtener_plagas_mas_tratadas(self, top: int = 5) -> List[Dict]:
        """
        Obtiene las plagas más frecuentemente tratadas
        
        Args:
            top: Número de plagas a retornar
            
        Returns:
            List[Dict]: Lista de plagas con conteo
        """
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
    
    def calcular_efectividad_periodo(self, id_ciclo: int) -> Dict:
        """
        Calcula métricas de efectividad para un ciclo
        
        Args:
            id_ciclo: ID del ciclo
            
        Returns:
            Dict: Métricas de efectividad
        """
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
            
            frecuencia_promedio = sum(dias_entre_tratamientos) / len(dias_entre_tratamientos)
        
        return {
            'tiene_tratamientos': True,
            'total_aplicaciones': len(tratamientos),
            'frecuencia_promedio_dias': round(frecuencia_promedio, 1) if frecuencia_promedio > 0 else 0,
            'area_promedio_tratada': round(sum(t['area_tratada'] for t in tratamientos) / len(tratamientos), 2)
        }
    
    # ==================== VALIDACIONES ====================
    
    def _validar_datos_tratamiento(self, datos: Dict) -> Tuple[bool, str]:
        """
        Valida los datos de un tratamiento antes de crear/actualizar
        
        Args:
            datos: Datos del tratamiento a validar
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error si aplica)
        """
        # Campos requeridos para creación
        campos_requeridos = ['id_ciclo', 'fecha_aplicacion', 'area_tratada', 'realizado_por']
        
        for campo in campos_requeridos:
            if campo not in datos:
                return False, f"El campo '{campo}' es obligatorio"
        
        # Validar área tratada
        if datos['area_tratada'] <= 0:
            return False, "El área tratada debe ser mayor a cero"
        
        if datos['area_tratada'] > 10000:  # Límite razonable
            return False, "El área tratada excede el límite permitido (10,000 ha)"
        
        # Validar fecha de aplicación
        if isinstance(datos['fecha_aplicacion'], date):
            if datos['fecha_aplicacion'] > date.today():
                return False, "La fecha de aplicación no puede ser futura"
        
        # Validar persona que realizó
        if not datos['realizado_por'] or len(datos['realizado_por'].strip()) == 0:
            return False, "Debe especificar quién realizó el tratamiento"
        
        # Validar cantidad de agua si está presente
        if 'cantidad_agua' in datos and datos['cantidad_agua'] is not None:
            if datos['cantidad_agua'] < 0:
                return False, "La cantidad de agua no puede ser negativa"
        
        # Validar costo si está presente
        if 'costo_total' in datos and datos['costo_total'] is not None:
            if datos['costo_total'] < 0:
                return False, "El costo total no puede ser negativo"
        
        return True, "Validación exitosa"
    
    # ==================== UTILIDADES ====================
    
    def contar_tratamientos(self, id_ciclo: Optional[int] = None) -> int:
        """
        Cuenta el total de tratamientos
        
        Args:
            id_ciclo: Si se especifica, cuenta solo tratamientos de ese ciclo
            
        Returns:
            int: Cantidad de tratamientos
        """
        return self.tratamiento_repo.contar_tratamientos(id_ciclo)
    
    def calcular_costo_total_ciclo(self, id_ciclo: int) -> float:
        """
        Calcula el costo total de tratamientos de un ciclo
        
        Args:
            id_ciclo: ID del ciclo
            
        Returns:
            float: Costo total
        """
        return self.tratamiento_repo.calcular_costo_total_ciclo(id_ciclo)