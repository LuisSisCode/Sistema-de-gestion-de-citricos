import pyodbc
import logging
from .nucleo.bd_connection import DatabaseConnection
from datetime import datetime
from .nucleo.cache_system import cacheable, cache_invalidator, get_ttl
# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_maquinaria')

# Metodo para corregir los errores de las fechas
def formatear_fecha_segura(fecha_obj, formato='%Y-%m-%d'):
    """
    Formatea una fecha de manera segura, manejando tanto objetos datetime como strings.
    
    Args:
        fecha_obj: Objeto fecha que puede ser datetime, date, string o None
        formato: Formato de salida deseado
        
    Returns:
        str: Fecha formateada como string o None si no hay fecha
    """
    if fecha_obj is None:
        return None
    
    # Si ya es un string, devolverlo tal como está (asumiendo que está bien formateado)
    if isinstance(fecha_obj, str):
        try:
            # Intentar parsear el string para validar que es una fecha válida
            if len(fecha_obj) == 10:  # Formato YYYY-MM-DD
                datetime.strptime(fecha_obj, '%Y-%m-%d')
                return fecha_obj if formato == '%Y-%m-%d' else datetime.strptime(fecha_obj, '%Y-%m-%d').strftime(formato)
            elif len(fecha_obj) == 19:  # Formato YYYY-MM-DD HH:MM:SS
                datetime.strptime(fecha_obj, '%Y-%m-%d %H:%M:%S')
                return fecha_obj if formato == '%Y-%m-%d %H:%M:%S' else datetime.strptime(fecha_obj, '%Y-%m-%d %H:%M:%S').strftime(formato)
            else:
                # Intentar parsearlo automáticamente
                fecha_parseada = datetime.fromisoformat(fecha_obj.replace('Z', '+00:00'))
                return fecha_parseada.strftime(formato)
        except (ValueError, AttributeError):
            logger.warning(f"No se pudo parsear la fecha string: {fecha_obj}")
            return str(fecha_obj)
    
    # Si es un objeto datetime o date, usar strftime
    if hasattr(fecha_obj, 'strftime'):
        try:
            return fecha_obj.strftime(formato)
        except (ValueError, AttributeError) as e:
            logger.warning(f"Error al formatear fecha {fecha_obj}: {e}")
            return str(fecha_obj)
    
    # Si no sabemos qué es, convertir a string
    logger.warning(f"Tipo de fecha desconocido: {type(fecha_obj)} - {fecha_obj}")
    return str(fecha_obj)

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
    def formatear_fecha_segura(self, fecha_obj, formato='%Y-%m-%d'):
        """Versión mejorada para manejar DATE correctamente"""
        if fecha_obj is None:
            return None
        
        # Si es string y está vacío
        if isinstance(fecha_obj, str) and not fecha_obj.strip():
            return None
        
        # Si ya es un string en formato DATE
        if isinstance(fecha_obj, str) and len(fecha_obj) == 10 and fecha_obj.count('-') == 2:
            try:
                datetime.strptime(fecha_obj, '%Y-%m-%d')  # Validar formato
                return fecha_obj
            except ValueError:
                pass
        
        # Si es datetime.date o datetime.datetime
        if hasattr(fecha_obj, 'strftime'):
            return fecha_obj.strftime(formato)
        
        # Para otros casos (enteros, objetos fecha de otros tipos)
        try:
            return datetime.fromisoformat(str(fecha_obj)).strftime(formato)
        except:
            logger.warning(f"Formato de fecha no reconocido: {fecha_obj}")
            return None
    @cacheable('maquinaria', ttl=get_ttl('maquinaria'))
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
                
                logger.info("=== OBTENIENDO MAQUINARIA DESDE BD ===")
                
                for row in cursor.fetchall():
                    # ✅ CONVERSIÓN EXPLÍCITA del campo 'activo'
                    # En SQL Server, BIT puede devolver 1/0, True/False, o otros tipos
                    activo_raw = row.activo
                    activo_procesado = bool(activo_raw) if activo_raw is not None else True
                    
                    maquinaria = {
                        'id_maquinaria': int(row.id_maquinaria) if row.id_maquinaria else 0,
                        'codigo': str(row.codigo) if row.codigo else "",
                        'nombre': str(row.nombre) if row.nombre else "",
                        'tipo': str(row.tipo) if row.tipo else "",
                        'marca': str(row.marca) if row.marca else "",
                        'tipo_combustible': str(row.tipo_combustible) if row.tipo_combustible else "",
                        'estado': str(row.estado) if row.estado else "Operativo",
                        'ubicacion_actual': str(row.ubicacion_actual) if row.ubicacion_actual else "",
                        'activo': activo_procesado  # ✅ Asegurar que sea booleano
                    }
                    
                    logger.info(f"Equipo procesado: {maquinaria['codigo']} - activo: {activo_raw} → {activo_procesado} (tipo: {type(activo_procesado)})")
                    maquinarias.append(maquinaria)
                
                # ✅ ESTADÍSTICAS DE DEPURACIÓN
                total_equipos = len(maquinarias)
                equipos_activos = sum(1 for m in maquinarias if m['activo'])
                equipos_inactivos = total_equipos - equipos_activos
                
                logger.info(f"📊 ESTADÍSTICAS BD:")
                logger.info(f"  Total equipos: {total_equipos}")
                logger.info(f"  Equipos activos: {equipos_activos}")
                logger.info(f"  Equipos inactivos: {equipos_inactivos}")
                
                # Mostrar algunos ejemplos
                logger.info("📊 EJEMPLOS (primeros 3 equipos):")
                for i, maquina in enumerate(maquinarias[:3]):
                    logger.info(f"  {i+1}. {maquina['codigo']} - {maquina['nombre']} - activo: {maquina['activo']} - estado: {maquina['estado']}")
                
                logger.info(f"✅ Se obtuvieron {len(maquinarias)} equipos de maquinaria de la base de datos.")
                return maquinarias
                
        except Exception as e:
            logger.error(f"❌ Error al obtener maquinaria: {str(e)}")
            logger.error(f"Tipo de error: {type(e).__name__}")
            import traceback
            logger.error(f"Traceback: {traceback.format_exc()}")
            return []

    @cache_invalidator('maquinaria')
    @cache_invalidator('estadisticas')
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
    @cache_invalidator('maquinaria')
    @cache_invalidator('estadisticas')
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
    @cache_invalidator('maquinaria')
    @cache_invalidator('estadisticas')
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
    @cache_invalidator('maquinaria')
    @cache_invalidator('estadisticas')
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
        
    def verificar_estructura_bd(self):
        """
        Función de diagnóstico para verificar la estructura de la tabla Maquinaria.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Obtener información de columnas
                query_info = """
                SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_NAME = 'Maquinaria'
                ORDER BY ORDINAL_POSITION
                """
                
                cursor.execute(query_info)
                logger.info("=== ESTRUCTURA TABLA MAQUINARIA ===")
                
                for row in cursor.fetchall():
                    logger.info(f"Columna: {row.COLUMN_NAME} | Tipo: {row.DATA_TYPE} | Nullable: {row.IS_NULLABLE} | Default: {row.COLUMN_DEFAULT}")
                
                # Obtener algunos registros de ejemplo
                query_sample = "SELECT TOP 5 * FROM Maquinaria"
                cursor.execute(query_sample)
                
                logger.info("=== REGISTROS DE EJEMPLO ===")
                for i, row in enumerate(cursor.fetchall()):
                    logger.info(f"Registro {i+1}:")
                    logger.info(f"  id_maquinaria: {row.id_maquinaria} (tipo: {type(row.id_maquinaria)})")
                    logger.info(f"  codigo: {row.codigo} (tipo: {type(row.codigo)})")
                    logger.info(f"  activo: {row.activo} (tipo: {type(row.activo)})")
                    logger.info(f"  estado: {row.estado} (tipo: {type(row.estado)})")
                
                logger.info("=== FIN VERIFICACIÓN ===")
                
        except Exception as e:
            logger.error(f"❌ Error al verificar estructura BD: {str(e)}")
    @cacheable('uso_maquinaria', key_func=lambda id_maq=None: f"usos_{id_maq or 'todos'}", ttl=600)
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
                    fecha_inicio = formatear_fecha_segura(row.fecha_inicio, '%Y-%m-%d %H:%M:%S')
                    fecha_fin = formatear_fecha_segura(row.fecha_fin, '%Y-%m-%d %H:%M:%S')
                    
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
    @cache_invalidator('uso_maquinaria')
    @cache_invalidator('estadisticas')
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
    @cache_invalidator('uso_maquinaria')
    @cache_invalidator('estadisticas')
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
    @cacheable('mantenimientos', key_func=lambda id_maq=None: f"mant_{id_maq or 'todos'}", ttl=900)
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
                    fecha_realizada = formatear_fecha_segura(row.fecha_realizada, '%Y-%m-%d')
                    
                    mantenimiento = {
                        'id_mantenimiento': row.id_mantenimiento,
                        'id_maquinaria': row.id_maquinaria,
                        'nombre_maquinaria': row.nombre_maquinaria,
                        'tipo': row.tipo,
                        'fecha_realizada': fecha_realizada,
                        'descripcion': row.descripcion,
                        'costo_total': float(row.costo_total) if row.costo_total is not None else 0.0,
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
    @cache_invalidator('mantenimientos')
    @cache_invalidator('maquinaria')  # Mantenimientos pueden cambiar estado de maquinaria
    @cache_invalidator('estadisticas')
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
            logger.info("=== REGISTRAR MANTENIMIENTO CON GESTIÓN DE ESTADOS ===")
            logger.info(f"Datos recibidos: {mantenimiento_data}")
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Obtener el estado actual de la maquinaria
                id_maquinaria = int(mantenimiento_data['id_maquinaria'])
                query_estado = "SELECT estado FROM Maquinaria WHERE id_maquinaria = ?"
                cursor.execute(query_estado, (id_maquinaria,))
                row = cursor.fetchone()
                estado_actual = row.estado if row else "Operativo"
                
                logger.info(f"Estado actual de la maquinaria: {estado_actual}")
                
                # Insertar el mantenimiento
                query = """
                INSERT INTO Mantenimientos (id_maquinaria, tipo, fecha_realizada, 
                                        descripcion, costo_total, responsable, estado)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """
                
                tipo = str(mantenimiento_data['tipo'])
                descripcion = str(mantenimiento_data['descripcion'])
                costo_total = mantenimiento_data.get('costo_total')
                if costo_total is None or costo_total == "":
                    costo_total = None  # ← NULL en BD
                else:
                    costo_total = float(costo_total)
                responsable = int(mantenimiento_data['responsable'])
                estado_mantenimiento = str(mantenimiento_data['estado'])
                
                # Manejo de fecha
                fecha_realizada = mantenimiento_data.get('fecha_realizada')
                if not fecha_realizada or (isinstance(fecha_realizada, str) and fecha_realizada.strip() == ""):
                    fecha_realizada = None
                
                valores = (
                    id_maquinaria, tipo, fecha_realizada, descripcion, 
                    costo_total, responsable, estado_mantenimiento
                )
                
                cursor.execute(query, valores)
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_mantenimiento = cursor.fetchone()[0]
                
                # ✅ NUEVA LÓGICA DE GESTIÓN DE ESTADOS
                nuevo_estado_maquinaria = None
                
                if estado_mantenimiento == 'Completado':
                    # Si el mantenimiento se completa, determinar el nuevo estado
                    if estado_actual in ['En mantenimiento', 'Fuera de servicio']:
                        nuevo_estado_maquinaria = 'Operativo'
                        logger.info(f"Mantenimiento completado: {estado_actual} → Operativo")
                        
                elif estado_mantenimiento == 'Programado':
                    # Si es un nuevo mantenimiento programado
                    if estado_actual == 'Operativo':
                        nuevo_estado_maquinaria = 'En mantenimiento'
                        logger.info(f"Mantenimiento programado: Operativo → En mantenimiento")
                    # Si ya está "Fuera de servicio", mantener ese estado
                    elif estado_actual == 'Fuera de servicio':
                        logger.info("Maquinaria fuera de servicio permanece así hasta completar mantenimiento")
                
                # Actualizar estado de la maquinaria si es necesario
                if nuevo_estado_maquinaria:
                    query_update = "UPDATE Maquinaria SET estado = ? WHERE id_maquinaria = ?"
                    cursor.execute(query_update, (nuevo_estado_maquinaria, id_maquinaria))
                    logger.info(f"Estado de maquinaria actualizado a: {nuevo_estado_maquinaria}")
                
                conn.commit()
                logger.info(f"✅ Mantenimiento registrado con ID: {id_mantenimiento}")
                return True, id_mantenimiento
                
        except Exception as e:
            logger.error(f"❌ Error al registrar mantenimiento: {str(e)}")
            return False, None
    @cache_invalidator('mantenimientos')
    @cache_invalidator('maquinaria')
    @cache_invalidator('estadisticas')
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
            logger.info("=== ACTUALIZAR MANTENIMIENTO CON GESTIÓN DE ESTADOS ===")
            logger.info(f"ID: {id_mantenimiento}, Datos: {mantenimiento_data}")
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Obtener datos actuales del mantenimiento y maquinaria
                query_actual = """
                SELECT m.estado as estado_mantenimiento, m.id_maquinaria, 
                    maq.estado as estado_maquinaria
                FROM Mantenimientos m
                JOIN Maquinaria maq ON m.id_maquinaria = maq.id_maquinaria
                WHERE m.id_mantenimiento = ?
                """
                cursor.execute(query_actual, (id_mantenimiento,))
                row = cursor.fetchone()
                
                if not row:
                    logger.error("Mantenimiento no encontrado")
                    return False
                    
                estado_actual_mantenimiento = row.estado_mantenimiento
                id_maquinaria = row.id_maquinaria
                estado_actual_maquinaria = row.estado_maquinaria
                
                logger.info(f"Estados actuales - Mantenimiento: {estado_actual_mantenimiento}, Maquinaria: {estado_actual_maquinaria}")
                
                # Construir consulta de actualización
                campos_actualizar = []
                valores = []
                
                for campo in ['id_maquinaria', 'tipo', 'descripcion', 'costo_total', 'responsable', 'estado']:
                    if campo in mantenimiento_data:
                        if campo == 'costo_total':
                            costo_valor = mantenimiento_data[campo]
                            campos_actualizar.append(f"{campo} = ?")
                            if costo_valor is None or costo_valor == "":
                                valores.append(None)  # ← NULL en BD
                            else:
                                valores.append(float(costo_valor))
                        elif campo in ['id_maquinaria', 'responsable']:
                            campos_actualizar.append(f"{campo} = ?")
                            valores.append(int(mantenimiento_data[campo]))
                        else:
                            campos_actualizar.append(f"{campo} = ?")
                            valores.append(str(mantenimiento_data[campo]))
                
                # Manejo especial de fecha
                if 'fecha_realizada' in mantenimiento_data:
                    fecha = mantenimiento_data['fecha_realizada']
                    if fecha is None or (isinstance(fecha, str) and fecha.strip() == ""):
                        campos_actualizar.append("fecha_realizada = ?")
                        valores.append(None)
                    else:
                        campos_actualizar.append("fecha_realizada = ?")
                        valores.append(str(fecha))
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                # Actualizar mantenimiento
                query = f"UPDATE Mantenimientos SET {', '.join(campos_actualizar)} WHERE id_mantenimiento = ?"
                valores.append(int(id_mantenimiento))
                cursor.execute(query, valores)
                
                # ✅ LÓGICA MEJORADA DE CAMBIO DE ESTADO
                nuevo_estado_mantenimiento = mantenimiento_data.get('estado', estado_actual_mantenimiento)
                
                # Determinar si necesitamos cambiar el estado de la maquinaria
                nuevo_estado_maquinaria = None
                
                if (estado_actual_mantenimiento != 'Completado' and 
                    nuevo_estado_mantenimiento == 'Completado'):
                    # El mantenimiento se acaba de completar
                    if estado_actual_maquinaria in ['En mantenimiento', 'Fuera de servicio']:
                        # Solo cambiar a Operativo si no hay otros mantenimientos pendientes
                        query_pendientes = """
                        SELECT COUNT(*) as pendientes
                        FROM Mantenimientos 
                        WHERE id_maquinaria = ? AND estado = 'Programado' AND id_mantenimiento != ?
                        """
                        cursor.execute(query_pendientes, (id_maquinaria, id_mantenimiento))
                        pendientes = cursor.fetchone().pendientes
                        
                        if pendientes == 0:
                            nuevo_estado_maquinaria = 'Operativo'
                            logger.info("No hay mantenimientos pendientes → Maquinaria pasa a Operativo")
                        else:
                            logger.info(f"Hay {pendientes} mantenimientos pendientes → Maquinaria sigue en mantenimiento")
                            
                elif (estado_actual_mantenimiento == 'Completado' and 
                    nuevo_estado_mantenimiento == 'Programado'):
                    # El mantenimiento se vuelve a programar
                    if estado_actual_maquinaria == 'Operativo':
                        nuevo_estado_maquinaria = 'En mantenimiento'
                        logger.info("Mantenimiento reprogramado → Maquinaria pasa a En mantenimiento")
                
                # Actualizar estado de maquinaria si es necesario
                if nuevo_estado_maquinaria:
                    query_update_maq = "UPDATE Maquinaria SET estado = ? WHERE id_maquinaria = ?"
                    cursor.execute(query_update_maq, (nuevo_estado_maquinaria, id_maquinaria))
                    logger.info(f"Estado de maquinaria actualizado: {estado_actual_maquinaria} → {nuevo_estado_maquinaria}")
                
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"✅ Mantenimiento actualizado. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"❌ Error al actualizar mantenimiento: {str(e)}")
            return False
    @cache_invalidator('maquinaria')
    def cambiar_estado_maquinaria(self, id_maquinaria, nuevo_estado):
        """
        Cambia el estado de una maquinaria con validaciones.
        
        Args:
            id_maquinaria (int): ID de la maquinaria
            nuevo_estado (str): Nuevo estado ('Operativo', 'En mantenimiento', 'Fuera de servicio')
        
        Returns:
            bool: True si se cambió correctamente
        """
        try:
            logger.info(f"=== CAMBIO DE ESTADO MAQUINARIA ===")
            logger.info(f"ID: {id_maquinaria}, Nuevo estado: {nuevo_estado}")
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Obtener estado actual
                query_actual = """
                SELECT codigo, nombre, estado, activo 
                FROM Maquinaria 
                WHERE id_maquinaria = ?
                """
                cursor.execute(query_actual, (id_maquinaria,))
                row = cursor.fetchone()
                
                if not row:
                    logger.error(f"❌ Maquinaria {id_maquinaria} no encontrada")
                    return False
                
                estado_actual = row.estado
                activo_actual = bool(row.activo)
                
                logger.info(f"Estado actual: {estado_actual} | Activo: {activo_actual}")
                logger.info(f"Cambio solicitado: {estado_actual} → {nuevo_estado}")
                
                # Validaciones específicas
                if nuevo_estado == 'Operativo':
                    # Verificar que no haya mantenimientos pendientes
                    query_pendientes = """
                    SELECT COUNT(*) as pendientes 
                    FROM Mantenimientos 
                    WHERE id_maquinaria = ? AND estado = 'Programado'
                    """
                    cursor.execute(query_pendientes, (id_maquinaria,))
                    pendientes = cursor.fetchone().pendientes
                    
                    if pendientes > 0:
                        logger.warning(f"❌ No se puede poner en Operativo: hay {pendientes} mantenimientos pendientes")
                        return False
                
                # Actualizar estado
                query_update = "UPDATE Maquinaria SET estado = ? WHERE id_maquinaria = ?"
                cursor.execute(query_update, (nuevo_estado, id_maquinaria))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"✅ Estado actualizado. Filas afectadas: {filas_afectadas}")
                
                if filas_afectadas > 0:
                    logger.info(f"✅ Maquinaria {row.codigo} - {row.nombre}: {estado_actual} → {nuevo_estado}")
                    return True
                else:
                    logger.warning(f"⚠️ No se actualizó ninguna fila")
                    return False
                
        except Exception as e:
            logger.error(f"❌ Error al cambiar estado de maquinaria: {str(e)}")
            return False

    # Funciones para la gestión de compras de combustible
    @cacheable('combustible', key_func=lambda filtro=None: f"combustible_{hash(str(filtro))}", ttl=600)
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
                    fecha_compra = formatear_fecha_segura(row.fecha_compra, '%Y-%m-%d')
                    
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
    @cache_invalidator('combustible')
    @cache_invalidator('estadisticas')
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
            # ✅ LOGGING INICIAL DETALLADO
            logger.info("=== INICIO REGISTRO COMPRA COMBUSTIBLE ===")
            logger.info(f"Datos recibidos RAW: {compra_data}")
            logger.info(f"Tipo de datos recibidos: {type(compra_data)}")
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # ✅ PROCESAMIENTO Y VALIDACIÓN STEP BY STEP
                
                # 1. Tipo de combustible
                tipo_combustible = str(compra_data.get('tipo_combustible', '')).strip()
                logger.info(f"1. Tipo combustible: '{tipo_combustible}' (tipo: {type(tipo_combustible)})")
                if not tipo_combustible:
                    raise ValueError("Tipo de combustible es obligatorio")
                
                # 2. Fecha
                fecha_compra = compra_data.get('fecha_compra')
                if fecha_compra is None:
                    fecha_compra = datetime.now().strftime('%Y-%m-%d')
                elif isinstance(fecha_compra, str):
                    try:
                        if len(fecha_compra) == 10:  # YYYY-MM-DD
                            datetime.strptime(fecha_compra, '%Y-%m-%d')  # Solo validar
                        else:
                            fecha_compra = datetime.now().strftime('%Y-%m-%d')
                    except:
                        fecha_compra = datetime.now().strftime('%Y-%m-%d')
                else:
                    # Convertir datetime.date a string
                    fecha_compra = fecha_compra.strftime('%Y-%m-%d')
                logger.info(f"2. Fecha procesada: {fecha_compra} (tipo: {type(fecha_compra)})")
                
                # 3. Cantidad
                try:
                    cantidad_raw = compra_data.get('cantidad', 0)
                    logger.info(f"3a. Cantidad RAW: {cantidad_raw} (tipo: {type(cantidad_raw)})")
                    
                    if isinstance(cantidad_raw, str):
                        # Limpiar string y convertir
                        cantidad_clean = cantidad_raw.replace(',', '.').strip()
                        cantidad = float(cantidad_clean)
                    else:
                        cantidad = float(cantidad_raw)
                        
                    logger.info(f"3b. Cantidad procesada: {cantidad}")
                    
                    if cantidad <= 0:
                        raise ValueError(f"Cantidad debe ser mayor a 0, recibido: {cantidad}")
                        
                except Exception as e:
                    logger.error(f"Error procesando cantidad: {e}")
                    raise ValueError(f"Cantidad inválida: {compra_data.get('cantidad')}")
                
                # 4. Unidad de medida
                unidad_medida = str(compra_data.get('unidad_medida', 'Litros')).strip()
                logger.info(f"4. Unidad medida: '{unidad_medida}'")
                
                # 5. Precio unitario
                try:
                    precio_raw = compra_data.get('precio_unitario', 0)
                    logger.info(f"5a. Precio unitario RAW: {precio_raw} (tipo: {type(precio_raw)})")
                    
                    if isinstance(precio_raw, str):
                        # Manejar notación científica y decimales
                        precio_clean = precio_raw.replace(',', '.').strip()
                        precio_unitario = float(precio_clean)
                    else:
                        precio_unitario = float(precio_raw)
                        
                    logger.info(f"5b. Precio unitario procesado: {precio_unitario}")
                    
                    if precio_unitario <= 0:
                        raise ValueError(f"Precio unitario debe ser mayor a 0, recibido: {precio_unitario}")
                        
                except Exception as e:
                    logger.error(f"Error procesando precio unitario: {e}")
                    raise ValueError(f"Precio unitario inválido: {compra_data.get('precio_unitario')}")
                
                # 6. Precio total (calcular o usar el proporcionado)
                precio_total_raw = compra_data.get('precio_total')
                if precio_total_raw is not None:
                    try:
                        if isinstance(precio_total_raw, str):
                            precio_total = float(precio_total_raw.replace(',', '.').strip())
                        else:
                            precio_total = float(precio_total_raw)
                    except:
                        precio_total = cantidad * precio_unitario
                else:
                    precio_total = cantidad * precio_unitario
                
                logger.info(f"6. Precio total: {precio_total}")
                
                # 7. Proveedor (opcional)
                proveedor = str(compra_data.get('proveedor', '')).strip()
                if len(proveedor) > 100:  # Limitar longitud
                    proveedor = proveedor[:100]
                logger.info(f"7. Proveedor: '{proveedor}' (longitud: {len(proveedor)})")
                
                # 8. Responsable
                try:
                    responsable_raw = compra_data.get('responsable', 1)
                    responsable = int(responsable_raw)
                    logger.info(f"8. Responsable: {responsable} (tipo: {type(responsable)})")
                    
                    if responsable <= 0:
                        raise ValueError(f"Responsable debe ser un ID válido, recibido: {responsable}")
                        
                except Exception as e:
                    logger.error(f"Error procesando responsable: {e}")
                    raise ValueError(f"Responsable inválido: {compra_data.get('responsable')}")
                
                # 9. Observaciones (opcional) - NUNCA ENVIAR None
                observaciones = str(compra_data.get('observaciones', '')).strip()
                if len(observaciones) > 500:
                    observaciones = observaciones[:500]
                # ASEGURAR QUE NUNCA SEA None
                if not observaciones:
                    observaciones = ''
                logger.info(f"9. Observaciones: '{observaciones[:50]}...' (longitud: {len(observaciones)})")
                
                # ✅ PREPARAR QUERY E INSERCIÓN
                query = """
                INSERT INTO ComprasCombustible 
                (tipo_combustible, fecha_compra, cantidad, unidad_medida, 
                precio_unitario, precio_total, proveedor, responsable, observaciones)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    tipo_combustible,    # VARCHAR
                    fecha_compra,        # DATE
                    cantidad,            # DECIMAL
                    unidad_medida,       # VARCHAR
                    precio_unitario,     # DECIMAL
                    precio_total,        # DECIMAL
                    proveedor if proveedor else "",     # VARCHAR (puede ser NULL)
                    responsable,         # INT
                    observaciones if observaciones else None  # TEXT (puede ser NULL)
                )
                
                # ✅ LOGGING FINAL DE VALORES
                logger.info("=== VALORES FINALES PARA INSERCIÓN ===")
                for i, valor in enumerate(valores):
                    logger.info(f"  Parámetro {i+1}: {repr(valor)} (tipo: {type(valor)})")
                
                logger.info(f"Query a ejecutar: {query}")
                
                # ✅ EJECUTAR INSERCIÓN
                cursor.execute(query, valores)
                
                # Obtener ID antes del commit
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_compra = cursor.fetchone()[0]
                
                # Commit de la transacción
                conn.commit()
                
                logger.info(f"✅ ÉXITO: Compra registrada con ID: {id_compra}")
                logger.info("=== FIN REGISTRO COMPRA COMBUSTIBLE ===")
                
                return True, id_compra
                
        except Exception as e:
            logger.error("=== ERROR EN REGISTRO COMPRA COMBUSTIBLE ===")
            logger.error(f"Tipo de error: {type(e).__name__}")
            logger.error(f"Mensaje de error: {str(e)}")
            logger.error(f"Datos que causaron el error: {compra_data}")
            
            # Si es un error específico de pyodbc, loggear detalles adicionales
            if hasattr(e, 'args') and len(e.args) > 0:
                logger.error(f"Código de error: {e.args[0] if len(e.args) > 0 else 'N/A'}")
                logger.error(f"Mensaje detallado: {e.args[1] if len(e.args) > 1 else 'N/A'}")
                
            logger.error("=== FIN ERROR ===")
            return False, None
    @cache_invalidator('combustible')
    @cache_invalidator('estadisticas')
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
    @cache_invalidator('combustible')
    @cache_invalidator('estadisticas')
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
    @cacheable('resumen_combustible', key_func=lambda periodo: f"resumen_{periodo}", ttl=600)
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
                    SUM(COALESCE(um.combustible_consumido, 0)) as total_consumido
                FROM UsoMaquinaria um
                JOIN Maquinaria m ON um.id_maquinaria = m.id_maquinaria
                WHERE um.fecha_inicio >= {fecha_inicio}
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

