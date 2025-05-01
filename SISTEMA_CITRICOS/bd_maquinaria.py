import pyodbc
import logging
from bd_connection import DatabaseConnection
from datetime import datetime

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_maquinaria')

class GestorMaquinaria:
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
            logger.info("Conexión a la base de datos establecida correctamente en GestorMaquinaria.")
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

    def obtener_maquinaria(self):
        """
        Obtiene todos los equipos de maquinaria de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada equipo.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_maquinaria, codigo, nombre, tipo, marca, tipo_combustible, 
                       estado, ubicacion_actual, activo
                FROM Maquinaria
                ORDER BY id_maquinaria
                """
                
                cursor.execute(query)
                maquinarias = []
                
                for row in cursor.fetchall():
                    maquinaria = {
                        'id_maquinaria': row.id_maquinaria,
                        'codigo': row.codigo,
                        'nombre': row.nombre,
                        'tipo': row.tipo,
                        'marca': row.marca,
                        'tipo_combustible': row.tipo_combustible,
                        'estado': row.estado,
                        'ubicacion_actual': row.ubicacion_actual,
                        'activo': bool(row.activo)
                    }
                    maquinarias.append(maquinaria)
                
                logger.info(f"Se obtuvieron {len(maquinarias)} equipos de maquinaria de la base de datos.")
                return maquinarias
        except Exception as e:
            logger.error(f"Error al obtener maquinaria: {str(e)}")
            return []

    def agregar_maquinaria(self, maquinaria_data):
        """
        Agrega un nuevo equipo de maquinaria a la base de datos.
        
        Args:
            maquinaria_data (dict): Datos del equipo a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del equipo agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Maquinaria (codigo, nombre, tipo, marca, tipo_combustible, 
                                     estado, ubicacion_actual, activo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                # Configurar valores para la inserción
                valores = (
                    maquinaria_data['codigo'],
                    maquinaria_data['nombre'],
                    maquinaria_data['tipo'],
                    maquinaria_data['marca'],
                    maquinaria_data.get('tipo_combustible'),
                    maquinaria_data['estado'],
                    maquinaria_data.get('ubicacion_actual'),
                    1 if maquinaria_data.get('activo', True) else 0
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del equipo recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_maquinaria = cursor.fetchone()[0]
                
                logger.info(f"Equipo de maquinaria agregado correctamente con ID: {id_maquinaria}")
                return True, id_maquinaria
        except Exception as e:
            logger.error(f"Error al agregar equipo de maquinaria: {str(e)}")
            return False, None

    def actualizar_maquinaria(self, id_maquinaria, maquinaria_data):
        """
        Actualiza un equipo de maquinaria existente en la base de datos.
        
        Args:
            id_maquinaria (int): ID del equipo a actualizar.
            maquinaria_data (dict): Datos actualizados del equipo.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'codigo' in maquinaria_data:
                    campos_actualizar.append("codigo = ?")
                    valores.append(maquinaria_data['codigo'])
                    
                if 'nombre' in maquinaria_data:
                    campos_actualizar.append("nombre = ?")
                    valores.append(maquinaria_data['nombre'])
                    
                if 'tipo' in maquinaria_data:
                    campos_actualizar.append("tipo = ?")
                    valores.append(maquinaria_data['tipo'])
                    
                if 'marca' in maquinaria_data:
                    campos_actualizar.append("marca = ?")
                    valores.append(maquinaria_data['marca'])
                    
                if 'tipo_combustible' in maquinaria_data:
                    campos_actualizar.append("tipo_combustible = ?")
                    valores.append(maquinaria_data['tipo_combustible'])
                    
                if 'estado' in maquinaria_data:
                    campos_actualizar.append("estado = ?")
                    valores.append(maquinaria_data['estado'])
                    
                if 'ubicacion_actual' in maquinaria_data:
                    campos_actualizar.append("ubicacion_actual = ?")
                    valores.append(maquinaria_data['ubicacion_actual'])
                    
                if 'activo' in maquinaria_data:
                    campos_actualizar.append("activo = ?")
                    valores.append(1 if maquinaria_data['activo'] else 0)
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE Maquinaria SET {', '.join(campos_actualizar)} WHERE id_maquinaria = ?"
                valores.append(id_maquinaria)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Equipo de maquinaria actualizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar equipo de maquinaria: {str(e)}")
            return False

    def eliminar_maquinaria(self, id_maquinaria):
        """
        Elimina un equipo de maquinaria de la base de datos.
        
        Args:
            id_maquinaria (int): ID del equipo a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM Maquinaria WHERE id_maquinaria = ?"
                cursor.execute(query, (id_maquinaria,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Equipo de maquinaria eliminado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar equipo de maquinaria: {str(e)}")
            return False
    
    def desactivar_maquinaria(self, id_maquinaria):
        """
        Desactiva un equipo de maquinaria en lugar de eliminarlo físicamente.
        
        Args:
            id_maquinaria (int): ID del equipo a desactivar.
            
        Returns:
            bool: True si se desactivó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "UPDATE Maquinaria SET activo = 0 WHERE id_maquinaria = ?"
                cursor.execute(query, (id_maquinaria,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Equipo de maquinaria desactivado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al desactivar equipo de maquinaria: {str(e)}")
            return False

    # Funciones para la gestión de uso de maquinaria
    def obtener_usos_maquinaria(self, id_maquinaria=None):
        """
        Obtiene los registros de uso de maquinaria de la base de datos.
        
        Args:
            id_maquinaria (int, opcional): ID del equipo para filtrar los usos. Si es None, se obtienen todos.
            
        Returns:
            list: Lista de diccionarios con la información de cada registro de uso.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT um.id_uso, um.id_maquinaria, m.nombre AS nombre_maquinaria, 
                       um.id_usuario, u.nombre + ' ' + u.apellido AS nombre_usuario,
                       um.fecha_inicio, um.fecha_fin, um.actividad_realizada, 
                       um.parcela, um.combustible_consumido
                FROM UsoMaquinaria um
                JOIN Maquinaria m ON um.id_maquinaria = m.id_maquinaria
                JOIN Usuarios u ON um.id_usuario = u.id_usuario
                """
                
                params = []
                if id_maquinaria:
                    query += " WHERE um.id_maquinaria = ?"
                    params.append(id_maquinaria)
                
                query += " ORDER BY um.fecha_inicio DESC"
                
                cursor.execute(query, params)
                usos = []
                
                for row in cursor.fetchall():
                    # Formatear fechas como strings
                    fecha_inicio = row.fecha_inicio.strftime('%Y-%m-%d %H:%M:%S') if row.fecha_inicio else None
                    fecha_fin = row.fecha_fin.strftime('%Y-%m-%d %H:%M:%S') if row.fecha_fin else None
                    
                    uso = {
                        'id_uso': row.id_uso,
                        'id_maquinaria': row.id_maquinaria,
                        'nombre_maquinaria': row.nombre_maquinaria,
                        'id_usuario': row.id_usuario,
                        'nombre_usuario': row.nombre_usuario,
                        'fecha_inicio': fecha_inicio,
                        'fecha_fin': fecha_fin,
                        'actividad_realizada': row.actividad_realizada,
                        'parcela': row.parcela,
                        'combustible_consumido': row.combustible_consumido
                    }
                    usos.append(uso)
                
                logger.info(f"Se obtuvieron {len(usos)} registros de uso de maquinaria.")
                return usos
        except Exception as e:
            logger.error(f"Error al obtener registros de uso de maquinaria: {str(e)}")
            return []

    def registrar_uso_maquinaria(self, uso_data):
        """
        Registra un nuevo uso de maquinaria en la base de datos.
        
        Args:
            uso_data (dict): Datos del uso a registrar.
            
        Returns:
            bool: True si se registró correctamente, False en caso contrario.
            int: ID del uso agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO UsoMaquinaria (id_maquinaria, id_usuario, fecha_inicio, 
                                        fecha_fin, actividad_realizada, parcela, 
                                        combustible_consumido)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """
                
                # Preparar los valores para la inserción
                fecha_inicio = datetime.now() if 'fecha_inicio' not in uso_data else uso_data['fecha_inicio']
                valores = (
                    uso_data['id_maquinaria'],
                    uso_data['id_usuario'],
                    fecha_inicio,
                    uso_data.get('fecha_fin'),
                    uso_data['actividad_realizada'],
                    uso_data.get('parcela'),
                    uso_data.get('combustible_consumido')
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del uso recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_uso = cursor.fetchone()[0]
                
                logger.info(f"Uso de maquinaria registrado correctamente con ID: {id_uso}")
                return True, id_uso
        except Exception as e:
            logger.error(f"Error al registrar uso de maquinaria: {str(e)}")
            return False, None

    def finalizar_uso_maquinaria(self, id_uso, fecha_fin=None, combustible_consumido=None):
        """
        Finaliza un registro de uso de maquinaria marcando la fecha de fin y el combustible consumido.
        
        Args:
            id_uso (int): ID del registro de uso a finalizar.
            fecha_fin (datetime, opcional): Fecha y hora de finalización. Si es None, se usa la hora actual.
            combustible_consumido (float, opcional): Cantidad de combustible consumido.
            
        Returns:
            bool: True si se finalizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                if fecha_fin is None:
                    fecha_fin = datetime.now()
                
                query = "UPDATE UsoMaquinaria SET fecha_fin = ?"
                params = [fecha_fin]
                
                if combustible_consumido is not None:
                    query += ", combustible_consumido = ?"
                    params.append(combustible_consumido)
                
                query += " WHERE id_uso = ?"
                params.append(id_uso)
                
                cursor.execute(query, params)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Uso de maquinaria finalizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al finalizar uso de maquinaria: {str(e)}")
            return False

    # Funciones para la gestión de mantenimientos
    def obtener_mantenimientos(self, id_maquinaria=None):
        """
        Obtiene los registros de mantenimientos de la base de datos.
        
        Args:
            id_maquinaria (int, opcional): ID del equipo para filtrar los mantenimientos. Si es None, se obtienen todos.
            
        Returns:
            list: Lista de diccionarios con la información de cada mantenimiento.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT m.id_mantenimiento, m.id_maquinaria, maq.nombre AS nombre_maquinaria, 
                       m.tipo, m.fecha_realizada, m.descripcion, m.costo_total, 
                       m.responsable, u.nombre + ' ' + u.apellido AS nombre_responsable, 
                       m.estado
                FROM Mantenimientos m
                JOIN Maquinaria maq ON m.id_maquinaria = maq.id_maquinaria
                JOIN Usuarios u ON m.responsable = u.id_usuario
                """
                
                params = []
                if id_maquinaria:
                    query += " WHERE m.id_maquinaria = ?"
                    params.append(id_maquinaria)
                
                query += " ORDER BY m.fecha_realizada DESC"
                
                cursor.execute(query, params)
                mantenimientos = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string
                    fecha_realizada = row.fecha_realizada.strftime('%Y-%m-%d') if row.fecha_realizada else None
                    
                    mantenimiento = {
                        'id_mantenimiento': row.id_mantenimiento,
                        'id_maquinaria': row.id_maquinaria,
                        'nombre_maquinaria': row.nombre_maquinaria,
                        'tipo': row.tipo,
                        'fecha_realizada': fecha_realizada,
                        'descripcion': row.descripcion,
                        'costo_total': float(row.costo_total),
                        'responsable': row.responsable,
                        'nombre_responsable': row.nombre_responsable,
                        'estado': row.estado
                    }
                    mantenimientos.append(mantenimiento)
                
                logger.info(f"Se obtuvieron {len(mantenimientos)} registros de mantenimientos.")
                return mantenimientos
        except Exception as e:
            logger.error(f"Error al obtener registros de mantenimientos: {str(e)}")
            return []

    def registrar_mantenimiento(self, mantenimiento_data):
        """
        Registra un nuevo mantenimiento en la base de datos.
        
        Args:
            mantenimiento_data (dict): Datos del mantenimiento a registrar.
            
        Returns:
            bool: True si se registró correctamente, False en caso contrario.
            int: ID del mantenimiento agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Mantenimientos (id_maquinaria, tipo, fecha_realizada, 
                                         descripcion, costo_total, responsable, estado)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """
                
                # Preparar los valores para la inserción
                valores = (
                    mantenimiento_data['id_maquinaria'],
                    mantenimiento_data['tipo'],
                    mantenimiento_data.get('fecha_realizada'),
                    mantenimiento_data['descripcion'],
                    mantenimiento_data['costo_total'],
                    mantenimiento_data['responsable'],
                    mantenimiento_data['estado']
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del mantenimiento recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_mantenimiento = cursor.fetchone()[0]
                
                # Si el mantenimiento está completado y la maquinaria estaba en mantenimiento,
                # actualizar el estado de la maquinaria a operativo
                if mantenimiento_data['estado'] == 'Completado':
                    query_maquinaria = """
                    UPDATE Maquinaria 
                    SET estado = 'Operativo' 
                    WHERE id_maquinaria = ? AND estado = 'En mantenimiento'
                    """
                    cursor.execute(query_maquinaria, (mantenimiento_data['id_maquinaria'],))
                    conn.commit()
                
                # Si es un nuevo mantenimiento programado, actualizar el estado de la maquinaria
                elif mantenimiento_data['estado'] == 'Programado':
                    query_maquinaria = """
                    UPDATE Maquinaria 
                    SET estado = 'En mantenimiento' 
                    WHERE id_maquinaria = ?
                    """
                    cursor.execute(query_maquinaria, (mantenimiento_data['id_maquinaria'],))
                    conn.commit()
                
                logger.info(f"Mantenimiento registrado correctamente con ID: {id_mantenimiento}")
                return True, id_mantenimiento
        except Exception as e:
            logger.error(f"Error al registrar mantenimiento: {str(e)}")
            return False, None

    def actualizar_mantenimiento(self, id_mantenimiento, mantenimiento_data):
        """
        Actualiza un mantenimiento existente en la base de datos.
        
        Args:
            id_mantenimiento (int): ID del mantenimiento a actualizar.
            mantenimiento_data (dict): Datos actualizados del mantenimiento.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'id_maquinaria' in mantenimiento_data:
                    campos_actualizar.append("id_maquinaria = ?")
                    valores.append(mantenimiento_data['id_maquinaria'])
                    
                if 'tipo' in mantenimiento_data:
                    campos_actualizar.append("tipo = ?")
                    valores.append(mantenimiento_data['tipo'])
                    
                if 'fecha_realizada' in mantenimiento_data:
                    campos_actualizar.append("fecha_realizada = ?")
                    valores.append(mantenimiento_data['fecha_realizada'])
                    
                if 'descripcion' in mantenimiento_data:
                    campos_actualizar.append("descripcion = ?")
                    valores.append(mantenimiento_data['descripcion'])
                    
                if 'costo_total' in mantenimiento_data:
                    campos_actualizar.append("costo_total = ?")
                    valores.append(mantenimiento_data['costo_total'])
                    
                if 'responsable' in mantenimiento_data:
                    campos_actualizar.append("responsable = ?")
                    valores.append(mantenimiento_data['responsable'])
                    
                if 'estado' in mantenimiento_data:
                    campos_actualizar.append("estado = ?")
                    valores.append(mantenimiento_data['estado'])
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE Mantenimientos SET {', '.join(campos_actualizar)} WHERE id_mantenimiento = ?"
                valores.append(id_mantenimiento)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                
                # Si se cambió el estado a Completado, verificar si debemos actualizar el estado de la maquinaria
                if 'estado' in mantenimiento_data and mantenimiento_data['estado'] == 'Completado':
                    # Obtener el ID de la maquinaria
                    if 'id_maquinaria' in mantenimiento_data:
                        id_maquinaria = mantenimiento_data['id_maquinaria']
                    else:
                        query_get = "SELECT id_maquinaria FROM Mantenimientos WHERE id_mantenimiento = ?"
                        cursor.execute(query_get, (id_mantenimiento,))
                        row = cursor.fetchone()
                        id_maquinaria = row.id_maquinaria if row else None
                    
                    if id_maquinaria:
                        query_maquinaria = """
                        UPDATE Maquinaria 
                        SET estado = 'Operativo' 
                        WHERE id_maquinaria = ? AND estado = 'En mantenimiento'
                        """
                        cursor.execute(query_maquinaria, (id_maquinaria,))
                        conn.commit()
                
                logger.info(f"Mantenimiento actualizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar mantenimiento: {str(e)}")
            return False

    # Funciones para la gestión de compras de combustible
    def obtener_compras_combustible(self, filtro=None):
        """
        Obtiene los registros de compras de combustible de la base de datos.
        
        Args:
            filtro (dict, opcional): Filtros para la consulta (tipo_combustible, fecha_inicio, fecha_fin).
            
        Returns:
            list: Lista de diccionarios con la información de cada compra.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_compra, c.tipo_combustible, c.fecha_compra, c.cantidad, 
                       c.unidad_medida, c.precio_unitario, c.precio_total, c.proveedor,
                       c.responsable, u.nombre + ' ' + u.apellido AS nombre_responsable,
                       c.observaciones
                FROM ComprasCombustible c
                JOIN Usuarios u ON c.responsable = u.id_usuario
                """
                
                params = []
                where_clauses = []
                
                if filtro:
                    if 'tipo_combustible' in filtro and filtro['tipo_combustible']:
                        where_clauses.append("c.tipo_combustible = ?")
                        params.append(filtro['tipo_combustible'])
                    
                    if 'fecha_inicio' in filtro and filtro['fecha_inicio']:
                        where_clauses.append("c.fecha_compra >= ?")
                        params.append(filtro['fecha_inicio'])
                    
                    if 'fecha_fin' in filtro and filtro['fecha_fin']:
                        where_clauses.append("c.fecha_compra <= ?")
                        params.append(filtro['fecha_fin'])
                
                if where_clauses:
                    query += " WHERE " + " AND ".join(where_clauses)
                
                query += " ORDER BY c.fecha_compra DESC"
                
                cursor.execute(query, params)
                compras = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string
                    fecha_compra = row.fecha_compra.strftime('%Y-%m-%d') if row.fecha_compra else None
                    
                    compra = {
                        'id_compra': row.id_compra,
                        'tipo_combustible': row.tipo_combustible,
                        'fecha_compra': fecha_compra,
                        'cantidad': float(row.cantidad),
                        'unidad_medida': row.unidad_medida,
                        'precio_unitario': float(row.precio_unitario),
                        'precio_total': float(row.precio_total),
                        'proveedor': row.proveedor,
                        'responsable': row.responsable,
                        'nombre_responsable': row.nombre_responsable,
                        'observaciones': row.observaciones
                    }
                    compras.append(compra)
                
                logger.info(f"Se obtuvieron {len(compras)} registros de compras de combustible.")
                return compras
        except Exception as e:
            logger.error(f"Error al obtener registros de compras de combustible: {str(e)}")
            return []

    def registrar_compra_combustible(self, compra_data):
        """
        Registra una nueva compra de combustible en la base de datos.
        
        Args:
            compra_data (dict): Datos de la compra a registrar.
            
        Returns:
            bool: True si se registró correctamente, False en caso contrario.
            int: ID de la compra agregada o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO ComprasCombustible (tipo_combustible, fecha_compra, cantidad, 
                                             unidad_medida, precio_unitario, precio_total, 
                                             proveedor, responsable, observaciones)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                 # Calcular precio total si no se proporciona
                precio_total = compra_data.get('precio_total')
                if precio_total is None and 'cantidad' in compra_data and 'precio_unitario' in compra_data:
                    precio_total = float(compra_data['cantidad']) * float(compra_data['precio_unitario'])
                
                # Preparar los valores para la inserción
                valores = (
                    compra_data['tipo_combustible'],
                    compra_data.get('fecha_compra', datetime.now().date()),
                    compra_data['cantidad'],
                    compra_data['unidad_medida'],
                    compra_data['precio_unitario'],
                    precio_total,
                    compra_data.get('proveedor'),
                    compra_data['responsable'],
                    compra_data.get('observaciones')
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID de la compra recién insertada
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_compra = cursor.fetchone()[0]
                
                logger.info(f"Compra de combustible registrada correctamente con ID: {id_compra}")
                return True, id_compra
        except Exception as e:
            logger.error(f"Error al registrar compra de combustible: {str(e)}")
            return False, None

    def actualizar_compra_combustible(self, id_compra, compra_data):
        """
        Actualiza una compra de combustible existente en la base de datos.
        
        Args:
            id_compra (int): ID de la compra a actualizar.
            compra_data (dict): Datos actualizados de la compra.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'tipo_combustible' in compra_data:
                    campos_actualizar.append("tipo_combustible = ?")
                    valores.append(compra_data['tipo_combustible'])
                    
                if 'fecha_compra' in compra_data:
                    campos_actualizar.append("fecha_compra = ?")
                    valores.append(compra_data['fecha_compra'])
                    
                if 'cantidad' in compra_data:
                    campos_actualizar.append("cantidad = ?")
                    valores.append(compra_data['cantidad'])
                    
                if 'unidad_medida' in compra_data:
                    campos_actualizar.append("unidad_medida = ?")
                    valores.append(compra_data['unidad_medida'])
                    
                if 'precio_unitario' in compra_data:
                    campos_actualizar.append("precio_unitario = ?")
                    valores.append(compra_data['precio_unitario'])
                    
                # Calcular precio total si cambió cantidad o precio unitario
                if ('cantidad' in compra_data or 'precio_unitario' in compra_data) and 'precio_total' not in compra_data:
                    # Obtener los valores actuales
                    query_get = """
                    SELECT cantidad, precio_unitario 
                    FROM ComprasCombustible 
                    WHERE id_compra = ?
                    """
                    cursor.execute(query_get, (id_compra,))
                    row = cursor.fetchone()
                    
                    if row:
                        cantidad = compra_data.get('cantidad', row.cantidad)
                        precio_unitario = compra_data.get('precio_unitario', row.precio_unitario)
                        precio_total = float(cantidad) * float(precio_unitario)
                        
                        campos_actualizar.append("precio_total = ?")
                        valores.append(precio_total)
                elif 'precio_total' in compra_data:
                    campos_actualizar.append("precio_total = ?")
                    valores.append(compra_data['precio_total'])
                    
                if 'proveedor' in compra_data:
                    campos_actualizar.append("proveedor = ?")
                    valores.append(compra_data['proveedor'])
                    
                if 'responsable' in compra_data:
                    campos_actualizar.append("responsable = ?")
                    valores.append(compra_data['responsable'])
                    
                if 'observaciones' in compra_data:
                    campos_actualizar.append("observaciones = ?")
                    valores.append(compra_data['observaciones'])
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE ComprasCombustible SET {', '.join(campos_actualizar)} WHERE id_compra = ?"
                valores.append(id_compra)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Compra de combustible actualizada correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar compra de combustible: {str(e)}")
            return False

    def eliminar_compra_combustible(self, id_compra):
        """
        Elimina una compra de combustible de la base de datos.
        
        Args:
            id_compra (int): ID de la compra a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM ComprasCombustible WHERE id_compra = ?"
                cursor.execute(query, (id_compra,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Compra de combustible eliminada correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar compra de combustible: {str(e)}")
            return False

    def obtener_resumen_combustible(self, periodo='mes'):
        """
        Obtiene un resumen del consumo de combustible para un período de tiempo.
        
        Args:
            periodo (str): Período de tiempo ('mes', 'trimestre', 'año').
            
        Returns:
            dict: Diccionario con el resumen de combustible por tipo.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Definir el filtro de fechas según el período
                fecha_inicio = None
                if periodo == 'mes':
                    fecha_inicio = "DATEADD(month, -1, GETDATE())"
                elif periodo == 'trimestre':
                    fecha_inicio = "DATEADD(month, -3, GETDATE())"
                elif periodo == 'año':
                    fecha_inicio = "DATEADD(year, -1, GETDATE())"
                else:
                    # Por defecto, usar el último mes
                    fecha_inicio = "DATEADD(month, -1, GETDATE())"
                
                # Consulta para obtener el total de combustible comprado por tipo
                query = f"""
                SELECT tipo_combustible, 
                       SUM(cantidad) as total_cantidad,
                       SUM(precio_total) as total_costo
                FROM ComprasCombustible
                WHERE fecha_compra >= {fecha_inicio}
                GROUP BY tipo_combustible
                """
                
                cursor.execute(query)
                
                resumen = {}
                for row in cursor.fetchall():
                    resumen[row.tipo_combustible] = {
                        'total_cantidad': float(row.total_cantidad),
                        'total_costo': float(row.total_costo)
                    }
                
                # Consulta para obtener el total de combustible consumido por tipo
                query_consumo = f"""
                SELECT m.tipo_combustible, 
                       SUM(um.combustible_consumido) as total_consumido
                FROM UsoMaquinaria um
                JOIN Maquinaria m ON um.id_maquinaria = m.id_maquinaria
                WHERE um.fecha_inicio >= {fecha_inicio}
                  AND um.combustible_consumido IS NOT NULL
                GROUP BY m.tipo_combustible
                """
                
                cursor.execute(query_consumo)
                
                for row in cursor.fetchall():
                    if row.tipo_combustible in resumen:
                        resumen[row.tipo_combustible]['total_consumido'] = float(row.total_consumido)
                    else:
                        resumen[row.tipo_combustible] = {
                            'total_cantidad': 0,
                            'total_costo': 0,
                            'total_consumido': float(row.total_consumido)
                        }
                
                logger.info(f"Se generó el resumen de combustible para el período: {periodo}")
                return resumen
        except Exception as e:
            logger.error(f"Error al obtener resumen de combustible: {str(e)}")
            return {}

