# bd_conecciones/repositorios/__init__.py

"""
Repositorios para gestión de productores y parcelas.

Este módulo contiene los repositorios que manejan las operaciones CRUD
para productores y parcelas.
"""

from .productor_repositorio import ProductorRepositorio
from .parcela_repositorio import ParcelaRepositorio

__all__ = [
    'ProductorRepositorio',
    'ParcelaRepositorio'
]

__version__ = "1.0.0"