"""
Servicio de Maquinaria
Contiene la lógica de negocio para la gestión de maquinaria agrícola.
"""

import logging
from typing import List, Dict, Optional, Tuple
from backend.repositories.MaquinariaRep.maquinaria_repositorio import MaquinariaRepositorio
from backend.repositories.MaquinariaRep.mantenimiento_repositorio import MantenimientoRepositorio
from backend.core.repositorio_base import ErrorConsulta
logger = logging.getLogger(__name__)


class MaquinariaService:
    """
    Servicio para gestión de maquinaria agrícola.
    Implementa la lógica de negocio y validaciones.
    """
    
    def __init__(self):
        self.maquinaria_repo = MaquinariaRepositorio()
        self.mantenimiento_repo = MantenimientoRepositorio()
        logger.info("MaquinariaService inicializado")
    
    def obtener_maquinaria(self, solo_activos: bool = False) -> List[Dict]:
        """
        Obtiene la lista de maquinaria.
        
        Args:
            solo_activos: Si True, solo devuelve equipos activos
            
        Returns:
            Lista de equipos de maquinaria
        """
        try:
            return self.maquinaria_repo.obtener_todos(solo_activos)
        except Exception as e:
            logger.error(f"Error en servicio al obtener maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al obtener maquinaria: {str(e)}")
    
    def obtener_maquinaria_por_id(self, id_maquinaria: int) -> Optional[Dict]:
        """
        Obtiene un equipo específico con información adicional.
        
        Args:
            id_maquinaria: ID del equipo
            
        Returns:
            Diccionario con datos del equipo o None
        """
        try:
            maquina = self.maquinaria_repo.obtener_por_id(id_maquinaria)
            
            if maquina:
                # Enriquecer con información de mantenimientos
                mantenimientos = self.mantenimiento_repo.obtener_todos(id_maquinaria)
                maquina['total_mantenimientos'] = len(mantenimientos)
                maquina['ultimo_mantenimiento'] = mantenimientos[0]['fecha_realizada'] if mantenimientos else None
            
            return maquina
            
        except Exception as e:
            logger.error(f"Error en servicio al obtener maquinaria por ID: {str(e)}")
            raise ErrorConsulta(f"Error al obtener maquinaria: {str(e)}")
    
    def validar_datos_maquinaria(self, datos: Dict, es_actualizacion: bool = False) -> Tuple[bool, str]:
        """
        Valida los datos de maquinaria antes de crear/actualizar.
        
        Args:
            datos: Diccionario con datos a validar
            es_actualizacion: Si es una actualización (permite campos opcionales)
            
        Returns:
            Tupla (es_válido, mensaje_error)
        """
        try:
            if not es_actualizacion:
                # Validar campos requeridos para creación
                if not datos.get('codigo'):
                    return False, "El código es requerido"
                
                if not datos.get('nombre'):
                    return False, "El nombre es requerido"
                
                if not datos.get('tipo'):
                    return False, "El tipo es requerido"
                
                if not datos.get('marca'):
                    return False, "La marca es requerida"
                
                # Validar longitud de código
                if len(datos['codigo']) > 20:
                    return False, "El código no puede exceder 20 caracteres"
            
            # Validar estado si está presente
            estados_validos = ['Operativo', 'En mantenimiento', 'Fuera de servicio']
            if 'estado' in datos and datos['estado'] not in estados_validos:
                return False, f"Estado inválido. Debe ser uno de: {', '.join(estados_validos)}"
            
            # Validar tipo de combustible si está presente
            combustibles_validos = ['Diesel', 'Gasolina', 'Eléctrico', 'Manual', 'Híbrido']
            if 'tipo_combustible' in datos and datos['tipo_combustible']:
                if datos['tipo_combustible'] not in combustibles_validos:
                    logger.warning(f"Tipo de combustible no estándar: {datos['tipo_combustible']}")
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error al validar datos de maquinaria: {str(e)}")
            return False, f"Error en validación: {str(e)}"
    
    def agregar_maquinaria(self, datos: Dict) -> Tuple[bool, int, str]:
        """
        Agrega un nuevo equipo de maquinaria con validaciones de negocio.
        
        Args:
            datos: Diccionario con datos del equipo
            
        Returns:
            Tupla (éxito, id_generado, mensaje)
        """
        try:
            # Validar datos
            es_valido, mensaje = self.validar_datos_maquinaria(datos)
            if not es_valido:
                return False, 0, mensaje
            
            # Verificar código duplicado
            if self.maquinaria_repo.obtener_por_codigo(datos['codigo']):
                return False, 0, f"Ya existe un equipo con el código '{datos['codigo']}'"
            
            # Establecer valores por defecto
            if 'estado' not in datos:
                datos['estado'] = 'Operativo'
            
            if 'activo' not in datos:
                datos['activo'] = True
            
            # Crear el equipo
            exito, id_generado = self.maquinaria_repo.crear(datos)
            
            if exito:
                logger.info(f"Equipo creado exitosamente: {datos['codigo']} (ID: {id_generado})")
                return True, id_generado, "Equipo registrado exitosamente"
            else:
                return False, 0, "Error al registrar el equipo"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al agregar maquinaria: {str(e)}")
            return False, 0, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al agregar maquinaria: {str(e)}")
            return False, 0, f"Error al registrar equipo: {str(e)}"
    
    def actualizar_maquinaria(self, id_maquinaria: int, datos: Dict) -> Tuple[bool, str]:
        """
        Actualiza un equipo de maquinaria con validaciones.
        
        Args:
            id_maquinaria: ID del equipo a actualizar
            datos: Diccionario con campos a actualizar
            
        Returns:
            Tupla (éxito, mensaje)
        """
        try:
            # Validar que el equipo existe
            if not self.maquinaria_repo.obtener_por_id(id_maquinaria):
                return False, f"No existe equipo con ID: {id_maquinaria}"
            
            # Validar datos
            es_valido, mensaje = self.validar_datos_maquinaria(datos, es_actualizacion=True)
            if not es_valido:
                return False, mensaje
            
            # Actualizar
            exito = self.maquinaria_repo.actualizar(id_maquinaria, datos)
            
            if exito:
                logger.info(f"Equipo actualizado: ID {id_maquinaria}")
                return True, "Equipo actualizado exitosamente"
            else:
                return False, "No se pudo actualizar el equipo"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al actualizar maquinaria: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al actualizar maquinaria: {str(e)}")
            return False, f"Error al actualizar equipo: {str(e)}"
    
    def eliminar_maquinaria(self, id_maquinaria: int, forzar: bool = False) -> Tuple[bool, str]:
        """
        Elimina un equipo (preferiblemente desactivación).
        
        Args:
            id_maquinaria: ID del equipo a eliminar
            forzar: Si True, elimina físicamente; si False, solo desactiva
            
        Returns:
            Tupla (éxito, mensaje)
        """
        try:
            # Verificar que existe
            maquina = self.maquinaria_repo.obtener_por_id(id_maquinaria)
            if not maquina:
                return False, f"No existe equipo con ID: {id_maquinaria}"
            
            # Verificar si tiene mantenimientos
            mantenimientos = self.mantenimiento_repo.obtener_todos(id_maquinaria)
            
            if mantenimientos and not forzar:
                # Si tiene historial, solo desactivar
                exito = self.maquinaria_repo.desactivar(id_maquinaria)
                if exito:
                    return True, "Equipo desactivado (tiene historial de mantenimientos)"
                else:
                    return False, "Error al desactivar el equipo"
            
            if forzar:
                # Eliminación física
                exito = self.maquinaria_repo.eliminar(id_maquinaria)
                if exito:
                    return True, "Equipo eliminado permanentemente"
                else:
                    return False, "Error al eliminar el equipo"
            else:
                # Desactivación
                exito = self.maquinaria_repo.desactivar(id_maquinaria)
                if exito:
                    return True, "Equipo desactivado exitosamente"
                else:
                    return False, "Error al desactivar el equipo"
                    
        except ErrorConsulta as e:
            logger.error(f"Error de BD al eliminar maquinaria: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error en servicio al eliminar maquinaria: {str(e)}")
            return False, f"Error al eliminar equipo: {str(e)}"
    
    def desactivar_maquinaria(self, id_maquinaria: int) -> Tuple[bool, str]:
        """
        Desactiva un equipo de maquinaria.
        
        Args:
            id_maquinaria: ID del equipo
            
        Returns:
            Tupla (éxito, mensaje)
        """
        try:
            exito = self.maquinaria_repo.desactivar(id_maquinaria)
            
            if exito:
                return True, "Equipo desactivado exitosamente"
            else:
                return False, "Error al desactivar el equipo"
                
        except Exception as e:
            logger.error(f"Error al desactivar maquinaria: {str(e)}")
            return False, f"Error: {str(e)}"
    
    def activar_maquinaria(self, id_maquinaria: int) -> Tuple[bool, str]:
        """
        Reactiva un equipo de maquinaria.
        
        Args:
            id_maquinaria: ID del equipo
            
        Returns:
            Tupla (éxito, mensaje)
        """
        try:
            exito = self.maquinaria_repo.activar(id_maquinaria)
            
            if exito:
                return True, "Equipo activado exitosamente"
            else:
                return False, "Error al activar el equipo"
                
        except Exception as e:
            logger.error(f"Error al activar maquinaria: {str(e)}")
            return False, f"Error: {str(e)}"
    
    def filtrar_maquinaria(self, filtros: Dict) -> List[Dict]:
        """
        Filtra maquinaria según criterios.
        
        Args:
            filtros: Diccionario con criterios de filtrado
            
        Returns:
            Lista de equipos filtrados
        """
        try:
            return self.maquinaria_repo.filtrar(filtros)
        except Exception as e:
            logger.error(f"Error al filtrar maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al filtrar maquinaria: {str(e)}")
    
    def obtener_estadisticas_completas(self) -> Dict:
        """
        Obtiene estadísticas completas de maquinaria.
        
        Returns:
            Diccionario con estadísticas detalladas
        """
        try:
            # Estadísticas básicas de maquinaria
            stats_maq = self.maquinaria_repo.obtener_estadisticas()
            
            # Estadísticas de mantenimientos
            stats_mant = self.mantenimiento_repo.obtener_estadisticas()
            
            # Combinar
            estadisticas = {
                **stats_maq,
                'mantenimientos': stats_mant
            }
            
            return estadisticas
            
        except Exception as e:
            logger.error(f"Error al obtener estadísticas completas: {str(e)}")
            raise ErrorConsulta(f"Error al obtener estadísticas: {str(e)}")
    
    def verificar_estructura_bd(self) -> Dict:
        """
        Verifica la estructura de la base de datos de maquinaria.
        
        Returns:
            Diccionario con información de verificación
        """
        try:
            # Obtener una muestra de datos
            maquinarias = self.maquinaria_repo.obtener_todos()
            
            verificacion = {
                'tabla_maquinaria': {
                    'existe': True,
                    'total_registros': len(maquinarias),
                    'campos_verificados': [
                        'id_maquinaria', 'codigo', 'nombre', 'tipo', 
                        'marca', 'tipo_combustible', 'estado', 
                        'ubicacion_actual', 'activo'
                    ]
                }
            }
            
            if maquinarias:
                verificacion['tabla_maquinaria']['ejemplo'] = maquinarias[0]
            
            logger.info("Verificación de estructura BD completada")
            return verificacion
            
        except Exception as e:
            logger.error(f"Error al verificar estructura BD: {str(e)}")
            return {
                'tabla_maquinaria': {
                    'existe': False,
                    'error': str(e)
                }
            }
    
    def obtener_candidatos_eliminacion(self) -> List[Dict]:
        """
        Obtiene equipos candidatos para eliminación.
        Equipos inactivos sin mantenimientos recientes.
        
        Returns:
            Lista de equipos candidatos
        """
        try:
            from datetime import datetime, timedelta
            
            # Obtener equipos inactivos
            equipos_inactivos = self.maquinaria_repo.filtrar({'activo': False})
            
            candidatos = []
            fecha_limite = (datetime.now() - timedelta(days=365)).strftime('%Y-%m-%d')
            
            for equipo in equipos_inactivos:
                # Verificar mantenimientos
                mantenimientos = self.mantenimiento_repo.filtrar({
                    'id_maquinaria': equipo['id_maquinaria'],
                    'fecha_desde': fecha_limite
                })
                
                if not mantenimientos:
                    candidatos.append({
                        **equipo,
                        'razon_candidato': 'Inactivo sin mantenimientos en el último año'
                    })
            
            logger.info(f"Se encontraron {len(candidatos)} candidatos para eliminación")
            return candidatos
            
        except Exception as e:
            logger.error(f"Error al obtener candidatos de eliminación: {str(e)}")
            return []
    
    def generar_reporte_auditoria(self) -> Dict:
        """
        Genera un reporte de auditoría de equipos.
        
        Returns:
            Diccionario con reporte de auditoría
        """
        try:
            from datetime import datetime, timedelta
            
            estadisticas = self.obtener_estadisticas_completas()
            maquinarias = self.maquinaria_repo.obtener_todos()
            
            fecha_mes_pasado = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
            
            equipos_sin_mantenimiento = []
            for maquina in maquinarias:
                if maquina['activo']:
                    mantenimientos = self.mantenimiento_repo.filtrar({
                        'id_maquinaria': maquina['id_maquinaria'],
                        'fecha_desde': fecha_mes_pasado
                    })
                    
                    if not mantenimientos:
                        equipos_sin_mantenimiento.append({
                            'codigo': maquina['codigo'],
                            'nombre': maquina['nombre'],
                            'estado': maquina['estado']
                        })
            
            reporte = {
                'fecha_reporte': datetime.now().isoformat(),
                'estadisticas_generales': estadisticas,
                'equipos_sin_mantenimiento_reciente': equipos_sin_mantenimiento,
                'total_equipos_sin_mantenimiento': len(equipos_sin_mantenimiento)
            }
            
            logger.info("Reporte de auditoría generado")
            return reporte
            
        except Exception as e:
            logger.error(f"Error al generar reporte de auditoría: {str(e)}")
            return {}