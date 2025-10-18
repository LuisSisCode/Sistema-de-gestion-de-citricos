# bd_conecciones/servicios/__init__.py

"""
Paquete de servicios para el sistema agrícola.
Contiene toda la lógica de negocio organizada por módulos.
"""

# Servicios de Agricultores y Parcelas
from .AgricultorParcelaServ.agricultor_servicio import AgricultorServicio
from .AgricultorParcelaServ.parcela_servicio import ParcelaServicio
from .AgricultorParcelaServ.gestion_servicio import GestionServicio

# Servicios de Cultivos
from .CultivosServ.tipo_cultivo_servicio import TipoCultivoServicio
from .CultivosServ.variedad_cultivo_servicio import VariedadCultivoServicio
from .CultivosServ.ciclo_produccion_servicio import CicloProduccionServicio
from .CultivosServ.gestion_cultivo_servicio import GestionCultivoServicio
from .CultivosServ.analisis_rentabilidad_servicio import AnalisisRentabilidadServicio

# Servicios de Clientes y Ventas
from .ClientesVentasServ.cliente_servicio import ClienteServicio
from .ClientesVentasServ.venta_servicio import VentaServicio
from .ClientesVentasServ.gestion_cliente_venta_servicio import GestionClienteVentaServicio

__all__ = [
    # Agricultores y Parcelas
    'AgricultorServicio',
    'ParcelaServicio',
    'GestionServicio',
    
    # Cultivos
    'TipoCultivoServicio',
    'VariedadCultivoServicio', 
    'CicloProduccionServicio',
    'GestionCultivoServicio',
    'AnalisisRentabilidadServicio',
    
    # Clientes y Ventas
    'ClienteServicio',
    'VentaServicio',
    'GestionClienteVentaServicio'
]