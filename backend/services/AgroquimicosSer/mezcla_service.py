# backend/services/AgroquimicosServ/mezcla_service.py
"""
Servicio de Mezclas de Agroquímicos
Contiene la lógica de negocio para gestión de mezclas y sus productos
"""

import logging
from typing import List, Dict, Optional, Tuple
from backend.repositories.AgroquimicosRep.mezcla_repositorio import MezclaRepositorio
from backend.repositories.AgroquimicosRep.producto_repositorio import ProductoRepositorio
from backend.core.repositorio_base import ErrorConsulta

logger = logging.getLogger(__name__)


class MezclaService:
    """Servicio con lógica de negocio para Mezclas de Agroquímicos"""
    
    def __init__(self):
        self.mezcla_repo = MezclaRepositorio()
        self.producto_repo = ProductoRepositorio()
        logger.info("MezclaService inicializado")
    
    # ==================== CONSULTAS ====================
    
    def obtener_todas_mezclas(self) -> List[Dict]:
        """
        Obtiene todas las mezclas
        
        Returns:
            List[Dict]: Lista de mezclas
        """
        try:
            return self.mezcla_repo.obtener_todas()
        except Exception as e:
            logger.error(f"Error al obtener mezclas: {str(e)}")
            raise ErrorConsulta(f"Error al obtener mezclas: {str(e)}")
    
    def obtener_mezcla(self, id_mezcla: int, incluir_detalles: bool = False) -> Optional[Dict]:
        """
        Obtiene una mezcla específica
        
        Args:
            id_mezcla: ID de la mezcla
            incluir_detalles: Si True, incluye los productos de la mezcla
            
        Returns:
            Dict: Datos de la mezcla o None
        """
        try:
            if incluir_detalles:
                return self.mezcla_repo.obtener_mezcla_completa(id_mezcla)
            else:
                return self.mezcla_repo.obtener_por_id(id_mezcla)
        except Exception as e:
            logger.error(f"Error al obtener mezcla {id_mezcla}: {str(e)}")
            raise ErrorConsulta(f"Error al obtener mezcla: {str(e)}")
    
    def obtener_mezclas_activas(self) -> List[Dict]:
        """
        Obtiene solo las mezclas activas
        
        Returns:
            List[Dict]: Lista de mezclas activas
        """
        try:
            return self.mezcla_repo.obtener_activas()
        except Exception as e:
            logger.error(f"Error al obtener mezclas activas: {str(e)}")
            return []
    
    def obtener_detalles_mezcla(self, id_mezcla: int) -> List[Dict]:
        """
        Obtiene los productos que componen una mezcla
        
        Args:
            id_mezcla: ID de la mezcla
            
        Returns:
            List[Dict]: Lista de productos de la mezcla
        """
        try:
            return self.mezcla_repo.obtener_detalles(id_mezcla)
        except Exception as e:
            logger.error(f"Error al obtener detalles de mezcla {id_mezcla}: {str(e)}")
            return []
    
    # ==================== CREACIÓN ====================
    
    def crear_mezcla(self, datos: Dict, productos: Optional[List[Dict]] = None) -> Tuple[bool, Optional[int], str]:
        """
        Crea una nueva mezcla con sus productos
        
        Args:
            datos: Diccionario con los datos de la mezcla
                - nombre (str): Nombre de la mezcla
                - descripcion (str, optional): Propósito de la mezcla
                - activo (bool, optional): Estado activo
            productos: Lista de productos (opcional)
                Cada producto debe tener:
                - id_producto (int): ID del producto
                - dosis (float): Dosis del producto
                - orden (int, optional): Orden de aplicación
            
        Returns:
            Tuple[bool, Optional[int], str]: (Éxito, ID de la mezcla, Mensaje)
        """
        try:
            # Validaciones
            validacion = self._validar_datos_mezcla(datos)
            if not validacion[0]:
                return False, None, validacion[1]
            
            # Validar productos si se proporcionaron
            if productos:
                validacion_productos = self._validar_productos_mezcla(productos)
                if not validacion_productos[0]:
                    return False, None, validacion_productos[1]
            
            # Crear la mezcla
            exito, id_mezcla = self.mezcla_repo.crear(datos, productos)
            
            if exito:
                num_productos = len(productos) if productos else 0
                logger.info(f"Mezcla '{datos['nombre']}' creada con ID: {id_mezcla} y {num_productos} productos")
                return True, id_mezcla, "Mezcla creada exitosamente"
            else:
                return False, None, "Error al crear la mezcla en la base de datos"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al crear mezcla: {str(e)}")
            return False, None, str(e)
        except Exception as e:
            logger.error(f"Error al crear mezcla: {str(e)}")
            return False, None, f"Error al crear mezcla: {str(e)}"
    
    def agregar_producto_a_mezcla(self, id_mezcla: int, id_producto: int, dosis: float, orden: Optional[int] = None) -> Tuple[bool, str]:
        """
        Agrega un producto a una mezcla existente
        
        Args:
            id_mezcla: ID de la mezcla
            id_producto: ID del producto a agregar
            dosis: Dosis del producto
            orden: Orden de aplicación (opcional)
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que la mezcla exista
            if not self.mezcla_repo.existe(id_mezcla):
                return False, "La mezcla no existe"
            
            # Verificar que el producto exista
            if not self.producto_repo.obtener_por_id(id_producto):
                return False, "El producto no existe"
            
            # Validar dosis
            if dosis <= 0:
                return False, "La dosis debe ser mayor a cero"
            
            # Agregar el producto
            exito = self.mezcla_repo.agregar_producto_a_mezcla(id_mezcla, id_producto, dosis, orden)
            
            if exito:
                logger.info(f"Producto {id_producto} agregado a mezcla {id_mezcla}")
                return True, "Producto agregado a la mezcla exitosamente"
            else:
                return False, "Error al agregar el producto a la mezcla"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al agregar producto a mezcla: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error al agregar producto a mezcla: {str(e)}")
            return False, f"Error: {str(e)}"
    
    # ==================== ACTUALIZACIÓN ====================
    
    def actualizar_mezcla(self, id_mezcla: int, datos: Dict) -> Tuple[bool, str]:
        """
        Actualiza una mezcla existente
        
        Args:
            id_mezcla: ID de la mezcla a actualizar
            datos: Datos a actualizar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que la mezcla exista
            if not self.mezcla_repo.existe(id_mezcla):
                return False, "La mezcla no existe"
            
            # Validaciones parciales
            if 'nombre' in datos:
                if not datos['nombre'] or len(datos['nombre'].strip()) == 0:
                    return False, "El nombre de la mezcla no puede estar vacío"
            
            # Actualizar
            exito = self.mezcla_repo.actualizar(id_mezcla, datos)
            
            if exito:
                logger.info(f"Mezcla {id_mezcla} actualizada exitosamente")
                return True, "Mezcla actualizada exitosamente"
            else:
                return False, "Error al actualizar la mezcla"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al actualizar mezcla: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error al actualizar mezcla {id_mezcla}: {str(e)}")
            return False, f"Error: {str(e)}"
    
    def actualizar_detalle_mezcla(self, id_detalle: int, dosis: Optional[float] = None, orden: Optional[int] = None) -> Tuple[bool, str]:
        """
        Actualiza un producto dentro de una mezcla
        
        Args:
            id_detalle: ID del detalle a actualizar
            dosis: Nueva dosis (opcional)
            orden: Nuevo orden (opcional)
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            if dosis is not None and dosis <= 0:
                return False, "La dosis debe ser mayor a cero"
            
            exito = self.mezcla_repo.actualizar_detalle(id_detalle, dosis, orden)
            
            if exito:
                logger.info(f"Detalle {id_detalle} actualizado")
                return True, "Detalle de mezcla actualizado exitosamente"
            else:
                return False, "Error al actualizar el detalle de la mezcla"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al actualizar detalle: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error al actualizar detalle: {str(e)}")
            return False, f"Error: {str(e)}"
    
    def reemplazar_productos_mezcla(self, id_mezcla: int, nuevos_productos: List[Dict]) -> Tuple[bool, str]:
        """
        Reemplaza todos los productos de una mezcla
        
        Args:
            id_mezcla: ID de la mezcla
            nuevos_productos: Lista de nuevos productos
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que la mezcla exista
            if not self.mezcla_repo.existe(id_mezcla):
                return False, "La mezcla no existe"
            
            # Validar productos
            validacion = self._validar_productos_mezcla(nuevos_productos)
            if not validacion[0]:
                return False, validacion[1]
            
            # Eliminar productos actuales
            self.mezcla_repo.eliminar_todos_productos(id_mezcla)
            
            # Agregar nuevos productos
            for producto in nuevos_productos:
                self.mezcla_repo.agregar_producto_a_mezcla(
                    id_mezcla,
                    producto['id_producto'],
                    producto['dosis'],
                    producto.get('orden')
                )
            
            logger.info(f"Productos de mezcla {id_mezcla} reemplazados")
            return True, "Productos de la mezcla actualizados exitosamente"
            
        except Exception as e:
            logger.error(f"Error al reemplazar productos de mezcla: {str(e)}")
            return False, f"Error: {str(e)}"
    
    # ==================== ELIMINACIÓN ====================
    
    def eliminar_mezcla(self, id_mezcla: int) -> Tuple[bool, str]:
        """
        Elimina (desactiva) una mezcla
        
        Args:
            id_mezcla: ID de la mezcla a eliminar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            if not self.mezcla_repo.existe(id_mezcla):
                return False, "La mezcla no existe"
            
            exito = self.mezcla_repo.eliminar(id_mezcla)
            
            if exito:
                logger.info(f"Mezcla {id_mezcla} eliminada (desactivada)")
                return True, "Mezcla eliminada exitosamente"
            else:
                return False, "Error al eliminar la mezcla"
                
        except ErrorConsulta as e:
            logger.error(f"Error de BD al eliminar mezcla: {str(e)}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Error al eliminar mezcla {id_mezcla}: {str(e)}")
            return False, f"Error: {str(e)}"
    
    def eliminar_producto_de_mezcla(self, id_detalle: int) -> Tuple[bool, str]:
        """
        Elimina un producto de una mezcla
        
        Args:
            id_detalle: ID del detalle a eliminar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            exito = self.mezcla_repo.eliminar_producto_de_mezcla(id_detalle)
            
            if exito:
                logger.info(f"Producto eliminado de la mezcla (detalle {id_detalle})")
                return True, "Producto eliminado de la mezcla exitosamente"
            else:
                return False, "Error al eliminar el producto de la mezcla"
                
        except Exception as e:
            logger.error(f"Error al eliminar producto de mezcla: {str(e)}")
            return False, f"Error: {str(e)}"
    
    def vaciar_mezcla(self, id_mezcla: int) -> Tuple[bool, str]:
        """
        Elimina todos los productos de una mezcla
        
        Args:
            id_mezcla: ID de la mezcla
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            if not self.mezcla_repo.existe(id_mezcla):
                return False, "La mezcla no existe"
            
            exito = self.mezcla_repo.eliminar_todos_productos(id_mezcla)
            
            if exito:
                logger.info(f"Todos los productos de la mezcla {id_mezcla} fueron eliminados")
                return True, "Mezcla vaciada exitosamente"
            else:
                return False, "Error al vaciar la mezcla"
                
        except Exception as e:
            logger.error(f"Error al vaciar mezcla: {str(e)}")
            return False, f"Error: {str(e)}"
    
    # ==================== ANÁLISIS Y CÁLCULOS ====================
    
    def calcular_costo_mezcla(self, id_mezcla: int, cantidad_agua: float = 1.0) -> Tuple[float, List[Dict]]:
        """
        Calcula el costo total de una mezcla según las dosis y precios
        
        Args:
            id_mezcla: ID de la mezcla
            cantidad_agua: Cantidad de agua en litros (default: 1L para obtener costo por litro)
            
        Returns:
            Tuple[float, List[Dict]]: (Costo total, Desglose por producto)
        """
        try:
            detalles = self.mezcla_repo.obtener_detalles(id_mezcla)
            
            if not detalles:
                return 0.0, []
            
            costo_total = 0.0
            desglose = []
            
            for detalle in detalles:
                # Obtener información completa del producto
                producto = self.producto_repo.obtener_por_id(detalle['id_producto'])
                if not producto:
                    continue
                
                # Calcular costo: (dosis / cantidad_agua) * precio
                dosis_por_litro = detalle['dosis'] / cantidad_agua if cantidad_agua > 0 else detalle['dosis']
                costo_producto = dosis_por_litro * producto['precio']
                costo_total += costo_producto
                
                desglose.append({
                    'producto': producto['nombre_comercial'],
                    'dosis': detalle['dosis'],
                    'precio_unitario': producto['precio'],
                    'costo': costo_producto
                })
            
            return round(costo_total, 2), desglose
            
        except Exception as e:
            logger.error(f"Error al calcular costo de mezcla: {str(e)}")
            return 0.0, []
    
    def obtener_estadisticas_mezclas(self) -> Dict:
        """
        Obtiene estadísticas generales de las mezclas
        
        Returns:
            Dict: Estadísticas de mezclas
        """
        try:
            mezclas = self.mezcla_repo.obtener_todas()
            
            total_mezclas = len(mezclas)
            mezclas_activas = sum(1 for m in mezclas if m['activo'])
            
            # Mezcla con más productos
            mezclas_con_conteo = []
            for mezcla in mezclas:
                if mezcla['activo']:
                    num_productos = self.mezcla_repo.contar_productos_en_mezcla(mezcla['id_mezcla'])
                    mezclas_con_conteo.append({
                        'id_mezcla': mezcla['id_mezcla'],
                        'nombre': mezcla['nombre'],
                        'num_productos': num_productos
                    })
            
            mezcla_mayor = None
            if mezclas_con_conteo:
                mezcla_mayor = max(mezclas_con_conteo, key=lambda m: m['num_productos'])
            
            return {
                'total_mezclas': total_mezclas,
                'mezclas_activas': mezclas_activas,
                'mezcla_con_mas_productos': mezcla_mayor['nombre'] if mezcla_mayor else 'N/A',
                'max_productos': mezcla_mayor['num_productos'] if mezcla_mayor else 0
            }
            
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de mezclas: {str(e)}")
            return {
                'total_mezclas': 0,
                'mezclas_activas': 0,
                'mezcla_con_mas_productos': 'N/A',
                'max_productos': 0
            }
    
    # ==================== VALIDACIONES ====================
    
    def _validar_datos_mezcla(self, datos: Dict) -> Tuple[bool, str]:
        """
        Valida los datos de una mezcla antes de crear/actualizar
        
        Args:
            datos: Datos de la mezcla a validar
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error si aplica)
        """
        try:
            # Campo requerido
            if 'nombre' not in datos or not datos['nombre']:
                return False, "El nombre de la mezcla es obligatorio"
            
            # Validar nombre
            if not datos['nombre'] or len(datos['nombre'].strip()) == 0:
                return False, "El nombre de la mezcla no puede estar vacío"
            
            if len(datos['nombre']) > 200:
                return False, "El nombre de la mezcla no puede exceder 200 caracteres"
            
            # Validar propósito si está presente
            if 'descripcion' in datos and datos['descripcion']:
                if len(datos['descripcion']) > 500:
                    return False, "El propósito no puede exceder 500 caracteres"
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error al validar datos de mezcla: {str(e)}")
            return False, f"Error en validación: {str(e)}"
    
    def _validar_productos_mezcla(self, productos: List[Dict]) -> Tuple[bool, str]:
        """
        Valida una lista de productos para una mezcla
        
        Args:
            productos: Lista de productos a validar
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error si aplica)
        """
        try:
            if not productos:
                return False, "Debe especificar al menos un producto"
            
            for idx, producto in enumerate(productos, start=1):
                # Verificar campos requeridos
                if 'id_producto' not in producto:
                    return False, f"El producto #{idx} no tiene id_producto"
                
                if 'dosis' not in producto:
                    return False, f"El producto #{idx} no tiene dosis especificada"
                
                # Validar dosis
                try:
                    dosis = float(producto['dosis'])
                    if dosis <= 0:
                        return False, f"La dosis del producto #{idx} debe ser mayor a cero"
                except (ValueError, TypeError):
                    return False, f"La dosis del producto #{idx} debe ser un número válido"
                
                # Verificar que el producto exista
                if not self.producto_repo.obtener_por_id(producto['id_producto']):
                    return False, f"El producto #{idx} con ID {producto['id_producto']} no existe"
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error al validar productos de mezcla: {str(e)}")
            return False, f"Error en validación: {str(e)}"
    
    # ==================== UTILIDADES ====================
    
    def contar_mezclas(self, solo_activas: bool = True) -> int:
        """
        Cuenta el total de mezclas
        
        Args:
            solo_activas: Si True, cuenta solo mezclas activas
            
        Returns:
            int: Cantidad de mezclas
        """
        try:
            return self.mezcla_repo.contar_mezclas(solo_activas)
        except Exception as e:
            logger.error(f"Error al contar mezclas: {str(e)}")
            return 0