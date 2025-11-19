"""
Servicio de Mantenimientos
Contiene la lógica de negocio para la gestión de mantenimientos de maquinaria.
"""

import logging
from typing import List, Dict, Optional, Tuple
from datetime import datetime, timedelta
from backend.repositories.MaquinariaRep.mantenimiento_repositorio import MantenimientoRepositorio
from backend.repositories.MaquinariaRep.maquinaria_repositorio import MaquinariaRepositorio
from backend.core.repositorio_base import ErrorConsulta

logger = logging.getLogger(__name__)


class MantenimientoService:
    """
    Servicio para gestión de mantenimientos de maquinaria.
    Implementa la lógica de negocio y validaciones.
    """
    
    def __init__(self):
        self.mantenimiento_repo = MantenimientoRepositorio()
        self.maquinaria_repo = MaquinariaRepositorio()
        logger.info("MantenimientoService inicializado")
    
    def obtener_mantenimientos(self, id_maquinaria: Optional[int] = None) -> List[Dict]:
        """
        Obtiene la lista de mantenimientos.
        
        Args:
            id_maquinaria: ID de maquinaria para filtrar (opcional)
            
        Returns:
            Lista de mantenimientos
        """
        try:
            return self.mantenimiento_repo.obtener_todos(id_maquinaria)
        except Exception as e:
            logger.error(f"Error en servicio al obtener mantenimientos: {str(e)}")
            raise ErrorConsulta(f"Error al obtener mantenimientos: {str(e)}")
    
    def obtener_mantenimiento_por_id(self, id_mantenimiento: int) -> Optional[Dict]:
        """
        Obtiene un mantenimiento específico.
        
        Args:
            id_mantenimiento: ID del mantenimiento
            
        Returns:
            Diccionario con datos del mantenimiento o None
        """
        try:
            return self.mantenimiento_repo.obtener_por_id(id_mantenimiento)
        except Exception as e:
            logger.error(f"Error en servicio al obtener mantenimiento por ID: {str(e)}")
            raise ErrorConsulta(f"Error al obtener mantenimiento: {str(e)}")
    
    def validar_datos_mantenimiento(self, datos: Dict, es_actualizacion: bool = False) -> Tuple[bool, str]:
        """
        Valida los datos de mantenimiento antes de crear/actualizar.
        
        Args:
            datos: Diccionario con datos a validar
            es_actualizacion: Si es una actualización
            
        Returns:
            Tupla (es_válido, mensaje_error)
        """
        try:
            if not es_actualizacion:
                # Campos requeridos para creación
                if 'id_maquinaria' not in datos or not datos['id_maquinaria']:
                    return False, "El ID de maquinaria es requerido"
                
                if 'tipo' not in datos or not datos['tipo']:
                    return False, "El tipo de mantenimiento es requerido"
                
                if 'descripcion' not in datos or not datos['descripcion']:
                    return False, "La descripción es requerida"
                
                if 'costo_total' not in datos or datos['costo_total'] is None:
                    return False, "El costo total es requerido"
                
                if 'responsable' not in datos or not datos['responsable']:
                    return False, "El responsable es requerido"
                
                if 'estado' not in datos or not datos['estado']:
                    return False, "El estado es requerido"
            
            # Validar costo si está presente
            if 'costo_total' in datos:
                try:
                    costo = float(datos['costo_total'])
                    if costo < 0:
                        return False, "El costo no puede ser negativo"
                except (ValueError, TypeError):
                    return False, "El costo debe ser un número válido"
            
            # Validar tipo
            tipos_validos = ['Preventivo', 'Correctivo', 'Emergencia']
            if 'tipo' in datos and datos['tipo'] not in tipos_validos:
                logger.warning(f"Tipo de mantenimiento no estándar: {datos['tipo']}")
            
            # Validar estado
            estados_validos = ['Pendiente', 'En proceso', 'Completado', 'Cancelado']
            if 'estado' in datos and datos['estado'] not in estados_validos:
                return False, f"Estado inválido. Debe ser: {', '.join(estados_validos)}"
            
            # Validar fecha_realizada solo si el estado es Completado
            if 'estado' in datos and datos['estado'] == 'Completado':
                if 'fecha_realizada' not in datos or not datos['fecha_realizada']:
                    return False, "Se requiere fecha de realización para mantenimientos completados"
            
            # Validar que no se ponga fecha_realizada si no está completado
            if 'estado' in datos and datos['estado'] != 'Completado':
                if 'fecha_realizada' in datos and datos['fecha_realizada']:
                    return False, "Solo los mantenimientos completados pueden tener fecha de realización"
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error al validar datos de mantenimiento: {str(e)}")
            return False, f"Error en validación: {str(e)}"
    
    def registrar_mantenimiento(self, datos: Dict) -> Tuple[bool, int, str]:
        """
        Registra un nuevo mantenimiento con validaciones de negocio.
        
        Args:
            datos: Diccionario con datos del mantenimiento
            
        Returns:
            Tupla (éxito, id_generado, mensaje)
        """
        try:
            # Validar datos
            es_valido, mensaje = self.validar_datos_mantenimiento(datos)
            if not es_valido:
                return False, 0, mensaje
            
            # Verificar que la maquinaria existe y está activa
            maquina = self.maquinaria_repo.obtener_por_id(datos['id_maquinaria'])
            if not maquina:
                return False, 0, f"No existe maquinaria con ID: {datos['id_maquinaria']}"
            
            if not maquina['activo']:
                logger.warning(f"Registrando mantenimiento para maquinaria inactiva: {maquina['codigo']}")
            
            # Crear el mantenimiento
            exito, id_generado = self.mantenimiento_repo.crear(datos)
            
            if exito:
                # Si el estado es "En proceso", actualizar el estado de la maquinaria
                if datos.get('estado') == 'En proceso':
                    self.maquinaria_repo.actualizar(datos['id_maquinaria'], {'estado': 'En mantenimiento'})
                
                # Si se completó, volver a operativo
                if datos.get('estado') == 'Completado':
                    self.maquinaria_repo.actualizar(datos['id_maquinaria'], {'estado': 'Operativo'})
                
                logger.info(f"Mantenimiento registrado: ID {id_generado} para maquinaria {datos['id_maquinaria']}")
                return True, id_generado, "Mantenimiento registrado exitosamente"
            else:
                return False, 0, "Error al registrar el mantenimiento"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al registrar mantenimiento: {str(e)}")
            return False, 0, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al registrar mantenimiento: {str(e)}")
            return False, 0, f"Error al registrar mantenimiento: {str(e)}"
    
    def actualizar_mantenimiento(self, id_mantenimiento: int, datos: Dict) -> Tuple[bool, str]:
        """
        Actualiza un mantenimiento con validaciones.
        
        Args:
            id_mantenimiento: ID del mantenimiento a actualizar
            datos: Diccionario con campos a actualizar
            
        Returns:
            Tupla (éxito, mensaje)
        """
        try:
            # Verificar que el mantenimiento existe
            mantenimiento_actual = self.mantenimiento_repo.obtener_por_id(id_mantenimiento)
            if not mantenimiento_actual:
                return False, f"No existe mantenimiento con ID: {id_mantenimiento}"
            
            # Validar datos
            es_valido, mensaje = self.validar_datos_mantenimiento(datos, es_actualizacion=True)
            if not es_valido:
                return False, mensaje
            
            # Actualizar
            exito = self.mantenimiento_repo.actualizar(id_mantenimiento, datos)
            
            if exito:
                # Actualizar estado de maquinaria si cambió el estado del mantenimiento
                if 'estado' in datos:
                    id_maquinaria = mantenimiento_actual['id_maquinaria']
                    
                    if datos['estado'] == 'En proceso':
                        self.maquinaria_repo.actualizar(id_maquinaria, {'estado': 'En mantenimiento'})
                    elif datos['estado'] == 'Completado':
                        self.maquinaria_repo.actualizar(id_maquinaria, {'estado': 'Operativo'})
                    elif datos['estado'] == 'Cancelado':
                        self.maquinaria_repo.actualizar(id_maquinaria, {'estado': 'Operativo'})
                
                logger.info(f"Mantenimiento actualizado: ID {id_mantenimiento}")
                return True, "Mantenimiento actualizado exitosamente"
            else:
                return False, "No se pudo actualizar el mantenimiento"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al actualizar mantenimiento: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al actualizar mantenimiento: {str(e)}")
            return False, f"Error al actualizar mantenimiento: {str(e)}"
    
    def eliminar_mantenimiento(self, id_mantenimiento: int) -> Tuple[bool, str]:
        """
        Elimina un mantenimiento.
        
        Args:
            id_mantenimiento: ID del mantenimiento a eliminar
            
        Returns:
            Tupla (éxito, mensaje)
        """
        try:
            # Verificar que existe
            mantenimiento = self.mantenimiento_repo.obtener_por_id(id_mantenimiento)
            if not mantenimiento:
                return False, f"No existe mantenimiento con ID: {id_mantenimiento}"
            
            # Eliminar
            exito = self.mantenimiento_repo.eliminar(id_mantenimiento)
            
            if exito:
                # Si estaba en proceso, volver maquinaria a operativo
                if mantenimiento['estado'] == 'En proceso':
                    self.maquinaria_repo.actualizar(
                        mantenimiento['id_maquinaria'], 
                        {'estado': 'Operativo'}
                    )
                
                logger.info(f"Mantenimiento eliminado: ID {id_mantenimiento}")
                return True, "Mantenimiento eliminado exitosamente"
            else:
                return False, "Error al eliminar el mantenimiento"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al eliminar mantenimiento: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al eliminar mantenimiento: {str(e)}")
            return False, f"Error al eliminar mantenimiento: {str(e)}"
    
    def filtrar_mantenimientos(self, filtros: Dict) -> List[Dict]:
        """
        Filtra mantenimientos según criterios.
        
        Args:
            filtros: Diccionario con criterios de filtrado
            
        Returns:
            Lista de mantenimientos filtrados
        """
        try:
            return self.mantenimiento_repo.filtrar(filtros)
        except Exception as e:
            logger.error(f"Error al filtrar mantenimientos: {str(e)}")
            raise ErrorConsulta(f"Error al filtrar mantenimientos: {str(e)}")
    
    def obtener_estadisticas(self, id_maquinaria: Optional[int] = None) -> Dict:
        """
        Obtiene estadísticas de mantenimientos.
        
        Args:
            id_maquinaria: ID de maquinaria para filtrar (opcional)
            
        Returns:
            Diccionario con estadísticas
        """
        try:
            return self.mantenimiento_repo.obtener_estadisticas(id_maquinaria)
        except Exception as e:
            logger.error(f"Error al obtener estadísticas: {str(e)}")
            raise ErrorConsulta(f"Error al obtener estadísticas: {str(e)}")
    
    def obtener_mantenimientos_vencidos(self, dias_umbral: int = 30) -> List[Dict]:
        """
        Obtiene equipos que necesitan mantenimiento según días desde el último.
        
        Args:
            dias_umbral: Número de días sin mantenimiento para considerar vencido
            
        Returns:
            Lista de equipos con mantenimiento vencido
        """
        try:
            fecha_limite = (datetime.now() - timedelta(days=dias_umbral)).strftime('%Y-%m-%d')
            
            # Obtener todos los equipos activos
            equipos = self.maquinaria_repo.obtener_todos(solo_activos=True)
            
            equipos_vencidos = []
            for equipo in equipos:
                # Obtener último mantenimiento
                mantenimientos = self.mantenimiento_repo.filtrar({
                    'id_maquinaria': equipo['id_maquinaria'],
                    'estado': 'Completado'
                })
                
                if not mantenimientos:
                    # Nunca ha tenido mantenimiento
                    equipos_vencidos.append({
                        **equipo,
                        'dias_sin_mantenimiento': 'Nunca',
                        'ultimo_mantenimiento': None
                    })
                else:
                    # Verificar si el último mantenimiento es anterior al umbral
                    ultimo = mantenimientos[0]  # Ya vienen ordenados por fecha DESC
                    if ultimo['fecha_realizada'] and ultimo['fecha_realizada'] < fecha_limite:
                        dias_sin = (datetime.now() - datetime.strptime(ultimo['fecha_realizada'], '%Y-%m-%d')).days
                        equipos_vencidos.append({
                            **equipo,
                            'dias_sin_mantenimiento': dias_sin,
                            'ultimo_mantenimiento': ultimo['fecha_realizada']
                        })
            
            logger.info(f"Se encontraron {len(equipos_vencidos)} equipos con mantenimiento vencido")
            return equipos_vencidos
            
        except Exception as e:
            logger.error(f"Error al obtener mantenimientos vencidos: {str(e)}")
            return []
    
    def obtener_mantenimientos_pendientes(self) -> List[Dict]:
        """
        Obtiene todos los mantenimientos con estado Pendiente.
        
        Returns:
            Lista de mantenimientos pendientes
        """
        try:
            return self.mantenimiento_repo.filtrar({'estado': 'Pendiente'})
        except Exception as e:
            logger.error(f"Error al obtener mantenimientos pendientes: {str(e)}")
            return []
    
    def calcular_costo_promedio_por_equipo(self, id_maquinaria: int) -> float:
        """
        Calcula el costo promedio de mantenimiento para un equipo.
        
        Args:
            id_maquinaria: ID del equipo
            
        Returns:
            Costo promedio
        """
        try:
            stats = self.mantenimiento_repo.obtener_estadisticas(id_maquinaria)
            return stats.get('costo_promedio', 0)
        except Exception as e:
            logger.error(f"Error al calcular costo promedio: {str(e)}")
            return 0
    
    def generar_reporte_mantenimientos(self, fecha_desde: str, fecha_hasta: str) -> Dict:
        """
        Genera un reporte de mantenimientos para un período.
        
        Args:
            fecha_desde: Fecha inicial YYYY-MM-DD
            fecha_hasta: Fecha final YYYY-MM-DD
            
        Returns:
            Diccionario con reporte detallado
        """
        try:
            # Obtener mantenimientos del período
            mantenimientos = self.mantenimiento_repo.filtrar({
                'fecha_desde': fecha_desde,
                'fecha_hasta': fecha_hasta
            })
            
            # Calcular totales
            costo_total = sum(m['costo_total'] for m in mantenimientos)
            
            # Agrupar por tipo
            por_tipo = {}
            for m in mantenimientos:
                tipo = m['tipo']
                if tipo not in por_tipo:
                    por_tipo[tipo] = {'cantidad': 0, 'costo': 0}
                por_tipo[tipo]['cantidad'] += 1
                por_tipo[tipo]['costo'] += m['costo_total']
            
            # Agrupar por estado
            por_estado = {}
            for m in mantenimientos:
                estado = m['estado']
                if estado not in por_estado:
                    por_estado[estado] = 0
                por_estado[estado] += 1
            
            reporte = {
                'fecha_desde': fecha_desde,
                'fecha_hasta': fecha_hasta,
                'total_mantenimientos': len(mantenimientos),
                'costo_total': costo_total,
                'costo_promedio': costo_total / len(mantenimientos) if mantenimientos else 0,
                'por_tipo': por_tipo,
                'por_estado': por_estado,
                'mantenimientos': mantenimientos
            }
            
            logger.info(f"Reporte generado: {len(mantenimientos)} mantenimientos en el período")
            return reporte
            
        except Exception as e:
            logger.error(f"Error al generar reporte de mantenimientos: {str(e)}")
            return {}