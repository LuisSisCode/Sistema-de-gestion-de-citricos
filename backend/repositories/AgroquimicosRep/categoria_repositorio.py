# backend/repositories/AgroquimicosRep/categoria_repositorio.py
"""
Repositorio para gestión de Categorías de Agroquímicos
Maneja el acceso a datos de la tabla CategoriaAgroquimicos
"""

import logging
from typing import List, Dict, Optional, Tuple
from backend.core.repositorio_base import RepositorioBase
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class CategoriaRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de Categorías de Agroquímicos"""
    
    def __init__(self):
        super().__init__()
        self.tabla = "CategoriaAgroquimicos"
    
    # ==================== CONSULTAS ====================
    
    @cacheable('categorias_agroquimicos', ttl=get_ttl('categorias_agroquimicos'))
    def obtener_todas(self) -> List[Dict]:
        """
        Obtiene todas las categorías de agroquímicos
        
        Returns:
            List[Dict]: Lista de categorías con sus datos
        """
        query = """
        SELECT id_categoria, nombre, descripcion, activo
        FROM CategoriaAgroquimicos
        ORDER BY nombre
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                categorias = []
                for row in cursor.fetchall():
                    categoria = {
                        'id_categoria': row.id_categoria,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'activo': bool(row.activo)
                    }
                    categorias.append(categoria)
                
                logger.info(f"Se obtuvieron {len(categorias)} categorías de la base de datos")
                return categorias
                
        except Exception as e:
            logger.error(f"Error al obtener categorías: {str(e)}")
            return []
    
    def obtener_por_id(self, id_categoria: int) -> Optional[Dict]:
        """
        Obtiene una categoría específica por su ID
        
        Args:
            id_categoria: ID de la categoría a buscar
            
        Returns:
            Dict: Datos de la categoría o None si no existe
        """
        query = """
        SELECT id_categoria, nombre, descripcion, activo
        FROM CategoriaAgroquimicos
        WHERE id_categoria = ?
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_categoria,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                return {
                    'id_categoria': row.id_categoria,
                    'nombre': row.nombre,
                    'descripcion': row.descripcion,
                    'activo': bool(row.activo)
                }
                
        except Exception as e:
            logger.error(f"Error al obtener categoría {id_categoria}: {str(e)}")
            return None
    
    def obtener_activas(self) -> List[Dict]:
        """
        Obtiene solo las categorías activas
        
        Returns:
            List[Dict]: Lista de categorías activas
        """
        query = """
        SELECT id_categoria, nombre, descripcion, activo
        FROM CategoriaAgroquimicos
        WHERE activo = 1
        ORDER BY nombre
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                categorias = []
                for row in cursor.fetchall():
                    categoria = {
                        'id_categoria': row.id_categoria,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'activo': bool(row.activo)
                    }
                    categorias.append(categoria)
                
                return categorias
                
        except Exception as e:
            logger.error(f"Error al obtener categorías activas: {str(e)}")
            return []
    
    def obtener_con_conteo_productos(self) -> List[Dict]:
        """
        Obtiene categorías con el conteo de productos que tiene cada una
        
        Returns:
            List[Dict]: Lista de categorías con conteo de productos
        """
        query = """
        SELECT c.id_categoria, c.nombre, c.descripcion, c.activo,
               COUNT(p.id_producto) as total_productos,
               SUM(CASE WHEN p.activo = 1 THEN 1 ELSE 0 END) as productos_activos
        FROM CategoriaAgroquimicos c
        LEFT JOIN ProductosAgroquimicos p ON c.id_categoria = p.id_categoria
        GROUP BY c.id_categoria, c.nombre, c.descripcion, c.activo
        ORDER BY c.nombre
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                categorias = []
                for row in cursor.fetchall():
                    categoria = {
                        'id_categoria': row.id_categoria,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'activo': bool(row.activo),
                        'total_productos': row.total_productos,
                        'productos_activos': row.productos_activos
                    }
                    categorias.append(categoria)
                
                return categorias
                
        except Exception as e:
            logger.error(f"Error al obtener categorías con conteo: {str(e)}")
            return []
    
    # ==================== INSERCIÓN ====================
    
    @cache_invalidator('categorias_agroquimicos')
    @cache_invalidator('agroquimicos')
    def crear(self, datos: Dict) -> Tuple[bool, Optional[int]]:
        """
        Crea una nueva categoría de agroquímicos
        
        Args:
            datos: Diccionario con los datos de la categoría
                - nombre (str): Nombre de la categoría
                - descripcion (str, optional): Descripción de la categoría
                - activo (bool, optional): Estado activo (default: True)
                
        Returns:
            Tuple[bool, Optional[int]]: (Éxito, ID de la categoría creada)
        """
        query = """
        INSERT INTO CategoriaAgroquimicos (nombre, descripcion, activo)
        VALUES (?, ?, ?)
        """
        
        try:
            valores = (
                datos['nombre'],
                datos.get('descripcion'),
                1 if datos.get('activo', True) else 0
            )
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID generado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_categoria = cursor.fetchone()[0]
                
                logger.info(f"Categoría creada correctamente con ID: {id_categoria}")
                return True, id_categoria
                
        except Exception as e:
            logger.error(f"Error al crear categoría: {str(e)}")
            return False, None
    
    # ==================== ACTUALIZACIÓN ====================
    
    @cache_invalidator('categorias_agroquimicos')
    @cache_invalidator('agroquimicos')
    def actualizar(self, id_categoria: int, datos: Dict) -> bool:
        """
        Actualiza una categoría existente
        
        Args:
            id_categoria: ID de la categoría a actualizar
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
                    # Convertir booleano a int para el campo activo
                    if campo == 'activo':
                        valores.append(1 if datos[campo] else 0)
                    else:
                        valores.append(datos[campo])
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar")
                return False
            
            # Agregar el ID al final
            valores.append(id_categoria)
            
            query = f"UPDATE CategoriaAgroquimicos SET {', '.join(campos_actualizar)} WHERE id_categoria = ?"
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Categoría {id_categoria} actualizada. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al actualizar categoría {id_categoria}: {str(e)}")
            return False
    
    # ==================== ELIMINACIÓN ====================
    
    @cache_invalidator('categorias_agroquimicos')
    @cache_invalidator('agroquimicos')
    def eliminar(self, id_categoria: int) -> bool:
        """
        Elimina (desactiva) una categoría
        
        Args:
            id_categoria: ID de la categoría a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
        query = "UPDATE CategoriaAgroquimicos SET activo = 0 WHERE id_categoria = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_categoria,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Categoría {id_categoria} eliminada (desactivada)")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al eliminar categoría {id_categoria}: {str(e)}")
            return False
    
    def eliminar_permanente(self, id_categoria: int) -> bool:
        """
        Elimina permanentemente una categoría de la base de datos
        ⚠️ USAR CON PRECAUCIÓN - Debe verificarse que no tenga productos asociados
        
        Args:
            id_categoria: ID de la categoría a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
        query = "DELETE FROM CategoriaAgroquimicos WHERE id_categoria = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_categoria,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.warning(f"Categoría {id_categoria} eliminada PERMANENTEMENTE")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al eliminar permanentemente categoría {id_categoria}: {str(e)}")
            return False
    
    # ==================== UTILIDADES ====================
    
    def tiene_productos(self, id_categoria: int) -> bool:
        """
        Verifica si una categoría tiene productos asociados
        
        Args:
            id_categoria: ID de la categoría
            
        Returns:
            bool: True si tiene productos
        """
        query = """
        SELECT COUNT(*) 
        FROM ProductosAgroquimicos 
        WHERE id_categoria = ?
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_categoria,))
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar productos de categoría {id_categoria}: {str(e)}")
            return False
    
    def contar_categorias(self, solo_activas: bool = True) -> int:
        """
        Cuenta el total de categorías
        
        Args:
            solo_activas: Si True, cuenta solo categorías activas
            
        Returns:
            int: Cantidad de categorías
        """
        query = "SELECT COUNT(*) FROM CategoriaAgroquimicos"
        if solo_activas:
            query += " WHERE activo = 1"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                return cursor.fetchone()[0]
                
        except Exception as e:
            logger.error(f"Error al contar categorías: {str(e)}")
            return 0
    
    def existe(self, id_categoria: int) -> bool:
        """
        Verifica si una categoría existe
        
        Args:
            id_categoria: ID de la categoría
            
        Returns:
            bool: True si existe
        """
        query = "SELECT COUNT(*) FROM CategoriaAgroquimicos WHERE id_categoria = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_categoria,))
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar existencia de categoría {id_categoria}: {str(e)}")
            return False
    
    def existe_nombre(self, nombre: str, excluir_id: Optional[int] = None) -> bool:
        """
        Verifica si ya existe una categoría con ese nombre
        
        Args:
            nombre: Nombre a verificar
            excluir_id: ID de categoría a excluir de la búsqueda (útil para ediciones)
            
        Returns:
            bool: True si el nombre ya existe
        """
        query = "SELECT COUNT(*) FROM CategoriaAgroquimicos WHERE nombre = ?"
        params = [nombre]
        
        if excluir_id:
            query += " AND id_categoria != ?"
            params.append(excluir_id)
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params)
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar nombre de categoría: {str(e)}")
            return False