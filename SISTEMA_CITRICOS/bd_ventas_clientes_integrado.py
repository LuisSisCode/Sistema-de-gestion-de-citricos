# Integración de gestores de clientes y ventas
import logging
from bdclientes import GestorClientes
from bd_ventas import GestorVentas
from datetime import datetime, timedelta

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