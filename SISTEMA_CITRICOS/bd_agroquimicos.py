# Base de datos donde se conectan las tablas de: productos agroquímicos, categorías, mezclas y tratamientos
import pyodbc
import logging
from bd_connection import DatabaseConnection
from datetime import datetime, date

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_agroquimicos')

class GestorAgroquimicos:
    def __init__(self, server=None, database=None, trusted_connection=True):
        """
        Inicializa la conexión a la base de datos SQL Server.
        
        Args:
            server (str): Nombre del servidor SQL Server.
            database (str): Nombre de la base de datos.
            trusted_connection (bool): Usar autenticación de Windows (True) o SQL Server (False).
        """
        try:
            if server and database:
                self.db = DatabaseConnection(server, database, trusted_connection)
            else:
                self.db = DatabaseConnection()
                
            # Probar la conexión al iniciar
            self.test_connection()
            logger.info("Conexión a la base de datos establecida correctamente.")
        except Exception as e:
            logger.error(f"Error al establecer la conexión a la base de datos: {str(e)}")
            raise

    def test_connection(self):
        """Prueba la conexión a la base de datos."""
        try:
            with self.db.get_connection() as conn:
                pass
        except Exception as e:
            logger.error(f"Error al probar la conexión: {str(e)}")
            raise

    # PRODUCTOS AGROQUÍMICOS
    def obtener_productos(self):
        """
        Obtiene todos los productos agroquímicos de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada producto.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT p.id_producto, p.nombre_comercial, c.nombre as categoria, 
                       p.formulacion, p.unidad, p.precio, p.stock, 
                       p.registro, p.notas, p.fecha_registro, p.activo,
                       c.id_categoria
                FROM ProductosAgroquimicos p
                LEFT JOIN CategoriaAgroquimicos c ON p.id_categoria = c.id_categoria
                ORDER BY p.id_producto
                """
                
                cursor.execute(query)
                productos = []
                
                for row in cursor.fetchall():
                    fecha_registro = row.fecha_registro.strftime('%Y-%m-%d') if row.fecha_registro else None
                    
                    producto = {
                        'id_producto': row.id_producto,
                        'nombre_comercial': row.nombre_comercial,
                        'categoria': row.categoria,
                        'id_categoria': row.id_categoria,
                        'formulacion': row.formulacion,
                        'unidad': row.unidad,
                        'precio': float(row.precio) if row.precio else 0.0,
                        'stock': float(row.stock) if row.stock else 0.0,
                        'registro': row.registro,
                        'notas': row.notas,
                        'fecha_registro': fecha_registro,
                        'activo': bool(row.activo)
                    }
                    productos.append(producto)
                
                logger.info(f"Se obtuvieron {len(productos)} productos de la base de datos.")
                return productos
        except Exception as e:
            logger.error(f"Error al obtener productos: {str(e)}")
            return []

    def agregar_producto(self, producto_data):
        """
        Agrega un nuevo producto agroquímico a la base de datos.
        
        Args:
            producto_data (dict): Datos del producto a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del producto agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO ProductosAgroquimicos (id_categoria, nombre_comercial, formulacion, 
                                                  unidad, precio, stock, registro, notas, fecha_registro, activo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                fecha_actual = date.today() if not producto_data.get('fecha_registro') else producto_data['fecha_registro']
                valores = (
                    producto_data['id_categoria'],
                    producto_data['nombre_comercial'],
                    producto_data.get('formulacion', 'Líquido'),
                    producto_data.get('unidad', 'L'),
                    producto_data.get('precio', 0.0),
                    producto_data.get('stock', 0.0),
                    producto_data.get('registro', 'PENDIENTE'),
                    producto_data.get('notas'),
                    fecha_actual,
                    1 if producto_data.get('activo', True) else 0
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_producto = cursor.fetchone()[0]
                
                logger.info(f"Producto agregado correctamente con ID: {id_producto}")
                return True, id_producto
        except Exception as e:
            logger.error(f"Error al agregar producto: {str(e)}")
            return False, None

    def actualizar_producto(self, id_producto, producto_data):
        """
        Actualiza un producto existente en la base de datos.
        
        Args:
            id_producto (int): ID del producto a actualizar.
            producto_data (dict): Datos actualizados del producto.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                campos_actualizar = []
                valores = []
                
                if 'id_categoria' in producto_data:
                    campos_actualizar.append("id_categoria = ?")
                    valores.append(producto_data['id_categoria'])
                    
                if 'nombre_comercial' in producto_data:
                    campos_actualizar.append("nombre_comercial = ?")
                    valores.append(producto_data['nombre_comercial'])
                    
                if 'formulacion' in producto_data:
                    campos_actualizar.append("formulacion = ?")
                    valores.append(producto_data['formulacion'])
                    
                if 'unidad' in producto_data:
                    campos_actualizar.append("unidad = ?")
                    valores.append(producto_data['unidad'])
                    
                if 'precio' in producto_data:
                    campos_actualizar.append("precio = ?")
                    valores.append(producto_data['precio'])
                    
                if 'stock' in producto_data:
                    campos_actualizar.append("stock = ?")
                    valores.append(producto_data['stock'])
                    
                if 'registro' in producto_data:
                    campos_actualizar.append("registro = ?")
                    valores.append(producto_data['registro'])
                    
                if 'notas' in producto_data:
                    campos_actualizar.append("notas = ?")
                    valores.append(producto_data['notas'])
                    
                if 'activo' in producto_data:
                    campos_actualizar.append("activo = ?")
                    valores.append(1 if producto_data['activo'] else 0)
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE ProductosAgroquimicos SET {', '.join(campos_actualizar)} WHERE id_producto = ?"
                valores.append(id_producto)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Producto actualizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar producto: {str(e)}")
            return False

    def eliminar_producto(self, id_producto):
        """
        Elimina un producto de la base de datos.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM ProductosAgroquimicos WHERE id_producto = ?"
                cursor.execute(query, (id_producto,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Producto eliminado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar producto: {str(e)}")
            return False

    # CATEGORÍAS
    def obtener_categorias(self):
        """
        Obtiene todas las categorías de productos agroquímicos de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada categoría.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_categoria, nombre, descripcion, activo
                FROM CategoriaAgroquimicos
                ORDER BY id_categoria
                """
                
                cursor.execute(query)
                categorias = []
                
                for row in cursor.fetchall():
                    categoria = {
                        'id_categoria': row.id_categoria,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'activo': bool(row.activo)
                    }
                    categorias.append(categoria)
                
                logger.info(f"Se obtuvieron {len(categorias)} categorías de la base de datos.")
                return categorias
        except Exception as e:
            logger.error(f"Error al obtener categorías: {str(e)}")
            return []

    def agregar_categoria(self, categoria_data):
        """
        Agrega una nueva categoría de agroquímicos a la base de datos.
        
        Args:
            categoria_data (dict): Datos de la categoría a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID de la categoría agregada o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO CategoriaAgroquimicos (nombre, descripcion, activo)
                VALUES (?, ?, ?)
                """
                
                valores = (
                    categoria_data['nombre'],
                    categoria_data.get('descripcion'),
                    1 if categoria_data.get('activo', True) else 0
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_categoria = cursor.fetchone()[0]
                
                logger.info(f"Categoría agregada correctamente con ID: {id_categoria}")
                return True, id_categoria
        except Exception as e:
            logger.error(f"Error al agregar categoría: {str(e)}")
            return False, None

    # MEZCLAS
    def obtener_mezclas(self):
        """
        Obtiene todas las mezclas de agroquímicos de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada mezcla.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_mezcla, nombre, descripcion, cantidad_agua, 
                       area_aplicacion, objetivo, indicaciones, fecha_creacion, activo, nota
                FROM MezclasAgroquimicos
                ORDER BY id_mezcla
                """
                
                cursor.execute(query)
                mezclas = []
                
                for row in cursor.fetchall():
                    fecha_creacion = row.fecha_creacion.strftime('%Y-%m-%d') if row.fecha_creacion else None
                    
                    mezcla = {
                        'id_mezcla': row.id_mezcla,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                        'area_aplicacion': float(row.area_aplicacion) if row.area_aplicacion else 0.0,
                        'objetivo': row.objetivo,
                        'indicaciones': row.indicaciones,
                        'fecha_creacion': fecha_creacion,
                        'activo': bool(row.activo),
                        'nota': row.nota
                    }
                    mezclas.append(mezcla)
                
                logger.info(f"Se obtuvieron {len(mezclas)} mezclas de la base de datos.")
                return mezclas
        except Exception as e:
            logger.error(f"Error al obtener mezclas: {str(e)}")
            return []

    def obtener_detalles_mezcla(self, id_mezcla):
        """
        Obtiene los detalles de una mezcla específica.
        
        Args:
            id_mezcla (int): ID de la mezcla.
            
        Returns:
            list: Lista de diccionarios con los detalles de la mezcla.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT dm.id_detalle_mezcla, dm.id_producto, dm.cantidad, 
                       dm.unidad_medida, dm.observaciones, p.nombre_comercial
                FROM DetallesMezcla dm
                JOIN ProductosAgroquimicos p ON dm.id_producto = p.id_producto
                WHERE dm.id_mezcla = ?
                ORDER BY dm.id_detalle_mezcla
                """
                
                cursor.execute(query, (id_mezcla,))
                detalles = []
                
                for row in cursor.fetchall():
                    detalle = {
                        'id_detalle_mezcla': row.id_detalle_mezcla,
                        'id_producto': row.id_producto,
                        'nombre_producto': row.nombre_comercial,
                        'cantidad': float(row.cantidad),
                        'unidad_medida': row.unidad_medida,
                        'observaciones': row.observaciones
                    }
                    detalles.append(detalle)
                
                return detalles
        except Exception as e:
            logger.error(f"Error al obtener detalles de mezcla: {str(e)}")
            return []

    def agregar_mezcla(self, mezcla_data, detalles_data=None):
        """
        Agrega una nueva mezcla de agroquímicos a la base de datos.
        
        Args:
            mezcla_data (dict): Datos de la mezcla a agregar.
            detalles_data (list): Lista de detalles de la mezcla.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID de la mezcla agregada o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Insertar la mezcla
                query = """
                INSERT INTO MezclasAgroquimicos (nombre, descripcion, cantidad_agua, 
                                                area_aplicacion, objetivo, indicaciones, fecha_creacion, activo, nota)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                fecha_actual = date.today()
                valores = (
                    mezcla_data['nombre'],
                    mezcla_data.get('descripcion'),
                    mezcla_data.get('cantidad_agua', 0.0),
                    mezcla_data.get('area_aplicacion', 0.0),
                    mezcla_data.get('objetivo'),
                    mezcla_data.get('indicaciones'),
                    fecha_actual,
                    1 if mezcla_data.get('activo', True) else 0,
                    mezcla_data.get('nota')
                )
                
                cursor.execute(query, valores)
                
                # Obtener el ID de la mezcla recién insertada
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_mezcla = cursor.fetchone()[0]
                
                # Insertar los detalles de la mezcla si existen
                if detalles_data:
                    query_detalle = """
                    INSERT INTO DetallesMezcla (id_mezcla, id_producto, cantidad, unidad_medida, observaciones)
                    VALUES (?, ?, ?, ?, ?)
                    """
                    
                    for detalle in detalles_data:
                        valores_detalle = (
                            id_mezcla,
                            detalle['id_producto'],
                            detalle['cantidad'],
                            detalle.get('unidad_medida', 'L'),
                            detalle.get('observaciones')
                        )
                        cursor.execute(query_detalle, valores_detalle)
                
                conn.commit()
                logger.info(f"Mezcla agregada correctamente con ID: {id_mezcla}")
                return True, id_mezcla
        except Exception as e:
            logger.error(f"Error al agregar mezcla: {str(e)}")
            return False, None

    # TRATAMIENTOS FITOSANITARIOS
    def obtener_tratamientos(self):
        """
        Obtiene todos los tratamientos fitosanitarios de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada tratamiento.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT t.id_tratamiento, t.id_ciclo, t.id_tipo_plaga, t.fecha_aplicacion, 
                       t.area_tratada, t.metodo_aplicacion, t.condiciones_climaticas, 
                       t.id_mezcla, t.cantidad_agua, t.costo_total, t.realizado_por, 
                       t.observaciones, 
                       c.id_variedad, v.nombre as variedad, p.nombre as parcela,
                       tp.nombre as tipo_plaga, m.nombre as mezcla,
                       u.nombre + ' ' + u.apellido as responsable
                FROM TratamientosFitosanitarios t
                LEFT JOIN CiclosProduccion c ON t.id_ciclo = c.id_ciclo
                LEFT JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
                LEFT JOIN Parcelas p ON c.id_parcela = p.id_parcela
                LEFT JOIN TiposPlagasMalezas tp ON t.id_tipo_plaga = tp.id_tipo
                LEFT JOIN MezclasAgroquimicos m ON t.id_mezcla = m.id_mezcla
                LEFT JOIN Usuarios u ON t.realizado_por = u.id_usuario
                ORDER BY t.fecha_aplicacion DESC
                """
                
                cursor.execute(query)
                tratamientos = []
                
                for row in cursor.fetchall():
                    fecha_aplicacion = row.fecha_aplicacion.strftime('%Y-%m-%d') if row.fecha_aplicacion else None
                    
                    tratamiento = {
                        'id_tratamiento': row.id_tratamiento,
                        'id_ciclo': row.id_ciclo,
                        'id_tipo_plaga': row.id_tipo_plaga,
                        'fecha_aplicacion': fecha_aplicacion,
                        'area_tratada': float(row.area_tratada) if row.area_tratada else 0.0,
                        'metodo_aplicacion': row.metodo_aplicacion,
                        'condiciones_climaticas': row.condiciones_climaticas,
                        'id_mezcla': row.id_mezcla,
                        'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                        'costo_total': float(row.costo_total) if row.costo_total else 0.0,
                        'realizado_por': row.realizado_por,
                        'observaciones': row.observaciones,
                        'variedad': row.variedad,
                        'parcela': row.parcela,
                        'tipo_plaga': row.tipo_plaga,
                        'mezcla': row.mezcla,
                        'responsable': row.responsable
                    }
                    tratamientos.append(tratamiento)
                
                logger.info(f"Se obtuvieron {len(tratamientos)} tratamientos de la base de datos.")
                return tratamientos
        except Exception as e:
            logger.error(f"Error al obtener tratamientos: {str(e)}")
            return []

    def agregar_tratamiento(self, tratamiento_data):
        """
        Agrega un nuevo tratamiento fitosanitario a la base de datos.
        
        Args:
            tratamiento_data (dict): Datos del tratamiento a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del tratamiento agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO TratamientosFitosanitarios (id_ciclo, id_tipo_plaga, fecha_aplicacion, 
                                                       area_tratada, metodo_aplicacion, condiciones_climaticas, 
                                                       id_mezcla, cantidad_agua, costo_total, realizado_por, 
                                                       observaciones)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    tratamiento_data['id_ciclo'],
                    tratamiento_data.get('id_tipo_plaga'),
                    tratamiento_data['fecha_aplicacion'],
                    tratamiento_data['area_tratada'],
                    tratamiento_data.get('metodo_aplicacion'),
                    tratamiento_data.get('condiciones_climaticas'),
                    tratamiento_data.get('id_mezcla'),
                    tratamiento_data.get('cantidad_agua'),
                    tratamiento_data.get('costo_total', 0.0),
                    tratamiento_data['realizado_por'],
                    tratamiento_data.get('observaciones')
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_tratamiento = cursor.fetchone()[0]
                
                logger.info(f"Tratamiento agregado correctamente con ID: {id_tratamiento}")
                return True, id_tratamiento
        except Exception as e:
            logger.error(f"Error al agregar tratamiento: {str(e)}")
            return False, None

    # TIPOS DE PLAGAS Y MALEZAS
    def obtener_tipos_plagas(self):
        """
        Obtiene todos los tipos de plagas y malezas de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada tipo.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_tipo, nombre, descripcion, categoria, activo
                FROM TiposPlagasMalezas
                ORDER BY nombre
                """
                
                cursor.execute(query)
                tipos = []
                
                for row in cursor.fetchall():
                    tipo = {
                        'id_tipo': row.id_tipo,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'categoria': row.categoria,
                        'activo': bool(row.activo)
                    }
                    tipos.append(tipo)
                
                logger.info(f"Se obtuvieron {len(tipos)} tipos de plagas/malezas de la base de datos.")
                return tipos
        except Exception as e:
            logger.error(f"Error al obtener tipos de plagas/malezas: {str(e)}")
            return []

    # CICLOS DE PRODUCCIÓN (para los tratamientos)
    def obtener_ciclos_activos(self):
        """
        Obtiene los ciclos de producción activos para los tratamientos.
        
        Returns:
            list: Lista de diccionarios con la información de cada ciclo activo.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_ciclo, c.fecha_siembra, c.estado, c.area_sembrada,
                       p.nombre as parcela, p.ubicacion,
                       v.nombre as variedad, t.nombre as tipo_cultivo
                FROM CiclosProduccion c
                JOIN Parcelas p ON c.id_parcela = p.id_parcela
                JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
                JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
                WHERE c.activo = 1 AND c.estado NOT IN ('Finalizado', 'Cancelado')
                ORDER BY c.fecha_siembra DESC
                """
                
                cursor.execute(query)
                ciclos = []
                
                for row in cursor.fetchall():
                    fecha_siembra = row.fecha_siembra.strftime('%Y-%m-%d') if row.fecha_siembra else None
                    
                    ciclo = {
                        'id_ciclo': row.id_ciclo,
                        'fecha_siembra': fecha_siembra,
                        'estado': row.estado,
                        'area_sembrada': float(row.area_sembrada) if row.area_sembrada else 0.0,
                        'parcela': row.parcela,
                        'ubicacion': row.ubicacion,
                        'variedad': row.variedad,
                        'tipo_cultivo': row.tipo_cultivo,
                        'descripcion': f"{row.tipo_cultivo} - {row.variedad} ({row.parcela})"
                    }
                    ciclos.append(ciclo)
                
                logger.info(f"Se obtuvieron {len(ciclos)} ciclos activos de la base de datos.")
                return ciclos
        except Exception as e:
            logger.error(f"Error al obtener ciclos activos: {str(e)}")
            return []