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
from controllers.login_controller import LoginController

# Modelos existentes
from backend.models.usuario_model import UsuariosRolesModel
from backend.models.productores_parcelas_model import ProductoresParcelasModels
from backend.models.cultivos_model import CultivosModel
from backend.models.agroquimicos_model import AgroquimicosModel
from backend.models.maquinaria_model import MaquinariaModel
from backend.models.ventas_cliente_model import ClientesVentaModel

# Nuevos modelos a incluir
from backend.models.auth_model import AutoModel 
from backend.models.gastos_model import GastosModel
from backend.models.reportes_model import *
from backend.models.dashboard_model import DashboardModel


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
        """Muestra la vista principal y carga el dashboard"""
        print("🔓 Mostrando vista principal...")
        self.vistaActual = "main"
        
        if self.root:
            self.root.setProperty("currentView", "main")
            
            # Esperar a que se cargue el QML principal
            # Usamos un pequeño delay para asegurar que el Loader haya terminado de cargar
            from PySide6.QtCore import QTimer
            QTimer.singleShot(100, self.inicializarModuleManager)
    
    def inicializarModuleManager(self):
        """Inicializa el ModuleManager después de que main.qml esté cargado"""
        if not self.module_manager:
            print("🔧 Inicializando ModuleManager...")
            self.module_manager = ModuleManager(self.engine)
            
            # Buscar el Loader del app_container
            if self.root:
                # El root es app_container (Window)
                # Buscar el Loader dentro de él
                loader = self.root.findChild(QObject, "viewLoader")
                if loader:
                    # Obtener el item cargado (main.qml)
                    main_item = loader.property("item")
                    if main_item:
                        print("✅ main.qml encontrado")
                        # main_item es el Rectangle con objectName "mainContainer"
                        self.module_manager.set_root_object(main_item)
                    else:
                        print("⚠️ No se pudo obtener el item del Loader")
                else:
                    print("⚠️ No se encontró el Loader viewLoader")
    
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
            0: "dashboard.qml",  # ✅ CORREGIDO: en minúsculas
            1: "usuario_roles.qml",
            2: "productores_parcela.qml",
            3: "cultivos.qml",
            4: "agroquimico.qml",
            5: "ventas_cliente.qml",
            6: "maquinaria.qml",
            7: "configuracion.qml",
            8: "reportesAgricola.qml",
            9: "gastos.qml"
        }
    
    def set_root_object(self, root):
        """Establece el objeto raíz de QML (main.qml Rectangle)"""
        self.root = root
        print(f"✅ Root object establecido: {root}")
        
        # Buscar el contentContainer (Loader)
        self.content_container = self.root.findChild(QObject, "contentContainer")
        if self.content_container:
            print("✅ contentContainer encontrado")
            # ✅ CARGAR EL DASHBOARD POR DEFECTO
            self.change_module(0)
        else:
            print("❌ No se encontró contentContainer")
    
    @Slot(int)
    def change_module(self, module_index):
        """Cambia al módulo especificado"""
        print(f"📂 Cambiando al módulo: {module_index}")
        
        # Obtener el archivo QML correspondiente
        qml_file = self.module_files.get(module_index)
        if not qml_file:
            print(f"❌ No se encontró archivo para módulo {module_index}")
            return
        
        # Verificar que el archivo existe
        if not os.path.exists(qml_file):
            print(f"❌ No existe el archivo {qml_file}")
            return
        
        # Actualizar la propiedad activeModule en el QML
        if self.root:
            self.root.setProperty("activeModule", module_index)
        
        # Cargar el archivo QML en el Loader
        if self.content_container:
            print(f"✅ Cargando {qml_file}...")
            self.content_container.setProperty("source", qml_file)
        else:
            print("❌ contentContainer no disponible")
        
        self._current_module = module_index
        self.moduleChanged.emit(module_index)

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
    
    os.environ["QT_DEBUG_PLUGINS"] = "0"
    
    # Crear el motor QML
    engine = QQmlApplicationEngine()

    
    # Crear el gestor de aplicación
    app_manager = AppManager(engine)
    
    # Crear el controlador de login
    login_controller = LoginController()
    
    # Conectar señal de login exitoso
    login_controller.loginExitoso.connect(app_manager.mostrarMain)
    
    # ============================================
    # REGISTRO DE MODELOS EN CONTEXTO QML
    # ============================================
    
    # Registrar servicios y controladores principales
    engine.rootContext().setContextProperty("appManager", app_manager)
    engine.rootContext().setContextProperty("loginController", login_controller)
    engine.rootContext().setContextProperty("authService", auth_service)
    
    # Crear y registrar modelos existentes
    print("📊 Registrando modelos de datos...")
    
    # Modelo de autenticación - ✅ CORREGIDO
    try:
        auth_model = AutoModel()  # ✅ CORREGIDO: Era AuthModel()
        engine.rootContext().setContextProperty("authModel", auth_model)
        print("✅ AutoModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar AutoModel: {e}")
    
    # Modelo de dashboard
    try:
        dashboard_model = DashboardModel()
        engine.rootContext().setContextProperty("dashboardModel", dashboard_model)
        print("✅ DashboardModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar DashboardModel: {e}")
    
    # Modelo de gastos
    try:
        gastos_model = GastosModel()
        engine.rootContext().setContextProperty("gastosModel", gastos_model)
        print("✅ GastosModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar GastosModel: {e}")
    
    # Modelo de reportes
    try:
        reportes_model = ReportesModel()
        engine.rootContext().setContextProperty("reportesModel", reportes_model)
        print("✅ ReportesModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar ReportesModel: {e}")
    
    # Modelos existentes (mantener compatibilidad)
    try:
        usuario_roles_model = UsuariosRolesModel()
        engine.rootContext().setContextProperty("usuariosRolesModel", usuario_roles_model)
        print("✅ UsuariosRolesModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar UsuariosRolesModel: {e}")
    
    try:
        productores_parcelas_model = ProductoresParcelasModels()
        engine.rootContext().setContextProperty("productoresparcelas", productores_parcelas_model)
        print("✅ ProductoresParcelasModels registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar ProductoresParcelasModels: {e}")
    
    try:
        cultivos_model = CultivosModel()
        engine.rootContext().setContextProperty("cultivos", cultivos_model)
        print("✅ CultivosModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar CultivosModel: {e}")
    
    try:
        agroquimicos_model = AgroquimicosModel()
        engine.rootContext().setContextProperty("agroquimicosModel", agroquimicos_model)
        print("✅ AgroquimicosModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar AgroquimicosModel: {e}")
    
    try:
        ventas_cliente_model = ClientesVentaModel()
        engine.rootContext().setContextProperty("ventaModel", ventas_cliente_model)
        print("✅ ClientesVentaModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar ClientesVentaModel: {e}")
    
    try:
        maquinaria_model = MaquinariaModel()
        engine.rootContext().setContextProperty("maquinariaModel", maquinaria_model)
        print("✅ MaquinariaModel registrado en QML")
    except Exception as e:
        print(f"⚠️ No se pudo registrar MaquinariaModel: {e}")
    
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
    print("📦 Modelos registrados en QML:")
    print("   - authModel (AutoModel)")
    print("   - dashboardModel (DashboardModel)")
    print("   - gastosModel (GastosModel)")
    print("   - reportesModel (ReportesModel)")
    print("   - usuariosRolesModel (UsuariosRolesModel)")
    print("   - productoresparcelas (ProductoresParcelasModels)")
    print("   - cultivos (CultivosModel)")
    print("   - agroquimicosModel (AgroquimicosModel)")
    print("   - ventaModel (ClientesVentaModel)")
    print("   - maquinariaModel (MaquinariaModel)")
    
    # Ejecutar la aplicación
    sys.exit(app.exec())


if __name__ == "__main__":
    main()