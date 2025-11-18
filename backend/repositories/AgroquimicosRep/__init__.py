# backend/repositories/AgroquimicosRep/__init__.py
"""
Repositorios del módulo de Agroquímicos
Manejo de acceso a datos para productos, categorías, mezclas y tratamientos
"""

from .producto_repositorio import ProductoRepositorio
from .categoria_repositorio import CategoriaRepositorio
from .mezcla_repositorio import MezclaRepositorio
from .tratamiento_repositorio import TratamientoRepositorio

__all__ = [
    'ProductoRepositorio',
    'CategoriaRepositorio',
    'MezclaRepositorio',
    'TratamientoRepositorio'
]