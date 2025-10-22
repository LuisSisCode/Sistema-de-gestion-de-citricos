# backend/core/db_installer.py
"""
Instalador automático de base de datos para AgroIchilo
"""

import os
import sys
import pyodbc
import hashlib
from pathlib import Path
from typing import Tuple, Optional


class DatabaseInstaller:
    """Instalador automático para crear y configurar la base de datos"""
    
    def __init__(self):
        """Inicializa el instalador de base de datos"""
        # Detectar rutas de scripts SQL
        if getattr(sys, 'frozen', False):
            # Ejecutable (PyInstaller)
            self.scripts_dir = Path(sys._MEIPASS) / 'database_scripts'
        else:
            # Desarrollo
            self.scripts_dir = Path(__file__).resolve().parent.parent.parent / 'database' / 'scripts'
        
        print(f"📁 Directorio de scripts SQL: {self.scripts_dir}")
        
        # Archivos de scripts
        self.schema_script = self.scripts_dir / '01_schema_creation.sql'
        self.datos_script = self.scripts_dir / '02_datos_iniciales.sql'
    
    def verificar_sql_server(self, server: str) -> Tuple[bool, str]:
        """
        Verifica si SQL Server está disponible y accesible.
        
        Args:
            server: Nombre del servidor SQL Server
            
        Returns:
            tuple: (disponible: bool, mensaje: str)
        """
        print(f"\n🔍 Verificando SQL Server: {server}")
        
        try:
            # Intentar conectar a la base de datos master
            conn_str = f"DRIVER={{SQL Server}};SERVER={server};DATABASE=master;Trusted_Connection=yes;"
            
            with pyodbc.connect(conn_str, timeout=5) as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT @@VERSION")
                version = cursor.fetchone()[0]
                
                print(f"✅ SQL Server disponible")
                print(f"   📊 Versión: {version[:70]}...")
                
                return True, "SQL Server disponible"
                
        except pyodbc.Error as e:
            error_msg = f"SQL Server no disponible: {e}"
            print(f"❌ {error_msg}")
            return False, error_msg
        except Exception as e:
            error_msg = f"Error verificando SQL Server: {e}"
            print(f"❌ {error_msg}")
            return False, error_msg
    
    def verificar_base_datos_existe(self, server: str, db_name: str) -> bool:
        """
        Verifica si una base de datos existe en el servidor.
        
        Args:
            server: Nombre del servidor
            db_name: Nombre de la base de datos
            
        Returns:
            bool: True si existe, False en caso contrario
        """
        print(f"\n🔍 Verificando si existe la base de datos: {db_name}")
        
        try:
            conn_str = f"DRIVER={{SQL Server}};SERVER={server};DATABASE=master;Trusted_Connection=yes;"
            
            with pyodbc.connect(conn_str, timeout=5) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "SELECT database_id FROM sys.databases WHERE name = ?",
                    (db_name,)
                )
                result = cursor.fetchone()
                
                exists = result is not None
                
                if exists:
                    print(f"✅ Base de datos '{db_name}' ya existe")
                else:
                    print(f"ℹ️  Base de datos '{db_name}' no existe (se creará)")
                
                return exists
                
        except Exception as e:
            print(f"❌ Error verificando base de datos: {e}")
            return False
    
    def ejecutar_script_sql(
        self,
        script_path: Path,
        server: str,
        db_name: str
    ) -> Tuple[bool, str]:
        """
        Ejecuta un script SQL en la base de datos.
        
        Args:
            script_path: Ruta al archivo .sql
            server: Nombre del servidor
            db_name: Nombre de la base de datos
            
        Returns:
            tuple: (éxito: bool, mensaje: str)
        """
        if not script_path.exists():
            error_msg = f"Script no encontrado: {script_path}"
            print(f"❌ {error_msg}")
            return False, error_msg
        
        print(f"\n📜 Ejecutando script: {script_path.name}")
        
        try:
            # Leer script SQL
            with open(script_path, 'r', encoding='utf-8') as f:
                sql_script = f.read()
            
            # Conectar a la base de datos
            conn_str = f"DRIVER={{SQL Server}};SERVER={server};DATABASE={db_name};Trusted_Connection=yes;"
            
            with pyodbc.connect(conn_str, autocommit=True) as conn:
                cursor = conn.cursor()
                
                # Dividir el script en comandos individuales
                # SQL Server usa GO como separador de lotes
                comandos = sql_script.split('GO')
                
                total_comandos = len([cmd for cmd in comandos if cmd.strip()])
                print(f"   📝 Total de comandos a ejecutar: {total_comandos}")
                
                for i, comando in enumerate(comandos, 1):
                    comando = comando.strip()
                    if comando:
                        try:
                            cursor.execute(comando)
                            print(f"   ✅ Comando {i}/{total_comandos} ejecutado")
                        except pyodbc.Error as e:
                            # Algunos errores pueden ser ignorables (ej: tabla ya existe)
                            if "already exists" in str(e):
                                print(f"   ⚠️  Comando {i}/{total_comandos}: {e}")
                            else:
                                raise
                
                print(f"✅ Script ejecutado exitosamente: {script_path.name}")
                return True, "Script ejecutado correctamente"
                
        except pyodbc.Error as e:
            error_msg = f"Error ejecutando script SQL: {e}"
            print(f"❌ {error_msg}")
            return False, error_msg
        except Exception as e:
            error_msg = f"Error inesperado: {e}"
            print(f"❌ {error_msg}")
            return False, error_msg
    
    def crear_base_datos(self, server: str, db_name: str) -> Tuple[bool, str]:
        """
        Crea una nueva base de datos y ejecuta los scripts de inicialización.
        
        Args:
            server: Nombre del servidor
            db_name: Nombre de la base de datos a crear
            
        Returns:
            tuple: (éxito: bool, mensaje: str)
        """
        print("\n" + "="*60)
        print("🏗️  CREANDO BASE DE DATOS")
        print("="*60)
        
        try:
            # Conectar a master para crear la BD
            conn_str = f"DRIVER={{SQL Server}};SERVER={server};DATABASE=master;Trusted_Connection=yes;"
            
            with pyodbc.connect(conn_str, autocommit=True) as conn:
                cursor = conn.cursor()
                
                # Crear base de datos
                print(f"\n📦 Creando base de datos: {db_name}")
                cursor.execute(f"CREATE DATABASE [{db_name}]")
                print(f"✅ Base de datos '{db_name}' creada exitosamente")
            
            # Ejecutar script de schema
            if self.schema_script.exists():
                print(f"\n📋 Aplicando schema (tablas, relaciones)...")
                exito, mensaje = self.ejecutar_script_sql(
                    self.schema_script,
                    server,
                    db_name
                )
                
                if not exito:
                    return False, f"Error aplicando schema: {mensaje}"
            else:
                print(f"⚠️  Script de schema no encontrado: {self.schema_script}")
            
            # Ejecutar script de datos iniciales (si existe)
            if self.datos_script.exists():
                print(f"\n📊 Insertando datos iniciales...")
                self.ejecutar_script_sql(self.datos_script, server, db_name)
            else:
                print(f"ℹ️  Script de datos iniciales no encontrado (opcional)")
            
            print("\n" + "="*60)
            print("✅ BASE DE DATOS CREADA CORRECTAMENTE")
            print("="*60)
            
            return True, "Base de datos creada exitosamente"
            
        except pyodbc.Error as e:
            error_msg = f"Error creando base de datos: {e}"
            print(f"❌ {error_msg}")
            return False, error_msg
        except Exception as e:
            error_msg = f"Error inesperado: {e}"
            print(f"❌ {error_msg}")
            return False, error_msg
    
    def crear_usuario_admin(
        self,
        server: str,
        db_name: str,
        username: str = "admin",
        password: str = "admin123"
    ) -> Tuple[bool, dict]:
        """
        Crea el usuario administrador inicial en la base de datos.
        
        Args:
            server: Nombre del servidor
            db_name: Nombre de la base de datos
            username: Nombre de usuario (default: admin)
            password: Contraseña (default: admin123)
            
        Returns:
            tuple: (éxito: bool, credenciales: dict)
        """
        print(f"\n👤 Creando usuario administrador: {username}")
        
        try:
            # Hash de la contraseña (simple con hashlib)
            password_hash = hashlib.sha256(password.encode()).hexdigest()
            
            conn_str = f"DRIVER={{SQL Server}};SERVER={server};DATABASE={db_name};Trusted_Connection=yes;"
            
            with pyodbc.connect(conn_str) as conn:
                cursor = conn.cursor()
                
                # Verificar si el usuario ya existe
                cursor.execute(
                    "SELECT COUNT(*) FROM Usuarios WHERE usuario = ?",
                    (username,)
                )
                existe = cursor.fetchone()[0] > 0
                
                if existe:
                    print(f"ℹ️  Usuario '{username}' ya existe")
                    return True, {'usuario': username, 'existe': True}
                
                # Insertar usuario admin
                query = """
                INSERT INTO Usuarios (usuario, contrasena, id_rol, activo, fecha_creacion)
                VALUES (?, ?, ?, ?, GETDATE())
                """
                
                cursor.execute(query, (username, password_hash, 1, 1))
                conn.commit()
                
                print(f"✅ Usuario administrador creado:")
                print(f"   👤 Usuario: {username}")
                print(f"   🔑 Contraseña: {password}")
                print(f"   ⚠️  IMPORTANTE: Cambiar contraseña después del primer login")
                
                credenciales = {
                    'usuario': username,
                    'password': password,
                    'id_rol': 1,
                    'existe': False
                }
                
                return True, credenciales
                
        except pyodbc.Error as e:
            error_msg = f"Error creando usuario: {e}"
            print(f"❌ {error_msg}")
            return False, {'error': error_msg}
        except Exception as e:
            error_msg = f"Error inesperado: {e}"
            print(f"❌ {error_msg}")
            return False, {'error': error_msg}
    
    def setup_completo(
        self,
        server: str,
        db_name: str,
        admin_username: str = "admin",
        admin_password: str = "admin123"
    ) -> Tuple[bool, dict]:
        """
        Realiza el setup completo de la base de datos.
        
        Args:
            server: Nombre del servidor
            db_name: Nombre de la base de datos
            admin_username: Usuario administrador
            admin_password: Contraseña administrador
            
        Returns:
            tuple: (éxito: bool, resultado: dict)
        """
        print("\n" + "="*60)
        print("🚀 SETUP COMPLETO DE BASE DE DATOS")
        print("="*60)
        
        resultado = {
            'sql_server_disponible': False,
            'base_datos_creada': False,
            'schema_aplicado': False,
            'usuario_admin_creado': False,
            'credenciales': {},
            'errores': []
        }
        
        # 1. Verificar SQL Server
        print("\n1️⃣  Verificando SQL Server...")
        disponible, mensaje = self.verificar_sql_server(server)
        resultado['sql_server_disponible'] = disponible
        
        if not disponible:
            resultado['errores'].append(mensaje)
            return False, resultado
        
        # 2. Verificar si BD ya existe
        print("\n2️⃣  Verificando base de datos...")
        bd_existe = self.verificar_base_datos_existe(server, db_name)
        
        # 3. Crear BD si no existe
        if not bd_existe:
            print("\n3️⃣  Creando base de datos...")
            exito, mensaje = self.crear_base_datos(server, db_name)
            resultado['base_datos_creada'] = exito
            resultado['schema_aplicado'] = exito
            
            if not exito:
                resultado['errores'].append(mensaje)
                return False, resultado
        else:
            print("\n3️⃣  Base de datos ya existe, saltando creación...")
            resultado['base_datos_creada'] = True
            resultado['schema_aplicado'] = True
        
        # 4. Crear usuario admin
        print("\n4️⃣  Configurando usuario administrador...")
        exito, credenciales = self.crear_usuario_admin(
            server,
            db_name,
            admin_username,
            admin_password
        )
        resultado['usuario_admin_creado'] = exito
        resultado['credenciales'] = credenciales
        
        if not exito:
            resultado['errores'].append(credenciales.get('error', 'Error desconocido'))
        
        # Resumen final
        print("\n" + "="*60)
        print("📊 RESUMEN DEL SETUP:")
        print("="*60)
        print(f"   SQL Server: {'✅' if resultado['sql_server_disponible'] else '❌'}")
        print(f"   Base de datos: {'✅' if resultado['base_datos_creada'] else '❌'}")
        print(f"   Schema aplicado: {'✅' if resultado['schema_aplicado'] else '❌'}")
        print(f"   Usuario admin: {'✅' if resultado['usuario_admin_creado'] else '❌'}")
        
        if resultado['errores']:
            print(f"\n⚠️  Errores encontrados:")
            for error in resultado['errores']:
                print(f"   • {error}")
        else:
            print("\n✅ Setup completado sin errores")
            
            if not credenciales.get('existe', False):
                print("\n🔐 CREDENCIALES DE ADMINISTRADOR:")
                print(f"   👤 Usuario: {credenciales.get('usuario')}")
                print(f"   🔑 Contraseña: {credenciales.get('password')}")
                print(f"   ⚠️  IMPORTANTE: Cambiar contraseña en el primer login")
        
        print("="*60 + "\n")
        
        setup_exitoso = all([
            resultado['sql_server_disponible'],
            resultado['base_datos_creada'],
            resultado['schema_aplicado']
        ])
        
        return setup_exitoso, resultado


# Función de conveniencia para setup rápido
def setup_rapido(
    server: str = "localhost\\SQLEXPRESS",
    db_name: str = "Produccion_Agro"
):
    """
    Ejecuta un setup rápido con valores por defecto.
    
    Args:
        server: Servidor SQL Server
        db_name: Nombre de la base de datos
        
    Returns:
        tuple: (éxito, resultado)
    """
    installer = DatabaseInstaller()
    return installer.setup_completo(server, db_name)