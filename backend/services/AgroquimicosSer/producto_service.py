# backend/services/AgroquimicosServ/producto_service.py
"""
Servicio de Productos Agroquímicos
Contiene la lógica de negocio para gestión de productos
"""

import logging
from typing import List, Dict, Optional, Tuple
from backend.repositories.AgroquimicosRep.producto_repositorio import ProductoRepositorio
from backend.repositories.AgroquimicosRep.categoria_repositorio import CategoriaRepositorio

logger = logging.getLogger(__name__)


class ProductoService:
    """Servicio con lógica de negocio para Productos Agroquímicos"""
    
    def __init__(self):
        self.producto_repo = ProductoRepositorio()
        self.categoria_repo = CategoriaRepositorio()
    
    # ==================== CONSULTAS ====================
    
    def obtener_todos_productos(self) -> List[Dict]:
        """
        Obtiene todos los productos con información de categoría
        
        Returns:
            List[Dict]: Lista de productos
        """
        return self.producto_repo.obtener_todos()
    
    def obtener_producto(self, id_producto: int) -> Optional[Dict]:
        """
        Obtiene un producto específico
        
        Args:
            id_producto: ID del producto
            
        Returns:
            Dict: Datos del producto o None
        """
        return self.producto_repo.obtener_por_id(id_producto)
    
    def obtener_productos_por_categoria(self, id_categoria: int) -> List[Dict]:
        """
        Obtiene productos de una categoría específica
        
        Args:
            id_categoria: ID de la categoría
            
        Returns:
            List[Dict]: Lista de productos de esa categoría
        """
        return self.producto_repo.obtener_por_categoria(id_categoria)
    
    def obtener_productos_stock_bajo(self, limite: float = 10.0) -> List[Dict]:
        """
        Obtiene productos con stock por debajo del límite
        
        Args:
            limite: Cantidad mínima de stock
            
        Returns:
            List[Dict]: Lista de productos con stock crítico
        """
        return self.producto_repo.obtener_stock_bajo(limite)
    
    # ==================== CREACIÓN ====================
    
    def crear_producto(self, datos: Dict) -> Tuple[bool, Optional[int], str]:
        """
        Crea un nuevo producto con validaciones
        
        Args:
            datos: Diccionario con los datos del producto
            
        Returns:
            Tuple[bool, Optional[int], str]: (Éxito, ID del producto, Mensaje)
        """
        # Validaciones
        validacion = self._validar_datos_producto(datos)
        if not validacion[0]:
            return False, None, validacion[1]
        
        # Verificar que la categoría exista
        if not self.categoria_repo.existe(datos['id_categoria']):
            return False, None, "La categoría especificada no existe"
        
        # Crear el producto
        exito, id_producto = self.producto_repo.crear(datos)
        
        if exito:
            logger.info(f"Producto '{datos['nombre_comercial']}' creado con ID: {id_producto}")
            return True, id_producto, "Producto creado exitosamente"
        else:
            return False, None, "Error al crear el producto en la base de datos"
    
    # ==================== ACTUALIZACIÓN ====================
    
    def actualizar_producto(self, id_producto: int, datos: Dict) -> Tuple[bool, str]:
        """
        Actualiza un producto existente con validaciones
        
        Args:
            id_producto: ID del producto a actualizar
            datos: Datos a actualizar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        # Verificar que el producto exista
        if not self.producto_repo.existe(id_producto):
            return False, "El producto no existe"
        
        # Si se está cambiando la categoría, verificar que exista
        if 'id_categoria' in datos:
            if not self.categoria_repo.existe(datos['id_categoria']):
                return False, "La categoría especificada no existe"
        
        # Validaciones parciales (solo para campos presentes)
        if 'nombre_comercial' in datos:
            if not datos['nombre_comercial'] or len(datos['nombre_comercial'].strip()) == 0:
                return False, "El nombre comercial no puede estar vacío"
        
        if 'precio' in datos:
            if datos['precio'] < 0:
                return False, "El precio no puede ser negativo"
        
        if 'stock' in datos:
            if datos['stock'] < 0:
                return False, "El stock no puede ser negativo"
        
        # Actualizar
        exito = self.producto_repo.actualizar(id_producto, datos)
        
        if exito:
            logger.info(f"Producto {id_producto} actualizado")
            return True, "Producto actualizado exitosamente"
        else:
            return False, "Error al actualizar el producto"
    
    def actualizar_stock_producto(self, id_producto: int, nueva_cantidad: float) -> Tuple[bool, str]:
        """
        Actualiza el stock de un producto
        
        Args:
            id_producto: ID del producto
            nueva_cantidad: Nueva cantidad en stock
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        if nueva_cantidad < 0:
            return False, "El stock no puede ser negativo"
        
        if not self.producto_repo.existe(id_producto):
            return False, "El producto no existe"
        
        exito = self.producto_repo.actualizar_stock(id_producto, nueva_cantidad)
        
        if exito:
            return True, "Stock actualizado exitosamente"
        else:
            return False, "Error al actualizar el stock"
    
    def ajustar_stock_producto(self, id_producto: int, cantidad: float, operacion: str = 'sumar') -> Tuple[bool, str]:
        """
        Ajusta el stock de un producto (suma o resta)
        
        Args:
            id_producto: ID del producto
            cantidad: Cantidad a ajustar
            operacion: 'sumar' o 'restar'
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        if cantidad < 0:
            return False, "La cantidad no puede ser negativa"
        
        if operacion not in ['sumar', 'restar']:
            return False, "Operación inválida. Debe ser 'sumar' o 'restar'"
        
        if not self.producto_repo.existe(id_producto):
            return False, "El producto no existe"
        
        # Si es restar, verificar que haya suficiente stock
        if operacion == 'restar':
            producto = self.producto_repo.obtener_por_id(id_producto)
            if producto and producto['stock'] < cantidad:
                return False, f"Stock insuficiente. Disponible: {producto['stock']}"
        
        exito = self.producto_repo.ajustar_stock(id_producto, cantidad, operacion)
        
        if exito:
            accion = "aumentado" if operacion == 'sumar' else "reducido"
            return True, f"Stock {accion} exitosamente en {cantidad} unidades"
        else:
            return False, "Error al ajustar el stock"
    
    # ==================== ELIMINACIÓN ====================
    
    def eliminar_producto(self, id_producto: int) -> Tuple[bool, str]:
        """
        Elimina (desactiva) un producto
        
        Args:
            id_producto: ID del producto a eliminar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        if not self.producto_repo.existe(id_producto):
            return False, "El producto no existe"
        
        exito = self.producto_repo.eliminar(id_producto)
        
        if exito:
            logger.info(f"Producto {id_producto} eliminado (desactivado)")
            return True, "Producto eliminado exitosamente"
        else:
            return False, "Error al eliminar el producto"
    
    # ==================== ANÁLISIS Y ESTADÍSTICAS ====================
    
    def obtener_resumen_inventario(self) -> Dict:
        """
        Obtiene un resumen completo del inventario
        
        Returns:
            Dict: Estadísticas del inventario
        """
        productos = self.producto_repo.obtener_todos()
        
        total_productos = len(productos)
        productos_activos = sum(1 for p in productos if p['activo'])
        valor_total = sum(p['precio'] * p['stock'] for p in productos if p['activo'])
        stock_critico = sum(1 for p in productos if p['activo'] and p['stock'] < 10)
        
        # Categoría más usada
        categoria_mas_usada = "N/A"
        if productos:
            categorias_count = {}
            for producto in productos:
                if producto['activo']:
                    categoria = producto.get('categoria', 'Sin categoría')
                    categorias_count[categoria] = categorias_count.get(categoria, 0) + 1
            
            if categorias_count:
                categoria_mas_usada = max(categorias_count, key=categorias_count.get)
        
        return {
            'total_productos': total_productos,
            'productos_activos': productos_activos,
            'valor_inventario': round(valor_total, 2),
            'stock_critico': stock_critico,
            'categoria_mas_usada': categoria_mas_usada
        }
    
    def obtener_productos_por_categoria_agrupados(self) -> Dict[str, List[Dict]]:
        """
        Obtiene productos agrupados por categoría
        
        Returns:
            Dict: Productos agrupados por nombre de categoría
        """
        productos = self.producto_repo.obtener_todos()
        agrupados = {}
        
        for producto in productos:
            categoria = producto.get('categoria', 'Sin categoría')
            if categoria not in agrupados:
                agrupados[categoria] = []
            agrupados[categoria].append(producto)
        
        return agrupados
    
    def verificar_stock_critico(self, limite: float = 10.0) -> Tuple[bool, List[Dict]]:
        """
        Verifica si hay productos con stock crítico
        
        Args:
            limite: Límite de stock considerado crítico
            
        Returns:
            Tuple[bool, List[Dict]]: (Hay críticos, Lista de productos críticos)
        """
        productos_criticos = self.producto_repo.obtener_stock_bajo(limite)
        return len(productos_criticos) > 0, productos_criticos
    
    # ==================== VALIDACIONES ====================
    
    def _validar_datos_producto(self, datos: Dict) -> Tuple[bool, str]:
        """
        Valida los datos de un producto antes de crear/actualizar
        
        Args:
            datos: Datos del producto a validar
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error si aplica)
        """
        # Campos requeridos para creación
        if 'nombre_comercial' not in datos:
            return False, "El nombre comercial es obligatorio"
        
        if 'id_categoria' not in datos:
            return False, "La categoría es obligatoria"
        
        # Validar nombre
        if not datos['nombre_comercial'] or len(datos['nombre_comercial'].strip()) == 0:
            return False, "El nombre comercial no puede estar vacío"
        
        if len(datos['nombre_comercial']) > 200:
            return False, "El nombre comercial no puede exceder 200 caracteres"
        
        # Validar precio si está presente
        if 'precio' in datos and datos['precio'] is not None:
            if datos['precio'] < 0:
                return False, "El precio no puede ser negativo"
        
        # Validar stock si está presente
        if 'stock' in datos and datos['stock'] is not None:
            if datos['stock'] < 0:
                return False, "El stock no puede ser negativo"
        
        return True, "Validación exitosa"
    
    # ==================== UTILIDADES ====================
    
    def contar_productos(self, solo_activos: bool = True) -> int:
        """
        Cuenta el total de productos
        
        Args:
            solo_activos: Si True, cuenta solo productos activos
            
        Returns:
            int: Cantidad de productos
        """
        return self.producto_repo.contar_productos(solo_activos)
    
    def obtener_valor_total_inventario(self) -> float:
        """
        Calcula el valor total del inventario
        
        Returns:
            float: Valor total en moneda
        """
        return self.producto_repo.obtener_valor_inventario()