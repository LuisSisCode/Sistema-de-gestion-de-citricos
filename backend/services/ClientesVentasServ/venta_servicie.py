"""
Servicio de Ventas
Capa de lógica de negocio - Validaciones, análisis, orquestación
Usa VentaRepositorio para acceso a datos
"""

import logging
from datetime import datetime, timedelta, date
from typing import List, Dict, Optional, Tuple
from backend.repositories.ClientesVentasRep.venta_repositorio import VentaRepositorio
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

# Configurar logging
logger = logging.getLogger('venta_service')


class VentaService:
    """
    Servicio de lógica de negocio para ventas.
    Responsabilidad: Validaciones, análisis, cálculos complejos, orquestación.
    """
    
    def __init__(self):
        """Inicializa el servicio con su repositorio."""
        self.repo = VentaRepositorio()
        logger.info("✅ VentaService inicializado correctamente.")
    
    # ==================== CRUD CON LÓGICA DE NEGOCIO ====================
    
    @cacheable('ventas', ttl=get_ttl('ventas'))
    def obtener_ventas(self) -> List[Dict]:
        """
        Obtiene todas las ventas con caché.
        
        Returns:
            List[Dict]: Lista de ventas.
        """
        try:
            ventas = self.repo.obtener_todas()
            logger.info(f"✅ Servicio: {len(ventas)} ventas obtenidas")
            return ventas
        except Exception as e:
            logger.error(f"❌ Error en servicio al obtener ventas: {str(e)}")
            return []
    
    @cacheable('ventas', key_func=lambda self, id_v: f"id_{id_v}")
    def obtener_venta(self, id_venta: int) -> Optional[Dict]:
        """
        Obtiene una venta por ID con caché.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            Dict con información de la venta o None.
        """
        try:
            venta = self.repo.obtener_por_id(id_venta)
            
            if venta:
                logger.info(f"✅ Venta {id_venta} obtenida")
            else:
                logger.warning(f"⚠️ Venta {id_venta} no encontrada")
            
            return venta
        except Exception as e:
            logger.error(f"❌ Error al obtener venta {id_venta}: {str(e)}")
            return None
    
    @cache_invalidator('ventas')
    def crear_venta(self, venta_data: Dict, detalles: List[Dict], registrado_por: int) -> Tuple[bool, str, Optional[int]]:
        """
        Crea una nueva venta con sus detalles.
        Incluye validación y cálculo de totales.
        
        Args:
            venta_data: Datos de la venta.
            detalles: Lista de detalles de la venta.
            registrado_por: ID del usuario que registra.
            
        Returns:
            Tuple[bool, str, Optional[int]]: (Éxito, Mensaje, ID de la venta)
        """
        try:
            # Validar datos de venta
            valido, mensaje = self.validar_datos_venta(venta_data)
            if not valido:
                logger.warning(f"⚠️ Validación fallida: {mensaje}")
                return False, mensaje, None
            
            # Validar detalles
            if not detalles or len(detalles) == 0:
                return False, "Debe agregar al menos un producto a la venta", None
            
            # Calcular totales
            subtotal = sum(float(d.get('subtotal', 0)) for d in detalles)
            total = subtotal  # Puedes agregar impuestos o descuentos aquí
            
            venta_data['subtotal'] = subtotal
            venta_data['total'] = total
            
            # Generar código si no viene
            if not venta_data.get('codigo_venta'):
                venta_data['codigo_venta'] = self.repo.generar_codigo_venta()
            
            # Crear venta
            exito, id_venta = self.repo.crear(venta_data, registrado_por)
            
            if not exito:
                return False, "Error al crear venta en la base de datos", None
            
            # Agregar detalles
            for detalle in detalles:
                detalle['id_venta'] = id_venta
                exito_detalle, _ = self.repo.agregar_detalle(detalle)
                if not exito_detalle:
                    logger.warning(f"⚠️ Error al agregar detalle a venta {id_venta}")
            
            logger.info(f"✅ Venta creada exitosamente: ID {id_venta}")
            return True, "Venta creada exitosamente", id_venta
                
        except Exception as e:
            logger.error(f"❌ Error al crear venta: {str(e)}")
            return False, f"Error al crear venta: {str(e)}", None
    
    @cache_invalidator('ventas')
    def actualizar_venta(self, id_venta: int, venta_data: Dict) -> Tuple[bool, str]:
        """
        Actualiza una venta existente con validación.
        
        Args:
            id_venta: ID de la venta a actualizar.
            venta_data: Datos actualizados.
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que la venta existe
            if not self.repo.existe_venta(id_venta):
                return False, f"Venta {id_venta} no encontrada"
            
            # Validar datos
            valido, mensaje = self.validar_datos_venta(venta_data)
            if not valido:
                logger.warning(f"⚠️ Validación fallida: {mensaje}")
                return False, mensaje
            
            # Actualizar
            exito = self.repo.actualizar(id_venta, venta_data)
            
            if exito:
                logger.info(f"✅ Venta {id_venta} actualizada")
                return True, "Venta actualizada exitosamente"
            else:
                return False, "Error al actualizar venta"
                
        except Exception as e:
            logger.error(f"❌ Error al actualizar venta: {str(e)}")
            return False, f"Error al actualizar venta: {str(e)}"
    
    @cache_invalidator('ventas')
    def eliminar_venta(self, id_venta: int) -> Tuple[bool, str]:
        """
        Elimina una venta con validaciones.
        
        Args:
            id_venta: ID de la venta a eliminar.
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que existe
            if not self.repo.existe_venta(id_venta):
                return False, f"Venta {id_venta} no encontrada"
            
            # Eliminar
            exito = self.repo.eliminar(id_venta)
            
            if exito:
                logger.info(f"✅ Venta {id_venta} eliminada")
                return True, "Venta eliminada exitosamente"
            else:
                return False, "Error al eliminar venta"
                
        except Exception as e:
            logger.error(f"❌ Error al eliminar venta: {str(e)}")
            return False, f"Error al eliminar venta: {str(e)}"
    
    # ==================== GESTIÓN DE DETALLES ====================
    
    def obtener_detalles_venta(self, id_venta: int) -> List[Dict]:
        """
        Obtiene los detalles de una venta.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            List[Dict]: Lista de detalles.
        """
        try:
            return self.repo.obtener_detalles_venta(id_venta)
        except Exception as e:
            logger.error(f"❌ Error al obtener detalles: {str(e)}")
            return []
    
    @cache_invalidator('ventas')
    def agregar_detalle_venta(self, detalle_data: Dict) -> Tuple[bool, str, Optional[int]]:
        """
        Agrega un detalle a una venta existente.
        
        Args:
            detalle_data: Datos del detalle.
            
        Returns:
            Tuple[bool, str, Optional[int]]: (Éxito, Mensaje, ID del detalle)
        """
        try:
            # Validar detalle
            valido, mensaje = self.validar_detalle_venta(detalle_data)
            if not valido:
                return False, mensaje, None
            
            # Agregar detalle
            exito, id_detalle = self.repo.agregar_detalle(detalle_data)
            
            if exito:
                # Recalcular totales de la venta
                self._recalcular_totales_venta(detalle_data['id_venta'])
                return True, "Detalle agregado exitosamente", id_detalle
            else:
                return False, "Error al agregar detalle", None
                
        except Exception as e:
            logger.error(f"❌ Error al agregar detalle: {str(e)}")
            return False, f"Error: {str(e)}", None
    
    @cache_invalidator('ventas')
    def actualizar_detalle_venta(self, id_detalle: int, detalle_data: Dict) -> Tuple[bool, str]:
        """
        Actualiza un detalle de venta.
        
        Args:
            id_detalle: ID del detalle.
            detalle_data: Datos actualizados.
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Validar
            valido, mensaje = self.validar_detalle_venta(detalle_data)
            if not valido:
                return False, mensaje
            
            # Actualizar
            exito = self.repo.actualizar_detalle(id_detalle, detalle_data)
            
            if exito:
                # Recalcular totales
                self._recalcular_totales_venta(detalle_data['id_venta'])
                return True, "Detalle actualizado exitosamente"
            else:
                return False, "Error al actualizar detalle"
                
        except Exception as e:
            logger.error(f"❌ Error al actualizar detalle: {str(e)}")
            return False, f"Error: {str(e)}"
    
    @cache_invalidator('ventas')
    def eliminar_detalle_venta(self, id_detalle: int, id_venta: int) -> Tuple[bool, str]:
        """
        Elimina un detalle de venta.
        
        Args:
            id_detalle: ID del detalle.
            id_venta: ID de la venta (para recalcular totales).
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            exito = self.repo.eliminar_detalle(id_detalle)
            
            if exito:
                # Recalcular totales
                self._recalcular_totales_venta(id_venta)
                return True, "Detalle eliminado exitosamente"
            else:
                return False, "Error al eliminar detalle"
                
        except Exception as e:
            logger.error(f"❌ Error al eliminar detalle: {str(e)}")
            return False, f"Error: {str(e)}"
    
    # ==================== BÚSQUEDAS Y FILTROS ====================
    
    @cacheable('ventas', key_func=lambda self, criterio: f"buscar_{criterio}", ttl=900)
    def buscar_ventas(self, criterio: str) -> List[Dict]:
        """
        Busca ventas por criterio con caché.
        
        Args:
            criterio: Texto a buscar.
            
        Returns:
            List[Dict]: Ventas que coinciden.
        """
        try:
            if not criterio or len(criterio.strip()) < 2:
                logger.warning("⚠️ Criterio de búsqueda muy corto")
                return []
            
            ventas = self.repo.buscar_por_criterio(criterio.strip())
            logger.info(f"🔍 Búsqueda '{criterio}': {len(ventas)} resultados")
            return ventas
            
        except Exception as e:
            logger.error(f"❌ Error al buscar ventas: {str(e)}")
            return []
    
    def obtener_ventas_por_cliente(self, id_cliente: int) -> List[Dict]:
        """
        Obtiene todas las ventas de un cliente.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            List[Dict]: Ventas del cliente.
        """
        try:
            return self.repo.obtener_por_cliente(id_cliente)
        except Exception as e:
            logger.error(f"❌ Error al obtener ventas del cliente: {str(e)}")
            return []
    
    def obtener_ventas_por_periodo(self, fecha_inicio_str: str, fecha_fin_str: str) -> List[Dict]:
        """
        Obtiene ventas en un período.
        
        Args:
            fecha_inicio_str: Fecha de inicio (YYYY-MM-DD).
            fecha_fin_str: Fecha de fin (YYYY-MM-DD).
            
        Returns:
            List[Dict]: Ventas del período.
        """
        try:
            fecha_inicio = datetime.strptime(fecha_inicio_str, '%Y-%m-%d').date()
            fecha_fin = datetime.strptime(fecha_fin_str, '%Y-%m-%d').date()
            
            return self.repo.obtener_por_periodo(fecha_inicio, fecha_fin)
        except Exception as e:
            logger.error(f"❌ Error al obtener ventas por período: {str(e)}")
            return []
    
    def obtener_ventas_pendientes(self) -> List[Dict]:
        """
        Obtiene ventas con pago pendiente.
        
        Returns:
            List[Dict]: Ventas pendientes.
        """
        try:
            return self.repo.obtener_por_estado_pago('Pendiente')
        except Exception as e:
            logger.error(f"❌ Error al obtener ventas pendientes: {str(e)}")
            return []
    
    # ==================== REPORTES Y ANÁLISIS ====================
    
    @cacheable('ventas_analisis', key_func=lambda self: 'resumen_mes', ttl=1800)
    def obtener_resumen_mes_actual(self) -> Dict:
        """
        Obtiene resumen de ventas del mes actual.
        
        Returns:
            Dict: Resumen con totales y estadísticas.
        """
        try:
            hoy = date.today()
            primer_dia = date(hoy.year, hoy.month, 1)
            
            if hoy.month == 12:
                ultimo_dia = date(hoy.year + 1, 1, 1) - timedelta(days=1)
            else:
                ultimo_dia = date(hoy.year, hoy.month + 1, 1) - timedelta(days=1)
            
            ventas = self.repo.obtener_por_periodo(primer_dia, ultimo_dia)
            
            total_ventas = len(ventas)
            monto_total = sum(v['total'] for v in ventas)
            pendientes = sum(1 for v in ventas if v['estado_pago'] == 'Pendiente')
            monto_pendiente = sum(v['total'] for v in ventas if v['estado_pago'] == 'Pendiente')
            
            resumen = {
                'mes': hoy.month,
                'año': hoy.year,
                'total_ventas': total_ventas,
                'monto_total': monto_total,
                'ventas_pendientes': pendientes,
                'monto_pendiente': monto_pendiente,
                'ventas_pagadas': total_ventas - pendientes,
                'promedio_venta': monto_total / total_ventas if total_ventas > 0 else 0
            }
            
            logger.info(f"📊 Resumen mes actual: {total_ventas} ventas, ${monto_total:,.2f}")
            return resumen
            
        except Exception as e:
            logger.error(f"❌ Error al obtener resumen del mes: {str(e)}")
            return {}
    
    def calcular_estadisticas_venta(self, id_venta: int) -> Optional[Dict]:
        """
        Calcula estadísticas para una venta específica.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            Dict con estadísticas o None.
        """
        try:
            venta = self.repo.obtener_por_id(id_venta)
            if not venta:
                return None
            
            detalles = self.repo.obtener_detalles_venta(id_venta)
            
            estadisticas = {
                **venta,
                'cantidad_productos': len(detalles),
                'total_items': sum(d['cantidad'] for d in detalles),
                'precio_promedio': venta['total'] / len(detalles) if detalles else 0
            }
            
            return estadisticas
            
        except Exception as e:
            logger.error(f"❌ Error al calcular estadísticas: {str(e)}")
            return None
    
    # ==================== VALIDACIONES ====================
    
    def validar_datos_venta(self, venta_data: Dict) -> Tuple[bool, str]:
        """
        Valida los datos de una venta.
        
        Args:
            venta_data: Datos de la venta.
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error)
        """
        # Validar cliente
        if not venta_data.get('id_cliente'):
            return False, "Debe seleccionar un cliente"
        
        # Validar fecha
        if not venta_data.get('fecha_venta'):
            return False, "Debe especificar la fecha de venta"
        
        # Validar estado de pago
        estados_validos = ['Pendiente', 'Pagado', 'Parcial']
        if venta_data.get('estado_pago') and venta_data['estado_pago'] not in estados_validos:
            return False, f"Estado de pago inválido. Use: {', '.join(estados_validos)}"
        
        return True, "Datos válidos"
    
    def validar_detalle_venta(self, detalle_data: Dict) -> Tuple[bool, str]:
        """
        Valida los datos de un detalle de venta.
        
        Args:
            detalle_data: Datos del detalle.
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error)
        """
        # Validar cantidad
        if not detalle_data.get('cantidad') or float(detalle_data['cantidad']) <= 0:
            return False, "La cantidad debe ser mayor a 0"
        
        # Validar precio
        if not detalle_data.get('precio_unitario') or float(detalle_data['precio_unitario']) <= 0:
            return False, "El precio unitario debe ser mayor a 0"
        
        # Validar subtotal
        cantidad = float(detalle_data['cantidad'])
        precio = float(detalle_data['precio_unitario'])
        subtotal = float(detalle_data.get('subtotal', 0))
        
        if abs(subtotal - (cantidad * precio)) > 0.01:  # Tolerancia de 1 centavo
            return False, "El subtotal no coincide con cantidad x precio"
        
        return True, "Datos válidos"
    
    # ==================== MÉTODOS AUXILIARES ====================
    
    def _recalcular_totales_venta(self, id_venta: int):
        """
        Recalcula los totales de una venta basándose en sus detalles.
        
        Args:
            id_venta: ID de la venta.
        """
        try:
            detalles = self.repo.obtener_detalles_venta(id_venta)
            subtotal = sum(d['subtotal'] for d in detalles)
            total = subtotal  # Aquí puedes agregar impuestos o descuentos
            
            venta_data = {
                'subtotal': subtotal,
                'total': total
            }
            
            # Obtener datos actuales de la venta para no perder información
            venta_actual = self.repo.obtener_por_id(id_venta)
            if venta_actual:
                venta_data.update({
                    'fecha_venta': venta_actual['fecha_venta'],
                    'id_cliente': venta_actual['id_cliente'],
                    'fecha_entrega': venta_actual.get('fecha_entrega'),
                    'estado_pago': venta_actual['estado_pago'],
                    'observaciones': venta_actual.get('observaciones')
                })
                
                self.repo.actualizar(id_venta, venta_data)
                logger.info(f"✅ Totales recalculados para venta {id_venta}")
            
        except Exception as e:
            logger.error(f"❌ Error al recalcular totales: {str(e)}")
    
    def generar_codigo_venta(self) -> str:
        """
        Genera un código único para una nueva venta.
        
        Returns:
            str: Código generado.
        """
        return self.repo.generar_codigo_venta()


# Ejemplo de uso y testing
if __name__ == "__main__":
    try:
        service = VentaService()
        
        # Obtener todas las ventas
        ventas = service.obtener_ventas()
        print(f"✅ Total de ventas: {len(ventas)}")
        
        # Resumen del mes
        resumen = service.obtener_resumen_mes_actual()
        print(f"✅ Resumen del mes:")
        print(f"   Total ventas: {resumen.get('total_ventas', 0)}")
        print(f"   Monto total: ${resumen.get('monto_total', 0):,.2f}")
        
        # Ventas pendientes
        pendientes = service.obtener_ventas_pendientes()
        print(f"✅ Ventas pendientes: {len(pendientes)}")
        
    except Exception as e:
        print(f"❌ Error en prueba: {str(e)}")