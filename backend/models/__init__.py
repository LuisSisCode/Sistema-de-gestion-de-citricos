from .auth_model import AuthModel
from .agricultores_parcelas_model import AgricultoresParcelasModels
from .agroquimicos_model import AgroquimicosModel
from .dashboard_model import *
from .cultivos_model import CultivosModel
from .gastos_model import *
from .maquinaria_model import MaquinariaModel
from .reportes_model import *
from .usuario_model import UsuariosRolesModel
from .ventas_cliente_model import ClientesVentaModel
"""
Models QObject - Conectores entre QML y Backend

Models disponibles:
- InventarioModel: Gestión de inventario con FIFO y alertas
- VentaModel: Procesamiento de ventas con carrito reactivo
- CompraModel: Gestión de compras con auto-creación de lotes

Todos los models tienen Signals/Slots/Properties para integración QML
"""


__all__ = [
    'AuthModel',
    'AgricultoresParcelasModels',
    'AgroquimicosModel',   
    #'DashboardModel',
    'CultivosModel',
    #'GastosModel',
    'MaquinariaModel',
    #'ReportesModel',
    'UsuariosRolesModel',
    'ClientesVentaModel',
]

print("🎯 Models QObject cargados")