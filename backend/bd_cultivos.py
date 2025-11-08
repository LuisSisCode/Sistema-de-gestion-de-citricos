# Base de datos para la gestión de cultivos, variedades y ciclos de producción
import pyodbc
import logging
from .core.database import DatabaseConnection
from datetime import datetime

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_cultivos')

class GestorCultivos:
    def __init__(self, server=None, database=None, trusted_connection=False):
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
                
        except Exception as e:
            logger.error(f"Error al establecer la conexión a la base de datos: {str(e)}")
            raise

    def obtener_tipos_cultivo(self):
        """
        Obtiene todos los tipos de cultivo de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada tipo de cultivo.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_tipo_cultivo, nombre, nombre_cientifico, descripcion, 
                       tiempo_cosecha_min, tiempo_cosecha_max, activo
                FROM TiposCultivo
                ORDER BY nombre
                """
                
                cursor.execute(query)
                tipos_cultivo = []
                
                for row in cursor.fetchall():
                    tipo = {
                        'id_tipo_cultivo': row.id_tipo_cultivo,
                        'nombre': row.nombre,
                        'nombre_cientifico': row.nombre_cientifico,
                        'descripcion': row.descripcion,
                        'tiempo_cosecha_min': row.tiempo_cosecha_min,
                        'tiempo_cosecha_max': row.tiempo_cosecha_max,
                        'activo': bool(row.activo)
                    }
                    tipos_cultivo.append(tipo)
                
                logger.info(f"Se obtuvieron {len(tipos_cultivo)} tipos de cultivo de la base de datos.")
                return tipos_cultivo
        except Exception as e:
            logger.error(f"Error al obtener tipos de cultivo: {str(e)}")
            return []

    def obtener_variedades_cultivo(self, id_tipo_cultivo=None):
        """
        Obtiene las variedades de cultivo, opcionalmente filtradas por tipo de cultivo.
        
        Args:
            id_tipo_cultivo (int, optional): ID del tipo de cultivo para filtrar. Si es None, 
                                            se obtienen todas las variedades.
        
        Returns:
            list: Lista de diccionarios con la información de cada variedad.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                if id_tipo_cultivo:
                    query = """
                    SELECT v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
                           v.resistencia_zona, v.activo,
                           t.nombre AS nombre_tipo_cultivo
                    FROM VariedadesCultivo v
                    JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
                    WHERE v.id_tipo_cultivo = ?
                    ORDER BY v.nombre
                    """
                    cursor.execute(query, (id_tipo_cultivo,))
                else:
                    query = """
                    SELECT v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
                           v.resistencia_zona, v.activo,
                           t.nombre AS nombre_tipo_cultivo
                    FROM VariedadesCultivo v
                    JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
                    ORDER BY t.nombre, v.nombre
                    """
                    cursor.execute(query)
                
                variedades = []
                
                for row in cursor.fetchall():
                    variedad = {
                        'id_variedad': row.id_variedad,
                        'id_tipo_cultivo': row.id_tipo_cultivo,
                        'nombre': row.nombre,
                        'tiempo_produccion': row.tiempo_produccion,
                        'resistencia_zona': row.resistencia_zona,
                        'activo': bool(row.activo),
                        'nombre_tipo_cultivo': row.nombre_tipo_cultivo
                    }
                    variedades.append(variedad)
                
                logger.info(f"Se obtuvieron {len(variedades)} variedades de cultivo.")
                return variedades
        except Exception as e:
            logger.error(f"Error al obtener variedades de cultivo: {str(e)}")
            return []

    def obtener_ciclos_produccion(self, id_parcela=None, filtro_estado=None):
        """
        Obtiene los ciclos de producción, opcionalmente filtrados por parcela y/o estado.
        
        Args:
            id_parcela (int, optional): ID de la parcela para filtrar.
            filtro_estado (str, optional): Estado de los ciclos para filtrar.
        
        Returns:
            list: Lista de diccionarios con la información de cada ciclo de producción.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Base query
                query = """
                SELECT c.id_ciclo, c.id_parcela, c.id_variedad, c.fecha_siembra, 
                       c.fecha_cosecha_estimada, c.fecha_cosecha_real, c.area_sembrada,
                       c.densidad_siembra, c.estado, c.activo,
                       c.fecha_floracion, c.fecha_poda, c.fecha_limpieza, c.frecuencia_limpieza,
                       p.nombre AS nombre_parcela, 
                       v.nombre AS nombre_variedad,
                       t.nombre AS nombre_tipo_cultivo
                FROM CiclosProduccion c
                JOIN Parcelas p ON c.id_parcela = p.id_parcela
                JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
                JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
                """

                # Aplicar filtros
                where_clauses = []
                params = []
                
                if id_parcela:
                    where_clauses.append("c.id_parcela = ?")
                    params.append(id_parcela)
                
                if filtro_estado:
                    where_clauses.append("c.estado = ?")
                    params.append(filtro_estado)
                
                # Añadir cláusulas WHERE si es necesario
                if where_clauses:
                    query += " WHERE " + " AND ".join(where_clauses)
                
                query += " ORDER BY c.fecha_siembra DESC"
                
                cursor.execute(query, params)
                ciclos = []
                
 
                for row in cursor.fetchall():
                    # Formatear fechas como strings con verificación de tipo
                    fecha_siembra = row.fecha_siembra.strftime('%Y-%m-%d') if row.fecha_siembra and isinstance(row.fecha_siembra, datetime) else row.fecha_siembra if row.fecha_siembra else None
                    fecha_cosecha_estimada = row.fecha_cosecha_estimada.strftime('%Y-%m-%d') if row.fecha_cosecha_estimada and isinstance(row.fecha_cosecha_estimada, datetime) else row.fecha_cosecha_estimada if row.fecha_cosecha_estimada else None
                    fecha_cosecha_real = row.fecha_cosecha_real.strftime('%Y-%m-%d') if row.fecha_cosecha_real and isinstance(row.fecha_cosecha_real, datetime) else row.fecha_cosecha_real if row.fecha_cosecha_real else None
                    fecha_floracion = row.fecha_floracion.strftime('%Y-%m-%d') if row.fecha_floracion and isinstance(row.fecha_floracion, datetime) else row.fecha_floracion if row.fecha_floracion else None
                    fecha_poda = row.fecha_poda.strftime('%Y-%m-%d') if row.fecha_poda and isinstance(row.fecha_poda, datetime) else row.fecha_poda if row.fecha_poda else None
                    fecha_limpieza = row.fecha_limpieza.strftime('%Y-%m-%d') if row.fecha_limpieza and isinstance(row.fecha_limpieza, datetime) else row.fecha_limpieza if row.fecha_limpieza else None
                                    
                    ciclo = {
                        'id_ciclo': row.id_ciclo,
                        'id_parcela': row.id_parcela,
                        'id_variedad': row.id_variedad,
                        'fecha_siembra': fecha_siembra,
                        'fecha_cosecha_estimada': fecha_cosecha_estimada,
                        'fecha_cosecha_real': fecha_cosecha_real,
                        'area_sembrada': float(row.area_sembrada),
                        'densidad_siembra': row.densidad_siembra,
                        'estado': row.estado,
                        'activo': bool(row.activo),
                        'fecha_floracion': fecha_floracion,
                        'fecha_poda': fecha_poda,
                        'fecha_limpieza': fecha_limpieza,
                        'frecuencia_limpieza': row.frecuencia_limpieza,
                        'nombre_parcela': row.nombre_parcela,
                        'nombre_variedad': row.nombre_variedad,
                        'nombre_tipo_cultivo': row.nombre_tipo_cultivo
                    }
                    ciclos.append(ciclo)
                
                logger.info(f"Se obtuvieron {len(ciclos)} ciclos de producción.")
                return ciclos
        except Exception as e:
            logger.error(f"Error al obtener ciclos de producción: {str(e)}")
            return []

    def agregar_tipo_cultivo(self, tipo_data):
        """
        Agrega un nuevo tipo de cultivo a la base de datos.
        
        Args:
            tipo_data (dict): Datos del tipo de cultivo a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del tipo de cultivo agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO TiposCultivo (nombre, nombre_cientifico, descripcion, 
                                       tiempo_cosecha_min, tiempo_cosecha_max, activo)
                VALUES (?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    tipo_data['nombre'],
                    tipo_data.get('nombre_cientifico'),
                    tipo_data.get('descripcion'),
                    tipo_data.get('tiempo_cosecha_min'),
                    tipo_data.get('tiempo_cosecha_max'),
                    1 if tipo_data.get('activo', True) else 0
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del tipo recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_tipo = cursor.fetchone()[0]
                
                logger.info(f"Tipo de cultivo agregado correctamente con ID: {id_tipo}")
                return True, id_tipo
        except Exception as e:
            logger.error(f"Error al agregar tipo de cultivo: {str(e)}")
            return False, None

    def actualizar_tipo_cultivo(self, id_tipo_cultivo, tipo_data):
        """
        Actualiza un tipo de cultivo existente en la base de datos.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo a actualizar.
            tipo_data (dict): Datos actualizados del tipo de cultivo.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'nombre' in tipo_data:
                    campos_actualizar.append("nombre = ?")
                    valores.append(tipo_data['nombre'])
                    
                if 'nombre_cientifico' in tipo_data:
                    campos_actualizar.append("nombre_cientifico = ?")
                    valores.append(tipo_data['nombre_cientifico'])
                    
                if 'descripcion' in tipo_data:
                    campos_actualizar.append("descripcion = ?")
                    valores.append(tipo_data['descripcion'])
                    
                if 'tiempo_cosecha_min' in tipo_data:
                    campos_actualizar.append("tiempo_cosecha_min = ?")
                    valores.append(tipo_data['tiempo_cosecha_min'])
                    
                if 'tiempo_cosecha_max' in tipo_data:
                    campos_actualizar.append("tiempo_cosecha_max = ?")
                    valores.append(tipo_data['tiempo_cosecha_max'])
                    
                if 'activo' in tipo_data:
                    campos_actualizar.append("activo = ?")
                    valores.append(1 if tipo_data['activo'] else 0)
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE TiposCultivo SET {', '.join(campos_actualizar)} WHERE id_tipo_cultivo = ?"
                valores.append(id_tipo_cultivo)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Tipo de cultivo actualizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar tipo de cultivo: {str(e)}")
            return False

    def eliminar_tipo_cultivo(self, id_tipo_cultivo):
        """
        Elimina un tipo de cultivo de la base de datos.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Verificar primero si hay variedades asociadas
                cursor.execute("SELECT COUNT(*) FROM VariedadesCultivo WHERE id_tipo_cultivo = ?", (id_tipo_cultivo,))
                count = cursor.fetchone()[0]
                
                if count > 0:
                    logger.warning(f"No se puede eliminar el tipo de cultivo {id_tipo_cultivo} porque tiene {count} variedades asociadas")
                    return False
                
                query = "DELETE FROM TiposCultivo WHERE id_tipo_cultivo = ?"
                cursor.execute(query, (id_tipo_cultivo,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Tipo de cultivo eliminado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar tipo de cultivo: {str(e)}")
            return False

    def desactivar_tipo_cultivo(self, id_tipo_cultivo):
        """
        Desactiva un tipo de cultivo en lugar de eliminarlo físicamente.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo a desactivar.
            
        Returns:
            bool: True si se desactivó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "UPDATE TiposCultivo SET activo = 0 WHERE id_tipo_cultivo = ?"
                cursor.execute(query, (id_tipo_cultivo,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Tipo de cultivo desactivado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al desactivar tipo de cultivo: {str(e)}")
            return False

    def agregar_variedad_cultivo(self, variedad_data):
        """
        Agrega una nueva variedad de cultivo a la base de datos.
        
        Args:
            variedad_data (dict): Datos de la variedad de cultivo a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID de la variedad agregada o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO VariedadesCultivo (id_tipo_cultivo, nombre, tiempo_produccion, 
                                            resistencia_zona, activo)
                VALUES (?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    variedad_data['id_tipo_cultivo'],
                    variedad_data['nombre'],
                    variedad_data.get('tiempo_produccion'),
                    variedad_data.get('resistencia_zona'),
                    1 if variedad_data.get('activo', True) else 0
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID de la variedad recién insertada
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_variedad = cursor.fetchone()[0]
                
                logger.info(f"Variedad de cultivo agregada correctamente con ID: {id_variedad}")
                return True, id_variedad
        except Exception as e:
            logger.error(f"Error al agregar variedad de cultivo: {str(e)}")
            return False, None

    def actualizar_variedad_cultivo(self, id_variedad, variedad_data):
        """
        Actualiza una variedad de cultivo existente en la base de datos.
        
        Args:
            id_variedad (int): ID de la variedad de cultivo a actualizar.
            variedad_data (dict): Datos actualizados de la variedad de cultivo.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'id_tipo_cultivo' in variedad_data:
                    campos_actualizar.append("id_tipo_cultivo = ?")
                    valores.append(variedad_data['id_tipo_cultivo'])
                    
                if 'nombre' in variedad_data:
                    campos_actualizar.append("nombre = ?")
                    valores.append(variedad_data['nombre'])
                    
                if 'tiempo_produccion' in variedad_data:
                    campos_actualizar.append("tiempo_produccion = ?")
                    valores.append(variedad_data['tiempo_produccion'])
                    
                if 'resistencia_zona' in variedad_data:
                    campos_actualizar.append("resistencia_zona = ?")
                    valores.append(variedad_data['resistencia_zona'])
                    
                if 'activo' in variedad_data:
                    campos_actualizar.append("activo = ?")
                    valores.append(1 if variedad_data['activo'] else 0)
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE VariedadesCultivo SET {', '.join(campos_actualizar)} WHERE id_variedad = ?"
                valores.append(id_variedad)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Variedad de cultivo actualizada correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar variedad de cultivo: {str(e)}")
            return False

    def eliminar_variedad_cultivo(self, id_variedad):
        """
        Elimina una variedad de cultivo de la base de datos.
        
        Args:
            id_variedad (int): ID de la variedad de cultivo a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Verificar primero si hay ciclos de producción asociados
                cursor.execute("SELECT COUNT(*) FROM CiclosProduccion WHERE id_variedad = ?", (id_variedad,))
                count = cursor.fetchone()[0]
                
                if count > 0:
                    logger.warning(f"No se puede eliminar la variedad {id_variedad} porque tiene {count} ciclos de producción asociados")
                    return False
                
                query = "DELETE FROM VariedadesCultivo WHERE id_variedad = ?"
                cursor.execute(query, (id_variedad,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Variedad de cultivo eliminada correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar variedad de cultivo: {str(e)}")
            return False

    def desactivar_variedad_cultivo(self, id_variedad):
        """
        Desactiva una variedad de cultivo en lugar de eliminarla físicamente.
        
        Args:
            id_variedad (int): ID de la variedad de cultivo a desactivar.
            
        Returns:
            bool: True si se desactivó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "UPDATE VariedadesCultivo SET activo = 0 WHERE id_variedad = ?"
                cursor.execute(query, (id_variedad,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Variedad de cultivo desactivada correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al desactivar variedad de cultivo: {str(e)}")
            return False

    def agregar_ciclo_produccion(self, ciclo_data):
        """
        Agrega un nuevo ciclo de producción a la base de datos.
        
        Args:
            ciclo_data (dict): Datos del ciclo de producción a agregar.
            
        Returns:
            bool: True si se agregó correctamente, False en caso contrario.
            int: ID del ciclo agregado o None en caso de error.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO CiclosProduccion (
                    id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, 
                    fecha_cosecha_real, area_sembrada, densidad_siembra, estado, 
                    fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza, activo
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    ciclo_data['id_parcela'],
                    ciclo_data['id_variedad'],
                    ciclo_data.get('fecha_siembra'),
                    ciclo_data.get('fecha_cosecha_estimada'),
                    ciclo_data.get('fecha_cosecha_real'),
                    ciclo_data['area_sembrada'],
                    ciclo_data.get('densidad_siembra'),
                    ciclo_data['estado'],
                    ciclo_data.get('fecha_floracion'),
                    ciclo_data.get('fecha_poda'),
                    ciclo_data.get('fecha_limpieza'),
                    ciclo_data.get('frecuencia_limpieza'),
                    1 if ciclo_data.get('activo', True) else 0
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del ciclo recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_ciclo = cursor.fetchone()[0]
                
                logger.info(f"Ciclo de producción agregado correctamente con ID: {id_ciclo}")
                return True, id_ciclo
        except Exception as e:
            logger.error(f"Error al agregar ciclo de producción: {str(e)}")
            return False, None

    def actualizar_ciclo_produccion(self, id_ciclo, ciclo_data):
        """
        Actualiza un ciclo de producción existente en la base de datos.
        
        Args:
            id_ciclo (int): ID del ciclo de producción a actualizar.
            ciclo_data (dict): Datos actualizados del ciclo de producción.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'id_parcela' in ciclo_data:
                    campos_actualizar.append("id_parcela = ?")
                    valores.append(ciclo_data['id_parcela'])
                    
                if 'id_variedad' in ciclo_data:
                    campos_actualizar.append("id_variedad = ?")
                    valores.append(ciclo_data['id_variedad'])
                    
                if 'fecha_siembra' in ciclo_data:
                    campos_actualizar.append("fecha_siembra = ?")
                    valores.append(ciclo_data['fecha_siembra'])
                    
                if 'fecha_cosecha_estimada' in ciclo_data:
                    campos_actualizar.append("fecha_cosecha_estimada = ?")
                    valores.append(ciclo_data['fecha_cosecha_estimada'])
                    
                if 'fecha_cosecha_real' in ciclo_data:
                    campos_actualizar.append("fecha_cosecha_real = ?")
                    valores.append(ciclo_data['fecha_cosecha_real'])
                    
                if 'area_sembrada' in ciclo_data:
                    campos_actualizar.append("area_sembrada = ?")
                    valores.append(ciclo_data['area_sembrada'])
                    
                if 'densidad_siembra' in ciclo_data:
                    campos_actualizar.append("densidad_siembra = ?")
                    valores.append(ciclo_data['densidad_siembra'])
                    
                if 'estado' in ciclo_data:
                    campos_actualizar.append("estado = ?")
                    valores.append(ciclo_data['estado'])
                    
                if 'fecha_floracion' in ciclo_data:
                    campos_actualizar.append("fecha_floracion = ?")
                    valores.append(ciclo_data['fecha_floracion'])
                    
                if 'fecha_poda' in ciclo_data:
                    campos_actualizar.append("fecha_poda = ?")
                    valores.append(ciclo_data['fecha_poda'])
                    
                if 'fecha_limpieza' in ciclo_data:
                    campos_actualizar.append("fecha_limpieza = ?")
                    valores.append(ciclo_data['fecha_limpieza'])
                    
                if 'frecuencia_limpieza' in ciclo_data:
                    campos_actualizar.append("frecuencia_limpieza = ?")
                    valores.append(ciclo_data['frecuencia_limpieza'])
                    
                if 'activo' in ciclo_data:
                    campos_actualizar.append("activo = ?")
                    valores.append(1 if ciclo_data['activo'] else 0)
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE CiclosProduccion SET {', '.join(campos_actualizar)} WHERE id_ciclo = ?"
                valores.append(id_ciclo)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Ciclo de producción actualizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar ciclo de producción: {str(e)}")
            return False

    def eliminar_ciclo_produccion(self, id_ciclo):
        """
        Elimina un ciclo de producción de la base de datos.
        
        Args:
            id_ciclo (int): ID del ciclo de producción a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM CiclosProduccion WHERE id_ciclo = ?"
                cursor.execute(query, (id_ciclo,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Ciclo de producción eliminado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar ciclo de producción: {str(e)}")
            return False
            
    def desactivar_ciclo_produccion(self, id_ciclo):
        """
        Desactiva un ciclo de producción en lugar de eliminarlo físicamente.
        
        Args:
            id_ciclo (int): ID del ciclo de producción a desactivar.
            
        Returns:
            bool: True si se desactivó correctamente, False en caso contrario.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "UPDATE CiclosProduccion SET activo = 0 WHERE id_ciclo = ?"
                cursor.execute(query, (id_ciclo,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Ciclo de producción desactivado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al desactivar ciclo de producción: {str(e)}")
            return False
    
    def cambiar_estado_ciclo(self, id_ciclo, nuevo_estado):
        """
        Cambia el estado de un ciclo de producción.
        
        Args:
            id_ciclo (int): ID del ciclo de producción.
            nuevo_estado (str): Nuevo estado del ciclo ('Planificado', 'En Preparación', 'Sembrado', 
                              'En Desarrollo', 'En Cosecha', 'Finalizado', 'Cancelado').
            
        Returns:
            bool: True si se cambió correctamente, False en caso contrario.
        """
        estados_validos = ['Planificado', 'En Preparación', 'Sembrado', 
                          'En Desarrollo', 'En Cosecha', 'Finalizado', 'Cancelado']
        
        if nuevo_estado not in estados_validos:
            logger.error(f"Estado no válido: {nuevo_estado}. Estados válidos: {estados_validos}")
            return False
        
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "UPDATE CiclosProduccion SET estado = ? WHERE id_ciclo = ?"
                cursor.execute(query, (nuevo_estado, id_ciclo))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Estado del ciclo {id_ciclo} actualizado a '{nuevo_estado}'. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al cambiar estado del ciclo: {str(e)}")
            return False
    
    def obtener_estadisticas_cultivos(self):
        """
        Obtiene estadísticas generales de cultivos y producción.
        
        Returns:
            dict: Diccionario con diversas estadísticas de cultivos.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Total de tipos de cultivo activos
                cursor.execute("SELECT COUNT(*) FROM TiposCultivo WHERE activo = 1")
                total_tipos = cursor.fetchone()[0]
                
                # Total de variedades activas
                cursor.execute("SELECT COUNT(*) FROM VariedadesCultivo WHERE activo = 1")
                total_variedades = cursor.fetchone()[0]
                
                # Ciclos activos por estado
                cursor.execute("""
                    SELECT estado, COUNT(*) as total
                    FROM CiclosProduccion
                    WHERE activo = 1
                    GROUP BY estado
                    ORDER BY COUNT(*) DESC
                """)
                
                ciclos_por_estado = {}
                for row in cursor.fetchall():
                    ciclos_por_estado[row[0]] = row[1]
                
                # Área total sembrada actualmente
                cursor.execute("""
                    SELECT SUM(area_sembrada) 
                    FROM CiclosProduccion 
                    WHERE activo = 1 AND estado NOT IN ('Finalizado', 'Cancelado')
                """)
                area_sembrada = cursor.fetchone()[0]
                area_sembrada = float(area_sembrada) if area_sembrada else 0
                
                # Tipos de cultivo más utilizados
                cursor.execute("""
                    SELECT t.nombre, COUNT(c.id_ciclo) as total_ciclos
                    FROM TiposCultivo t
                    JOIN VariedadesCultivo v ON t.id_tipo_cultivo = v.id_tipo_cultivo
                    JOIN CiclosProduccion c ON v.id_variedad = c.id_variedad
                    WHERE c.activo = 1
                    GROUP BY t.nombre
                    ORDER BY total_ciclos DESC
                """)
                
                cultivos_populares = {}
                for row in cursor.fetchall():
                    cultivos_populares[row[0]] = row[1]
                
                estadisticas = {
                    'total_tipos_cultivo': total_tipos,
                    'total_variedades': total_variedades,
                    'ciclos_por_estado': ciclos_por_estado,
                    'area_sembrada_activa': area_sembrada,
                    'cultivos_populares': cultivos_populares
                }
                
                logger.info("Estadísticas de cultivos generadas correctamente")
                return estadisticas
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de cultivos: {str(e)}")
            return {}

# Ejemplo de uso

if __name__ == "__main__":
    # Prueba la conexión y consulta
    try:
        gestor = GestorCultivos()
        tipos = gestor.obtener_tipos_cultivo()
        print(f"Total de tipos de cultivo: {len(tipos)}")
        for tipo in tipos:
            print(f"ID: {tipo['id_tipo_cultivo']}, Nombre: {tipo['nombre']}, "
                  f"Nombre científico: {tipo['nombre_cientifico']}")
            
        variedades = gestor.obtener_variedades_cultivo()
        print(f"\nTotal de variedades: {len(variedades)}")
        for variedad in variedades:
            print(f"ID: {variedad['id_variedad']}, Nombre: {variedad['nombre']}, "
                  f"Tipo: {variedad['nombre_tipo_cultivo']}")
            
        ciclos = gestor.obtener_ciclos_produccion()
        print(f"\nTotal de ciclos de producción: {len(ciclos)}")
        for ciclo in ciclos:
            print(f"ID: {ciclo['id_ciclo']}, Parcela: {ciclo['nombre_parcela']}, "
                  f"Cultivo: {ciclo['nombre_tipo_cultivo']} - {ciclo['nombre_variedad']}, "
                  f"Estado: {ciclo['estado']}")
    except Exception as e:
        print(f"Error al ejecutar el ejemplo: {str(e)}")
