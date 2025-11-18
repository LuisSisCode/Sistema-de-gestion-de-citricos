# bd_conecciones/repositorio/ClientesVentasRep/__init__.py

"""
Paquete de repositorios para la gestión de clientes y ventas.

Este paquete contiene los repositorios que manejan las operaciones CRUD
y consultas relacionadas con clientes, ventas, detalles de venta y sus relaciones.

Módulos:
    - cliente_repositorio: Operaciones CRUD para clientes
    - venta_repositorio: Operaciones CRUD para ventas principales  
    - detalle_venta_repositorio: Operaciones CRUD para detalles de venta
    - estado_venta_repositorio: Operaciones CRUD para estados de venta
    - relacion_cliente_venta_repositorio: Consultas complejas y relaciones
"""

from .cliente_repositorio import ClienteRepositorio
from .venta_repositorio import VentaRepositorio


__all__ = [
    'ClienteRepositorio',
    'VentaRepositorio',

]

__version__ = '1.0.0'
__author__ = 'AgroIchilo Development Team'