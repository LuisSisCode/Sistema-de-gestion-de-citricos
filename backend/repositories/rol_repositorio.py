# backend/repositories/rol_repositorio.py
"""
Repositorio para gestión de roles del sistema
"""

from backend.core.repositorio_base import RepositorioBase
from backend.core.excepciones_bd import RegistroNoEncontrado
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl
from typing import List, Dict, Optional


class RolRepositorio(RepositorioBase):
    """Repositorio para gestión de roles del sistema"""
    
    @cacheable('roles', ttl=7200)  # 2 horas
    def obtener_todos(self) -> List[Dict]:
        """
        Obtiene todos los roles activos del sistema
        
        Returns:
            list: Lista de roles con sus datos
        """
        query = """
        SELECT 
            id_rol,
            nombre_rol,
            descripcion,
            nivel_acceso,
            activo
        FROM Roles
        WHERE activo = 1
        ORDER BY nivel_acceso DESC, nombre_rol
        """
        
        rows = self._ejecutar_consulta(query)
        roles = []
        
        for row in rows:
            rol = {
                'id_rol': row.id_rol,
                'nombre_rol': row.nombre_rol,
                'descripcion': row.descripcion if hasattr(row, 'descripcion') else '',
                'nivel_acceso': row.nivel_acceso,
                'activo': bool(row.activo)
            }
            roles.append(rol)
        
        print(f"✅ Obtenidos {len(roles)} roles del sistema")
        return roles
    
    @cacheable('roles', ttl=7200)
    def obtener_por_id(self, id_rol: int) -> Dict:
        """
        Obtiene un rol por su ID
        
        Args:
            id_rol: ID del rol a buscar
            
        Returns:
            dict: Datos del rol
            
        Raises:
            RegistroNoEncontrado: Si el rol no existe
        """
        query = """
        SELECT 
            id_rol,
            nombre_rol,
            descripcion,
            nivel_acceso,
            activo
        FROM Roles
        WHERE id_rol = ? AND activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_rol,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Rol con ID {id_rol} no encontrado")
        
        row = rows[0]
        rol = {
            'id_rol': row.id_rol,
            'nombre_rol': row.nombre_rol,
            'descripcion': row.descripcion if hasattr(row, 'descripcion') else '',
            'nivel_acceso': row.nivel_acceso,
            'activo': bool(row.activo)
        }
        
        print(f"✅ Rol '{rol['nombre_rol']}' obtenido")
        return rol
    
    @cacheable('roles', ttl=7200)
    def obtener_permisos_rol(self, id_rol: int) -> List[Dict]:
        """
        Obtiene los permisos asociados a un rol
        
        Args:
            id_rol: ID del rol
            
        Returns:
            list: Lista de permisos del rol
        """
        query = """
        SELECT 
            id_permiso,
            id_rol,
            modulo,
            puede_leer,
            puede_crear,
            puede_editar,
            puede_eliminar
        FROM Permisos
        WHERE id_rol = ?
        ORDER BY modulo
        """
        
        rows = self._ejecutar_consulta(query, (id_rol,))
        permisos = []
        
        for row in rows:
            permiso = {
                'id_permiso': row.id_permiso,
                'id_rol': row.id_rol,
                'modulo': row.modulo,
                'puede_leer': bool(row.puede_leer),
                'puede_crear': bool(row.puede_crear),
                'puede_editar': bool(row.puede_editar),
                'puede_eliminar': bool(row.puede_eliminar)
            }
            permisos.append(permiso)
        
        print(f"✅ Obtenidos {len(permisos)} permisos para rol ID {id_rol}")
        return permisos
    
    def verificar_permiso(
        self, 
        id_rol: int, 
        modulo: str, 
        accion: str
    ) -> bool:
        """
        Verifica si un rol tiene permiso para realizar una acción en un módulo
        
        Args:
            id_rol: ID del rol a verificar
            modulo: Nombre del módulo (ej: 'agricultores', 'parcelas')
            accion: Acción a verificar ('leer', 'crear', 'editar', 'eliminar')
            
        Returns:
            bool: True si tiene permiso, False en caso contrario
        """
        # Mapeo de acciones a columnas en la tabla Permisos
        acciones_map = {
            'leer': 'puede_leer',
            'crear': 'puede_crear',
            'editar': 'puede_editar',
            'eliminar': 'puede_eliminar'
        }
        
        columna = acciones_map.get(accion.lower())
        if not columna:
            print(f"⚠️  Acción '{accion}' no válida")
            return False
        
        query = f"""
        SELECT {columna}
        FROM Permisos
        WHERE id_rol = ? AND modulo = ?
        """
        
        resultado = self._ejecutar_consulta_escalar(query, (id_rol, modulo))
        
        tiene_permiso = bool(resultado) if resultado is not None else False
        
        if tiene_permiso:
            print(f"✅ Rol {id_rol} TIENE permiso: {accion} en {modulo}")
        else:
            print(f"❌ Rol {id_rol} NO tiene permiso: {accion} en {modulo}")
        
        return tiene_permiso
    
    def obtener_roles_combo(self) -> List[Dict]:
        """
        Obtiene roles formateados para combo boxes
        
        Returns:
            list: Lista de roles con formato simple
        """
        query = """
        SELECT id_rol, nombre_rol
        FROM Roles
        WHERE activo = 1
        ORDER BY nivel_acceso DESC
        """
        
        rows = self._ejecutar_consulta(query)
        roles = []
        
        for row in rows:
            roles.append({
                'id': row.id_rol,
                'nombre': row.nombre_rol
            })
        
        return roles
    
    def obtener_modulos_disponibles(self) -> List[str]:
        """
        Obtiene la lista de módulos únicos con permisos
        
        Returns:
            list: Lista de nombres de módulos
        """
        query = """
        SELECT DISTINCT modulo
        FROM Permisos
        ORDER BY modulo
        """
        
        rows = self._ejecutar_consulta(query)
        modulos = [row.modulo for row in rows]
        
        print(f"✅ Módulos con permisos: {', '.join(modulos)}")
        return modulos
    
    def es_rol_admin(self, id_rol: int) -> bool:
        """
        Verifica si un rol es de nivel administrador
        
        Args:
            id_rol: ID del rol
            
        Returns:
            bool: True si es admin (nivel_acceso >= 90)
        """
        try:
            rol = self.obtener_por_id(id_rol)
            return rol.get('nivel_acceso', 0) >= 90
        except RegistroNoEncontrado:
            return False