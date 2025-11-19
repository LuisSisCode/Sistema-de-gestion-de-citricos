# backend/models/agroquimicos_model.py
"""
Modelo de Agroquímicos - Completamente integrado y corregido
Bridge entre QML y los servicios de negocio
"""

from PySide6.QtCore import QObject, Slot, Signal, Property
import json
import logging

# Importar servicios
from backend.services.AgroquimicosServ import (
    ProductoService,
    CategoriaService,
    MezclaService,
    TratamientoService,
    LoteAgroquimicoService
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
    lotesChanged = Signal()
    tiposPlagasChanged = Signal()
    ciclosActivosChanged = Signal()
    detallesMezclaChanged = Signal()
    alertasInventarioChanged = Signal()
    
    def __init__(self, db_session=None, parent=None):
        super().__init__(parent)
        self.db_session = db_session
        
        # Inicializar servicios con sesión de base de datos
        self.producto_service = ProductoService(db_session)
        self.categoria_service = CategoriaService(db_session)
        self.mezcla_service = MezclaService(db_session)
        self.tratamiento_service = TratamientoService(db_session)
        self.lote_service = LoteAgroquimicoService(db_session)
        
        # Propiedades internas para QML
        self._productos = []
        self._categorias = []
        self._mezclas = []
        self._tratamientos = []
        self._lotes = []
        self._tipos_plagas = []
        self._ciclos_activos = []
        self._detalles_mezcla = []
        self._alertas_inventario = {}
        
        # Cargar datos iniciales si hay sesión
        if db_session:
            self.cargar_datos_iniciales()
    
    def set_db_session(self, db_session):
        """Establece la sesión de base de datos y carga los datos"""
        self.db_session = db_session
        # Recrear servicios con la nueva sesión
        self.producto_service = ProductoService(db_session)
        self.categoria_service = CategoriaService(db_session)
        self.mezcla_service = MezclaService(db_session)
        self.tratamiento_service = TratamientoService(db_session)
        self.lote_service = LoteAgroquimicoService(db_session)
        
        self.cargar_datos_iniciales()
    
    def cargar_datos_iniciales(self):
        """Carga todos los datos iniciales"""
        if not self.db_session:
            logger.warning("No hay sesión de base de datos para cargar datos")
            return
            
        self.cargar_productos()
        self.cargar_categorias()
        self.cargar_mezclas()
        self.cargar_tratamientos()
        self.cargar_lotes()
        self.cargar_alertas_inventario()
    
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
    
    @Property(list, notify=lotesChanged)
    def lotes(self):
        return self._lotes
    
    @Property(list, notify=tiposPlagasChanged)
    def tipos_plagas(self):
        return self._tipos_plagas
    
    @Property(list, notify=ciclosActivosChanged)
    def ciclos_activos(self):
        return self._ciclos_activos
    
    @Property(list, notify=detallesMezclaChanged)
    def detalles_mezcla(self):
        return self._detalles_mezcla
    
    @Property(dict, notify=alertasInventarioChanged)
    def alertas_inventario(self):
        return self._alertas_inventario
    
    # ==================== MÉTODOS PARA CARGAR DATOS ====================
    
    @Slot()
    def cargar_productos(self):
        """Carga la lista de productos desde el servicio"""
        try:
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar productos")
                return
                
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
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar categorías")
                return
                
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
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar mezclas")
                return
                
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
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar tratamientos")
                return
                
            self._tratamientos = self.tratamiento_service.obtener_todos_tratamientos()
            self.tratamientosChanged.emit()
            logger.info(f"✅ Cargados {len(self._tratamientos)} tratamientos")
        except Exception as e:
            logger.error(f"❌ Error al cargar tratamientos: {str(e)}")
            self._tratamientos = []
            self.tratamientosChanged.emit()
    
    @Slot()
    def cargar_lotes(self):
        """Carga la lista de lotes desde el servicio"""
        try:
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar lotes")
                return
                
            self._lotes = self.lote_service.obtener_todos_lotes()
            self.lotesChanged.emit()
            logger.info(f"✅ Cargados {len(self._lotes)} lotes")
        except Exception as e:
            logger.error(f"❌ Error al cargar lotes: {str(e)}")
            self._lotes = []
            self.lotesChanged.emit()
    
    @Slot()
    def cargar_tipos_plagas(self):
        """Carga la lista de tipos de plagas desde el servicio"""
        try:
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar tipos de plagas")
                return
                
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
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar ciclos activos")
                return
                
            self._ciclos_activos = self.tratamiento_service.obtener_ciclos_activos()
            self.ciclosActivosChanged.emit()
            logger.info(f"✅ Cargados {len(self._ciclos_activos)} ciclos activos")
        except Exception as e:
            logger.error(f"❌ Error al cargar ciclos activos: {str(e)}")
            self._ciclos_activos = []
            self.ciclosActivosChanged.emit()
    
    @Slot()
    def cargar_alertas_inventario(self):
        """Carga las alertas de inventario desde el servicio"""
        try:
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar alertas")
                return
                
            self._alertas_inventario = self.lote_service.obtener_alertas_inventario()
            self.alertasInventarioChanged.emit()
            logger.info("✅ Alertas de inventario cargadas")
        except Exception as e:
            logger.error(f"❌ Error al cargar alertas de inventario: {str(e)}")
            self._alertas_inventario = {}
            self.alertasInventarioChanged.emit()
    
    @Slot(int)
    def cargar_detalles_mezcla(self, id_mezcla):
        """Carga los detalles de una mezcla específica"""
        try:
            if not self.db_session:
                logger.warning("No hay sesión de BD para cargar detalles de mezcla")
                return
                
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
        """Agrega un nuevo producto"""
        try:
            producto_data = json.loads(producto_data_json)
            exito, id_producto, mensaje = self.producto_service.crear_producto(producto_data)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_producto})")
                self.cargar_productos()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except Exception as e:
            logger.error(f"❌ Error al agregar producto: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_producto(self, id_producto, producto_data_json):
        """Actualiza un producto existente"""
        try:
            producto_data = json.loads(producto_data_json)
            exito, mensaje = self.producto_service.actualizar_producto(id_producto, producto_data)
            
            if exito:
                logger.info(f"✅ {mensaje}")
                self.cargar_productos()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except Exception as e:
            logger.error(f"❌ Error al actualizar producto: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_producto(self, id_producto):
        """Elimina un producto existente"""
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
    
    # ==================== MÉTODOS PARA CATEGORÍAS ====================
    
    @Slot(str, result=bool)
    def agregar_categoria(self, categoria_data_json):
        """Agrega una nueva categoría"""
        try:
            categoria_data = json.loads(categoria_data_json)
            exito, id_categoria, mensaje = self.categoria_service.crear_categoria(categoria_data)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_categoria})")
                self.cargar_categorias()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except Exception as e:
            logger.error(f"❌ Error al agregar categoría: {str(e)}")
            return False
    
    # ==================== MÉTODOS PARA MEZCLAS ====================
    
    @Slot(str, str, result=bool)
    def agregar_mezcla(self, mezcla_data_json, detalles_data_json):
        """Agrega una nueva mezcla"""
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
            
        except Exception as e:
            logger.error(f"❌ Error al agregar mezcla: {str(e)}")
            return False
    
    # ==================== MÉTODOS PARA TRATAMIENTOS ====================
    
    @Slot(str, result=bool)
    def agregar_tratamiento(self, tratamiento_data_json):
        """Agrega un nuevo tratamiento"""
        try:
            tratamiento_data = json.loads(tratamiento_data_json)
            exito, id_tratamiento, mensaje = self.tratamiento_service.crear_tratamiento(tratamiento_data)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_tratamiento})")
                self.cargar_tratamientos()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except Exception as e:
            logger.error(f"❌ Error al agregar tratamiento: {str(e)}")
            return False
    
    # ==================== MÉTODOS PARA LOTES ====================
    
    @Slot(str, result=bool)
    def agregar_lote(self, lote_data_json):
        """Agrega un nuevo lote"""
        try:
            lote_data = json.loads(lote_data_json)
            exito, id_lote, mensaje = self.lote_service.crear_lote(lote_data)
            
            if exito:
                logger.info(f"✅ {mensaje} (ID: {id_lote})")
                self.cargar_lotes()
                self.cargar_alertas_inventario()
            else:
                logger.warning(f"⚠️ {mensaje}")
            
            return exito
            
        except Exception as e:
            logger.error(f"❌ Error al agregar lote: {str(e)}")
            return False
    
    @Slot(int, result=str)
    def obtener_lotes_por_producto(self, id_producto):
        """Obtiene lotes por producto"""
        try:
            lotes = self.lote_service.obtener_lotes_por_producto(id_producto)
            return json.dumps(lotes)
        except Exception as e:
            logger.error(f"❌ Error al obtener lotes por producto: {str(e)}")
            return json.dumps([])
    
    @Slot(result=str)
    def obtener_lotes_proximos_vencer(self):
        """Obtiene lotes próximos a vencer"""
        try:
            lotes = self.lote_service.obtener_lotes_proximos_vencer(30)
            return json.dumps(lotes)
        except Exception as e:
            logger.error(f"❌ Error al obtener lotes próximos a vencer: {str(e)}")
            return json.dumps([])
    
    # ==================== MÉTODOS DE UTILIDAD ====================
    
    @Slot(result=str)
    def obtener_resumen_inventario(self):
        """Obtiene resumen del inventario"""
        try:
            resumen = self.lote_service.obtener_resumen_inventario()
            return json.dumps(resumen)
        except Exception as e:
            logger.error(f"❌ Error al obtener resumen de inventario: {str(e)}")
            return json.dumps({})
    
    @Slot(int, float, result=str)
    def calcular_costo_mezcla(self, id_mezcla, cantidad_agua):
        """Calcula costo de mezcla"""
        try:
            costo_total, desglose = self.mezcla_service.calcular_costo_mezcla(id_mezcla, cantidad_agua)
            resultado = {'costo_total': costo_total, 'desglose': desglose}
            return json.dumps(resultado)
        except Exception as e:
            logger.error(f"❌ Error al calcular costo de mezcla: {str(e)}")
            return json.dumps({'costo_total': 0, 'desglose': []})
    
    @Slot()
    def actualizar_todos_datos(self):
        """Actualiza todos los datos del modelo"""
        logger.info("🔄 Actualizando todos los datos...")
        self.cargar_productos()
        self.cargar_categorias()
        self.cargar_mezclas()
        self.cargar_tratamientos()
        self.cargar_lotes()
        self.cargar_alertas_inventario()
        logger.info("✅ Todos los datos actualizados")
    
    @Slot(result=bool)
    def tiene_conexion_db(self):
        """Verifica si hay conexión a la base de datos"""
        return self.db_session is not None