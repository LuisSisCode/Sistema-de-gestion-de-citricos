# Integración de gestores de clientes y ventas
import logging
from .bd_clientes import GestorClientes
from .bd_ventas import GestorVentas
from datetime import datetime, timedelta
from .core.cache_system import cacheable, cache_invalidator, get_ttl, cache_manager

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_clientes_ventas_integrado')

class GestorClientesVentas:
    """
    Clase que integra las funcionalidades de gestión de clientes y ventas.
    Implementa el patrón fachada para simplificar el acceso a ambos gestores.
    """
    
    def __init__(self, server=None, database=None, trusted_connection=True):
        """
        Inicializa los gestores de clientes y ventas.
        
        Args:
            server (str): Nombre del servidor SQL Server.
            database (str): Nombre de la base de datos.
            trusted_connection (bool): Usar autenticación de Windows (True) o SQL Server (False).
        """
        try:
            self.gestor_clientes = GestorClientes(server, database, trusted_connection)
            self.gestor_ventas = GestorVentas(server, database, trusted_connection)
            logger.info("Gestores de clientes y ventas inicializados correctamente.")
        except Exception as e:
            logger.error(f"Error al inicializar los gestores: {str(e)}")
            raise

    # ==================== MÉTODOS DE GESTIÓN DE CACHÉ ====================
    
    def limpiar_cache_completo(self):
        """
        Limpia completamente todo el caché del sistema.
        """
        try:
            cache_manager.clear_all()
            logger.info("🧹 Cache completo limpiado exitosamente")
            return True
        except Exception as e:
            logger.error(f"❌ Error limpiando cache completo: {e}")
            return False

    def mostrar_estado_cache(self):
        """
        Muestra el estado actual del sistema de caché.
        """
        try:
            estadisticas = cache_manager.get_stats()
            
            print("\n" + "="*50)
            print("📊 ESTADO DEL SISTEMA DE CACHÉ")
            print("="*50)
            
            if estadisticas:
                print(f"🎯 Aciertos: {estadisticas.get('hits', 0)}")
                print(f"❌ Fallos: {estadisticas.get('misses', 0)}")
                print(f"🗑️ Invalidaciones: {estadisticas.get('invalidations', 0)}")
                print(f"📈 Tasa de aciertos: {estadisticas.get('hit_rate', 0)}%")
                
                total_requests = estadisticas.get('hits', 0) + estadisticas.get('misses', 0)
                if total_requests > 0:
                    print(f"📊 Total de consultas: {total_requests}")
            else:
                print("ℹ️  No hay estadísticas disponibles")
                
            # Mostrar información de los namespaces en caché
            try:
                with cache_manager._lock:
                    namespaces = list(cache_manager._cache.keys())
                    if namespaces:
                        print(f"\n🗂️ Namespaces en caché ({len(namespaces)}):")
                        for i, namespace in enumerate(namespaces, 1):
                            keys_count = len(cache_manager._cache[namespace])
                            print(f"   {i}. {namespace} ({keys_count} entradas)")
                            
                            # Mostrar algunas claves de ejemplo
                            keys = list(cache_manager._cache[namespace].keys())[:3]
                            for key in keys:
                                # Obtener info de TTL
                                if namespace in cache_manager._metadata and key in cache_manager._metadata[namespace]:
                                    metadata = cache_manager._metadata[namespace][key]
                                    timestamp = metadata['timestamp']
                                    ttl = metadata['ttl']
                                    expiry = timestamp + timedelta(seconds=ttl)
                                    tiempo_restante = (expiry - datetime.now()).total_seconds()
                                    print(f"      └─ {key[:20]}... (TTL: {tiempo_restante:.0f}s)")
                    else:
                        print("\n🗂️ No hay namespaces en caché")
            except Exception as e:
                print(f"⚠️ Error accediendo a información de caché: {e}")
                
            print("="*50)
            
        except Exception as e:
            logger.error(f"❌ Error mostrando estado del cache: {e}")
            print(f"❌ Error obteniendo estadísticas: {e}")

    def invalidar_cache_completo(self):
        """
        Alias para limpiar_cache_completo.
        """
        return self.limpiar_cache_completo()

    def obtener_estadisticas_cache(self):
        """
        Obtiene las estadísticas del caché en formato diccionario.
        
        Returns:
            dict: Estadísticas del caché
        """
        try:
            return cache_manager.get_stats()
        except Exception as e:
            logger.error(f"❌ Error obteniendo estadísticas: {e}")
            return {}

    def limpiar_cache_patron(self, patron):
        """
        Limpia entradas del caché que coincidan con un patrón.
        
        Args:
            patron (str): Patrón a buscar en las claves del caché
        """
        try:
            cache_manager.invalidate_pattern(patron)
            logger.info(f"🧹 Cache limpiado para patrón: {patron}")
            return True
        except Exception as e:
            logger.error(f"❌ Error limpiando cache con patrón {patron}: {e}")
            return False

    def limpiar_cache_namespace(self, namespace):
        """
        Limpia todo el caché de un namespace específico.
        
        Args:
            namespace (str): Namespace a limpiar (ej: 'clientes', 'ventas')
        """
        try:
            cache_manager.invalidate(namespace)
            logger.info(f"🧹 Cache limpiado para namespace: {namespace}")
            return True
        except Exception as e:
            logger.error(f"❌ Error limpiando cache del namespace {namespace}: {e}")
            return False

    def diagnosticar_cache_detallado(self):
        """
        Diagnóstico detallado del sistema de caché.
        """
        print("\n🔍 DIAGNÓSTICO DETALLADO DEL CACHÉ")
        print("="*60)
        
        # Estadísticas básicas
        stats = cache_manager.get_stats()
        print(f"📊 Estadísticas básicas:")
        print(f"   🎯 Hits: {stats.get('hits', 0)}")
        print(f"   ❌ Misses: {stats.get('misses', 0)}")
        print(f"   🗑️ Invalidaciones: {stats.get('invalidations', 0)}")
        print(f"   📈 Hit Rate: {stats.get('hit_rate', 0)}%")
        
        # TTL Configuration
        print(f"\n⏱️ Configuración de TTL:")
        from .core.cache_system import TTL_CONFIG
        for namespace, ttl in TTL_CONFIG.items():
            minutos = ttl // 60
            print(f"   📋 {namespace}: {ttl}s ({minutos}min)")
        
        # Estado interno del caché
        try:
            with cache_manager._lock:
                total_namespaces = len(cache_manager._cache)
                total_keys = sum(len(keys) for keys in cache_manager._cache.values())
                
                print(f"\n💾 Estado interno:")
                print(f"   📁 Total namespaces: {total_namespaces}")
                print(f"   🔑 Total claves: {total_keys}")
                
                if cache_manager._cache:
                    print(f"\n📋 Detalle por namespace:")
                    for namespace, keys_dict in cache_manager._cache.items():
                        print(f"   🗂️ {namespace}: {len(keys_dict)} entradas")
                        
        except Exception as e:
            print(f"⚠️ Error accediendo al estado interno: {e}")
        
        print("="*60)

    # ==================== MÉTODOS DE INVALIDACIÓN ESPECÍFICA ====================
    
    def invalidar_cache_cliente_ventas(self, id_cliente):
        """Invalida todo el caché relacionado con un cliente específico"""
        cache_manager.invalidate_pattern(f"cliente_{id_cliente}")
        cache_manager.invalidate('estadisticas')
        cache_manager.invalidate('reportes')
        logger.info(f"Caché invalidado para cliente {id_cliente}")

    def invalidar_cache_venta_completa(self, id_venta):
        """Invalida todo el caché relacionado con una venta específica"""
        cache_manager.invalidate_pattern(f"id_{id_venta}")
        cache_manager.invalidate_pattern(f"detalles_{id_venta}")
        cache_manager.invalidate('ventas')
        cache_manager.invalidate('estadisticas')
        cache_manager.invalidate('reportes')
        logger.info(f"Caché invalidado para venta {id_venta}")

    def warm_cache_dashboard(self):
        """Calienta el caché con datos del dashboard principal"""
        try:
            # Datos más utilizados en dashboard
            self.obtener_clientes()
            self.obtener_ventas()
            self.obtener_estados_venta()
            self.obtener_variedades_disponibles()
            self.obtener_pagos_pendientes()
            self.obtener_ventas_vencidas()
            self.clasificar_clientes_por_volumen()
            
            logger.info("🔥 Cache dashboard calentado exitosamente")
            return True
        except Exception as e:
            logger.error(f"❌ Error calentando cache dashboard: {e}")
            return False

    @cacheable('dashboard_completo', ttl=300)  # 5 minutos - datos dinámicos
    def obtener_dashboard_completo(self):
        """
        Obtiene todos los datos necesarios para el dashboard (VERSIÓN CACHEADA).
        """
        try:
            dashboard = {
                'clientes': self.obtener_clientes(),
                'ventas_recientes': self.obtener_ventas()[:20],  # Solo las 20 más recientes
                'estados_venta': self.obtener_estados_venta(),
                'variedades': self.obtener_variedades_disponibles(),
                'pagos_pendientes': self.obtener_pagos_pendientes(),
                'ventas_vencidas': self.obtener_ventas_vencidas(),
                'clasificacion_clientes': self.clasificar_clientes_por_volumen(),
                'cliente_top': self.obtener_cliente_top(),
                'resumen_mes': self.obtener_ventas_del_mes(),
                'timestamp': datetime.now().isoformat()
            }
            
            logger.info("Dashboard completo generado con caché")
            return dashboard
        except Exception as e:
            logger.error(f"Error generando dashboard: {e}")
            return {}

    # ==================== MÉTODOS DE DELEGACIÓN PARA CLIENTES ====================
        
    def obtener_clientes(self):
        """
        Obtiene todos los clientes de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada cliente.
        """
        return self.gestor_clientes.obtener_clientes()
    
    def obtener_cliente_por_id(self, id_cliente):
        """
        Obtiene un cliente específico por su ID.
        
        Args:
            id_cliente (int): ID del cliente a obtener.
            
        Returns:
            dict: Diccionario con la información del cliente o None si no se encuentra.
        """
        return self.gestor_clientes.obtener_cliente_por_id(id_cliente)
    
    def buscar_clientes(self, criterio):
        """
        Busca clientes que coincidan con el criterio en varios campos.
        
        Args:
            criterio (str): Texto a buscar en los campos del cliente.
            
        Returns:
            list: Lista de diccionarios con los clientes que coinciden con el criterio.
        """
        return self.gestor_clientes.buscar_clientes(criterio)
    
    def agregar_cliente(self, cliente_data):
        """
        Agrega un nuevo cliente a la base de datos.
        
        Args:
            cliente_data (dict): Datos del cliente a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del cliente agregado o None en caso de error.
        """
        return self.gestor_clientes.agregar_cliente(cliente_data)
    
    def actualizar_cliente(self, id_cliente, cliente_data):
        """
        Actualiza un cliente existente en la base de datos.
        
        Args:
            id_cliente (int): ID del cliente a actualizar.
            cliente_data (dict): Datos actualizados del cliente.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        return self.gestor_clientes.actualizar_cliente(id_cliente, cliente_data)
    
    def eliminar_cliente(self, id_cliente):
        """
        Elimina un cliente de la base de datos (eliminación lógica).
        
        Args:
            id_cliente (int): ID del cliente a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        return self.gestor_clientes.eliminar_cliente(id_cliente)
    
    def obtener_historial_compras_cliente(self, id_cliente):
        """
        Obtiene el historial de compras de un cliente específico.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            dict: Diccionario con el historial de compras y estadísticas.
        """
        return self.gestor_clientes.obtener_historial_compras_cliente(id_cliente)
    
    def clasificar_clientes_por_volumen(self):
        """
        Clasifica a los clientes por volumen de compras.
        
        Returns:
            list: Lista de diccionarios con los clientes clasificados.
        """
        return self.gestor_clientes.clasificar_clientes_por_volumen()
    
    def obtener_clientes_inactivos(self, dias_inactividad=90):
        """
        Obtiene los clientes que no han realizado compras en el período especificado.
        
        Args:
            dias_inactividad (int): Número de días sin compras para considerar inactivo.
            
        Returns:
            list: Lista de diccionarios con los clientes inactivos.
        """
        return self.gestor_clientes.obtener_clientes_inactivos(dias_inactividad)
    
    # ==================== MÉTODOS DE DELEGACIÓN PARA VENTAS ====================
    
    def obtener_ventas(self):
        """
        Obtiene todas las ventas de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada venta.
        """
        return self.gestor_ventas.obtener_ventas()
    
    def obtener_venta_por_id(self, id_venta):
        """
        Obtiene una venta específica por su ID.
        
        Args:
            id_venta (int): ID de la venta a obtener.
            
        Returns:
            dict: Diccionario con la información de la venta o None si no se encuentra.
        """
        return self.gestor_ventas.obtener_venta_por_id(id_venta)
    
    def obtener_estados_venta(self):
        """
        Obtiene todos los estados de venta posibles.
        
        Returns:
            list: Lista de diccionarios con la información de cada estado de venta.
        """
        return self.gestor_ventas.obtener_estados_venta()
    
    def obtener_variedades_disponibles(self):
        """
        Obtiene las variedades de cultivo disponibles para venta.
        
        Returns:
            list: Lista de diccionarios con la información de cada variedad disponible.
        """
        return self.gestor_ventas.obtener_variedades_disponibles()
    
    def obtener_variedad_por_id(self, id_variedad):
        """
        Obtiene información detallada de una variedad específica.
        
        Args:
            id_variedad (int): ID de la variedad a obtener.
            
        Returns:
            dict: Diccionario con la información de la variedad o None si no se encuentra.
        """
        return self.gestor_ventas.obtener_variedad_por_id(id_variedad)
    
    def agregar_venta(self, venta_data, detalles_data):
        """
        Agrega una nueva venta con sus detalles a la base de datos.
        
        Args:
            venta_data (dict): Datos generales de la venta.
            detalles_data (list): Lista de diccionarios con los detalles de la venta.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID de la venta agregada o None en caso de error.
        """
        return self.gestor_ventas.agregar_venta(venta_data, detalles_data)
    
    def actualizar_venta(self, id_venta, venta_data):
        """
        Actualiza una venta existente en la base de datos.
        
        Args:
            id_venta (int): ID de la venta a actualizar.
            venta_data (dict): Datos actualizados de la venta.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        return self.gestor_ventas.actualizar_venta(id_venta, venta_data)
    
    def cancelar_venta(self, id_venta, motivo_cancelacion):
        """
        Cancela una venta.
        
        Args:
            id_venta (int): ID de la venta a cancelar.
            motivo_cancelacion (str): Motivo por el cual se cancela la venta.
            
        Returns:
            bool: True si se canceló correctamente, False en caso contrario.
        """
        return self.gestor_ventas.cancelar_venta(id_venta, motivo_cancelacion)
    
    def cambiar_estado_venta(self, id_venta, nuevo_estado_id):
        """
        Actualiza el estado de una venta.
        
        Args:
            id_venta (int): ID de la venta a actualizar.
            nuevo_estado_id (int): ID del nuevo estado.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        return self.gestor_ventas.cambiar_estado_venta(id_venta, nuevo_estado_id)
    
    def cambiar_estado_pago(self, id_venta, nuevo_estado_pago):
        """
        Actualiza el estado de pago de una venta.
        
        Args:
            id_venta (int): ID de la venta a actualizar.
            nuevo_estado_pago (str): Nuevo estado de pago ('Pendiente', 'Parcial', 'Pagado').
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        return self.gestor_ventas.cambiar_estado_pago(id_venta, nuevo_estado_pago)
    
    def duplicar_venta(self, id_venta, nuevo_codigo=None, nueva_fecha=None):
        """
        Duplica una venta existente con todos sus detalles.
        
        Args:
            id_venta (int): ID de la venta a duplicar.
            nuevo_codigo (str): Código para la nueva venta. Si es None, se genera automáticamente.
            nueva_fecha (str): Fecha para la nueva venta en formato 'YYYY-MM-DD'. Si es None, se usa la fecha actual.
            
        Returns:
            bool: True si se duplicó correctamente, False en caso contrario.
            int: ID de la nueva venta o None en caso de error.
        """
        return self.gestor_ventas.duplicar_venta(id_venta, nuevo_codigo, nueva_fecha)
    
    def obtener_detalles_venta(self, id_venta):
        """
        Obtiene todos los detalles de una venta específica.
        
        Args:
            id_venta (int): ID de la venta para obtener sus detalles.
            
        Returns:
            list: Lista de diccionarios con la información de cada detalle.
        """
        return self.gestor_ventas.obtener_detalles_venta(id_venta)
    
    def agregar_detalle_venta(self, id_venta, detalle_data):
        """
        Agrega un nuevo detalle a una venta existente.
        
        Args:
            id_venta (int): ID de la venta a la que se agregará el detalle.
            detalle_data (dict): Datos del detalle a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
        """
        return self.gestor_ventas.agregar_detalle_venta(id_venta, detalle_data)
    
    def eliminar_detalle_venta(self, id_detalle_venta):
        """
        Elimina un detalle de venta y actualiza los totales de la venta.
        
        Args:
            id_detalle_venta (int): ID del detalle de venta a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        return self.gestor_ventas.eliminar_detalle_venta(id_detalle_venta)
    
    def actualizar_detalle_venta(self, id_detalle_venta, detalle_data):
        """
        Actualiza un detalle de venta existente y recalcula los totales.
        
        Args:
            id_detalle_venta (int): ID del detalle de venta a actualizar.
            detalle_data (dict): Datos actualizados del detalle.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        return self.gestor_ventas.actualizar_detalle_venta(id_detalle_venta, detalle_data)
    
    # ==================== MÉTODOS PARA REPORTES Y ESTADÍSTICAS ====================
    
    def obtener_resumen_ventas_por_periodo(self, fecha_inicio_str, fecha_fin_str):
        """
        Obtiene un resumen de ventas por un período específico.
        
        Args:
            fecha_inicio (str): Fecha de inicio en formato YYYY-MM-DD.
            fecha_fin (str): Fecha de fin en formato YYYY-MM-DD.
            
        Returns:
            dict: Diccionario con el resumen de ventas.
        """
        return self.gestor_ventas.obtener_resumen_ventas_por_periodo(fecha_inicio_str, fecha_fin_str)
    
    def obtener_ventas_del_mes(self):
        """
        Obtiene un resumen de las ventas del mes actual.
        
        Returns:
            dict: Diccionario con el resumen de ventas del mes.
        """
        return self.gestor_ventas.obtener_ventas_del_mes()
    
    def obtener_reporte_semanal(self):
        """
        Obtiene un reporte de ventas de la semana actual.
        
        Returns:
            dict: Diccionario con el reporte semanal.
        """
        return self.gestor_ventas.obtener_reporte_semanal()
    
    def obtener_reporte_anual(self, año=None):
        """
        Obtiene un reporte anual de ventas.
        
        Args:
            año (int): Año para el reporte. Si es None, se usa el año actual.
            
        Returns:
            dict: Diccionario con el reporte anual.
        """
        return self.gestor_ventas.obtener_reporte_anual(año)
    
    def obtener_pagos_pendientes(self):
        """
        Obtiene un resumen de los pagos pendientes.
        
        Returns:
            list: Lista de diccionarios con información de ventas con pagos pendientes.
        """
        return self.gestor_ventas.obtener_pagos_pendientes()
    
    def obtener_ventas_vencidas(self):
        """
        Obtiene las ventas con fecha de entrega vencida.
        
        Returns:
            list: Lista de diccionarios con información de ventas vencidas.
        """
        return self.gestor_ventas.obtener_ventas_vencidas()
    
    def obtener_ventas_por_cliente(self, id_cliente):
        """
        Obtiene todas las ventas realizadas a un cliente específico.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            list: Lista de diccionarios con las ventas del cliente.
        """
        return self.gestor_ventas.obtener_ventas_por_cliente(id_cliente)
    
    def calcular_estadisticas_venta(self, id_venta):
        """
        Calcula estadísticas básicas para una venta específica.
        
        Args:
            id_venta (int): ID de la venta para calcular estadísticas.
            
        Returns:
            dict: Diccionario con estadísticas de la venta.
        """
        return self.gestor_ventas.calcular_estadisticas_venta(id_venta)
    
    def obtener_cliente_top(self):
        """
        Obtiene el cliente con mayor volumen de compras en el último mes.
        
        Returns:
            dict: Diccionario con la información del cliente top o None si no hay ventas.
        """
        return self.gestor_ventas.obtener_cliente_top()
    
    # ==================== MÉTODOS UTILITARIOS ====================
    
    def generar_codigo_venta(self):
        """
        Genera un código único para una nueva venta.
        
        Returns:
            str: Código generado para la venta.
        """
        return self.gestor_ventas.generar_codigo_venta()
    
    def obtener_productos_venta(self, id_venta):
        """
        Obtiene los productos de una venta específica.
        
        Args:
            id_venta (int): ID de la venta para obtener sus productos.
            
        Returns:
            list: Lista de diccionarios con la información de los productos.
        """
        return self.gestor_ventas.obtener_productos_venta(id_venta)
    def obtener_estadisticas_ventas(self):
        """Obtiene estadísticas generales de ventas"""
        return self.gestor_ventas.obtener_estadisticas_ventas()

    def obtener_ventas_por_mes(self, anio):
        """Obtiene ventas agrupadas por mes"""
        return self.gestor_ventas.obtener_ventas_por_mes(anio)
        
    def obtener_productos_mas_vendidos(self):
        """Obtiene productos más vendidos"""
        return self.gestor_ventas.obtener_productos_mas_vendidos()
        
    def obtener_clientes_top_completo(self):
        """Obtiene lista completa de mejores clientes"""
        return self.gestor_ventas.obtener_clientes_top_completo()

# ==================== CÓDIGO DE PRUEBA DEL SISTEMA ====================

if __name__ == "__main__":
    print("🚀 Iniciando pruebas completas del sistema de caché...")
    
    # Importar funciones del sistema de caché
    from .core.cache_system import print_cache_stats, clear_cache
    
    # Crear instancia del gestor
    try:
        gestor = GestorClientesVentas()
        print("✅ Gestor creado exitosamente")
    except Exception as e:
        print(f"❌ Error creando gestor: {e}")
        exit(1)
    
    # Estado inicial
    print("\n" + "="*60)
    print("📊 ESTADO INICIAL DEL CACHÉ")
    print("="*60)
    print_cache_stats()
    gestor.mostrar_estado_cache()
    
    # Limpiar caché
    print("\n🧹 Limpiando caché completo...")
    resultado = gestor.limpiar_cache_completo()
    if resultado:
        print("✅ Caché limpiado exitosamente")
        print_cache_stats()
    else:
        print("❌ Error limpiando caché")
    
    # Calentar el caché del dashboard
    print("\n🔥 Calentando caché del dashboard...")
    if gestor.warm_cache_dashboard():
        print("✅ Dashboard cache calentado")
        print_cache_stats()
    else:
        print("⚠️ Error calentando dashboard cache")
    
    # Prueba de rendimiento con dashboard completo
    print("\n" + "="*60)
    print("⚡ PRUEBA DE RENDIMIENTO - DASHBOARD COMPLETO")
    print("="*60)
    
    import time
    
    # Primera carga (desde BD)
    print("1️⃣ Primera carga (desde base de datos)...")
    start = time.time()
    dashboard1 = gestor.obtener_dashboard_completo()
    time1 = time.time() - start
    print(f"   ⏱️ Tiempo: {time1:.3f}s")
    print_cache_stats()
    
    # Segunda carga (desde caché)
    print("\n2️⃣ Segunda carga (desde caché)...")
    start = time.time()
    dashboard2 = gestor.obtener_dashboard_completo()
    time2 = time.time() - start
    print(f"   ⏱️ Tiempo: {time2:.3f}s")
    print_cache_stats()
    
    # Tercera carga (confirmar caché)
    print("\n3️⃣ Tercera carga (confirmar caché)...")
    start = time.time()
    dashboard3 = gestor.obtener_dashboard_completo()
    time3 = time.time() - start
    print(f"   ⏱️ Tiempo: {time3:.3f}s")
    print_cache_stats()
    
    # Análisis de rendimiento
    print("\n📈 ANÁLISIS DE RENDIMIENTO:")
    print(f"   🐌 Primera carga (BD): {time1:.3f}s")
    print(f"   🚀 Segunda carga (caché): {time2:.3f}s") 
    print(f"   🚀 Tercera carga (caché): {time3:.3f}s")
    
    if time1 > time2:
        mejora1 = ((time1-time2)/time1)*100
        print(f"   📊 Mejora 1ra->2da: {mejora1:.1f}%")
    
    if time1 > time3:
        mejora2 = ((time1-time3)/time1)*100
        print(f"   📊 Mejora 1ra->3ra: {mejora2:.1f}%")
    
    # Verificar que los datos son consistentes
    print(f"\n🔍 VERIFICACIÓN DE CONSISTENCIA:")
    consistent = dashboard1 == dashboard2 == dashboard3
    print(f"   {'✅' if consistent else '❌'} Datos consistentes: {consistent}")
    
    # Prueba de operaciones individuales
    print("\n" + "="*60)
    print("🧪 PRUEBA DE OPERACIONES INDIVIDUALES")
    print("="*60)
    
    operaciones = [
        ('obtener_clientes', lambda: gestor.obtener_clientes()),
        ('obtener_ventas', lambda: gestor.obtener_ventas()),
        ('obtener_estados_venta', lambda: gestor.obtener_estados_venta()),
        ('obtener_variedades_disponibles', lambda: gestor.obtener_variedades_disponibles()),
    ]
    
    for nombre, operacion in operaciones:
        print(f"\n🔍 Probando {nombre}...")
        try:
            # Primera llamada
            start = time.time()
            resultado1 = operacion()
            time1 = time.time() - start
            
            # Segunda llamada (desde caché)
            start = time.time()
            resultado2 = operacion()
            time2 = time.time() - start
            
            # Análisis
            mejora = ((time1-time2)/time1)*100 if time1 > time2 else 0
            consistent = resultado1 == resultado2
            
            print(f"   ⏱️ 1ra: {time1:.3f}s | 2da: {time2:.3f}s | Mejora: {mejora:.1f}%")
            print(f"   {'✅' if consistent else '❌'} Consistente | Registros: {len(resultado1) if resultado1 else 0}")
            
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    # Estado final del caché
    print("\n" + "="*60)
    print("📊 ESTADO FINAL DEL CACHÉ")
    print("="*60)
    print_cache_stats()
    gestor.mostrar_estado_cache()
    
    # Diagnóstico detallado
    print("\n🔬 DIAGNÓSTICO DETALLADO:")
    gestor.diagnosticar_cache_detallado()
    
    # Prueba de invalidación
    print("\n🧪 PRUEBA DE INVALIDACIÓN:")
    print("   🗑️ Limpiando caché de clientes...")
    gestor.limpiar_cache_namespace('clientes')
    print_cache_stats()
    
    print("   🗑️ Limpiando con patrón 'dashboard'...")
    gestor.limpiar_cache_patron('dashboard')
    print_cache_stats()
    
    # Resumen final
    print("\n" + "="*60)
    print("🎉 RESUMEN FINAL")
    print("="*60)
    stats_finales = gestor.obtener_estadisticas_cache()
    print(f"✅ Hits totales: {stats_finales.get('hits', 0)}")
    print(f"❌ Misses totales: {stats_finales.get('misses', 0)}")
    print(f"🗑️ Invalidaciones: {stats_finales.get('invalidations', 0)}")
    print(f"📈 Hit rate final: {stats_finales.get('hit_rate', 0)}%")
    print(f"🚀 Sistema de caché: {'✅ FUNCIONANDO' if stats_finales.get('hits', 0) > 0 else '⚠️ NECESITA REVISIÓN'}")
    
    print("\n✅ ¡Pruebas completadas exitosamente!")
    print("="*60)