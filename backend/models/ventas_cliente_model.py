from PySide6.QtCore import QObject, Slot, Signal, Property, QDate
from backend.services.ClientesVentasServ import GestionClienteVentaServicio
from .cultivos_model import CultivosModel
from datetime import datetime, timedelta
# ✅ CORREGIDO: Usar auth_service en lugar de user_session
from backend.services.auth_service import auth_service
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
        self._gestor = GestionClienteVentaServicio()

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
        self.cargar_estadisticas_completas()
    
    # ==================== PROPIEDADES ====================
    @Property(int, notify=currentUserChanged)
    def current_user_id(self):
        """Retorna el ID del usuario actual para QML"""
        try:
            user_id = auth_service.obtener_id_usuario()
            return user_id if user_id is not None else 0
        except Exception as e:
            logger.error(f"Error al obtener ID de usuario: {str(e)}")
            return 0
    
    @Property(str, notify=currentUserChanged)
    def current_user_name(self):
        """Retorna el nombre del usuario actual para QML"""
        # ✅ CORREGIDO: Usar auth_service en lugar de leer current_user.json
        try:
            return auth_service.obtener_nombre_completo()
        except Exception as e:
            logger.error(f"Error al obtener nombre de usuario: {str(e)}")
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
        """Carga el cliente top del mes desde la base de datos"""
        try:
            self._cliente_top = self._gestor.obtener_cliente_top_del_mes() or {}
            self.clienteTopChanged.emit()
        except Exception as e:
            print(f"Error al cargar cliente top: {str(e)}")
    
    @Slot(int)
    def cargar_historial_cliente(self, id_cliente):
        """Carga el historial de compras de un cliente específico"""
        try:
            self._cliente_historial = self._gestor.obtener_historial_compras_cliente(id_cliente) or {}
            self.clienteHistorialChanged.emit()
        except Exception as e:
            print(f"Error al cargar historial del cliente: {str(e)}")
    
    @Slot()
    def cargar_clientes_clasificados(self):
        """Carga los clientes clasificados por su nivel de compras"""
        try:
            self._clientes_clasificados = self._gestor.obtener_clientes_clasificados()
            self.clientesClasificadosChanged.emit()
        except Exception as e:
            print(f"Error al cargar clientes clasificados: {str(e)}")
    
    # ==================== SLOTS PARA OPERACIONES CRUD ====================
    
    @Slot(str, result=bool)
    def agregar_cliente(self, cliente_data_json):
        """Agrega un nuevo cliente a la base de datos"""
        try:
            cliente_data = json.loads(cliente_data_json)
            user_id = auth_service.obtener_id_usuario()
            if user_id:
                cliente_data['id_usuario_creacion'] = user_id
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
            cliente_data = json.loads(cliente_data_json)
            user_id = auth_service.obtener_id_usuario()
            if user_id:
                cliente_data['id_usuario_modificacion'] = user_id
            success = self._gestor.actualizar_cliente(id_cliente, cliente_data)
            if success:
                self.cargar_clientes()
            return success
        except Exception as e:
            print(f"Error al actualizar cliente: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_cliente(self, id_cliente):
        """Elimina un cliente existente"""
        try:
            success = self._gestor.eliminar_cliente(id_cliente)
            if success:
                self.cargar_clientes()
            return success
        except Exception as e:
            print(f"Error al eliminar cliente: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def registrar_venta(self, venta_data_json):
        """Registra una nueva venta en la base de datos"""
        try:
            venta_data = json.loads(venta_data_json)
            user_id = auth_service.obtener_id_usuario()
            venta_data['id_usuario'] = user_id if user_id is not None else 0
            success, _ = self._gestor.registrar_venta(venta_data)
            if success:
                self.cargar_ventas()
                self.cargar_resumen_ventas_mes()
                self.cargar_variedades_disponibles()
            return success
        except Exception as e:
            print(f"Error al registrar venta: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_venta(self, id_venta, venta_data_json):
        """Actualiza una venta existente"""
        try:
            venta_data = json.loads(venta_data_json)
            user_id = auth_service.obtener_id_usuario()
            if user_id:
                venta_data['id_usuario_modificacion'] = user_id
            success = self._gestor.actualizar_venta(id_venta, venta_data)
            if success:
                self.cargar_ventas()
                self.cargar_resumen_ventas_mes()
            return success
        except Exception as e:
            print(f"Error al actualizar venta: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def cancelar_venta(self, id_venta):
        """Cancela una venta existente"""
        try:
            success = self._gestor.cancelar_venta(id_venta)
            if success:
                self.cargar_ventas()
                self.cargar_resumen_ventas_mes()
                self.cargar_variedades_disponibles()
            return success
        except Exception as e:
            print(f"Error al cancelar venta: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def registrar_pago(self, pago_data_json):
        """Registra un pago para una venta"""
        try:
            pago_data = json.loads(pago_data_json)
            user_id = auth_service.obtener_id_usuario()
            pago_data['id_usuario'] = user_id if user_id is not None else 0
            success, _ = self._gestor.registrar_pago(pago_data)
            if success:
                self.cargar_ventas()
                self.cargar_pagos_pendientes()
                self.cargar_resumen_ventas_mes()
            return success
        except Exception as e:
            print(f"Error al registrar pago: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_estado_venta(self, id_venta, id_estado):
        """Actualiza el estado de una venta"""
        try:
            success = self._gestor.actualizar_estado_venta(id_venta, int(id_estado))
            if success:
                self.cargar_ventas()
                self.cargar_resumen_ventas_mes()
            return success
        except Exception as e:
            print(f"Error al actualizar estado de venta: {str(e)}")
            return False
    
    @Slot(int)
    def seleccionar_venta(self, id_venta):
        """Selecciona una venta para ver sus detalles"""
        try:
            venta = next((v for v in self._ventas if v['id'] == id_venta), None)
            if venta:
                self._venta_seleccionada = venta
                self.ventaSeleccionadaChanged.emit()
        except Exception as e:
            print(f"Error al seleccionar venta: {str(e)}")
    
    @Slot(int, result=str)
    def obtener_pagos_venta(self, id_venta):
        """Obtiene los pagos realizados para una venta específica"""
        try:
            pagos = self._gestor.obtener_pagos_venta(id_venta)
            return json.dumps(pagos)
        except Exception as e:
            print(f"Error al obtener pagos de la venta: {str(e)}")
            return "[]"
    
    # ==================== MÉTODOS DE BÚSQUEDA Y FILTRADO ====================
    
    @Slot(str, result=str)
    def buscar_clientes(self, termino_busqueda):
        """Busca clientes por nombre, documento o contacto"""
        try:
            if not termino_busqueda:
                return json.dumps(self._clientes)
            
            termino = termino_busqueda.lower()
            resultados = [
                cliente for cliente in self._clientes
                if termino in cliente['nombre_completo'].lower() or
                   termino in cliente['documento'].lower() or
                   termino in cliente.get('telefono', '').lower() or
                   termino in cliente.get('email', '').lower()
            ]
            return json.dumps(resultados)
        except Exception as e:
            print(f"Error al buscar clientes: {str(e)}")
            return "[]"
    
    @Slot(str, result=str)
    def buscar_ventas(self, termino_busqueda):
        """Busca ventas por cliente, número de venta o producto"""
        try:
            if not termino_busqueda:
                return json.dumps(self._ventas)
            
            termino = termino_busqueda.lower()
            resultados = [
                venta for venta in self._ventas
                if termino in venta['cliente'].lower() or
                   termino in str(venta['id']).lower() or
                   termino in venta.get('observaciones', '').lower()
            ]
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
            # Asegúrate de recargar las ventas desde la base de datos
            self._ventas = self._gestor.obtener_ventas()
            logger.info(f"Se cargaron {len(self._ventas)} ventas de la base de datos")
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
    @Slot(result=str)
    def get_estadisticas_ventas_json(self):
        """Expone estadísticas generales como JSON"""
        try:
            # CAMBIAR: usar self._gestor en lugar de self.bd_ventas
            stats = self._gestor.obtener_estadisticas_ventas()
            return json.dumps(stats) if stats else "{}"
        except Exception as e:
            logger.error(f"Error al obtener estadísticas: {e}")
            return "{}"

    @Slot(int, result=str)
    def get_ventas_por_mes_json(self, anio):
        """Expone ventas por mes como JSON"""
        try:
            # CAMBIAR: usar self._gestor
            ventas = self._gestor.obtener_ventas_por_mes(anio)
            return json.dumps(ventas) if ventas else "[]"
        except Exception as e:
            logger.error(f"Error al obtener ventas por mes: {e}")
            return "[]"

    @Slot(result=str)
    def get_productos_mas_vendidos_json(self):
        """Expone productos más vendidos como JSON"""
        try:
            # CAMBIAR: usar self._gestor
            productos = self._gestor.obtener_productos_mas_vendidos()
            return json.dumps(productos) if productos else "[]"
        except Exception as e:
            logger.error(f"Error al obtener productos más vendidos: {e}")
            return "[]"

    @Slot(result=str)
    def get_clientes_top_completo_json(self):
        """Expone clientes top como JSON"""
        try:
            # CAMBIAR: usar self._gestor
            clientes = self._gestor.obtener_clientes_top_completo()
            return json.dumps(clientes) if clientes else "[]"
        except Exception as e:
            logger.error(f"Error al obtener clientes top: {e}")
            return "[]"
    
    @Slot()
    def cargar_estadisticas_completas(self):
        """Carga todas las estadísticas necesarias para el dashboard"""
        try:
            # Cargar estadísticas básicas del mes
            self.cargar_resumen_ventas_mes()
            
            # Cargar datos complementarios
            self.cargar_pagos_pendientes()
            self.cargar_ventas_vencidas()
            self.cargar_cliente_top()
            self.cargar_clientes_clasificados()
            
            logger.info("Estadísticas completas cargadas exitosamente")
        except Exception as e:
            logger.error(f"Error al cargar estadísticas completas: {str(e)}")