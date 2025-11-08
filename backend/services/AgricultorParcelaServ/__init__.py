# bd_conecciones/servicios/AgricultorParcelasServ/__init__.py

"""
Servicios para gestión de productores y parcelas.

Este módulo contiene los servicios que manejan la lógica de negocio
para productores, parcelas y la gestión general del sistema.
"""

from .productor_servicio import ProductorServicio
from .parcela_servicio import ParcelaServicio
from .gestion_servicio import GestionServicio

__all__ = [
    'ProductorServicio',
    'ParcelaServicio',
    'GestionServicio'
]

__version__ = "1.0.0"