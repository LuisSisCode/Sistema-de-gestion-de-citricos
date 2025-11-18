# bd_conecciones/__init__.py

"""
Capa de acceso a datos para el Sistema Agrícola.

Esta capa maneja toda la interacción con la base de datos organizando
el código en repositorios (CRUD) y servicios (lógica de negocio).

Estructura:
- nucleo/: Clases base y utilidades compartidas
- repositorios/: Operaciones CRUD por entidad
- servicios/: Lógica de negocio y validaciones complejas
"""

# Importaciones principales del núcleo
from .core.excepciones_bd import (
    ExcepcionBaseDatos,
    ErrorConexion, 
    ErrorConsulta,
    RegistroNoEncontrado,
    RegistroYaExiste,
    ErrorValidacion,
    RegistroTieneDependencias
)

# Importaciones de repositorios
from .repositories import (
    ProductorRepositorio,
    ParcelaRepositorio,
    RelacionRepositorio,
    RelacionCultivoRepositorio,
    CicloProduccionRepositorio,
    TipoCultivoRepositorio,
    VariedadCultivoRepositorio,
    # Nuevos repositorios de Clientes y Ventas
    ClienteRepositorio,
    VentaRepositorio
)

# Importaciones de servicios
from .services import (
    ProductorServicio,
    ParcelaServicio,
    GestionServicio,
    GestionCultivoServicio,
    CicloProduccionServicio,
    TipoCultivoServicio,
    VariedadCultivoServicio,
    # Nuevos servicios de Clientes y Ventas
    ClienteService,
    VentaService
)

__version__ = "1.0.0"

__all__ = [
    # Excepciones
    'ExcepcionBaseDatos',
    'ErrorConexion',
    'ErrorConsulta', 
    'RegistroNoEncontrado',
    'RegistroYaExiste',
    'ErrorValidacion',
    'RegistroTieneDependencias',
    
    # Repositorios
    'ProductorRepositorio',
    'ParcelaRepositorio',
    'RelacionRepositorio',
    'RelacionCultivoRepositorio',
    'CicloProduccionRepositorio',
    'TipoCultivoRepositorio',
    'VariedadCultivoRepositorio',
    'ClienteRepositorio',
    'VentaRepositorio',
    
    # Servicios
    'ProductorServicio',
    'ParcelaServicio', 
    'GestionServicio',
    'GestionCultivoServicio',
    'CicloProduccionServicio',
    'TipoCultivoServicio',
    'VariedadCultivoServicio',
    'ClienteService',
    'VentaService',
]