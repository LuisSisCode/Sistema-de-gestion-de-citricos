# backend/services/AgroquimicosServ/categoria_service.py
"""
Servicio de Categorías de Agroquímicos
Contiene la lógica de negocio para gestión de categorías
"""

import logging
from typing import List, Dict, Optional, Tuple
from backend.repositories.AgroquimicosRep.categoria_repositorio import CategoriaRepositorio

logger = logging.getLogger(__name__)


class CategoriaService:
    """Servicio con lógica de negocio para Categorías de Agroquímicos"""
    
    def __init__(self):
        self.categoria_repo = CategoriaRepositorio()
    
    # ==================== CONSULTAS ====================
    
    def obtener_todas_categorias(self) -> List[Dict]:
        """
        Obtiene todas las categorías
        
        Returns:
            List[Dict]: Lista de categorías
        """
        return self.categoria_repo.obtener_todas()
    
    def obtener_categoria(self, id_categoria: int) -> Optional[Dict]:
        """
        Obtiene una categoría específica
        
        Args:
            id_categoria: ID de la categoría
            
        Returns:
            Dict: Datos de la categoría o None
        """
        return self.categoria_repo.obtener_por_id(id_categoria)
    
    def obtener_categorias_activas(self) -> List[Dict]:
        """
        Obtiene solo las categorías activas
        
        Returns:
            List[Dict]: Lista de categorías activas
        """
        return self.categoria_repo.obtener_activas()
    
    def obtener_categorias_con_conteo(self) -> List[Dict]:
        """
        Obtiene categorías con el conteo de productos
        
        Returns:
            List[Dict]: Categorías con conteo de productos
        """
        return self.categoria_repo.obtener_con_conteo_productos()
    
    # ==================== CREACIÓN ====================
    
    def crear_categoria(self, datos: Dict) -> Tuple[bool, Optional[int], str]:
        """
        Crea una nueva categoría con validaciones
        
        Args:
            datos: Diccionario con los datos de la categoría
                - nombre (str): Nombre de la categoría
                - descripcion (str, optional): Descripción
                - activo (bool, optional): Estado activo
            
        Returns:
            Tuple[bool, Optional[int], str]: (Éxito, ID de la categoría, Mensaje)
        """
        # Validaciones
        validacion = self._validar_datos_categoria(datos)
        if not validacion[0]:
            return False, None, validacion[1]
        
        # Verificar que no exista una categoría con el mismo nombre
        if self.categoria_repo.existe_nombre(datos['nombre']):
            return False, None, f"Ya existe una categoría con el nombre '{datos['nombre']}'"
        
        # Crear la categoría
        exito, id_categoria = self.categoria_repo.crear(datos)
        
        if exito:
            logger.info(f"Categoría '{datos['nombre']}' creada con ID: {id_categoria}")
            return True, id_categoria, "Categoría creada exitosamente"
        else:
            return False, None, "Error al crear la categoría en la base de datos"
    
    # ==================== ACTUALIZACIÓN ====================
    
    def actualizar_categoria(self, id_categoria: int, datos: Dict) -> Tuple[bool, str]:
        """
        Actualiza una categoría existente con validaciones
        
        Args:
            id_categoria: ID de la categoría a actualizar
            datos: Datos a actualizar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        # Verificar que la categoría exista
        if not self.categoria_repo.existe(id_categoria):
            return False, "La categoría no existe"
        
        # Validaciones parciales
        if 'nombre' in datos:
            if not datos['nombre'] or len(datos['nombre'].strip()) == 0:
                return False, "El nombre de la categoría no puede estar vacío"
            
            # Verificar duplicados (excluyendo la categoría actual)
            if self.categoria_repo.existe_nombre(datos['nombre'], excluir_id=id_categoria):
                return False, f"Ya existe otra categoría con el nombre '{datos['nombre']}'"
        
        # Actualizar
        exito = self.categoria_repo.actualizar(id_categoria, datos)
        
        if exito:
            logger.info(f"Categoría {id_categoria} actualizada")
            return True, "Categoría actualizada exitosamente"
        else:
            return False, "Error al actualizar la categoría"
    
    # ==================== ELIMINACIÓN ====================
    
    def eliminar_categoria(self, id_categoria: int, forzar: bool = False) -> Tuple[bool, str]:
        """
        Elimina (desactiva) una categoría
        
        Args:
            id_categoria: ID de la categoría a eliminar
            forzar: Si True, elimina incluso si tiene productos asociados
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        # Verificar que exista
        if not self.categoria_repo.existe(id_categoria):
            return False, "La categoría no existe"
        
        # Verificar si tiene productos asociados
        if not forzar and self.categoria_repo.tiene_productos(id_categoria):
            return False, "No se puede eliminar la categoría porque tiene productos asociados"
        
        # Eliminar (desactivar)
        exito = self.categoria_repo.eliminar(id_categoria)
        
        if exito:
            logger.info(f"Categoría {id_categoria} eliminada (desactivada)")
            return True, "Categoría eliminada exitosamente"
        else:
            return False, "Error al eliminar la categoría"
    
    def eliminar_categoria_permanente(self, id_categoria: int) -> Tuple[bool, str]:
        """
        Elimina permanentemente una categoría
        ⚠️ USAR CON PRECAUCIÓN - No se puede deshacer
        
        Args:
            id_categoria: ID de la categoría a eliminar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        # Verificar que exista
        if not self.categoria_repo.existe(id_categoria):
            return False, "La categoría no existe"
        
        # Verificar si tiene productos asociados
        if self.categoria_repo.tiene_productos(id_categoria):
            return False, "No se puede eliminar permanentemente la categoría porque tiene productos asociados"
        
        # Eliminar permanentemente
        exito = self.categoria_repo.eliminar_permanente(id_categoria)
        
        if exito:
            logger.warning(f"Categoría {id_categoria} eliminada PERMANENTEMENTE")
            return True, "Categoría eliminada permanentemente"
        else:
            return False, "Error al eliminar permanentemente la categoría"
    
    # ==================== ANÁLISIS Y ESTADÍSTICAS ====================
    
    def obtener_estadisticas_categorias(self) -> Dict:
        """
        Obtiene estadísticas generales de las categorías
        
        Returns:
            Dict: Estadísticas de categorías
        """
        categorias = self.categoria_repo.obtener_con_conteo_productos()
        
        total_categorias = len(categorias)
        categorias_activas = sum(1 for c in categorias if c['activo'])
        categorias_con_productos = sum(1 for c in categorias if c['total_productos'] > 0)
        
        # Categoría con más productos
        categoria_mayor = None
        if categorias:
            categoria_mayor = max(categorias, key=lambda c: c['total_productos'])
        
        return {
            'total_categorias': total_categorias,
            'categorias_activas': categorias_activas,
            'categorias_con_productos': categorias_con_productos,
            'categoria_con_mas_productos': categoria_mayor['nombre'] if categoria_mayor else 'N/A',
            'max_productos': categoria_mayor['total_productos'] if categoria_mayor else 0
        }
    
    def obtener_categoria_mas_usada(self) -> Optional[Dict]:
        """
        Obtiene la categoría con más productos
        
        Returns:
            Dict: Categoría más usada o None
        """
        categorias = self.categoria_repo.obtener_con_conteo_productos()
        
        if not categorias:
            return None
        
        return max(categorias, key=lambda c: c['total_productos'])
    
    def verificar_categorias_sin_uso(self) -> List[Dict]:
        """
        Obtiene categorías que no tienen productos asociados
        
        Returns:
            List[Dict]: Lista de categorías sin productos
        """
        categorias = self.categoria_repo.obtener_con_conteo_productos()
        return [c for c in categorias if c['total_productos'] == 0 and c['activo']]
    
    # ==================== VALIDACIONES ====================
    
    def _validar_datos_categoria(self, datos: Dict) -> Tuple[bool, str]:
        """
        Valida los datos de una categoría antes de crear/actualizar
        
        Args:
            datos: Datos de la categoría a validar
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error si aplica)
        """
        # Campo requerido
        if 'nombre' not in datos:
            return False, "El nombre de la categoría es obligatorio"
        
        # Validar nombre
        if not datos['nombre'] or len(datos['nombre'].strip()) == 0:
            return False, "El nombre de la categoría no puede estar vacío"
        
        if len(datos['nombre']) > 100:
            return False, "El nombre de la categoría no puede exceder 100 caracteres"
        
        # Validar descripción si está presente
        if 'descripcion' in datos and datos['descripcion']:
            if len(datos['descripcion']) > 500:
                return False, "La descripción no puede exceder 500 caracteres"
        
        return True, "Validación exitosa"
    
    # ==================== UTILIDADES ====================
    
    def contar_categorias(self, solo_activas: bool = True) -> int:
        """
        Cuenta el total de categorías
        
        Args:
            solo_activas: Si True, cuenta solo categorías activas
            
        Returns:
            int: Cantidad de categorías
        """
        return self.categoria_repo.contar_categorias(solo_activas)
    
    def buscar_categoria_por_nombre(self, nombre: str) -> Optional[Dict]:
        """
        Busca una categoría por su nombre exacto
        
        Args:
            nombre: Nombre de la categoría
            
        Returns:
            Dict: Categoría encontrada o None
        """
        categorias = self.categoria_repo.obtener_todas()
        for categoria in categorias:
            if categoria['nombre'].lower() == nombre.lower():
                return categoria
        return None