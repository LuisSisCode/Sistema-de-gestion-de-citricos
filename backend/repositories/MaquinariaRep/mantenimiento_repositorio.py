"""
Repositorio para gestión de Mantenimientos de Maquinaria
Maneja todas las operaciones CRUD de la tabla Mantenimientos
"""

import logging
from typing import List, Dict, Optional, Tuple
from datetime import datetime, date
from backend.core.repositorio_base import RepositorioBase
from backend.core.repositorio_base import ErrorConsulta
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class MantenimientoRepositorio(RepositorioBase):
    """
    Repositorio para la gestión de mantenimientos de maquinaria agrícola.
    
    Tabla: Mantenimientos
    Columnas: id_mantenimiento, id_maquinaria, tipo, fecha_realizada,
              descripcion, costo_total, responsable, estado
    """
    
    def __init__(self):
        super().__init__()
        self.tabla = "Mantenimientos"
        logger.info("MantenimientoRepositorio inicializado")
    
    def _formatear_fecha(self, fecha_valor) -> Optional[str]:
        """Convierte diferentes formatos de fecha a string YYYY-MM-DD"""
        if fecha_valor is None:
            return None
        
        if isinstance(fecha_valor, str):
            if not fecha_valor.strip():
                return None
            # Validar formato
            try:
                datetime.strptime(fecha_valor.strip(), '%Y-%m-%d')
                return fecha_valor.strip()
            except ValueError:
                logger.warning(f"Formato de fecha inválido: {fecha_valor}")
                return None
        
        if isinstance(fecha_valor, (datetime, date)):
            return fecha_valor.strftime('%Y-%m-%d')
        
        return None
    
    @cacheable('mantenimientos', ttl=get_ttl('mantenimientos'))
    def obtener_todos(self, id_maquinaria: Optional[int] = None) -> List[Dict]:
        """
        Obtiene todos los mantenimientos, opcionalmente filtrados por maquinaria.
        
        Args:
            id_maquinaria: ID de maquinaria para filtrar (opcional)
            
        Returns:
            Lista de diccionarios con información de mantenimientos
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT m.id_mantenimiento, m.id_maquinaria, m.tipo, m.fecha_realizada,
                       m.descripcion, m.costo_total, m.responsable, m.estado,
                       maq.codigo as maquinaria_codigo, maq.nombre as maquinaria_nombre,
                       emp.nombre as responsable_nombre, emp.apellido as responsable_apellido
                FROM Mantenimientos m
                INNER JOIN Maquinaria maq ON m.id_maquinaria = maq.id_maquinaria
                INNER JOIN Empleados emp ON m.responsable = emp.id_empleado
                """
                
                valores = []
                if id_maquinaria is not None:
                    query += " WHERE m.id_maquinaria = ?"
                    valores.append(id_maquinaria)
                
                query += " ORDER BY m.fecha_realizada DESC, m.id_mantenimiento DESC"
                
                cursor.execute(query, valores)
                
                mantenimientos = []
                for row in cursor.fetchall():
                    mantenimiento = {
                        'id_mantenimiento': int(row.id_mantenimiento),
                        'id_maquinaria': int(row.id_maquinaria),
                        'tipo': str(row.tipo).strip(),
                        'fecha_realizada': self._formatear_fecha(row.fecha_realizada),
                        'descripcion': str(row.descripcion).strip() if row.descripcion else "",
                        'costo_total': float(row.costo_total),
                        'responsable': int(row.responsable),
                        'estado': str(row.estado).strip(),
                        # Campos adicionales de JOIN
                        'maquinaria_codigo': str(row.maquinaria_codigo).strip(),
                        'maquinaria_nombre': str(row.maquinaria_nombre).strip(),
                        'responsable_nombre': f"{row.responsable_nombre} {row.responsable_apellido}".strip()
                    }
                    mantenimientos.append(mantenimiento)
                
                logger.info(f"Se obtuvieron {len(mantenimientos)} mantenimientos")
                return mantenimientos
                
        except Exception as e:
            logger.error(f"Error al obtener mantenimientos: {str(e)}")
            raise ErrorConsulta(f"Error al obtener mantenimientos: {str(e)}")
    
    def obtener_por_id(self, id_mantenimiento: int) -> Optional[Dict]:
        """
        Obtiene un mantenimiento específico por su ID.
        
        Args:
            id_mantenimiento: ID del mantenimiento
            
        Returns:
            Diccionario con datos del mantenimiento o None si no existe
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT m.id_mantenimiento, m.id_maquinaria, m.tipo, m.fecha_realizada,
                       m.descripcion, m.costo_total, m.responsable, m.estado,
                       maq.codigo as maquinaria_codigo, maq.nombre as maquinaria_nombre,
                       emp.nombre as responsable_nombre, emp.apellido as responsable_apellido
                FROM Mantenimientos m
                INNER JOIN Maquinaria maq ON m.id_maquinaria = maq.id_maquinaria
                INNER JOIN Empleados emp ON m.responsable = emp.id_empleado
                WHERE m.id_mantenimiento = ?
                """
                
                cursor.execute(query, (id_mantenimiento,))
                row = cursor.fetchone()
                
                if not row:
                    logger.warning(f"No se encontró mantenimiento con ID: {id_mantenimiento}")
                    return None
                
                mantenimiento = {
                    'id_mantenimiento': int(row.id_mantenimiento),
                    'id_maquinaria': int(row.id_maquinaria),
                    'tipo': str(row.tipo).strip(),
                    'fecha_realizada': self._formatear_fecha(row.fecha_realizada),
                    'descripcion': str(row.descripcion).strip() if row.descripcion else "",
                    'costo_total': float(row.costo_total),
                    'responsable': int(row.responsable),
                    'estado': str(row.estado).strip(),
                    'maquinaria_codigo': str(row.maquinaria_codigo).strip(),
                    'maquinaria_nombre': str(row.maquinaria_nombre).strip(),
                    'responsable_nombre': f"{row.responsable_nombre} {row.responsable_apellido}".strip()
                }
                
                logger.info(f"Mantenimiento obtenido: ID {id_mantenimiento}")
                return mantenimiento
                
        except Exception as e:
            logger.error(f"Error al obtener mantenimiento por ID {id_mantenimiento}: {str(e)}")
            raise ErrorConsulta(f"Error al obtener mantenimiento: {str(e)}")
    
    @cache_invalidator('mantenimientos')
    def crear(self, datos: Dict) -> Tuple[bool, int]:
        """
        Registra un nuevo mantenimiento.
        
        Args:
            datos: Diccionario con los datos del mantenimiento
                - id_maquinaria (int, requerido): ID de la maquinaria
                - tipo (str, requerido): Tipo de mantenimiento
                - descripcion (str, requerido): Descripción del trabajo
                - costo_total (float, requerido): Costo total
                - responsable (int, requerido): ID del empleado responsable
                - estado (str, requerido): Estado del mantenimiento
                - fecha_realizada (str, opcional): Fecha YYYY-MM-DD (solo si estado es Completado)
                
        Returns:
            Tupla (éxito, id_generado)
        """
        try:
            # Validar campos requeridos
            campos_requeridos = ['id_maquinaria', 'tipo', 'descripcion', 'costo_total', 'responsable', 'estado']
            for campo in campos_requeridos:
                if campo not in datos or datos[campo] is None or datos[campo] == '':
                    raise ValueError(f"El campo '{campo}' es requerido")
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Validar que exista la maquinaria
                cursor.execute("SELECT id_maquinaria FROM Maquinaria WHERE id_maquinaria = ?", 
                             (datos['id_maquinaria'],))
                if not cursor.fetchone():
                    raise ValueError(f"No existe maquinaria con ID: {datos['id_maquinaria']}")
                
                # Validar que exista el empleado
                cursor.execute("SELECT id_empleado FROM Empleados WHERE id_empleado = ?", 
                             (datos['responsable'],))
                if not cursor.fetchone():
                    raise ValueError(f"No existe empleado con ID: {datos['responsable']}")
                
                # Procesar fecha_realizada
                fecha_realizada = None
                if 'fecha_realizada' in datos:
                    fecha_realizada = self._formatear_fecha(datos['fecha_realizada'])
                
                query = """
                INSERT INTO Mantenimientos 
                (id_maquinaria, tipo, fecha_realizada, descripcion, costo_total, responsable, estado)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    int(datos['id_maquinaria']),
                    str(datos['tipo']).strip(),
                    fecha_realizada,
                    str(datos['descripcion']).strip(),
                    float(datos['costo_total']),
                    int(datos['responsable']),
                    str(datos['estado']).strip()
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID generado
                cursor.execute("SELECT @@IDENTITY")
                id_generado = cursor.fetchone()[0]
                
                logger.info(f"Mantenimiento registrado exitosamente: ID {id_generado}")
                return True, int(id_generado)
                
        except ValueError as ve:
            logger.warning(f"Validación fallida al crear mantenimiento: {str(ve)}")
            raise ErrorConsulta(str(ve))
        except Exception as e:
            logger.error(f"Error al crear mantenimiento: {str(e)}")
            raise ErrorConsulta(f"Error al crear mantenimiento: {str(e)}")
    
    @cache_invalidator('mantenimientos')
    def actualizar(self, id_mantenimiento: int, datos: Dict) -> bool:
        """
        Actualiza un mantenimiento existente.
        
        Args:
            id_mantenimiento: ID del mantenimiento a actualizar
            datos: Diccionario con campos a actualizar
            
        Returns:
            True si se actualizó correctamente
        """
        try:
            # Verificar que el mantenimiento existe
            if not self.obtener_por_id(id_mantenimiento):
                raise ValueError(f"No existe mantenimiento con ID: {id_mantenimiento}")
            
            campos_actualizar = []
            valores = []
            
            # Campos actualizables
            if 'tipo' in datos:
                campos_actualizar.append("tipo = ?")
                valores.append(str(datos['tipo']).strip())
            
            if 'fecha_realizada' in datos:
                campos_actualizar.append("fecha_realizada = ?")
                valores.append(self._formatear_fecha(datos['fecha_realizada']))
            
            if 'descripcion' in datos:
                campos_actualizar.append("descripcion = ?")
                valores.append(str(datos['descripcion']).strip())
            
            if 'costo_total' in datos:
                campos_actualizar.append("costo_total = ?")
                valores.append(float(datos['costo_total']))
            
            if 'responsable' in datos:
                # Validar que exista el empleado
                with self.db.get_connection() as conn:
                    cursor = conn.cursor()
                    cursor.execute("SELECT id_empleado FROM Empleados WHERE id_empleado = ?", 
                                 (datos['responsable'],))
                    if not cursor.fetchone():
                        raise ValueError(f"No existe empleado con ID: {datos['responsable']}")
                
                campos_actualizar.append("responsable = ?")
                valores.append(int(datos['responsable']))
            
            if 'estado' in datos:
                campos_actualizar.append("estado = ?")
                valores.append(str(datos['estado']).strip())
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar")
                return False
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = f"UPDATE Mantenimientos SET {', '.join(campos_actualizar)} WHERE id_mantenimiento = ?"
                valores.append(id_mantenimiento)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                
                if filas_afectadas > 0:
                    logger.info(f"Mantenimiento actualizado: ID {id_mantenimiento}")
                    return True
                else:
                    logger.warning(f"No se actualizó ninguna fila para ID: {id_mantenimiento}")
                    return False
                    
        except ValueError as ve:
            logger.warning(f"Validación fallida al actualizar mantenimiento: {str(ve)}")
            raise ErrorConsulta(str(ve))
        except Exception as e:
            logger.error(f"Error al actualizar mantenimiento: {str(e)}")
            raise ErrorConsulta(f"Error al actualizar mantenimiento: {str(e)}")
    
    @cache_invalidator('mantenimientos')
    def eliminar(self, id_mantenimiento: int) -> bool:
        """
        Elimina un mantenimiento de la base de datos.
        
        Args:
            id_mantenimiento: ID del mantenimiento a eliminar
            
        Returns:
            True si se eliminó correctamente
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM Mantenimientos WHERE id_mantenimiento = ?"
                cursor.execute(query, (id_mantenimiento,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                
                if filas_afectadas > 0:
                    logger.info(f"Mantenimiento eliminado: ID {id_mantenimiento}")
                    return True
                else:
                    logger.warning(f"No se eliminó ninguna fila para ID: {id_mantenimiento}")
                    return False
                    
        except Exception as e:
            logger.error(f"Error al eliminar mantenimiento: {str(e)}")
            raise ErrorConsulta(f"Error al eliminar mantenimiento: {str(e)}")
    
    def filtrar(self, filtros: Dict) -> List[Dict]:
        """
        Filtra mantenimientos según criterios específicos.
        
        Args:
            filtros: Diccionario con criterios de filtrado
                - id_maquinaria: ID de maquinaria
                - tipo: Tipo de mantenimiento
                - estado: Estado del mantenimiento
                - fecha_desde: Fecha inicial (YYYY-MM-DD)
                - fecha_hasta: Fecha final (YYYY-MM-DD)
                - responsable: ID del empleado responsable
                
        Returns:
            Lista de mantenimientos que cumplen los criterios
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT m.id_mantenimiento, m.id_maquinaria, m.tipo, m.fecha_realizada,
                       m.descripcion, m.costo_total, m.responsable, m.estado,
                       maq.codigo as maquinaria_codigo, maq.nombre as maquinaria_nombre,
                       emp.nombre as responsable_nombre, emp.apellido as responsable_apellido
                FROM Mantenimientos m
                INNER JOIN Maquinaria maq ON m.id_maquinaria = maq.id_maquinaria
                INNER JOIN Empleados emp ON m.responsable = emp.id_empleado
                WHERE 1=1
                """
                
                valores = []
                
                if 'id_maquinaria' in filtros and filtros['id_maquinaria']:
                    query += " AND m.id_maquinaria = ?"
                    valores.append(filtros['id_maquinaria'])
                
                if 'tipo' in filtros and filtros['tipo']:
                    query += " AND m.tipo = ?"
                    valores.append(filtros['tipo'])
                
                if 'estado' in filtros and filtros['estado']:
                    query += " AND m.estado = ?"
                    valores.append(filtros['estado'])
                
                if 'fecha_desde' in filtros and filtros['fecha_desde']:
                    query += " AND m.fecha_realizada >= ?"
                    valores.append(self._formatear_fecha(filtros['fecha_desde']))
                
                if 'fecha_hasta' in filtros and filtros['fecha_hasta']:
                    query += " AND m.fecha_realizada <= ?"
                    valores.append(self._formatear_fecha(filtros['fecha_hasta']))
                
                if 'responsable' in filtros and filtros['responsable']:
                    query += " AND m.responsable = ?"
                    valores.append(filtros['responsable'])
                
                query += " ORDER BY m.fecha_realizada DESC, m.id_mantenimiento DESC"
                
                cursor.execute(query, valores)
                
                mantenimientos = []
                for row in cursor.fetchall():
                    mantenimiento = {
                        'id_mantenimiento': int(row.id_mantenimiento),
                        'id_maquinaria': int(row.id_maquinaria),
                        'tipo': str(row.tipo).strip(),
                        'fecha_realizada': self._formatear_fecha(row.fecha_realizada),
                        'descripcion': str(row.descripcion).strip() if row.descripcion else "",
                        'costo_total': float(row.costo_total),
                        'responsable': int(row.responsable),
                        'estado': str(row.estado).strip(),
                        'maquinaria_codigo': str(row.maquinaria_codigo).strip(),
                        'maquinaria_nombre': str(row.maquinaria_nombre).strip(),
                        'responsable_nombre': f"{row.responsable_nombre} {row.responsable_apellido}".strip()
                    }
                    mantenimientos.append(mantenimiento)
                
                logger.info(f"Filtro aplicado. {len(mantenimientos)} mantenimientos encontrados")
                return mantenimientos
                
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
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Total de mantenimientos
                query_total = "SELECT COUNT(*) FROM Mantenimientos"
                valores = []
                if id_maquinaria:
                    query_total += " WHERE id_maquinaria = ?"
                    valores.append(id_maquinaria)
                
                cursor.execute(query_total, valores)
                total = cursor.fetchone()[0]
                
                # Costo total
                query_costo = "SELECT COALESCE(SUM(costo_total), 0) FROM Mantenimientos"
                if id_maquinaria:
                    query_costo += " WHERE id_maquinaria = ?"
                
                cursor.execute(query_costo, valores)
                costo_total = float(cursor.fetchone()[0])
                
                # Por tipo
                query_tipo = """
                SELECT tipo, COUNT(*) as cantidad, SUM(costo_total) as costo
                FROM Mantenimientos
                """
                if id_maquinaria:
                    query_tipo += " WHERE id_maquinaria = ?"
                query_tipo += " GROUP BY tipo"
                
                cursor.execute(query_tipo, valores)
                por_tipo = {}
                for row in cursor.fetchall():
                    por_tipo[row.tipo] = {
                        'cantidad': row.cantidad,
                        'costo_total': float(row.costo)
                    }
                
                # Por estado
                query_estado = """
                SELECT estado, COUNT(*) as cantidad
                FROM Mantenimientos
                """
                if id_maquinaria:
                    query_estado += " WHERE id_maquinaria = ?"
                query_estado += " GROUP BY estado"
                
                cursor.execute(query_estado, valores)
                por_estado = {row.estado: row.cantidad for row in cursor.fetchall()}
                
                estadisticas = {
                    'total_mantenimientos': total,
                    'costo_total': costo_total,
                    'costo_promedio': costo_total / total if total > 0 else 0,
                    'por_tipo': por_tipo,
                    'por_estado': por_estado
                }
                
                logger.info("Estadísticas de mantenimientos generadas")
                return estadisticas
                
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de mantenimientos: {str(e)}")
            raise ErrorConsulta(f"Error al obtener estadísticas: {str(e)}")