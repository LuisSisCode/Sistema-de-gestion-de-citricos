#!/usr/bin/env python3
"""
DIAGNÓSTICO DEL SISTEMA
Verifica dependencias y configuración antes de los tests
"""

import sys
import os
import platform
import subprocess
import importlib

def check_python_version():
    """Verifica la versión de Python"""
    print("🐍 VERSIÓN DE PYTHON:")
    version = sys.version_info
    print(f"   Python {version.major}.{version.minor}.{version.micro}")
    
    if version.major == 3 and version.minor >= 8:
        print("   ✅ Versión compatible")
        return True
    else:
        print("   ⚠️ Versión muy antigua, recomendado Python 3.8+")
        return False

def check_pyside6_installation():
    """Verifica la instalación de PySide6"""
    print("\n📦 PYSIDE6:")
    try:
        import PySide6
        print(f"   ✅ PySide6 instalado: {PySide6.__version__}")
        
        # Verificar módulos específicos
        modules_to_check = [
            ('PySide6.QtCore', 'QtCore'),
            ('PySide6.QtGui', 'QtGui'),
            ('PySide6.QtQml', 'QtQml'),
            ('PySide6.QtWebEngineQuick', 'QtWebEngineQuick'),
            ('PySide6.QtWebEngineCore', 'QtWebEngineCore'),
        ]
        
        missing_modules = []
        for module_name, display_name in modules_to_check:
            try:
                importlib.import_module(module_name)
                print(f"   ✅ {display_name}")
            except ImportError:
                print(f"   ❌ {display_name} - NO DISPONIBLE")
                missing_modules.append(display_name)
        
        if missing_modules:
            print(f"   ⚠️ Módulos faltantes: {', '.join(missing_modules)}")
            print("   💡 Solución: pip install PySide6[webengine]")
            return False
        
        return True
        
    except ImportError:
        print("   ❌ PySide6 NO instalado")
        print("   💡 Solución: pip install PySide6")
        return False

def check_system_info():
    """Información del sistema"""
    print(f"\n💻 SISTEMA OPERATIVO:")
    print(f"   OS: {platform.system()} {platform.release()}")
    print(f"   Arquitectura: {platform.machine()}")
    print(f"   Procesador: {platform.processor()}")
    
    # Variables de entorno relevantes
    print(f"\n🔧 VARIABLES DE ENTORNO:")
    env_vars = [
        'QTWEBENGINE_DISABLE_SANDBOX',
        'QTWEBENGINE_CHROMIUM_FLAGS',
        'QT_LOGGING_RULES'
    ]
    
    for var in env_vars:
        value = os.environ.get(var, 'No configurada')
        print(f"   {var}: {value}")

def check_network_connectivity():
    """Verifica conectividad de red"""
    print(f"\n🌐 CONECTIVIDAD:")
    
    # Verificar conectividad a internet
    try:
        import urllib.request
        urllib.request.urlopen('https://www.google.com', timeout=5)
        print("   ✅ Internet: Conectado")
    except:
        print("   ⚠️ Internet: Sin conexión o muy lenta")
    
    # Verificar puerto localhost
    try:
        import socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex(('localhost', 5001))
        sock.close()
        
        if result == 0:
            print("   ✅ Puerto 5001: En uso (tu aplicación está ejecutándose)")
        else:
            print("   ⚠️ Puerto 5001: Libre (tu aplicación NO está ejecutándose)")
    except:
        print("   ❌ Puerto 5001: Error verificando")

def check_qt_webengine_dependencies():
    """Verifica dependencias específicas de WebEngine"""
    print(f"\n🌐 DEPENDENCIAS WEBENGINE:")
    
    # En Windows, verificar Visual C++ Redistributables
    if platform.system() == 'Windows':
        print("   🪟 Windows detectado")
        print("   ℹ️ WebEngine requiere Visual C++ Redistributables")
        print("   💡 Si hay problemas, instalar desde Microsoft")
    
    # En Linux, sugerir dependencias comunes
    elif platform.system() == 'Linux':
        print("   🐧 Linux detectado")
        print("   ℹ️ WebEngine requiere: libxss1, libnss3, libgconf-2-4")
        print("   💡 Ubuntu/Debian: sudo apt install qtwebengine5-dev")
        print("   💡 Fedora: sudo dnf install qt5-qtwebengine-devel")
    
    # En macOS
    elif platform.system() == 'Darwin':
        print("   🍎 macOS detectado")
        print("   ℹ️ WebEngine generalmente funciona sin dependencias extra")

def run_quick_webengine_test():
    """Test rápido de WebEngine sin interfaz"""
    print(f"\n⚡ TEST RÁPIDO WEBENGINE:")
    
    try:
        # Importar sin crear aplicación
        from PySide6.QtWebEngineQuick import QtWebEngineQuick
        print("   ✅ Importación QtWebEngineQuick: OK")
        
        # Intentar inicializar (esto puede fallar si ya se hizo)
        try:
            QtWebEngineQuick.initialize()
            print("   ✅ Inicialización QtWebEngine: OK")
        except:
            print("   ⚠️ Inicialización QtWebEngine: Ya inicializado o error")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False

def generate_report():
    """Genera reporte de diagnóstico"""
    print("\n" + "="*60)
    print("📋 REPORTE DE DIAGNÓSTICO")
    print("="*60)
    
    results = {
        'python': check_python_version(),
        'pyside6': check_pyside6_installation(),
        'webengine': run_quick_webengine_test()
    }
    
    check_system_info()
    check_network_connectivity()
    check_qt_webengine_dependencies()
    
    print(f"\n🎯 RESUMEN:")
    for component, status in results.items():
        status_icon = "✅" if status else "❌"
        print(f"   {status_icon} {component.title()}")
    
    print(f"\n💡 RECOMENDACIONES:")
    if not results['python']:
        print("   🔧 Actualizar Python a versión 3.8+")
    
    if not results['pyside6']:
        print("   🔧 Instalar/reparar PySide6: pip install --upgrade PySide6")
    
    if not results['webengine']:
        print("   🔧 Problema con WebEngine - usar alternativa MapaSimple")
    
    if all(results.values()):
        print("   🎉 ¡Todo parece estar bien! Procede con los tests")
        print("   ➡️  Ejecuta: python test_webengine_basico.py")
    
    return all(results.values())

def main():
    print("🔍 DIAGNÓSTICO DEL SISTEMA PARA WEBENGINE")
    print("="*60)
    print("Este script verifica que todo esté configurado correctamente")
    print("antes de ejecutar los tests de WebEngine.\n")
    
    success = generate_report()
    
    print(f"\n{'='*60}")
    if success:
        print("✅ DIAGNÓSTICO: Sistema listo para WebEngine")
        print("🚀 SIGUIENTE PASO: Ejecutar test_webengine_basico.py")
    else:
        print("⚠️ DIAGNÓSTICO: Problemas detectados")
        print("🔧 SIGUIENTE PASO: Corregir problemas listados arriba")
    
    return success

if __name__ == "__main__":
    main()