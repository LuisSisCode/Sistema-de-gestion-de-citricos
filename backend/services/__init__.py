# bd_conecciones/servicios/__init__.py

"""
Paquete de servicios para el sistema agrícola.
Contiene toda la lógica de negocio organizada por módulos.
"""

# Servicios de Agricultores y Parcelas
from .AgricultorParcelaServ.productor_servicio import ProductorServicio
from .AgricultorParcelaServ.parcela_servicio import ParcelaServicio
from .AgricultorParcelaServ.gestion_servicio import GestionServicio

# Servicios de Cultivos
from .CultivosServ.tipo_cultivo_servicio import TipoCultivoServicio
from .CultivosServ.variedad_cultivo_servicio import VariedadCultivoServicio
from .CultivosServ.ciclo_produccion_servicio import CicloProduccionServicio
from .CultivosServ.gestion_cultivo_servicio import GestionCultivoServicio
from .CultivosServ.analisis_rentabilidad_servicio import AnalisisRentabilidadServicio

# Servicios de Clientes y Ventas
from .ClientesVentasServ.cliente_service import ClienteService
from .ClientesVentasServ.venta_servicie import VentaService

__all__ = [
    # Agricultores y Parcelas
    'ProductorServicio',
    'ParcelaServicio',
    'GestionServicio',
    
    # Cultivos
    'TipoCultivoServicio',
    'VariedadCultivoServicio', 
    'CicloProduccionServicio',
    'GestionCultivoServicio',
    'AnalisisRentabilidadServicio',
    
    # Clientes y Ventas
    'ClienteService',
    'VentaServices',
]