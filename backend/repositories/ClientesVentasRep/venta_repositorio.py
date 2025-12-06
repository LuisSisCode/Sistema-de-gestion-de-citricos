"""
Repositorio de Ventas - CORREGIDO
Capa de acceso a datos - Solo queries SQL
Sin lógica de negocio, sin cálculos complejos
"""

import logging
from datetime import datetime, date
from typing import List, Dict, Optional, Tuple
from backend.core.database import DatabaseConnection

# Configurar logging
logger = logging.getLogger('venta_repositorio')


def safe_date_format(date_value) -> Optional[str]:
    """
    Formatea una fecha de forma segura, manejando diferentes tipos.
    """
    if date_value is None:
        return None
    
    # Si ya es string, retornar directamente
    if isinstance(date_value, str):
        return date_value
    
    # Si tiene el método strftime (datetime, date), usarlo
    if hasattr(date_value, 'strftime'):
        return date_value.strftime('%Y-%m-%d')
    
    # Intentar convertir a string como último recurso
    return str(date_value)


class VentaRepositorio:
    """
    Repositorio para acceso a datos de ventas.
    Responsabilidad: Solo ejecutar queries SQL, sin lógica de negocio.
    """
    
    def __init__(self):
        """Inicializa la conexión a la base de datos."""
        try:
            self.db = DatabaseConnection()
            logger.info("✅ VentaRepositorio inicializado correctamente.")
        except Exception as e:
            logger.error(f"❌ Error al inicializar VentaRepositorio: {str(e)}")
            raise

    def test_connection(self):
        """Prueba la conexión a la base de datos."""
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT 1")
                logger.info("✅ Conexión a BD verificada")
                return True
        except Exception as e:
            logger.error(f"❌ Error al probar la conexión: {str(e)}")
            raise

    # ==================== CRUD BÁSICO DE VENTAS ====================
    
    def obtener_todas(self) -> List[Dict]:
        """
        Obtiene todas las ventas.
        
        Returns:
            List[Dict]: Lista de ventas.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.id_cliente,
                       c.nombre AS cliente_nombre, v.subtotal, v.total,
                       v.fecha_entrega, v.estado_pago, v.registrado_por,
                       u.nombre AS registrado_por_nombre, v.observaciones
                FROM Ventas v
                LEFT JOIN Clientes c ON v.id_cliente = c.id_cliente
                LEFT JOIN Usuarios u ON v.registrado_por = u.id_usuario
                ORDER BY v.fecha_venta DESC, v.id_venta DESC
                """
                
                cursor.execute(query)
                ventas = []
                
                for row in cursor.fetchall():
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': safe_date_format(row.fecha_venta),
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'fecha_entrega': safe_date_format(row.fecha_entrega),
                        'estado_pago': row.estado_pago,
                        'registrado_por': row.registrado_por,
                        'registrado_por_nombre': row.registrado_por_nombre,
                        'observaciones': row.observaciones
                    }
                    ventas.append(venta)
                
                logger.info(f"📊 Se obtuvieron {len(ventas)} ventas")
                return ventas
                
        except Exception as e:
            logger.error(f"❌ Error al obtener ventas: {str(e)}")
            return []
    
    def obtener_por_id(self, id_venta: int) -> Optional[Dict]:
        """
        Obtiene una venta específica por su ID.
        
        Args:
            id_venta: ID de la venta a obtener.
            
        Returns:
            Dict con la información de la venta o None si no se encuentra.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.id_cliente,
                       c.nombre AS cliente_nombre, c.telefono AS cliente_telefono,
                       v.subtotal, v.total, v.fecha_entrega, v.estado_pago,
                       v.registrado_por, u.nombre AS registrado_por_nombre,
                       v.observaciones
                FROM Ventas v
                LEFT JOIN Clientes c ON v.id_cliente = c.id_cliente
                LEFT JOIN Usuarios u ON v.registrado_por = u.id_usuario
                WHERE v.id_venta = ?
                """
                
                cursor.execute(query, (id_venta,))
                row = cursor.fetchone()
                
                if row:
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': safe_date_format(row.fecha_venta),
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'cliente_telefono': row.cliente_telefono,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'fecha_entrega': safe_date_format(row.fecha_entrega),
                        'estado_pago': row.estado_pago,
                        'registrado_por': row.registrado_por,
                        'registrado_por_nombre': row.registrado_por_nombre,
                        'observaciones': row.observaciones
                    }
                    
                    logger.info(f"✅ Venta {id_venta} encontrada")
                    return venta
                
                logger.warning(f"⚠️ Venta {id_venta} no encontrada")
                return None
                
        except Exception as e:
            logger.error(f"❌ Error al obtener venta {id_venta}: {str(e)}")
            return None
    
    def crear(self, venta_data: Dict, registrado_por: int) -> Tuple[bool, Optional[int]]:
        """
        Crea una nueva venta en la base de datos.
        
        Args:
            venta_data: Diccionario con los datos de la venta.
            registrado_por: ID del usuario que registra la venta.
            
        Returns:
            Tuple[bool, Optional[int]]: (Éxito, ID de la nueva venta)
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Ventas (codigo_venta, fecha_venta, id_cliente, subtotal,
                                   total, fecha_entrega, estado_pago, registrado_por, observaciones)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    venta_data['codigo_venta'],
                    venta_data['fecha_venta'],
                    venta_data['id_cliente'],
                    venta_data.get('subtotal', 0),
                    venta_data.get('total', 0),
                    venta_data.get('fecha_entrega'),
                    venta_data.get('estado_pago', 'Pendiente'),
                    registrado_por,
                    venta_data.get('observaciones')
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_venta = int(cursor.fetchone()[0])
                
                logger.info(f"✅ Venta creada con ID: {id_venta}")
                return True, id_venta
                
        except Exception as e:
            logger.error(f"❌ Error al crear venta: {str(e)}")
            return False, None
    
    def actualizar(self, id_venta: int, venta_data: Dict) -> bool:
        """
        Actualiza una venta existente.
        
        Args:
            id_venta: ID de la venta a actualizar.
            venta_data: Diccionario con los datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                UPDATE Ventas 
                SET fecha_venta = ?,
                    id_cliente = ?,
                    subtotal = ?,
                    total = ?,
                    fecha_entrega = ?,
                    estado_pago = ?,
                    observaciones = ?
                WHERE id_venta = ?
                """
                
                valores = (
                    venta_data['fecha_venta'],
                    venta_data['id_cliente'],
                    venta_data.get('subtotal', 0),
                    venta_data.get('total', 0),
                    venta_data.get('fecha_entrega'),
                    venta_data.get('estado_pago'),
                    venta_data.get('observaciones'),
                    id_venta
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                if cursor.rowcount > 0:
                    logger.info(f"✅ Venta {id_venta} actualizada")
                    return True
                else:
                    logger.warning(f"⚠️ Venta {id_venta} no encontrada para actualizar")
                    return False
                    
        except Exception as e:
            logger.error(f"❌ Error al actualizar venta: {str(e)}")
            return False
    
    def eliminar(self, id_venta: int) -> bool:
        """
        Elimina una venta.
        
        Args:
            id_venta: ID de la venta a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM Ventas WHERE id_venta = ?"
                cursor.execute(query, (id_venta,))
                conn.commit()
                
                if cursor.rowcount > 0:
                    logger.info(f"✅ Venta {id_venta} eliminada")
                    return True
                else:
                    logger.warning(f"⚠️ Venta {id_venta} no encontrada para eliminar")
                    return False
                    
        except Exception as e:
            logger.error(f"❌ Error al eliminar venta: {str(e)}")
            return False
    
    # ==================== GESTIÓN DE DETALLES ====================
    
    def obtener_detalles_venta(self, id_venta: int) -> List[Dict]:
        """
        Obtiene los detalles de una venta.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            List[Dict]: Lista de detalles.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT dv.id_detalle_venta, dv.id_venta, dv.producto,
                       dv.cantidad, dv.precio_unitario, dv.subtotal
                FROM Detalles_Venta dv
                WHERE dv.id_venta = ?
                ORDER BY dv.id_detalle_venta
                """
                
                cursor.execute(query, (id_venta,))
                detalles = []
                
                for row in cursor.fetchall():
                    detalle = {
                        'id_detalle_venta': row.id_detalle_venta,
                        'id_venta': row.id_venta,
                        'producto': row.producto,
                        'cantidad': float(row.cantidad) if row.cantidad else 0.0,
                        'precio_unitario': float(row.precio_unitario) if row.precio_unitario else 0.0,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0
                    }
                    detalles.append(detalle)
                
                return detalles
                
        except Exception as e:
            logger.error(f"❌ Error al obtener detalles de venta: {str(e)}")
            return []
    
    def agregar_detalle(self, detalle_data: Dict) -> Tuple[bool, Optional[int]]:
        """
        Agrega un detalle a una venta.
        
        Args:
            detalle_data: Datos del detalle.
            
        Returns:
            Tuple[bool, Optional[int]]: (Éxito, ID del detalle)
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Detalles_Venta (id_venta, producto, cantidad, precio_unitario, subtotal)
                VALUES (?, ?, ?, ?, ?)
                """
                
                valores = (
                    detalle_data['id_venta'],
                    detalle_data['producto'],
                    detalle_data['cantidad'],
                    detalle_data['precio_unitario'],
                    detalle_data['subtotal']
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_detalle = int(cursor.fetchone()[0])
                
                return True, id_detalle
                
        except Exception as e:
            logger.error(f"❌ Error al agregar detalle: {str(e)}")
            return False, None
    
    def eliminar_detalle(self, id_detalle: int) -> bool:
        """
        Elimina un detalle de venta.
        
        Args:
            id_detalle: ID del detalle.
            
        Returns:
            bool: True si se eliminó.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                query = "DELETE FROM Detalles_Venta WHERE id_detalle_venta = ?"
                cursor.execute(query, (id_detalle,))
                conn.commit()
                return cursor.rowcount > 0
        except Exception as e:
            logger.error(f"❌ Error al eliminar detalle: {str(e)}")
            return False
    
    # ==================== BÚSQUEDAS ====================
    
    def buscar_por_criterio(self, criterio: str) -> List[Dict]:
        """
        Busca ventas por criterio.
        
        Args:
            criterio: Texto a buscar.
            
        Returns:
            List[Dict]: Ventas que coinciden.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.id_cliente,
                       c.nombre AS cliente_nombre, v.total, v.estado_pago
                FROM Ventas v
                LEFT JOIN Clientes c ON v.id_cliente = c.id_cliente
                WHERE v.codigo_venta LIKE ? OR c.nombre LIKE ?
                ORDER BY v.fecha_venta DESC
                """
                
                patron = f"%{criterio}%"
                cursor.execute(query, (patron, patron))
                
                ventas = []
                for row in cursor.fetchall():
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': safe_date_format(row.fecha_venta),
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'total': float(row.total) if row.total else 0.0,
                        'estado_pago': row.estado_pago
                    }
                    ventas.append(venta)
                
                return ventas
                
        except Exception as e:
            logger.error(f"❌ Error al buscar ventas: {str(e)}")
            return []
    
    def obtener_por_cliente(self, id_cliente: int) -> List[Dict]:
        """
        Obtiene ventas de un cliente.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            List[Dict]: Ventas del cliente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta,
                       v.subtotal, v.total, v.fecha_entrega, v.estado_pago
                FROM Ventas v
                WHERE v.id_cliente = ?
                ORDER BY v.fecha_venta DESC
                """
                
                cursor.execute(query, (id_cliente,))
                
                ventas = []
                for row in cursor.fetchall():
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': safe_date_format(row.fecha_venta),
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'fecha_entrega': safe_date_format(row.fecha_entrega),
                        'estado_pago': row.estado_pago
                    }
                    ventas.append(venta)
                
                return ventas
                
        except Exception as e:
            logger.error(f"❌ Error al obtener ventas del cliente: {str(e)}")
            return []
    
    def obtener_por_periodo(self, fecha_inicio: date, fecha_fin: date) -> List[Dict]:
        """
        Obtiene ventas en un período.
        
        Args:
            fecha_inicio: Fecha de inicio.
            fecha_fin: Fecha de fin.
            
        Returns:
            List[Dict]: Ventas del período.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.id_cliente,
                       c.nombre AS cliente_nombre, v.subtotal, v.total, v.estado_pago
                FROM Ventas v
                LEFT JOIN Clientes c ON v.id_cliente = c.id_cliente
                WHERE v.fecha_venta BETWEEN ? AND ?
                ORDER BY v.fecha_venta DESC
                """
                
                cursor.execute(query, (fecha_inicio, fecha_fin))
                
                ventas = []
                for row in cursor.fetchall():
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': safe_date_format(row.fecha_venta),
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'estado_pago': row.estado_pago
                    }
                    ventas.append(venta)
                
                return ventas
                
        except Exception as e:
            logger.error(f"❌ Error al obtener ventas por período: {str(e)}")
            return []
    
    def obtener_por_estado_pago(self, estado_pago: str) -> List[Dict]:
        """
        Obtiene ventas con un estado de pago específico.
        
        Args:
            estado_pago: Estado de pago.
            
        Returns:
            List[Dict]: Ventas con ese estado.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.id_cliente,
                       c.nombre AS cliente_nombre, v.total, v.estado_pago
                FROM Ventas v
                LEFT JOIN Clientes c ON v.id_cliente = c.id_cliente
                WHERE v.estado_pago = ?
                ORDER BY v.fecha_venta DESC
                """
                
                cursor.execute(query, (estado_pago,))
                
                ventas = []
                for row in cursor.fetchall():
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': safe_date_format(row.fecha_venta),
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'total': float(row.total) if row.total else 0.0,
                        'estado_pago': row.estado_pago
                    }
                    ventas.append(venta)
                
                return ventas
                
        except Exception as e:
            logger.error(f"❌ Error al obtener ventas por estado: {str(e)}")
            return []
    
    # ==================== UTILIDADES ====================
    
    def existe_venta(self, id_venta: int) -> bool:
        """
        Verifica si existe una venta.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            bool: True si existe.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT COUNT(*) FROM Ventas WHERE id_venta = ?", (id_venta,))
                return cursor.fetchone()[0] > 0
        except Exception as e:
            logger.error(f"❌ Error al verificar existencia: {str(e)}")
            return False
    
    def generar_codigo_venta(self) -> str:
        """
        Genera un código único para una nueva venta.
        
        Returns:
            str: Código generado.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT TOP 1 codigo_venta 
                FROM Ventas 
                WHERE codigo_venta LIKE 'V-%'
                ORDER BY id_venta DESC
                """
                
                cursor.execute(query)
                row = cursor.fetchone()
                
                if row:
                    ultimo_codigo = row.codigo_venta
                    try:
                        numero_str = ultimo_codigo.replace("V-", "")
                        if "-" in numero_str:
                            numero_str = numero_str.split("-")[-1]
                        numero = int(numero_str)
                        nuevo_numero = numero + 1
                    except (ValueError, IndexError):
                        nuevo_numero = 1
                else:
                    nuevo_numero = 1
                
                nuevo_codigo = f"V-{nuevo_numero:04d}"
                return nuevo_codigo
                
        except Exception as e:
            logger.error(f"❌ Error al generar código: {str(e)}")
            return "V-0001"