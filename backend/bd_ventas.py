# Gestión de ventas, detalles de venta, variedades y estados de venta
import pyodbc
import logging
from .core.database import DatabaseConnection
from datetime import datetime, date, timedelta
import uuid
import json
import logging
from datetime import datetime
from user_session import get_current_user_id  # Importar la función
from .core.cache_system import cacheable, cache_invalidator, get_ttl
# Configurar logging si no está ya configurado
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('ventas_model')

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_ventas')

logger = logging.getLogger('ventas_cliente_model')
class GestorVentas:
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

    # ==================== MÉTODOS PARA ESTADOS DE VENTA ====================
    @cacheable('estados', ttl=7200)
    def obtener_estados_venta(self):
        """
        Obtiene todos los estados de venta posibles.
        
        Returns:
            list: Lista de diccionarios con la información de cada estado de venta.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_estado, nombre, descripcion, activo
                FROM EstadosVenta
                WHERE activo = 1
                ORDER BY id_estado
                """
                
                cursor.execute(query)
                estados = []
                
                for row in cursor.fetchall():
                    estado = {
                        'id_estado': row.id_estado,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'activo': bool(row.activo)
                    }
                    estados.append(estado)
                
                logger.info(f"Se obtuvieron {len(estados)} estados de venta.")
                return estados
        except Exception as e:
            logger.error(f"Error al obtener estados de venta: {str(e)}")
            return []
    @cache_invalidator('estados')
    def agregar_estado_venta(self, estado_data):
        """
        Agrega un nuevo estado de venta.
        
        Args:
            estado_data (dict): Datos del estado a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del estado agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO EstadosVenta (nombre, descripcion, activo)
                VALUES (?, ?, ?)
                """
                
                valores = (
                    estado_data['nombre'],
                    estado_data.get('descripcion'),
                    1  # Activo por defecto
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del estado recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_estado = cursor.fetchone()[0]
                
                logger.info(f"Estado de venta agregado correctamente con ID: {id_estado}")
                return True, id_estado
        except Exception as e:
            logger.error(f"Error al agregar estado de venta: {str(e)}")
            return False, None

    # ==================== MÉTODOS PARA VARIEDADES DE CULTIVO ====================
    
    @cacheable('variedades', ttl=get_ttl('variedades'))
    def obtener_variedades_disponibles(self):
        """
        Obtiene las variedades de cultivo disponibles para venta.
        
        Returns:
            list: Lista de diccionarios con la información de cada variedad disponible.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_variedad, v.nombre AS variedad, 
                    tc.id_tipo_cultivo, tc.nombre AS tipo_cultivo,
                    v.activo
                FROM VariedadesCultivo v
                JOIN TiposCultivo tc ON v.id_tipo_cultivo = tc.id_tipo_cultivo
                WHERE v.activo = 1
                ORDER BY tc.nombre, v.nombre
                """
                
                cursor.execute(query)
                variedades = []
                
                for row in cursor.fetchall():
                    variedad = {
                        'id_variedad': row.id_variedad,
                        'variedad': row.variedad,
                        'id_tipo_cultivo': row.id_tipo_cultivo,
                        'tipo_cultivo': row.tipo_cultivo,
                        'activo': bool(row.activo),
                        'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
                    }
                    variedades.append(variedad)
                
                logger.info(f"Se obtuvieron {len(variedades)} variedades disponibles para venta.")
                return variedades
        except Exception as e:
            logger.error(f"Error al obtener variedades disponibles: {str(e)}")
            return []
    @cacheable('variedades', key_func=lambda id_var: f"id_{id_var}")
    def obtener_variedad_por_id(self, id_variedad):
        """
        Obtiene información detallada de una variedad específica.
        
        Args:
            id_variedad (int): ID de la variedad a obtener.
            
        Returns:
            dict: Diccionario con la información de la variedad o None si no se encuentra.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_variedad, v.nombre AS variedad, 
                    tc.id_tipo_cultivo, tc.nombre AS tipo_cultivo,
                    v.nombre_cientifico, v.descripcion, v.activo
                FROM VariedadesCultivo v
                JOIN TiposCultivo tc ON v.id_tipo_cultivo = tc.id_tipo_cultivo
                WHERE v.id_variedad = ?
                """
                
                cursor.execute(query, (id_variedad,))
                row = cursor.fetchone()
                
                if row:
                    variedad = {
                        'id_variedad': row.id_variedad,
                        'variedad': row.variedad,
                        'id_tipo_cultivo': row.id_tipo_cultivo,
                        'tipo_cultivo': row.tipo_cultivo,
                        'nombre_cientifico': row.nombre_cientifico,
                        'descripcion': row.descripcion,
                        'activo': bool(row.activo),
                        'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
                    }
                    return variedad
                return None
        except Exception as e:
            logger.error(f"Error al obtener variedad por ID: {str(e)}")
            return None

    # ==================== MÉTODOS PARA VENTAS ====================
    @cache_invalidator('ventas')
    def obtener_ventas(self):
        """
        Obtiene todas las ventas de la base de datos con información de cliente, estado y primer detalle.
        
        Returns:
            list: Lista de diccionarios con la información de cada venta.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Consulta modificada para incluir datos del primer detalle de cada venta
                query = """
                SELECT v.id_venta, v.id_cliente, c.nombre AS cliente_nombre, v.codigo_venta, 
                    v.fecha_venta, v.subtotal, v.total, v.condiciones_pago, v.fecha_entrega, 
                    v.lugar_entrega, v.id_estado, e.nombre AS estado_nombre, v.estado_pago,
                    u.nombre AS registrado_por_nombre, v.observaciones,
                    -- Datos del primer detalle de la venta (o NULL si no hay detalles)
                    (SELECT TOP 1 dv.cantidad FROM DetallesVenta dv WHERE dv.id_venta = v.id_venta) AS cantidad,
                    (SELECT TOP 1 dv.precio_unitario FROM DetallesVenta dv WHERE dv.id_venta = v.id_venta) AS precio_unitario
                FROM Ventas v
                JOIN Clientes c ON v.id_cliente = c.id_cliente
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                JOIN Usuarios u ON v.registrado_por = u.id_usuario
                ORDER BY v.fecha_venta DESC
                """
                
                cursor.execute(query)
                ventas = []
                
                for row in cursor.fetchall():
                    # Formatear fechas como strings de manera segura
                    fecha_venta = ""
                    fecha_entrega = ""
                    
                    # Manejar fecha_venta con cuidado
                    if row.fecha_venta:
                        if isinstance(row.fecha_venta, str):
                            fecha_venta = row.fecha_venta
                        elif hasattr(row.fecha_venta, 'strftime'):
                            fecha_venta = row.fecha_venta.strftime('%Y-%m-%d')
                        else:
                            fecha_venta = str(row.fecha_venta)
                    
                    # Manejar fecha_entrega con cuidado
                    if row.fecha_entrega:
                        if isinstance(row.fecha_entrega, str):
                            fecha_entrega = row.fecha_entrega
                        elif hasattr(row.fecha_entrega, 'strftime'):
                            fecha_entrega = row.fecha_entrega.strftime('%Y-%m-%d')
                        else:
                            fecha_entrega = str(row.fecha_entrega)
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'condiciones_pago': row.condiciones_pago or '',
                        'fecha_entrega': fecha_entrega,
                        'lugar_entrega': row.lugar_entrega or "",
                        'id_estado': row.id_estado,
                        'estado_nombre': row.estado_nombre,
                        'estado_pago': row.estado_pago,
                        'registrado_por': row.registrado_por_nombre,
                        'observaciones': row.observaciones or "",
                        # Agregar los datos del detalle
                        'cantidad': float(row.cantidad) if row.cantidad else 0.0,
                        'precio_unitario': float(row.precio_unitario) if row.precio_unitario else 0.0,
                    }
                    ventas.append(venta)
                    
                logger.info(f"Se obtuvieron {len(ventas)} ventas de la base de datos.")
                return ventas
        except Exception as e:
            logger.error(f"Error al obtener ventas: {str(e)}")
            return []
    @cacheable('ventas', key_func=lambda id_venta: f"id_{id_venta}")
    def obtener_venta_por_id(self, id_venta):
        """
        Obtiene una venta específica por su ID con todos sus detalles.
        
        Args:
            id_venta (int): ID de la venta a obtener.
            
        Returns:
            dict: Diccionario con la información de la venta o None si no se encuentra.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Consulta para obtener la información general de la venta
                query_venta = """
                SELECT v.id_venta, v.id_cliente, c.nombre AS cliente_nombre, v.codigo_venta, 
                       v.fecha_venta, v.subtotal, v.total, v.condiciones_pago, v.fecha_entrega, 
                       v.lugar_entrega, v.id_estado, e.nombre AS estado_nombre, v.estado_pago,
                       u.nombre AS registrado_por_nombre, v.observaciones
                FROM Ventas v
                JOIN Clientes c ON v.id_cliente = c.id_cliente
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                JOIN Usuarios u ON v.registrado_por = u.id_usuario
                WHERE v.id_venta = ?
                """
                
                cursor.execute(query_venta, (id_venta,))
                row_venta = cursor.fetchone()
                
                if not row_venta:
                    return None
                
                # Formatear fechas como strings
                fecha_venta = row_venta.fecha_venta.strftime('%Y-%m-%d') if row_venta.fecha_venta else None
                fecha_entrega = row_venta.fecha_entrega.strftime('%Y-%m-%d') if row_venta.fecha_entrega else None
                
                venta = {
                    'id_venta': row_venta.id_venta,
                    'id_cliente': row_venta.id_cliente,
                    'cliente_nombre': row_venta.cliente_nombre,
                    'codigo_venta': row_venta.codigo_venta,
                    'fecha_venta': fecha_venta,
                    'subtotal': float(row_venta.subtotal),
                    'total': float(row_venta.total),
                    'condiciones_pago': row_venta.condiciones_pago,
                    'fecha_entrega': fecha_entrega,
                    'lugar_entrega': row_venta.lugar_entrega,
                    'id_estado': row_venta.id_estado,
                    'estado_nombre': row_venta.estado_nombre,
                    'estado_pago': row_venta.estado_pago,
                    'registrado_por': row_venta.registrado_por_nombre,
                    'observaciones': row_venta.observaciones,
                    'detalles': []
                }
                
                # Consulta para obtener los detalles de la venta
                query_detalles = """
                SELECT dv.id_detalle_venta, dv.id_variedad,
                       vc.nombre AS variedad, tc.nombre AS tipo_cultivo,
                       dv.cantidad, dv.unidad_medida, dv.precio_unitario, 
                       dv.subtotal, dv.total, dv.observaciones
                FROM DetallesVenta dv
                JOIN VariedadesCultivo vc ON dv.id_variedad = vc.id_variedad
                JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
                WHERE dv.id_venta = ?
                """
                
                cursor.execute(query_detalles, (id_venta,))
                detalles_rows = cursor.fetchall()
                
                for detalle_row in detalles_rows:
                    detalle = {
                        'id_detalle_venta': detalle_row.id_detalle_venta,
                        'id_variedad': detalle_row.id_variedad,
                        'tipo_cultivo': detalle_row.tipo_cultivo,
                        'variedad': detalle_row.variedad,
                        'cantidad': float(detalle_row.cantidad),
                        'unidad_medida': detalle_row.unidad_medida,
                        'precio_unitario': float(detalle_row.precio_unitario),
                        'subtotal': float(detalle_row.subtotal),
                        'total': float(detalle_row.total),
                        'observaciones': detalle_row.observaciones,
                        'producto_completo': f"{detalle_row.tipo_cultivo} - {detalle_row.variedad}"
                    }
                    venta['detalles'].append(detalle)
                
                return venta
        except Exception as e:
            logger.error(f"Error al obtener venta por ID: {str(e)}")
            return None
    @cache_invalidator('ventas')
    @cache_invalidator('estadisticas')
    @cache_invalidator('reportes')
    def agregar_venta(self, venta_data_json, detalles_data_json):
        """Agrega una nueva venta con sus detalles a la base de datos"""
        try:
            # Convertir los strings JSON a diccionarios
            venta_data = json.loads(venta_data_json)
            detalles_data = json.loads(detalles_data_json)
            
            # Obtener el ID del usuario actual y asignarlo a registrado_por
            venta_data['registrado_por'] = get_current_user_id()
            logger.info(f"Venta será registrada por usuario ID: {venta_data['registrado_por']}")
            
            # Usar el método existente para agregar la venta
            success, id_venta = self._agregar_venta_impl(venta_data, detalles_data)
            
            #if success: -- por implementar
                #Recargar todas las listas afectadas
                #self.cargar_ventas()
                #self.cargar_resumen_ventas_mes()
                #self.cargar_pagos_pendientes()
                #self.cargar_cliente_top()
                #self.cargar_clientes_clasificados()
            
            return success
        except Exception as e:
            logger.error(f"Error al agregar venta: {str(e)}")
            return False

    def _agregar_venta_impl(self, venta_data, detalles_data):
        """Implementación interna del método agregar_venta"""
        try:
            # Validar cliente
            id_cliente = venta_data.get('id_cliente')
            if not id_cliente or id_cliente <= 0:
                logger.error(f"ID de cliente inválido: {id_cliente}")
                return False, None
                
            # Verificar que los detalles de venta contengan id_variedad válidos
            for i, detalle in enumerate(detalles_data):
                # Si no hay un id variedad válido
                if 'id_variedad' not in detalle or not detalle['id_variedad']:
                    logger.warning(f"Detalle #{i+1} tiene id_variedad inválido.")
                    return False, None
                
                # Verificar que la cantidad sea mayor que cero
                if 'cantidad' not in detalle or float(detalle['cantidad']) <= 0:
                    logger.error(f"Detalle #{i+1} no tiene cantidad válida")
                    return False, None
            
            # Verificar que el cliente existe
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                cursor.execute("SELECT COUNT(*) FROM Clientes WHERE id_cliente = ?", (id_cliente,))
                if cursor.fetchone()[0] == 0:
                    logger.error(f"El cliente con ID {id_cliente} no existe en la base de datos")
                    return False, None
                
                # Crear una declaración de inserción que evite el uso de parámetros para las fechas
                query_venta = """
                INSERT INTO Ventas (id_cliente, codigo_venta, fecha_venta, subtotal, total, 
                                condiciones_pago, fecha_entrega, lugar_entrega, id_estado, 
                                estado_pago, registrado_por, observaciones)
                VALUES (?, ?, CONVERT(DATE, ?), ?, ?, ?, {0}, ?, ?, ?, ?, ?)
                """
                
                # Manejar la fecha de entrega que podría ser NULL
                if venta_data.get('fecha_entrega'):
                    query_venta = query_venta.format("CONVERT(DATE, ?)")
                    fecha_entrega_param = venta_data['fecha_entrega']
                else:
                    query_venta = query_venta.format("NULL")
                    fecha_entrega_param = None
                
                # Configurar valores para la inserción
                fecha_venta = datetime.now().strftime('%Y-%m-%d') if 'fecha_venta' not in venta_data else venta_data['fecha_venta']
                
                valores_venta = [
                    venta_data['id_cliente'],
                    venta_data['codigo_venta'],
                    fecha_venta,
                    float(venta_data['subtotal']) if venta_data['subtotal'] is not None else 0.0,
                    float(venta_data['total']) if venta_data['total'] is not None else 0.0,
                    venta_data.get('condiciones_pago', ''),
                ]
                
                # Añadir fecha de entrega solo si no es NULL
                if fecha_entrega_param is not None:
                    valores_venta.append(fecha_entrega_param)
                    
                # Añadir el resto de parámetros
                valores_venta.extend([
                    venta_data.get('lugar_entrega', ''),
                    venta_data['id_estado'],
                    venta_data.get('estado_pago', 'Pendiente'),
                    venta_data['registrado_por'],  # Aquí está el ID del usuario actual
                    venta_data.get('observaciones', '')
                ])
                
                cursor.execute(query_venta, valores_venta)
                
                # Obtener el ID de la venta recién insertada
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_venta = cursor.fetchone()[0]
                
                # 2. Insertar los detalles de la venta
                for detalle in detalles_data:
                    # Insertar detalle de venta
                    query_detalle = """
                    INSERT INTO DetallesVenta (id_venta, cantidad, unidad_medida, 
                                            precio_unitario, subtotal, total, observaciones)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """
                    
                    valores_detalle = (
                        id_venta,
                        detalle['cantidad'],
                        detalle['unidad_medida'],
                        detalle['precio_unitario'],
                        detalle['subtotal'],
                        detalle['total'],
                        detalle.get('observaciones')
                    )
                    
                    cursor.execute(query_detalle, valores_detalle)
                
                # Confirmar la transacción
                conn.commit()
                
                logger.info(f"Venta agregada correctamente con ID: {id_venta}")
                return True, id_venta
        except Exception as e:
            if 'conn' in locals() and conn:
                conn.rollback()
            logger.error(f"Error al agregar venta: {str(e)}")
            return False, None
    @cache_invalidator('ventas', pattern='id_')
    @cache_invalidator('estadisticas')
    @cache_invalidator('reportes')
    def actualizar_venta(self, id_venta, venta_data):
        """
        Actualiza una venta existente en la base de datos.
        
        Args:
            id_venta (int): ID de la venta a actualizar.
            venta_data (dict): Datos actualizados de la venta.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'id_cliente' in venta_data:
                    campos_actualizar.append("id_cliente = ?")
                    valores.append(venta_data['id_cliente'])
                    
                if 'fecha_venta' in venta_data:
                    campos_actualizar.append("fecha_venta = ?")
                    fecha_venta = datetime.strptime(venta_data['fecha_venta'], '%Y-%m-%d').date()
                    valores.append(fecha_venta)
                    
                if 'subtotal' in venta_data:
                    campos_actualizar.append("subtotal = ?")
                    valores.append(venta_data['subtotal'])
                    
                if 'total' in venta_data:
                    campos_actualizar.append("total = ?")
                    valores.append(venta_data['total'])
                    
                if 'condiciones_pago' in venta_data:
                    campos_actualizar.append("condiciones_pago = ?")
                    valores.append(venta_data['condiciones_pago'])
                    
                if 'fecha_entrega' in venta_data:
                    campos_actualizar.append("fecha_entrega = ?")
                    if venta_data['fecha_entrega']:
                        fecha_entrega = datetime.strptime(venta_data['fecha_entrega'], '%Y-%m-%d').date()
                        valores.append(fecha_entrega)
                    else:
                        valores.append(None)
                    
                if 'lugar_entrega' in venta_data:
                    campos_actualizar.append("lugar_entrega = ?")
                    valores.append(venta_data['lugar_entrega'])
                    
                if 'id_estado' in venta_data:
                    campos_actualizar.append("id_estado = ?")
                    valores.append(venta_data['id_estado'])
                    
                if 'estado_pago' in venta_data:
                    campos_actualizar.append("estado_pago = ?")
                    valores.append(venta_data['estado_pago'])
                    
                if 'observaciones' in venta_data:
                    campos_actualizar.append("observaciones = ?")
                    valores.append(venta_data['observaciones'])
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE Ventas SET {', '.join(campos_actualizar)} WHERE id_venta = ?"
                valores.append(id_venta)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Venta actualizada correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar venta: {str(e)}")
            return False
    @cache_invalidator('ventas')
    @cache_invalidator('estadisticas')
    @cache_invalidator('reportes')
    def cancelar_venta(self, id_venta, motivo_cancelacion):
        """
        Cancela una venta.
        
        Args:
            id_venta (int): ID de la venta a cancelar.
            motivo_cancelacion (str): Motivo por el cual se cancela la venta.
            
        Returns:
            bool: True si se canceló correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                conn.autocommit = False  # Iniciar transacción
                
                # 1. Obtener el ID del estado "Cancelado"
                query_estado = "SELECT id_estado FROM EstadosVenta WHERE nombre = 'Cancelado'"
                cursor.execute(query_estado)
                row_estado = cursor.fetchone()
                
                if not row_estado:
                    logger.error("No se encontró el estado 'Cancelado'")
                    return False
                
                id_estado_cancelado = row_estado.id_estado
                
                # 2. Actualizar la venta a estado cancelado
                observaciones = f"CANCELADO: {motivo_cancelacion}"
                query_actualizar = """
                UPDATE Ventas
                SET id_estado = ?, observaciones = ?
                WHERE id_venta = ?
                """
                
                cursor.execute(query_actualizar, (id_estado_cancelado, observaciones, id_venta))
                
                # Confirmar la transacción
                conn.commit()
                
                logger.info(f"Venta ID {id_venta} cancelada correctamente")
                return True
        except Exception as e:
            if 'conn' in locals() and conn:
                conn.rollback()
            logger.error(f"Error al cancelar venta: {str(e)}")
            return False
    @cache_invalidator('ventas', pattern='id_')
    @cache_invalidator('estadisticas')
    def cambiar_estado_venta(self, id_venta, nuevo_estado_id):
        """
        Actualiza el estado de una venta.
        
        Args:
            id_venta (int): ID de la venta a actualizar.
            nuevo_estado_id (int): ID del nuevo estado.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "UPDATE Ventas SET id_estado = ? WHERE id_venta = ?"
                cursor.execute(query, (nuevo_estado_id, id_venta))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Estado de venta actualizado. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al cambiar estado de venta: {str(e)}")
            return False
    @cache_invalidator('ventas', pattern='id_')
    @cache_invalidator('estadisticas')
    def cambiar_estado_pago(self, id_venta, nuevo_estado_pago):
        """
        Actualiza el estado de pago de una venta.
        
        Args:
            id_venta (int): ID de la venta a actualizar.
            nuevo_estado_pago (str): Nuevo estado de pago ('Pendiente', 'Parcial', 'Pagado').
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Verificar que el nuevo estado sea válido
                if nuevo_estado_pago not in ['Pendiente', 'Parcial', 'Pagado']:
                    logger.error(f"Estado de pago inválido: {nuevo_estado_pago}")
                    return False
                
                query = "UPDATE Ventas SET estado_pago = ? WHERE id_venta = ?"
                cursor.execute(query, (nuevo_estado_pago, id_venta))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Estado de pago actualizado. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al cambiar estado de pago: {str(e)}")
            return False
    @cache_invalidator('ventas')
    @cache_invalidator('estadisticas')
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
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                conn.autocommit = False  # Iniciar transacción
                
                # 1. Obtener los datos de la venta original
                query_venta = """
                SELECT id_cliente, codigo_venta, fecha_venta, condiciones_pago, 
                    lugar_entrega, registrado_por
                FROM Ventas 
                WHERE id_venta = ?
                """
                
                cursor.execute(query_venta, (id_venta,))
                venta_original = cursor.fetchone()
                
                if not venta_original:
                    logger.error(f"No se encontró la venta con ID {id_venta}")
                    return False, None
                
                # 2. Generar nuevo código si no se proporcionó
                if not nuevo_codigo:
                    nuevo_codigo = self.generar_codigo_venta()
                
                # 3. Establecer nueva fecha si no se proporcionó
                if nueva_fecha:
                    fecha_nueva_venta = datetime.strptime(nueva_fecha, '%Y-%m-%d').date()
                else:
                    fecha_nueva_venta = datetime.now().date()
                
                # 4. Obtener ID del estado 'Planificado' o similar
                query_estado = "SELECT TOP 1 id_estado FROM EstadosVenta WHERE nombre IN ('Planificado', 'Pendiente', 'Borrador')"
                cursor.execute(query_estado)
                estado_inicial = cursor.fetchone()
                
                if not estado_inicial:
                    # Si no encuentra estados específicos, usar el primer estado activo
                    cursor.execute("SELECT TOP 1 id_estado FROM EstadosVenta WHERE activo = 1")
                    estado_inicial = cursor.fetchone()
                
                id_estado_inicial = estado_inicial.id_estado
                
                # 5. Insertar la nueva venta
                query_insertar = """
                INSERT INTO Ventas (id_cliente, codigo_venta, fecha_venta, subtotal, total, 
                                condiciones_pago, lugar_entrega, id_estado, 
                                estado_pago, registrado_por, observaciones)
                VALUES (?, ?, ?, 0, 0, ?, ?, ?, 'Pendiente', ?, 'Duplicado de venta #' + CAST(? AS VARCHAR))
                """
                
                valores_insertar = (
                    venta_original.id_cliente,
                    nuevo_codigo,
                    fecha_nueva_venta,
                    venta_original.condiciones_pago,
                    venta_original.lugar_entrega,
                    id_estado_inicial,
                    venta_original.registrado_por,
                    id_venta
                )
                
                cursor.execute(query_insertar, valores_insertar)
                
                # 6. Obtener el ID de la venta recién insertada
                cursor.execute("SELECT @@IDENTITY AS ID")
                nueva_venta_id = cursor.fetchone()[0]
                
                # 7. Obtener los detalles de la venta original
                query_detalles = """
                SELECT id_variedad, cantidad, unidad_medida, precio_unitario, 
                    subtotal, total, observaciones
                FROM DetallesVenta 
                WHERE id_venta = ?
                """
                
                cursor.execute(query_detalles, (id_venta,))
                detalles_originales = cursor.fetchall()
                
                # 8. Calcular totales para actualizar
                subtotal_total = 0
                total_final = 0
                
                # 9. Insertar los detalles
                for detalle in detalles_originales:
                    # Insertar detalle
                    query_insertar_detalle = """
                    INSERT INTO DetallesVenta (id_venta, id_variedad, cantidad, unidad_medida, 
                                            precio_unitario, subtotal, total, observaciones)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """
                    
                    valores_detalle = (
                        nueva_venta_id,
                        detalle.id_variedad,
                        detalle.cantidad,
                        detalle.unidad_medida,
                        detalle.precio_unitario,
                        detalle.subtotal,
                        detalle.total,
                        detalle.observaciones
                    )
                    
                    cursor.execute(query_insertar_detalle, valores_detalle)
                    
                    # Acumular totales
                    subtotal_total += detalle.subtotal
                    total_final += detalle.total
                
                # 10. Actualizar los totales de la nueva venta
                query_actualizar_totales = """
                UPDATE Ventas
                SET subtotal = ?, total = ?
                WHERE id_venta = ?
                """
                
                cursor.execute(query_actualizar_totales, (subtotal_total, total_final, nueva_venta_id))
                
                # Confirmar la transacción
                conn.commit()
                
                logger.info(f"Venta duplicada correctamente con ID: {nueva_venta_id}")
                return True, nueva_venta_id
        except Exception as e:
            if 'conn' in locals() and conn:
                conn.rollback()
            logger.error(f"Error al duplicar venta: {str(e)}")
            return False, None

    def buscar_ventas_por_rango_monto(self, monto_min, monto_max):
        """
        Busca ventas dentro de un rango de montos.
        
        Args:
            monto_min (float): Monto mínimo a buscar.
            monto_max (float): Monto máximo a buscar.
            
        Returns:
            list: Lista de diccionarios con las ventas encontradas.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.id_cliente, c.nombre AS cliente_nombre, v.codigo_venta, 
                       v.fecha_venta, v.total, v.estado_pago, e.nombre AS estado_nombre
                FROM Ventas v
                JOIN Clientes c ON v.id_cliente = c.id_cliente
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                WHERE v.total BETWEEN ? AND ?
                ORDER BY v.total DESC
                """
                
                cursor.execute(query, (monto_min, monto_max))
                ventas = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'total': float(row.total),
                        'estado_pago': row.estado_pago,
                        'estado_nombre': row.estado_nombre
                    }
                    ventas.append(venta)
                
                logger.info(f"Se encontraron {len(ventas)} ventas en el rango de montos especificado.")
                return ventas
        except Exception as e:
            logger.error(f"Error al buscar ventas por rango de monto: {str(e)}")
            return []

    # ==================== MÉTODOS PARA DETALLES DE VENTA ====================
    @cacheable('ventas', key_func=lambda id_venta: f"detalles_{id_venta}") 
    def obtener_detalles_venta(self, id_venta):
        """
        Obtiene todos los detalles de una venta específica.
        
        Args:
            id_venta (int): ID de la venta para obtener sus detalles.
            
        Returns:
            list: Lista de diccionarios con la información de cada detalle.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT dv.id_detalle_venta, dv.id_variedad,
                       tc.nombre AS tipo_cultivo, vc.nombre AS variedad, 
                       dv.cantidad, dv.unidad_medida, dv.precio_unitario, 
                       dv.subtotal, dv.total, dv.observaciones
                FROM DetallesVenta dv
                JOIN VariedadesCultivo vc ON dv.id_variedad = vc.id_variedad
                JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
                WHERE dv.id_venta = ?
                ORDER BY dv.id_detalle_venta
                """
                
                cursor.execute(query, (id_venta,))
                detalles = []
                
                for row in cursor.fetchall():
                    detalle = {
                        'id_detalle_venta': row.id_detalle_venta,
                        'id_variedad': row.id_variedad,
                        'tipo_cultivo': row.tipo_cultivo,
                        'variedad': row.variedad,
                        'cantidad': float(row.cantidad),
                        'unidad_medida': row.unidad_medida,
                        'precio_unitario': float(row.precio_unitario),
                        'subtotal': float(row.subtotal),
                        'total': float(row.total),
                        'observaciones': row.observaciones,
                        'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
                    }
                    detalles.append(detalle)
                
                logger.info(f"Se obtuvieron {len(detalles)} detalles para la venta ID: {id_venta}")
                return detalles
        except Exception as e:
            logger.error(f"Error al obtener detalles de venta: {str(e)}")
            return []
    @cache_invalidator('ventas', pattern='detalles_')
    @cache_invalidator('estadisticas')
    def agregar_detalle_venta(self, id_venta, detalle_data):
        """
        Agrega un nuevo detalle a una venta existente.
        
        Args:
            id_venta (int): ID de la venta a la que se agregará el detalle.
            detalle_data (dict): Datos del detalle a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                conn.autocommit = False  # Iniciar transacción
                
                # Insertar detalle de venta
                query_detalle = """
                INSERT INTO DetallesVenta (id_venta, id_variedad, cantidad, unidad_medida, 
                                        precio_unitario, subtotal, total, observaciones)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                valores_detalle = (
                    id_venta,
                    detalle_data['id_variedad'],
                    detalle_data['cantidad'],
                    detalle_data['unidad_medida'],
                    detalle_data['precio_unitario'],
                    detalle_data['subtotal'],
                    detalle_data['total'],
                    detalle_data.get('observaciones')
                )
                
                cursor.execute(query_detalle, valores_detalle)
                
                # Actualizar el total de la venta
                query_obtener_totales = """
                SELECT SUM(subtotal) AS nuevo_subtotal, SUM(total) AS nuevo_total 
                FROM DetallesVenta 
                WHERE id_venta = ?
                """
                
                cursor.execute(query_obtener_totales, (id_venta,))
                row_totales = cursor.fetchone()
                
                if row_totales:
                    nuevo_subtotal = row_totales.nuevo_subtotal
                    nuevo_total = row_totales.nuevo_total
                    
                    query_actualizar_venta = """
                    UPDATE Ventas 
                    SET subtotal = ?, total = ?
                    WHERE id_venta = ?
                    """
                    
                    cursor.execute(query_actualizar_venta, (nuevo_subtotal, nuevo_total, id_venta))
                
                conn.commit()
                
                logger.info(f"Detalle de venta agregado correctamente a la venta {id_venta}")
                return True
        except Exception as e:
            if 'conn' in locals() and conn:
                conn.rollback()
            logger.error(f"Error al agregar detalle de venta: {str(e)}")
            return False
    @cache_invalidator('ventas', pattern='detalles_')
    @cache_invalidator('estadisticas')
    def eliminar_detalle_venta(self, id_detalle_venta):
        """
        Elimina un detalle de venta y actualiza los totales de la venta.
        
        Args:
            id_detalle_venta (int): ID del detalle de venta a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                conn.autocommit = False  # Iniciar transacción
                
                # Obtener información del detalle antes de eliminarlo
                query_obtener_detalle = """
                SELECT id_venta
                FROM DetallesVenta
                WHERE id_detalle_venta = ?
                """
                
                cursor.execute(query_obtener_detalle, (id_detalle_venta,))
                row_detalle = cursor.fetchone()
                
                if not row_detalle:
                    logger.warning(f"No se encontró el detalle de venta con ID {id_detalle_venta}")
                    return False
                
                id_venta = row_detalle.id_venta
                
                # Eliminar el detalle de venta
                query_eliminar = "DELETE FROM DetallesVenta WHERE id_detalle_venta = ?"
                cursor.execute(query_eliminar, (id_detalle_venta,))
                
                # Actualizar el total de la venta
                query_obtener_totales = """
                SELECT SUM(subtotal) AS nuevo_subtotal, SUM(total) AS nuevo_total 
                FROM DetallesVenta 
                WHERE id_venta = ?
                """
                
                cursor.execute(query_obtener_totales, (id_venta,))
                row_totales = cursor.fetchone()
                
                nuevo_subtotal = row_totales.nuevo_subtotal if row_totales.nuevo_subtotal else 0
                nuevo_total = row_totales.nuevo_total if row_totales.nuevo_total else 0
                
                query_actualizar_venta = """
                UPDATE Ventas 
                SET subtotal = ?, total = ?
                WHERE id_venta = ?
                """
                
                cursor.execute(query_actualizar_venta, (nuevo_subtotal, nuevo_total, id_venta))
                
                conn.commit()
                
                logger.info(f"Detalle de venta eliminado correctamente. ID: {id_detalle_venta}")
                return True
        except Exception as e:
            if 'conn' in locals() and conn:
                conn.rollback()
            logger.error(f"Error al eliminar detalle de venta: {str(e)}")
            return False
    @cache_invalidator('ventas', pattern='detalles_')
    @cache_invalidator('estadisticas')
    def actualizar_detalle_venta(self, id_detalle_venta, detalle_data):
        """
        Actualiza un detalle de venta existente y recalcula los totales.
        
        Args:
            id_detalle_venta (int): ID del detalle de venta a actualizar.
            detalle_data (dict): Datos actualizados del detalle.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                conn.autocommit = False  # Iniciar transacción
                
                # Obtener información del detalle antes de actualizarlo
                query_obtener_detalle = """
                SELECT id_venta
                FROM DetallesVenta
                WHERE id_detalle_venta = ?
                """
                
                cursor.execute(query_obtener_detalle, (id_detalle_venta,))
                row_detalle = cursor.fetchone()
                
                if not row_detalle:
                    logger.warning(f"No se encontró el detalle de venta con ID {id_detalle_venta}")
                    return False
                
                id_venta = row_detalle.id_venta
                
                # Actualizar el detalle de venta
                campos_actualizar = []
                valores = []
                
                if 'id_variedad' in detalle_data:
                    campos_actualizar.append("id_variedad = ?")
                    valores.append(detalle_data['id_variedad'])
                    
                if 'cantidad' in detalle_data:
                    campos_actualizar.append("cantidad = ?")
                    valores.append(detalle_data['cantidad'])
                    
                if 'unidad_medida' in detalle_data:
                    campos_actualizar.append("unidad_medida = ?")
                    valores.append(detalle_data['unidad_medida'])
                    
                if 'precio_unitario' in detalle_data:
                    campos_actualizar.append("precio_unitario = ?")
                    valores.append(detalle_data['precio_unitario'])
                    
                if 'subtotal' in detalle_data:
                    campos_actualizar.append("subtotal = ?")
                    valores.append(detalle_data['subtotal'])
                    
                if 'total' in detalle_data:
                    campos_actualizar.append("total = ?")
                    valores.append(detalle_data['total'])
                    
                if 'observaciones' in detalle_data:
                    campos_actualizar.append("observaciones = ?")
                    valores.append(detalle_data['observaciones'])
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar en el detalle")
                    conn.commit()  # Confirmar las operaciones realizadas
                    return True
                
                query_actualizar = f"UPDATE DetallesVenta SET {', '.join(campos_actualizar)} WHERE id_detalle_venta = ?"
                valores.append(id_detalle_venta)
                
                cursor.execute(query_actualizar, valores)
                
                # Recalcular los totales de la venta
                query_obtener_totales = """
                SELECT SUM(subtotal) AS nuevo_subtotal, SUM(total) AS nuevo_total 
                FROM DetallesVenta 
                WHERE id_venta = ?
                """
                
                cursor.execute(query_obtener_totales, (id_venta,))
                row_totales = cursor.fetchone()
                
                nuevo_subtotal = row_totales.nuevo_subtotal if row_totales.nuevo_subtotal else 0
                nuevo_total = row_totales.nuevo_total if row_totales.nuevo_total else 0
                
                query_actualizar_venta = """
                UPDATE Ventas 
                SET subtotal = ?, total = ?
                WHERE id_venta = ?
                """
                
                cursor.execute(query_actualizar_venta, (nuevo_subtotal, nuevo_total, id_venta))
                
                conn.commit()
                
                logger.info(f"Detalle de venta actualizado correctamente. ID: {id_detalle_venta}")
                return True
        except Exception as e:
            if 'conn' in locals() and conn:
                conn.rollback()
            logger.error(f"Error al actualizar detalle de venta: {str(e)}")
            return False

    # ==================== MÉTODOS PARA REPORTES Y ESTADÍSTICAS ====================
    @cacheable('reportes', key_func=lambda fi, ff: f"periodo_{fi}_{ff}", ttl=600)
    def obtener_resumen_ventas_por_periodo(self, fecha_inicio, fecha_fin):
        """
        Obtiene un resumen de ventas por un período específico.
        
        Args:
            fecha_inicio (str): Fecha de inicio en formato YYYY-MM-DD.
            fecha_fin (str): Fecha de fin en formato YYYY-MM-DD.
            
        Returns:
            dict: Diccionario con el resumen de ventas.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Guardar las fechas originales como string para el resultado
                fecha_inicio_str = fecha_inicio
                fecha_fin_str = fecha_fin
                
                # Asegurarse de que las fechas estén en formato string adecuado para SQL Server
                # SQL Server usa 'YYYY-MM-DD' para fechas
                if isinstance(fecha_inicio, datetime) or isinstance(fecha_inicio, date):
                    fecha_inicio = fecha_inicio.strftime('%Y-%m-%d')
                
                if isinstance(fecha_fin, datetime) or isinstance(fecha_fin, date):
                    fecha_fin = fecha_fin.strftime('%Y-%m-%d')
                
                # Consulta para obtener el total de ventas en el período
                query_total = """
                SELECT COUNT(*) AS total_ventas, 
                    SUM(total) AS monto_total,
                    SUM(CASE WHEN estado_pago = 'Pagado' THEN total ELSE 0 END) AS monto_pagado,
                    SUM(CASE WHEN estado_pago = 'Pendiente' THEN total ELSE 0 END) AS monto_pendiente,
                    SUM(CASE WHEN estado_pago = 'Parcial' THEN total ELSE 0 END) AS monto_parcial
                FROM Ventas
                WHERE fecha_venta BETWEEN ? AND ?
                """
                
                cursor.execute(query_total, (fecha_inicio, fecha_fin))
                row_total = cursor.fetchone()
                
                # Si no hay resultados, devolver un resumen vacío pero estructurado
                if not row_total:
                    return {
                        'periodo': {
                            'fecha_inicio': fecha_inicio_str,
                            'fecha_fin': fecha_fin_str
                        },
                        'totales': {
                            'total_ventas': 0,
                            'monto_total': 0.0,
                            'monto_pagado': 0.0,
                            'monto_pendiente': 0.0,
                            'monto_parcial': 0.0
                        },
                        'por_cliente': [],
                        'por_estado': []
                    }
                
                # Consulta para obtener ventas por cliente
                query_clientes = """
                SELECT c.id_cliente, c.nombre, COUNT(v.id_venta) AS total_ventas, SUM(v.total) AS monto_total
                FROM Ventas v
                JOIN Clientes c ON v.id_cliente = c.id_cliente
                WHERE v.fecha_venta BETWEEN ? AND ?
                GROUP BY c.id_cliente, c.nombre
                ORDER BY monto_total DESC
                """
                
                cursor.execute(query_clientes, (fecha_inicio, fecha_fin))
                clientes_rows = cursor.fetchall()
                
                clientes = []
                for row in clientes_rows:
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'total_ventas': row.total_ventas,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0
                    }
                    clientes.append(cliente)
                
                # Consulta para obtener ventas por estado
                query_estados = """
                SELECT e.id_estado, e.nombre, COUNT(v.id_venta) AS total_ventas, SUM(v.total) AS monto_total
                FROM Ventas v
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                WHERE v.fecha_venta BETWEEN ? AND ?
                GROUP BY e.id_estado, e.nombre
                ORDER BY monto_total DESC
                """
                
                cursor.execute(query_estados, (fecha_inicio, fecha_fin))
                estados_rows = cursor.fetchall()
                
                estados = []
                for row in estados_rows:
                    estado = {
                        'id_estado': row.id_estado,
                        'nombre': row.nombre,
                        'total_ventas': row.total_ventas,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0
                    }
                    estados.append(estado)
                
                # Armar el resumen
                resumen = {
                    'periodo': {
                        'fecha_inicio': fecha_inicio_str,
                        'fecha_fin': fecha_fin_str
                    },
                    'totales': {
                        'total_ventas': row_total.total_ventas,
                        'monto_total': float(row_total.monto_total) if row_total.monto_total else 0.0,
                        'monto_pagado': float(row_total.monto_pagado) if row_total.monto_pagado else 0.0,
                        'monto_pendiente': float(row_total.monto_pendiente) if row_total.monto_pendiente else 0.0,
                        'monto_parcial': float(row_total.monto_parcial) if row_total.monto_parcial else 0.0
                    },
                    'por_cliente': clientes,
                    'por_estado': estados
                }
                
                return resumen
        except Exception as e:
            logger.error(f"Error al obtener resumen de ventas: {str(e)}")
            return None
    @cacheable('reportes', key_func=lambda: 'mes_actual', ttl=600)
    def obtener_ventas_del_mes(self):
        """
        Obtiene un resumen de las ventas del mes actual.
        
        Returns:
            dict: Diccionario con el resumen de ventas del mes.
        """
        try:
            # Obtener el primer y último día del mes actual
            hoy = datetime.now().date()
            primer_dia_mes = datetime(hoy.year, hoy.month, 1).date()
            
            # Calcular el último día del mes
            if hoy.month == 12:
                ultimo_dia_mes = datetime(hoy.year + 1, 1, 1).date()
            else:
                ultimo_dia_mes = datetime(hoy.year, hoy.month + 1, 1).date()
            
            ultimo_dia_mes = (ultimo_dia_mes - timedelta(days=1))
            
            # Utilizar la función existente
            return self.obtener_resumen_ventas_por_periodo(
                primer_dia_mes.strftime('%Y-%m-%d'),
                ultimo_dia_mes.strftime('%Y-%m-%d')
            )
        except Exception as e:
            logger.error(f"Error al obtener ventas del mes: {str(e)}")
            return None
    @cacheable('reportes', key_func=lambda: 'semana_actual', ttl=600)
    def obtener_reporte_semanal(self):
        """
        Obtiene un reporte de ventas de la semana actual.
        
        Returns:
            dict: Diccionario con el reporte semanal.
        """
        try:
            # Obtener el primer día de la semana (lunes)
            hoy = datetime.now().date()
            dia_semana = hoy.weekday()  # 0 es lunes, 6 es domingo
            primer_dia_semana = hoy - timedelta(days=dia_semana)
            ultimo_dia_semana = primer_dia_semana + timedelta(days=6)
            
            # Obtener resumen de ventas
            resumen_ventas = self.obtener_resumen_ventas_por_periodo(
                primer_dia_semana.strftime('%Y-%m-%d'),
                ultimo_dia_semana.strftime('%Y-%m-%d')
            )
            
            # Obtener ventas por día de la semana
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query_por_dia = """
                SELECT 
                    DATEPART(weekday, fecha_venta) AS dia_semana,
                    COUNT(*) AS total_ventas,
                    SUM(total) AS monto_total
                FROM Ventas
                WHERE fecha_venta BETWEEN ? AND ?
                GROUP BY DATEPART(weekday, fecha_venta)
                ORDER BY dia_semana
                """
                
                cursor.execute(query_por_dia, (primer_dia_semana, ultimo_dia_semana))
                dias_semana = []
                
                # Inicializar días de la semana (1 = Domingo, ..., 7 = Sábado en SQL Server)
                dias_nombres = {
                    1: 'Domingo',
                    2: 'Lunes',
                    3: 'Martes',
                    4: 'Miércoles',
                    5: 'Jueves',
                    6: 'Viernes',
                    7: 'Sábado'
                }
                
                for row in cursor.fetchall():
                    dia = {
                        'dia_semana': row.dia_semana,
                        'nombre_dia': dias_nombres.get(row.dia_semana, f"Día {row.dia_semana}"),
                        'total_ventas': row.total_ventas,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0
                    }
                    dias_semana.append(dia)
            
            # Agregar información por día al resumen
            if resumen_ventas:
                resumen_ventas['por_dia'] = dias_semana
            
            return resumen_ventas
        except Exception as e:
            logger.error(f"Error al obtener reporte semanal: {str(e)}")
            return None
    @cacheable('reportes', key_func=lambda anio: f"anual_{anio or 'actual'}", ttl=1800)
    def obtener_reporte_anual(self, año=None):
        """
        Obtiene un reporte anual de ventas.
        
        Args:
            año (int): Año para el reporte. Si es None, se usa el año actual.
            
        Returns:
            dict: Diccionario con el reporte anual.
        """
        try:
            # Determinar el año
            if año is None:
                año = datetime.now().year
            
            # Establecer fecha inicio y fin
            fecha_inicio = datetime(año, 1, 1).date()
            fecha_fin = datetime(año, 12, 31).date()
            
            # Obtener resumen de ventas
            resumen_ventas = self.obtener_resumen_ventas_por_periodo(
                fecha_inicio.strftime('%Y-%m-%d'),
                fecha_fin.strftime('%Y-%m-%d')
            )
            
            # Obtener ventas por mes
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query_por_mes = """
                SELECT 
                    MONTH(fecha_venta) AS mes,
                    COUNT(*) AS total_ventas,
                    SUM(total) AS monto_total
                FROM Ventas
                WHERE YEAR(fecha_venta) = ?
                GROUP BY MONTH(fecha_venta)
                ORDER BY mes
                """
                
                cursor.execute(query_por_mes, (año,))
                meses = []
                
                # Nombres de los meses
                nombres_meses = {
                    1: 'Enero', 2: 'Febrero', 3: 'Marzo', 4: 'Abril',
                    5: 'Mayo', 6: 'Junio', 7: 'Julio', 8: 'Agosto',
                    9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre', 12: 'Diciembre'
                }
                
                for row in cursor.fetchall():
                    mes = {
                        'numero_mes': row.mes,
                        'nombre_mes': nombres_meses.get(row.mes, f"Mes {row.mes}"),
                        'total_ventas': row.total_ventas,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0
                    }
                    meses.append(mes)
            
            # Agregar información por mes al resumen
            if resumen_ventas:
                resumen_ventas['año'] = año
                resumen_ventas['por_mes'] = meses
            
            return resumen_ventas
        except Exception as e:
            logger.error(f"Error al obtener reporte anual: {str(e)}")
            return None
    @cacheable('pagos_pendientes', ttl=300)  # 5 minutos - datos dinámicos
    def obtener_pagos_pendientes(self):
        """
        Obtiene un resumen de los pagos pendientes.
        
        Returns:
            list: Lista de diccionarios con información de ventas con pagos pendientes.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, 
                    c.id_cliente, c.nombre AS cliente_nombre,
                    v.total, v.estado_pago, v.condiciones_pago
                FROM Ventas v
                JOIN Clientes c ON v.id_cliente = c.id_cliente
                WHERE v.estado_pago IN ('Pendiente', 'Parcial')
                ORDER BY v.fecha_venta
                """
                
                cursor.execute(query)
                pagos_pendientes = []
                
                for row in cursor.fetchall():
                    # Manejar fecha de manera segura
                    if hasattr(row.fecha_venta, 'strftime'):
                        fecha_venta = row.fecha_venta.strftime('%Y-%m-%d')
                    else:
                        fecha_venta = str(row.fecha_venta) if row.fecha_venta else None
                    
                    pago = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'total': float(row.total),
                        'estado_pago': row.estado_pago,
                        'condiciones_pago': row.condiciones_pago
                    }
                    pagos_pendientes.append(pago)
                
                logger.info(f"Se obtuvieron {len(pagos_pendientes)} pagos pendientes.")
                return pagos_pendientes
        except Exception as e:
            logger.error(f"Error al obtener pagos pendientes: {str(e)}")
            return []
    @cacheable('ventas_vencidas', ttl=300)  # 5 minutos - datos dinámicos   
    def obtener_ventas_vencidas(self):
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                hoy = datetime.now().date()
                hoy_str = hoy.strftime('%Y-%m-%d')
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.fecha_entrega,
                    c.id_cliente, c.nombre AS cliente_nombre,
                    v.total, v.estado_pago, e.nombre AS estado_nombre
                FROM Ventas v
                JOIN Clientes c ON v.id_cliente = c.id_cliente
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                WHERE CONVERT(DATE, v.fecha_entrega) < CONVERT(DATE, ?) 
                    AND v.id_estado NOT IN (
                        SELECT id_estado FROM EstadosVenta WHERE nombre IN ('Entregado', 'Finalizado', 'Cancelado')
                    )
                ORDER BY v.fecha_entrega
                """
                
                try:
                    cursor.execute(query, (hoy_str,))
                    ventas_vencidas = []
                    
                    for row in cursor.fetchall():
                        # Formatear fechas como strings de manera segura
                        if hasattr(row.fecha_venta, 'strftime'):
                            fecha_venta = row.fecha_venta.strftime('%Y-%m-%d')
                        else:
                            fecha_venta = str(row.fecha_venta) if row.fecha_venta else None
                        
                        if hasattr(row.fecha_entrega, 'strftime'):
                            fecha_entrega = row.fecha_entrega.strftime('%Y-%m-%d')
                        else:
                            fecha_entrega = str(row.fecha_entrega) if row.fecha_entrega else None
                        
                        venta = {
                            'id_venta': row.id_venta,
                            'codigo_venta': row.codigo_venta,
                            'fecha_venta': fecha_venta,
                            'fecha_entrega': fecha_entrega,
                            'id_cliente': row.id_cliente,
                            'cliente_nombre': row.cliente_nombre,
                            'total': float(row.total),
                            'estado_pago': row.estado_pago,
                            'estado_nombre': row.estado_nombre
                        }
                        ventas_vencidas.append(venta)
                    
                    logger.info(f"Se obtuvieron {len(ventas_vencidas)} ventas vencidas.")
                    return ventas_vencidas
                except Exception as e:
                    # Si hay un error con esta consulta específica, intentemos una versión simplificada
                    logger.warning(f"Error en consulta principal de ventas vencidas. Probando alternativa: {str(e)}")
                    
                    # Consulta alternativa sin filtro de estados
                    alt_query = """
                    SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.fecha_entrega,
                        c.id_cliente, c.nombre AS cliente_nombre,
                        v.total, v.estado_pago, e.nombre AS estado_nombre
                    FROM Ventas v
                    JOIN Clientes c ON v.id_cliente = c.id_cliente
                    JOIN EstadosVenta e ON v.id_estado = e.id_estado
                    WHERE v.fecha_entrega < ?
                    ORDER BY v.fecha_entrega
                    """
                    
                    cursor.execute(alt_query, (hoy_str,))
                    ventas_vencidas = []
                    
                    for row in cursor.fetchall():
                        # Formatear fechas como strings (mismo código que arriba)
                        if hasattr(row.fecha_venta, 'strftime'):
                            fecha_venta = row.fecha_venta.strftime('%Y-%m-%d')
                        else:
                            fecha_venta = str(row.fecha_venta) if row.fecha_venta else None
                        
                        if hasattr(row.fecha_entrega, 'strftime'):
                            fecha_entrega = row.fecha_entrega.strftime('%Y-%m-%d')
                        else:
                            fecha_entrega = str(row.fecha_entrega) if row.fecha_entrega else None
                        
                        venta = {
                            'id_venta': row.id_venta,
                            'codigo_venta': row.codigo_venta,
                            'fecha_venta': fecha_venta,
                            'fecha_entrega': fecha_entrega,
                            'id_cliente': row.id_cliente,
                            'cliente_nombre': row.cliente_nombre,
                            'total': float(row.total),
                            'estado_pago': row.estado_pago,
                            'estado_nombre': row.estado_nombre
                        }
                        ventas_vencidas.append(venta)
                    
                    logger.info(f"Se obtuvieron {len(ventas_vencidas)} ventas vencidas (consulta alternativa).")
                    return ventas_vencidas
                    
        except Exception as e:
            logger.error(f"Error al obtener ventas vencidas: {str(e)}")
            return []
    @cacheable('ventas', key_func=lambda id_cli: f"cliente_{id_cli}")
    def obtener_ventas_por_cliente(self, id_cliente):
        """
        Obtiene todas las ventas realizadas a un cliente específico.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            list: Lista de diccionarios con las ventas del cliente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.subtotal, 
                       v.total, v.estado_pago, e.nombre AS estado_nombre
                FROM Ventas v
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                WHERE v.id_cliente = ?
                ORDER BY v.fecha_venta DESC
                """
                
                cursor.execute(query, (id_cliente,))
                ventas = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'subtotal': float(row.subtotal),
                        'total': float(row.total),
                        'estado_pago': row.estado_pago,
                        'estado_nombre': row.estado_nombre
                    }
                    ventas.append(venta)
                
                logger.info(f"Se obtuvieron {len(ventas)} ventas para el cliente ID: {id_cliente}")
                return ventas
        except Exception as e:
            logger.error(f"Error al obtener ventas por cliente: {str(e)}")
            return []
    @cacheable('estadisticas', key_func=lambda id_venta: f"stats_{id_venta}", ttl=1800)
    def calcular_estadisticas_venta(self, id_venta):
        """
        Calcula estadísticas básicas para una venta específica.
        
        Args:
            id_venta (int): ID de la venta para calcular estadísticas.
            
        Returns:
            dict: Diccionario con estadísticas de la venta.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Consulta para obtener información básica de la venta
                query_venta = """
                SELECT v.fecha_venta, v.fecha_entrega, v.subtotal, v.total,
                       c.nombre AS cliente, e.nombre AS estado, v.estado_pago
                FROM Ventas v
                JOIN Clientes c ON v.id_cliente = c.id_cliente
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                WHERE v.id_venta = ?
                """
                
                cursor.execute(query_venta, (id_venta,))
                row_venta = cursor.fetchone()
                
                if not row_venta:
                    return {}
                
                # Consulta para obtener estadísticas de los detalles
                query_detalles = """
                SELECT COUNT(*) AS total_productos,
                       SUM(cantidad) AS total_unidades,
                       AVG(precio_unitario) AS precio_promedio,
                       MAX(precio_unitario) AS precio_maximo,
                       MIN(precio_unitario) AS precio_minimo
                FROM DetallesVenta
                WHERE id_venta = ?
                """
                
                cursor.execute(query_detalles, (id_venta,))
                row_detalles = cursor.fetchone()
                
                # Calcular días entre fecha de venta y entrega
                dias_entrega = None
                if row_venta.fecha_entrega and row_venta.fecha_venta:
                    dias_entrega = (row_venta.fecha_entrega - row_venta.fecha_venta).days
                
                # Armar el objeto de estadísticas
                estadisticas = {
                    'cliente': row_venta.cliente,
                    'fecha_venta': row_venta.fecha_venta.strftime('%Y-%m-%d') if row_venta.fecha_venta else None,
                    'fecha_entrega': row_venta.fecha_entrega.strftime('%Y-%m-%d') if row_venta.fecha_entrega else None,
                    'dias_entrega': dias_entrega,
                    'subtotal': float(row_venta.subtotal),
                    'total': float(row_venta.total),
                    'estado': row_venta.estado,
                    'estado_pago': row_venta.estado_pago,
                    'total_productos': row_detalles.total_productos,
                    'total_unidades': float(row_detalles.total_unidades) if row_detalles.total_unidades else 0,
                    'precio_promedio': float(row_detalles.precio_promedio) if row_detalles.precio_promedio else 0,
                    'precio_maximo': float(row_detalles.precio_maximo) if row_detalles.precio_maximo else 0,
                    'precio_minimo': float(row_detalles.precio_minimo) if row_detalles.precio_minimo else 0
                }
                
                return estadisticas
        except Exception as e:
            logger.error(f"Error al calcular estadísticas de venta: {str(e)}")
            return {}
    @cacheable('cliente_top', ttl=900)  # 15 minutos
    def obtener_cliente_top(self):
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Obtener el primer día del mes actual
                hoy = datetime.now().date()
                primer_dia_mes = datetime(hoy.year, hoy.month, 1).date()
                primer_dia_mes_str = primer_dia_mes.strftime('%Y-%m-%d')
                
                query = """
                SELECT TOP 1 c.id_cliente, c.nombre, COUNT(v.id_venta) AS total_ventas, 
                    SUM(v.total) AS monto_total,
                    (SELECT SUM(total) FROM Ventas 
                        WHERE fecha_venta >= ?) AS total_ventas_mes
                FROM Ventas v
                JOIN Clientes c ON v.id_cliente = c.id_cliente
                WHERE v.fecha_venta >= ?
                GROUP BY c.id_cliente, c.nombre
                ORDER BY monto_total DESC
                """
                
                cursor.execute(query, (primer_dia_mes_str, primer_dia_mes_str))
                row = cursor.fetchone()
                
                if row and row.monto_total:
                    # Calcular el porcentaje del total de ventas
                    porcentaje = (float(row.monto_total) / float(row.total_ventas_mes)) * 100 if row.total_ventas_mes else 0
                    
                    cliente_top = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'total_ventas': row.total_ventas,
                        'monto_total': float(row.monto_total),
                        'porcentaje_ventas': round(porcentaje, 2)
                    }
                    return cliente_top
                return None
        except Exception as e:
            logger.error(f"Error al obtener cliente top: {str(e)}")
            return None
        
    @cacheable('estadisticas_ventas', ttl=900)  # 15 minutos
    def obtener_estadisticas_ventas(self):
        """
        Obtiene estadísticas generales de ventas.
        
        Returns:
            dict: Diccionario con estadísticas generales.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Estadísticas básicas
                query_basicas = """
                SELECT 
                    COUNT(*) as total_ventas,
                    SUM(total) as monto_total,
                    AVG(total) as promedio_venta,
                    COUNT(DISTINCT id_cliente) as clientes_unicos,
                    SUM(CASE WHEN estado_pago = 'Pagado' THEN total ELSE 0 END) as total_pagado,
                    SUM(CASE WHEN estado_pago = 'Pendiente' THEN total ELSE 0 END) as total_pendiente,
                    SUM(CASE WHEN estado_pago = 'Parcial' THEN total ELSE 0 END) as total_parcial
                FROM Ventas
                WHERE YEAR(fecha_venta) = YEAR(GETDATE())
                """
                
                cursor.execute(query_basicas)
                row_basicas = cursor.fetchone()
                
                # Estadísticas por mes del año actual
                query_por_mes = """
                SELECT 
                    MONTH(fecha_venta) as mes,
                    COUNT(*) as cantidad_ventas,
                    SUM(total) as monto_mes
                FROM Ventas
                WHERE YEAR(fecha_venta) = YEAR(GETDATE())
                GROUP BY MONTH(fecha_venta)
                ORDER BY mes
                """
                
                cursor.execute(query_por_mes)
                ventas_por_mes = cursor.fetchall()
                
                # Estadísticas por estado de venta
                query_estados = """
                SELECT 
                    e.nombre as estado,
                    COUNT(v.id_venta) as cantidad,
                    SUM(v.total) as monto
                FROM Ventas v
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                WHERE YEAR(v.fecha_venta) = YEAR(GETDATE())
                GROUP BY e.nombre
                ORDER BY cantidad DESC
                """
                
                cursor.execute(query_estados)
                ventas_por_estado = cursor.fetchall()
                
                # Preparar resultado
                estadisticas = {
                    'resumen_general': {
                        'total_ventas': row_basicas.total_ventas or 0,
                        'monto_total': float(row_basicas.monto_total) if row_basicas.monto_total else 0.0,
                        'promedio_venta': float(row_basicas.promedio_venta) if row_basicas.promedio_venta else 0.0,
                        'clientes_unicos': row_basicas.clientes_unicos or 0,
                        'total_pagado': float(row_basicas.total_pagado) if row_basicas.total_pagado else 0.0,
                        'total_pendiente': float(row_basicas.total_pendiente) if row_basicas.total_pendiente else 0.0,
                        'total_parcial': float(row_basicas.total_parcial) if row_basicas.total_parcial else 0.0
                    },
                    'por_mes': [
                        {
                            'mes': row.mes,
                            'nombre_mes': self._obtener_nombre_mes(row.mes),
                            'cantidad_ventas': row.cantidad_ventas,
                            'monto_mes': float(row.monto_mes) if row.monto_mes else 0.0
                        }
                        for row in ventas_por_mes
                    ],
                    'por_estado': [
                        {
                            'estado': row.estado,
                            'cantidad': row.cantidad,
                            'monto': float(row.monto) if row.monto else 0.0
                        }
                        for row in ventas_por_estado
                    ]
                }
                
                logger.info("Estadísticas de ventas generadas exitosamente")
                return estadisticas
                
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de ventas: {str(e)}")
            return {}

    @cacheable('ventas_por_mes', key_func=lambda anio: f"mes_{anio}", ttl=1800)  # 30 minutos
    def obtener_ventas_por_mes(self, anio):
        """
        Obtiene ventas agrupadas por mes para un año específico.
        
        Args:
            anio (int): Año para obtener las ventas.
            
        Returns:
            list: Lista de ventas agrupadas por mes.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT 
                    MONTH(fecha_venta) as mes,
                    COUNT(*) as total_ventas,
                    SUM(total) as monto_total,
                    AVG(total) as promedio_venta,
                    COUNT(DISTINCT id_cliente) as clientes_distintos
                FROM Ventas
                WHERE YEAR(fecha_venta) = ?
                GROUP BY MONTH(fecha_venta)
                ORDER BY mes
                """
                
                cursor.execute(query, (anio,))
                ventas_mes = []
                
                # Nombres de meses
                nombres_meses = {
                    1: 'Enero', 2: 'Febrero', 3: 'Marzo', 4: 'Abril',
                    5: 'Mayo', 6: 'Junio', 7: 'Julio', 8: 'Agosto',
                    9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre', 12: 'Diciembre'
                }
                
                for row in cursor.fetchall():
                    mes_data = {
                        'mes': row.mes,
                        'nombre_mes': nombres_meses.get(row.mes, f"Mes {row.mes}"),
                        'total_ventas': row.total_ventas,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0,
                        'promedio_venta': float(row.promedio_venta) if row.promedio_venta else 0.0,
                        'clientes_distintos': row.clientes_distintos
                    }
                    ventas_mes.append(mes_data)
                
                logger.info(f"Ventas por mes obtenidas para el año {anio}: {len(ventas_mes)} meses")
                return ventas_mes
                
        except Exception as e:
            logger.error(f"Error al obtener ventas por mes: {str(e)}")
            return []

    @cacheable('productos_mas_vendidos', ttl=1800)  # 30 minutos
    def obtener_productos_mas_vendidos(self):
        """
        Obtiene los productos más vendidos basado en las variedades.
        
        Returns:
            list: Lista de productos más vendidos.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT TOP 10
                    v.id_variedad,
                    tc.nombre as tipo_cultivo,
                    vc.nombre as variedad,
                    COUNT(dv.id_detalle_venta) as veces_vendido,
                    SUM(dv.cantidad) as cantidad_total,
                    SUM(dv.total) as monto_total,
                    AVG(dv.precio_unitario) as precio_promedio
                FROM DetallesVenta dv
                JOIN Ventas v ON dv.id_venta = v.id_venta
                JOIN VariedadesCultivo vc ON dv.id_variedad = vc.id_variedad
                JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
                WHERE YEAR(v.fecha_venta) = YEAR(GETDATE())
                GROUP BY v.id_variedad, tc.nombre, vc.nombre
                ORDER BY cantidad_total DESC, monto_total DESC
                """
                
                cursor.execute(query)
                productos = []
                
                for row in cursor.fetchall():
                    producto = {
                        'id_variedad': row.id_variedad,
                        'tipo_cultivo': row.tipo_cultivo,
                        'variedad': row.variedad,
                        'producto_completo': f"{row.tipo_cultivo} - {row.variedad}",
                        'veces_vendido': row.veces_vendido,
                        'cantidad_total': float(row.cantidad_total) if row.cantidad_total else 0.0,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0,
                        'precio_promedio': float(row.precio_promedio) if row.precio_promedio else 0.0
                    }
                    productos.append(producto)
                
                logger.info(f"Productos más vendidos obtenidos: {len(productos)}")
                return productos
                
        except Exception as e:
            logger.error(f"Error al obtener productos más vendidos: {str(e)}")
            return []

    @cacheable('clientes_top_completo', ttl=900)  # 15 minutos
    def obtener_clientes_top_completo(self):
        """
        Obtiene la lista completa de mejores clientes ordenados por volumen.
        
        Returns:
            list: Lista completa de mejores clientes.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT TOP 20
                    c.id_cliente,
                    c.nombre,
                    c.telefono,
                    c.email,
                    COUNT(v.id_venta) as total_ventas,
                    SUM(v.total) as monto_total,
                    AVG(v.total) as promedio_compra,
                    MAX(v.fecha_venta) as ultima_compra,
                    MIN(v.fecha_venta) as primera_compra
                FROM Clientes c
                JOIN Ventas v ON c.id_cliente = v.id_cliente
                WHERE c.activo = 1 AND YEAR(v.fecha_venta) = YEAR(GETDATE())
                GROUP BY c.id_cliente, c.nombre, c.telefono, c.email
                ORDER BY monto_total DESC, total_ventas DESC
                """
                
                cursor.execute(query)
                clientes_top = []
                
                for row in cursor.fetchall():
                    # Formatear fechas
                    ultima_compra = row.ultima_compra.strftime('%Y-%m-%d') if row.ultima_compra else None
                    primera_compra = row.primera_compra.strftime('%Y-%m-%d') if row.primera_compra else None
                    
                    # Calcular fidelidad (meses como cliente activo)
                    fidelidad_meses = 0
                    if row.primera_compra and row.ultima_compra:
                        delta = row.ultima_compra - row.primera_compra
                        fidelidad_meses = max(1, delta.days // 30)
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'telefono': row.telefono or '',
                        'email': row.email or '',
                        'total_ventas': row.total_ventas,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0,
                        'promedio_compra': float(row.promedio_compra) if row.promedio_compra else 0.0,
                        'ultima_compra': ultima_compra,
                        'primera_compra': primera_compra,
                        'fidelidad_meses': fidelidad_meses,
                        'categoria': self._clasificar_cliente_por_monto(float(row.monto_total) if row.monto_total else 0.0)
                    }
                    clientes_top.append(cliente)
                
                logger.info(f"Clientes top completo obtenido: {len(clientes_top)} clientes")
                return clientes_top
                
        except Exception as e:
            logger.error(f"Error al obtener clientes top completo: {str(e)}")
            return []

    # ==================== MÉTODOS UTILITARIOS ====================
    
    def get_estados_venta_json(self):
        """Obtiene los estados de venta disponibles en formato JSON."""
        try:
            estados = self.obtener_estados_venta()
            return json.dumps(estados)
        except Exception as e:
            logger.error(f"Error al obtener estados de venta en JSON: {str(e)}")
            return "[]"
    
    def generar_codigo_venta(self):
        """
        Genera un código único para una nueva venta con formato V-XXXX.
        
        Returns:
            str: Código generado para la venta.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Consultar el último código
                query = """
                SELECT TOP 1 codigo_venta 
                FROM Ventas 
                WHERE codigo_venta LIKE 'V-%'
                ORDER BY id_venta DESC
                """
                
                cursor.execute(query)
                row = cursor.fetchone()
                
                if row:
                    # Extraer el número del último código
                    ultimo_codigo = row.codigo_venta
                    
                    # Intentar extraer el número después del "V-"
                    try:
                        numero_str = ultimo_codigo.replace("V-", "")
                        # Si tiene guiones adicionales (como en V-2023-001), tomar la última parte
                        if "-" in numero_str:
                            numero_str = numero_str.split("-")[-1]
                        numero = int(numero_str)
                        nuevo_numero = numero + 1
                    except (ValueError, IndexError):
                        # Si hay algún problema al extraer el número, comenzar desde 1
                        nuevo_numero = 1
                else:
                    nuevo_numero = 1
                
                # Generar el nuevo código con formato simple V-XXXX
                nuevo_codigo = f"V-{nuevo_numero:04d}"
                
                return nuevo_codigo
        except Exception as e:
            logger.error(f"Error al generar código de venta: {str(e)}")
            # Generar un código alternativo si hay error
            return f"V-{1:04d}"
    @cacheable('productos_venta', key_func=lambda id_venta: f"productos_{id_venta}")
    def obtener_productos_venta(self, id_venta):
        """
        Obtiene los productos de una venta específica.
        
        Args:
            id_venta (int): ID de la venta para obtener sus productos.
            
        Returns:
            list: Lista de diccionarios con la información de los productos.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT dv.id_detalle_venta, dv.id_variedad, tc.nombre AS tipo_cultivo, 
                    vc.nombre AS variedad,
                    dv.cantidad, dv.unidad_medida, dv.precio_unitario, 
                    dv.subtotal, dv.total
                FROM DetallesVenta dv
                JOIN VariedadesCultivo vc ON dv.id_variedad = vc.id_variedad
                JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
                WHERE dv.id_venta = ?
                ORDER BY dv.id_detalle_venta
                """
                
                cursor.execute(query, (id_venta,))
                productos = []
                
                for row in cursor.fetchall():
                    producto = {
                        'id_detalle': row.id_detalle_venta,
                        'nombre': f"{row.tipo_cultivo} - {row.variedad}",
                        'cantidad': float(row.cantidad),
                        'unidad': row.unidad_medida,
                        'precio_unitario': float(row.precio_unitario),
                        'subtotal': float(row.subtotal)
                    }
                    productos.append(producto)
                
                logger.info(f"Se obtuvieron {len(productos)} productos para la venta ID: {id_venta}")
                return productos
        except Exception as e:
            logger.error(f"Error al obtener productos de venta: {str(e)}")
            return []
        
    # Metodos AUXILIARES
    def _obtener_nombre_mes(self, numero_mes):
        """
        Obtiene el nombre de un mes a partir de su número.
        
        Args:
            numero_mes (int): Número del mes (1-12).
            
        Returns:
            str: Nombre del mes.
        """
        nombres_meses = {
            1: 'Enero', 2: 'Febrero', 3: 'Marzo', 4: 'Abril',
            5: 'Mayo', 6: 'Junio', 7: 'Julio', 8: 'Agosto',
            9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre', 12: 'Diciembre'
        }
        return nombres_meses.get(numero_mes, f"Mes {numero_mes}")

    def _clasificar_cliente_por_monto(self, monto_total):
        """
        Clasifica un cliente según su monto total de compras.
        
        Args:
            monto_total (float): Monto total de compras del cliente.
            
        Returns:
            str: Categoría del cliente.
        """
        if monto_total >= 100000:
            return 'Premium'
        elif monto_total >= 50000:
            return 'Gold'
        elif monto_total >= 20000:
            return 'Silver'
        elif monto_total >= 5000:
            return 'Regular'
        else:
            return 'Nuevo'


# Ejemplo de uso
if __name__ == "__main__":
    # Prueba la conexión y consulta
    try:
        gestor = GestorVentas()
        ventas = gestor.obtener_ventas()
        print(f"Total de ventas: {len(ventas)}")
        
    except Exception as e:
        print(f"Error al ejecutar el ejemplo: {str(e)}")