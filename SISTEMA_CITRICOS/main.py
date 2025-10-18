import sys
import os

# ⭐ CRÍTICO: Configurar WebEngine ANTES de cualquier importación Qt
os.environ["QTWEBENGINE_DISABLE_SANDBOX"] = "1"
os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = "--disable-web-security --allow-running-insecure-content --disable-dev-shm-usage"
os.environ["QT_LOGGING_RULES"] = "*.debug=false"
from bd_conecciones.nucleo.cache_system import cache_manager, print_cache_stats, clear_cache
from PySide6.QtCore import QObject, Slot, QUrl, Property, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

# ⭐ IMPORTACIONES WEBENGINE EN ORDEN CORRECTO
from PySide6.QtWebEngineQuick import QtWebEngineQuick
from PySide6.QtWebEngineCore import QWebEngineSettings

from models.usuario_roles_model import UsuariosRolesModel
from models.agricultores_parcelas_model import AgricultoresParcelasModels
from models.cultivos_model import CultivosModel
from models.agroquimicos_model import AgroquimicosModel
from models.maquinaria_model import MaquinariaModel
from models.ventas_cliente_model import ClientesVentaModel
from datetime import datetime

from mapa_service_integrado import inicializar_servicio_mapa, servicio_mapa, obtener_url_mapa

