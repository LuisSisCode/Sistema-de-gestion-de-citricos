# backend/repositories/UsuariosRep/__init__.py

"""
Repositorios para gestión de usuarios y roles.

Este módulo expone los repositorios que manejan las operaciones CRUD
y la lógica relacionada con usuarios, roles y (si aplica) recursos adicionales.
"""

from .auto_repositorio import AutoRepositorio
from .rol_repositorio import RolRepositorio
from .usuario_repositorio import UsuarioRepositorio

__all__ = [
    "AutoRepositorio",
    "RolRepositorio",
    "UsuarioRepositorio",
]

__version__ = "1.0.0"