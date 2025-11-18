# backend/repositories/AgroquimicosRep/mezcla_repositorio.py
"""
Repositorio para gestión de Mezclas de Agroquímicos
Maneja el acceso a datos de las tablas MezclasAgroquimicos y DetallesMezclas
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
        """
        Obtiene todas las mezclas de agroquímicos
        
        Returns:
            List[Dict]: Lista de mezclas con sus datos
        """
        query = """
        SELECT id_mezcla, nombre, descripcion, fecha_creacion, activo
        FROM MezclasAgroquimicos
        ORDER BY fecha_creacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                mezclas = []
                for row in cursor.fetchall():
                    # Formatear fecha
                    fecha_creacion = None
                    if row.fecha_creacion:
                        if isinstance(row.fecha_creacion, str):
                            fecha_creacion = row.fecha_creacion
                        else:
                            fecha_creacion = row.fecha_creacion.strftime('%Y-%m-%d')
                    
                    mezcla = {
                        'id_mezcla': row.id_mezcla,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'fecha_creacion': fecha_creacion,
                        'activo': bool(row.activo)
                    }
                    mezclas.append(mezcla)
                
                logger.info(f"Se obtuvieron {len(mezclas)} mezclas de la base de datos")
                return mezclas
                
        except Exception as e:
            logger.error(f"Error al obtener mezclas: {str(e)}")
            return []
    
    def obtener_por_id(self, id_mezcla: int) -> Optional[Dict]:
        """
        Obtiene una mezcla específica por su ID
        
        Args:
            id_mezcla: ID de la mezcla a buscar
            
        Returns:
            Dict: Datos de la mezcla o None si no existe
        """
        query = """
        SELECT id_mezcla, nombre, descripcion, fecha_creacion, activo
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
                
                # Formatear fecha
                fecha_creacion = None
                if row.fecha_creacion:
                    if isinstance(row.fecha_creacion, str):
                        fecha_creacion = row.fecha_creacion
                    else:
                        fecha_creacion = row.fecha_creacion.strftime('%Y-%m-%d')
                
                return {
                    'id_mezcla': row.id_mezcla,
                    'nombre': row.nombre,
                    'descripcion': row.descripcion,
                    'fecha_creacion': fecha_creacion,
                    'activo': bool(row.activo)
                }
                
        except Exception as e:
            logger.error(f"Error al obtener mezcla {id_mezcla}: {str(e)}")
            return None
    
    def obtener_activas(self) -> List[Dict]:
        """
        Obtiene solo las mezclas activas
        
        Returns:
            List[Dict]: Lista de mezclas activas
        """
        query = """
        SELECT id_mezcla, nombre, descripcion, fecha_creacion, activo
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
                    fecha_creacion = None
                    if row.fecha_creacion:
                        if isinstance(row.fecha_creacion, str):
                            fecha_creacion = row.fecha_creacion
                        else:
                            fecha_creacion = row.fecha_creacion.strftime('%Y-%m-%d')
                    
                    mezcla = {
                        'id_mezcla': row.id_mezcla,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'fecha_creacion': fecha_creacion,
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
        """
        Obtiene los detalles (productos) de una mezcla específica
        
        Args:
            id_mezcla: ID de la mezcla
            
        Returns:
            List[Dict]: Lista de productos que componen la mezcla
        """
        query = """
        SELECT dm.id_detalle, dm.id_mezcla, dm.id_producto, 
               p.nombre_comercial, p.unidad,
               dm.dosis, dm.orden
        FROM DetallesMezclas dm
        JOIN ProductosAgroquimicos p ON dm.id_producto = p.id_producto
        WHERE dm.id_mezcla = ?
        ORDER BY dm.orden, dm.id_detalle
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                
                detalles = []
                for row in cursor.fetchall():
                    detalle = {
                        'id_detalle': row.id_detalle,
                        'id_mezcla': row.id_mezcla,
                        'id_producto': row.id_producto,
                        'nombre_producto': row.nombre_comercial,
                        'unidad': row.unidad,
                        'dosis': float(row.dosis) if row.dosis else 0.0,
                        'orden': row.orden
                    }
                    detalles.append(detalle)
                
                logger.info(f"Se obtuvieron {len(detalles)} productos para la mezcla {id_mezcla}")
                return detalles
                
        except Exception as e:
            logger.error(f"Error al obtener detalles de mezcla {id_mezcla}: {str(e)}")
            return []
    
    def obtener_mezcla_completa(self, id_mezcla: int) -> Optional[Dict]:
        """
        Obtiene una mezcla con todos sus detalles (productos)
        
        Args:
            id_mezcla: ID de la mezcla
            
        Returns:
            Dict: Mezcla con sus productos o None si no existe
        """
        mezcla = self.obtener_por_id(id_mezcla)
        if not mezcla:
            return None
        
        mezcla['productos'] = self.obtener_detalles(id_mezcla)
        return mezcla
    
    # ==================== INSERCIÓN ====================
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def crear(self, datos: Dict, detalles: Optional[List[Dict]] = None) -> Tuple[bool, Optional[int]]:
        """
        Crea una nueva mezcla de agroquímicos con sus detalles
        
        Args:
            datos: Diccionario con los datos de la mezcla
                - nombre (str): Nombre de la mezcla
                - descripcion (str, optional): Propósito de la mezcla
                - fecha_creacion (date, optional): Fecha de creación (default: hoy)
                - activo (bool, optional): Estado activo (default: True)
            detalles: Lista de productos que componen la mezcla (opcional)
                Cada detalle debe tener:
                - id_producto (int): ID del producto
                - dosis (float): Dosis del producto
                - orden (int, optional): Orden de aplicación
                
        Returns:
            Tuple[bool, Optional[int]]: (Éxito, ID de la mezcla creada)
        """
        query_mezcla = """
        INSERT INTO MezclasAgroquimicos (nombre, descripcion, fecha_creacion, activo)
        VALUES (?, ?, ?, ?)
        """
        
        try:
            fecha_actual = datos.get('fecha_creacion', date.today())
            
            valores = (
                datos['nombre'],
                datos.get('descripcion'),
                fecha_actual,
                1 if datos.get('activo', True) else 0
            )
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                # Insertar la mezcla
                cursor.execute(query_mezcla, valores)
                
                # Obtener el ID generado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_mezcla = cursor.fetchone()[0]
                
                # Si hay detalles, insertarlos
                if detalles:
                    query_detalle = """
                    INSERT INTO DetallesMezclas (id_mezcla, id_producto, dosis, orden)
                    VALUES (?, ?, ?, ?)
                    """
                    
                    for idx, detalle in enumerate(detalles, start=1):
                        valores_detalle = (
                            id_mezcla,
                            detalle['id_producto'],
                            detalle['dosis'],
                            detalle.get('orden', idx)
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
    def agregar_producto_a_mezcla(self, id_mezcla: int, id_producto: int, dosis: float, orden: Optional[int] = None) -> bool:
        """
        Agrega un producto a una mezcla existente
        
        Args:
            id_mezcla: ID de la mezcla
            id_producto: ID del producto a agregar
            dosis: Dosis del producto
            orden: Orden de aplicación (opcional)
            
        Returns:
            bool: True si se agregó correctamente
        """
        query = """
        INSERT INTO DetallesMezclas (id_mezcla, id_producto, dosis, orden)
        VALUES (?, ?, ?, ?)
        """
        
        try:
            # Si no se especifica orden, usar el siguiente disponible
            if orden is None:
                orden = self._obtener_siguiente_orden(id_mezcla)
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla, id_producto, dosis, orden))
                conn.commit()
                
                logger.info(f"Producto {id_producto} agregado a mezcla {id_mezcla}")
                return True
                
        except Exception as e:
            logger.error(f"Error al agregar producto a mezcla: {str(e)}")
            return False
    
    # ==================== ACTUALIZACIÓN ====================
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def actualizar(self, id_mezcla: int, datos: Dict) -> bool:
        """
        Actualiza una mezcla existente
        
        Args:
            id_mezcla: ID de la mezcla a actualizar
            datos: Diccionario con los campos a actualizar
            
        Returns:
            bool: True si se actualizó correctamente
        """
        try:
            campos_actualizar = []
            valores = []
            
            # Construir dinámicamente los campos a actualizar
            campos_permitidos = ['nombre', 'descripcion', 'activo']
            
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
    def actualizar_detalle(self, id_detalle: int, dosis: Optional[float] = None, orden: Optional[int] = None) -> bool:
        """
        Actualiza un detalle de mezcla
        
        Args:
            id_detalle: ID del detalle a actualizar
            dosis: Nueva dosis (opcional)
            orden: Nuevo orden (opcional)
            
        Returns:
            bool: True si se actualizó correctamente
        """
        try:
            campos_actualizar = []
            valores = []
            
            if dosis is not None:
                campos_actualizar.append("dosis = ?")
                valores.append(dosis)
            
            if orden is not None:
                campos_actualizar.append("orden = ?")
                valores.append(orden)
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar en el detalle")
                return False
            
            valores.append(id_detalle)
            
            query = f"UPDATE DetallesMezclas SET {', '.join(campos_actualizar)} WHERE id_detalle = ?"
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Detalle {id_detalle} actualizado")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al actualizar detalle {id_detalle}: {str(e)}")
            return False
    
    # ==================== ELIMINACIÓN ====================
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def eliminar(self, id_mezcla: int) -> bool:
        """
        Elimina (desactiva) una mezcla
        
        Args:
            id_mezcla: ID de la mezcla a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
        query = "UPDATE MezclasAgroquimicos SET activo = 0 WHERE id_mezcla = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Mezcla {id_mezcla} eliminada (desactivada)")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al eliminar mezcla {id_mezcla}: {str(e)}")
            return False
    
    @cache_invalidator('detalles_mezcla')
    def eliminar_producto_de_mezcla(self, id_detalle: int) -> bool:
        """
        Elimina un producto de una mezcla
        
        Args:
            id_detalle: ID del detalle a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
        query = "DELETE FROM DetallesMezclas WHERE id_detalle = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_detalle,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Detalle {id_detalle} eliminado de la mezcla")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al eliminar detalle {id_detalle}: {str(e)}")
            return False
    
    @cache_invalidator('mezclas_agroquimicos')
    @cache_invalidator('detalles_mezcla')
    def eliminar_todos_productos(self, id_mezcla: int) -> bool:
        """
        Elimina todos los productos de una mezcla
        
        Args:
            id_mezcla: ID de la mezcla
            
        Returns:
            bool: True si se eliminaron correctamente
        """
        query = "DELETE FROM DetallesMezclas WHERE id_mezcla = ?"
        
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
        """
        Cuenta el total de mezclas
        
        Args:
            solo_activas: Si True, cuenta solo mezclas activas
            
        Returns:
            int: Cantidad de mezclas
        """
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
        """
        Cuenta cuántos productos tiene una mezcla
        
        Args:
            id_mezcla: ID de la mezcla
            
        Returns:
            int: Cantidad de productos
        """
        query = "SELECT COUNT(*) FROM DetallesMezclas WHERE id_mezcla = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                return cursor.fetchone()[0]
                
        except Exception as e:
            logger.error(f"Error al contar productos de mezcla: {str(e)}")
            return 0
    
    def existe(self, id_mezcla: int) -> bool:
        """
        Verifica si una mezcla existe
        
        Args:
            id_mezcla: ID de la mezcla
            
        Returns:
            bool: True si existe
        """
        query = "SELECT COUNT(*) FROM MezclasAgroquimicos WHERE id_mezcla = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar existencia de mezcla {id_mezcla}: {str(e)}")
            return False
    
    def _obtener_siguiente_orden(self, id_mezcla: int) -> int:
        """
        Obtiene el siguiente número de orden disponible para una mezcla
        
        Args:
            id_mezcla: ID de la mezcla
            
        Returns:
            int: Siguiente orden disponible
        """
        query = "SELECT ISNULL(MAX(orden), 0) + 1 FROM DetallesMezclas WHERE id_mezcla = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_mezcla,))
                return cursor.fetchone()[0]
                
        except Exception as e:
            logger.error(f"Error al obtener siguiente orden: {str(e)}")
            return 1