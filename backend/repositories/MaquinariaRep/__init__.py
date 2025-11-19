"""
Repositorios del módulo de Maquinaria
Gestiona el acceso a datos de maquinaria, mantenimientos y combustible.
"""

from .maquinaria_repositorio import MaquinariaRepositorio
from .mantenimiento_repositorio import MantenimientoRepositorio
from .compra_combustible_repositorio import CompraCombustibleRepositorio

__all__ = [
    'MaquinariaRepositorio',
    'MantenimientoRepositorio',
    'CompraCombustibleRepositorio'
]