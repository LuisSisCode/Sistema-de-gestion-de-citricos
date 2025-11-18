from .auth_model import AutoModel
from .productores_parcelas_model import ProductoresParcelasModels
from .agroquimicos_model import AgroquimicosModel
from .dashboard_model import DashboardModel
from .cultivos_model import CultivosModel
from .maquinaria_model import MaquinariaModel
from .reportes_model import *
from .usuario_model import UsuariosRolesModel
from .clientes_model import ClientesModel
from .ventas_model import VentasModel
"""
Models QObject - Conectores entre QML y Backend

Models disponibles:
- InventarioModel: Gestión de inventario con FIFO y alertas
- VentaModel: Procesamiento de ventas con carrito reactivo
- CompraModel: Gestión de compras con auto-creación de lotes

Todos los models tienen Signals/Slots/Properties para integración QML
"""


__all__ = [
    'AutoModel',
    'ProductoresParcelasModels',
    'AgroquimicosModel',   
    'DashboardModel',
    'CultivosModel',
    'GastosModel',
    'MaquinariaModel',
    #'ReportesModel',
    'UsuariosRolesModel',
    'ClientesModel',
    'VentasModel',
]

print("🎯 Models QObject cargados")