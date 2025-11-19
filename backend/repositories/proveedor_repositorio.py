"""
Repositorio para gestión de Proveedores
Maneja todas las operaciones CRUD de la tabla Proveedores
"""

import logging
from typing import List, Dict, Optional
from backend.core.repositorio_base import RepositorioBase
from backend.core.repositorio_base import ErrorConsulta

logger = logging.getLogger(__name__)


class ProveedorRepositorio(RepositorioBase):
    """
    Repositorio para la gestión de proveedores.
    """
    
    def __init__(self):
        super().__init__()
        self.tabla = "Proveedores"
        logger.info("ProveedorRepositorio inicializado")
    
    def obtener_proveedores_activos(self) -> List[Dict]:
        """
        Obtiene la lista de proveedores activos.
        
        Returns:
            Lista de proveedores
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_proveedor, nombre, telefono, direccion, tipo_proveedor, fecha_registro, activo
                FROM Proveedores 
                WHERE activo = 1
                ORDER BY nombre
                """
                
                cursor.execute(query)
                
                proveedores = []
                for row in cursor.fetchall():
                    proveedor = {
                        'id_proveedor': int(row.id_proveedor),
                        'nombre': str(row.nombre).strip(),
                        'telefono': str(row.telefono).strip() if row.telefono else "",
                        'direccion': str(row.direccion).strip() if row.direccion else "",
                        'tipo_proveedor': str(row.tipo_proveedor).strip() if row.tipo_proveedor else "",
                        'fecha_registro': str(row.fecha_registro).strip() if row.fecha_registro else "",
                        'activo': bool(row.activo)
                    }
                    proveedores.append(proveedor)
                
                logger.info(f"Se obtuvieron {len(proveedores)} proveedores activos")
                return proveedores
                
        except Exception as e:
            logger.error(f"Error al obtener proveedores activos: {str(e)}")
            raise ErrorConsulta(f"Error al obtener proveedores: {str(e)}")
    
    def obtener_proveedor_por_id(self, id_proveedor: int) -> Optional[Dict]:
        """
        Obtiene un proveedor específico por su ID.
        
        Args:
            id_proveedor: ID del proveedor
            
        Returns:
            Diccionario con datos del proveedor o None si no existe
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_proveedor, nombre, telefono, direccion, tipo_proveedor, fecha_registro, activo
                FROM Proveedores 
                WHERE id_proveedor = ? AND activo = 1
                """
                
                cursor.execute(query, (id_proveedor,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                proveedor = {
                    'id_proveedor': int(row.id_proveedor),
                    'nombre': str(row.nombre).strip(),
                    'telefono': str(row.telefono).strip() if row.telefono else "",
                    'direccion': str(row.direccion).strip() if row.direccion else "",
                    'tipo_proveedor': str(row.tipo_proveedor).strip() if row.tipo_proveedor else "",
                    'fecha_registro': str(row.fecha_registro).strip() if row.fecha_registro else "",
                    'activo': bool(row.activo)
                }
                
                return proveedor
                
        except Exception as e:
            logger.error(f"Error al obtener proveedor por ID {id_proveedor}: {str(e)}")
            raise ErrorConsulta(f"Error al obtener proveedor: {str(e)}")