# Base de datos donde se conectan las tablas de: agricultores, parcelas
import pyodbc
import logging
from datetime import datetime

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('bd_agricultores_parcelas')

class GestorAgricultoresParcelas:
    def __init__(self, server="DESKTOP-HOE6AHT\\SQLEXPRESS", database="Produccion_Citricos", trusted_connection=True):
        """
        Inicializa la conexión a la base de datos SQL Server.
        
        Args:
            server (str): Nombre del servidor SQL Server.
            database (str): Nombre de la base de datos.
            trusted_connection (bool): Usar autenticación de Windows (True) o SQL Server (False).
        """
        try:
            self.connection_string = f"DRIVER={{SQL Server}};SERVER={server};DATABASE={database};"
            
            if trusted_connection:
                self.connection_string += "Trusted_Connection=yes;"
            else:
                # Si necesitas usar autenticación de SQL Server, añade usuario y contraseña
                # self.connection_string += "UID=tu_usuario;PWD=tu_contraseña;"
                pass
                
            # Probar la conexión al iniciar
            self.test_connection()
            logger.info("Conexión a la base de datos establecida correctamente.")
        except Exception as e:
            logger.error(f"Error al establecer la conexión a la base de datos: {str(e)}")
            raise

    def test_connection(self):
        """Prueba la conexión a la base de datos."""
        try:
            with pyodbc.connect(self.connection_string) as conn:
                pass
        except Exception as e:
            logger.error(f"Error al probar la conexión: {str(e)}")
            raise

    def obtener_agricultores(self):
        """
        Obtiene todos los agricultores de la base de datos.
        
        Returns:
            list: Lista de diccionarios con la información de cada agricultor.
        """
        try:
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_agricultor, nombre, apellido, identificacion, 
                       telefono, correo, direccion, fecha_registro, 
                       es_propietario, activo
                FROM Agricultores
                ORDER BY id_agricultor
                """
                
                cursor.execute(query)
                agricultores = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string si existe
                    fecha_registro = None
                    if row.fecha_registro:
                        if isinstance(row.fecha_registro, str):
                            fecha_registro = row.fecha_registro
                        else:
                            try:
                                fecha_registro = row.fecha_registro.strftime('%Y-%m-%d')
                            except AttributeError:
                                fecha_registro = str(row.fecha_registro)
                    
                    agricultor = {
                        'agricultorId': row.id_agricultor,
                        'nombre': row.nombre,
                        'apellido': row.apellido,
                        'identificacion': row.identificacion,
                        'telefono': row.telefono,
                        'correo': row.correo,
                        'direccion': row.direccion,
                        'fecha_registro': fecha_registro,
                        'esPropietario': bool(row.es_propietario),
                        'activo': bool(row.activo)
                    }
                    agricultores.append(agricultor)
                
                logger.info(f"Se obtuvieron {len(agricultores)} agricultores de la base de datos.")
                return agricultores
        except Exception as e:
            logger.error(f"Error al obtener agricultores: {str(e)}")
            return []

    def obtener_parcelas(self):
        """
        Obtiene todas las parcelas de la base de datos con información de sus propietarios.
        
        Returns:
            list: Lista de diccionarios con la información de cada parcela.
        """
        try:
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT p.id_parcela, p.nombre, p.ubicacion, p.area_total,
                       p.coordenadas_gps, p.tipo_suelo, p.fuente_agua,
                       p.fecha_adquisicion, p.activo, 
                       a.id_agricultor, a.nombre + ' ' + a.apellido AS nombre_propietario
                FROM Parcelas p
                JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
                ORDER BY p.id_parcela
                """
                
                cursor.execute(query)
                parcelas = []
                
                for row in cursor.fetchall():
                    # Formatear fecha como string si existe
                    fecha_adquisicion = None
                    if row.fecha_adquisicion:
                        if isinstance(row.fecha_adquisicion, str):
                            fecha_adquisicion = row.fecha_adquisicion
                        else:
                            try:
                                fecha_adquisicion = row.fecha_adquisicion.strftime('%Y-%m-%d')
                            except AttributeError:
                                fecha_adquisicion = str(row.fecha_adquisicion)
                    
                    # Calcular un porcentaje de uso ficticio (en una implementación real esto podría
                    # calcularse basado en los ciclos de producción activos en la parcela)
                    # Por ahora es simplemente un valor aleatorio entre 0 y 100 para demostración
                    from random import randint
                    porcentaje_uso = randint(0, 100)
                    
                    parcela = {
                        'parcelaId': row.id_parcela,
                        'nombre': row.nombre,
                        'propietario': row.nombre_propietario,
                        'propietarioId': row.id_agricultor,
                        'ubicacion': row.ubicacion,
                        'area': float(row.area_total),
                        'coordenadasGPS': row.coordenadas_gps,
                        'tipoSuelo': row.tipo_suelo,
                        'fuenteAgua': row.fuente_agua,
                        'fechaAdquisicion': fecha_adquisicion,
                        'porcentajeUso': porcentaje_uso,  # Valor demostrativo
                        'activo': bool(row.activo)
                    }
                    parcelas.append(parcela)
                
                logger.info(f"Se obtuvieron {len(parcelas)} parcelas de la base de datos.")
                return parcelas
        except Exception as e:
            logger.error(f"Error al obtener parcelas: {str(e)}")
            return []

    def obtener_propietarios(self):
        """
        Obtiene la lista de agricultores que son propietarios.
        
        Returns:
            list: Lista de diccionarios con la información de cada propietario.
        """
        try:
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_agricultor, nombre, apellido
                FROM Agricultores
                WHERE es_propietario = 1 AND activo = 1
                ORDER BY nombre, apellido
                """
                
                cursor.execute(query)
                propietarios = []
                
                for row in cursor.fetchall():
                    propietario = {
                        'id': row.id_agricultor,
                        'nombre': f"{row.nombre} {row.apellido}"
                    }
                    propietarios.append(propietario)
                
                logger.info(f"Se obtuvieron {len(propietarios)} propietarios de la base de datos.")
                return propietarios
        except Exception as e:
            logger.error(f"Error al obtener propietarios: {str(e)}")
            return []

    def agregar_agricultor(self, agricultor_data):
        """
        Agrega un nuevo agricultor a la base de datos.
        
        Args:
            agricultor_data (dict): Datos del agricultor a agregar.
            
        Returns:
            tuple: (bool, int) - Éxito de la operación y ID del agricultor agregado.
        """
        try:
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Agricultores (nombre, apellido, identificacion, telefono, 
                                      correo, direccion, fecha_registro, es_propietario, 
                                      notas, activo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                # Configurar valores para la inserción
                fecha_actual = datetime.now().date()
                valores = (
                    agricultor_data['nombre'],
                    agricultor_data['apellido'],
                    agricultor_data['identificacion'],
                    agricultor_data.get('telefono'),
                    agricultor_data.get('correo'),
                    agricultor_data.get('direccion'),
                    fecha_actual,
                    1 if agricultor_data.get('esPropietario', False) else 0,
                    agricultor_data.get('notas'),
                    1  # Activo por defecto
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID del agricultor recién insertado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_agricultor = cursor.fetchone()[0]
                
                logger.info(f"Agricultor agregado correctamente con ID: {id_agricultor}")
                return True, id_agricultor
        except Exception as e:
            logger.error(f"Error al agregar agricultor: {str(e)}")
            return False, None

    def actualizar_agricultor(self, id_agricultor, agricultor_data):
        """
        Actualiza un agricultor existente en la base de datos.
        
        Args:
            id_agricultor (int): ID del agricultor a actualizar.
            agricultor_data (dict): Datos actualizados del agricultor.
            
        Returns:
            bool: True si se actualizó correctamente, False en caso contrario.
        """
        try:
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                
                # Construir la consulta de actualización dinámicamente
                campos_actualizar = []
                valores = []
                
                if 'nombre' in agricultor_data:
                    campos_actualizar.append("nombre = ?")
                    valores.append(agricultor_data['nombre'])
                    
                if 'apellido' in agricultor_data:
                    campos_actualizar.append("apellido = ?")
                    valores.append(agricultor_data['apellido'])
                    
                if 'identificacion' in agricultor_data:
                    campos_actualizar.append("identificacion = ?")
                    valores.append(agricultor_data['identificacion'])
                    
                if 'telefono' in agricultor_data:
                    campos_actualizar.append("telefono = ?")
                    valores.append(agricultor_data['telefono'])
                    
                if 'correo' in agricultor_data:
                    campos_actualizar.append("correo = ?")
                    valores.append(agricultor_data['correo'])
                    
                if 'direccion' in agricultor_data:
                    campos_actualizar.append("direccion = ?")
                    valores.append(agricultor_data['direccion'])
                    
                if 'esPropietario' in agricultor_data:
                    campos_actualizar.append("es_propietario = ?")
                    valores.append(1 if agricultor_data['esPropietario'] else 0)
                    
                if 'notas' in agricultor_data:
                    campos_actualizar.append("notas = ?")
                    valores.append(agricultor_data['notas'])
                    
                if 'activo' in agricultor_data:
                    campos_actualizar.append("activo = ?")
                    valores.append(1 if agricultor_data['activo'] else 0)
                
                if not campos_actualizar:
                    logger.warning("No hay campos para actualizar")
                    return False
                
                query = f"UPDATE Agricultores SET {', '.join(campos_actualizar)} WHERE id_agricultor = ?"
                valores.append(id_agricultor)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Agricultor actualizado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al actualizar agricultor: {str(e)}")
            return False

    def eliminar_agricultor(self, id_agricultor):
        """
        Elimina un agricultor de la base de datos.
        
        Args:
            id_agricultor (int): ID del agricultor a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente, False en caso contrario.
        """
        try:
            # Primero verificamos si el agricultor tiene parcelas asociadas
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                
                query_check = "SELECT COUNT(*) FROM Parcelas WHERE id_agricultor = ?"
                cursor.execute(query_check, (id_agricultor,))
                count = cursor.fetchone()[0]
                
                if count > 0:
                    logger.warning(f"No se puede eliminar el agricultor ID {id_agricultor} porque tiene {count} parcelas asociadas.")
                    return False
                
                # Si no tiene parcelas, procedemos a eliminar
                query_delete = "DELETE FROM Agricultores WHERE id_agricultor = ?"
                cursor.execute(query_delete, (id_agricultor,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Agricultor eliminado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al eliminar agricultor: {str(e)}")
            return False
        
    def desactivar_agricultor(self, id_agricultor):
        """
        Desactiva un agricultor en lugar de eliminarlo físicamente.
        
        Args:
            id_agricultor (int): ID del agricultor a desactivar.
            
        Returns:
            bool: True si se desactivó correctamente, False en caso contrario.
        """
        try:
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                
                query = "UPDATE Agricultores SET activo = 0 WHERE id_agricultor = ?"
                cursor.execute(query, (id_agricultor,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Agricultor desactivado correctamente. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
        except Exception as e:
            logger.error(f"Error al desactivar agricultor: {str(e)}")
            return False

    def agregar_parcela(self, parcela_data):
        """
        Agrega una nueva parcela a la base de datos.
        
        Args:
            parcela_data (dict): Datos de la parcela a agregar.
            
        Returns:
            tuple: (bool, int) - Éxito de la operación y ID de la parcela agregada.
        """
        try:
            with pyodbc.connect(self.connection_string) as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Parcelas (id_agricultor, nombre, ubicacion, area_total,
                                    coordenadas_gps, tipo_suelo, fuente_agua,
                                    fecha_adquisicion, activo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                # Configurar valores para la inserción
                fecha_actual = datetime.now().date()
                valores = (
                    parcela_data['propietarioId'],
                    parcela_data['nombre'],
                    parcela_data['ubicacion'],
                    parcela_data['area'],
                    parcela_data.get('coordenadasGPS'),
                    parcela_data.get('tipoSuelo'),
                    parcela_data.get('fuenteAgua'),
                    fecha_actual,
                    1  # Activo por defecto
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID de la parcela recién insertada
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_parcela = cursor.fetchone()[0]
                
                logger.info(f"Parcela agregada correctamente con ID: {id_parcela}")
                return True, id_parcela
        except Exception as e:
            logger.error(f"Error al agregar parcela: {str(e)}")
            return False, None

# Ejemplo de uso
"""
if __name__ == "__main__":
    # Prueba la conexión y consulta
    try:
        gestor = GestorAgricultoresParcelas()
        agricultores = gestor.obtener_agricultores()
        print(f"Total de agricultores: {len(agricultores)}")
        for agricultor in agricultores:
            print(f"ID: {agricultor['agricultorId']}, Nombre: {agricultor['nombre']} {agricultor['apellido']}, "
                  f"Identificación: {agricultor['identificacion']}, Es propietario: {'Sí' if agricultor['esPropietario'] else 'No'}")
            
        parcelas = gestor.obtener_parcelas()
        print(f"\nTotal de parcelas: {len(parcelas)}")
        for parcela in parcelas:
            print(f"ID: {parcela['parcelaId']}, Nombre: {parcela['nombre']}, "
                  f"Propietario: {parcela['propietario']}, Área: {parcela['area']} hectáreas")
    except Exception as e:
        print(f"Error al ejecutar el ejemplo: {str(e)}")
"""