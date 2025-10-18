# bd_conecciones/servicios/AgricultorParcelasServ/__init__.py

"""
Servicios para gestión de agricultores y parcelas.

Este módulo contiene los servicios que manejan la lógica de negocio
para agricultores, parcelas y la gestión general del sistema.
"""

from .agricultor_servicio import AgricultorServicio
from .parcela_servicio import ParcelaServicio
from .gestion_servicio import GestionServicio

__all__ = [
    'AgricultorServicio',
    'ParcelaServicio',
    'GestionServicio'
]

__version__ = "1.0.0"