# cache_config.py - Configurador avanzado del sistema de caché

import pyodbc
import logging
import time
import threading
from datetime import datetime, timedelta
from .cache_system import cacheable, cache_invalidator, get_ttl, cache_manager, TTL_CONFIG

class CacheConfigurator:
    """
    Configurador avanzado para el sistema de caché de la aplicación.
    Proporciona herramientas de configuración, monitoreo y optimización.
    """
    
    def __init__(self):
        """Inicializa el configurador de caché"""
        self.logger = logging.getLogger('CacheConfigurator')
        self.stats_iniciales = None
        self.monitoring_active = False
    
    def configurar_cache_aplicacion(self):
        """Configuración inicial completa del caché para la aplicación"""
        print("🚀 CONFIGURANDO SISTEMA DE CACHÉ AVANZADO")
        print("="*50)
        
        # 1. Configurar logging
        self._configurar_logging()
        
        # 2. Mostrar configuración TTL
        self._mostrar_configuracion_ttl()
        
        # 3. Configurar dependencias (simulado - tu CacheManager no tiene este método)
        self._configurar_dependencias()
        
        # 4. Configurar limpieza automática
        self._configurar_limpieza_automatica()
        
        # 5. Configurar estadísticas iniciales
        self.stats_iniciales = cache_manager.get_stats()
        
        print("✅ Sistema de caché configurado completamente")
        return cache_manager
    
    def _configurar_logging(self):
        """Configura el logging para el sistema de caché"""
        cache_logger = logging.getLogger('CacheManager')
        cache_logger.setLevel(logging.INFO)
        
        # Handler para consola (opcional)
        if not cache_logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter('%(asctime)s - CACHE - %(levelname)s - %(message)s')
            handler.setFormatter(formatter)
            cache_logger.addHandler(handler)
        
        print("✅ Logging de caché configurado")
    
    def _mostrar_configuracion_ttl(self):
        """Muestra la configuración de TTL por módulo"""
        print("\n⚙️ CONFIGURACIÓN TTL (Tiempo de Vida):")
        print("-" * 40)
        
        for modulo, ttl in TTL_CONFIG.items():
            minutos = ttl // 60
            horas = minutos // 60
            
            if horas > 0:
                tiempo_str = f"{horas}h {minutos % 60}min"
            else:
                tiempo_str = f"{minutos}min"
            
            print(f"   📦 {modulo:20} → {ttl:4}s ({tiempo_str})")
    
    def _configurar_dependencias(self):
        """Configura las dependencias entre módulos (simulado)"""
        # Como tu CacheManager no tiene add_dependency, solo mostramos la configuración
        dependencias = {
            'productores': ['parcelas', 'estadisticas'],
            'parcelas': ['estadisticas'],
            'clientes': ['ventas', 'estadisticas'],
            'ventas': ['estadisticas', 'reportes'],
            'cultivos': ['variedades', 'ciclos'],
            'variedades': ['ciclos', 'ventas'],
            'maquinaria': ['uso_maquinaria', 'mantenimientos'],
            'usuarios': ['estadisticas'],
            'roles': ['usuarios', 'permisos'],
        }
        
        print(f"\n🔗 DEPENDENCIAS CONFIGURADAS:")
        for dependency, dependents in dependencias.items():
            print(f"   📦 {dependency} → {', '.join(dependents)}")
        
        print(f"✅ Dependencias mapeadas: {len(dependencias)} módulos")
        
        # Guardar para invalidación en cascada
        self.dependencias = dependencias
    
    def _configurar_limpieza_automatica(self):
        """Configura la limpieza automática del caché"""
        print("✅ Limpieza automática: TTL configurado por módulo")
        print("   🕒 Los datos expirarán automáticamente según su TTL")
    
    def invalidar_en_cascada(self, modulo_principal):
        """
        Invalida un módulo y sus dependencias en cascada
        
        Args:
            modulo_principal (str): Módulo principal a invalidar
        """
        try:
            # Invalidar el módulo principal
            cache_manager.invalidate(modulo_principal)
            invalidados = [modulo_principal]
            
            # Invalidar dependencias
            if hasattr(self, 'dependencias'):
                for modulo, dependencias in self.dependencias.items():
                    if modulo_principal in dependencias:
                        cache_manager.invalidate(modulo)
                        invalidados.append(modulo)
            
            self.logger.info(f"🔄 Invalidación en cascada: {' → '.join(invalidados)}")
            print(f"🔄 Invalidados: {', '.join(invalidados)}")
            
        except Exception as e:
            self.logger.error(f"❌ Error en invalidación cascada: {e}")
    
    def warm_cache_completo(self, repositorios_dict):
        """
        Calienta el caché con datos esenciales de todos los módulos
        
        Args:
            repositorios_dict (dict): Diccionario con repositorios {nombre: instancia}
        """
        print("\n🔥 CALENTANDO CACHÉ COMPLETO...")
        print("-" * 30)
        
        calentados = 0
        errores = 0
        
        # Orden de prioridad para calentar caché
        orden_calentamiento = [
            'usuarios',
            'roles', 
            'productores',
            'clientes',
            'cultivos',
            'variedades',
            'parcelas',
            'maquinaria',
            'agroquimicos',
            'ventas',
            'estadisticas'
        ]
        
        for modulo in orden_calentamiento:
            if modulo in repositorios_dict:
                try:
                    repo = repositorios_dict[modulo]
                    
                    # Intentar calentar con métodos comunes
                    if hasattr(repo, 'obtener_todos'):
                        datos = repo.obtener_todos()
                        count = len(datos) if isinstance(datos, list) else 'OK'
                        print(f"   ✅ {modulo:15} → {count}")
                        calentados += 1
                    elif hasattr(repo, 'obtener_usuarios'):
                        datos = repo.obtener_usuarios()
                        print(f"   ✅ {modulo:15} → {len(datos)} registros")
                        calentados += 1
                    elif hasattr(repo, 'obtener_clientes'):
                        datos = repo.obtener_clientes()
                        print(f"   ✅ {modulo:15} → {len(datos)} registros")
                        calentados += 1
                    elif hasattr(repo, 'obtener_ventas'):
                        datos = repo.obtener_ventas()
                        print(f"   ✅ {modulo:15} → {len(datos)} registros")
                        calentados += 1
                    else:
                        print(f"   ⚠️ {modulo:15} → Sin método conocido")
                        
                except Exception as e:
                    print(f"   ❌ {modulo:15} → Error: {str(e)[:30]}...")
                    errores += 1
        
        print(f"\n🔥 Calentamiento completado:")
        print(f"   ✅ Exitosos: {calentados}")
        print(f"   ❌ Errores: {errores}")
        
        # Mostrar estadísticas finales
        stats = cache_manager.get_stats()
        with cache_manager._lock:
            total_keys = sum(len(keys) for keys in cache_manager._cache.values())
            print(f"   📊 Total claves en caché: {total_keys}")
    
    def monitorear_rendimiento(self, duracion_minutos=5):
        """
        Monitorea el rendimiento del caché por un tiempo determinado
        
        Args:
            duracion_minutos (int): Duración del monitoreo en minutos
        """
        print(f"\n📊 MONITOREANDO CACHÉ POR {duracion_minutos} MINUTOS")
        print("=" * 50)
        print("Presiona Ctrl+C para detener antes...")
        
        inicio = time.time()
        fin = inicio + (duracion_minutos * 60)
        
        stats_inicial = cache_manager.get_stats()
        self.monitoring_active = True
        
        try:
            while time.time() < fin and self.monitoring_active:
                time.sleep(10)  # Revisar cada 10 segundos
                
                stats_actual = cache_manager.get_stats()
                
                # Calcular diferencias
                hits_diff = stats_actual['hits'] - stats_inicial['hits']
                misses_diff = stats_actual['misses'] - stats_inicial['misses']
                
                if hits_diff > 0 or misses_diff > 0:
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] "
                          f"Hits: +{hits_diff}, Misses: +{misses_diff}, "
                          f"Hit Rate: {stats_actual['hit_rate']:.1f}%")
                
        except KeyboardInterrupt:
            print("\n⏹️ Monitoreo detenido por el usuario")
        
        self.monitoring_active = False
        
        # Estadísticas finales
        stats_final = cache_manager.get_stats()
        print(f"\n📈 RESUMEN DE RENDIMIENTO:")
        print(f"   Total Hits: {stats_final['hits']} (+{stats_final['hits'] - stats_inicial['hits']})")
        print(f"   Total Misses: {stats_final['misses']} (+{stats_final['misses'] - stats_inicial['misses']})")
        print(f"   Hit Rate Final: {stats_final['hit_rate']:.1f}%")
        print(f"   Invalidaciones: {stats_final['invalidations']}")
    
    def detener_monitoreo(self):
        """Detiene el monitoreo activo"""
        self.monitoring_active = False
    
    def generar_reporte_cache(self):
        """Genera un reporte completo del estado del caché"""
        print("\n📋 REPORTE COMPLETO DEL CACHÉ")
        print("=" * 40)
        
        stats = cache_manager.get_stats()
        
        # Estadísticas generales
        print(f"📊 ESTADÍSTICAS GENERALES:")
        print(f"   Hits: {stats['hits']}")
        print(f"   Misses: {stats['misses']}")
        print(f"   Hit Rate: {stats['hit_rate']:.2f}%")
        print(f"   Invalidaciones: {stats['invalidations']}")
        
        # Eficiencia
        total_requests = stats['hits'] + stats['misses']
        if total_requests > 0:
            eficiencia = (stats['hits'] / total_requests) * 100
            print(f"   Eficiencia: {eficiencia:.1f}%")
        
        # Namespaces activos
        with cache_manager._lock:
            if cache_manager._cache:
                print(f"\n📦 MÓDULOS EN CACHÉ:")
                total_keys = 0
                for namespace, data in cache_manager._cache.items():
                    keys_count = len(data)
                    total_keys += keys_count
                    
                    # Calcular memoria aproximada
                    memoria_aprox = self._estimar_memoria_namespace(namespace, data)
                    
                    print(f"   {namespace:20} → {keys_count:3} claves ({memoria_aprox})")
                
                print(f"\n   TOTAL CLAVES: {total_keys}")
            else:
                print(f"\n📦 Sin datos en caché")
        
        # Análisis de TTL
        self._analizar_ttl_activos()
        
        # Recomendaciones
        self._generar_recomendaciones(stats)
    
    def _estimar_memoria_namespace(self, namespace, data):
        """Estima el uso de memoria de un namespace"""
        try:
            import sys
            total_size = sys.getsizeof(data)
            
            # Convertir a unidades legibles
            if total_size < 1024:
                return f"{total_size}B"
            elif total_size < 1024 * 1024:
                return f"{total_size/1024:.1f}KB"
            else:
                return f"{total_size/(1024*1024):.1f}MB"
        except:
            return "~KB"
    
    def _analizar_ttl_activos(self):
        """Analiza los TTL de las claves activas"""
        print(f"\n⏰ ANÁLISIS TTL:")
        
        with cache_manager._lock:
            if not cache_manager._metadata:
                print("   Sin metadatos TTL disponibles")
                return
            
            expiraciones_proximas = []
            
            for namespace, keys_metadata in cache_manager._metadata.items():
                for key, metadata in keys_metadata.items():
                    expiry_time = metadata['timestamp'] + timedelta(seconds=metadata['ttl'])
                    tiempo_restante = (expiry_time - datetime.now()).total_seconds()
                    
                    if tiempo_restante > 0:
                        expiraciones_proximas.append((namespace, key, tiempo_restante))
            
            # Ordenar por tiempo restante
            expiraciones_proximas.sort(key=lambda x: x[2])
            
            # Mostrar las 5 próximas a expirar
            print("   🔜 Próximas expiraciones:")
            for namespace, key, tiempo in expiraciones_proximas[:5]:
                minutos = int(tiempo // 60)
                segundos = int(tiempo % 60)
                print(f"      {namespace}.{key[:15]}... → {minutos}m {segundos}s")
    
    def _generar_recomendaciones(self, stats):
        """Genera recomendaciones basadas en las estadísticas"""
        print(f"\n💡 RECOMENDACIONES:")
        
        hit_rate = stats['hit_rate']
        
        if hit_rate < 50:
            print("   ⚠️ Hit rate bajo (<50%) - Considera aumentar TTL")
            print("   💡 Sugerencia: Revisar patrones de acceso a datos")
        elif hit_rate < 70:
            print("   📈 Hit rate moderado (50-70%) - Buen rendimiento")
            print("   💡 Sugerencia: Optimizar consultas frecuentes")
        else:
            print("   🎯 Excelente hit rate (>70%) - Óptimo rendimiento")
            print("   ✨ Sistema funcionando eficientemente")
        
        total_requests = stats['hits'] + stats['misses']
        if total_requests < 100:
            print("   📊 Pocas requests - Considera precalentar caché")
            print("   🔥 Usa warm_cache_completo() al inicio")
        
        if stats['invalidations'] > total_requests * 0.1:
            print("   🔄 Muchas invalidaciones - Revisa la lógica de invalidación")
            print("   🎯 Considera invalidación más granular")
        
        # Análisis de memoria
        with cache_manager._lock:
            total_namespaces = len(cache_manager._cache)
            if total_namespaces > 20:
                print("   🧹 Muchos namespaces activos - Considera limpieza periódica")
    
    def optimizar_cache_automaticamente(self):
        """Aplica optimizaciones automáticas al caché"""
        print("\n🎯 OPTIMIZANDO CACHÉ AUTOMÁTICAMENTE...")
        
        stats = cache_manager.get_stats()
        optimizaciones = 0
        
        # Optimización 1: Limpiar namespaces vacíos
        with cache_manager._lock:
            namespaces_vacios = [ns for ns, data in cache_manager._cache.items() if not data]
            for ns in namespaces_vacios:
                cache_manager.invalidate(ns)
                optimizaciones += 1
        
        if namespaces_vacios:
            print(f"   🧹 Limpiados {len(namespaces_vacios)} namespaces vacíos")
        
        # Optimización 2: Verificar hit rate bajo
        if stats['hit_rate'] < 30:
            print("   ⚠️ Hit rate muy bajo detectado")
            print("   💡 Considera revisar la lógica de caché")
        
        # Optimización 3: Análisis de invalidaciones excesivas
        total_requests = stats['hits'] + stats['misses']
        if stats['invalidations'] > total_requests * 0.2:
            print("   🔄 Invalidaciones excesivas detectadas")
            print("   💡 Revisa patrones de invalidación")
        
        print(f"✅ Optimización completada: {optimizaciones} acciones realizadas")
    
    def ejecutar_diagnostico_completo(self):
        """Ejecuta un diagnóstico completo del sistema de caché"""
        print("\n🔍 DIAGNÓSTICO COMPLETO DEL SISTEMA DE CACHÉ")
        print("=" * 55)
        
        # 1. Estado general
        print("1️⃣ ESTADO GENERAL:")
        stats = cache_manager.get_stats()
        print(f"   Estado: {'✅ Operativo' if stats['hits'] > 0 or stats['misses'] > 0 else '⚠️ Sin actividad'}")
        
        # 2. Rendimiento
        print("\n2️⃣ RENDIMIENTO:")
        self.generar_reporte_cache()
        
        # 3. Configuración
        print("\n3️⃣ CONFIGURACIÓN:")
        self._mostrar_configuracion_ttl()
        
        # 4. Optimizaciones
        print("\n4️⃣ OPTIMIZACIONES:")
        self.optimizar_cache_automaticamente()
        
        print("\n✅ Diagnóstico completado")


# Instancia global del configurador
cache_configurator = CacheConfigurator()

# Funciones de conveniencia
def configurar_cache():
    """Función de conveniencia para configurar el caché"""
    return cache_configurator.configurar_cache_aplicacion()

def warm_cache(repositorios):
    """Función de conveniencia para calentar el caché"""
    return cache_configurator.warm_cache_completo(repositorios)

def monitorear_cache(minutos=5):
    """Función de conveniencia para monitorear el caché"""
    return cache_configurator.monitorear_rendimiento(minutos)

def reporte_cache():
    """Función de conveniencia para generar reporte"""
    return cache_configurator.generar_reporte_cache()

def diagnostico_completo():
    """Función de conveniencia para diagnóstico completo"""
    return cache_configurator.ejecutar_diagnostico_completo()