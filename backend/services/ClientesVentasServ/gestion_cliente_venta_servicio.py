# bd_conecciones/servicios/ClientesVentasServ/gestion_cliente_venta_servicio.py

import logging
from datetime import datetime, timedelta
from backend.services.ClientesVentasServ.cliente_servicio import ClienteServicio
from backend.services.ClientesVentasServ.venta_servicio import VentaServicio
from backend.repositories.ClientesVentasRep.relacion_cliente_venta_repositorio import RelacionClienteVentaRepositorio
from backend.repositories.ClientesVentasRep.estado_venta_repositorio import EstadoVentaRepositorio
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl, cache_manager

logger = logging.getLogger(__name__)

class GestionClienteVentaServicio:
    """
    Servicio de orquestación y fachada para gestión integrada de clientes y ventas.
    Mantiene compatibilidad con el modelo existente y simplifica el acceso a las funcionalidades.
    """
    
    def __init__(self):
        self.cliente_servicio = ClienteServicio()
        self.venta_servicio = VentaServicio()
        self.relacion_repo = RelacionClienteVentaRepositorio()
        self.estado_repo = EstadoVentaRepositorio()
    
    # ==================== MÉTODOS DE GESTIÓN DE CACHÉ ====================
    
    def limpiar_cache_completo(self):
        """Limpia completamente todo el caché del sistema."""
        try:
            cache_manager.clear_all()
            logger.info("🧹 Cache completo limpiado exitosamente")
            return True
        except Exception as e:
            logger.error(f"❌ Error limpiando cache completo: {e}")
            return False

    def mostrar_estado_cache(self):
        """Muestra el estado actual del sistema de caché."""
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
            
            print("="*50)
            
        except Exception as e:
            logger.error(f"❌ Error mostrando estado del cache: {e}")
            print(f"❌ Error obteniendo estadísticas: {e}")

    def invalidar_cache_completo(self):
        """Alias para limpiar_cache_completo."""
        return self.limpiar_cache_completo()

    def obtener_estadisticas_cache(self):
        """Obtiene las estadísticas del caché en formato diccionario."""
        try:
            return cache_manager.get_stats()
        except Exception as e:
            logger.error(f"❌ Error obteniendo estadísticas: {e}")
            return {}

    @cacheable('dashboard_completo', ttl=300)  # 5 minutos - datos dinámicos
    def obtener_dashboard_completo(self):
        """Obtiene todos los datos necesarios para el dashboard (VERSIÓN CACHEADA)."""
        try:
            dashboard = {
                'clientes': self.obtener_clientes(),
                'ventas_recientes': self.obtener_ventas()[:20],  # Solo las 20 más recientes
                'estados_venta': self.obtener_estados_venta(),
                'variedades_disponibles': self.obtener_variedades_disponibles(),
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
        """Obtiene todos los clientes activos."""
        return self.cliente_servicio.cliente_repo.obtener_todos()
    
    def obtener_cliente_por_id(self, id_cliente):
        """Obtiene un cliente específico por su ID."""
        return self.cliente_servicio.cliente_repo.obtener_por_id(id_cliente)
    
    def buscar_clientes(self, criterio):
        """Busca clientes que coincidan con el criterio en varios campos."""
        return self.cliente_servicio.buscar_clientes(criterio)
    
    def agregar_cliente(self, cliente_data):
        """Agrega un nuevo cliente a la base de datos."""
        resultado = self.cliente_servicio.crear_cliente(cliente_data)
        if resultado['exito']:
            return True, resultado['id_cliente']
        else:
            return False, None
    
    def actualizar_cliente(self, id_cliente, cliente_data):
        """Actualiza un cliente existente en la base de datos."""
        resultado = self.cliente_servicio.actualizar_cliente(id_cliente, cliente_data)
        return resultado['exito']
    
    def eliminar_cliente(self, id_cliente):
        """Elimina un cliente de la base de datos (eliminación lógica)."""
        resultado = self.cliente_servicio.eliminar_cliente(id_cliente)
        return resultado['exito']
    
    def obtener_historial_compras_cliente(self, id_cliente):
        """Obtiene el historial de compras de un cliente específico."""
        return self.relacion_repo.obtener_historial_compras_cliente(id_cliente)
    
    def clasificar_clientes_por_volumen(self):
        """Clasifica a los clientes por volumen de compras."""
        return self.relacion_repo.clasificar_clientes_por_volumen()
    
    def obtener_clientes_inactivos(self, dias_inactividad=90):
        """Obtiene los clientes que no han realizado compras en el período especificado."""
        return self.cliente_servicio.cliente_repo.obtener_clientes_inactivos(dias_inactividad)
    
    # ==================== MÉTODOS DE DELEGACIÓN PARA VENTAS ====================
    
    def obtener_ventas(self):
        """Obtiene todas las ventas de la base de datos."""
        return self.venta_servicio.venta_repo.obtener_todos()
    
    def obtener_venta_por_id(self, id_venta):
        """Obtiene una venta específica por su ID."""
        return self.venta_servicio.venta_repo.obtener_por_id(id_venta)
    
    def obtener_estados_venta(self):
        """Obtiene todos los estados de venta posibles."""
        return self.estado_repo.obtener_todos()
    
    def obtener_variedades_disponibles(self):
        """Obtiene las variedades de cultivo disponibles para venta."""
        return self.venta_servicio.venta_repo.obtener_variedades_disponibles()
    
    def obtener_variedad_por_id(self, id_variedad):
        """Obtiene información detallada de una variedad específica."""
        variedades = self.obtener_variedades_disponibles()
        for variedad in variedades:
            if variedad['id_variedad'] == id_variedad:
                return variedad
        return None
    
    def agregar_venta(self, venta_data, detalles_data):
        """Agrega una nueva venta con sus detalles a la base de datos."""
        resultado = self.venta_servicio.crear_venta(venta_data, detalles_data)
        return resultado['exito']
    
    def actualizar_venta(self, id_venta, venta_data):
        """Actualiza una venta existente en la base de datos."""
        resultado = self.venta_servicio.actualizar_venta(id_venta, venta_data)
        return resultado['exito']
    
    def cancelar_venta(self, id_venta, motivo_cancelacion):
        """Cancela una venta."""
        resultado = self.venta_servicio.cancelar_venta(id_venta, motivo_cancelacion)
        return resultado['exito']
    
    def cambiar_estado_venta(self, id_venta, nuevo_estado_id):
        """Actualiza el estado de una venta."""
        resultado = self.venta_servicio.cambiar_estado_venta(id_venta, nuevo_estado_id)
        return resultado['exito']
    
    def cambiar_estado_pago(self, id_venta, nuevo_estado_pago):
        """Actualiza el estado de pago de una venta."""
        resultado = self.venta_servicio.cambiar_estado_pago(id_venta, nuevo_estado_pago)
        return resultado['exito']
    
    def duplicar_venta(self, id_venta, nuevo_codigo=None, nueva_fecha=None):
        """Duplica una venta existente con todos sus detalles."""
        resultado = self.venta_servicio.duplicar_venta(id_venta, nuevo_codigo, nueva_fecha)
        if resultado['exito']:
            return True, resultado['nueva_venta_id']
        else:
            return False, None
    
    def obtener_detalles_venta(self, id_venta):
        """Obtiene todos los detalles de una venta específica."""
        return self.venta_servicio.detalle_repo.obtener_por_venta(id_venta)
    
    def agregar_detalle_venta(self, id_venta, detalle_data):
        """Agrega un nuevo detalle a una venta existente."""
        resultado = self.venta_servicio.agregar_detalle_venta(id_venta, detalle_data)
        return resultado['exito']
    
    def eliminar_detalle_venta(self, id_detalle_venta):
        """Elimina un detalle de venta y actualiza los totales de la venta."""
        resultado = self.venta_servicio.eliminar_detalle_venta(id_detalle_venta)
        return resultado['exito']
    
    def actualizar_detalle_venta(self, id_detalle_venta, detalle_data):
        """Actualiza un detalle de venta existente y recalcula los totales."""
        resultado = self.venta_servicio.actualizar_detalle_venta(id_detalle_venta, detalle_data)
        return resultado['exito']
    
    # ==================== MÉTODOS PARA REPORTES Y CONSULTAS ====================
    
    def obtener_resumen_ventas_por_periodo(self, fecha_inicio_str, fecha_fin_str):
        """Obtiene un resumen de ventas por un período específico."""
        return self.relacion_repo.obtener_resumen_ventas_por_periodo(fecha_inicio_str, fecha_fin_str)
    
    def obtener_ventas_del_mes(self):
        """Obtiene un resumen de las ventas del mes actual."""
        return self.relacion_repo.obtener_ventas_del_mes()
    
    def obtener_reporte_semanal(self):
        """Obtiene un reporte de ventas de la semana actual."""
        # Obtener el primer día de la semana (lunes)
        hoy = datetime.now().date()
        dia_semana = hoy.weekday()  # 0 es lunes, 6 es domingo
        primer_dia_semana = hoy - timedelta(days=dia_semana)
        ultimo_dia_semana = primer_dia_semana + timedelta(days=6)
        
        # Obtener resumen de ventas para la semana
        resumen_ventas = self.obtener_resumen_ventas_por_periodo(
            primer_dia_semana.strftime('%Y-%m-%d'),
            ultimo_dia_semana.strftime('%Y-%m-%d')
        )
        
        return resumen_ventas
    
    def obtener_reporte_anual(self, año=None):
        """Obtiene un reporte anual de ventas."""
        if año is None:
            año = datetime.now().year
        
        fecha_inicio = datetime(año, 1, 1).date()
        fecha_fin = datetime(año, 12, 31).date()
        
        return self.obtener_resumen_ventas_por_periodo(
            fecha_inicio.strftime('%Y-%m-%d'),
            fecha_fin.strftime('%Y-%m-%d')
        )
    
    def obtener_pagos_pendientes(self):
        """Obtiene un resumen de los pagos pendientes."""
        return self.relacion_repo.obtener_pagos_pendientes()
    
    def obtener_ventas_vencidas(self):
        """Obtiene las ventas con fecha de entrega vencida."""
        return self.relacion_repo.obtener_ventas_vencidas()
    
    def obtener_ventas_por_cliente(self, id_cliente):
        """Obtiene todas las ventas realizadas a un cliente específico."""
        return self.relacion_repo.obtener_ventas_por_cliente(id_cliente)
    
    def calcular_estadisticas_venta(self, id_venta):
        """Calcula estadísticas básicas para una venta específica."""
        try:
            venta = self.obtener_venta_por_id(id_venta)
            if not venta:
                return {}
            
            detalles = self.obtener_detalles_venta(id_venta)
            
            # Calcular días entre fecha de venta y entrega
            dias_entrega = None
            if venta.get('fecha_entrega') and venta.get('fecha_venta'):
                try:
                    fecha_venta = datetime.strptime(venta['fecha_venta'], '%Y-%m-%d').date()
                    fecha_entrega = datetime.strptime(venta['fecha_entrega'], '%Y-%m-%d').date()
                    dias_entrega = (fecha_entrega - fecha_venta).days
                except:
                    dias_entrega = None
            
            # Calcular estadísticas de detalles
            total_productos = len(detalles)
            total_unidades = sum(float(d['cantidad']) for d in detalles)
            precios = [float(d['precio_unitario']) for d in detalles if d['precio_unitario']]
            
            estadisticas = {
                'cliente': venta['cliente_nombre'],
                'fecha_venta': venta['fecha_venta'],
                'fecha_entrega': venta.get('fecha_entrega'),
                'dias_entrega': dias_entrega,
                'subtotal': float(venta['subtotal']),
                'total': float(venta['total']),
                'estado': venta['estado_nombre'],
                'estado_pago': venta['estado_pago'],
                'total_productos': total_productos,
                'total_unidades': total_unidades,
                'precio_promedio': sum(precios) / len(precios) if precios else 0,
                'precio_maximo': max(precios) if precios else 0,
                'precio_minimo': min(precios) if precios else 0
            }
            
            return estadisticas
        except Exception as e:
            logger.error(f"Error al calcular estadísticas de venta: {str(e)}")
            return {}
    
    def obtener_cliente_top(self):
        """Obtiene el cliente con mayor volumen de compras en el último mes."""
        return self.relacion_repo.obtener_cliente_top()
    
    # ==================== MÉTODOS UTILITARIOS ====================
    
    def generar_codigo_venta(self):
        """Genera un código único para una nueva venta."""
        return self.venta_servicio.venta_repo.generar_codigo_venta()
    
    def obtener_productos_venta(self, id_venta):
        """Obtiene los productos de una venta específica."""
        try:
            detalles = self.obtener_detalles_venta(id_venta)
            productos = []
            
            for detalle in detalles:
                producto = {
                    'id_detalle': detalle['id_detalle_venta'],
                    'nombre': detalle['producto_completo'],
                    'cantidad': detalle['cantidad'],
                    'unidad': detalle['unidad_medida'],
                    'precio_unitario': detalle['precio_unitario'],
                    'subtotal': detalle['subtotal']
                }
                productos.append(producto)
            
            logger.info(f"Se obtuvieron {len(productos)} productos para la venta ID: {id_venta}")
            return productos
        except Exception as e:
            logger.error(f"Error al obtener productos de venta: {str(e)}")
            return []

    # ==================== MÉTODOS DE COMPATIBILIDAD PARA EL MODELO EXISTENTE ====================
    
    def agregar_estado_venta(self, estado_data):
        """Agrega un nuevo estado de venta."""
        exito, id_estado = self.estado_repo.crear(estado_data)
        return exito, id_estado
    
    def buscar_ventas_por_rango_monto(self, monto_min, monto_max):
        """Busca ventas dentro de un rango de montos."""
        return self.venta_servicio.venta_repo.buscar_por_rango_monto(monto_min, monto_max)
    
    def obtener_lotes_disponibles(self):
        """Obtiene los lotes de cosecha disponibles para venta."""
        return self.venta_servicio.detalle_repo.obtener_lotes_disponibles()
    
    # ==================== MÉTODOS DE OPERACIONES COMPLEJAS ====================
    
    @cache_invalidator('dashboard_completo')
    @cache_invalidator('servicio_clientes', pattern='paginado_')
    @cache_invalidator('servicio_ventas', pattern='paginado_')
    def recargar_datos_completos(self):
        """Invalida cachés y fuerza recarga de datos principales."""
        try:
            # Invalidar cachés principales
            cache_manager.invalidate('clientes')
            cache_manager.invalidate('ventas')
            cache_manager.invalidate('estados_venta')
            cache_manager.invalidate('pagos_pendientes')
            cache_manager.invalidate('ventas_vencidas')
            cache_manager.invalidate('clientes_clasificados')
            cache_manager.invalidate('cliente_top')
            cache_manager.invalidate('resumen_ventas')
            
            logger.info("🔄 Datos principales recargados exitosamente")
            return True
        except Exception as e:
            logger.error(f"❌ Error recargando datos: {e}")
            return False
    
    def verificar_integridad_venta(self, id_venta):
        """Verifica la integridad de una venta y sus detalles."""
        try:
            venta = self.obtener_venta_por_id(id_venta)
            if not venta:
                return {'valida': False, 'errores': ['Venta no encontrada']}
            
            detalles = self.obtener_detalles_venta(id_venta)
            errores = []
            
            # Verificar que tiene detalles
            if not detalles:
                errores.append('La venta no tiene detalles')
            
            # Verificar totales
            subtotal_calculado = sum(float(d['subtotal']) for d in detalles)
            total_calculado = sum(float(d['total']) for d in detalles)
            
            if abs(float(venta['subtotal']) - subtotal_calculado) > 0.01:
                errores.append(f"Subtotal inconsistente: {venta['subtotal']} vs {subtotal_calculado}")
            
            if abs(float(venta['total']) - total_calculado) > 0.01:
                errores.append(f"Total inconsistente: {venta['total']} vs {total_calculado}")
            
            # Verificar cliente existe
            try:
                cliente = self.obtener_cliente_por_id(venta['id_cliente'])
                if not cliente:
                    errores.append('Cliente asociado no encontrado')
            except:
                errores.append('Error verificando cliente')
            
            # Verificar estado existe
            try:
                estado = self.estado_repo.obtener_por_id(venta['id_estado'])
                if not estado:
                    errores.append('Estado de venta no encontrado')
            except:
                errores.append('Error verificando estado')
            
            integridad = {
                'valida': len(errores) == 0,
                'errores': errores,
                'venta': venta,
                'detalles_count': len(detalles),
                'subtotal_calculado': subtotal_calculado,
                'total_calculado': total_calculado
            }
            
            return integridad
            
        except Exception as e:
            logger.error(f"Error verificando integridad de venta {id_venta}: {str(e)}")
            return {'valida': False, 'errores': [f'Error interno: {str(e)}']}
    
    def transferir_cliente_ventas(self, id_cliente_origen, id_cliente_destino):
        """Transfiere todas las ventas de un cliente a otro (operación administrativa)."""
        try:
            # Verificar que ambos clientes existen
            cliente_origen = self.obtener_cliente_por_id(id_cliente_origen)
            cliente_destino = self.obtener_cliente_por_id(id_cliente_destino)
            
            if not cliente_origen or not cliente_destino:
                return {
                    'exito': False,
                    'mensaje': 'Uno o ambos clientes no existen'
                }
            
            # Obtener ventas del cliente origen
            ventas = self.obtener_ventas_por_cliente(id_cliente_origen)
            
            if not ventas:
                return {
                    'exito': True,
                    'mensaje': 'No hay ventas para transferir',
                    'ventas_transferidas': 0
                }
            
            # Transferir ventas (esto requeriría acceso directo al repositorio)
            # Por seguridad, esta operación debería hacerse directamente en BD
            logger.warning(f"Transferencia de ventas solicitada: {len(ventas)} ventas de cliente {id_cliente_origen} a {id_cliente_destino}")
            
            return {
                'exito': False,
                'mensaje': 'Operación requiere acceso directo a base de datos',
                'ventas_encontradas': len(ventas)
            }
            
        except Exception as e:
            logger.error(f"Error en transferencia de ventas: {str(e)}")
            return {'exito': False, 'mensaje': f'Error interno: {str(e)}'}

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        return datetime.now().isoformat()
    
    def obtener_resumen_sistema(self):
        """Obtiene un resumen del estado del sistema."""
        try:
            resumen = {
                'clientes': {
                    'total_activos': len(self.obtener_clientes()),
                    'clasificacion': len(self.clasificar_clientes_por_volumen())
                },
                'ventas': {
                    'total': len(self.obtener_ventas()),
                    'pagos_pendientes': len(self.obtener_pagos_pendientes()),
                    'ventas_vencidas': len(self.obtener_ventas_vencidas())
                },
                'estados_venta': len(self.obtener_estados_venta()),
                'variedades_disponibles': len(self.obtener_variedades_disponibles()),
                'timestamp': self._get_timestamp(),
                'cache_stats': self.obtener_estadisticas_cache()
            }
            
            return resumen
        except Exception as e:
            logger.error(f"Error obteniendo resumen del sistema: {str(e)}")
            return {'error': str(e), 'timestamp': self._get_timestamp()}