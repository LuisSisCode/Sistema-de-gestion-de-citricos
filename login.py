# login.py - Modificado para lanzar la aplicación principal después del login exitoso
from datetime import datetime
import sys
import os
import subprocess
from pathlib import Path
from user_session import save_current_user

# Importamos los módulos necesarios de PySide6
from PySide6.QtCore import QObject, Slot, Property, Signal, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
import pyodbc  # Para la conexión con SQL Server

class Backend(QObject):
    """Clase para el backend en Python que se comunicará con QML"""
    
    # Señal para notificar cambios
    statusChanged = Signal(str)
    loginSuccess = Signal(bool)
    
    def __init__(self):
        super().__init__()
        self._status = "El sistema está listo para autenticar"
        self._connection = None
        self._connect_to_db()
    
    def _connect_to_db(self):
        """Establece conexión con la base de datos SQL Server"""
        try:
            # Configuración específica para tu servidor
            server = 'DESKTOP-HOE6AHT\\SQLEXPRESS'  # Servidor específico de la imagen
            database = 'Produccion_Citricos'
            # Usamos autenticación de Windows para conectar
            conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'
            
            self._connection = pyodbc.connect(conn_str)
            print("Conexión a la base de datos establecida con éxito")
        except Exception as e:
            print(f"Error al conectar a la base de datos: {e}")
            self._connection = None
            self._status = f"Error de conexión: {str(e)}"
            self.statusChanged.emit(self._status)
    
    @Property(str)
    def status(self):
        """Propiedad status para QML"""
        return self._status
    
    @Slot(str, str)
    def login(self, username, password):
        """Función para manejar el login desde QML verificando en la base de datos con contraseña en texto plano"""
        print(f"Intentando login con usuario: {username}")
        
        if not self._connection:
            self._status = "Error: No se pudo conectar a la base de datos."
            self.statusChanged.emit(self._status)
            self.loginSuccess.emit(False)
            return
        
        if not username or not password:
            self._status = "Por favor, ingresa nombre de usuario y contraseña."
            self.statusChanged.emit(self._status)
            self.loginSuccess.emit(False)
            return
        
        try:
            cursor = self._connection.cursor()
            
            # Consulta modificada para texto plano (sin hash)
            query = """
            SELECT u.id_usuario, u.nombre, u.apellido, r.nombre_rol 
            FROM Usuarios u
            JOIN Roles r ON u.id_rol = r.id_rol
            WHERE u.usuario = ? AND u.contrasena = ?
            AND u.activo = 1
            """
            
            # Pasamos username y password directamente (sin calcular hash)
            cursor.execute(query, (username, password))
            
            user = cursor.fetchone()
            if user:
                id_usuario, nombre, apellido, rol = user
                self._status = f"Bienvenido, {nombre} {apellido} ({rol})"
                self._save_current_user(id_usuario, nombre, apellido, rol)
                # Actualizar último acceso
                try:
                    update_query = """
                    UPDATE Usuarios SET ultimo_acceso = GETDATE()
                    WHERE id_usuario = ?
                    """
                    cursor.execute(update_query, (id_usuario,))
                    self._connection.commit()
                    print(f"Actualizado último acceso para usuario ID: {id_usuario}")
                except Exception as update_error:
                    print(f"Error al actualizar último acceso: {update_error}")
                
                print("Usuario y Contraseña Correcta :)")
                self.statusChanged.emit(self._status)
                self.loginSuccess.emit(True)
                
                # Cerrar la ventana de login y abrir la aplicación principal
                QGuiApplication.instance().quit()
                self._launch_main_application()
                
            else:
                print("Usuario o contraseña incorrecto")
                self._status = "Usuario o contraseña incorrectos."
                self.statusChanged.emit(self._status)
                self.loginSuccess.emit(False)
            
            cursor.close()
            
        except Exception as e:
            self._status = f"Error durante el inicio de sesión: {str(e)}"
            self.statusChanged.emit(self._status)
            self.loginSuccess.emit(False)
            print(f"Error de login: {e}")
    def _save_current_user(self, id_usuario, nombre, apellido, rol):
        """Guarda la información del usuario actual para que esté disponible en toda la aplicación"""
        try:
            # Opción 1: Usar un archivo temporal
            import json
            user_data = {
                "id_usuario": id_usuario,
                "nombre": nombre,
                "apellido": apellido,
                "rol": rol,
                "login_time": datetime.now().isoformat()
            }
            
            with open("current_user.json", "w") as f:
                json.dump(user_data, f)
                
            print(f"Información del usuario guardada: ID={id_usuario}, Nombre={nombre} {apellido}")
        except Exception as e:
            print(f"Error al guardar información del usuario: {e}")
    
    def _launch_main_application(self):
        """Lanza la aplicación principal después de un login exitoso"""
        try:
            # Obtiene la ruta del directorio actual
            current_dir = os.path.dirname(os.path.abspath(__file__))
            main_script = os.path.join(current_dir, "main.py")
            
            # Verifica que el archivo main.py existe
            if not os.path.exists(main_script):
                print(f"Error: No se encontró el archivo principal en {main_script}")
                return
                
            # Lanza el proceso de la aplicación principal
            print(f"Iniciando aplicación principal: {main_script}")
            
            # Usar el mismo intérprete de Python que está ejecutando este script
            python_executable = sys.executable
            subprocess.Popen([python_executable, main_script])
        except Exception as e:
            print(f"Error al iniciar la aplicación principal: {e}")
    
    def __del__(self):
        """Cerrar la conexión a la base de datos cuando se destruye el objeto"""
        if self._connection:
            self._connection.close()
            print("Conexión a la base de datos cerrada")

def main():
    # Configuración para asegurar que se utilice la versión correcta de Qt
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"  # Usa un estilo básico que funciona sin problemas
    
    # Crear la aplicación
    app = QGuiApplication(sys.argv)
    
    # Configuramos para depuración - ayuda a identificar problemas
    os.environ["QT_DEBUG_PLUGINS"] = "1"
    
    # Crear el motor QML
    engine = QQmlApplicationEngine()
    
    # Crear e instalar el backend
    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)
    
    # Cargar el archivo QML
    qml_file = os.path.join(os.path.dirname(__file__), "login.qml")
    print(f"Cargando archivo QML: {qml_file}")
    
    # Verificar si el archivo existe
    if not os.path.exists(qml_file):
        print(f"Error: El archivo QML no existe en {qml_file}")
        sys.exit(-1)
        
    engine.load(QUrl.fromLocalFile(qml_file))
    
    # Verificar si el archivo QML se cargó correctamente
    if not engine.rootObjects():
        print("Error: No se pudo cargar el archivo QML. Verifica los errores de importación.")
        sys.exit(-1)
    
    # Ejecutar la aplicación
    sys.exit(app.exec())

if __name__ == "__main__":
    main()