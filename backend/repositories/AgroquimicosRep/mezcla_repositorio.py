# backend/repositories/AgroquimicosRep/mezcla_repositorio.py
"""
Repositorio para gestión de Mezclas de Agroquímicos
Maneja el acceso a datos de las tablas MezclasAgroquimicos y DetallesMezcla
"""

import logging
from datetime import date
from typing import List, Dict, Optional, Tuple
from backend.core.repositorio_base import RepositorioBase
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class MezclaRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de Mezclas de Agroquímicos"""
    
    def __init__(self):
        super().__init__()
        self.tabla = "MezclasAgroquimicos"
    
    # ==================== CONSULTAS DE MEZCLAS ====================
    
    @cacheable('mezclas_agroquimicos', ttl=get_ttl('mezclas'))
    def obtener_todas(self) -> List[Dict]:
        """Obtiene todas las mezclas de agroquímicos"""
        query = """
        SELECT id_mezcla, nombre, descripcion, cantidad_agua, area_aplicacion,
               objetivo, indicaciones, fecha_creacion, activo
        FROM MezclasAgroquimicos
        ORDER BY fecha_creacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                mezclas = []
                for row in cursor.fetchall():
                    mezcla = {
                        'id_mezcla': row.id_mezcla,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                        'area_aplicacion': float(row.area_aplicacion) if row.area_aplicacion else 0.0,
                        'objetivo': row.objetivo,
                        'indicaciones': row.indicaciones,
                        'fecha_creacion': self._formatear_fecha(row.fecha_creacion),
                        'activo': bool(row.activo)
                    }
                    mezclas.append(mezcla)
                
                logger.info(f"Se obtuvieron {len(mezclas)} mezclas")
                return mezclas
                
        except Exception as e:
            logger.error(f"Error al obtener mezclas: {str(e)}")
            return []
    
    def obtener_por_id(self, id_mezcla: int) -> Optional[Dict]:
        """Obtiene una mezcla específica por su ID"""
        query = """
        SELECT id_mezcla, nombre, descripcion, cantidad_agua, area_aplicacion,
               objetivo, indicaciones, fecha_creacion, activo
        FROM MezclasAgroquimicos
        WHERE id_mezcla = ?
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                return {
                    'id_mezcla': row.id_mezcla,
                    'nombre': row.nombre,
                    'descripcion': row.descripcion,
                    'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                    'area_aplicacion': float(row.area_aplicacion) if row.area_aplicacion else 0.0,
                    'objetivo': row.objetivo,
                    'indicaciones': row.indicaciones,
                    'fecha_creacion': self._formatear_fecha(row.fecha_creacion),
                    'activo': bool(row.activo)
                }
                
        except Exception as e:
            logger.error(f"Error al obtener mezcla {id_mezcla}: {str(e)}")
            return None
    
    def obtener_activas(self) -> List[Dict]:
        """Obtiene solo las mezclas activas"""
        query = """
        SELECT id_mezcla, nombre, descripcion, cantidad_agua, area_aplicacion,
               objetivo, fecha_creacion, activo
        FROM MezclasAgroquimicos
        WHERE activo = 1
        ORDER BY fecha_creacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                mezclas = []
                for row in cursor.fetchall():
                    mezcla = {
                        'id_mezcla': row.id_mezcla,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                        'area_aplicacion': float(row.area_aplicacion) if row.area_aplicacion else 0.0,
                        'objetivo': row.objetivo,
                        'fecha_creacion': self._formatear_fecha(row.fecha_creacion),
                        'activo': bool(row.activo)
                    }
                    mezclas.append(mezcla)
                
                return mezclas
                
        except Exception as e:
            logger.error(f"Error al obtener mezclas activas: {str(e)}")
            return []
    
    # ==================== CONSULTAS DE DETALLES DE MEZCLAS ====================
    
    @cacheable('detalles_mezcla', ttl=get_ttl('mezclas'))
    def obtener_detalles(self, id_mezcla: int) -> List[Dict]:
        """Obtiene los detalles (productos) de una mezcla específica"""
        query = """
        SELECT dm.id_detalle_mezcla, dm.id_mezcla, dm.id_producto, 
               p.nombre_comercial, p.unidad as unidad_producto,
               dm.cantidad, dm.unidad_medida, dm.observaciones
        FROM DetallesMezcla dm
        JOIN ProductosAgroquimicos p ON dm.id_producto = p.id_producto
        WHERE dm.id_mezcla = ?
        ORDER BY dm.id_detalle_mezcla
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                
                detalles = []
                for row in cursor.fetchall():
                    detalle = {
                        'id_detalle_mezcla': row.id_detalle_mezcla,
                        'id_mezcla': row.id_mezcla,
                        'id_producto': row.id_producto,
                        'nombre_producto': row.nombre_comercial,
                        'unidad_producto': row.unidad_producto,
                        'cantidad': float(row.cantidad) if row.cantidad else 0.0,
                        'unidad_medida': row.unidad_medida,
                        'observaciones': row.observaciones
                    }
                    detalles.append(detalle)
                
                logger.info(f"Se obtuvieron {len(detalles)} productos para la mezcla {id_mezcla}")
                return detalles
                
        except Exception as e:
            logger.error(f"Error al obtener detalles de mezcla {id_mezcla}: {str(e)}")
            return []
    
    def obtener_mezcla_completa(self, id_mezcla: int) -> Optional[Dict]:
        """Obtiene una mezcla con todos sus detalles (productos)"""
        mezcla = self.obtener_por_id(id_mezcla)
        if not mezcla:
            return None
        
        mezcla['detalles'] = self.obtener_detalles(id_mezcla)
        return mezcla
    
    # ==================== INSERCIÓN ====================
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def crear(self, datos: Dict, detalles: Optional[List[Dict]] = None) -> Tuple[bool, Optional[int]]:
        """Crea una nueva mezcla de agroquímicos con sus detalles"""
        query_mezcla = """
        INSERT INTO MezclasAgroquimicos 
        (nombre, descripcion, cantidad_agua, area_aplicacion, objetivo, indicaciones, fecha_creacion, activo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        try:
            fecha_actual = datos.get('fecha_creacion', date.today())
            
            valores = (
                datos['nombre'],
                datos.get('descripcion'),
                datos.get('cantidad_agua'),
                datos.get('area_aplicacion'),
                datos.get('objetivo'),
                datos.get('indicaciones'),
                fecha_actual,
                1 if datos.get('activo', True) else 0
            )
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                # Insertar la mezcla
                cursor.execute(query_mezcla, valores)
                id_mezcla = self._obtener_ultimo_id()
                
                # Si hay detalles, insertarlos
                if detalles:
                    query_detalle = """
                    INSERT INTO DetallesMezcla (id_mezcla, id_producto, cantidad, unidad_medida, observaciones)
                    VALUES (?, ?, ?, ?, ?)
                    """
                    
                    for detalle in detalles:
                        valores_detalle = (
                            id_mezcla,
                            detalle['id_producto'],
                            detalle['cantidad'],
                            detalle.get('unidad_medida', 'ml'),
                            detalle.get('observaciones')
                        )
                        cursor.execute(query_detalle, valores_detalle)
                
                conn.commit()
                
                logger.info(f"Mezcla creada correctamente con ID: {id_mezcla}")
                if detalles:
                    logger.info(f"Se agregaron {len(detalles)} productos a la mezcla")
                
                return True, id_mezcla
                
        except Exception as e:
            logger.error(f"Error al crear mezcla: {str(e)}")
            return False, None
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def agregar_producto_a_mezcla(self, id_mezcla: int, datos_detalle: Dict) -> bool:
        """Agrega un producto a una mezcla existente"""
        query = """
        INSERT INTO DetallesMezla (id_mezcla, id_producto, cantidad, unidad_medida, observaciones)
        VALUES (?, ?, ?, ?, ?)
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (
                    id_mezcla,
                    datos_detalle['id_producto'],
                    datos_detalle['cantidad'],
                    datos_detalle.get('unidad_medida', 'ml'),
                    datos_detalle.get('observaciones')
                ))
                conn.commit()
                
                logger.info(f"Producto {datos_detalle['id_producto']} agregado a mezcla {id_mezcla}")
                return True
                
        except Exception as e:
            logger.error(f"Error al agregar producto a mezcla: {str(e)}")
            return False
    
    # ==================== ACTUALIZACIÓN ====================
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def actualizar(self, id_mezcla: int, datos: Dict) -> bool:
        """Actualiza una mezcla existente"""
        try:
            campos_actualizar = []
            valores = []
            
            campos_permitidos = ['nombre', 'descripcion', 'cantidad_agua', 'area_aplicacion',
                               'objetivo', 'indicaciones', 'activo']
            
            for campo in campos_permitidos:
                if campo in datos:
                    campos_actualizar.append(f"{campo} = ?")
                    if campo == 'activo':
                        valores.append(1 if datos[campo] else 0)
                    else:
                        valores.append(datos[campo])
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar")
                return False
            
            valores.append(id_mezcla)
            query = f"UPDATE MezclasAgroquimicos SET {', '.join(campos_actualizar)} WHERE id_mezcla = ?"
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Mezcla {id_mezcla} actualizada. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al actualizar mezcla {id_mezcla}: {str(e)}")
            return False
    
    @cache_invalidator('detalles_mezcla')
    def actualizar_detalle(self, id_detalle_mezcla: int, datos: Dict) -> bool:
        """Actualiza un detalle de mezcla"""
        try:
            campos_actualizar = []
            valores = []
            
            campos_permitidos = ['cantidad', 'unidad_medida', 'observaciones']
            
            for campo in campos_permitidos:
                if campo in datos:
                    campos_actualizar.append(f"{campo} = ?")
                    valores.append(datos[campo])
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar en el detalle")
                return False
            
            valores.append(id_detalle_mezcla)
            query = f"UPDATE DetallesMezcla SET {', '.join(campos_actualizar)} WHERE id_detalle_mezcla = ?"
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Detalle {id_detalle_mezcla} actualizado")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al actualizar detalle {id_detalle_mezcla}: {str(e)}")
            return False
    
    # ==================== ELIMINACIÓN ====================
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def eliminar(self, id_mezcla: int) -> bool:
        """Elimina (desactiva) una mezcla"""
        return self.actualizar(id_mezcla, {'activo': False})
    
    @cache_invalidator('detalles_mezcla')
    def eliminar_producto_de_mezcla(self, id_detalle_mezcla: int) -> bool:
        """Elimina un producto de una mezcla"""
        query = "DELETE FROM DetallesMezcla WHERE id_detalle_mezcla = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_detalle_mezcla,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Detalle {id_detalle_mezcla} eliminado de la mezcla")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al eliminar detalle {id_detalle_mezcla}: {str(e)}")
            return False
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def eliminar_todos_productos(self, id_mezcla: int) -> bool:
        """Elimina todos los productos de una mezcla"""
        query = "DELETE FROM DetallesMezcla WHERE id_mezcla = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Se eliminaron {filas_afectadas} productos de la mezcla {id_mezcla}")
                return True
                
        except Exception as e:
            logger.error(f"Error al eliminar productos de mezcla {id_mezcla}: {str(e)}")
            return False
    
    # ==================== UTILIDADES ====================
    
    def contar_mezclas(self, solo_activas: bool = True) -> int:
        """Cuenta el total de mezclas"""
        query = "SELECT COUNT(*) FROM MezclasAgroquimicos"
        if solo_activas:
            query += " WHERE activo = 1"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                return cursor.fetchone()[0]
                
        except Exception as e:
            logger.error(f"Error al contar mezclas: {str(e)}")
            return 0
    
    def contar_productos_en_mezcla(self, id_mezcla: int) -> int:
        """Cuenta cuántos productos tiene una mezcla"""
        query = "SELECT COUNT(*) FROM DetallesMezcla WHERE id_mezcla = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                return cursor.fetchone()[0]
                
        except Exception as e:
            logger.error(f"Error al contar productos de mezcla: {str(e)}")
            return 0
    
    def existe(self, id_mezcla: int) -> bool:
        """Verifica si una mezcla existe"""
        query = "SELECT COUNT(*) FROM MezclasAgroquimicos WHERE id_mezcla = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar existencia de mezcla {id_mezcla}: {str(e)}")
            return False
    
    def existe_nombre(self, nombre: str, excluir_id: Optional[int] = None) -> bool:
        """Verifica si ya existe una mezcla con ese nombre"""
        query = "SELECT COUNT(*) FROM MezclasAgroquimicos WHERE nombre = ?"
        params = [nombre]
        
        if excluir_id:
            query += " AND id_mezcla != ?"
            params.append(excluir_id)
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params)
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar nombre de mezcla: {str(e)}")
            return False
    
    def obtener_mezclas_por_producto(self, id_producto: int) -> List[Dict]:
        """Obtiene las mezclas que contienen un producto específico"""
        query = """
        SELECT m.id_mezcla, m.nombre, m.objetivo, m.fecha_creacion,
               dm.cantidad, dm.unidad_medida
        FROM MezclasAgroquimicos m
        JOIN DetallesMezcla dm ON m.id_mezcla = dm.id_mezcla
        WHERE dm.id_producto = ? AND m.activo = 1
        ORDER BY m.fecha_creacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_producto,))
                
                mezclas = []
                for row in cursor.fetchall():
                    mezcla = {
                        'id_mezcla': row.id_mezcla,
                        'nombre': row.nombre,
                        'objetivo': row.objetivo,
                        'fecha_creacion': self._formatear_fecha(row.fecha_creacion),
                        'cantidad_producto': float(row.cantidad),
                        'unidad_medida': row.unidad_medida
                    }
                    mezclas.append(mezcla)
                
                return mezclas
                
        except Exception as e:
            logger.error(f"Error al obtener mezclas por producto {id_producto}: {str(e)}")
            return []
    
    def obtener_estadisticas(self) -> Dict:
        """Obtiene estadísticas de mezclas"""
        query = """
        SELECT 
            COUNT(*) as total_mezclas,
            SUM(CASE WHEN activo = 1 THEN 1 ELSE 0 END) as mezclas_activas,
            (SELECT COUNT(DISTINCT id_producto) FROM DetallesMezcla) as productos_utilizados,
            (SELECT COUNT(*) FROM DetallesMezcla) as total_detalles
        FROM MezclasAgroquimicos
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                row = cursor.fetchone()
                
                return {
                    'total_mezclas': row[0],
                    'mezclas_activas': row[1],
                    'productos_utilizados': row[2],
                    'total_detalles': row[3]
                }
                
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de mezclas: {str(e)}")
            return {
                'total_mezclas': 0,
                'mezclas_activas': 0,
                'productos_utilizados': 0,
                'total_detalles': 0
            }