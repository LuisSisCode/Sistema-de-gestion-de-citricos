from PySide6.QtCore import QObject, Slot, Signal, Property
from bd_conecciones.bd_usuario_roles import GestorUsuariosRoles
import json

class UsuariosRolesModel(QObject):
    usuariosChanged = Signal()
    rolesChanged = Signal()
    permisosChanged = Signal()
    usuariosFiltradosChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._gestor = GestorUsuariosRoles()
        self._usuarios = []
        self._usuarios_filtrados = []
        self._roles = []
        self._permisos = []
        self._rol_seleccionado = -1
        
        # Cargar datos iniciales
        self.cargar_usuarios()
        self.cargar_roles()
    
    @Property(list, notify=usuariosChanged)
    def usuarios(self):
        return self._usuarios
    
    @Property(list, notify=usuariosFiltradosChanged)
    def usuarios_filtrados(self):
        return self._usuarios_filtrados
    
    @Property(list, notify=rolesChanged)
    def roles(self):
        return self._roles
    
    @Property(list, notify=permisosChanged)
    def permisos(self):
        return self._permisos
    
    @Slot()
    def cargar_usuarios(self):
        """Carga la lista de usuarios desde la base de datos"""
        try:
            self._usuarios = self._gestor.obtener_usuarios()
            self._usuarios_filtrados = self._usuarios
            self.usuariosChanged.emit()
            self.usuariosFiltradosChanged.emit()
        except Exception as e:
            print(f"Error al cargar usuarios: {str(e)}")
    
    @Slot()
    def cargar_roles(self):
        """Carga la lista de roles desde la base de datos"""
        try:
            self._roles = self._gestor.obtener_roles()
            self.rolesChanged.emit()
        except Exception as e:
            print(f"Error al cargar roles: {str(e)}")
    
    @Slot(int)
    def cargar_permisos_por_rol(self, id_rol):
        """Carga los permisos para un rol específico"""
        try:
            self._rol_seleccionado = id_rol
            self._permisos = self._gestor.obtener_permisos_por_rol(id_rol)
            self.permisosChanged.emit()
        except Exception as e:
            print(f"Error al cargar permisos: {str(e)}")
    
    @Slot(str, result=bool)
    def agregar_usuario(self, usuario_data_json):
        """Agrega un nuevo usuario a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            usuario_data = json.loads(usuario_data_json)
            success, _ = self._gestor.agregar_usuario(usuario_data)
            if success:
                self.cargar_usuarios()
            return success
        except Exception as e:
            print(f"Error al agregar usuario: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_usuario(self, id_usuario, usuario_data_json):
        """Actualiza un usuario existente"""
        try:
            # Convertir el string JSON a diccionario
            usuario_data = json.loads(usuario_data_json)
            success = self._gestor.actualizar_usuario(id_usuario, usuario_data)
            if success:
                self.cargar_usuarios()
            return success
        except Exception as e:
            print(f"Error al actualizar usuario: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_usuario(self, id_usuario):
        """Elimina un usuario existente"""
        try:
            success = self._gestor.eliminar_usuario(id_usuario)
            if success:
                self.cargar_usuarios()
            return success
        except Exception as e:
            print(f"Error al eliminar usuario: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def desactivar_usuario(self, id_usuario):
        """Desactiva un usuario en lugar de eliminarlo físicamente"""
        try:
            success = self._gestor.desactivar_usuario(id_usuario)
            if success:
                self.cargar_usuarios()
            return success
        except Exception as e:
            print(f"Error al desactivar usuario: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def agregar_rol(self, rol_data_json):
        """Agrega un nuevo rol a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            rol_data = json.loads(rol_data_json)
            success, _ = self._gestor.agregar_rol(rol_data)
            if success:
                self.cargar_roles()
            return success
        except Exception as e:
            print(f"Error al agregar rol: {str(e)}")
            return False
        
    @Slot(int, list, result=bool)
    def guardarPermisos(self, id_rol, permisos_actualizados):
        """Guarda los permisos actualizados para un rol específico"""
        try:
            # Aquí implementarías la lógica para guardar los permisos en la base de datos
            # Por ahora, solo actualizamos nuestro modelo local
            
            # Actualizar permisos en memoria
            for i, permiso_actualizado in enumerate(permisos_actualizados):
                if i < len(self._permisos):
                    self._permisos[i]['permitido'] = permiso_actualizado['permitido']
            
            self.permisosChanged.emit()
            return True
        except Exception as e:
            print(f"Error al guardar permisos: {str(e)}")
            return False
    
    @Slot(str)
    def filtrar_usuarios(self, texto_busqueda):
        """Filtra los usuarios según el texto de búsqueda"""
        if not texto_busqueda:
            self._usuarios_filtrados = self._usuarios
        else:
            texto_busqueda = texto_busqueda.lower()
            self._usuarios_filtrados = [u for u in self._usuarios if 
                                       texto_busqueda in u['nombre'].lower() or 
                                       texto_busqueda in u['apellido'].lower() or 
                                       texto_busqueda in u['usuario'].lower() or 
                                       texto_busqueda in u['correo'].lower() or 
                                       texto_busqueda in u['rol'].lower()]
        self.usuariosFiltradosChanged.emit()