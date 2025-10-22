# ============================================
# backend/core/__init__.py - CORREGIDO
# ============================================
"""
Módulo core del backend - Configuración y utilidades centrales
"""

from backend.core.config import Config
from backend.core.config_manager import ConfigManager
from backend.core.database import DatabaseConnection
from backend.core.db_installer import DatabaseInstaller
from backend.core.cache_system import cache_manager, cacheable, cache_invalidator
from backend.core.excepciones_bd import *

__all__ = [
    'Config',
    'ConfigManager',
    'DatabaseConnection',
    'DatabaseInstaller',
    'cache_manager',
    'cacheable',
    'cache_invalidator',
]


# ============================================
# backend/repositories/__init__.py - CORREGIDO
# ============================================
"""
Repositorios para acceso a datos
"""

from backend.repositories.usuario_repositorio import UsuarioRepositorio
from backend.repositories.rol_repositorio import RolRepositorio

__all__ = [
    'UsuarioRepositorio',
    'RolRepositorio',
]


# ============================================
# backend/services/__init__.py - CORREGIDO
# ============================================
"""
Servicios de lógica de negocio
"""

from backend.services.auth_service import AuthService, auth_service

__all__ = [
    'AuthService',
    'auth_service',
]


# ============================================
# backend/utils/__init__.py - CORREGIDO
# ============================================
"""
Utilidades del backend
"""

from backend.utils.password_utils import PasswordUtils

__all__ = [
    'PasswordUtils',
]


# ============================================
# controllers/__init__.py - CORREGIDO
# ============================================
"""
Controladores del frontend
"""

from controllers.login_controller import LoginController

__all__ = [
    'LoginController',
]


# ============================================
# utils/__init__.py - CORREGIDO (ya lo tenías del Sprint 1.1)
# ============================================
"""
Paquete de utilidades para AgroIchilo
"""

from utils.validators import *
from utils.formatters import *

__all__ = [
    # Validators
    'validar_email',
    'validar_identificacion',
    'validar_telefono',
    'validar_area',
    'validar_precio',
    'validar_password',
    'validar_username',
    'validar_cantidad',
    'validar_texto_requerido',
    'validar_rango_fecha',
    'validar_coordenadas_gps',
    'validar_porcentaje',
    
    # Formatters
    'formatear_fecha',
    'formatear_fecha_hora',
    'formatear_moneda',
    'formatear_area',
    'formatear_porcentaje',
    'formatear_telefono',
    'limpiar_texto',
    'capitalizar_texto',
    'truncar_texto',
    'formatear_numero',
    'formatear_coordenadas',
    'formatear_ruc_nit',
    'formatear_nombre_completo',
    'formatear_si_no',
    'formatear_activo_inactivo',
    'formatear_tamanio_archivo',
]