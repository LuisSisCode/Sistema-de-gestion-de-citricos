# backend/repositories/usuario_repositorio.py
"""
Repositorio para gestión de usuarios del sistema
"""

from backend.core.repositorio_base import RepositorioBase
from backend.core.excepciones_bd import (
    RegistroNoEncontrado,
    RegistroYaExiste,
    ErrorValidacion
)
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl
from backend.utils.password_utils import PasswordUtils
from utils.validators import validar_email, validar_username, validar_password
from typing import List, Dict, Tuple, Optional


class UsuarioRepositorio(RepositorioBase):
    """Repositorio para gestión de usuarios del sistema"""
    
    @cacheable('usuarios', ttl=3600)  # 1 hora
    def obtener_todos(self) -> List[Dict]:
        """
        Obtiene todos los usuarios activos del sistema
        
        Returns:
            list: Lista de usuarios con sus datos
        """
        query = """
        SELECT 
            u.id_usuario,
            u.usuario,
            u.id_rol,
            u.nombre,
            u.apellido,
            u.email,
            u.telefono,
            u.activo,
            u.ultimo_acceso,
            u.fecha_creacion,
            r.nombre_rol
        FROM Usuarios u
        LEFT JOIN Roles r ON u.id_rol = r.id_rol
        WHERE u.activo = 1
        ORDER BY u.nombre, u.apellido
        """
        
        rows = self._ejecutar_consulta(query)
        usuarios = []
        
        for row in rows:
            usuario = {
                'id_usuario': row.id_usuario,
                'usuario': row.usuario,
                'id_rol': row.id_rol,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'email': row.email if hasattr(row, 'email') else None,
                'telefono': row.telefono if hasattr(row, 'telefono') else None,
                'activo': bool(row.activo),
                'ultimo_acceso': self._formatear_fecha(row.ultimo_acceso) if hasattr(row, 'ultimo_acceso') else None,
                'fecha_creacion': self._formatear_fecha(row.fecha_creacion) if hasattr(row, 'fecha_creacion') else None,
                'nombre_rol': row.nombre_rol if hasattr(row, 'nombre_rol') else 'Sin rol'
            }
            usuarios.append(usuario)
        
        print(f"✅ Obtenidos {len(usuarios)} usuarios del sistema")
        return usuarios
    
    @cacheable('usuarios', ttl=3600)
    def obtener_por_id(self, id_usuario: int) -> Dict:
        """
        Obtiene un usuario por su ID
        
        Args:
            id_usuario: ID del usuario
            
        Returns:
            dict: Datos del usuario
            
        Raises:
            RegistroNoEncontrado: Si el usuario no existe
        """
        query = """
        SELECT 
            u.id_usuario,
            u.usuario,
            u.id_rol,
            u.nombre,
            u.apellido,
            u.email,
            u.telefono,
            u.activo,
            u.ultimo_acceso,
            u.fecha_creacion,
            r.nombre_rol,
            r.nivel_acceso
        FROM Usuarios u
        LEFT JOIN Roles r ON u.id_rol = r.id_rol
        WHERE u.id_usuario = ?
        """
        
        rows = self._ejecutar_consulta(query, (id_usuario,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Usuario con ID {id_usuario} no encontrado")
        
        row = rows[0]
        usuario = {
            'id_usuario': row.id_usuario,
            'usuario': row.usuario,
            'id_rol': row.id_rol,
            'nombre': row.nombre,
            'apellido': row.apellido,
            'email': row.email if hasattr(row, 'email') else None,
            'telefono': row.telefono if hasattr(row, 'telefono') else None,
            'activo': bool(row.activo),
            'ultimo_acceso': self._formatear_fecha(row.ultimo_acceso) if hasattr(row, 'ultimo_acceso') else None,
            'fecha_creacion': self._formatear_fecha(row.fecha_creacion) if hasattr(row, 'fecha_creacion') else None,
            'nombre_rol': row.nombre_rol if hasattr(row, 'nombre_rol') else 'Sin rol',
            'nivel_acceso': row.nivel_acceso if hasattr(row, 'nivel_acceso') else 0
        }
        
        return usuario
    
    def autenticar(self, usuario: str, password: str) -> Tuple[bool, Optional[Dict]]:
        """
        Autentica un usuario con sus credenciales
        
        Args:
            usuario: Nombre de usuario
            password: Contraseña en texto plano
            
        Returns:
            tuple: (autenticado: bool, datos_usuario: dict o None)
        """
        print(f"🔐 Intentando autenticar: {usuario}")
        
        query = """
        SELECT 
            u.id_usuario,
            u.usuario,
            u.contrasena,
            u.salt,
            u.id_rol,
            u.nombre,
            u.apellido,
            u.email,
            u.activo,
            r.nombre_rol,
            r.nivel_acceso
        FROM Usuarios u
        LEFT JOIN Roles r ON u.id_rol = r.id_rol
        WHERE u.usuario = ? AND u.activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (usuario,))
        
        if not rows:
            print(f"❌ Usuario '{usuario}' no encontrado o inactivo")
            return False, None
        
        row = rows[0]
        
        # Verificar contraseña
        if hasattr(row, 'salt') and row.salt:
            # Método nuevo con salt
            password_valida = PasswordUtils.verify_password(
                password,
                row.contrasena,
                row.salt
            )
        else:
            # Método antiguo (hash simple SHA256)
            password_valida = PasswordUtils.verify_password_simple(
                password,
                row.contrasena
            )
        
        if not password_valida:
            print(f"❌ Contraseña incorrecta para '{usuario}'")
            return False, None
        
        # Actualizar último acceso
        self._actualizar_ultimo_acceso(row.id_usuario)
        
        # Preparar datos de usuario
        usuario_data = {
            'id_usuario': row.id_usuario,
            'usuario': row.usuario,
            'id_rol': row.id_rol,
            'nombre': row.nombre,
            'apellido': row.apellido,
            'email': row.email if hasattr(row, 'email') else None,
            'nombre_rol': row.nombre_rol if hasattr(row, 'nombre_rol') else 'Sin rol',
            'nivel_acceso': row.nivel_acceso if hasattr(row, 'nivel_acceso') else 0,
            'activo': bool(row.activo)
        }
        
        print(f"✅ Usuario '{usuario}' autenticado exitosamente")
        print(f"   👤 Nombre: {usuario_data['nombre']} {usuario_data['apellido']}")
        print(f"   🎭 Rol: {usuario_data['nombre_rol']} (Nivel {usuario_data['nivel_acceso']})")
        
        return True, usuario_data
    
    @cache_invalidator('usuarios')
    def crear(self, datos: Dict) -> Tuple[bool, Optional[int]]:
        """
        Crea un nuevo usuario en el sistema
        
        Args:
            datos: Diccionario con los datos del usuario
                - usuario: str (requerido)
                - contrasena: str (requerido)
                - nombre: str (requerido)
                - apellido: str (requerido)
                - id_rol: int (requerido)
                - email: str (opcional)
                - telefono: str (opcional)
                
        Returns:
            tuple: (éxito: bool, id_usuario: int o None)
            
        Raises:
            ErrorValidacion: Si los datos no son válidos
            RegistroYaExiste: Si el usuario ya existe
        """
        # Validar datos
        valido, errores = self._validar_datos_usuario(datos, es_nuevo=True)
        if not valido:
            raise ErrorValidacion(f"Datos inválidos: {', '.join(errores)}")
        
        # Verificar si usuario ya existe
        if self._existe_usuario(datos['usuario']):
            raise RegistroYaExiste(f"Usuario '{datos['usuario']}' ya existe")
        
        # Hash de contraseña con salt
        password_hash, salt = PasswordUtils.hash_password(datos['contrasena'])
        
        query = """
        INSERT INTO Usuarios (
            usuario, contrasena, salt, id_rol,
            nombre, apellido, email, telefono,
            activo, fecha_creacion
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, GETDATE())
        """
        
        params = (
            datos['usuario'],
            password_hash,
            salt,
            datos['id_rol'],
            datos['nombre'],
            datos['apellido'],
            datos.get('email'),
            datos.get('telefono')
        )
        
        self._ejecutar_consulta(query, params, obtener_resultado=False)
        id_usuario = self._obtener_ultimo_id()
        
        print(f"✅ Usuario '{datos['usuario']}' creado con ID: {id_usuario}")
        return True, id_usuario
    
    @cache_invalidator('usuarios')
    def actualizar(self, id_usuario: int, datos: Dict) -> bool:
        """
        Actualiza un usuario existente
        
        Args:
            id_usuario: ID del usuario a actualizar
            datos: Datos a actualizar
            
        Returns:
            bool: True si se actualizó exitosamente
        """
        # Verificar que usuario existe
        usuario_actual = self.obtener_por_id(id_usuario)
        
        # Construir query dinámicamente según campos a actualizar
        campos = []
        params = []
        
        if 'nombre' in datos:
            campos.append("nombre = ?")
            params.append(datos['nombre'])
        
        if 'apellido' in datos:
            campos.append("apellido = ?")
            params.append(datos['apellido'])
        
        if 'email' in datos:
            # Validar email si se proporciona
            if datos['email']:
                valido, msg = validar_email(datos['email'])
                if not valido:
                    raise ErrorValidacion(f"Email inválido: {msg}")
            campos.append("email = ?")
            params.append(datos['email'])
        
        if 'telefono' in datos:
            campos.append("telefono = ?")
            params.append(datos['telefono'])
        
        if 'id_rol' in datos:
            campos.append("id_rol = ?")
            params.append(datos['id_rol'])
        
        if not campos:
            print("⚠️  No hay campos para actualizar")
            return False
        
        params.append(id_usuario)
        
        query = f"""
        UPDATE Usuarios
        SET {', '.join(campos)}
        WHERE id_usuario = ?
        """
        
        filas = self._ejecutar_consulta(query, tuple(params), obtener_resultado=False)
        
        if filas > 0:
            print(f"✅ Usuario ID {id_usuario} actualizado")
            return True
        else:
            print(f"⚠️  Usuario ID {id_usuario} no se actualizó")
            return False
    
    @cache_invalidator('usuarios')
    def cambiar_contrasena(
        self,
        id_usuario: int,
        nueva_contrasena: str
    ) -> bool:
        """
        Cambia la contraseña de un usuario
        
        Args:
            id_usuario: ID del usuario
            nueva_contrasena: Nueva contraseña en texto plano
            
        Returns:
            bool: True si se cambió exitosamente
        """
        # Validar nueva contraseña
        valido, msg = validar_password(nueva_contrasena)
        if not valido:
            raise ErrorValidacion(f"Contraseña inválida: {msg}")
        
        # Generar nuevo hash con salt
        password_hash, salt = PasswordUtils.hash_password(nueva_contrasena)
        
        query = """
        UPDATE Usuarios
        SET contrasena = ?, salt = ?
        WHERE id_usuario = ?
        """
        
        filas = self._ejecutar_consulta(
            query,
            (password_hash, salt, id_usuario),
            obtener_resultado=False
        )
        
        if filas > 0:
            print(f"✅ Contraseña actualizada para usuario ID {id_usuario}")
            return True
        else:
            print(f"❌ Error actualizando contraseña para usuario ID {id_usuario}")
            return False
    
    @cache_invalidator('usuarios')
    def desactivar(self, id_usuario: int) -> bool:
        """
        Desactiva un usuario (soft delete)
        
        Args:
            id_usuario: ID del usuario
            
        Returns:
            bool: True si se desactivó
        """
        query = "UPDATE Usuarios SET activo = 0 WHERE id_usuario = ?"
        filas = self._ejecutar_consulta(query, (id_usuario,), obtener_resultado=False)
        
        if filas > 0:
            print(f"✅ Usuario ID {id_usuario} desactivado")
            return True
        else:
            print(f"⚠️  Usuario ID {id_usuario} no se pudo desactivar")
            return False
    
    def _actualizar_ultimo_acceso(self, id_usuario: int):
        """Actualiza la fecha de último acceso del usuario"""
        query = "UPDATE Usuarios SET ultimo_acceso = GETDATE() WHERE id_usuario = ?"
        self._ejecutar_consulta(query, (id_usuario,), obtener_resultado=False)
    
    def _existe_usuario(self, usuario: str) -> bool:
        """
        Verifica si un nombre de usuario ya existe
        
        Args:
            usuario: Nombre de usuario a verificar
            
        Returns:
            bool: True si existe
        """
        count = self._contar_registros("Usuarios", "usuario = ?", (usuario,))
        return count > 0
    
    def _validar_datos_usuario(self, datos: Dict, es_nuevo: bool = False) -> Tuple[bool, List[str]]:
        """
        Valida los datos de un usuario
        
        Args:
            datos: Datos a validar
            es_nuevo: True si es un usuario nuevo (requiere contraseña)
            
        Returns:
            tuple: (válido: bool, lista_errores: list)
        """
        errores = []
        
        # Usuario requerido
        if 'usuario' in datos:
            valido, msg = validar_username(datos['usuario'])
            if not valido:
                errores.append(msg)
        elif es_nuevo:
            errores.append("Usuario requerido")
        
        # Contraseña requerida solo al crear
        if es_nuevo:
            if 'contrasena' in datos:
                valido, msg = validar_password(datos['contrasena'])
                if not valido:
                    errores.append(msg)
            else:
                errores.append("Contraseña requerida")
        
        # Email opcional pero debe ser válido si se proporciona
        if datos.get('email'):
            valido, msg = validar_email(datos['email'])
            if not valido:
                errores.append(msg)
        
        # Nombre requerido
        if not datos.get('nombre'):
            errores.append("Nombre requerido")
        
        # Apellido requerido
        if not datos.get('apellido'):
            errores.append("Apellido requerido")
        
        # Rol requerido
        if not datos.get('id_rol'):
            errores.append("Rol requerido")
        
        return len(errores) == 0, errores