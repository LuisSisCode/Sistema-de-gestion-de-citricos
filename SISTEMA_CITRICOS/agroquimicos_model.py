from PySide6.QtCore import QObject, Slot, Signal, Property
from bd_agroquimicos import GestorAgroquimicos
import json

class AgroquimicosModel(QObject):
    productosChanged = Signal()
    categoriasChanged = Signal()
    mezclasChanged = Signal()
    tratamientosChanged = Signal()
    tiposPlagasChanged = Signal()
    ciclosActivosChanged = Signal()
    detallesMezclaChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._gestor = GestorAgroquimicos()
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
    
    # Propiedades para QML
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
    
    # Métodos para cargar datos
    @Slot()
    def cargar_productos(self):
        """Carga la lista de productos desde la base de datos"""
        try:
            self._productos = self._gestor.obtener_productos()
            self.productosChanged.emit()
        except Exception as e:
            print(f"Error al cargar productos: {str(e)}")
    
    @Slot()
    def cargar_categorias(self):
        """Carga la lista de categorías desde la base de datos"""
        try:
            self._categorias = self._gestor.obtener_categorias()
            self.categoriasChanged.emit()
        except Exception as e:
            print(f"Error al cargar categorías: {str(e)}")
    
    @Slot()
    def cargar_mezclas(self):
        """Carga la lista de mezclas desde la base de datos"""
        try:
            self._mezclas = self._gestor.obtener_mezclas()
            self.mezclasChanged.emit()
        except Exception as e:
            print(f"Error al cargar mezclas: {str(e)}")
    
    @Slot()
    def cargar_tratamientos(self):
        """Carga la lista de tratamientos desde la base de datos"""
        try:
            self._tratamientos = self._gestor.obtener_tratamientos()
            self.tratamientosChanged.emit()
        except Exception as e:
            print(f"Error al cargar tratamientos: {str(e)}")
    
    @Slot()
    def cargar_tipos_plagas(self):
        """Carga la lista de tipos de plagas desde la base de datos"""
        try:
            self._tipos_plagas = self._gestor.obtener_tipos_plagas()
            self.tiposPlagasChanged.emit()
        except Exception as e:
            print(f"Error al cargar tipos de plagas: {str(e)}")
    
    @Slot()
    def cargar_ciclos_activos(self):
        """Carga la lista de ciclos activos desde la base de datos"""
        try:
            self._ciclos_activos = self._gestor.obtener_ciclos_activos()
            self.ciclosActivosChanged.emit()
        except Exception as e:
            print(f"Error al cargar ciclos activos: {str(e)}")
    
    @Slot(int)
    def cargar_detalles_mezcla(self, id_mezcla):
        """Carga los detalles de una mezcla específica"""
        try:
            self._detalles_mezcla = self._gestor.obtener_detalles_mezcla(id_mezcla)
            self.detallesMezclaChanged.emit()
        except Exception as e:
            print(f"Error al cargar detalles de mezcla: {str(e)}")
    
    # Métodos para PRODUCTOS
    @Slot(str, result=bool)
    def agregar_producto(self, producto_data_json):
        """Agrega un nuevo producto a la base de datos"""
        try:
            producto_data = json.loads(producto_data_json)
            success, _ = self._gestor.agregar_producto(producto_data)
            if success:
                self.cargar_productos()
            return success
        except Exception as e:
            print(f"Error al agregar producto: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_producto(self, id_producto, producto_data_json):
        """Actualiza un producto existente"""
        try:
            producto_data = json.loads(producto_data_json)
            success = self._gestor.actualizar_producto(id_producto, producto_data)
            if success:
                self.cargar_productos()
            return success
        except Exception as e:
            print(f"Error al actualizar producto: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_producto(self, id_producto):
        """Elimina un producto existente"""
        try:
            success = self._gestor.eliminar_producto(id_producto)
            if success:
                self.cargar_productos()
            return success
        except Exception as e:
            print(f"Error al eliminar producto: {str(e)}")
            return False
    
    # Métodos para CATEGORÍAS
    @Slot(str, result=bool)
    def agregar_categoria(self, categoria_data_json):
        """Agrega una nueva categoría a la base de datos"""
        try:
            categoria_data = json.loads(categoria_data_json)
            success, _ = self._gestor.agregar_categoria(categoria_data)
            if success:
                self.cargar_categorias()
            return success
        except Exception as e:
            print(f"Error al agregar categoría: {str(e)}")
            return False
    
    # Métodos para MEZCLAS
    @Slot(str, str, result=bool)
    def agregar_mezcla(self, mezcla_data_json, detalles_data_json):
        """Agrega una nueva mezcla a la base de datos"""
        try:
            mezcla_data = json.loads(mezcla_data_json)
            detalles_data = json.loads(detalles_data_json) if detalles_data_json else None
            success, _ = self._gestor.agregar_mezcla(mezcla_data, detalles_data)
            if success:
                self.cargar_mezclas()
            return success
        except Exception as e:
            print(f"Error al agregar mezcla: {str(e)}")
            return False
    
    # Métodos para TRATAMIENTOS
    @Slot(str, result=bool)
    def agregar_tratamiento(self, tratamiento_data_json):
        """Agrega un nuevo tratamiento a la base de datos"""
        try:
            tratamiento_data = json.loads(tratamiento_data_json)
            success, _ = self._gestor.agregar_tratamiento(tratamiento_data)
            if success:
                self.cargar_tratamientos()
            return success
        except Exception as e:
            print(f"Error al agregar tratamiento: {str(e)}")
            return False
    
    # Métodos de utilidad
    @Slot(result=str)
    def obtener_resumen_inventario(self):
        """Obtiene un resumen del inventario actual"""
        try:
            total_productos = len(self._productos)
            valor_total = sum(producto.get('precio', 0) * producto.get('stock', 0) for producto in self._productos)
            stock_critico = sum(1 for producto in self._productos if producto.get('stock', 0) < 1)
            categoria_mas_usada = "N/A"
            
            if self._productos:
                categorias_count = {}
                for producto in self._productos:
                    categoria = producto.get('categoria', 'Sin categoría')
                    categorias_count[categoria] = categorias_count.get(categoria, 0) + 1
                categoria_mas_usada = max(categorias_count, key=categorias_count.get)
            
            resumen = {
                'total_productos': total_productos,
                'valor_inventario': valor_total,
                'stock_critico': stock_critico,
                'categoria_mas_usada': categoria_mas_usada
            }
            
            return json.dumps(resumen)
        except Exception as e:
            print(f"Error al obtener resumen de inventario: {str(e)}")
            return json.dumps({})
    
    @Slot(float, result=bool)
    def actualizar_stock(self, id_producto, nueva_cantidad):
        """Actualiza el stock de un producto específico"""
        try:
            producto_data = {'stock': nueva_cantidad}
            success = self._gestor.actualizar_producto(id_producto, producto_data)
            if success:
                self.cargar_productos()
            return success
        except Exception as e:
            print(f"Error al actualizar stock: {str(e)}")
            return False
    @Slot(int, str, result=bool)
    def actualizar_categoria(self, id_categoria, categoria_data_json):
        """Actualiza una categoría existente"""
        try:
            categoria_data = json.loads(categoria_data_json)
            success = self._gestor.actualizar_categoria(id_categoria, categoria_data)
            if success:
                self.cargar_categorias()
            return success
        except Exception as e:
            print(f"Error al actualizar categoría: {str(e)}")
            return False