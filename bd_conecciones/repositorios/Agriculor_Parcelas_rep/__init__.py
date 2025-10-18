# bd_conecciones/repositorio/Agricultor_Parcelas_rep/__init__.py

"""
Repositorios para gestión de agricultores y parcelas.

Este módulo contiene los repositorios que manejan las operaciones CRUD
para agricultores, parcelas y sus relaciones.
"""

from .agricultor_repositorio import AgricultorRepositorio
from .parcela_repositorio import ParcelaRepositorio
from .relacion_AgriPar_repositorio import RelacionRepositorio

__all__ = [
    'AgricultorRepositorio',
    'ParcelaRepositorio', 
    'RelacionRepositorio'
]

__version__ = "1.0.0"