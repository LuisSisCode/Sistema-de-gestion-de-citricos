# backend/services/AgroquimicosServ/__init__.py
"""
Servicios del módulo de Agroquímicos
Lógica de negocio para productos, categorías, mezclas y tratamientos
"""

from .producto_service import ProductoService
from .categoria_service import CategoriaService
from .mezcla_service import MezclaService
from .tratamiento_service import TratamientoService

__all__ = [
    'ProductoService',
    'CategoriaService',
    'MezclaService',
    'TratamientoService'
]