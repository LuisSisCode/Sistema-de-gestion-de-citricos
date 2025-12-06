"""
Modelo Qt de Clientes - CORREGIDO
Capa de presentación - Bridge entre Python y QML
Expone funcionalidad del servicio como Slots Qt
"""

import logging
import json
from PySide6.QtCore import QObject, Slot, Signal, Property
from typing import List, Dict
from backend.services.ClientesVentasServ.cliente_service import ClienteService

# Configurar logging
logger = logging.getLogger('clientes_model')


class ClientesModel(QObject):
    """
    Modelo Qt para gestión de clientes.
    Responsabilidad: Exponer datos y operaciones a QML mediante señales y slots.
    """
    
    # ==================== SEÑALES ====================
    
    clientesActualizados = Signal()
    clienteCargado = Signal()
    errorOcurrido = Signal(str)  # Emite mensaje de error
    operacionExitosa = Signal(str)  # Emite mensaje de éxito
    
    clienteAgregado = Signal(int)  # Emite ID del nuevo cliente
    clienteActualizado = Signal(int)  # Emite ID del cliente actualizado
    clienteEliminado = Signal(int)  # Emite ID del cliente eliminado
    
    busquedaCompletada = Signal(int)  # Emite cantidad de resultados
    
    def __init__(self):
        """Inicializa el modelo con su servicio."""
        super().__init__()
        self.service = ClienteService()
        self._clientes = []
        self._cliente_actual = None
        logger.info("✅ ClientesModel inicializado correctamente")
    
    # ==================== PROPERTIES ====================
    
    @Property(int, notify=clientesActualizados)
    def totalClientes(self) -> int:
        """Retorna el total de clientes cargados."""
        return len(self._clientes)
    
    # ==================== CRUD OPERATIONS ====================
    
    @Slot(result='QVariantList')
    def obtenerClientes(self) -> List[Dict]:
        """
        Obtiene todos los clientes activos.
        
        Returns:
            Lista de clientes para QML.
        """
        try:
            logger.info("📊 Obteniendo clientes desde QML...")
            self._clientes = self.service.obtener_clientes()
            
            # NO emitir clientesActualizados aquí para evitar loops infinitos
            logger.info(f"✅ {len(self._clientes)} clientes obtenidos")
            
            return self._clientes
            
        except Exception as e:
            error_msg = f"Error al obtener clientes: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(int, result='QVariant')
    def obtenerCliente(self, id_cliente: int) -> Dict:
        """
        Obtiene un cliente específico por ID.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            Diccionario con datos del cliente o vacío si no se encuentra.
        """
        try:
            logger.info(f"🔍 Obteniendo cliente {id_cliente}...")
            cliente = self.service.obtener_cliente(id_cliente)
            
            if cliente:
                self._cliente_actual = cliente
                self.clienteCargado.emit()
                logger.info(f"✅ Cliente {id_cliente} cargado")
                return cliente
            else:
                error_msg = f"Cliente {id_cliente} no encontrado"
                logger.warning(f"⚠️ {error_msg}")
                self.errorOcurrido.emit(error_msg)
                return {}
                
        except Exception as e:
            error_msg = f"Error al obtener cliente: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return {}
    
    @Slot('QVariantMap', int, result=bool)
    def agregarCliente(self, cliente_data: Dict, registrado_por: int) -> bool:
        """
        Agrega un nuevo cliente.
        
        Args:
            cliente_data: Datos del cliente desde QML.
            registrado_por: ID del usuario que registra.
            
        Returns:
            True si se agregó correctamente.
        """
        try:
            logger.info(f"➕ Agregando nuevo cliente: {cliente_data.get('nombre')}...")
            
            exito, mensaje, id_cliente = self.service.crear_cliente(cliente_data, registrado_por)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_cliente})")
                self.operacionExitosa.emit(mensaje)
                self.clienteAgregado.emit(id_cliente)
                # Solo emitir clientesActualizados después de modificar datos
                self.clientesActualizados.emit()
                return True
            else:
                logger.warning(f"⚠️ {mensaje}")
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al agregar cliente: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    @Slot(int, 'QVariantMap', result=bool)
    def actualizarCliente(self, id_cliente: int, cliente_data: Dict) -> bool:
        """
        Actualiza un cliente existente.
        
        Args:
            id_cliente: ID del cliente a actualizar.
            cliente_data: Datos actualizados desde QML.
            
        Returns:
            True si se actualizó correctamente.
        """
        try:
            logger.info(f"✏️ Actualizando cliente {id_cliente}...")
            
            exito, mensaje = self.service.actualizar_cliente(id_cliente, cliente_data)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.operacionExitosa.emit(mensaje)
                self.clienteActualizado.emit(id_cliente)
                # Solo emitir clientesActualizados después de modificar datos
                self.clientesActualizados.emit()
                return True
            else:
                logger.warning(f"⚠️ {mensaje}")
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al actualizar cliente: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    @Slot(int, result=bool)
    def eliminarCliente(self, id_cliente: int) -> bool:
        """
        Elimina lógicamente un cliente.
        
        Args:
            id_cliente: ID del cliente a eliminar.
            
        Returns:
            True si se eliminó correctamente.
        """
        try:
            logger.info(f"🗑️ Eliminando cliente {id_cliente}...")
            
            exito, mensaje = self.service.eliminar_cliente(id_cliente)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.operacionExitosa.emit(mensaje)
                self.clienteEliminado.emit(id_cliente)
                # Solo emitir clientesActualizados después de modificar datos
                self.clientesActualizados.emit()
                return True
            else:
                logger.warning(f"⚠️ {mensaje}")
                self.errorOcurrido.emit(mensaje)
                return False
                
        except Exception as e:
            error_msg = f"Error al eliminar cliente: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    # ==================== BÚSQUEDAS ====================
    
    @Slot(str, result='QVariantList')
    def buscarClientes(self, criterio: str) -> List[Dict]:
        """
        Busca clientes por criterio.
        
        Args:
            criterio: Texto a buscar.
            
        Returns:
            Lista de clientes que coinciden.
        """
        try:
            logger.info(f"🔍 Buscando clientes: '{criterio}'...")
            
            if not criterio or len(criterio.strip()) < 2:
                self.errorOcurrido.emit("Debe ingresar al menos 2 caracteres para buscar")
                return []
            
            resultados = self.service.buscar_clientes(criterio)
            
            self.busquedaCompletada.emit(len(resultados))
            logger.info(f"✅ Búsqueda completada: {len(resultados)} resultados")
            
            return resultados
            
        except Exception as e:
            error_msg = f"Error al buscar clientes: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(result='QVariantList')
    def obtenerClientesClasificados(self) -> List[Dict]:
        """
        Obtiene clientes clasificados por volumen de compras.
        
        Returns:
            Lista de clientes con categoría asignada.
        """
        try:
            logger.info("📊 Obteniendo clientes clasificados...")
            
            clientes = self.service.clasificar_clientes_por_volumen()
            
            logger.info(f"✅ {len(clientes)} clientes clasificados")
            return clientes
            
        except Exception as e:
            error_msg = f"Error al clasificar clientes: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(int, result='QVariantList')
    def obtenerClientesInactivos(self, dias_inactividad: int = 90) -> List[Dict]:
        """
        Obtiene clientes inactivos (sin compras en X días).
        
        Args:
            dias_inactividad: Días sin compras para considerar inactivo.
            
        Returns:
            Lista de clientes inactivos.
        """
        try:
            logger.info(f"📊 Obteniendo clientes inactivos ({dias_inactividad} días)...")
            
            inactivos = self.service.obtener_clientes_inactivos(dias_inactividad)
            
            logger.info(f"✅ {len(inactivos)} clientes inactivos encontrados")
            return inactivos
            
        except Exception as e:
            error_msg = f"Error al obtener clientes inactivos: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(int, result='QVariantList')
    def obtenerMejoresClientes(self, limite: int = 10) -> List[Dict]:
        """
        Obtiene los N mejores clientes por volumen de compras.
        
        Args:
            limite: Número de clientes a retornar.
            
        Returns:
            Top N clientes.
        """
        try:
            logger.info(f"🏆 Obteniendo top {limite} clientes...")
            
            mejores = self.service.obtener_mejores_clientes(limite)
            
            logger.info(f"✅ Top {limite} clientes obtenidos")
            return mejores
            
        except Exception as e:
            error_msg = f"Error al obtener mejores clientes: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return []
    
    @Slot(int, result='QVariant')
    def obtenerEstadisticasCliente(self, id_cliente: int) -> Dict:
        """
        Obtiene estadísticas detalladas de un cliente.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            Diccionario con estadísticas del cliente.
        """
        try:
            logger.info(f"📊 Obteniendo estadísticas del cliente {id_cliente}...")
            
            estadisticas = self.service.calcular_estadisticas_cliente(id_cliente)
            
            if estadisticas:
                logger.info(f"✅ Estadísticas obtenidas")
                return estadisticas
            else:
                return {}
                
        except Exception as e:
            error_msg = f"Error al obtener estadísticas: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return {}
    
    # ==================== VALIDACIONES ====================
    
    @Slot('QVariantMap', result=bool)
    def validarDatosCliente(self, cliente_data: Dict) -> bool:
        """
        Valida los datos de un cliente antes de guardar.
        
        Args:
            cliente_data: Datos del cliente a validar.
            
        Returns:
            True si los datos son válidos.
        """
        try:
            valido, mensaje = self.service.validar_datos_cliente(cliente_data)
            
            if not valido:
                self.errorOcurrido.emit(mensaje)
                
            return valido
            
        except Exception as e:
            error_msg = f"Error al validar datos: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
    
    @Slot(int, result=bool)
    def clienteTieneVentas(self, id_cliente: int) -> bool:
        """
        Verifica si un cliente tiene ventas asociadas.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            True si tiene ventas.
        """
        try:
            return self.service.cliente_tiene_ventas(id_cliente)
        except Exception as e:
            logger.error(f"❌ Error al verificar ventas: {str(e)}")
            return False
    
    # ==================== MÉTODOS DE RECARGA ====================
    
    @Slot()
    def recargarClientes(self):
        """
        Recarga todos los clientes desde la base de datos.
        """
        try:
            logger.info("🔄 Recargando clientes...")
            self._clientes = self.service.obtener_clientes()
            # Emitir señal solo después de recargar explícitamente
            self.clientesActualizados.emit()
            logger.info(f"✅ {len(self._clientes)} clientes recargados")
        except Exception as e:
            error_msg = f"Error al recargar clientes: {str(e)}"
            logger.error(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
    
    @Slot()
    def limpiarClienteActual(self):
        """Limpia el cliente actual cargado."""
        self._cliente_actual = None
        self.clienteCargado.emit()