# bd_conecciones/servicios/ClientesVentasServ/__init__.py

"""
Paquete de servicios para la gestión de clientes y ventas.

Este paquete contiene los servicios que manejan la lógica de negocio
relacionada con clientes, ventas y sus operaciones complejas.

Módulos:
    - cliente_servicio: Lógica de negocio para clientes
    - venta_servicio: Lógica de negocio para ventas
    - gestion_cliente_venta_servicio: Orquestación y fachada para operaciones complejas
"""

from .cliente_servicio import ClienteServicio
from .venta_servicio import VentaServicio
from .gestion_cliente_venta_servicio import GestionClienteVentaServicio

__all__ = [
    'ClienteServicio',
    'VentaServicio',
    'GestionClienteVentaServicio'
]

__version__ = '1.0.0'
__author__ = 'AgroIchilo Development Team'