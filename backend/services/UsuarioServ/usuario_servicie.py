# backend/services/UsuariosServ/usuario_servicio.py
"""
Servicio para gestión de usuarios, roles y permisos
Capa de lógica de negocio entre el modelo y los repositorios
"""

from typing import List, Dict, Optional, Tuple
from backend.repositories.UsuariosRep.usuario_repositorio import UsuarioRepositorio
from backend.repositories.UsuariosRep.rol_repositorio import RolRepositorio


class UsuarioServicio:
    """Servicio de gestión de usuarios, roles y permisos"""
    
    def __init__(self):
        """Inicializa el servicio con sus repositorios"""
        self.usuario_repo = UsuarioRepositorio()
        self.rol_repo = RolRepositorio()
    
    # ==================== GESTIÓN DE USUARIOS ====================
    
    def obtener_usuarios(self) -> List[Dict]:
        """
        Obtiene todos los usuarios con información de sus roles
        
        Returns:
            list: Lista de usuarios con formato para el modelo
        """
        try:
            usuarios = self.usuario_repo.obtener_todos()
            
            # Formatear para el modelo QML
            usuarios_formateados = []
            for usuario in usuarios:
                usuario_formateado = {
                    'id_usuario': usuario.get('id_usuario'),
                    'usuario': usuario.get('usuario', ''),
                    'nombre': usuario.get('nombre', ''),
                    'apellido': usuario.get('apellido', ''),
                    'email': usuario.get('email', ''),
                    'telefono': usuario.get('telefono', ''),
                    'rol': usuario.get('nombre_rol', ''),
                    'id_rol': usuario.get('id_rol'),
                    'nivel_acceso': usuario.get('nivel_acceso', 0),
                    'activo': usuario.get('activo', False),
                    'fecha_creacion': usuario.get('fecha_creacion', ''),
                    'ultimo_acceso': usuario.get('ultimo_acceso', '')
                }
                usuarios_formateados.append(usuario_formateado)
            
            print(f"✅ Servicio: {len(usuarios_formateados)} usuarios obtenidos")
            return usuarios_formateados
            
        except Exception as e:
            print(f"❌ Error en servicio al obtener usuarios: {e}")
            return []
    
    def agregar_usuario(self, datos_usuario: Dict) -> Tuple[bool, Optional[int]]:
        """
        Agrega un nuevo usuario al sistema
        
        Args:
            datos_usuario: Diccionario con los datos del usuario
                - usuario (str): Nombre de usuario
                - password (str): Contraseña
                - nombre (str): Nombre
                - apellido (str): Apellido
                - email (str): Correo electrónico
                - telefono (str, opcional): Teléfono
                - id_rol (int): ID del rol
                
        Returns:
            tuple: (éxito: bool, id_usuario: int o None)
        """
        try:
            # Validar campos requeridos
            campos_requeridos = ['usuario', 'contrasena', 'nombre', 'apellido', 'email', 'id_rol']
            for campo in campos_requeridos:
                if campo not in datos_usuario or not datos_usuario[campo]:
                    print(f"❌ Campo requerido faltante: {campo}")
                    return False, None
            
            # Validar formato de email
            if '@' not in datos_usuario['email']:
                print("❌ Formato de email inválido")
                return False, None
            
            # Validar que el rol existe
            try:
                self.rol_repo.obtener_por_id(datos_usuario['id_rol'])
            except:
                print(f"❌ Rol con ID {datos_usuario['id_rol']} no existe")
                return False, None
            
            # Crear usuario a través del repositorio
            exito, id_usuario = self.usuario_repo.crear(datos_usuario)
            
            if exito:
                print(f"✅ Servicio: Usuario creado con ID {id_usuario}")
                return True, id_usuario
            else:
                print("❌ Servicio: Error al crear usuario")
                return False, None
                
        except Exception as e:
            print(f"❌ Error en servicio al agregar usuario: {e}")
            return False, None
    
    def actualizar_usuario(self, id_usuario: int, datos_usuario: Dict) -> bool:
        """
        Actualiza un usuario existente
        
        Args:
            id_usuario: ID del usuario a actualizar
            datos_usuario: Datos a actualizar
            
        Returns:
            bool: True si se actualizó correctamente
        """
        try:
            # Validar que el usuario existe
            try:
                self.usuario_repo.obtener_por_id(id_usuario)
            except:
                print(f"❌ Usuario con ID {id_usuario} no existe")
                return False
            
            # Si se actualiza el rol, validar que existe
            if 'id_rol' in datos_usuario:
                try:
                    self.rol_repo.obtener_por_id(datos_usuario['id_rol'])
                except:
                    print(f"❌ Rol con ID {datos_usuario['id_rol']} no existe")
                    return False
            
            # Validar email si se proporciona
            if 'email' in datos_usuario and datos_usuario['email']:
                if '@' not in datos_usuario['email']:
                    print("❌ Formato de email inválido")
                    return False
            
            # Actualizar usuario
            exito = self.usuario_repo.actualizar(id_usuario, datos_usuario)
            
            if exito:
                print(f"✅ Servicio: Usuario {id_usuario} actualizado")
                return True
            else:
                print(f"❌ Servicio: Error al actualizar usuario {id_usuario}")
                return False
                
        except Exception as e:
            print(f"❌ Error en servicio al actualizar usuario: {e}")
            return False
    
    def eliminar_usuario(self, id_usuario: int) -> bool:
        """
        Elimina físicamente un usuario del sistema
        
        Args:
            id_usuario: ID del usuario a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
        try:
            # Validar que el usuario existe
            try:
                usuario = self.usuario_repo.obtener_por_id(id_usuario)
            except:
                print(f"❌ Usuario con ID {id_usuario} no existe")
                return False
            
            # Eliminar usuario
            exito = self.usuario_repo.eliminar(id_usuario)
            
            if exito:
                print(f"✅ Servicio: Usuario {id_usuario} eliminado")
                return True
            else:
                print(f"❌ Servicio: Error al eliminar usuario {id_usuario}")
                return False
                
        except Exception as e:
            print(f"❌ Error en servicio al eliminar usuario: {e}")
            return False
    
    def desactivar_usuario(self, id_usuario: int) -> bool:
        """
        Desactiva un usuario (soft delete)
        
        Args:
            id_usuario: ID del usuario a desactivar
            
        Returns:
            bool: True si se desactivó correctamente
        """
        try:
            # Validar que el usuario existe
            try:
                usuario = self.usuario_repo.obtener_por_id(id_usuario)
            except:
                print(f"❌ Usuario con ID {id_usuario} no existe")
                return False
            
            # Prevenir desactivación de usuario admin principal
            if usuario.get('nivel_acceso', 0) >= 100:
                print("❌ No se puede desactivar el usuario administrador principal")
                return False
            
            # Desactivar usuario
            exito = self.usuario_repo.desactivar(id_usuario)
            
            if exito:
                print(f"✅ Servicio: Usuario {id_usuario} desactivado")
                return True
            else:
                print(f"❌ Servicio: Error al desactivar usuario {id_usuario}")
                return False
                
        except Exception as e:
            print(f"❌ Error en servicio al desactivar usuario: {e}")
            return False
    
    # ==================== GESTIÓN DE ROLES ====================
    
    def obtener_roles(self) -> List[Dict]:
        """
        Obtiene todos los roles del sistema
        
        Returns:
            list: Lista de roles con formato para el modelo
        """
        try:
            roles = self.rol_repo.obtener_todos()
            
            # Formatear para el modelo QML
            roles_formateados = []
            for rol in roles:
                rol_formateado = {
                    'id_rol': rol.get('id_rol'),
                    'nombre_rol': rol.get('nombre_rol', ''),
                    'descripcion': rol.get('descripcion', ''),
                    'nivel_acceso': rol.get('nivel_acceso', 0),
                    'activo': rol.get('activo', False)
                }
                roles_formateados.append(rol_formateado)
            
            print(f"✅ Servicio: {len(roles_formateados)} roles obtenidos")
            return roles_formateados
            
        except Exception as e:
            print(f"❌ Error en servicio al obtener roles: {e}")
            return []
    
    def agregar_rol(self, datos_rol: Dict) -> Tuple[bool, Optional[int]]:
        """
        Agrega un nuevo rol al sistema
        
        Args:
            datos_rol: Diccionario con los datos del rol
                - nombre_rol (str): Nombre del rol
                - descripcion (str, opcional): Descripción
                - nivel_acceso (int): Nivel de acceso (0-100)
                
        Returns:
            tuple: (éxito: bool, id_rol: int o None)
        """
        try:
            # Validar campos requeridos
            if 'nombre_rol' not in datos_rol or not datos_rol['nombre_rol']:
                print("❌ El nombre del rol es requerido")
                return False, None
            
            if 'nivel_acceso' not in datos_rol:
                print("❌ El nivel de acceso es requerido")
                return False, None
            
            # Validar nivel de acceso
            nivel = datos_rol['nivel_acceso']
            if not isinstance(nivel, int) or nivel < 0 or nivel > 100:
                print("❌ El nivel de acceso debe ser un número entre 0 y 100")
                return False, None
            
            # Crear rol usando AutoRepositorio
            from backend.repositories.UsuariosRep.auto_repositorio import AutoRepositorio
            roles_auto_repo = AutoRepositorio(
                nombre_tabla='Roles',
                nombre_id='id_rol',
                campos_requeridos=['nombre_rol', 'nivel_acceso'],
                campos_unicos=['nombre_rol']
            )
            
            # Asegurar que el rol esté activo
            if 'activo' not in datos_rol:
                datos_rol['activo'] = 1
            
            exito, id_rol = roles_auto_repo.crear(datos_rol)
            
            if exito:
                print(f"✅ Servicio: Rol creado con ID {id_rol}")
                return True, id_rol
            else:
                print("❌ Servicio: Error al crear rol")
                return False, None
                
        except Exception as e:
            print(f"❌ Error en servicio al agregar rol: {e}")
            return False, None
    
    # ==================== GESTIÓN DE PERMISOS ====================
    
    def obtener_permisos_por_rol(self, id_rol: int) -> List[Dict]:
        """
        Obtiene los permisos de un rol específico
        
        Args:
            id_rol: ID del rol
            
        Returns:
            list: Lista de permisos con formato para el modelo
        """
        try:
            permisos = self.rol_repo.obtener_permisos_rol(id_rol)
            
            # Formatear para el modelo QML
            permisos_formateados = []
            for permiso in permisos:
                permiso_formateado = {
                    'id_permiso': permiso.get('id_permiso'),
                    'id_rol': permiso.get('id_rol'),
                    'modulo': permiso.get('modulo', ''),
                    'puede_leer': permiso.get('puede_leer', False),
                    'puede_crear': permiso.get('puede_crear', False),
                    'puede_editar': permiso.get('puede_editar', False),
                    'puede_eliminar': permiso.get('puede_eliminar', False),
                    'permitido': permiso.get('puede_leer', False)  # Para compatibilidad con el modelo
                }
                permisos_formateados.append(permiso_formateado)
            
            print(f"✅ Servicio: {len(permisos_formateados)} permisos obtenidos para rol {id_rol}")
            return permisos_formateados
            
        except Exception as e:
            print(f"❌ Error en servicio al obtener permisos: {e}")
            return []
    
    def guardar_permisos(self, id_rol: int, permisos_actualizados: List[Dict]) -> bool:
        """
        Guarda los permisos actualizados para un rol
        
        Args:
            id_rol: ID del rol
            permisos_actualizados: Lista de permisos con sus valores actualizados
            
        Returns:
            bool: True si se guardaron correctamente
        """
        try:
            # Validar que el rol existe
            try:
                self.rol_repo.obtener_por_id(id_rol)
            except:
                print(f"❌ Rol con ID {id_rol} no existe")
                return False
            
            # Usar AutoRepositorio para actualizar permisos
            from backend.repositories.UsuariosRep.auto_repositorio import AutoRepositorio
            permisos_repo = AutoRepositorio(
                nombre_tabla='Permisos',
                nombre_id='id_permiso'
            )
            
            # Actualizar cada permiso
            for permiso in permisos_actualizados:
                if 'id_permiso' not in permiso:
                    continue
                
                # Preparar datos de actualización
                datos_actualizacion = {}
                if 'puede_leer' in permiso:
                    datos_actualizacion['puede_leer'] = 1 if permiso['puede_leer'] else 0
                if 'puede_crear' in permiso:
                    datos_actualizacion['puede_crear'] = 1 if permiso['puede_crear'] else 0
                if 'puede_editar' in permiso:
                    datos_actualizacion['puede_editar'] = 1 if permiso['puede_editar'] else 0
                if 'puede_eliminar' in permiso:
                    datos_actualizacion['puede_eliminar'] = 1 if permiso['puede_eliminar'] else 0
                
                # Compatibilidad con campo 'permitido' del modelo
                if 'permitido' in permiso and len(datos_actualizacion) == 0:
                    valor = 1 if permiso['permitido'] else 0
                    datos_actualizacion['puede_leer'] = valor
                    datos_actualizacion['puede_crear'] = valor
                    datos_actualizacion['puede_editar'] = valor
                    datos_actualizacion['puede_eliminar'] = valor
                
                # Actualizar permiso
                if datos_actualizacion:
                    permisos_repo.actualizar(permiso['id_permiso'], datos_actualizacion)
            
            print(f"✅ Servicio: Permisos actualizados para rol {id_rol}")
            return True
            
        except Exception as e:
            print(f"❌ Error en servicio al guardar permisos: {e}")
            return False
    
    # ==================== MÉTODOS DE UTILIDAD ====================
    
    def obtener_modulos_disponibles(self) -> List[str]:
        """
        Obtiene la lista de módulos del sistema con permisos
        
        Returns:
            list: Lista de nombres de módulos
        """
        try:
            return self.rol_repo.obtener_modulos_disponibles()
        except Exception as e:
            print(f"❌ Error al obtener módulos: {e}")
            return []
    
    def verificar_permiso(self, id_rol: int, modulo: str, accion: str) -> bool:
        """
        Verifica si un rol tiene permiso para una acción en un módulo
        
        Args:
            id_rol: ID del rol
            modulo: Nombre del módulo
            accion: Acción a verificar ('leer', 'crear', 'editar', 'eliminar')
            
        Returns:
            bool: True si tiene permiso
        """
        try:
            return self.rol_repo.verificar_permiso(id_rol, modulo, accion)
        except Exception as e:
            print(f"❌ Error al verificar permiso: {e}")
            return False