class ModuleManager(QObject):
    """Clase para manejar la navegación entre módulos de la aplicación"""
    
    # Señal para notificar cambios en el módulo activo
    moduleChanged = Signal(int)
    
    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        self.root = None
        
        self._current_module = 0  # Inicialmente en el módulo "Inicio"
        
        # Mapeo de índices de módulos a archivos QML
        self.module_files = {
            0: "inicio.qml",
            1: "usuario_roles.qml", # Esto no va a tener un empleado
            2: "agricultores_parcela.qml",
            3: "cultivos.qml",
            4: "agroquimico.qml",
            5: "ventas_cliente.qml",
            6: "maquinaria.qml",
            7: "configuracion.qml" ,
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
        
        print("Contenedor de contenido encontrado correctamente")
        
        # Conectar los botones
        self.connect_button("btnInicio", 0)
        self.connect_button("btnUsuarios", 1)
        self.connect_button("btnAgricultores", 2)
        self.connect_button("btnCultivos", 3)
        self.connect_button("btnAgroquimicos", 4)
        self.connect_button("btnVentas", 5)
        self.connect_button("btnMaquinaria", 6)
        self.connect_button("btnConfiguracion",7 )
        self.connect_button("btnReportes",8)
        self.connect_button("btnGastos",9)
        
        # Cargar el módulo inicial (inicio_content.qml)
        self.change_module(0)
    
    def connect_button(self, button_id, module_index):
        """Conecta un botón específico para cambiar al módulo correspondiente"""
        button = self.root.findChild(QObject, button_id)
        if button:
            #print(f"Botón {button_id} encontrado, conectando para cargar el módulo {module_index}")
            # Conectar la señal clicked del botón a nuestra función para cambiar el módulo
            button.clicked.connect(lambda: self.change_module(module_index))
        else:
            print(f"Error: No se pudo encontrar el botón {button_id}")
    
    @Slot(int)
    def change_module(self, module_index):
        """Cambia al módulo especificado cargando el archivo QML correspondiente"""
        print(f"Cambiando al módulo: {module_index}")
        
        # Actualizar la propiedad activeModule del QML para cambiar el estilo del botón
        self.root.setProperty("activeModule", module_index)
        
        # Obtener el archivo QML correspondiente al módulo
        qml_file = self.module_files.get(module_index)
        if not qml_file:
            print(f"Error: No se encontró un archivo QML para el módulo {module_index}")
            return
        
        # Verificar que el archivo existe
        if not os.path.exists(qml_file):
            print(f"Error: No se encontró el archivo {qml_file}")
            return
        
        # Cargar el archivo QML en el Loader
        if self.content_container:
            self.content_container.setProperty("source", qml_file)
            #print(f"Módulo {qml_file} cargado correctamente")
        else:
            print("Error: No se pudo acceder al contenedor de contenido")
        
        # Actualizar nuestro propio estado
        self._current_module = module_index
        self.moduleChanged.emit(module_index)

def configurar_webengine_global():
    """Configura WebEngine globalmente para localhost"""
    try:
        
        # Obtener configuración global
        settings = QWebEngineSettings.globalSettings()
        
        # ⭐ Configuraciones críticas para localhost
        settings.setAttribute(QWebEngineSettings.LocalContentCanAccessRemoteUrls, True)
        settings.setAttribute(QWebEngineSettings.LocalContentCanAccessFileUrls, True) 
        settings.setAttribute(QWebEngineSettings.AllowRunningInsecureContent, True)
        settings.setAttribute(QWebEngineSettings.JavascriptEnabled, True)
        settings.setAttribute(QWebEngineSettings.PluginsEnabled, True)
        settings.setAttribute(QWebEngineSettings.LocalStorageEnabled, True)
        
        # Configuraciones adicionales
        if hasattr(QWebEngineSettings, 'AllowWindowActivationFromJavaScript'):
            settings.setAttribute(QWebEngineSettings.AllowWindowActivationFromJavaScript, True)
            
        if hasattr(QWebEngineSettings, 'JavascriptCanOpenWindows'):
            settings.setAttribute(QWebEngineSettings.JavascriptCanOpenWindows, False)
            
        if hasattr(QWebEngineSettings, 'JavascriptCanAccessClipboard'):
            settings.setAttribute(QWebEngineSettings.JavascriptCanAccessClipboard, False)
        
        print("✅ WebEngine configurado globalmente para localhost")
        return True
        
    except Exception as e:
        print(f"⚠️ Error configurando WebEngine globalmente: {e}")
        return False

def inicializar_servicios_mapa():
    """Inicializa el servicio de mapas integrado"""
    print("🚀 Iniciando servicio de mapas integrado...")
    print("📦 Configurando sistema de caché...")
    print("✅ Sistema de caché configurado")
    print("📊 Estadísticas iniciales:")
    print_cache_stats()

    try:
        if inicializar_servicio_mapa():
            print("✅ Servicio de mapas iniciado correctamente")
            print("🗺️ Mapa disponible en: http://localhost:5001/mapa")
            return True
        else:
            print("⚠️ El servicio no se pudo iniciar. El mapa no estará disponible.")
            return False
    except Exception as e:
        print(f"❌ Error iniciando servicio de mapas: {str(e)}")
        return False

def main():
    print("🔧 Configurando WebEngine...")
    
    # ⭐ PASO 1: Configurar argumentos adicionales ANTES de crear QGuiApplication
    # Intentar habilitar compartir contextos OpenGL si está disponible
    try:
        from PySide6.QtCore import Qt
        if hasattr(Qt, 'AA_ShareOpenGLContexts'):
            QGuiApplication.setAttribute(Qt.AA_ShareOpenGLContexts, True)
            print("✅ Contextos OpenGL compartidos habilitados")
        else:
            print("ℹ️ Contextos OpenGL compartidos no disponibles (no crítico)")
    except Exception as e:
        print(f"ℹ️ No se pudo configurar contextos OpenGL: {e} (no crítico)")
    
    # ⭐ PASO 2: Inicializar QtWebEngine ANTES de QGuiApplication
    print("🌐 Inicializando QtWebEngine...")
    try:
        QtWebEngineQuick.initialize()
        print("✅ QtWebEngine inicializado correctamente")
    except Exception as e:
        print(f"⚠️ Error inicializando QtWebEngine: {e}")
        print("🔄 Continuando de todas formas...")
    
    # ⭐ PASO 3: Crear la aplicación CON ARGUMENTOS ESPECÍFICOS
    print("🖥️ Creando aplicación Qt...")
    
    # Argumentos específicos para WebEngine
    args = sys.argv + [
        "--disable-web-security",
        "--allow-running-insecure-content", 
        "--no-sandbox",
        "--disable-dev-shm-usage",
        "--allow-insecure-localhost",
        "--disable-features=VizDisplayCompositor"
    ]
    
    app = QGuiApplication(args)
    
    # ⭐ PASO 4: Configurar WebEngine DESPUÉS de crear app
    print("⚙️ Configurando WebEngine globalmente...")
    configurar_webengine_global()
    
    # Variables de entorno adicionales para debugging (menos verbose)
    os.environ["QT_DEBUG_PLUGINS"] = "0"  # Desactivar debug para menos spam
    
    # Crear el motor QML
    engine = QQmlApplicationEngine()

    # ⭐ PASO 5: Inicializar servicios DESPUÉS de WebEngine pero ANTES de cargar QML
    print("🗺️ Iniciando servicios de mapa...")
    inicializar_servicios_mapa()
    
    # Crear el gestor de módulos
    module_manager = ModuleManager(engine)
    
    # ⭐ PASO 5: Inicializar servicios DESPUÉS de WebEngine pero ANTES de cargar QML
    print("🗺️ Iniciando servicios de mapa...")
    inicializar_servicios_mapa()

    # Crear y registrar modelos
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
    
    maquinaria_model=MaquinariaModel()
    engine.rootContext().setContextProperty("maquinariaModel", maquinaria_model)

    # Verificar archivos
    print(f"📁 Directorio de trabajo: {os.getcwd()}")
    print("📄 Cargando interfaz principal...")
    qml_file_path = "main.qml"
    if not os.path.exists(qml_file_path):
        print(f"❌ Error: No se encontró {qml_file_path}")
        sys.exit(-1)
    
    # ⭐ PASO 6: Cargar QML principal
    print("📄 Cargando interfaz principal...")
    qml_file = QUrl.fromLocalFile(qml_file_path)
    engine.load(qml_file)
    
    # Verificar carga exitosa
    if not engine.rootObjects():
        print("❌ Error: No se pudo cargar el archivo QML principal.")
        sys.exit(-1)
    
    # Configurar el gestor de módulos
    root_object = engine.rootObjects()[0]
    module_manager.set_root_object(root_object)
    
    print("🎉 Aplicación iniciada correctamente")
    print("🔍 Si tienes problemas con el mapa, ve a la pestaña 'Mapa' y verifica los mensajes")
    def limpiar_cache():
        """Función útil para desarrollo - limpiar caché"""
        clear_cache()

    def mostrar_estadisticas_cache():
        """Muestra estadísticas del caché"""
        print_cache_stats()
    # Ejecutar la aplicación
    sys.exit(app.exec())
    print("\n📊 Estadísticas finales del caché:")
    print_cache_stats()

if __name__ == "__main__":
    main()