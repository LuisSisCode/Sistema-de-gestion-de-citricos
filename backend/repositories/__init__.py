# bd_conecciones/repositorios/__init__.py

"""
Paquete de repositorios para el sistema agrícola.
Contiene todos los repositorios organizados por módulos.
"""

# Repositorios de Usuarios y Autentificación
from .UsuariosRep.usuario_repositorio import UsuarioRepositorio
from .UsuariosRep.auto_repositorio import AutoRepositorio

# Repositorios de Agricultores y Parcelas
from .Productor_Parcelas_rep.productor_repositorio import ProductorRepositorio
from .Productor_Parcelas_rep.parcela_repositorio import ParcelaRepositorio

# Repositorios de Cultivos
from .CultivosRepositorio.tipo_cultivo_repositorio import TipoCultivoRepositorio
from .CultivosRepositorio.variedad_cultivo_repositorio import VariedadCultivoRepositorio
from .CultivosRepositorio.ciclo_produccion_repositorio import CicloProduccionRepositorio
from. CultivosRepositorio.lote_cosecha_repositorio import LoteCosechaRepositorio
from .CultivosRepositorio.relacion_cultivo_repositorio import RelacionCultivoRepositorio

# Repositorios de Clientes y Ventas
from .ClientesVentasRep.cliente_repositorio import ClienteRepositorio
from .ClientesVentasRep.venta_repositorio import VentaRepositorio

# Agroquímicos y Tratamientos
from .AgroquimicosRep.categoria_repositorio import CategoriaRepositorio
from .AgroquimicosRep.mezcla_repositorio import MezclaRepositorio
from .AgroquimicosRep.tratamiento_repositorio import TratamientoRepositorio
from .AgroquimicosRep.producto_repositorio import ProductoRepositorio

__all__ = [
    # Usuarios y autentificacion
    'UsuarioRepositorio',
    'AutoRepositorio',
    # Agricultores y Parcelas
    'ProductorRepositorio',
    'ParcelaRepositorio', 
    
    # Cultivos
    'TipoCultivoRepositorio',
    'VariedadCultivoRepositorio',
    'CicloProduccionRepositorio',
    'RelacionCultivoRepositorio',
    'LoteCosechaRepositorio',
    
    # Clientes y Ventas
    'ClienteRepositorio',
    'VentaRepositorio',

    # Agroquímicos y Tratamientos
    'CategoriaRepositorio',
    'MezclaRepositorio',
    'TratamientoRepositorio',
    'ProductoRepositorio',
]