# init_cache.py - VERSIÓN SIMPLE

from bd_conecciones.repositorios.Agriculor_Parcelas_rep.agricultor_repositorio import AgricultorRepositorio
from bd_conecciones.bd_clientes import GestorClientes
from bd_conecciones.bd_ventas import GestorVentas
from bd_conecciones.nucleo.cache_system import cache_manager, print_cache_stats

def setup_cache_para_main():
    """Función simple para inicializar todo"""
    print("🚀 Inicializando sistema con caché...")
    
    # Crear todos los gestores
    gestores = {}
    
    try:
        gestores['agricultor_repo'] = AgricultorRepositorio("DESKTOP-NVQ729A", "Producto_CitricosS")
        print("   ✅ Agricultor repositorio")
    except Exception as e:
        print(f"   ❌ Agricultor repositorio: {e}")
    
    try:
        gestores['clientes'] = GestorClientes("DESKTOP-NVQ729A", "Producto_CitricosS")
        print("   ✅ Gestor clientes")
    except Exception as e:
        print(f"   ❌ Gestor clientes: {e}")
    
    try:
        gestores['ventas'] = GestorVentas("DESKTOP-NVQ729A", "Producto_CitricosS")
        print("   ✅ Gestor ventas")
    except Exception as e:
        print(f"   ❌ Gestor ventas: {e}")
    
    # Calentar caché con datos básicos
    if 'agricultor_repo' in gestores:
        try:
            gestores['agricultor_repo'].obtener_todos()
            print("   🔥 Caché de agricultores calentado")
        except:
            pass
    
    print("✅ Sistema de caché listo")
    print_cache_stats()
    
    return gestores