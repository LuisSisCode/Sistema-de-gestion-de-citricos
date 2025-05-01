from PySide6.QtCore import QObject, Slot, Signal, Property, QDate
from bd_ventas_clientes_integrado import GestorClientesVentas
from cultivos_model import CultivosModel
from datetime import datetime, timedelta
from user_session import get_current_user_id
import json
import logging

# Configurar logging si no está configurado
logger = logging.getLogger('ventas_cliente_model')

class ClientesVentaModel(QObject):
    """
    Modelo para gestionar la interfaz entre la base de datos y la UI QML
    para las funcionalidades de clientes y ventas.
    """
    
    # Señales para notificar cambios en los datos
    currentUserChanged = Signal()
    clientesChanged = Signal()
    ventasChanged = Signal()
    resumenVentasChanged = Signal()
    estadosVentaChanged = Signal()
    variedadesDisponiblesChanged = Signal()  # Renombrado de lotesDisponiblesChanged
    pagosPendientesChanged = Signal()
    ventasVencidasChanged = Signal()
    clienteTopChanged = Signal()
    clienteHistorialChanged = Signal()
    clientesClasificadosChanged = Signal()
    
    # Señal para notificar detalles de venta seleccionada
    ventaSeleccionadaChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._gestor = GestorClientesVentas()

        # Añadir referencia al modelo de cultivos
        self._cultivos_model = CultivosModel()
        
        # Inicializar listas y diccionarios
        self._clientes = []
        self._ventas = []
        self._resumen_ventas = {}
        self._estados_venta = []
        self._variedades_disponibles = []  # Renombrado de _lotes_disponibles
        self._pagos_pendientes = []
        self._ventas_vencidas = []
        self._cliente_top = {}
        self._cliente_historial = {}
        self._clientes_clasificados = []
        
        # Venta seleccionada
        self._venta_seleccionada = {}
        
        # Cargar datos iniciales
        self.cargar_clientes()
        self.cargar_ventas()
        self.cargar_estados_venta()
        self.cargar_variedades_disponibles()  # Renombrado de cargar_lotes_disponibles
        self.cargar_resumen_ventas_mes()
        self.cargar_pagos_pendientes()
        self.cargar_ventas_vencidas()
        self.cargar_cliente_top()
        self.cargar_clientes_clasificados()
    
    # ==================== PROPIEDADES ====================
    @Property(int, notify=currentUserChanged)
    def current_user_id(self):
        """Retorna el ID del usuario actual para QML"""
        return get_current_user_id()
    
    @Property(str, notify=currentUserChanged)
    def current_user_name(self):
        """Retorna el nombre del usuario actual para QML"""
        try:
            with open("current_user.json", "r") as f:
                data = json.load(f)
                return f"{data.get('nombre')} {data.get('apellido')}"
        except:
            return "Usuario Desconocido"
    
    @Property(list, notify=clientesChanged)
    def clientes(self):
        return self._clientes
    
    @Property(list, notify=ventasChanged)
    def ventas(self):
        return self._ventas
    
    @Property(dict, notify=resumenVentasChanged)
    def resumenVentas(self):
        return self._resumen_ventas
    
    @Property(list, notify=estadosVentaChanged)
    def estadosVenta(self):
        return self._estados_venta
    
    @Property(list, notify=variedadesDisponiblesChanged)  # Renombrado
    def variedadesDisponibles(self):  # Renombrado de lotesDisponibles
        return self._variedades_disponibles
    
    @Property(list, notify=pagosPendientesChanged)
    def pagosPendientes(self):
        return self._pagos_pendientes
    
    @Property(list, notify=ventasVencidasChanged)
    def ventasVencidas(self):
        return self._ventas_vencidas
    
    @Property(dict, notify=clienteTopChanged)
    def clienteTop(self):
        return self._cliente_top
    
    @Property(dict, notify=clienteHistorialChanged)
    def clienteHistorial(self):
        return self._cliente_historial
    
    @Property(list, notify=clientesClasificadosChanged)
    def clientesClasificados(self):
        return self._clientes_clasificados
    
    @Property(dict, notify=ventaSeleccionadaChanged)
    def ventaSeleccionada(self):
        return self._venta_seleccionada
    
    # ==================== SLOTS PARA CARGAR DATOS ====================
    
    @Slot()
    def cargar_clientes(self):
        """Carga la lista de clientes desde la base de datos"""
        try:
            self._clientes = self._gestor.obtener_clientes()
            self.clientesChanged.emit()
        except Exception as e:
            print(f"Error al cargar clientes: {str(e)}")
    
    @Slot()
    def cargar_ventas(self):
        """Carga la lista de ventas desde la base de datos"""
        try:
            self._ventas = self._gestor.obtener_ventas()
            self.ventasChanged.emit()
        except Exception as e:
            print(f"Error al cargar ventas: {str(e)}")
    
    @Slot()
    def cargar_estados_venta(self):
        """Carga los posibles estados de venta desde la base de datos"""
        try:
            self._estados_venta = self._gestor.obtener_estados_venta()
            self.estadosVentaChanged.emit()
        except Exception as e:
            print(f"Error al cargar estados de venta: {str(e)}")
    
    @Slot()
    def cargar_variedades_disponibles(self):  # Renombrado de cargar_lotes_disponibles
        """Carga las variedades disponibles para venta desde la base de datos"""
        try:
            self._variedades_disponibles = self._gestor.obtener_variedades_disponibles()
            self.variedadesDisponiblesChanged.emit()
        except Exception as e:
            print(f"Error al cargar variedades disponibles: {str(e)}")
    
    @Slot()
    def cargar_resumen_ventas_mes(self):
        """Carga el resumen de ventas del mes actual"""
        try:
            self._resumen_ventas = self._gestor.obtener_ventas_del_mes() or {}
            self.resumenVentasChanged.emit()
        except Exception as e:
            print(f"Error al cargar resumen de ventas: {str(e)}")
    
    @Slot(str, str)
    def cargar_resumen_ventas_periodo(self, fecha_inicio, fecha_fin):
        """Carga el resumen de ventas para un período específico"""
        try:
            self._resumen_ventas = self._gestor.obtener_resumen_ventas_por_periodo(fecha_inicio, fecha_fin) or {}
            self.resumenVentasChanged.emit()
        except Exception as e:
            print(f"Error al cargar resumen de ventas por período: {str(e)}")
    
    @Slot()
    def cargar_pagos_pendientes(self):
        """Carga los pagos pendientes desde la base de datos"""
        try:
            self._pagos_pendientes = self._gestor.obtener_pagos_pendientes()
            self.pagosPendientesChanged.emit()
        except Exception as e:
            print(f"Error al cargar pagos pendientes: {str(e)}")
    
    @Slot()
    def cargar_ventas_vencidas(self):
        """Carga las ventas vencidas desde la base de datos"""
        try:
            self._ventas_vencidas = self._gestor.obtener_ventas_vencidas()
            self.ventasVencidasChanged.emit()
        except Exception as e:
            print(f"Error al cargar ventas vencidas: {str(e)}")
    
    @Slot()
    def cargar_cliente_top(self):
        """Carga el cliente top del mes actual"""
        try:
            self._cliente_top = self._gestor.obtener_cliente_top() or {}
            self.clienteTopChanged.emit()
        except Exception as e:
            print(f"Error al cargar cliente top: {str(e)}")
    
    @Slot(int)
    def cargar_venta_por_id(self, id_venta):
        """Carga los detalles de una venta específica"""
        try:
            self._venta_seleccionada = self._gestor.obtener_venta_por_id(id_venta) or {}
            self.ventaSeleccionadaChanged.emit()
        except Exception as e:
            print(f"Error al cargar venta por ID: {str(e)}")
    
    @Slot(int)
    def cargar_historial_cliente(self, id_cliente):
        """Carga el historial de compras de un cliente"""
        try:
            self._cliente_historial = self._gestor.obtener_historial_compras_cliente(id_cliente) or {}
            self.clienteHistorialChanged.emit()
        except Exception as e:
            print(f"Error al cargar historial del cliente: {str(e)}")
    
    @Slot()
    def cargar_clientes_clasificados(self):
        """Carga los clientes clasificados por volumen de compras"""
        try:
            self._clientes_clasificados = self._gestor.clasificar_clientes_por_volumen()
            self.clientesClasificadosChanged.emit()
        except Exception as e:
            print(f"Error al cargar clientes clasificados: {str(e)}")
    
    # ==================== SLOTS PARA GESTIONAR CLIENTES ====================
    
    @Slot(str, result=bool)
    def agregar_cliente(self, cliente_data_json):
        """Agrega un nuevo cliente a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            cliente_data = json.loads(cliente_data_json)
            
            # Asegurarse de que se incluya el ID del usuario que registra
            if 'registrado_por' not in cliente_data:
                # Aquí podría obtener el ID del usuario actual de algún sistema de autenticación
                cliente_data['registrado_por'] = 1  # Valor por defecto
            
            success, _ = self._gestor.agregar_cliente(cliente_data)
            if success:
                self.cargar_clientes()
            return success
        except Exception as e:
            print(f"Error al agregar cliente: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_cliente(self, id_cliente, cliente_data_json):
        """Actualiza un cliente existente"""
        try:
            # Convertir el string JSON a diccionario
            cliente_data = json.loads(cliente_data_json)
            success = self._gestor.actualizar_cliente(id_cliente, cliente_data)
            if success:
                self.cargar_clientes()
                self.cargar_clientes_clasificados()
            return success
        except Exception as e:
            print(f"Error al actualizar cliente: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_cliente(self, id_cliente):
        """Elimina un cliente existente (eliminación lógica)"""
        try:
            success = self._gestor.eliminar_cliente(id_cliente)
            if success:
                self.cargar_clientes()
            return success
        except Exception as e:
            print(f"Error al eliminar cliente: {str(e)}")
            return False
    
    @Slot(str, result=str)
    def buscar_clientes(self, criterio):
        """Busca clientes según un criterio de búsqueda"""
        try:
            resultados = self._gestor.buscar_clientes(criterio)
            return json.dumps(resultados)
        except Exception as e:
            print(f"Error al buscar clientes: {str(e)}")
            return "[]"
    
    # ==================== SLOTS PARA GESTIONAR VENTAS ====================
    
    @Slot(result=list)
    def obtener_variedades_disponibles(self):
        # Obtiene las variedades disponibles para venta directamente del gestor
        try:
            return self._gestor.obtener_variedades_disponibles()
        except Exception as e:
            logger.error(f"Error al obtener variedades disponibles: {str(e)}")
            return []
    
    @Slot(result=str)
    def generar_codigo_venta(self):
        """Genera un código único para una nueva venta"""
        try:
            return self._gestor.generar_codigo_venta()
        except Exception as e:
            print(f"Error al generar código de venta: {str(e)}")
            return f"V-{datetime.now().strftime('%Y%m%d%H%M%S')}"
    
    @Slot(str, str, result=bool)
    def agregar_venta(self, venta_data_json, detalles_data_json):
        """Agrega una nueva venta con sus detalles a la base de datos"""
        try:
            # Verificar si los parámetros son cadenas JSON o ya son diccionarios
            if isinstance(venta_data_json, str):
                venta_data = json.loads(venta_data_json)
            else:
                venta_data = venta_data_json  # Ya es un diccionario
                
            if isinstance(detalles_data_json, str):
                detalles_data = json.loads(detalles_data_json)
                logger.info(f"Detalles recibidos: {json.dumps(detalles_data, indent=2)}")
            else:
                detalles_data = detalles_data_json  # Ya es un diccionario
                logger.info(f"Detalles recibidos (dict): {detalles_data}")
            
            # Obtener el ID del usuario que inició sesión
            usuario_actual_id = get_current_user_id()
            
            # Asignar el ID del usuario actual al campo registrado_por
            venta_data['registrado_por'] = usuario_actual_id
            logger.info(f"Venta registrada por usuario ID: {usuario_actual_id}")
            
            # Ahora cada detalle debe tener un id_variedad en lugar de id_lote
            for detalle in detalles_data:
                if 'id_lote' in detalle and not 'id_variedad' in detalle:
                    logger.warning(f"Se encontró id_lote en los detalles de venta: {detalle['id_lote']}")
                    # Convertir id_lote a id_variedad si es necesario (o manejar según corresponda)
                    # Este caso podría ocurrir si el frontend todavía envía id_lote
                    logger.warning("Eliminando id_lote, ya que ahora se usa id_variedad")
                    del detalle['id_lote']
                
                # Asegurarse de que exista id_variedad
                if not 'id_variedad' in detalle:
                    logger.error("Falta id_variedad en un detalle de venta")
                    return False
            
            # Convertir los datos de vuelta a JSON para enviarlos al gestor
            venta_data_json = json.dumps(venta_data)
            detalles_data_json = json.dumps(detalles_data)
            
            # Llamar al método del gestor con los datos en formato JSON
            success = self._gestor.agregar_venta(venta_data_json, detalles_data_json)
            
            if success:
                # Recargar todas las listas afectadas
                self.cargar_ventas()
                self.cargar_variedades_disponibles()
                self.cargar_resumen_ventas_mes()
                self.cargar_pagos_pendientes()
                self.cargar_cliente_top()
                self.cargar_clientes_clasificados()
            return success
        except Exception as e:
            logger.error(f"Error al agregar venta: {str(e)}")
            return False
            
    @Slot(int, str, result=bool)
    def actualizar_venta(self, id_venta, venta_data_json):
        """Actualiza una venta existente"""
        try:
            # Convertir el string JSON a diccionario
            venta_data = json.loads(venta_data_json)
            success = self._gestor.actualizar_venta(id_venta, venta_data)
            if success:
                self.cargar_ventas()
                if self._venta_seleccionada and self._venta_seleccionada.get('id_venta') == id_venta:
                    self.cargar_venta_por_id(id_venta)
            return success
        except Exception as e:
            print(f"Error al actualizar venta: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def cancelar_venta(self, id_venta, motivo):
        """Cancela una venta"""
        try:
            success = self._gestor.cancelar_venta(id_venta, motivo)
            if success:
                self.cargar_ventas()
                self.cargar_variedades_disponibles()
                self.cargar_resumen_ventas_mes()
                if self._venta_seleccionada and self._venta_seleccionada.get('id_venta') == id_venta:
                    self.cargar_venta_por_id(id_venta)
            return success
        except Exception as e:
            print(f"Error al cancelar venta: {str(e)}")
            return False
    
    @Slot(int, int, result=bool)
    def cambiar_estado_venta(self, id_venta, nuevo_estado_id):
        """Actualiza el estado de una venta"""
        try:
            success = self._gestor.cambiar_estado_venta(id_venta, nuevo_estado_id)
            if success:
                self.cargar_ventas()
                if self._venta_seleccionada and self._venta_seleccionada.get('id_venta') == id_venta:
                    self.cargar_venta_por_id(id_venta)
                self.cargar_ventas_vencidas()
            return success
        except Exception as e:
            print(f"Error al cambiar estado de venta: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def cambiar_estado_pago(self, id_venta, nuevo_estado_pago):
        """Actualiza el estado de pago de una venta"""
        try:
            success = self._gestor.cambiar_estado_pago(id_venta, nuevo_estado_pago)
            if success:
                self.cargar_ventas()
                self.cargar_pagos_pendientes()
                if self._venta_seleccionada and self._venta_seleccionada.get('id_venta') == id_venta:
                    self.cargar_venta_por_id(id_venta)
            return success
        except Exception as e:
            print(f"Error al cambiar estado de pago: {str(e)}")
            return False
    
    @Slot(int, str, str, result=str)
    def duplicar_venta(self, id_venta, nuevo_codigo, nueva_fecha):
        """Duplica una venta existente"""
        try:
            success, nueva_id = self._gestor.duplicar_venta(id_venta, nuevo_codigo, nueva_fecha)
            if success:
                self.cargar_ventas()
                self.cargar_variedades_disponibles()
                return str(nueva_id)
            return ""
        except Exception as e:
            print(f"Error al duplicar venta: {str(e)}")
            return ""
    
    # ==================== SLOTS PARA GESTIONAR DETALLES DE VENTA ====================
    
    @Slot(int, str, result=bool)
    def agregar_detalle_venta(self, id_venta, detalle_data_json):
        """Agrega un nuevo detalle a una venta existente"""
        try:
            detalle_data = json.loads(detalle_data_json)
            
            # Asegurarse de que el detalle contiene id_variedad
            if 'id_lote' in detalle_data and not 'id_variedad' in detalle_data:
                logger.warning(f"Se encontró id_lote en detalle: {detalle_data['id_lote']}")
                # Convertir id_lote a id_variedad si es necesario (o manejar según corresponda)
                del detalle_data['id_lote']
                
            if not 'id_variedad' in detalle_data:
                logger.error("Falta id_variedad en detalle de venta")
                return False
                
            success = self._gestor.agregar_detalle_venta(id_venta, detalle_data)
            if success:
                self.cargar_variedades_disponibles()
                if self._venta_seleccionada and self._venta_seleccionada.get('id_venta') == id_venta:
                    self.cargar_venta_por_id(id_venta)
                self.cargar_ventas()  # Para actualizar totales
            return success
        except Exception as e:
            print(f"Error al agregar detalle de venta: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_detalle_venta(self, id_detalle_venta):
        """Elimina un detalle de venta"""
        try:
            # Necesitamos guardar el ID de la venta actual en caso de que necesitemos recargarla
            id_venta = None
            if self._venta_seleccionada:
                id_venta = self._venta_seleccionada.get('id_venta')
            
            success = self._gestor.eliminar_detalle_venta(id_detalle_venta)
            if success:
                self.cargar_variedades_disponibles()
                if id_venta:
                    self.cargar_venta_por_id(id_venta)
                self.cargar_ventas()  # Para actualizar totales
            return success
        except Exception as e:
            print(f"Error al eliminar detalle de venta: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_detalle_venta(self, id_detalle_venta, detalle_data_json):
        """Actualiza un detalle de venta existente"""
        try:
            # Necesitamos guardar el ID de la venta actual en caso de que necesitemos recargarla
            id_venta = None
            if self._venta_seleccionada:
                id_venta = self._venta_seleccionada.get('id_venta')
            
            detalle_data = json.loads(detalle_data_json)
            
            # Asegurarse de que el detalle contiene id_variedad si se está actualizando
            if 'id_lote' in detalle_data and not 'id_variedad' in detalle_data:
                logger.warning(f"Se encontró id_lote en detalle para actualizar: {detalle_data['id_lote']}")
                # Convertir id_lote a id_variedad si es necesario (o manejar según corresponda)
                del detalle_data['id_lote']
                
            success = self._gestor.actualizar_detalle_venta(id_detalle_venta, detalle_data)
            if success:
                self.cargar_variedades_disponibles()
                if id_venta:
                    self.cargar_venta_por_id(id_venta)
                self.cargar_ventas()  # Para actualizar totales
            return success
        except Exception as e:
            print(f"Error al actualizar detalle de venta: {str(e)}")
            return False
    
    # ==================== SLOTS PARA FILTROS Y BÚSQUEDAS ====================
    
    @Slot(str, result=str)
    def buscar_ventas(self, termino_busqueda):
        """Busca ventas que coincidan con el término de búsqueda"""
        try:
            termino = termino_busqueda.lower()
            resultados = []
            
            for venta in self._ventas:
                # Buscar coincidencias en código o cliente
                if (termino in venta['codigo_venta'].lower() or
                    termino in venta['cliente_nombre'].lower()):
                    resultados.append(venta)
            
            return json.dumps(resultados)
        except Exception as e:
            print(f"Error al buscar ventas: {str(e)}")
            return "[]"
    
    @Slot(str, result=str)
    def filtrar_ventas_por_estado(self, estado_id):
        """Filtra ventas por estado"""
        try:
            id_estado = int(estado_id) if estado_id and estado_id != "todos" else None
            
            if id_estado is None:
                return json.dumps(self._ventas)
            
            resultados = [venta for venta in self._ventas if venta['id_estado'] == id_estado]
            return json.dumps(resultados)
        except Exception as e:
            print(f"Error al filtrar ventas por estado: {str(e)}")
            return "[]"
    
    @Slot(str, str, result=str)
    def filtrar_ventas_por_fecha(self, fecha_inicio, fecha_fin):
        """Filtra ventas por rango de fechas"""
        try:
            # Convertir fechas de string a objetos date
            fecha_inicio_obj = datetime.strptime(fecha_inicio, '%Y-%m-%d').date()
            fecha_fin_obj = datetime.strptime(fecha_fin, '%Y-%m-%d').date()
            
            resultados = []
            for venta in self._ventas:
                # Convertir fecha_venta de string a objeto date
                if venta['fecha_venta']:
                    fecha_venta = datetime.strptime(venta['fecha_venta'], '%Y-%m-%d').date()
                    
                    # Verificar si la fecha está en el rango
                    if fecha_inicio_obj <= fecha_venta <= fecha_fin_obj:
                        resultados.append(venta)
            
            return json.dumps(resultados)
        except Exception as e:
            print(f"Error al filtrar ventas por fecha: {str(e)}")
            return "[]"
    
    # ==================== MÉTODOS PARA COMPATIBILIDAD CON QML ====================
    @Slot(result=str)
    def get_ventas_json(self):
        """Retorna todas las ventas en formato JSON para QML"""
        try:
            return json.dumps(self._ventas)
        except Exception as e:
            logger.error(f"Error al convertir ventas a JSON: {str(e)}")
            return "[]"

    @Slot(result=str)
    def get_clientes_json(self):
        """Retorna todos los clientes en formato JSON para QML"""
        try:
            return json.dumps(self._clientes)
        except Exception as e:
            logger.error(f"Error al convertir clientes a JSON: {str(e)}")
            return "[]"

    @Slot(result=str)
    def get_estados_venta_json(self):
        """Retorna todos los estados de venta en formato JSON para QML"""
        try:
            return json.dumps(self._estados_venta)
        except Exception as e:
            logger.error(f"Error al convertir estados de venta a JSON: {str(e)}")
            return "[]"
            
    @Slot(result=str)
    def get_variedades_disponibles_json(self):
        """Retorna todas las variedades disponibles en formato JSON para QML"""
        try:
            return json.dumps(self._variedades_disponibles)
        except Exception as e:
            logger.error(f"Error al convertir variedades disponibles a JSON: {str(e)}")
            return "[]"

    @Slot(result=str)
    def get_resumen_ventas_json(self):
        """Retorna resumen de ventas en formato JSON para QML"""
        try:
            return json.dumps(self._resumen_ventas)
        except Exception as e:
            logger.error(f"Error al convertir resumen de ventas a JSON: {str(e)}")
            return "{\"totales\": {\"monto_total\": 0, \"pendiente\": 0, \"vencido\": 0}}"

    @Slot(result=str)
    def get_cliente_top_json(self):
        """Retorna cliente top en formato JSON para QML"""
        try:
            return json.dumps(self._cliente_top)
        except Exception as e:
            logger.error(f"Error al convertir cliente top a JSON: {str(e)}")
            return "{\"nombre\": \"\", \"porcentaje\": 0}"

    @Slot(result=str)
    def get_venta_seleccionada_json(self):
        """Retorna la venta seleccionada en formato JSON para QML"""
        try:
            return json.dumps(self._venta_seleccionada)
        except Exception as e:
            logger.error(f"Error al convertir venta seleccionada a JSON: {str(e)}")
            return "{}"

    @Slot(str, result=str)
    def filtrar_ventas_por_estado_pago(self, estado_pago):
        """Filtra ventas por estado de pago"""
        try:
            if estado_pago == "Todos los estados":
                return json.dumps(self._ventas)
            
            resultados = [venta for venta in self._ventas if venta.get('estado_pago') == estado_pago]
            return json.dumps(resultados)
        except Exception as e:
            logger.error(f"Error al filtrar ventas por estado de pago: {str(e)}")
            return "[]"

    @Slot(int, result=str)
    def get_venta_por_id_json(self, id_venta):
        """Obtiene una venta por su ID en formato JSON"""
        try:
            venta = self._gestor.obtener_venta_por_id(id_venta)
            return json.dumps(venta) if venta else "{}"
        except Exception as e:
            logger.error(f"Error al obtener venta por ID: {str(e)}")
            return "{}"

    @Slot(int, result=str)
    def get_productos_venta_json(self, id_venta):
        """Obtiene los productos de una venta en formato JSON"""
        try:
            productos = self._gestor.obtener_productos_venta(id_venta)
            return json.dumps(productos) if productos else "[]"
        except Exception as e:
            logger.error(f"Error al obtener productos de la venta: {str(e)}")
            return "[]"