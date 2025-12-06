"""
Modelo Qt de Ventas - CORREGIDO
Capa de presentación - Bridge entre Python y QML
Expone funcionalidad del servicio como Slots Qt
"""

import logging
import json
from PySide6.QtCore import QObject, Slot, Signal, Property
from typing import List, Dict
from backend.services.ClientesVentasServ.venta_servicie import VentaService

# Configurar logging
logger = logging.getLogger('ventas_model')


class VentasModel(QObject):
    """
    Modelo Qt para gestión de ventas.
    Responsabilidad: Exponer datos y operaciones a QML mediante señales y slots.
    """
    
    # ==================== SEÑALES ====================
    
    ventasActualizadas = Signal()
    ventaCargada = Signal()
    errorOcurrido = Signal(str)  # Emite mensaje de error
    operacionExitosa = Signal(str)  # Emite mensaje de éxito
    
    ventaAgregada = Signal(int)  # Emite ID de la nueva venta
    ventaActualizada = Signal(int)  # Emite ID de la venta actualizada
    ventaEliminada = Signal(int)  # Emite ID de la venta eliminada
    
    detallesActualizados = Signal(int)  # Emite ID de venta cuyos detalles cambiaron
    busquedaCompletada = Signal(int)  # Emite cantidad de resultados
    
    def __init__(self):
        """Inicializa el modelo con su servicio."""
        super().__init__()
        self.service = VentaService()
        self._ventas = []
        self._venta_actual = None
        logger.info("✅ VentasModel inicializado correctamente")
    
    # ==================== PROPERTIES ====================
    
    @Property(int, notify=ventasActualizadas)
    def totalVentas(self) -> int:
        """Retorna el total de ventas cargadas."""
        return len(self._ventas)
    
    # ==================== CRUD OPERATIONS ====================
    
    @Slot(result='QVariantList')
    def obtenerVentas(self) -> List[Dict]:
        """
        Obtiene todas las ventas.
        
        Returns:
            Lista de ventas para QML.
        """
        try:
            logger.info("📊 Obteniendo ventas desde QML...")
            self._ventas = self.service.obtener_ventas()
            
            # NO emitir ventasActualizadas aquí para evitar loops infinitos
            logger.info(f"✅ {len(self._ventas)} ventas obtenidas")
            
            return self._ventas
            
        except Exception as e:
            error_msg = f"Error al obtener ventas: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(int, result='QVariant')
    def obtenerVenta(self, id_venta: int) -> Dict:
        """
        Obtiene una venta específica por ID.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            Diccionario con datos de la venta o vacío si no se encuentra.
        """
        try:
            logger.info(f"🔍 Obteniendo venta {id_venta}...")
            venta = self.service.obtener_venta(id_venta)
            
            if venta:
                self._venta_actual = venta
                self.ventaCargada.emit()
                logger.info(f"✅ Venta {id_venta} cargada")
                return venta
            else:
                error_msg = f"Venta {id_venta} no encontrada"
                logger.warning(f"⚠️ {error_msg}")
                self.errorOcurrido.emit(error_msg)
                return {}
                
        except Exception as e:
            error_msg = f"Error al obtener venta: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return {}
    
    @Slot('QVariantMap', 'QVariantList', int, result=bool)
    def agregarVenta(self, venta_data: Dict, detalles: List[Dict], registrado_por: int) -> bool:
        """
        Agrega una nueva venta con sus detalles.
        
        Args:
            venta_data: Datos de la venta desde QML.
            detalles: Lista de detalles de la venta.
            registrado_por: ID del usuario que registra.
            
        Returns:
            True si se agregó correctamente.
        """
        try:
            logger.info(f"➕ Agregando nueva venta...")
            
            exito, mensaje, id_venta = self.service.crear_venta(venta_data, detalles, registrado_por)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_venta})")
                self.operacionExitosa.emit(mensaje)
                self.ventaAgregada.emit(id_venta)
                # Solo emitir ventasActualizadas después de modificar datos
                self.ventasActualizadas.emit()
                return True
            else:
                logger.warning(f"⚠️ {mensaje}")
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al agregar venta: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    @Slot(int, 'QVariantMap', result=bool)
    def actualizarVenta(self, id_venta: int, venta_data: Dict) -> bool:
        """
        Actualiza una venta existente.
        
        Args:
            id_venta: ID de la venta a actualizar.
            venta_data: Datos actualizados desde QML.
            
        Returns:
            True si se actualizó correctamente.
        """
        try:
            logger.info(f"✏️ Actualizando venta {id_venta}...")
            
            exito, mensaje = self.service.actualizar_venta(id_venta, venta_data)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.operacionExitosa.emit(mensaje)
                self.ventaActualizada.emit(id_venta)
                # Solo emitir ventasActualizadas después de modificar datos
                self.ventasActualizadas.emit()
                return True
            else:
                logger.warning(f"⚠️ {mensaje}")
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al actualizar venta: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    @Slot(int, result=bool)
    def eliminarVenta(self, id_venta: int) -> bool:
        """
        Elimina una venta.
        
        Args:
            id_venta: ID de la venta a eliminar.
            
        Returns:
            True si se eliminó correctamente.
        """
        try:
            logger.info(f"🗑️ Eliminando venta {id_venta}...")
            
            exito, mensaje = self.service.eliminar_venta(id_venta)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.operacionExitosa.emit(mensaje)
                self.ventaEliminada.emit(id_venta)
                # Solo emitir ventasActualizadas después de modificar datos
                self.ventasActualizadas.emit()
                return True
            else:
                logger.warning(f"⚠️ {mensaje}")
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al eliminar venta: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    # ==================== GESTIÓN DE DETALLES ====================
    
    @Slot(int, result='QVariantList')
    def obtenerDetallesVenta(self, id_venta: int) -> List[Dict]:
        """
        Obtiene los detalles de una venta.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            Lista de detalles.
        """
        try:
            logger.info(f"📋 Obteniendo detalles de venta {id_venta}...")
            detalles = self.service.obtener_detalles_venta(id_venta)
            logger.info(f"✅ {len(detalles)} detalles obtenidos")
            return detalles
        except Exception as e:
            error_msg = f"Error al obtener detalles: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot('QVariantMap', result=bool)
    def agregarDetalleVenta(self, detalle_data: Dict) -> bool:
        """
        Agrega un detalle a una venta.
        
        Args:
            detalle_data: Datos del detalle.
            
        Returns:
            True si se agregó correctamente.
        """
        try:
            exito, mensaje, id_detalle = self.service.agregar_detalle_venta(detalle_data)
            
            if exito:
                self.operacionExitosa.emit(mensaje)
                self.detallesActualizados.emit(detalle_data['id_venta'])
                return True
            else:
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al agregar detalle: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    @Slot(int, 'QVariantMap', result=bool)
    def actualizarDetalleVenta(self, id_detalle: int, detalle_data: Dict) -> bool:
        """
        Actualiza un detalle de venta.
        
        Args:
            id_detalle: ID del detalle.
            detalle_data: Datos actualizados.
            
        Returns:
            True si se actualizó.
        """
        try:
            exito, mensaje = self.service.actualizar_detalle_venta(id_detalle, detalle_data)
            
            if exito:
                self.operacionExitosa.emit(mensaje)
                self.detallesActualizados.emit(detalle_data['id_venta'])
                return True
            else:
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al actualizar detalle: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    @Slot(int, int, result=bool)
    def eliminarDetalleVenta(self, id_detalle: int, id_venta: int) -> bool:
        """
        Elimina un detalle de venta.
        
        Args:
            id_detalle: ID del detalle.
            id_venta: ID de la venta (para actualizar totales).
            
        Returns:
            True si se eliminó.
        """
        try:
            exito, mensaje = self.service.eliminar_detalle_venta(id_detalle, id_venta)
            
            if exito:
                self.operacionExitosa.emit(mensaje)
                self.detallesActualizados.emit(id_venta)
                return True
            else:
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al eliminar detalle: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    # ==================== BÚSQUEDAS ====================
    
    @Slot(str, result='QVariantList')
    def buscarVentas(self, criterio: str) -> List[Dict]:
        """
        Busca ventas por criterio.
        
        Args:
            criterio: Texto a buscar.
            
        Returns:
            Lista de ventas que coinciden.
        """
        try:
            logger.info(f"🔍 Buscando ventas: '{criterio}'...")
            
            if not criterio or len(criterio.strip()) < 2:
                self.errorOcurrido.emit("Debe ingresar al menos 2 caracteres para buscar")
                return []
            
            resultados = self.service.buscar_ventas(criterio)
            
            self.busquedaCompletada.emit(len(resultados))
            logger.info(f"✅ Búsqueda completada: {len(resultados)} resultados")
            
            return resultados
            
        except Exception as e:
            error_msg = f"Error al buscar ventas: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(int, result='QVariantList')
    def obtenerVentasPorCliente(self, id_cliente: int) -> List[Dict]:
        """
        Obtiene ventas de un cliente específico.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            Lista de ventas del cliente.
        """
        try:
            ventas = self.service.obtener_ventas_por_cliente(id_cliente)
            logger.info(f"✅ {len(ventas)} ventas del cliente {id_cliente}")
            return ventas
        except Exception as e:
            error_msg = f"Error al obtener ventas del cliente: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(str, str, result='QVariantList')
    def obtenerVentasPorPeriodo(self, fecha_inicio: str, fecha_fin: str) -> List[Dict]:
        """
        Obtiene ventas en un período.
        
        Args:
            fecha_inicio: Fecha de inicio (YYYY-MM-DD).
            fecha_fin: Fecha de fin (YYYY-MM-DD).
            
        Returns:
            Lista de ventas del período.
        """
        try:
            ventas = self.service.obtener_ventas_por_periodo(fecha_inicio, fecha_fin)
            logger.info(f"✅ {len(ventas)} ventas en el período")
            return ventas
        except Exception as e:
            error_msg = f"Error al obtener ventas por período: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(result='QVariantList')
    def obtenerVentasPendientes(self) -> List[Dict]:
        """
        Obtiene ventas con pago pendiente.
        
        Returns:
            Lista de ventas pendientes.
        """
        try:
            ventas = self.service.obtener_ventas_pendientes()
            logger.info(f"✅ {len(ventas)} ventas pendientes")
            return ventas
        except Exception as e:
            error_msg = f"Error al obtener ventas pendientes: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    # ==================== REPORTES Y ANÁLISIS ====================
    
    @Slot(result='QVariant')
    def obtenerResumenMesActual(self) -> Dict:
        """
        Obtiene resumen del mes actual.
        
        Returns:
            Diccionario con resumen.
        """
        try:
            logger.info("📊 Obteniendo resumen del mes...")
            resumen = self.service.obtener_resumen_mes_actual()
            logger.info(f"✅ Resumen obtenido")
            return resumen
        except Exception as e:
            error_msg = f"Error al obtener resumen: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return {}
    
    @Slot(int, result='QVariant')
    def calcularEstadisticasVenta(self, id_venta: int) -> Dict:
        """
        Calcula estadísticas de una venta.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            Diccionario con estadísticas.
        """
        try:
            estadisticas = self.service.calcular_estadisticas_venta(id_venta)
            if estadisticas:
                return estadisticas
            return {}
        except Exception as e:
            error_msg = f"Error al calcular estadísticas: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return {}
    
    # ==================== UTILIDADES ====================
    
    @Slot(result=str)
    def generarCodigoVenta(self) -> str:
        """
        Genera un código único para una nueva venta.
        
        Returns:
            String con el código generado.
        """
        try:
            codigo = self.service.generar_codigo_venta()
            logger.info(f"✅ Código generado: {codigo}")
            return codigo
        except Exception as e:
            logger.error(f"❌ Error al generar código: {str(e)}")
            return "V-0001"
    
    @Slot()
    def recargarVentas(self):
        """
        Recarga todas las ventas desde la base de datos.
        """
        try:
            logger.info("🔄 Recargando ventas...")
            self._ventas = self.service.obtener_ventas()
            # Emitir señal solo después de recargar explícitamente
            self.ventasActualizadas.emit()
            logger.info(f"✅ {len(self._ventas)} ventas recargadas")
        except Exception as e:
            error_msg = f"Error al recargar ventas: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
    
    @Slot()
    def limpiarVentaActual(self):
        """Limpia la venta actual cargada."""
        self._venta_actual = None
        self.ventaCargada.emit()