"""
Repositorio de Clientes
Capa de acceso a datos - Solo queries SQL
Sin lógica de negocio, sin cálculos complejos
"""

import logging
from datetime import datetime, date
from typing import List, Dict, Optional, Tuple
from backend.core.database import DatabaseConnection

# Configurar logging
logger = logging.getLogger('cliente_repositorio')


class ClienteRepositorio:
    """
    Repositorio para acceso a datos de clientes.
    Responsabilidad: Solo ejecutar queries SQL, sin lógica de negocio.
    """
    
    def __init__(self):
        """Inicializa la conexión a la base de datos."""
        try:
            self.db = DatabaseConnection()
            logger.info("✅ ClienteRepositorio inicializado correctamente.")
        except Exception as e:
            logger.error(f"❌ Error al inicializar ClienteRepositorio: {str(e)}")
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

    # ==================== CRUD BÁSICO ====================
    
    def obtener_todos(self) -> List[Dict]:
        """
        Obtiene todos los clientes activos.
        
        Returns:
            List[Dict]: Lista de clientes.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_cliente, c.nombre, c.direccion, c.telefono, 
                       c.condiciones_pago, c.fecha_registro, c.registrado_por, 
                       u.nombre AS registrado_por_nombre, c.activo
                FROM Clientes c
                LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
                WHERE c.activo = 1
                ORDER BY c.nombre
                """
                
                cursor.execute(query)
                clientes = []
                
                for row in cursor.fetchall():
                    fecha_registro = row.fecha_registro.strftime('%Y-%m-%d') if row.fecha_registro and hasattr(row.fecha_registro, 'strftime') else row.fecha_registro
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'direccion': row.direccion,
                        'telefono': row.telefono,
                        'condiciones_pago': row.condiciones_pago,
                        'fecha_registro': fecha_registro,
                        'registrado_por': row.registrado_por,
                        'registrado_por_nombre': row.registrado_por_nombre,
                        'activo': bool(row.activo)
                    }
                    clientes.append(cliente)
                
                logger.info(f"📊 Se obtuvieron {len(clientes)} clientes")
                return clientes
                
        except Exception as e:
            logger.error(f"❌ Error al obtener clientes: {str(e)}")
            return []
    
    def obtener_por_id(self, id_cliente: int) -> Optional[Dict]:
        """
        Obtiene un cliente específico por su ID.
        
        Args:
            id_cliente: ID del cliente a obtener.
            
        Returns:
            Dict con la información del cliente o None si no se encuentra.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_cliente, c.nombre, c.direccion, 
                       c.telefono, c.condiciones_pago, c.fecha_registro, 
                       c.registrado_por, u.nombre AS registrado_por_nombre, c.activo
                FROM Clientes c
                LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
                WHERE c.id_cliente = ?
                """
                
                cursor.execute(query, (id_cliente,))
                row = cursor.fetchone()
                
                if row:
                    fecha_registro = row.fecha_registro.strftime('%Y-%m-%d') if row.fecha_registro else None
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'direccion': row.direccion,
                        'telefono': row.telefono,
                        'condiciones_pago': row.condiciones_pago,
                        'fecha_registro': fecha_registro,
                        'registrado_por': row.registrado_por,
                        'registrado_por_nombre': row.registrado_por_nombre,
                        'activo': bool(row.activo)
                    }
                    
                    logger.info(f"✅ Cliente {id_cliente} encontrado")
                    return cliente
                
                logger.warning(f"⚠️ Cliente {id_cliente} no encontrado")
                return None
                
        except Exception as e:
            logger.error(f"❌ Error al obtener cliente {id_cliente}: {str(e)}")
            return None
    
    def crear(self, cliente_data: Dict, registrado_por: int) -> Tuple[bool, Optional[int]]:
        """
        Crea un nuevo cliente en la base de datos.
        
        Args:
            cliente_data: Diccionario con los datos del cliente.
            registrado_por: ID del usuario que registra el cliente.
            
        Returns:
            Tuple[bool, Optional[int]]: (Éxito, ID del nuevo cliente)
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Clientes (nombre, direccion, telefono, condiciones_pago, 
                                     fecha_registro, registrado_por, activo)
                VALUES (?, ?, ?, ?, GETDATE(), ?, 1)
                """
                
                valores = (
                    cliente_data['nombre'],
                    cliente_data.get('direccion'),
                    cliente_data.get('telefono'),
                    cliente_data.get('condiciones_pago'),
                    registrado_por
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del cliente recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_cliente = int(cursor.fetchone()[0])
                
                logger.info(f"✅ Cliente creado con ID: {id_cliente}")
                return True, id_cliente
                
        except Exception as e:
            logger.error(f"❌ Error al crear cliente: {str(e)}")
            return False, None
    
    def actualizar(self, id_cliente: int, cliente_data: Dict) -> bool:
        """
        Actualiza un cliente existente.
        
        Args:
            id_cliente: ID del cliente a actualizar.
            cliente_data: Diccionario con los datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                UPDATE Clientes 
                SET nombre = ?, 
                    direccion = ?, 
                    telefono = ?, 
                    condiciones_pago = ?
                WHERE id_cliente = ?
                """
                
                valores = (
                    cliente_data['nombre'],
                    cliente_data.get('direccion'),
                    cliente_data.get('telefono'),
                    cliente_data.get('condiciones_pago'),
                    id_cliente
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                if cursor.rowcount > 0:
                    logger.info(f"✅ Cliente {id_cliente} actualizado")
                    return True
                else:
                    logger.warning(f"⚠️ Cliente {id_cliente} no encontrado para actualizar")
                    return False
                    
        except Exception as e:
            logger.error(f"❌ Error al actualizar cliente {id_cliente}: {str(e)}")
            return False
    
    def eliminar(self, id_cliente: int) -> bool:
        """
        Elimina lógicamente un cliente (soft delete).
        
        Args:
            id_cliente: ID del cliente a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                UPDATE Clientes 
                SET activo = 0 
                WHERE id_cliente = ?
                """
                
                cursor.execute(query, (id_cliente,))
                conn.commit()
                
                if cursor.rowcount > 0:
                    logger.info(f"✅ Cliente {id_cliente} desactivado")
                    return True
                else:
                    logger.warning(f"⚠️ Cliente {id_cliente} no encontrado para eliminar")
                    return False
                    
        except Exception as e:
            logger.error(f"❌ Error al eliminar cliente {id_cliente}: {str(e)}")
            return False
    
    # ==================== BÚSQUEDAS ====================
    
    def buscar_por_criterio(self, criterio: str) -> List[Dict]:
        """
        Busca clientes que coincidan con el criterio en varios campos.
        
        Args:
            criterio: Texto a buscar.
            
        Returns:
            List[Dict]: Lista de clientes que coinciden.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_cliente, c.nombre, c.direccion, 
                       c.telefono, c.condiciones_pago, c.fecha_registro, 
                       u.nombre AS registrado_por_nombre, c.activo
                FROM Clientes c
                LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
                WHERE c.activo = 1 AND (
                    c.nombre LIKE ? OR
                    c.direccion LIKE ? OR
                    c.telefono LIKE ?
                )
                ORDER BY c.nombre
                """
                
                param = f"%{criterio}%"
                cursor.execute(query, (param, param, param))
                
                clientes = []
                for row in cursor.fetchall():
                    fecha_registro = row.fecha_registro.strftime('%Y-%m-%d') if row.fecha_registro else None
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'direccion': row.direccion,
                        'telefono': row.telefono,
                        'condiciones_pago': row.condiciones_pago,
                        'fecha_registro': fecha_registro,
                        'registrado_por': row.registrado_por_nombre,
                        'activo': bool(row.activo)
                    }
                    clientes.append(cliente)
                
                logger.info(f"🔍 Búsqueda '{criterio}': {len(clientes)} resultados")
                return clientes
                
        except Exception as e:
            logger.error(f"❌ Error al buscar clientes: {str(e)}")
            return []
    
    def buscar_por_nombre(self, nombre: str) -> List[Dict]:
        """
        Busca clientes por nombre.
        
        Args:
            nombre: Nombre a buscar.
            
        Returns:
            List[Dict]: Lista de clientes que coinciden.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_cliente, c.nombre, c.direccion, c.telefono, 
                       c.condiciones_pago, c.fecha_registro, 
                       u.nombre AS registrado_por_nombre, c.activo
                FROM Clientes c
                LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
                WHERE c.activo = 1 AND c.nombre LIKE ?
                ORDER BY c.nombre
                """
                
                cursor.execute(query, (f"%{nombre}%",))
                
                clientes = []
                for row in cursor.fetchall():
                    fecha_registro = row.fecha_registro.strftime('%Y-%m-%d') if row.fecha_registro else None
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'direccion': row.direccion,
                        'telefono': row.telefono,
                        'condiciones_pago': row.condiciones_pago,
                        'fecha_registro': fecha_registro,
                        'registrado_por': row.registrado_por_nombre,
                        'activo': bool(row.activo)
                    }
                    clientes.append(cliente)
                
                return clientes
                
        except Exception as e:
            logger.error(f"❌ Error al buscar por nombre: {str(e)}")
            return []
    
    # ==================== QUERIES ESPECÍFICAS ====================
    
    def obtener_con_estadisticas_ventas(self) -> List[Dict]:
        """
        Obtiene clientes con sus estadísticas de ventas (JOIN con Ventas).
        
        Returns:
            List[Dict]: Lista de clientes con estadísticas.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_cliente, c.nombre, c.telefono, 
                       COUNT(v.id_venta) AS total_ventas,
                       ISNULL(SUM(v.total), 0) AS monto_total,
                       MAX(v.fecha_venta) AS ultima_compra
                FROM Clientes c
                LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
                WHERE c.activo = 1
                GROUP BY c.id_cliente, c.nombre, c.telefono
                ORDER BY monto_total DESC
                """
                
                cursor.execute(query)
                clientes = []
                
                for row in cursor.fetchall():
                    ultima_compra = row.ultima_compra.strftime('%Y-%m-%d') if hasattr(row.ultima_compra, 'strftime') else str(row.ultima_compra) if row.ultima_compra else None
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'telefono': row.telefono,
                        'total_ventas': row.total_ventas or 0,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0,
                        'ultima_compra': ultima_compra
                    }
                    clientes.append(cliente)
                
                logger.info(f"📊 Se obtuvieron {len(clientes)} clientes con estadísticas")
                return clientes
                
        except Exception as e:
            logger.error(f"❌ Error al obtener clientes con estadísticas: {str(e)}")
            return []
    
    def obtener_inactivos_desde(self, fecha_limite: date) -> List[Dict]:
        """
        Obtiene clientes que no han comprado desde una fecha específica.
        
        Args:
            fecha_limite: Fecha límite para considerar inactivo.
            
        Returns:
            List[Dict]: Lista de clientes inactivos.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_cliente, c.nombre, c.telefono,
                       MAX(v.fecha_venta) AS ultima_compra,
                       DATEDIFF(day, MAX(v.fecha_venta), GETDATE()) AS dias_inactividad
                FROM Clientes c
                LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
                WHERE c.activo = 1
                GROUP BY c.id_cliente, c.nombre, c.telefono
                HAVING MAX(v.fecha_venta) IS NULL OR MAX(v.fecha_venta) <= ?
                ORDER BY ultima_compra
                """
                
                cursor.execute(query, (fecha_limite,))
                clientes = []
                
                for row in cursor.fetchall():
                    ultima_compra = row.ultima_compra.strftime('%Y-%m-%d') if row.ultima_compra else None
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'telefono': row.telefono,
                        'ultima_compra': ultima_compra,
                        'dias_inactividad': row.dias_inactividad if row.dias_inactividad else None
                    }
                    clientes.append(cliente)
                
                logger.info(f"📊 Se obtuvieron {len(clientes)} clientes inactivos")
                return clientes
                
        except Exception as e:
            logger.error(f"❌ Error al obtener clientes inactivos: {str(e)}")
            return []
    
    def verificar_tiene_ventas(self, id_cliente: int) -> bool:
        """
        Verifica si un cliente tiene ventas asociadas.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            bool: True si tiene ventas.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT COUNT(*) 
                FROM Ventas 
                WHERE id_cliente = ?
                """
                
                cursor.execute(query, (id_cliente,))
                count = cursor.fetchone()[0]
                
                return count > 0
                
        except Exception as e:
            logger.error(f"❌ Error al verificar ventas del cliente: {str(e)}")
            return False
    
    def existe_cliente(self, id_cliente: int) -> bool:
        """
        Verifica si existe un cliente con el ID especificado.
        
        Args:
            id_cliente: ID del cliente a verificar.
            
        Returns:
            bool: True si existe.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "SELECT COUNT(*) FROM Clientes WHERE id_cliente = ?"
                cursor.execute(query, (id_cliente,))
                
                count = cursor.fetchone()[0]
                return count > 0
                
        except Exception as e:
            logger.error(f"❌ Error al verificar existencia del cliente: {str(e)}")
            return False
    
    def obtener_activos(self) -> List[Dict]:
        """
        Obtiene solo los clientes activos.
        Alias para obtener_todos() pero más explícito.
        
        Returns:
            List[Dict]: Lista de clientes activos.
        """
        return self.obtener_todos()


# Ejemplo de uso y testing
if __name__ == "__main__":
    try:
        repo = ClienteRepositorio()
        repo.test_connection()
        
        # Obtener todos los clientes
        clientes = repo.obtener_todos()
        print(f"✅ Total de clientes: {len(clientes)}")
        
        # Mostrar primeros 3 clientes
        for cliente in clientes[:3]:
            print(f"  - {cliente['nombre']} (ID: {cliente['id_cliente']})")
            
    except Exception as e:
        print(f"❌ Error en prueba: {str(e)}")
