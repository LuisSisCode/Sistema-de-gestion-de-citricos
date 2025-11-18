"""
Repositorio de Ventas
Capa de acceso a datos - Solo queries SQL
Sin lógica de negocio, sin cálculos complejos
"""

import logging
from datetime import datetime, date
from typing import List, Dict, Optional, Tuple
from backend.core.database import DatabaseConnection

# Configurar logging
logger = logging.getLogger('venta_repositorio')


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
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    fecha_entrega = row.fecha_entrega.strftime('%Y-%m-%d') if row.fecha_entrega else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'fecha_entrega': fecha_entrega,
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
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    fecha_entrega = row.fecha_entrega.strftime('%Y-%m-%d') if row.fecha_entrega else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'cliente_telefono': row.cliente_telefono,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'fecha_entrega': fecha_entrega,
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
                
                # Obtener el ID de la venta recién insertada
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
            logger.error(f"❌ Error al actualizar venta {id_venta}: {str(e)}")
            return False
    
    def eliminar(self, id_venta: int) -> bool:
        """
        Elimina una venta (elimina físicamente en este caso ya que no hay campo activo).
        
        Args:
            id_venta: ID de la venta a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Primero eliminar detalles de venta
                cursor.execute("DELETE FROM DetallesVenta WHERE id_venta = ?", (id_venta,))
                
                # Luego eliminar la venta
                cursor.execute("DELETE FROM Ventas WHERE id_venta = ?", (id_venta,))
                conn.commit()
                
                if cursor.rowcount > 0:
                    logger.info(f"✅ Venta {id_venta} eliminada")
                    return True
                else:
                    logger.warning(f"⚠️ Venta {id_venta} no encontrada para eliminar")
                    return False
                    
        except Exception as e:
            logger.error(f"❌ Error al eliminar venta {id_venta}: {str(e)}")
            return False
    
    # ==================== DETALLES DE VENTA ====================
    
    def obtener_detalles_venta(self, id_venta: int) -> List[Dict]:
        """
        Obtiene los detalles de una venta específica.
        
        Args:
            id_venta: ID de la venta.
            
        Returns:
            List[Dict]: Lista de detalles de la venta.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT dv.id_detalle_venta, dv.id_venta, dv.id_lote,
                       dv.cantidad, dv.unidad_medida, dv.precio_unitario,
                       dv.subtotal, dv.observaciones
                FROM DetallesVenta dv
                WHERE dv.id_venta = ?
                ORDER BY dv.id_detalle_venta
                """
                
                cursor.execute(query, (id_venta,))
                detalles = []
                
                for row in cursor.fetchall():
                    detalle = {
                        'id_detalle_venta': row.id_detalle_venta,
                        'id_venta': row.id_venta,
                        'id_lote': row.id_lote,
                        'cantidad': float(row.cantidad) if row.cantidad else 0.0,
                        'unidad_medida': row.unidad_medida,
                        'precio_unitario': float(row.precio_unitario) if row.precio_unitario else 0.0,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'observaciones': row.observaciones
                    }
                    detalles.append(detalle)
                
                logger.info(f"📊 Se obtuvieron {len(detalles)} detalles de venta {id_venta}")
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
                INSERT INTO DetallesVenta (id_venta, id_lote, cantidad, unidad_medida,
                                          precio_unitario, subtotal, observaciones)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    detalle_data['id_venta'],
                    detalle_data.get('id_lote'),
                    detalle_data['cantidad'],
                    detalle_data['unidad_medida'],
                    detalle_data['precio_unitario'],
                    detalle_data['subtotal'],
                    detalle_data.get('observaciones')
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_detalle = int(cursor.fetchone()[0])
                
                logger.info(f"✅ Detalle agregado con ID: {id_detalle}")
                return True, id_detalle
                
        except Exception as e:
            logger.error(f"❌ Error al agregar detalle: {str(e)}")
            return False, None
    
    def actualizar_detalle(self, id_detalle: int, detalle_data: Dict) -> bool:
        """
        Actualiza un detalle de venta.
        
        Args:
            id_detalle: ID del detalle.
            detalle_data: Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                UPDATE DetallesVenta
                SET cantidad = ?,
                    unidad_medida = ?,
                    precio_unitario = ?,
                    subtotal = ?,
                    observaciones = ?
                WHERE id_detalle_venta = ?
                """
                
                valores = (
                    detalle_data['cantidad'],
                    detalle_data['unidad_medida'],
                    detalle_data['precio_unitario'],
                    detalle_data['subtotal'],
                    detalle_data.get('observaciones'),
                    id_detalle
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                return cursor.rowcount > 0
                
        except Exception as e:
            logger.error(f"❌ Error al actualizar detalle: {str(e)}")
            return False
    
    def eliminar_detalle(self, id_detalle: int) -> bool:
        """
        Elimina un detalle de venta.
        
        Args:
            id_detalle: ID del detalle.
            
        Returns:
            bool: True si se eliminó correctamente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM DetallesVenta WHERE id_detalle_venta = ?", (id_detalle,))
                conn.commit()
                return cursor.rowcount > 0
                
        except Exception as e:
            logger.error(f"❌ Error al eliminar detalle: {str(e)}")
            return False
    
    # ==================== BÚSQUEDAS Y FILTROS ====================
    
    def buscar_por_criterio(self, criterio: str) -> List[Dict]:
        """
        Busca ventas por código o nombre de cliente.
        
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
                       c.nombre AS cliente_nombre, v.subtotal, v.total,
                       v.fecha_entrega, v.estado_pago
                FROM Ventas v
                LEFT JOIN Clientes c ON v.id_cliente = c.id_cliente
                WHERE v.codigo_venta LIKE ? OR c.nombre LIKE ?
                ORDER BY v.fecha_venta DESC
                """
                
                param = f"%{criterio}%"
                cursor.execute(query, (param, param))
                
                ventas = []
                for row in cursor.fetchall():
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    fecha_entrega = row.fecha_entrega.strftime('%Y-%m-%d') if row.fecha_entrega else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'id_cliente': row.id_cliente,
                        'cliente_nombre': row.cliente_nombre,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'fecha_entrega': fecha_entrega,
                        'estado_pago': row.estado_pago
                    }
                    ventas.append(venta)
                
                return ventas
                
        except Exception as e:
            logger.error(f"❌ Error al buscar ventas: {str(e)}")
            return []
    
    def obtener_por_cliente(self, id_cliente: int) -> List[Dict]:
        """
        Obtiene todas las ventas de un cliente.
        
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
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    fecha_entrega = row.fecha_entrega.strftime('%Y-%m-%d') if row.fecha_entrega else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                        'total': float(row.total) if row.total else 0.0,
                        'fecha_entrega': fecha_entrega,
                        'estado_pago': row.estado_pago
                    }
                    ventas.append(venta)
                
                return ventas
                
        except Exception as e:
            logger.error(f"❌ Error al obtener ventas del cliente: {str(e)}")
            return []
    
    def obtener_por_periodo(self, fecha_inicio: date, fecha_fin: date) -> List[Dict]:
        """
        Obtiene ventas en un período específico.
        
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
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
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
            estado_pago: Estado de pago (Pendiente, Pagado, Parcial).
            
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
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
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
            str: Código generado (formato V-XXXX).
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


# Ejemplo de uso y testing
if __name__ == "__main__":
    try:
        repo = VentaRepositorio()
        repo.test_connection()
        
        # Obtener todas las ventas
        ventas = repo.obtener_todas()
        print(f"✅ Total de ventas: {len(ventas)}")
        
        # Mostrar primeras 3 ventas
        for venta in ventas[:3]:
            print(f"  - {venta['codigo_venta']} - {venta['cliente_nombre']} - ${venta['total']}")
        
        # Generar código
        nuevo_codigo = repo.generar_codigo_venta()
        print(f"✅ Nuevo código generado: {nuevo_codigo}")
            
    except Exception as e:
        print(f"❌ Error en prueba: {str(e)}")