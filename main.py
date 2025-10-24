# main.py - AgroIchilo con autenticación integrada
import sys
import os

# ⭐ CRÍTICO: Configurar WebEngine ANTES de cualquier importación Qt
os.environ["QTWEBENGINE_DISABLE_SANDBOX"] = "1"
os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = "--disable-web-security --allow-running-insecure-content --disable-dev-shm-usage"
os.environ["QT_LOGGING_RULES"] = "*.debug=false"

from backend.core.cache_system import cache_manager, print_cache_stats, clear_cache
from PySide6.QtCore import QObject, Slot, QUrl, Property, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

# ⭐ IMPORTACIONES WEBENGINE EN ORDEN CORRECTO
from PySide6.QtWebEngineQuick import QtWebEngineQuick
from PySide6.QtWebEngineCore import QWebEngineSettings

# Importar AuthService y LoginController
from backend.services.auth_service import auth_service
from frontend.controllers.login_controller import LoginController

# Modelos existentes
from backend.models.usuario_model import UsuariosRolesModel
from backend.models.agricultores_parcelas_model import AgricultoresParcelasModels
from backend.models.cultivos_model import CultivosModel
from backend.models.agroquimicos_model import AgroquimicosModel
from backend.models.maquinaria_model import MaquinariaModel
from backend.models.ventas_cliente_model import ClientesVentaModel

from recursos.mapa.mapa_service_integrado import inicializar_servicio_mapa, servicio_mapa

class AppManager(QObject):
    """Gestor principal de la aplicación con autenticación"""
    
    # Señales
    vistaChanged = Signal(str)  # "login" o "main"
    
    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        self.root = None
        self._vista_actual = "login"  # Iniciar en login
        self.module_manager = None
        
    @Property(str, notify=vistaChanged)
    def vistaActual(self):
        return self._vista_actual
    
    @vistaActual.setter
    def vistaActual(self, value):
        if self._vista_actual != value:
            self._vista_actual = value
            self.vistaChanged.emit(value)
            print(f"📱 Vista cambiada a: {value}")
    
    def set_root_object(self, root):
        """Establece el objeto raíz de QML"""
        self.root = root
    
    @Slot()
    def mostrarLogin(self):
        """Muestra la vista de login"""
        self.vistaActual = "login"
        if self.root:
            self.root.setProperty("currentView", "login")
    
    @Slot()
    def mostrarMain(self):
        """Muestra la vista principal"""
        self.vistaActual = "main"
        if self.root:
            self.root.setProperty("currentView", "main")
            # Inicializar el ModuleManager si aún no existe
            if not self.module_manager:
                self.module_manager = ModuleManager(self.engine)
                # Buscar el objeto main dentro del contenedor
                main_obj = self.root.findChild(QObject, "mainContainer")
                if main_obj:
                    self.module_manager.set_root_object(main_obj)
    
    @Slot()
    def cerrarSesion(self):
        """Cierra la sesión del usuario"""
        auth_service.logout()
        self.mostrarLogin()
    
    @Slot(result=bool)
    def estaAutenticado(self):
        """Verifica si hay una sesión activa"""
        return auth_service.esta_autenticado()
    
    @Slot(result=str)
    def obtenerNombreUsuario(self):
        """Obtiene el nombre completo del usuario actual"""
        return auth_service.obtener_nombre_completo()
    
    @Slot(result=str)
    def obtenerRolUsuario(self):
        """Obtiene el rol del usuario actual"""
        return auth_service.obtener_nombre_rol()


