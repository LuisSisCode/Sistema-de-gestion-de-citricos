# bd_conecciones/repositorios/__init__.py

"""
Paquete de repositorios para el sistema agrícola.
Contiene todos los repositorios organizados por módulos.
"""

# Repositorios de Agricultores y Parcelas
from .Agriculor_Parcelas_rep.agricultor_repositorio import AgricultorRepositorio
from .Agriculor_Parcelas_rep.parcela_repositorio import ParcelaRepositorio
from .Agriculor_Parcelas_rep.relacion_AgriPar_repositorio import RelacionRepositorio

# Repositorios de Cultivos
from .CultivosRepositorio.tipo_cultivo_repositorio import TipoCultivoRepositorio
from .CultivosRepositorio.variedad_cultivo_repositorio import VariedadCultivoRepositorio
from .CultivosRepositorio.ciclo_produccion_repositorio import CicloProduccionRepositorio
from. CultivosRepositorio.lote_cosecha_repositorio import LoteCosechaRepositorio
from .CultivosRepositorio.relacion_cultivo_repositorio import RelacionCultivoRepositorio

# Repositorios de Clientes y Ventas
from .ClientesVentasRep.cliente_repositorio import ClienteRepositorio
from .ClientesVentasRep.venta_repositorio import VentaRepositorio
from .ClientesVentasRep.detalle_venta_repositorio import DetalleVentaRepositorio
from .ClientesVentasRep.estado_venta_repositorio import EstadoVentaRepositorio
from .ClientesVentasRep.relacion_cliente_venta_repositorio import RelacionClienteVentaRepositorio

__all__ = [
    # Agricultores y Parcelas
    'AgricultorRepositorio',
    'ParcelaRepositorio', 
    'RelacionRepositorio',
    
    # Cultivos
    'TipoCultivoRepositorio',
    'VariedadCultivoRepositorio',
    'CicloProduccionRepositorio',
    'RelacionCultivoRepositorio',
    'LoteCosechaRepositorio',
    
    # Clientes y Ventas
    'ClienteRepositorio',
    'VentaRepositorio',
    'DetalleVentaRepositorio',
    'EstadoVentaRepositorio',
    'RelacionClienteVentaRepositorio'
]