# backend/repositories/AgroquimicosRep/producto_repositorio.py
"""
Repositorio para gestión de Productos Agroquímicos
Maneja el acceso a datos de la tabla ProductosAgroquimicos
"""

import logging
from datetime import date
from typing import List, Dict, Optional, Tuple
from backend.core.repositorio_base import RepositorioBase
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class ProductoRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de Productos Agroquímicos"""
    
    def __init__(self):
        super().__init__()
        self.tabla = "ProductosAgroquimicos"
    
    # ==================== CONSULTAS ====================
    
    @cacheable('agroquimicos', ttl=get_ttl('agroquimicos'))
    def obtener_todos(self) -> List[Dict]:
        """
        Obtiene todos los productos agroquímicos con información de categoría
        
        Returns:
            List[Dict]: Lista de productos con sus datos completos
        """
        query = """
        SELECT p.id_producto, p.nombre_comercial, c.nombre as categoria, 
               p.formulacion, p.unidad, p.precio, 
               p.registro, p.notas, p.fecha_registro, p.activo,
               c.id_categoria
        FROM ProductosAgroquimicos p
        LEFT JOIN CategoriaAgroquimicos c ON p.id_categoria = c.id_categoria
        ORDER BY p.id_producto
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                productos = []
                for row in cursor.fetchall():
                    # Formatear fecha de registro
                    fecha_registro = None
                    if row.fecha_registro:
                        if isinstance(row.fecha_registro, str):
                            fecha_registro = row.fecha_registro
                        else:
                            fecha_registro = row.fecha_registro.strftime('%Y-%m-%d')
                    
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
                
                logger.info(f"Se obtuvieron {len(productos)} productos de la base de datos")
                return productos
                
        except Exception as e:
            logger.error(f"Error al obtener productos: {str(e)}")
            return []
    
    def obtener_por_id(self, id_producto: int) -> Optional[Dict]:
        """
        Obtiene un producto específico por su ID
        
        Args:
            id_producto: ID del producto a buscar
            
        Returns:
            Dict: Datos del producto o None si no existe
        """
        query = """
        SELECT p.id_producto, p.nombre_comercial, c.nombre as categoria, 
               p.formulacion, p.unidad, p.precio, p.stock, 
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
                
                # Formatear fecha de registro
                fecha_registro = None
                if row.fecha_registro:
                    if isinstance(row.fecha_registro, str):
                        fecha_registro = row.fecha_registro
                    else:
                        fecha_registro = row.fecha_registro.strftime('%Y-%m-%d')
                
                return {
                    'id_producto': row.id_producto,
                    'nombre_comercial': row.nombre_comercial,
                    'categoria': row.categoria,
                    'id_categoria': row.id_categoria,
                    'formulacion': row.formulacion,
                    'unidad': row.unidad,
                    'precio': float(row.precio) if row.precio else 0.0,
                    'stock': float(row.stock) if row.stock else 0.0,
                    'registro': row.registro,
                    'notas': row.notas,
                    'fecha_registro': fecha_registro,
                    'activo': bool(row.activo)
                }
                
        except Exception as e:
            logger.error(f"Error al obtener producto {id_producto}: {str(e)}")
            return None
    
    def obtener_por_categoria(self, id_categoria: int) -> List[Dict]:
        """
        Obtiene todos los productos de una categoría específica
        
        Args:
            id_categoria: ID de la categoría
            
        Returns:
            List[Dict]: Lista de productos de esa categoría
        """
        query = """
        SELECT p.id_producto, p.nombre_comercial, c.nombre as categoria, 
               p.formulacion, p.unidad, p.precio, p.stock, 
               p.registro, p.notas, p.fecha_registro, p.activo,
               c.id_categoria
        FROM ProductosAgroquimicos p
        LEFT JOIN CategoriaAgroquimicos c ON p.id_categoria = c.id_categoria
        WHERE p.id_categoria = ?
        ORDER BY p.nombre_comercial
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_categoria,))
                
                productos = []
                for row in cursor.fetchall():
                    fecha_registro = None
                    if row.fecha_registro:
                        if isinstance(row.fecha_registro, str):
                            fecha_registro = row.fecha_registro
                        else:
                            fecha_registro = row.fecha_registro.strftime('%Y-%m-%d')
                    
                    producto = {
                        'id_producto': row.id_producto,
                        'nombre_comercial': row.nombre_comercial,
                        'categoria': row.categoria,
                        'id_categoria': row.id_categoria,
                        'formulacion': row.formulacion,
                        'unidad': row.unidad,
                        'precio': float(row.precio) if row.precio else 0.0,
                        'stock': float(row.stock) if row.stock else 0.0,
                        'registro': row.registro,
                        'notas': row.notas,
                        'fecha_registro': fecha_registro,
                        'activo': bool(row.activo)
                    }
                    productos.append(producto)
                
                return productos
                
        except Exception as e:
            logger.error(f"Error al obtener productos por categoría {id_categoria}: {str(e)}")
            return []
    
    def obtener_stock_bajo(self, limite: float = 10.0) -> List[Dict]:
        """
        Obtiene productos con stock por debajo del límite especificado
        
        Args:
            limite: Cantidad mínima de stock
            
        Returns:
            List[Dict]: Lista de productos con stock bajo
        """
        query = """
        SELECT p.id_producto, p.nombre_comercial, c.nombre as categoria, 
               p.stock, p.unidad, p.activo
        FROM ProductosAgroquimicos p
        LEFT JOIN CategoriaAgroquimicos c ON p.id_categoria = c.id_categoria
        WHERE p.stock < ? AND p.activo = 1
        ORDER BY p.stock ASC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (limite,))
                
                productos = []
                for row in cursor.fetchall():
                    producto = {
                        'id_producto': row.id_producto,
                        'nombre_comercial': row.nombre_comercial,
                        'categoria': row.categoria,
                        'stock': float(row.stock) if row.stock else 0.0,
                        'unidad': row.unidad,
                        'activo': bool(row.activo)
                    }
                    productos.append(producto)
                
                return productos
                
        except Exception as e:
            logger.error(f"Error al obtener productos con stock bajo: {str(e)}")
            return []
    
    # ==================== INSERCIÓN ====================
    
    @cache_invalidator('agroquimicos')
    @cache_invalidator('estadisticas')
    def crear(self, datos: Dict) -> Tuple[bool, Optional[int]]:
        """
        Crea un nuevo producto agroquímico
        
        Args:
            datos: Diccionario con los datos del producto
                - id_categoria (int): ID de la categoría
                - nombre_comercial (str): Nombre del producto
                - formulacion (str, optional): Tipo de formulación (default: 'Líquido')
                - unidad (str, optional): Unidad de medida (default: 'L')
                - precio (float, optional): Precio unitario (default: 0.0)
                - stock (float, optional): Cantidad en stock (default: 0.0)
                - registro (str, optional): Número de registro (default: 'PENDIENTE')
                - notas (str, optional): Observaciones
                - fecha_registro (date, optional): Fecha de registro (default: hoy)
                - activo (bool, optional): Estado activo (default: True)
                
        Returns:
            Tuple[bool, Optional[int]]: (Éxito, ID del producto creado)
        """
        query = """
        INSERT INTO ProductosAgroquimicos 
        (id_categoria, nombre_comercial, formulacion, unidad, precio, stock, 
         registro, notas, fecha_registro, activo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        try:
            # Valores por defecto
            fecha_actual = datos.get('fecha_registro', date.today())
            
            valores = (
                datos['id_categoria'],
                datos['nombre_comercial'],
                datos.get('formulacion', 'Líquido'),
                datos.get('unidad', 'L'),
                datos.get('precio', 0.0),
                datos.get('stock', 0.0),
                datos.get('registro', 'PENDIENTE'),
                datos.get('notas'),
                fecha_actual,
                1 if datos.get('activo', True) else 0
            )
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID generado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_producto = cursor.fetchone()[0]
                
                logger.info(f"Producto creado correctamente con ID: {id_producto}")
                return True, id_producto
                
        except Exception as e:
            logger.error(f"Error al crear producto: {str(e)}")
            return False, None
    
    # ==================== ACTUALIZACIÓN ====================
    
    @cache_invalidator('agroquimicos')
    @cache_invalidator('estadisticas')
    def actualizar(self, id_producto: int, datos: Dict) -> bool:
        """
        Actualiza un producto existente
        
        Args:
            id_producto: ID del producto a actualizar
            datos: Diccionario con los campos a actualizar
            
        Returns:
            bool: True si se actualizó correctamente
        """
        try:
            campos_actualizar = []
            valores = []
            
            # Construir dinámicamente los campos a actualizar
            campos_permitidos = [
                'id_categoria', 'nombre_comercial', 'formulacion', 'unidad',
                'precio', 'stock', 'registro', 'notas', 'activo'
            ]
            
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
    
    @cache_invalidator('agroquimicos')
    @cache_invalidator('estadisticas')
    def actualizar_stock(self, id_producto: int, nueva_cantidad: float) -> bool:
        """
        Actualiza solo el stock de un producto
        
        Args:
            id_producto: ID del producto
            nueva_cantidad: Nueva cantidad en stock
            
        Returns:
            bool: True si se actualizó correctamente
        """
        query = "UPDATE ProductosAgroquimicos SET stock = ? WHERE id_producto = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (nueva_cantidad, id_producto))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Stock del producto {id_producto} actualizado a {nueva_cantidad}")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al actualizar stock del producto {id_producto}: {str(e)}")
            return False
    
    @cache_invalidator('agroquimicos')
    @cache_invalidator('estadisticas')
    def ajustar_stock(self, id_producto: int, cantidad: float, operacion: str = 'sumar') -> bool:
        """
        Ajusta el stock de un producto (suma o resta)
        
        Args:
            id_producto: ID del producto
            cantidad: Cantidad a ajustar
            operacion: 'sumar' o 'restar'
            
        Returns:
            bool: True si se actualizó correctamente
        """
        if operacion not in ['sumar', 'restar']:
            logger.error(f"Operación inválida: {operacion}")
            return False
        
        operador = '+' if operacion == 'sumar' else '-'
        query = f"UPDATE ProductosAgroquimicos SET stock = stock {operador} ? WHERE id_producto = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (cantidad, id_producto))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Stock del producto {id_producto} ajustado: {operacion} {cantidad}")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al ajustar stock del producto {id_producto}: {str(e)}")
            return False
    
    # ==================== ELIMINACIÓN ====================
    
    @cache_invalidator('agroquimicos')
    @cache_invalidator('estadisticas')
    def eliminar(self, id_producto: int) -> bool:
        """
        Elimina (desactiva) un producto
        
        Args:
            id_producto: ID del producto a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
        query = "UPDATE ProductosAgroquimicos SET activo = 0 WHERE id_producto = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_producto,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Producto {id_producto} eliminado (desactivado)")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al eliminar producto {id_producto}: {str(e)}")
            return False
    
    def eliminar_permanente(self, id_producto: int) -> bool:
        """
        Elimina permanentemente un producto de la base de datos
        ⚠️ USAR CON PRECAUCIÓN - No se puede deshacer
        
        Args:
            id_producto: ID del producto a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
        query = "DELETE FROM ProductosAgroquimicos WHERE id_producto = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_producto,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.warning(f"Producto {id_producto} eliminado PERMANENTEMENTE")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al eliminar permanentemente producto {id_producto}: {str(e)}")
            return False
    
    # ==================== UTILIDADES ====================
    
    def contar_productos(self, solo_activos: bool = True) -> int:
        """
        Cuenta el total de productos
        
        Args:
            solo_activos: Si True, cuenta solo productos activos
            
        Returns:
            int: Cantidad de productos
        """
        query = "SELECT COUNT(*) FROM ProductosAgroquimicos"
        if solo_activos:
            query += " WHERE activo = 1"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                return cursor.fetchone()[0]
                
        except Exception as e:
            logger.error(f"Error al contar productos: {str(e)}")
            return 0
    
    def obtener_valor_inventario(self) -> float:
        """
        Calcula el valor total del inventario (stock * precio)
        
        Returns:
            float: Valor total del inventario
        """
        query = """
        SELECT SUM(stock * precio) as valor_total
        FROM ProductosAgroquimicos
        WHERE activo = 1
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                resultado = cursor.fetchone()[0]
                return float(resultado) if resultado else 0.0
                
        except Exception as e:
            logger.error(f"Error al calcular valor de inventario: {str(e)}")
            return 0.0
    
    def existe(self, id_producto: int) -> bool:
        """
        Verifica si un producto existe
        
        Args:
            id_producto: ID del producto
            
        Returns:
            bool: True si existe
        """
        query = "SELECT COUNT(*) FROM ProductosAgroquimicos WHERE id_producto = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_producto,))
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar existencia del producto {id_producto}: {str(e)}")
            return False