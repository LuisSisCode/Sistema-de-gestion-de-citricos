# backend/services/AgroquimicosServ/producto_service.py
"""
Servicio de Productos Agroquímicos
Contiene la lógica de negocio para gestión de productos
"""

import logging
from typing import List, Dict, Optional, Tuple
from backend.repositories.AgroquimicosRep.producto_repositorio import ProductoRepositorio
from backend.repositories.AgroquimicosRep.categoria_repositorio import CategoriaRepositorio
from backend.core.repositorio_base import ErrorConsulta

logger = logging.getLogger(__name__)


class ProductoService:
    """Servicio con lógica de negocio para Productos Agroquímicos"""
    
    def __init__(self):
        self.producto_repo = ProductoRepositorio()
        self.categoria_repo = CategoriaRepositorio()
        logger.info("ProductoService inicializado")
    
    # ==================== CONSULTAS ====================
    
    def obtener_todos_productos(self) -> List[Dict]:
        """
        Obtiene todos los productos con información de categoría
        
        Returns:
            List[Dict]: Lista de productos
        """
        try:
            return self.producto_repo.obtener_todos()
        except Exception as e:
            logger.error(f"Error al obtener productos: {str(e)}")
            raise ErrorConsulta(f"Error al obtener productos: {str(e)}")
    
    def obtener_producto(self, id_producto: int) -> Optional[Dict]:
        """
        Obtiene un producto específico
        
        Args:
            id_producto: ID del producto
            
        Returns:
            Dict: Datos del producto o None
        """
        try:
            return self.producto_repo.obtener_por_id(id_producto)
        except Exception as e:
            logger.error(f"Error al obtener producto {id_producto}: {str(e)}")
            raise ErrorConsulta(f"Error al obtener producto: {str(e)}")
    
    def obtener_productos_activos(self) -> List[Dict]:
        """
        Obtiene solo los productos activos
        
        Returns:
            List[Dict]: Lista de productos activos
        """
        try:
            return self.producto_repo.obtener_activos()
        except Exception as e:
            logger.error(f"Error al obtener productos activos: {str(e)}")
            return []
    
    def obtener_productos_por_categoria(self, id_categoria: int) -> List[Dict]:
        """
        Obtiene productos de una categoría específica
        
        Args:
            id_categoria: ID de la categoría
            
        Returns:
            List[Dict]: Lista de productos de esa categoría
        """
        try:
            return self.producto_repo.obtener_por_categoria(id_categoria)
        except Exception as e:
            logger.error(f"Error al obtener productos por categoría {id_categoria}: {str(e)}")
            return []
    
    def obtener_producto_con_stock(self, id_producto: int) -> Optional[Dict]:
        """
        Obtiene un producto con información de stock desde lotes
        
        Args:
            id_producto: ID del producto
            
        Returns:
            Dict: Información del producto con stock o None
        """
        try:
            return self.producto_repo.obtener_producto_con_stock(id_producto)
        except Exception as e:
            logger.error(f"Error al obtener producto con stock {id_producto}: {str(e)}")
            return None
    
    # ==================== CREACIÓN ====================
    
    def crear_producto(self, datos: Dict) -> Tuple[bool, Optional[int], str]:
        """
        Crea un nuevo producto con validaciones
        
        Args:
            datos: Diccionario con los datos del producto
                - nombre_comercial (str): Nombre comercial
                - id_categoria (int): ID de la categoría
                - formulacion (str, optional): Formulación
                - unidad (str): Unidad de medida
                - precio (float, optional): Precio
                - registro (str, optional): Número de registro
                - notas (str, optional): Notas adicionales
                - activo (bool, optional): Estado activo
            
        Returns:
            Tuple[bool, Optional[int], str]: (Éxito, ID del producto, Mensaje)
        """
        try:
            # Validaciones
            validacion = self._validar_datos_producto(datos, es_actualizacion=False)
            if not validacion[0]:
                return False, None, validacion[1]
            
            # Verificar que la categoría exista
            if not self.categoria_repo.existe(datos['id_categoria']):
                return False, None, "La categoría especificada no existe"
            
            # Verificar que no exista un producto con el mismo nombre
            if self.producto_repo.existe_nombre(datos['nombre_comercial']):
                return False, None, f"Ya existe un producto con el nombre '{datos['nombre_comercial']}'"
            
            # Crear el producto
            exito, id_producto = self.producto_repo.crear(datos)
            
            if exito:
                logger.info(f"Producto '{datos['nombre_comercial']}' creado con ID: {id_producto}")
                return True, id_producto, "Producto creado exitosamente"
            else:
                return False, None, "Error al crear el producto en la base de datos"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al crear producto: {str(e)}")
            return False, None, str(e)
        except Exception as e:
            logger.error(f"Error al crear producto: {str(e)}")
            return False, None, f"Error al crear producto: {str(e)}"
    
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
        try:
            # Verificar que el producto exista
            producto_existente = self.producto_repo.obtener_por_id(id_producto)
            if not producto_existente:
                return False, "El producto no existe"
            
            # Validaciones
            validacion = self._validar_datos_producto(datos, es_actualizacion=True)
            if not validacion[0]:
                return False, validacion[1]
            
            # Si se está cambiando la categoría, verificar que exista
            if 'id_categoria' in datos:
                if not self.categoria_repo.existe(datos['id_categoria']):
                    return False, "La categoría especificada no existe"
            
            # Si se está cambiando el nombre, verificar duplicados
            if 'nombre_comercial' in datos and datos['nombre_comercial'] != producto_existente['nombre_comercial']:
                if self.producto_repo.existe_nombre(datos['nombre_comercial'], excluir_id=id_producto):
                    return False, f"Ya existe otro producto con el nombre '{datos['nombre_comercial']}'"
            
            # Actualizar
            exito = self.producto_repo.actualizar(id_producto, datos)
            
            if exito:
                logger.info(f"Producto {id_producto} actualizado exitosamente")
                return True, "Producto actualizado exitosamente"
            else:
                return False, "Error al actualizar el producto"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al actualizar producto: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error al actualizar producto {id_producto}: {str(e)}")
            return False, f"Error al actualizar producto: {str(e)}"
    
    # ==================== ELIMINACIÓN ====================
    
    def eliminar_producto(self, id_producto: int) -> Tuple[bool, str]:
        """
        Elimina (desactiva) un producto
        
        Args:
            id_producto: ID del producto a eliminar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que el producto exista
            if not self.producto_repo.obtener_por_id(id_producto):
                return False, "El producto no existe"
            
            # Eliminar (desactivar)
            exito = self.producto_repo.eliminar(id_producto)
            
            if exito:
                logger.info(f"Producto {id_producto} eliminado (desactivado)")
                return True, "Producto eliminado exitosamente"
            else:
                return False, "Error al eliminar el producto"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al eliminar producto: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error al eliminar producto {id_producto}: {str(e)}")
            return False, f"Error al eliminar producto: {str(e)}"
    
    # ==================== ANÁLISIS Y ESTADÍSTICAS ====================
    
    def obtener_estadisticas_productos(self) -> Dict:
        """
        Obtiene estadísticas generales de productos
        
        Returns:
            Dict: Estadísticas de productos
        """
        try:
            productos = self.producto_repo.obtener_todos()
            
            total_productos = len(productos)
            productos_activos = sum(1 for p in productos if p['activo'])
            
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
                'categoria_mas_usada': categoria_mas_usada
            }
            
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de productos: {str(e)}")
            return {
                'total_productos': 0,
                'productos_activos': 0,
                'categoria_mas_usada': 'N/A'
            }
    
    def obtener_productos_por_categoria_agrupados(self) -> Dict[str, List[Dict]]:
        """
        Obtiene productos agrupados por categoría
        
        Returns:
            Dict: Productos agrupados por nombre de categoría
        """
        try:
            productos = self.producto_repo.obtener_todos()
            agrupados = {}
            
            for producto in productos:
                categoria = producto.get('categoria', 'Sin categoría')
                if categoria not in agrupados:
                    agrupados[categoria] = []
                agrupados[categoria].append(producto)
            
            return agrupados
            
        except Exception as e:
            logger.error(f"Error al agrupar productos por categoría: {str(e)}")
            return {}
    
    # ==================== VALIDACIONES ====================
    
    def _validar_datos_producto(self, datos: Dict, es_actualizacion: bool = False) -> Tuple[bool, str]:
        """
        Valida los datos de un producto antes de crear/actualizar
        
        Args:
            datos: Datos del producto a validar
            es_actualizacion: Si es una actualización
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error si aplica)
        """
        try:
            if not es_actualizacion:
                # Campos requeridos para creación
                if 'nombre_comercial' not in datos or not datos['nombre_comercial']:
                    return False, "El nombre comercial es obligatorio"
                
                if 'id_categoria' not in datos:
                    return False, "La categoría es obligatoria"
                
                if 'unidad' not in datos or not datos['unidad']:
                    return False, "La unidad de medida es obligatoria"
            
            # Validar nombre comercial
            if 'nombre_comercial' in datos:
                if not datos['nombre_comercial'] or len(datos['nombre_comercial'].strip()) == 0:
                    return False, "El nombre comercial no puede estar vacío"
                
                if len(datos['nombre_comercial']) > 200:
                    return False, "El nombre comercial no puede exceder 200 caracteres"
            
            # Validar precio si está presente
            if 'precio' in datos and datos['precio'] is not None:
                try:
                    precio = float(datos['precio'])
                    if precio < 0:
                        return False, "El precio no puede ser negativo"
                except (ValueError, TypeError):
                    return False, "El precio debe ser un número válido"
            
            # Validar unidad de medida
            unidades_validas = ['litros', 'kg', 'gramos', 'ml', 'unidades', 'galones']
            if 'unidad' in datos and datos['unidad']:
                if datos['unidad'].lower() not in unidades_validas:
                    logger.warning(f"Unidad de medida no estándar: {datos['unidad']}")
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error al validar datos de producto: {str(e)}")
            return False, f"Error en validación: {str(e)}"
    
    # ==================== UTILIDADES ====================
    
    def contar_productos(self, id_categoria: Optional[int] = None, 
                        solo_activos: bool = True) -> int:
        """
        Cuenta el total de productos
        
        Args:
            id_categoria: Si se especifica, cuenta solo productos de esa categoría
            solo_activos: Si True, cuenta solo productos activos
            
        Returns:
            int: Cantidad de productos
        """
        try:
            return self.producto_repo.contar_productos(id_categoria)
        except Exception as e:
            logger.error(f"Error al contar productos: {str(e)}")
            return 0