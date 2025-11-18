# backend/models/agroquimicos_model.py
"""
Modelo de Agroquímicos - Actualizado con arquitectura en capas
Bridge entre QML y los servicios de negocio
"""

from PySide6.QtCore import QObject, Slot, Signal, Property
import json
import logging

# Importar servicios en lugar de GestorAgroquimicos
from backend.services.AgroquimicosSer import (
    ProductoService,
    CategoriaService,
    MezclaService,
    TratamientoService
)

logger = logging.getLogger(__name__)


class AgroquimicosModel(QObject):
    """
    Modelo de Agroquímicos para QML
    Utiliza servicios para la lógica de negocio
    """
    
    # ==================== SEÑALES ====================
    productosChanged = Signal()
    categoriasChanged = Signal()
    mezclasChanged = Signal()
    tratamientosChanged = Signal()
    tiposPlagasChanged = Signal()
    ciclosActivosChanged = Signal()
    detallesMezclaChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # Inicializar servicios (en lugar de GestorAgroquimicos)
        self.producto_service = ProductoService()
        self.categoria_service = CategoriaService()
        self.mezcla_service = MezclaService()
        self.tratamiento_service = TratamientoService()
        
        # Propiedades internas para QML
        self._productos = []
        self._categorias = []
        self._mezclas = []
        self._tratamientos = []
        self._tipos_plagas = []
        self._ciclos_activos = []
        self._detalles_mezcla = []
        
        # Cargar datos iniciales
        self.cargar_productos()
        self.cargar_categorias()
        self.cargar_mezclas()
        self.cargar_tratamientos()
        self.cargar_tipos_plagas()
        self.cargar_ciclos_activos()
    
    # ==================== PROPIEDADES PARA QML ====================
    
    @Property(list, notify=productosChanged)
    def productos(self):
        return self._productos
    
    @Property(list, notify=categoriasChanged)
    def categorias(self):
        return self._categorias
    
    @Property(list, notify=mezclasChanged)
    def mezclas(self):
        return self._mezclas
    
    @Property(list, notify=tratamientosChanged)
    def tratamientos(self):
        return self._tratamientos
    
    @Property(list, notify=tiposPlagasChanged)
    def tipos_plagas(self):
        return self._tipos_plagas
    
    @Property(list, notify=ciclosActivosChanged)
    def ciclos_activos(self):
        return self._ciclos_activos
    
    @Property(list, notify=detallesMezclaChanged)
    def detalles_mezcla(self):
        return self._detalles_mezcla
    
    # ==================== MÉTODOS PARA CARGAR DATOS ====================
    
    @Slot()
    def cargar_productos(self):
        """Carga la lista de productos desde el servicio"""
        try:
            self._productos = self.producto_service.obtener_todos_productos()
            self.productosChanged.emit()
            logger.info(f"✅ Cargados {len(self._productos)} productos")
        except Exception as e:
            logger.error(f"❌ Error al cargar productos: {str(e)}")
            self._productos = []
            self.productosChanged.emit()
    
    @Slot()
    def cargar_categorias(self):
        """Carga la lista de categorías desde el servicio"""
        try:
            self._categorias = self.categoria_service.obtener_todas_categorias()
            self.categoriasChanged.emit()
            logger.info(f"✅ Cargadas {len(self._categorias)} categorías")
        except Exception as e:
            logger.error(f"❌ Error al cargar categorías: {str(e)}")
            self._categorias = []
            self.categoriasChanged.emit()
    
    @Slot()
    def cargar_mezclas(self):
        """Carga la lista de mezclas desde el servicio"""
        try:
            self._mezclas = self.mezcla_service.obtener_todas_mezclas()
            self.mezclasChanged.emit()
            logger.info(f"✅ Cargadas {len(self._mezclas)} mezclas")
        except Exception as e:
            logger.error(f"❌ Error al cargar mezclas: {str(e)}")
            self._mezclas = []
            self.mezclasChanged.emit()
    
    @Slot()
    def cargar_tratamientos(self):
        """Carga la lista de tratamientos desde el servicio"""
        try:
            self._tratamientos = self.tratamiento_service.obtener_todos_tratamientos()
            self.tratamientosChanged.emit()
            logger.info(f"✅ Cargados {len(self._tratamientos)} tratamientos")
        except Exception as e:
            logger.error(f"❌ Error al cargar tratamientos: {str(e)}")
            self._tratamientos = []
            self.tratamientosChanged.emit()
    
    @Slot()
    def cargar_tipos_plagas(self):
        """Carga la lista de tipos de plagas desde el servicio"""
        try:
            self._tipos_plagas = self.tratamiento_service.obtener_tipos_plagas()
            self.tiposPlagasChanged.emit()
            logger.info(f"✅ Cargados {len(self._tipos_plagas)} tipos de plagas")
        except Exception as e:
            logger.error(f"❌ Error al cargar tipos de plagas: {str(e)}")
            self._tipos_plagas = []
            self.tiposPlagasChanged.emit()
    
    @Slot()
    def cargar_ciclos_activos(self):
        """Carga la lista de ciclos activos desde el servicio"""
        try:
            self._ciclos_activos = self.tratamiento_service.obtener_ciclos_activos()
            self.ciclosActivosChanged.emit()
            logger.info(f"✅ Cargados {len(self._ciclos_activos)} ciclos activos")
        except Exception as e:
            logger.error(f"❌ Error al cargar ciclos activos: {str(e)}")
            self._ciclos_activos = []
            self.ciclosActivosChanged.emit()
    
    @Slot(int)
    def cargar_detalles_mezcla(self, id_mezcla):
        """Carga los detalles de una mezcla específica"""
        try:
            self._detalles_mezcla = self.mezcla_service.obtener_detalles_mezcla(id_mezcla)
            self.detallesMezclaChanged.emit()
            logger.info(f"✅ Cargados {len(self._detalles_mezcla)} productos de la mezcla {id_mezcla}")
        except Exception as e:
            logger.error(f"❌ Error al cargar detalles de mezcla: {str(e)}")
            self._detalles_mezcla = []
            self.detallesMezclaChanged.emit()
    
    # ==================== MÉTODOS PARA PRODUCTOS ====================
    
    @Slot(str, result=bool)
    def agregar_producto(self, producto_data_json):
        """
        Agrega un nuevo producto a la base de datos
        
        Args:
            producto_data_json: JSON string con los datos del producto
            
        Returns:
            bool: True si se agregó correctamente
        """
        try:
            producto_data = json.loads(producto_data_json)
            exito, id_producto, mensaje = self.producto_service.crear_producto(producto_data)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_producto})")
                self.cargar_productos()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except json.JSONDecodeError as e:
            logger.error(f"❌ Error al decodificar JSON: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"❌ Error al agregar producto: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_producto(self, id_producto, producto_data_json):
        """
        Actualiza un producto existente
        
        Args:
            id_producto: ID del producto a actualizar
            producto_data_json: JSON string con los datos a actualizar
            
        Returns:
            bool: True si se actualizó correctamente
        """
        try:
            producto_data = json.loads(producto_data_json)
            exito, mensaje = self.producto_service.actualizar_producto(id_producto, producto_data)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.cargar_productos()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except json.JSONDecodeError as e:
            logger.error(f"❌ Error al decodificar JSON: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"❌ Error al actualizar producto: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_producto(self, id_producto):
        """
        Elimina un producto existente
        
        Args:
            id_producto: ID del producto a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
        try:
            exito, mensaje = self.producto_service.eliminar_producto(id_producto)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.cargar_productos()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except Exception as e:
            logger.error(f"❌ Error al eliminar producto: {str(e)}")
            return False
    
    @Slot(int, float, result=bool)
    def actualizar_stock(self, id_producto, nueva_cantidad):
        """
        Actualiza el stock de un producto específico
        
        Args:
            id_producto: ID del producto
            nueva_cantidad: Nueva cantidad en stock
            
        Returns:
            bool: True si se actualizó correctamente
        """
        try:
            exito, mensaje = self.producto_service.actualizar_stock_producto(id_producto, nueva_cantidad)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.cargar_productos()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except Exception as e:
            logger.error(f"❌ Error al actualizar stock: {str(e)}")
            return False
    
    # ==================== MÉTODOS PARA CATEGORÍAS ====================
    
    @Slot(str, result=bool)
    def agregar_categoria(self, categoria_data_json):
        """
        Agrega una nueva categoría a la base de datos
        
        Args:
            categoria_data_json: JSON string con los datos de la categoría
            
        Returns:
            bool: True si se agregó correctamente
        """
        try:
            categoria_data = json.loads(categoria_data_json)
            exito, id_categoria, mensaje = self.categoria_service.crear_categoria(categoria_data)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_categoria})")
                self.cargar_categorias()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except json.JSONDecodeError as e:
            logger.error(f"❌ Error al decodificar JSON: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"❌ Error al agregar categoría: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_categoria(self, id_categoria, categoria_data_json):
        """
        Actualiza una categoría existente
        
        Args:
            id_categoria: ID de la categoría a actualizar
            categoria_data_json: JSON string con los datos a actualizar
            
        Returns:
            bool: True si se actualizó correctamente
        """
        try:
            categoria_data = json.loads(categoria_data_json)
            exito, mensaje = self.categoria_service.actualizar_categoria(id_categoria, categoria_data)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.cargar_categorias()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except json.JSONDecodeError as e:
            logger.error(f"❌ Error al decodificar JSON: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"❌ Error al actualizar categoría: {str(e)}")
            return False
    
    # ==================== MÉTODOS PARA MEZCLAS ====================
    
    @Slot(str, str, result=bool)
    def agregar_mezcla(self, mezcla_data_json, detalles_data_json):
        """
        Agrega una nueva mezcla a la base de datos
        
        Args:
            mezcla_data_json: JSON string con los datos de la mezcla
            detalles_data_json: JSON string con los productos de la mezcla (opcional)
            
        Returns:
            bool: True si se agregó correctamente
        """
        try:
            mezcla_data = json.loads(mezcla_data_json)
            detalles_data = json.loads(detalles_data_json) if detalles_data_json else None
            
            exito, id_mezcla, mensaje = self.mezcla_service.crear_mezcla(mezcla_data, detalles_data)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_mezcla})")
                self.cargar_mezclas()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except json.JSONDecodeError as e:
            logger.error(f"❌ Error al decodificar JSON: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"❌ Error al agregar mezcla: {str(e)}")
            return False
    
    # ==================== MÉTODOS PARA TRATAMIENTOS ====================
    
    @Slot(str, result=bool)
    def agregar_tratamiento(self, tratamiento_data_json):
        """
        Agrega un nuevo tratamiento a la base de datos
        
        Args:
            tratamiento_data_json: JSON string con los datos del tratamiento
            
        Returns:
            bool: True si se agregó correctamente
        """
        try:
            tratamiento_data = json.loads(tratamiento_data_json)
            exito, id_tratamiento, mensaje = self.tratamiento_service.crear_tratamiento(tratamiento_data)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_tratamiento})")
                self.cargar_tratamientos()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except json.JSONDecodeError as e:
            logger.error(f"❌ Error al decodificar JSON: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"❌ Error al agregar tratamiento: {str(e)}")
            return False
    
    # ==================== MÉTODOS DE UTILIDAD ====================
    
    @Slot(result=str)
    def obtener_resumen_inventario(self):
        """
        Obtiene un resumen del inventario actual
        
        Returns:
            str: JSON string con el resumen del inventario
        """
        try:
            resumen = self.producto_service.obtener_resumen_inventario()
            return json.dumps(resumen)
        except Exception as e:
            logger.error(f"❌ Error al obtener resumen de inventario: {str(e)}")
            return json.dumps({
                'total_productos': 0,
                'productos_activos': 0,
                'valor_inventario': 0,
                'stock_critico': 0,
                'categoria_mas_usada': 'N/A'
            })
    
    @Slot(float, result=str)
    def obtener_productos_stock_bajo(self, limite):
        """
        Obtiene productos con stock por debajo del límite
        
        Args:
            limite: Cantidad mínima de stock
            
        Returns:
            str: JSON string con la lista de productos
        """
        try:
            productos = self.producto_service.obtener_productos_stock_bajo(limite)
            return json.dumps(productos)
        except Exception as e:
            logger.error(f"❌ Error al obtener productos con stock bajo: {str(e)}")
            return json.dumps([])
    
    @Slot(result=str)
    def obtener_estadisticas_categorias(self):
        """
        Obtiene estadísticas de las categorías
        
        Returns:
            str: JSON string con las estadísticas
        """
        try:
            estadisticas = self.categoria_service.obtener_estadisticas_categorias()
            return json.dumps(estadisticas)
        except Exception as e:
            logger.error(f"❌ Error al obtener estadísticas de categorías: {str(e)}")
            return json.dumps({})
    
    @Slot(result=str)
    def obtener_estadisticas_mezclas(self):
        """
        Obtiene estadísticas de las mezclas
        
        Returns:
            str: JSON string con las estadísticas
        """
        try:
            estadisticas = self.mezcla_service.obtener_estadisticas_mezclas()
            return json.dumps(estadisticas)
        except Exception as e:
            logger.error(f"❌ Error al obtener estadísticas de mezclas: {str(e)}")
            return json.dumps({})
    
    @Slot(int, result=str)
    def obtener_estadisticas_ciclo(self, id_ciclo):
        """
        Obtiene estadísticas de tratamientos de un ciclo
        
        Args:
            id_ciclo: ID del ciclo
            
        Returns:
            str: JSON string con las estadísticas
        """
        try:
            estadisticas = self.tratamiento_service.obtener_estadisticas_ciclo(id_ciclo)
            return json.dumps(estadisticas)
        except Exception as e:
            logger.error(f"❌ Error al obtener estadísticas del ciclo: {str(e)}")
            return json.dumps({})
    
    @Slot(int, float, result=str)
    def calcular_costo_mezcla(self, id_mezcla, cantidad_agua):
        """
        Calcula el costo de una mezcla según la cantidad de agua
        
        Args:
            id_mezcla: ID de la mezcla
            cantidad_agua: Cantidad de agua en litros
            
        Returns:
            str: JSON string con el costo total y desglose
        """
        try:
            costo_total, desglose = self.mezcla_service.calcular_costo_mezcla(id_mezcla, cantidad_agua)
            resultado = {
                'costo_total': costo_total,
                'desglose': desglose
            }
            return json.dumps(resultado)
        except Exception as e:
            logger.error(f"❌ Error al calcular costo de mezcla: {str(e)}")
            return json.dumps({'costo_total': 0, 'desglose': []})
    
    @Slot(int, float, result=str)
    def verificar_stock_mezcla(self, id_mezcla, cantidad_agua):
        """
        Verifica si hay suficiente stock para una mezcla
        
        Args:
            id_mezcla: ID de la mezcla
            cantidad_agua: Cantidad de agua en litros
            
        Returns:
            str: JSON string con el resultado de la verificación
        """
        try:
            hay_stock, productos_faltantes = self.mezcla_service.verificar_stock_mezcla(id_mezcla, cantidad_agua)
            resultado = {
                'hay_stock_suficiente': hay_stock,
                'productos_faltantes': productos_faltantes
            }
            return json.dumps(resultado)
        except Exception as e:
            logger.error(f"❌ Error al verificar stock de mezcla: {str(e)}")
            return json.dumps({'hay_stock_suficiente': False, 'productos_faltantes': []})
    
    # ==================== MÉTODOS ADICIONALES ====================
    
    @Slot(result=int)
    def contar_productos(self):
        """Cuenta el total de productos activos"""
        try:
            return self.producto_service.contar_productos(solo_activos=True)
        except Exception as e:
            logger.error(f"❌ Error al contar productos: {str(e)}")
            return 0
    
    @Slot(result=int)
    def contar_categorias(self):
        """Cuenta el total de categorías activas"""
        try:
            return self.categoria_service.contar_categorias(solo_activas=True)
        except Exception as e:
            logger.error(f"❌ Error al contar categorías: {str(e)}")
            return 0
    
    @Slot(result=int)
    def contar_mezclas(self):
        """Cuenta el total de mezclas activas"""
        try:
            return self.mezcla_service.contar_mezclas(solo_activas=True)
        except Exception as e:
            logger.error(f"❌ Error al contar mezclas: {str(e)}")
            return 0
    
    @Slot(int, result=int)
    def contar_tratamientos(self, id_ciclo):
        """
        Cuenta tratamientos de un ciclo específico
        
        Args:
            id_ciclo: ID del ciclo (0 para todos)
        """
        try:
            if id_ciclo == 0:
                return self.tratamiento_service.contar_tratamientos()
            else:
                return self.tratamiento_service.contar_tratamientos(id_ciclo)
        except Exception as e:
            logger.error(f"❌ Error al contar tratamientos: {str(e)}")
            return 0
    
    @Slot(result=float)
    def obtener_valor_inventario(self):
        """Obtiene el valor total del inventario"""
        try:
            return self.producto_service.obtener_valor_total_inventario()
        except Exception as e:
            logger.error(f"❌ Error al obtener valor de inventario: {str(e)}")
            return 0.0