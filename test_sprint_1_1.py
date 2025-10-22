# test_sprint_1_1.py
"""
Script de pruebas para Sprint 1.1 - Configuración y Utilidades
"""

def test_config():
    """Prueba el módulo de configuración"""
    print("\n" + "="*60)
    print("🧪 TEST 1: Config")
    print("="*60)
    
    try:
        from backend.core.config import Config
        
        print(f"✅ Config importado correctamente")
        print(f"   📍 BD: {Config.DB_SERVER}/{Config.DB_DATABASE}")
        print(f"   🔗 Connection string: {Config.get_db_connection_string()[:50]}...")
        print(f"   🏢 Empresa: {Config.EMPRESA_NOMBRE}")
        print(f"   💰 Moneda: {Config.MONEDA}")
        print(f"   🆕 ¿Primera vez? {Config.is_first_time()}")
        
        return True
    except Exception as e:
        print(f"❌ Error en Config: {e}")
        return False


def test_config_manager():
    """Prueba el gestor de configuración"""
    print("\n" + "="*60)
    print("🧪 TEST 2: ConfigManager")
    print("="*60)
    
    try:
        from backend.core.config_manager import ConfigManager
        
        manager = ConfigManager()
        print(f"✅ ConfigManager importado correctamente")
        print(f"   📂 Ubicación .env: {manager.env_file}")
        print(f"   📋 ¿Existe .env? {manager.existe_configuracion()}")
        print(f"   🆕 ¿Es primera vez? {manager.es_primera_vez()}")
        
        if manager.existe_configuracion():
            config = manager.leer_configuracion()
            print(f"   📊 Valores cargados: {len(config)}")
        
        return True
    except Exception as e:
        print(f"❌ Error en ConfigManager: {e}")
        return False


def test_database():
    """Prueba la conexión a base de datos"""
    print("\n" + "="*60)
    print("🧪 TEST 3: Database")
    print("="*60)
    
    try:
        from backend.core.database import DatabaseConnection
        
        db = DatabaseConnection()
        print(f"✅ DatabaseConnection importado correctamente")
        print(f"   📍 Servidor: {db.server}")
        print(f"   💾 Base de datos: {db.database}")
        
        # Verificar si BD existe
        existe = db.database_exists()
        print(f"   🔍 ¿BD existe? {existe}")
        
        # Probar conexión solo si BD existe
        if existe:
            exito, mensaje = db.test_connection()
            print(f"   🔗 Conexión: {'✅' if exito else '❌'} {mensaje}")
        
        return True
    except Exception as e:
        print(f"❌ Error en Database: {e}")
        return False


def test_db_installer():
    """Prueba el instalador de BD"""
    print("\n" + "="*60)
    print("🧪 TEST 4: DatabaseInstaller")
    print("="*60)
    
    try:
        from backend.core.db_installer import DatabaseInstaller
        
        installer = DatabaseInstaller()
        print(f"✅ DatabaseInstaller importado correctamente")
        print(f"   📁 Dir scripts: {installer.scripts_dir}")
        print(f"   📜 Schema script: {installer.schema_script.name}")
        
        # Verificar SQL Server (sin crear BD)
        from backend.core.config import Config
        disponible, mensaje = installer.verificar_sql_server(Config.DB_SERVER)
        print(f"   🔍 SQL Server: {'✅' if disponible else '❌'} {mensaje[:50]}...")
        
        return True
    except Exception as e:
        print(f"❌ Error en DatabaseInstaller: {e}")
        return False


def test_validators():
    """Prueba las validaciones"""
    print("\n" + "="*60)
    print("🧪 TEST 5: Validators")
    print("="*60)
    
    try:
        from utils.validators import (
            validar_email,
            validar_identificacion,
            validar_telefono,
            validar_area,
            validar_precio
        )
        
        print(f"✅ Validators importados correctamente")
        
        # Probar validaciones
        tests = [
            ("Email válido", validar_email("admin@agroichilo.com")),
            ("Email inválido", validar_email("invalido")),
            ("Identificación válida", validar_identificacion("12345678")),
            ("Teléfono válido", validar_telefono("71234567")),
            ("Área válida", validar_area(10.5)),
            ("Precio válido", validar_precio(150.50)),
        ]
        
        for nombre, (valido, mensaje) in tests:
            icono = "✅" if valido else "❌"
            print(f"   {icono} {nombre}: {mensaje}")
        
        return True
    except Exception as e:
        print(f"❌ Error en Validators: {e}")
        return False


def test_formatters():
    """Prueba los formateadores"""
    print("\n" + "="*60)
    print("🧪 TEST 6: Formatters")
    print("="*60)
    
    try:
        from utils.formatters import (
            formatear_moneda,
            formatear_fecha,
            formatear_telefono,
            formatear_area
        )
        from datetime import datetime
        
        print(f"✅ Formatters importados correctamente")
        
        # Probar formateos
        print(f"   💰 Moneda: {formatear_moneda(1500.50)}")
        print(f"   📅 Fecha: {formatear_fecha(datetime.now())}")
        print(f"   📞 Teléfono: {formatear_telefono('71234567')}")
        print(f"   📏 Área: {formatear_area(25.5)}")
        
        return True
    except Exception as e:
        print(f"❌ Error en Formatters: {e}")
        return False


def ejecutar_todas_las_pruebas():
    """Ejecuta todas las pruebas del Sprint 1.1"""
    print("\n" + "="*60)
    print("🚀 PRUEBAS DEL SPRINT 1.1 - AGROICHILO")
    print("="*60)
    
    resultados = []
    
    # Ejecutar tests
    resultados.append(("Config", test_config()))
    resultados.append(("ConfigManager", test_config_manager()))
    resultados.append(("Database", test_database()))
    resultados.append(("DatabaseInstaller", test_db_installer()))
    resultados.append(("Validators", test_validators()))
    resultados.append(("Formatters", test_formatters()))
    
    # Resumen final
    print("\n" + "="*60)
    print("📊 RESUMEN DE PRUEBAS")
    print("="*60)
    
    exitosos = sum(1 for _, exito in resultados if exito)
    total = len(resultados)
    
    for nombre, exito in resultados:
        icono = "✅" if exito else "❌"
        print(f"   {icono} {nombre:20} {'PASS' if exito else 'FAIL'}")
    
    print(f"\n   🎯 Resultado: {exitosos}/{total} pruebas exitosas")
    
    if exitosos == total:
        print("\n   ✨ ¡SPRINT 1.1 COMPLETADO EXITOSAMENTE! ✨")
    else:
        print(f"\n   ⚠️  {total - exitosos} prueba(s) fallida(s)")
    
    print("="*60 + "\n")


if __name__ == "__main__":
    ejecutar_todas_las_pruebas()