class ModuleManager(QObject):
    """Clase para manejar la navegación entre módulos de la aplicación"""
    
    moduleChanged = Signal(int)
    
    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        self.root = None
        self._current_module = 0
        
        # Mapeo de índices de módulos a archivos QML
        self.module_files = {
            0: "Dashboard.qml",
            1: "usuario_roles.qml",
            2: "agricultores_parcela.qml",
            3: "cultivos.qml",
            4: "agroquimico.qml",
            5: "ventas_cliente.qml",
            6: "maquinaria.qml",
            7: "configuracion.qml",
            8: "reportesAgricola.qml",
            9: "gastos.qml"
        }
    
    def set_root_object(self, root):
        """Establece el objeto raíz de QML y conecta los botones"""
        self.root = root
        self.connect_buttons()
    
    def connect_buttons(self):
        """Conecta los botones del menú con las funciones para cambiar módulos"""
        if not self.root:
            print("Error: No se pudo acceder al objeto raíz QML")
            return
        
        # Verificar si existe el contentContainer (Loader)
        self.content_container = self.root.findChild(QObject, "contentContainer")
        if not self.content_container:
            print("Error: No se pudo encontrar el contentContainer en el QML")
            return
        
        print("✅ Contenedor de contenido encontrado correctamente")
        
        # Conectar los botones
        self.connect_button("btnInicio", 0)
        self.connect_button("btnUsuarios", 1)
        self.connect_button("btnAgricultores", 2)
        self.connect_button("btnCultivos", 3)
        self.connect_button("btnAgroquimicos", 4)
        self.connect_button("btnVentas", 5)
        self.connect_button("btnMaquinaria", 6)
        self.connect_button("btnConfiguracion", 7)
        self.connect_button("btnReportes", 8)
        self.connect_button("btnGastos", 9)
        
        # Cargar el módulo inicial
        self.change_module(0)
    
    def connect_button(self, button_id, module_index):
        """Conecta un botón específico para cambiar al módulo correspondiente"""
        button = self.root.findChild(QObject, button_id)
        if button:
            button.clicked.connect(lambda: self.change_module(module_index))
        else:
            print(f"⚠️ No se encontró el botón {button_id}")
    
    @Slot(int)
    def change_module(self, module_index):
        """Cambia al módulo especificado"""
        # TODO: Verificar permisos antes de cambiar
        # if not auth_service.tiene_permiso(modulo, 'leer'):
        #     return
        
        print(f"📂 Cambiando al módulo: {module_index}")
        
        # Actualizar la propiedad activeModule del QML
        self.root.setProperty("activeModule", module_index)
        
        # Obtener el archivo QML correspondiente
        qml_file = self.module_files.get(module_index)
        if not qml_file:
            print(f"❌ No se encontró archivo para módulo {module_index}")
            return
        
        # Verificar que el archivo existe
        if not os.path.exists(qml_file):
            print(f"❌ No existe el archivo {qml_file}")
            return
        
        # Cargar el archivo QML en el Loader
        if self.content_container:
            self.content_container.setProperty("source", qml_file)
        
        self._current_module = module_index
        self.moduleChanged.emit(module_index)


def configurar_webengine_global():
    """Configura WebEngine globalmente para localhost"""
    try:
        settings = QWebEngineSettings.globalSettings()
        
        settings.setAttribute(QWebEngineSettings.LocalContentCanAccessRemoteUrls, True)
        settings.setAttribute(QWebEngineSettings.LocalContentCanAccessFileUrls, True) 
        settings.setAttribute(QWebEngineSettings.AllowRunningInsecureContent, True)
        settings.setAttribute(QWebEngineSettings.JavascriptEnabled, True)
        settings.setAttribute(QWebEngineSettings.PluginsEnabled, True)
        settings.setAttribute(QWebEngineSettings.LocalStorageEnabled, True)
        
        print("✅ WebEngine configurado globalmente")
        return True
        
    except Exception as e:
        print(f"⚠️ Error configurando WebEngine: {e}")
        return False


def inicializar_servicios_mapa():
    """Inicializa el servicio de mapas integrado"""
    print("🚀 Iniciando servicio de mapas...")
    print("📦 Configurando sistema de caché...")
    print("✅ Sistema de caché configurado")
    print_cache_stats()

    try:
        if inicializar_servicio_mapa():
            print("✅ Servicio de mapas iniciado")
            print("🗺️ Mapa disponible en: http://localhost:5001/mapa")
            return True
        else:
            print("⚠️ Servicio de mapas no disponible")
            return False
    except Exception as e:
        print(f"❌ Error iniciando servicio de mapas: {str(e)}")
        return False


