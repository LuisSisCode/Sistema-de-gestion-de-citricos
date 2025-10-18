# bd_conecciones/repositorio/CultivosRepositorio/__init__.py

"""
Repositorios para gestión del ecosistema de cultivos.

Este módulo contiene los repositorios que manejan las operaciones CRUD
para tipos de cultivo, variedades, ciclos de producción y sus relaciones.
"""

from .tipo_cultivo_repositorio import TipoCultivoRepositorio
from .variedad_cultivo_repositorio import VariedadCultivoRepositorio
from .ciclo_produccion_repositorio import CicloProduccionRepositorio
from .lote_cosecha_repositorio import LoteCosechaRepositorio
from .relacion_cultivo_repositorio import RelacionCultivoRepositorio

__all__ = [
    'TipoCultivoRepositorio',
    'VariedadCultivoRepositorio',
    'CicloProduccionRepositorio',
    'RelacionCultivoRepositorio',
    'LoteCosechaRepositorio'
]

__version__ = "1.0.0"