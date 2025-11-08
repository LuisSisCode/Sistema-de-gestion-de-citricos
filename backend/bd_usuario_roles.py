# Base de datos donde se concetas las tablas de: usuarios, roles
import pyodbc
import logging
from .core.database import DatabaseConnection
from datetime import datetime
from .core.cache_system import cacheable, cache_invalidator, get_ttl
# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_usuario_roles')

class GestorUsuariosRoles:
    def __init__(self, server=None, database=None, trusted_connection=True):
        """
        Inicializa la conexión a la base de datos SQL Server.
        
        Args:
            server (str): Nombre del servidor SQL Server.
            database (str): Nombre de la base de datos.
            trusted_connection (bool): Usar autenticación de Windows (True) o SQL Server (False).
        """
        try:
            
            if server and database:
                self.db = DatabaseConnection(server, database, trusted_connection)
            else:
                self.db =DatabaseConnection()
                
            # Probar la conexión al iniciar
            self.test_connection()
            logger.info("Conexión a la base de datos establecida correctamente.")
        except Exception as e:
            logger.error(f"Error al establecer la conexión a la base de datos: {str(e)}")
            raise
    def test_connection(self):
        """Prueba la conexión a la base de datos."""
        try:
            with self.db.get_connection() as conn:
                pass
        except Exception as e:
            logger.error(f"Error al probar la conexión: {str(e)}")
            raise
    @cacheable('usuarios', ttl=get_ttl('usuarios'))
    def obtener_usuarios(self):
        """
        Obtiene todos los usuarios de la base de datos con información de sus roles.
        
        Returns:
            list: Lista de diccionarios con la información de cada usuario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT u.id_usuario, u.nombre, u.apellido, u.usuario, u.email, 
                       u.telefono, u.direccion, r.nombre_rol AS rol, u.fecha_creacion, 
                       u.ultimo_acceso, u.activo
                FROM Usuarios u
                JOIN Roles r ON u.id_rol = r.id_rol
                ORDER BY u.id_usuario
                """
                
                cursor.execute(query)
                usuarios = []
                
                for row in cursor.fetchall():
                    # Formatear fechas como strings si existen
                    fecha_creacion = row.fecha_creacion.strftime('%Y-%m-%d %H:%M:%S') if row.fecha_creacion else None
                    ultimo_acceso = row.ultimo_acceso.strftime('%Y-%m-%d %H:%M:%S') if row.ultimo_acceso else None
                    
                    usuario = {
                        'id_usuario': row.id_usuario,
                        'nombre': row.nombre,
                        'apellido': row.apellido,
                        'nombre_completo': f"{row.nombre} {row.apellido}",
                        'usuario': row.usuario,
                        'email': row.email,
                        'telefono': row.telefono,
                        'direccion': row.direccion,
                        'rol': row.rol,
                        'fecha_creacion': fecha_creacion,
                        'ultimo_acceso': ultimo_acceso,
                        'activo': bool(row.activo)
                    }
                    usuarios.append(usuario)
                
                logger.info(f"Se obtuvieron {len(usuarios)} usuarios de la base de datos.")
                return usuarios
        except Exception as e:
            logger.error(f"Error al obtener usuarios: {str(e)}")
            return []
    @cacheable('roles', ttl=get_ttl('roles'))
    def obtener_roles(self):
        """
        Obtiene todos los roles de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada rol.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_rol, nombre_rol, descripcion, fecha_creacion, activo
                FROM Roles
                ORDER BY id_rol
                """
                
                cursor.execute(query)
                roles = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string
                    fecha_creacion = row.fecha_creacion.strftime('%Y-%m-%d %H:%M:%S') if row.fecha_creacion else None
                    
                    rol = {
                        'id_rol': row.id_rol,
                        'nombre': row.nombre_rol,
                        'descripcion': row.descripcion,
                        'fecha_creacion': fecha_creacion,
                        'activo': bool(row.activo)
                    }
                    roles.append(rol)
                
                logger.info(f"Se obtuvieron {len(roles)} roles de la base de datos.")
                return roles
        except Exception as e:
            logger.error(f"Error al obtener roles: {str(e)}")
            return []
    @cacheable('permisos', key_func=lambda id_rol: f"permisos_{id_rol}", ttl=3600)
    def obtener_permisos_por_rol(self, id_rol):
        """
        Este método simula obtener los permisos por rol.
        En la implementación real, necesitarías una tabla de permisos.
        
        Args:
            id_rol (int): ID del rol para obtener sus permisos.
            
        Returns:
            list: Lista de permisos para el rol.
        """
        # Esta función es un ejemplo. En una implementación real,
        # tendrías una tabla de permisos en tu base de datos.
        permisos_ejemplo = [
            {
                'seccion': 'Usuarios',
                'descripcion': 'Gestión de usuarios del sistema',
                'permitido': True if id_rol == 1 else False  # Administrador
            },
            {
                'seccion': 'Parcelas',
                'descripcion': 'Gestión de parcelas y terrenos',
                'permitido': True if id_rol in [1, 2] else False  # Admin y Empleado
            },
            {
                'seccion': 'Productores',
                'descripcion': 'Gestión de productores',
                'permitido': True if id_rol in [1, 2] else False
            },
            {
                'seccion': 'Cultivos',
                'descripcion': 'Gestión de cultivos y variedades',
                'permitido': True if id_rol in [1, 2, 3] else False
            },
            {
                'seccion': 'Agroquímicos',
                'descripcion': 'Gestión de productos agroquímicos',
                'permitido': True if id_rol in [1, 3] else False
            },
            {
                'seccion': 'Reportes',
                'descripcion': 'Generación de reportes',
                'permitido': True if id_rol == 1 else False
            }
        ]
        
        return permisos_ejemplo

    # Funciones adicionales para manipulación de usuarios y roles
    @cache_invalidator('usuarios')
    @cache_invalidator('estadisticas')
    def agregar_usuario(self, usuario_data):
        """
        Agrega un nuevo usuario a la base de datos.
        
        Args:
            usuario_data (dict): Datos del usuario a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del usuario agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Usuarios (id_rol, nombre, apellido, email, telefono, direccion, 
                                    usuario, contrasena, fecha_creacion, activo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                # Configurar valores para la inserción
                fecha_actual = datetime.now()
                valores = (
                    usuario_data['id_rol'],
                    usuario_data['nombre'],
                    usuario_data['apellido'],
                    usuario_data['email'],
                    usuario_data.get('telefono'),
                    usuario_data.get('direccion'),
                    usuario_data['usuario'],
                    usuario_data['contrasena'],  # Deberías encriptar esta contraseña
                    fecha_actual,
                    1 if usuario_data.get('activo', True) else 0
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del usuario recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_usuario = cursor.fetchone()[0]
                
                logger.info(f"Usuario agregado correctamente con ID: {id_usuario}")
                return True, id_usuario
        except Exception as e:
            logger.error(f"Error al agregar usuario: {str(e)}")
            return False, None
    @cache_invalidator('usuarios')
    @cache_invalidator('estadisticas')
    def actualizar_usuario(self, id_usuario, usuario_data):
        """
        Actualiza un usuario existente en la base de datos.
        
        Args:
            id_usuario (int): ID del usuario a actualizar.
            usuario_data (dict): Datos actualizados del usuario.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'id_rol' in usuario_data:
                    campos_actualizar.append("id_rol = ?")
                    valores.append(usuario_data['id_rol'])
                    
                if 'nombre' in usuario_data:
                    campos_actualizar.append("nombre = ?")
                    valores.append(usuario_data['nombre'])
                    
                if 'apellido' in usuario_data:
                    campos_actualizar.append("apellido = ?")
                    valores.append(usuario_data['apellido'])
                    
                if 'email' in usuario_data:
                    campos_actualizar.append("email = ?")
                    valores.append(usuario_data['email'])
                    
                if 'telefono' in usuario_data:
                    campos_actualizar.append("telefono = ?")
                    valores.append(usuario_data['telefono'])
                    
                if 'direccion' in usuario_data:
                    campos_actualizar.append("direccion = ?")
                    valores.append(usuario_data['direccion'])
                    
                if 'usuario' in usuario_data:
                    campos_actualizar.append("usuario = ?")
                    valores.append(usuario_data['usuario'])
                    
                if 'contrasena' in usuario_data:
                    campos_actualizar.append("contrasena = ?")
                    valores.append(usuario_data['contrasena'])
                    
                if 'activo' in usuario_data:
                    campos_actualizar.append("activo = ?")
                    valores.append(1 if usuario_data['activo'] else 0)
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE Usuarios SET {', '.join(campos_actualizar)} WHERE id_usuario = ?"
                valores.append(id_usuario)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Usuario actualizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar usuario: {str(e)}")
            return False
    @cache_invalidator('usuarios')
    @cache_invalidator('estadisticas')
    def eliminar_usuario(self, id_usuario):
        """
        Elimina un usuario de la base de datos.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM Usuarios WHERE id_usuario = ?"
                cursor.execute(query, (id_usuario,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Usuario eliminado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar usuario: {str(e)}")
            return False
    @cache_invalidator('usuarios')
    @cache_invalidator('estadisticas')    
    def desactivar_usuario(self, id_usuario):
            """Desactiva un usuario en lugar de eliminarlo físicamente."""
            try:
                with self.db.get_connection() as conn:
                    cursor = conn.cursor()
                    
                    query = "UPDATE Usuarios SET activo = 0 WHERE id_usuario = ?"
                    cursor.execute(query, (id_usuario,))
                    conn.commit()
                    
                    filas_afectadas = cursor.rowcount
                    logger.info(f"Usuario desactivado correctamente. Filas afectadas: {filas_afectadas}")
                    return filas_afectadas > 0
            except Exception as e:
                logger.error(f"Error al desactivar usuario: {str(e)}")
                return False
    @cache_invalidator('roles')
    @cache_invalidator('permisos', pattern='permisos_')
    @cache_invalidator('usuarios')  # Los roles afectan a los usuarios
    def agregar_rol(self, rol_data):
        """
        Agrega un nuevo rol a la base de datos.
        
        Args:
            rol_data (dict): Datos del rol a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del rol agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Roles (nombre_rol, descripcion, fecha_creacion, activo)
                VALUES (?, ?, ?, ?)
                """
                
                # Configurar valores para la inserción
                fecha_actual = datetime.now()
                valores = (
                    rol_data['nombre'],
                    rol_data.get('descripcion'),
                    fecha_actual,
                    1 if rol_data.get('activo', True) else 0
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del rol recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_rol = cursor.fetchone()[0]
                
                logger.info(f"Rol agregado correctamente con ID: {id_rol}")
                return True, id_rol
        except Exception as e:
            logger.error(f"Error al agregar rol: {str(e)}")
            return False, None
z = GestorUsuariosRoles()
z.obtener_roles()