def main():
    print("🔧 Configurando WebEngine...")
    
    # Configurar argumentos Qt
    try:
        from PySide6.QtCore import Qt
        if hasattr(Qt, 'AA_ShareOpenGLContexts'):
            QGuiApplication.setAttribute(Qt.AA_ShareOpenGLContexts, True)
            print("✅ Contextos OpenGL compartidos habilitados")
    except Exception as e:
        print(f"ℹ️ No se pudo configurar OpenGL: {e}")
    
    # Inicializar QtWebEngine
    print("🌐 Inicializando QtWebEngine...")
    try:
        QtWebEngineQuick.initialize()
        print("✅ QtWebEngine inicializado")
    except Exception as e:
        print(f"⚠️ Error inicializando QtWebEngine: {e}")
    
    # Crear la aplicación
    print("🖥️ Creando aplicación Qt...")
    
    args = sys.argv + [
        "--disable-web-security",
        "--allow-running-insecure-content", 
        "--no-sandbox",
        "--disable-dev-shm-usage",
        "--allow-insecure-localhost",
        "--disable-features=VizDisplayCompositor"
    ]
    
    app = QGuiApplication(args)
    
    # Configurar WebEngine
    print("⚙️ Configurando WebEngine globalmente...")
    configurar_webengine_global()
    
    os.environ["QT_DEBUG_PLUGINS"] = "0"
    
    # Crear el motor QML
    engine = QQmlApplicationEngine()
    
    # Inicializar servicios de mapa
    print("🗺️ Iniciando servicios de mapa...")
    inicializar_servicios_mapa()
    
    # Crear el gestor de aplicación
    app_manager = AppManager(engine)
    
    # Crear el controlador de login
    login_controller = LoginController()
    
    # Conectar señal de login exitoso
    login_controller.loginExitoso.connect(app_manager.mostrarMain)
    
    # Registrar en contexto QML
    engine.rootContext().setContextProperty("appManager", app_manager)
    engine.rootContext().setContextProperty("loginController", login_controller)
    engine.rootContext().setContextProperty("authService", auth_service)
    
    # Crear y registrar modelos existentes
    print("📊 Registrando modelos de datos...")
    usuario_roles_model = UsuariosRolesModel()
    engine.rootContext().setContextProperty("usuariosRolesModel", usuario_roles_model)
    
    agricultores_parcelas_model = AgricultoresParcelasModels()
    engine.rootContext().setContextProperty("agricultoresparcelas", agricultores_parcelas_model)

    cultivos_model = CultivosModel()
    engine.rootContext().setContextProperty("cultivos", cultivos_model)

    agroquimicos_model = AgroquimicosModel()
    engine.rootContext().setContextProperty("agroquimicosModel", agroquimicos_model)

    ventas_cliente_model = ClientesVentaModel()
    engine.rootContext().setContextProperty("ventaModel", ventas_cliente_model) 
    
    maquinaria_model = MaquinariaModel()
    engine.rootContext().setContextProperty("maquinariaModel", maquinaria_model)

    # Verificar archivos
    print(f"📁 Directorio de trabajo: {os.getcwd()}")
    
    # Cargar QML principal (app_container.qml en lugar de main.qml)
    print("📄 Cargando contenedor principal...")
    qml_file_path = "app_container.qml"
    
    if not os.path.exists(qml_file_path):
        print(f"❌ Error: No se encontró {qml_file_path}")
        sys.exit(-1)
    
    qml_file = QUrl.fromLocalFile(qml_file_path)
    engine.load(qml_file)
    
    # Verificar carga exitosa
    if not engine.rootObjects():
        print("❌ Error: No se pudo cargar el archivo QML principal.")
        sys.exit(-1)
    
    # Configurar el gestor
    root_object = engine.rootObjects()[0]
    app_manager.set_root_object(root_object)
    
    print("🎉 Aplicación iniciada correctamente")
    
    # Ejecutar la aplicación
    sys.exit(app.exec())


if __name__ == "__main__":
    main()