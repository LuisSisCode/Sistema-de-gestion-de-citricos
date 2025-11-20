# backend/repositories/AgroquimicosRep/producto_repositorio.py
"""
Repositorio para gestión de productos agroquímicos
Incluye funcionalidades de inventario y alertas de stock
"""

import logging
from typing import List, Optional, Dict, Any
from backend.core.repositorio_base import RepositorioBase
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class ProductoRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de Productos Agroquímicos"""
    
    def __init__(self):
        super().__init__()
        self.tabla = "ProductosAgroquimicos"
    
    # ==================== CONSULTAS BÁSICAS ====================
    
    @cacheable('productos_agroquimicos', ttl=get_ttl('productos'))
    def obtener_todos(self) -> List[Dict]:
        """
        Obtiene todos los productos agroquímicos con información de categoría
        """
        query = """
        SELECT p.id_producto, p.nombre_comercial, c.nombre as categoria, 
               p.formulacion, p.unidad, p.precio, 
               p.registro, p.notas, p.fecha_registro, p.activo,
               c.id_categoria
        FROM ProductosAgroquimicos p
        LEFT JOIN CategoriaAgroquimicos c ON p.id_categoria = c.id_categoria
        ORDER BY p.nombre_comercial
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                productos = []
                for row in cursor.fetchall():
                    fecha_registro = self._formatear_fecha(row.fecha_registro)
                    
                    producto = {
                        'id_producto': row.id_producto,
                        'nombre_comercial': row.nombre_comercial,
                        'categoria': row.categoria,
                        'id_categoria': row.id_categoria,
                        'formulacion': row.formulacion,
                        'unidad': row.unidad,
                        'precio': float(row.precio) if row.precio else 0.0,
                        'registro': row.registro,
                        'notas': row.notas,
                        'fecha_registro': fecha_registro,
                        'activo': bool(row.activo)
                    }
                    productos.append(producto)
                
                logger.info(f"Se obtuvieron {len(productos)} productos")
                return productos
                
        except Exception as e:
            logger.error(f"Error al obtener productos: {str(e)}")
            return []
    
    def obtener_por_id(self, id_producto: int) -> Optional[Dict]:
        """
        Obtiene un producto específico por su ID
        """
        query = """
        SELECT p.id_producto, p.nombre_comercial, c.nombre as categoria,
               p.formulacion, p.unidad, p.precio, 
               p.registro, p.notas, p.fecha_registro, p.activo,
               c.id_categoria
        FROM ProductosAgroquimicos p
        LEFT JOIN CategoriaAgroquimicos c ON p.id_categoria = c.id_categoria
        WHERE p.id_producto = ?
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_producto,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                fecha_registro = self._formatear_fecha(row.fecha_registro)
                
                return {
                    'id_producto': row.id_producto,
                    'nombre_comercial': row.nombre_comercial,
                    'categoria': row.categoria,
                    'id_categoria': row.id_categoria,
                    'formulacion': row.formulacion,
                    'unidad': row.unidad,
                    'precio': float(row.precio) if row.precio else 0.0,
                    'registro': row.registro,
                    'notas': row.notas,
                    'fecha_registro': fecha_registro,
                    'activo': bool(row.activo)
                }
                
        except Exception as e:
            logger.error(f"Error al obtener producto {id_producto}: {str(e)}")
            return None
    
    def obtener_activos(self) -> List[Dict]:
        """Obtiene solo los productos activos"""
        query = """
        SELECT p.id_producto, p.nombre_comercial, c.nombre as categoria,
               p.formulacion, p.unidad, p.precio, p.activo
        FROM ProductosAgroquimicos p
        LEFT JOIN CategoriaAgroquimicos c ON p.id_categoria = c.id_categoria
        WHERE p.activo = 1
        ORDER BY p.nombre_comercial
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                productos = []
                for row in cursor.fetchall():
                    producto = {
                        'id_producto': row.id_producto,
                        'nombre_comercial': row.nombre_comercial,
                        'categoria': row.categoria,
                        'formulacion': row.formulacion,
                        'unidad': row.unidad,
                        'precio': float(row.precio) if row.precio else 0.0,
                        'activo': bool(row.activo)
                    }
                    productos.append(producto)
                
                return productos
                
        except Exception as e:
            logger.error(f"Error al obtener productos activos: {str(e)}")
            return []
    
    # ==================== INSERCIÓN ====================
    
    @cache_invalidator('productos_agroquimicos')
    def crear(self, datos: Dict) -> tuple[bool, Optional[int]]:
        """
        Crea un nuevo producto agroquímico
        """
        query = """
        INSERT INTO ProductosAgroquimicos 
        (id_categoria, nombre_comercial, formulacion, unidad, precio, registro, notas, activo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        try:
            valores = (
                datos['id_categoria'],
                datos['nombre_comercial'],
                datos.get('formulacion'),
                datos['unidad'],
                datos.get('precio', 0.0),
                datos.get('registro'),
                datos.get('notas'),
                1 if datos.get('activo', True) else 0
            )
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                id_producto = self._obtener_ultimo_id()
                logger.info(f"Producto creado con ID: {id_producto}")
                return True, id_producto
                
        except Exception as e:
            logger.error(f"Error al crear producto: {str(e)}")
            return False, None
    
    # ==================== ACTUALIZACIÓN ====================
    
    @cache_invalidator('productos_agroquimicos')
    def actualizar(self, id_producto: int, datos: Dict) -> bool:
        """
        Actualiza un producto existente
        """
        try:
            campos_actualizar = []
            valores = []
            
            campos_permitidos = ['id_categoria', 'nombre_comercial', 'formulacion', 
                               'unidad', 'precio', 'registro', 'notas', 'activo']
            
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
            
            valores.append(id_producto)
            query = f"UPDATE ProductosAgroquimicos SET {', '.join(campos_actualizar)} WHERE id_producto = ?"
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Producto {id_producto} actualizado. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al actualizar producto {id_producto}: {str(e)}")
            return False
    
    # ==================== ELIMINACIÓN ====================
    
    @cache_invalidator('productos_agroquimicos')
    def eliminar(self, id_producto: int) -> bool:
        """
        Elimina (desactiva) un producto
        """
        return self.actualizar(id_producto, {'activo': False})
    
    # ==================== CONSULTAS ESPECIALIZADAS ====================
    
    def obtener_por_categoria(self, id_categoria: int) -> List[Dict]:
        """Obtiene productos por categoría"""
        query = """
        SELECT id_producto, nombre_comercial, formulacion, unidad, precio, activo
        FROM ProductosAgroquimicos
        WHERE id_categoria = ? AND activo = 1
        ORDER BY nombre_comercial
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_categoria,))
                
                productos = []
                for row in cursor.fetchall():
                    producto = {
                        'id_producto': row.id_producto,
                        'nombre_comercial': row.nombre_comercial,
                        'formulacion': row.formulacion,
                        'unidad': row.unidad,
                        'precio': float(row.precio) if row.precio else 0.0,
                        'activo': bool(row.activo)
                    }
                    productos.append(producto)
                
                return productos
                
        except Exception as e:
            logger.error(f"Error al obtener productos por categoría {id_categoria}: {str(e)}")
            return []
    
    def existe_nombre(self, nombre: str, excluir_id: Optional[int] = None) -> bool:
        """Verifica si ya existe un producto con ese nombre"""
        query = "SELECT COUNT(*) FROM ProductosAgroquimicos WHERE nombre_comercial = ?"
        params = [nombre]
        
        if excluir_id:
            query += " AND id_producto != ?"
            params.append(excluir_id)
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params)
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar nombre de producto: {str(e)}")
            return False
    
    def contar_productos(self, id_categoria: Optional[int] = None) -> int:
        """Cuenta el total de productos"""
        query = "SELECT COUNT(*) FROM ProductosAgroquimicos"
        params = []
        
        if id_categoria:
            query += " WHERE id_categoria = ?"
            params.append(id_categoria)
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params)
                return cursor.fetchone()[0]
                
        except Exception as e:
            logger.error(f"Error al contar productos: {str(e)}")
            return 0

    # ==================== MÉTODOS DE INVENTARIO ====================

    def obtener_producto_con_stock(self, id_producto: int) -> Optional[Dict[str, Any]]:
        """
        Obtiene un producto con información de stock actual desde LotesAgroquimicos
        """
        query = """
        SELECT 
            p.id_producto,
            p.nombre_comercial,
            p.formulacion,
            p.unidad,
            COALESCE(SUM(l.cantidad_actual), 0) as stock_total,
            COUNT(CASE WHEN l.cantidad_actual > 0 THEN 1 END) as lotes_disponibles,
            MIN(l.fecha_vencimiento) as proxima_fecha_vencimiento,
            MIN(DATEDIFF(day, GETDATE(), l.fecha_vencimiento)) as dias_minimo_vencer
        FROM ProductosAgroquimicos p
        LEFT JOIN LotesAgroquimicos l ON p.id_producto = l.id_producto 
            AND l.cantidad_actual > 0 
            AND l.activo = 1
        WHERE p.id_producto = ?
        GROUP BY p.id_producto, p.nombre_comercial, p.formulacion, p.unidad
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_producto,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                return {
                    'id_producto': row[0],
                    'nombre_comercial': row[1],
                    'formulacion': row[2],
                    'unidad': row[3],
                    'stock_total': float(row[4]),
                    'lotes_disponibles': row[5],
                    'proxima_fecha_vencimiento': row[6],
                    'dias_minimo_vencer': row[7] if row[7] is not None else None
                }
                
        except Exception as e:
            logger.error(f"Error al obtener producto con stock {id_producto}: {str(e)}")
            return None