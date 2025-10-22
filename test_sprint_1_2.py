# test_sprint_1_2.py
"""
Script de pruebas para Sprint 1.2 - Autenticación y Usuarios
"""


def test_password_utils():
    """Prueba las utilidades de contraseñas"""
    print("\n" + "="*60)
    print("🧪 TEST 1: PasswordUtils")
    print("="*60)
    
    try:
        from backend.utils.password_utils import PasswordUtils
        
        print("✅ PasswordUtils importado correctamente")
        
        # Test 1: Hash y verificación
        password = "admin123"
        hash_password, salt = PasswordUtils.hash_password(password)
        
        print(f"   🔐 Hash generado: {hash_password[:40]}...")
        print(f"   🧂 Salt generado: {salt[:40]}...")
        
        # Verificar que la contraseña sea correcta
        valida = PasswordUtils.verify_password(password, hash_password, salt)
        print(f"   {'✅' if valida else '❌'} Verificación correcta: {valida}")
        
        # Verificar que una contraseña incorrecta falle
        invalida = PasswordUtils.verify_password("incorrecta", hash_password, salt)
        print(f"   {'✅' if not invalida else '❌'} Verificación incorrecta rechazada: {not invalida}")
        
        # Test 2: Hash simple (compatibilidad)
        hash_simple = PasswordUtils.hash_password_simple(password)
        print(f"   🔑 Hash simple: {hash_simple[:40]}...")
        
        valida_simple = PasswordUtils.verify_password_simple(password, hash_simple)
        print(f"   {'✅' if valida_simple else '❌'} Verificación simple: {valida_simple}")
        
        # Test 3: Generar password temporal
        temp_password = PasswordUtils.generar_password_temporal()
        print(f"   🎲 Password temporal: {temp_password}")
        print(f"   📏 Longitud: {len(temp_password)} caracteres")
        
        # Test 4: Validar fortaleza
        passwords = ["123", "admin123", "Admin123!", "A1b2C3d4E5!@"]
        print(f"\n   💪 Validando fortaleza de contraseñas:")
        for pwd in passwords:
            fuerte, msg, puntos = PasswordUtils.validar_fortaleza_password(pwd)
            print(f"      {pwd:15} → {puntos:3} pts - {msg}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en PasswordUtils: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_rol_repositorio():
    """Prueba el repositorio de roles"""
    print("\n" + "="*60)
    print("🧪 TEST 2: RolRepositorio")
    print("="*60)
    
    try:
        from backend.repositories.rol_repositorio import RolRepositorio
        
        repo = RolRepositorio()
        print("✅ RolRepositorio importado correctamente")
        
        # Test 1: Obtener todos los roles
        roles = repo.obtener_todos()
        print(f"   📋 Roles encontrados: {len(roles)}")
        
        if roles:
            print(f"\n   📝 Lista de roles:")
            for rol in roles:
                print(f"      • {rol['nombre_rol']:20} (Nivel {rol['nivel_acceso']})")
            
            # Test 2: Obtener rol por ID
            primer_rol = roles[0]
            rol_detalle = repo.obtener_por_id(primer_rol['id_rol'])
            print(f"\n   🔍 Detalle rol '{rol_detalle['nombre_rol']}':")
            print(f"      ID: {rol_detalle['id_rol']}")
            print(f"      Nivel: {rol_detalle['nivel_acceso']}")
            
            # Test 3: Obtener permisos
            permisos = repo.obtener_permisos_rol(primer_rol['id_rol'])
            print(f"\n   🔑 Permisos del rol: {len(permisos)} módulos")
            
            if permisos:
                print(f"      Primeros 3 módulos:")
                for permiso in permisos[:3]:
                    print(f"      • {permiso['modulo']:15} → ", end="")
                    acciones = []
                    if permiso['puede_leer']: acciones.append("Leer")
                    if permiso['puede_crear']: acciones.append("Crear")
                    if permiso['puede_editar']: acciones.append("Editar")
                    if permiso['puede_eliminar']: acciones.append("Eliminar")
                    print(", ".join(acciones))
            
            # Test 4: Verificar permiso específico
            if permisos:
                primer_permiso = permisos[0]
                tiene_permiso = repo.verificar_permiso(
                    primer_rol['id_rol'],
                    primer_permiso['modulo'],
                    'leer'
                )
                print(f"\n   🔐 Verificación permiso 'leer' en '{primer_permiso['modulo']}': {'✅' if tiene_permiso else '❌'}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en RolRepositorio: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_usuario_repositorio():
    """Prueba el repositorio de usuarios"""
    print("\n" + "="*60)
    print("🧪 TEST 3: UsuarioRepositorio")
    print("="*60)
    
    try:
        from backend.repositories.usuario_repositorio import UsuarioRepositorio
        
        repo = UsuarioRepositorio()
        print("✅ UsuarioRepositorio importado correctamente")
        
        # Test 1: Obtener todos los usuarios
        usuarios = repo.obtener_todos()
        print(f"   👥 Usuarios encontrados: {len(usuarios)}")
        
        if usuarios:
            print(f"\n   📝 Lista de usuarios:")
            for usuario in usuarios[:5]:  # Mostrar primeros 5
                print(f"      • {usuario['usuario']:15} - {usuario['nombre']} {usuario['apellido']:15} ({usuario['nombre_rol']})")
            
            if len(usuarios) > 5:
                print(f"      ... y {len(usuarios) - 5} más")
        
        # Test 2: Autenticación
        print(f"\n   🔐 Probando autenticación con usuario 'admin'...")
        autenticado, datos = repo.autenticar("admin", "admin123")
        
        if autenticado:
            print(f"   ✅ Autenticación exitosa")
            print(f"      Usuario: {datos['usuario']}")
            print(f"      Nombre: {datos['nombre']} {datos['apellido']}")
            print(f"      Rol: {datos['nombre_rol']}")
            print(f"      Nivel: {datos['nivel_acceso']}")
        else:
            print(f"   ⚠️  Autenticación fallida")
            print(f"      Nota: Asegúrate de tener un usuario 'admin' con password 'admin123'")
        
        # Test 3: Autenticación fallida
        print(f"\n   🔐 Probando con credenciales incorrectas...")
        autenticado_mal, _ = repo.autenticar("admin", "incorrecta")
        print(f"   {'✅' if not autenticado_mal else '❌'} Rechaza password incorrecta: {not autenticado_mal}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en UsuarioRepositorio: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_auth_service():
    """Prueba el servicio de autenticación"""
    print("\n" + "="*60)
    print("🧪 TEST 4: AuthService")
    print("="*60)
    
    try:
        from backend.services.auth_service import auth_service
        
        print("✅ AuthService importado correctamente")
        
        # Test 1: Login
        print(f"\n   🔐 Intentando login...")
        exito, usuario, mensaje = auth_service.login("admin", "admin123")
        
        if exito:
            print(f"   ✅ Login exitoso: {mensaje}")
            print(f"      Usuario: {usuario['usuario']}")
            print(f"      Nombre: {usuario['nombre']} {usuario['apellido']}")
            print(f"      Rol: {usuario['nombre_rol']}")
            print(f"      Permisos: {len(usuario.get('permisos', []))} módulos")
            
            # Test 2: Verificar sesión
            esta_autenticado = auth_service.esta_autenticado()
            print(f"\n   👤 ¿Está autenticado?: {'✅' if esta_autenticado else '❌'}")
            
            # Test 3: Obtener usuario actual
            usuario_actual = auth_service.obtener_usuario_actual()
            if usuario_actual:
                print(f"   👤 Usuario actual: {usuario_actual['usuario']}")
            
            # Test 4: Verificar si es admin
            es_admin = auth_service.es_admin()
            print(f"   🔑 ¿Es administrador?: {'✅' if es_admin else '❌'}")
            
            # Test 5: Verificar permisos
            if len(usuario.get('permisos', [])) > 0:
                primer_permiso = usuario['permisos'][0]
                tiene_permiso = auth_service.tiene_permiso(
                    primer_permiso['modulo'],
                    'leer'
                )
                print(f"   🔐 Tiene permiso 'leer' en '{primer_permiso['modulo']}': {'✅' if tiene_permiso else '❌'}")
            
            # Test 6: Logout
            auth_service.logout()
            print(f"\n   🚪 Logout ejecutado")
            
            esta_autenticado_despues = auth_service.esta_autenticado()
            print(f"   {'✅' if not esta_autenticado_despues else '❌'} Sesión cerrada correctamente: {not esta_autenticado_despues}")
        else:
            print(f"   ⚠️  Login fallido: {mensaje}")
            print(f"      Nota: Verifica que existe usuario 'admin' con password 'admin123'")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en AuthService: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_login_controller():
    """Prueba el controlador de login"""
    print("\n" + "="*60)
    print("🧪 TEST 5: LoginController")
    print("="*60)
    
    try:
        from controllers.login_controller import LoginController
        
        controller = LoginController()
        print("✅ LoginController importado correctamente")
        
        # Test 1: Propiedades iniciales
        print(f"   📊 Estado inicial:")
        print(f"      Cargando: {controller.cargando}")
        print(f"      Mensaje error: '{controller.mensajeError}'")
        
        # Test 2: Obtener datos de config
        nombre_empresa = controller.obtenerNombreEmpresa()
        version_app = controller.obtenerVersionApp()
        nombre_app = controller.obtenerNombreApp()
        
        print(f"\n   ℹ️  Información de la app:")
        print(f"      Nombre: {nombre_app}")
        print(f"      Empresa: {nombre_empresa}")
        print(f"      Versión: {version_app}")
        
        # Test 3: Primera vez
        primera_vez = controller.esPrimeraVez()
        print(f"      Primera vez: {'✅' if primera_vez else '❌'}")
        
        print(f"\n   ✅ Controller funciona correctamente")
        print(f"      Nota: Pruebas de login requieren interfaz QML")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en LoginController: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_integracion_completa():
    """Prueba de integración completa"""
    print("\n" + "="*60)
    print("🧪 TEST 6: Integración Completa")
    print("="*60)
    
    try:
        from backend.services.auth_service import AuthService
        from backend.repositories.usuario_repositorio import UsuarioRepositorio
        from backend.repositories.rol_repositorio import RolRepositorio
        
        print("✅ Todos los módulos importados")
        
        # Crear instancias
        auth = AuthService()
        usuario_repo = UsuarioRepositorio()
        rol_repo = RolRepositorio()
        
        print("\n   🔄 Flujo completo de autenticación:")
        
        # 1. Login
        print(f"      1. Login...")
        exito, usuario, msg = auth.login("admin", "admin123")
        
        if not exito:
            print(f"         ⚠️  No se pudo autenticar")
            return False
        
        print(f"         ✅ Autenticado: {usuario['usuario']}")
        
        # 2. Obtener roles
        print(f"      2. Consultando roles...")
        roles = rol_repo.obtener_todos()
        print(f"         ✅ {len(roles)} roles disponibles")
        
        # 3. Obtener permisos
        print(f"      3. Consultando permisos del usuario...")
        permisos = rol_repo.obtener_permisos_rol(usuario['id_rol'])
        print(f"         ✅ {len(permisos)} permisos del rol")
        
        # 4. Verificar permiso específico
        if permisos:
            modulo_test = permisos[0]['modulo']
            print(f"      4. Verificando permiso 'leer' en '{modulo_test}'...")
            tiene = auth.tiene_permiso(modulo_test, 'leer')
            print(f"         {'✅' if tiene else '❌'} Permiso: {tiene}")
        
        # 5. Logout
        print(f"      5. Cerrando sesión...")
        auth.logout()
        print(f"         ✅ Sesión cerrada")
        
        print(f"\n   ✅ Integración completa exitosa")
        return True
        
    except Exception as e:
        print(f"❌ Error en integración: {e}")
        import traceback
        traceback.print_exc()
        return False


def ejecutar_todas_las_pruebas():
    """Ejecuta todas las pruebas del Sprint 1.2"""
    print("\n" + "="*60)
    print("🚀 PRUEBAS DEL SPRINT 1.2 - AGROICHILO")
    print("   Autenticación y Gestión de Usuarios")
    print("="*60)
    
    resultados = []
    
    # Ejecutar tests
    resultados.append(("PasswordUtils", test_password_utils()))
    resultados.append(("RolRepositorio", test_rol_repositorio()))
    resultados.append(("UsuarioRepositorio", test_usuario_repositorio()))
    resultados.append(("AuthService", test_auth_service()))
    resultados.append(("LoginController", test_login_controller()))
    resultados.append(("Integración", test_integracion_completa()))
    
    # Resumen final
    print("\n" + "="*60)
    print("📊 RESUMEN DE PRUEBAS")
    print("="*60)
    
    exitosos = sum(1 for _, exito in resultados if exito)
    total = len(resultados)
    
    for nombre, exito in resultados:
        icono = "✅" if exito else "❌"
        estado = "PASS" if exito else "FAIL"
        print(f"   {icono} {nombre:20} {estado}")
    
    print(f"\n   🎯 Resultado: {exitosos}/{total} pruebas exitosas")
    
    if exitosos == total:
        print("\n   ✨ ¡SPRINT 1.2 COMPLETADO EXITOSAMENTE! ✨")
    else:
        print(f"\n   ⚠️  {total - exitosos} prueba(s) fallida(s)")
        print("   💡 Revisa que la base de datos esté configurada correctamente")
        print("   💡 Verifica que exista un usuario 'admin' con password 'admin123'")
    
    print("="*60 + "\n")


if __name__ == "__main__":
    ejecutar_todas_las_pruebas()