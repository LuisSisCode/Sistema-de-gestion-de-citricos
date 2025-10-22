# backend/core/database.py
"""
Gestor de conexión a la base de datos SQL Server
"""

import pyodbc
import logging
from .config import Config

# Configurar logging con colores
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('DatabaseConnection')


class DatabaseConnection:
    """
    Clase para manejar la conexión a la base de datos SQL Server.
    Implementa el patrón Singleton.
    """
    _instance = None
    
    def __new__(cls, *args, **kwargs):
        """
        Implementación del patrón Singleton para asegurar una única instancia
        de la conexión a la base de datos.
        """
        if cls._instance is None:
            cls._instance = super(DatabaseConnection, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self, server=None, database=None, trusted_connection=None):
        """
        Inicializa la conexión a la base de datos SQL Server.
        
        Args:
            server (str, optional): Nombre del servidor SQL Server.
            database (str, optional): Nombre de la base de datos.
            trusted_connection (bool, optional): Usar autenticación de Windows.
        """
        # Evitar reinicialización si ya está inicializado (patrón Singleton)
        if self._initialized:
            return
        
        # Usar Config si no se proporcionan parámetros
        self.server = server or Config.DB_SERVER
        self.database = database or Config.DB_DATABASE
        
        if trusted_connection is None:
            trusted_connection = Config.DB_TRUSTED_CONNECTION.lower() in ['yes', 'true', '1']
        
        self.trusted_connection = trusted_connection
        
        # Generar connection string desde Config
        self.connection_string = Config.get_db_connection_string()
        
        print(f"🔧 DatabaseConnection inicializado:")
        print(f"   📍 Servidor: {self.server}")
        print(f"   💾 Base de datos: {self.database}")
        print(f"   🔐 Trusted Connection: {self.trusted_connection}")
        
        self._initialized = True
    
    def test_connection(self):
        """
        Prueba la conexión a la base de datos.
        
        Returns:
            tuple: (éxito: bool, mensaje: str)
        """
        try:
            with pyodbc.connect(self.connection_string, timeout=Config.DB_TIMEOUT) as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT @@VERSION")
                version = cursor.fetchone()[0]
                
                logger.info("✅ Conexión a la base de datos exitosa")
                print(f"✅ Conexión exitosa a SQL Server")
                print(f"   📊 Versión: {version[:50]}...")
                
                return True, "Conexión exitosa"
                
        except pyodbc.Error as e:
            error_msg = str(e)
            logger.error(f"❌ Error al probar la conexión: {error_msg}")
            print(f"❌ Error de conexión: {error_msg}")
            
            return False, error_msg
        except Exception as e:
            error_msg = str(e)
            logger.error(f"❌ Error inesperado: {error_msg}")
            print(f"❌ Error inesperado: {error_msg}")
            
            return False, error_msg
    
    def database_exists(self) -> bool:
        """
        Verifica si la base de datos existe en el servidor.
        
        Returns:
            bool: True si la base de datos existe, False en caso contrario
        """
        try:
            # Conectar a master para verificar si la BD existe
            master_conn_str = f"DRIVER={{SQL Server}};SERVER={self.server};DATABASE=master;"
            
            if self.trusted_connection:
                master_conn_str += "Trusted_Connection=yes;"
            
            with pyodbc.connect(master_conn_str, timeout=Config.DB_TIMEOUT) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "SELECT database_id FROM sys.databases WHERE name = ?",
                    (self.database,)
                )
                result = cursor.fetchone()
                
                exists = result is not None
                
                if exists:
                    logger.info(f"✅ Base de datos '{self.database}' encontrada")
                    print(f"✅ Base de datos '{self.database}' existe")
                else:
                    logger.warning(f"⚠️  Base de datos '{self.database}' no encontrada")
                    print(f"⚠️  Base de datos '{self.database}' NO existe")
                
                return exists
                
        except pyodbc.Error as e:
            logger.error(f"❌ Error verificando base de datos: {e}")
            print(f"❌ Error al verificar BD: {e}")
            return False
        except Exception as e:
            logger.error(f"❌ Error inesperado: {e}")
            print(f"❌ Error inesperado: {e}")
            return False
    
    def get_connection(self):
        """
        Obtiene una conexión a la base de datos.
        
        Returns:
            Connection: Objeto de conexión pyodbc.
        """
        try:
            conn = pyodbc.connect(self.connection_string, timeout=Config.DB_TIMEOUT)
            logger.debug("Conexión obtenida exitosamente")
            return conn
        except pyodbc.Error as e:
            logger.error(f"❌ Error al obtener conexión: {e}")
            raise
        except Exception as e:
            logger.error(f"❌ Error inesperado al obtener conexión: {e}")
            raise
    
    def get_connection_string(self):
        """
        Obtiene la cadena de conexión.
        
        Returns:
            str: Cadena de conexión a la base de datos.
        """
        return self.connection_string
    
    def get_server_info(self):
        """
        Obtiene información del servidor SQL Server.
        
        Returns:
            dict: Información del servidor o None si hay error
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                # Versión de SQL Server
                cursor.execute("SELECT @@VERSION")
                version = cursor.fetchone()[0]
                
                # Nombre del servidor
                cursor.execute("SELECT @@SERVERNAME")
                server_name = cursor.fetchone()[0]
                
                # Nombre de la base de datos actual
                cursor.execute("SELECT DB_NAME()")
                db_name = cursor.fetchone()[0]
                
                info = {
                    'version': version,
                    'server_name': server_name,
                    'database_name': db_name,
                    'connection_string': self.connection_string[:50] + "..."
                }
                
                logger.info("✅ Información del servidor obtenida")
                return info
                
        except Exception as e:
            logger.error(f"❌ Error obteniendo información del servidor: {e}")
            return None
    
    def verificar_conexion_completa(self):
        """
        Realiza una verificación completa de la conexión.
        
        Returns:
            dict: Resultado de la verificación
        """
        print("\n" + "="*60)
        print("🔍 VERIFICACIÓN COMPLETA DE CONEXIÓN")
        print("="*60)
        
        resultado = {
            'servidor_alcanzable': False,
            'base_datos_existe': False,
            'conexion_exitosa': False,
            'errores': []
        }
        
        # 1. Verificar si el servidor está alcanzable
        print("\n1️⃣  Verificando servidor...")
        try:
            master_conn_str = f"DRIVER={{SQL Server}};SERVER={self.server};DATABASE=master;"
            if self.trusted_connection:
                master_conn_str += "Trusted_Connection=yes;"
            
            with pyodbc.connect(master_conn_str, timeout=5) as conn:
                print(f"   ✅ Servidor '{self.server}' alcanzable")
                resultado['servidor_alcanzable'] = True
        except Exception as e:
            print(f"   ❌ Servidor no alcanzable: {e}")
            resultado['errores'].append(f"Servidor: {e}")
        
        # 2. Verificar si la base de datos existe
        if resultado['servidor_alcanzable']:
            print("\n2️⃣  Verificando base de datos...")
            existe = self.database_exists()
            resultado['base_datos_existe'] = existe
            
            if not existe:
                resultado['errores'].append(f"Base de datos '{self.database}' no existe")
        
        # 3. Probar conexión completa
        if resultado['base_datos_existe']:
            print("\n3️⃣  Probando conexión...")
            exito, mensaje = self.test_connection()
            resultado['conexion_exitosa'] = exito
            
            if not exito:
                resultado['errores'].append(f"Conexión: {mensaje}")
        
        # Resumen
        print("\n" + "="*60)
        print("📊 RESUMEN:")
        print(f"   Servidor alcanzable: {'✅' if resultado['servidor_alcanzable'] else '❌'}")
        print(f"   Base de datos existe: {'✅' if resultado['base_datos_existe'] else '❌'}")
        print(f"   Conexión exitosa: {'✅' if resultado['conexion_exitosa'] else '❌'}")
        
        if resultado['errores']:
            print(f"\n⚠️  Errores encontrados:")
            for error in resultado['errores']:
                print(f"   • {error}")
        
        print("="*60 + "\n")
        
        return resultado


# NO ejecutar test_connection automáticamente al importar
# El usuario debe llamarlo explícitamente cuando lo necesite