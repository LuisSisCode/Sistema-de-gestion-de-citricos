# backend/services/auth_service.py
"""
Servicio de autenticación y gestión de sesión
"""

from typing import Optional, Dict, Tuple
from backend.repositories.usuario_repositorio import UsuarioRepositorio
from backend.repositories.rol_repositorio import RolRepositorio


class AuthService:
    """Servicio de autenticación y gestión de sesión de usuario"""
    
    def __init__(self):
        """Inicializa el servicio de autenticación"""
        self.usuario_repo = UsuarioRepositorio()
        self.rol_repo = RolRepositorio()
        self.sesion_actual: Optional[Dict] = None
    
    def login(self, usuario: str, password: str) -> Tuple[bool, Optional[Dict], str]:
        """
        Inicia sesión de usuario
        
        Args:
            usuario: Nombre de usuario
            password: Contraseña en texto plano
            
        Returns:
            tuple: (éxito: bool, datos_usuario: dict o None, mensaje: str)
        """
        try:
            # Validar campos vacíos
            if not usuario or not password:
                return False, None, "Complete todos los campos"
            
            # Autenticar con el repositorio
            autenticado, datos_usuario = self.usuario_repo.autenticar(usuario, password)
            
            if autenticado and datos_usuario:
                # Obtener permisos del rol del usuario
                permisos = self.rol_repo.obtener_permisos_rol(datos_usuario['id_rol'])
                
                # Crear sesión con datos del usuario y sus permisos
                self.sesion_actual = {
                    **datos_usuario,
                    'permisos': permisos
                }
                
                print(f"✅ Sesión iniciada exitosamente")
                print(f"   👤 Usuario: {usuario}")
                print(f"   🎭 Rol: {datos_usuario.get('nombre_rol')}")
                print(f"   🔑 Permisos: {len(permisos)} módulos")
                
                return True, self.sesion_actual, "Login exitoso"
            else:
                return False, None, "Usuario o contraseña incorrectos"
                
        except Exception as e:
            error_msg = f"Error en autenticación: {str(e)}"
            print(f"❌ {error_msg}")
            return False, None, error_msg
    
    def logout(self):
        """Cierra la sesión actual"""
        if self.sesion_actual:
            usuario = self.sesion_actual.get('usuario', 'desconocido')
            print(f"✅ Sesión cerrada: {usuario}")
            self.sesion_actual = None
        else:
            print("⚠️  No hay sesión activa para cerrar")
    
    def esta_autenticado(self) -> bool:
        """
        Verifica si hay una sesión activa
        
        Returns:
            bool: True si hay sesión activa
        """
        return self.sesion_actual is not None
    
    def obtener_usuario_actual(self) -> Optional[Dict]:
        """
        Obtiene los datos del usuario de la sesión actual
        
        Returns:
            dict: Datos del usuario o None si no hay sesión
        """
        return self.sesion_actual
    
    def tiene_permiso(self, modulo: str, accion: str) -> bool:
        """
        Verifica si el usuario actual tiene permiso para una acción en un módulo
        
        Args:
            modulo: Nombre del módulo (ej: 'productores', 'parcelas')
            accion: Acción a verificar ('leer', 'crear', 'editar', 'eliminar')
            
        Returns:
            bool: True si tiene permiso
        """
        if not self.sesion_actual:
            print("⚠️  No hay sesión activa - permiso denegado")
            return False
        
        # Los administradores tienen todos los permisos
        if self.es_admin():
            return True
        
        # Buscar el permiso en los permisos del usuario
        permisos = self.sesion_actual.get('permisos', [])
        
        for permiso in permisos:
            if permiso['modulo'] == modulo:
                # Mapear la acción a la clave del permiso
                acciones_map = {
                    'leer': 'puede_leer',
                    'crear': 'puede_crear',
                    'editar': 'puede_editar',
                    'eliminar': 'puede_eliminar'
                }
                
                clave_permiso = acciones_map.get(accion.lower())
                if clave_permiso:
                    return permiso.get(clave_permiso, False)
        
        return False
    
    def es_admin(self) -> bool:
        """
        Verifica si el usuario actual es administrador
        
        Returns:
            bool: True si es administrador (nivel_acceso >= 90)
        """
        if not self.sesion_actual:
            return False
        
        nivel_acceso = self.sesion_actual.get('nivel_acceso', 0)
        return nivel_acceso >= 90
    
    def obtener_nombre_completo(self) -> str:
        """
        Obtiene el nombre completo del usuario actual
        
        Returns:
            str: Nombre completo o cadena vacía
        """
        if not self.sesion_actual:
            return ""
        
        nombre = self.sesion_actual.get('nombre', '')
        apellido = self.sesion_actual.get('apellido', '')
        
        return f"{nombre} {apellido}".strip()
    
    def obtener_id_usuario(self) -> Optional[int]:
        """
        Obtiene el ID del usuario actual
        
        Returns:
            int: ID del usuario o None
        """
        if not self.sesion_actual:
            return None
        
        return self.sesion_actual.get('id_usuario')
    
    def obtener_nombre_rol(self) -> str:
        """
        Obtiene el nombre del rol del usuario actual
        
        Returns:
            str: Nombre del rol o cadena vacía
        """
        if not self.sesion_actual:
            return ""
        
        return self.sesion_actual.get('nombre_rol', '')
    
    def validar_sesion(self) -> bool:
        """
        Valida que la sesión actual sea válida
        (puede expandirse para verificar timeout, etc.)
        
        Returns:
            bool: True si la sesión es válida
        """
        if not self.esta_autenticado():
            return False
        
        # Verificar que el usuario sigue activo
        try:
            id_usuario = self.obtener_id_usuario()
            if id_usuario:
                usuario = self.usuario_repo.obtener_por_id(id_usuario)
                if not usuario.get('activo'):
                    print("⚠️  Usuario desactivado - cerrando sesión")
                    self.logout()
                    return False
                
                return True
        except Exception as e:
            print(f"❌ Error validando sesión: {e}")
            self.logout()
            return False
        
        return True


# Instancia global del servicio de autenticación
# Puede ser importada y usada en toda la aplicación
auth_service = AuthService()