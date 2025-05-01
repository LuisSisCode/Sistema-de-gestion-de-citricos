# Gestión de clientes y sus relacionados
import pyodbc
import logging
from bd_connection import DatabaseConnection
from datetime import datetime, timedelta

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_clientes')

class GestorClientes:
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

    # ==================== MÉTODOS PARA GESTIÓN DE CLIENTES ====================
    
    def obtener_clientes(self):
        """
        Obtiene todos los clientes de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada cliente.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_cliente, c.nombre, c.direccion, c.ciudad, c.estado_provincia, 
                       c.telefono, c.correo, c.condiciones_pago, c.fecha_registro, 
                       u.nombre AS registrado_por_nombre, c.activo
                FROM Clientes c
                LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
                WHERE c.activo = 1
                ORDER BY c.nombre
                """
                
                cursor.execute(query)
                clientes = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string
                    fecha_registro = row.fecha_registro.strftime('%Y-%m-%d') if row.fecha_registro and hasattr(row.fecha_registro, 'strftime') else row.fecha_registro
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'direccion': row.direccion,
                        'ciudad': row.ciudad,
                        'estado_provincia': row.estado_provincia,
                        'telefono': row.telefono,
                        'correo': row.correo,
                        'condiciones_pago': row.condiciones_pago,
                        'fecha_registro': fecha_registro,
                        'registrado_por': row.registrado_por_nombre,
                        'activo': bool(row.activo)
                    }
                    clientes.append(cliente)
                
                logger.info(f"Se obtuvieron {len(clientes)} clientes de la base de datos.")
                return clientes
        except Exception as e:
            logger.error(f"Error al obtener clientes: {str(e)}")
            return []

    def obtener_cliente_por_id(self, id_cliente):
        """
        Obtiene un cliente específico por su ID.
        
        Args:
            id_cliente (int): ID del cliente a obtener.
            
        Returns:
            dict: Diccionario con la información del cliente o None si no se encuentra.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_cliente, c.nombre, c.direccion, c.ciudad, c.estado_provincia, 
                       c.telefono, c.correo, c.condiciones_pago, c.fecha_registro, 
                       u.nombre AS registrado_por_nombre, c.activo
                FROM Clientes c
                LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
                WHERE c.id_cliente = ?
                """
                
                cursor.execute(query, (id_cliente,))
                row = cursor.fetchone()
                
                if row:
                    # Formatear fecha como string
                    fecha_registro = row.fecha_registro.strftime('%Y-%m-%d') if row.fecha_registro else None
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'direccion': row.direccion,
                        'ciudad': row.ciudad,
                        'estado_provincia': row.estado_provincia,
                        'telefono': row.telefono,
                        'correo': row.correo,
                        'condiciones_pago': row.condiciones_pago,
                        'fecha_registro': fecha_registro,
                        'registrado_por': row.registrado_por_nombre,
                        'activo': bool(row.activo)
                    }
                    return cliente
                return None
        except Exception as e:
            logger.error(f"Error al obtener cliente por ID: {str(e)}")
            return None

    def buscar_clientes(self, criterio):
        """
        Busca clientes que coincidan con el criterio en varios campos.
        
        Args:
            criterio (str): Texto a buscar en los campos del cliente.
            
        Returns:
            list: Lista de diccionarios con los clientes que coinciden con el criterio.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta para buscar en múltiples campos
                query = """
                SELECT c.id_cliente, c.nombre, c.direccion, c.ciudad, c.estado_provincia, 
                       c.telefono, c.correo, c.condiciones_pago, c.fecha_registro, 
                       u.nombre AS registrado_por_nombre, c.activo
                FROM Clientes c
                LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
                WHERE c.activo = 1 AND (
                    c.nombre LIKE ? OR
                    c.direccion LIKE ? OR
                    c.ciudad LIKE ? OR
                    c.estado_provincia LIKE ? OR
                    c.telefono LIKE ? OR
                    c.correo LIKE ?
                )
                ORDER BY c.nombre
                """
                
                # Parámetro de búsqueda con comodines
                param = f"%{criterio}%"
                params = (param, param, param, param, param, param)
                
                cursor.execute(query, params)
                clientes = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string
                    fecha_registro = row.fecha_registro.strftime('%Y-%m-%d') if row.fecha_registro else None
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'direccion': row.direccion,
                        'ciudad': row.ciudad,
                        'estado_provincia': row.estado_provincia,
                        'telefono': row.telefono,
                        'correo': row.correo,
                        'condiciones_pago': row.condiciones_pago,
                        'fecha_registro': fecha_registro,
                        'registrado_por': row.registrado_por_nombre,
                        'activo': bool(row.activo)
                    }
                    clientes.append(cliente)
                
                logger.info(f"Se encontraron {len(clientes)} clientes con el criterio '{criterio}'.")
                return clientes
        except Exception as e:
            logger.error(f"Error al buscar clientes: {str(e)}")
            return []

    def agregar_cliente(self, cliente_data):
        """
        Agrega un nuevo cliente a la base de datos.
        
        Args:
            cliente_data (dict): Datos del cliente a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del cliente agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Clientes (nombre, direccion, ciudad, estado_provincia, telefono, correo, 
                                     condiciones_pago, fecha_registro, registrado_por, activo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                # Configurar valores para la inserción
                fecha_actual = datetime.now().date()
                valores = (
                    cliente_data['nombre'],
                    cliente_data.get('direccion'),
                    cliente_data.get('ciudad'),
                    cliente_data.get('estado_provincia'),
                    cliente_data.get('telefono'),
                    cliente_data.get('correo'),
                    cliente_data.get('condiciones_pago'),
                    fecha_actual,
                    cliente_data['registrado_por'],  # ID del usuario que registra
                    1  # Activo por defecto
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del cliente recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_cliente = cursor.fetchone()[0]
                
                logger.info(f"Cliente agregado correctamente con ID: {id_cliente}")
                return True, id_cliente
        except Exception as e:
            logger.error(f"Error al agregar cliente: {str(e)}")
            return False, None

    def actualizar_cliente(self, id_cliente, cliente_data):
        """
        Actualiza un cliente existente en la base de datos.
        
        Args:
            id_cliente (int): ID del cliente a actualizar.
            cliente_data (dict): Datos actualizados del cliente.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'nombre' in cliente_data:
                    campos_actualizar.append("nombre = ?")
                    valores.append(cliente_data['nombre'])
                    
                if 'direccion' in cliente_data:
                    campos_actualizar.append("direccion = ?")
                    valores.append(cliente_data['direccion'])
                    
                if 'ciudad' in cliente_data:
                    campos_actualizar.append("ciudad = ?")
                    valores.append(cliente_data['ciudad'])
                    
                if 'estado_provincia' in cliente_data:
                    campos_actualizar.append("estado_provincia = ?")
                    valores.append(cliente_data['estado_provincia'])
                    
                if 'telefono' in cliente_data:
                    campos_actualizar.append("telefono = ?")
                    valores.append(cliente_data['telefono'])
                    
                if 'correo' in cliente_data:
                    campos_actualizar.append("correo = ?")
                    valores.append(cliente_data['correo'])
                    
                if 'condiciones_pago' in cliente_data:
                    campos_actualizar.append("condiciones_pago = ?")
                    valores.append(cliente_data['condiciones_pago'])
                
                if 'activo' in cliente_data:
                    campos_actualizar.append("activo = ?")
                    valores.append(1 if cliente_data['activo'] else 0)
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE Clientes SET {', '.join(campos_actualizar)} WHERE id_cliente = ?"
                valores.append(id_cliente)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Cliente actualizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar cliente: {str(e)}")
            return False

    def eliminar_cliente(self, id_cliente):
        """
        Elimina un cliente de la base de datos (eliminación lógica).
        
        Args:
            id_cliente (int): ID del cliente a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Verificar primero si el cliente tiene ventas asociadas
                query_ventas = """
                SELECT COUNT(*) AS total_ventas
                FROM Ventas
                WHERE id_cliente = ?
                """
                
                cursor.execute(query_ventas, (id_cliente,))
                row_ventas = cursor.fetchone()
                
                if row_ventas and row_ventas.total_ventas > 0:
                    # Si el cliente tiene ventas, hacer eliminación lógica
                    query = "UPDATE Clientes SET activo = 0 WHERE id_cliente = ?"
                    cursor.execute(query, (id_cliente,))
                else:
                    # Si no tiene ventas, se podría hacer eliminación física
                    # pero por seguridad mantendremos la eliminación lógica
                    query = "UPDATE Clientes SET activo = 0 WHERE id_cliente = ?"
                    cursor.execute(query, (id_cliente,))
                
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Cliente eliminado lógicamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar cliente: {str(e)}")
            return False

    # ==================== MÉTODOS PARA ANÁLISIS DE CLIENTES ====================
    
    def obtener_historial_compras_cliente(self, id_cliente):
        """
        Obtiene el historial de compras de un cliente específico.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            dict: Diccionario con el historial de compras y estadísticas.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Obtener información básica del cliente
                query_cliente = """
                SELECT nombre, fecha_registro
                FROM Clientes
                WHERE id_cliente = ?
                """
                
                cursor.execute(query_cliente, (id_cliente,))
                row_cliente = cursor.fetchone()
                
                if not row_cliente:
                    return None
                
                # Obtener todas las ventas del cliente
                query_ventas = """
                SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.subtotal, v.total,
                       v.condiciones_pago, v.estado_pago, e.nombre AS estado_nombre,
                       (SELECT COUNT(*) FROM DetallesVenta WHERE id_venta = v.id_venta) AS total_productos
                FROM Ventas v
                JOIN EstadosVenta e ON v.id_estado = e.id_estado
                WHERE v.id_cliente = ?
                ORDER BY v.fecha_venta DESC
                """
                
                cursor.execute(query_ventas, (id_cliente,))
                ventas_rows = cursor.fetchall()
                
                ventas = []
                total_ventas = 0
                total_gastado = 0
                
                for row in ventas_rows:
                    # Formatear fecha como string
                    fecha_venta = row.fecha_venta.strftime('%Y-%m-%d') if row.fecha_venta else None
                    
                    venta = {
                        'id_venta': row.id_venta,
                        'codigo_venta': row.codigo_venta,
                        'fecha_venta': fecha_venta,
                        'subtotal': float(row.subtotal),
                        'total': float(row.total),
                        'condiciones_pago': row.condiciones_pago,
                        'estado_pago': row.estado_pago,
                        'estado_nombre': row.estado_nombre,
                        'total_productos': row.total_productos
                    }
                    ventas.append(venta)
                    
                    total_ventas += 1
                    total_gastado += float(row.total)
                
                # Obtener información de los productos más comprados
                query_productos = """
                SELECT tc.nombre AS tipo_cultivo, vc.nombre AS variedad,
                       SUM(dv.cantidad) AS cantidad_total,
                       COUNT(DISTINCT v.id_venta) AS frecuencia_compra
                FROM DetallesVenta dv
                JOIN Ventas v ON dv.id_venta = v.id_venta
                JOIN LotesCosecha lc ON dv.id_lote = lc.id_lote
                JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
                JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
                JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
                WHERE v.id_cliente = ?
                GROUP BY tc.nombre, vc.nombre
                ORDER BY cantidad_total DESC
                """
                
                cursor.execute(query_productos, (id_cliente,))
                productos_rows = cursor.fetchall()
                
                productos = []
                for row in productos_rows:
                    producto = {
                        'tipo_cultivo': row.tipo_cultivo,
                        'variedad': row.variedad,
                        'cantidad_total': float(row.cantidad_total),
                        'frecuencia_compra': row.frecuencia_compra,
                        'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
                    }
                    productos.append(producto)
                
                # Obtener estadísticas por mes (últimos 12 meses)
                query_por_mes = """
                SELECT YEAR(fecha_venta) AS año, MONTH(fecha_venta) AS mes,
                       COUNT(*) AS total_ventas, SUM(total) AS monto_total
                FROM Ventas
                WHERE id_cliente = ? AND fecha_venta >= DATEADD(month, -12, GETDATE())
                GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
                ORDER BY año DESC, mes DESC
                """
                
                cursor.execute(query_por_mes, (id_cliente,))
                meses_rows = cursor.fetchall()
                
                meses = []
                for row in meses_rows:
                    mes = {
                        'año': row.año,
                        'mes': row.mes,
                        'total_ventas': row.total_ventas,
                        'monto_total': float(row.monto_total) if row.monto_total else 0.0,
                        'mes_nombre': self._obtener_nombre_mes(row.mes)
                    }
                    meses.append(mes)
                
                # Calcular promedio por compra
                promedio_compra = total_gastado / total_ventas if total_ventas > 0 else 0
                
                # Calcular antigüedad del cliente en días
                fecha_registro = row_cliente.fecha_registro.date() if row_cliente.fecha_registro else datetime.now().date()
                antiguedad_dias = (datetime.now().date() - fecha_registro).days
                
                # Armar el historial completo
                historial = {
                    'cliente': {
                        'id_cliente': id_cliente,
                        'nombre': row_cliente.nombre,
                        'fecha_registro': fecha_registro.strftime('%Y-%m-%d'),
                        'antiguedad_dias': antiguedad_dias
                    },
                    'estadisticas': {
                        'total_ventas': total_ventas,
                        'total_gastado': total_gastado,
                        'promedio_compra': promedio_compra,
                        'primera_compra': ventas[-1]['fecha_venta'] if ventas else None,
                        'ultima_compra': ventas[0]['fecha_venta'] if ventas else None
                    },
                    'ventas': ventas,
                    'productos_favoritos': productos[:5],  # Top 5 productos
                    'compras_por_mes': meses
                }
                
                return historial
        except Exception as e:
            logger.error(f"Error al obtener historial de compras del cliente: {str(e)}")
            return None

    def clasificar_clientes_por_volumen(self):
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Consulta para obtener el volumen de compras de cada cliente
                query = """
                SELECT c.id_cliente, c.nombre, c.telefono, c.correo,
                    COUNT(v.id_venta) AS total_ventas,
                    SUM(v.total) AS monto_total,
                    MAX(v.fecha_venta) AS ultima_compra
                FROM Clientes c
                LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
                WHERE c.activo = 1
                GROUP BY c.id_cliente, c.nombre, c.telefono, c.correo
                ORDER BY monto_total DESC
                """
                
                cursor.execute(query)
                clientes_rows = cursor.fetchall()
                
                clientes = []
                
                # Determinar categorías de clientes basadas en percentiles
                if len(clientes_rows) > 0:
                    # Extrae montos totales para calcular percentiles
                    montos = [float(row.monto_total) if row.monto_total else 0.0 for row in clientes_rows]
                    montos.sort()
                    
                    # Calculamos percentiles para clasificación
                    percentil_80 = self._calcular_percentil(montos, 80)
                    percentil_50 = self._calcular_percentil(montos, 50)
                    percentil_20 = self._calcular_percentil(montos, 20)
                    
                    for row in clientes_rows:
                        # Formatear fecha como string de manera segura
                        if hasattr(row.ultima_compra, 'strftime'):
                            ultima_compra = row.ultima_compra.strftime('%Y-%m-%d')
                        else:
                            ultima_compra = str(row.ultima_compra) if row.ultima_compra else None
                        
                        # Determinar categoría
                        monto = float(row.monto_total) if row.monto_total else 0.0
                        if monto >= percentil_80:
                            categoria = "Premium"
                        elif monto >= percentil_50:
                            categoria = "Regular"
                        elif monto >= percentil_20:
                            categoria = "Ocasional" 
                        else:
                            categoria = "Nuevo"
                        
                        cliente = {
                            'id_cliente': row.id_cliente,
                            'nombre': row.nombre,
                            'telefono': row.telefono,
                            'correo': row.correo,
                            'total_ventas': row.total_ventas or 0,
                            'monto_total': monto,
                            'ultima_compra': ultima_compra,
                            'categoria': categoria
                        }
                        clientes.append(cliente)
                
                logger.info(f"Clasificación de clientes completada. Total: {len(clientes)}")
                return clientes
        except Exception as e:
            logger.error(f"Error al clasificar clientes por volumen: {str(e)}")
            return []   

    def obtener_clientes_inactivos(self, dias_inactividad=90):
        """
        Obtiene los clientes que no han realizado compras en el período especificado.
        
        Args:
            dias_inactividad (int): Número de días sin compras para considerar inactivo.
            
        Returns:
            list: Lista de diccionarios con los clientes inactivos.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                fecha_limite = datetime.now().date() - timedelta(days=dias_inactividad)
                
                query = """
                SELECT c.id_cliente, c.nombre, c.telefono, c.correo,
                       MAX(v.fecha_venta) AS ultima_compra,
                       DATEDIFF(day, MAX(v.fecha_venta), GETDATE()) AS dias_inactividad
                FROM Clientes c
                LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
                WHERE c.activo = 1
                GROUP BY c.id_cliente, c.nombre, c.telefono, c.correo
                HAVING MAX(v.fecha_venta) IS NULL OR MAX(v.fecha_venta) <= ?
                ORDER BY ultima_compra
                """
                
                cursor.execute(query, (fecha_limite,))
                clientes_rows = cursor.fetchall()
                
                clientes_inactivos = []
                
                for row in clientes_rows:
                    # Formatear fecha como string
                    ultima_compra = row.ultima_compra.strftime('%Y-%m-%d') if row.ultima_compra else None
                    
                    cliente = {
                        'id_cliente': row.id_cliente,
                        'nombre': row.nombre,
                        'telefono': row.telefono,
                        'correo': row.correo,
                        'ultima_compra': ultima_compra,
                        'dias_inactividad': row.dias_inactividad if row.dias_inactividad else dias_inactividad  # Por defecto si nunca compró
                    }
                    clientes_inactivos.append(cliente)
                
                logger.info(f"Se obtuvieron {len(clientes_inactivos)} clientes inactivos.")
                return clientes_inactivos
        except Exception as e:
            logger.error(f"Error al obtener clientes inactivos: {str(e)}")
            return []

    # ==================== MÉTODOS UTILITARIOS ====================
    
    def _calcular_percentil(self, valores, percentil):
        """
        Calcula un percentil específico para una lista de valores.
        
        Args:
            valores (list): Lista de valores numéricos.
            percentil (float): Percentil a calcular (0-100).
            
        Returns:
            float: Valor del percentil.
        """
        if not valores:
            return 0
            
        k = (len(valores) - 1) * percentil / 100
        f = int(k)
        c = int(k) + 1 if k != f else int(k)
        
        if f >= len(valores):
            return valores[-1]
        elif c >= len(valores):
            return valores[-1]
        else:
            return valores[f] + (valores[c] - valores[f]) * (k - f)

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

# Ejemplo de uso
if __name__ == "__main__":
    # Prueba la conexión y consulta
    try:
        gestor = GestorClientes()
        clientes = gestor.obtener_clientes()
        print(f"Total de clientes: {len(clientes)}")
        for cliente in clientes[:5]:  # Mostrar solo los primeros 5 clientes
            print(f"ID: {cliente['id_cliente']}, Nombre: {cliente['nombre']}, "
                  f"Teléfono: {cliente['telefono']}, Correo: {cliente['correo']}")
            
        # Ejemplo de clasificación
        clasificacion = gestor.clasificar_clientes_por_volumen()
        print("\nClasificación de clientes por volumen:")
        categorias = {}
        for cliente in clasificacion:
            cat = cliente['categoria']
            if cat in categorias:
                categorias[cat] += 1
            else:
                categorias[cat] = 1
        
        for categoria, cantidad in categorias.items():
            print(f"  {categoria}: {cantidad} clientes")
    except Exception as e:
        print(f"Error al ejecutar el ejemplo: {str(e)}")