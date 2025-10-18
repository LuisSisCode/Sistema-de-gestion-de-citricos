# main_test.py - Prueba específica para el mapa interactivo
import sys
import os
import time

# 1. Configuración crítica para WebEngine DEBE estar primero
os.environ["QTWEBENGINE_DISABLE_SANDBOX"] = "1"
os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = "--disable-web-security --allow-running-insecure-content --disable-dev-shm-usage --ignore-certificate-errors"
os.environ["QT_LOGGING_RULES"] = "qt.*=false"

# 2. Importar Qt después de las variables de entorno
from PySide6.QtCore import Qt, QUrl
from PySide6.QtWidgets import QApplication, QMainWindow
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWebEngineQuick import QtWebEngineQuick
from PySide6.QtQuick import QQuickWindow
from PySide6.QtQuickControls2 import QQuickStyle

# 3. Importar el servicio de mapas
from mapa_service_integrado import inicializar_servicio_mapa, servicio_mapa

def main():
    print("🚀 Iniciando prueba específica para el mapa interactivo...")
    
    # 4. Inicializar WebEngine
    try:
        QtWebEngineQuick.initialize()
        print("✅ QtWebEngine inicializado")
    except Exception as e:
        print(f"⚠️ Error inicializando WebEngine: {e}")
    
    # 5. Crear aplicación
    app = QApplication(sys.argv)
    QQuickStyle.setStyle("Basic")
    
    # 6. Iniciar servicio de mapas en un hilo separado
    print("🌐 Iniciando servicio de mapas...")
    if inicializar_servicio_mapa():
        print("✅ Servicio de mapas iniciado")
        print(f"🗺️ URL del mapa: {servicio_mapa.obtener_url_mapa()}")
    else:
        print("⚠️ No se pudo iniciar servicio de mapas")
        sys.exit(1)
    
    # 7. Crear ventana principal
    window = QQuickWindow()
    window.setTitle("Mapa Interactivo")
    window.resize(1200, 800)
    
    # 8. Configurar el motor QML
    engine = QQmlApplicationEngine()
    
    # 9. Cargar el componente QML
    qml_file = os.path.abspath("MapaInteractivo.qml")
    if not os.path.exists(qml_file):
        print(f"❌ Error: No se encontró {qml_file}")
        sys.exit(1)
    
    print(f"📄 Cargando componente: {qml_file}")
    engine.load(QUrl.fromLocalFile(qml_file))
    
    # 10. Verificar carga exitosa
    if not engine.rootObjects():
        print("❌ Error: No se pudo cargar el componente QML")
        sys.exit(1)
    
    # 11. Conectar el componente a la ventana
    root = engine.rootObjects()[0]
    root.setParentItem(window.contentItem())
    
    # 12. Forzar visualización
    window.show()
    window.raise_()
    window.requestActivate()
    
    print("✅ Prueba iniciada. Debería verse la ventana con el mapa")
    print("🔍 Si no se ve, verifique si hay ventanas ocultas o minimizadas")
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()