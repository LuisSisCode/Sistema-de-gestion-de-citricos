"""
Repositorio para gestión de Maquinaria
Maneja todas las operaciones CRUD de la tabla Maquinaria
"""

import logging
from typing import List, Dict, Optional, Tuple
from backend.core.repositorio_base import RepositorioBase
from backend.core.repositorio_base import ErrorConexion
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class MaquinariaRepositorio(RepositorioBase):
    """
    Repositorio para la gestión de equipos de maquinaria agrícola.
    
    Tabla: Maquinaria
    Columnas: id_maquinaria, codigo, nombre, tipo, marca, tipo_combustible,
              estado, ubicacion_actual, activo
    """
    
    def __init__(self):
        super().__init__()
        self.tabla = "Maquinaria"
        logger.info("MaquinariaRepositorio inicializado")
    
    @cacheable('maquinaria', ttl=get_ttl('maquinaria'))
    def obtener_todos(self, solo_activos: bool = False) -> List[Dict]:
        """
        Obtiene todos los equipos de maquinaria.
        
        Args:
            solo_activos: Si True, solo devuelve equipos activos
            
        Returns:
            Lista de diccionarios con información de maquinaria
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_maquinaria, codigo, nombre, tipo, marca, 
                       tipo_combustible, estado, ubicacion_actual, activo
                FROM Maquinaria
                """
                
                if solo_activos:
                    query += " WHERE activo = 1"
                
                query += " ORDER BY codigo"
                
                cursor.execute(query)
                
                maquinarias = []
                for row in cursor.fetchall():
                    maquinaria = {
                        'id_maquinaria': int(row.id_maquinaria) if row.id_maquinaria else 0,
                        'codigo': str(row.codigo).strip() if row.codigo else "",
                        'nombre': str(row.nombre).strip() if row.nombre else "",
                        'tipo': str(row.tipo).strip() if row.tipo else "",
                        'marca': str(row.marca).strip() if row.marca else "",
                        'tipo_combustible': str(row.tipo_combustible).strip() if row.tipo_combustible else "",
                        'estado': str(row.estado).strip() if row.estado else "Operativo",
                        'ubicacion_actual': str(row.ubicacion_actual).strip() if row.ubicacion_actual else "",
                        'activo': bool(row.activo) if row.activo is not None else True
                    }
                    maquinarias.append(maquinaria)
                
                logger.info(f"Se obtuvieron {len(maquinarias)} equipos de maquinaria")
                return maquinarias
                
        except Exception as e:
            logger.error(f"Error al obtener maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al obtener maquinaria: {str(e)}")
    
    def obtener_por_id(self, id_maquinaria: int) -> Optional[Dict]:
        """
        Obtiene un equipo específico por su ID.
        
        Args:
            id_maquinaria: ID del equipo
            
        Returns:
            Diccionario con datos del equipo o None si no existe
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_maquinaria, codigo, nombre, tipo, marca, 
                       tipo_combustible, estado, ubicacion_actual, activo
                FROM Maquinaria
                WHERE id_maquinaria = ?
                """
                
                cursor.execute(query, (id_maquinaria,))
                row = cursor.fetchone()
                
                if not row:
                    logger.warning(f"No se encontró maquinaria con ID: {id_maquinaria}")
                    return None
                
                maquinaria = {
                    'id_maquinaria': int(row.id_maquinaria),
                    'codigo': str(row.codigo).strip() if row.codigo else "",
                    'nombre': str(row.nombre).strip() if row.nombre else "",
                    'tipo': str(row.tipo).strip() if row.tipo else "",
                    'marca': str(row.marca).strip() if row.marca else "",
                    'tipo_combustible': str(row.tipo_combustible).strip() if row.tipo_combustible else "",
                    'estado': str(row.estado).strip() if row.estado else "Operativo",
                    'ubicacion_actual': str(row.ubicacion_actual).strip() if row.ubicacion_actual else "",
                    'activo': bool(row.activo) if row.activo is not None else True
                }
                
                logger.info(f"Equipo obtenido: {maquinaria['codigo']}")
                return maquinaria
                
        except Exception as e:
            logger.error(f"Error al obtener maquinaria por ID {id_maquinaria}: {str(e)}")
            raise ErrorConsulta(f"Error al obtener maquinaria: {str(e)}")
    
    def obtener_por_codigo(self, codigo: str) -> Optional[Dict]:
        """
        Obtiene un equipo por su código único.
        
        Args:
            codigo: Código del equipo
            
        Returns:
            Diccionario con datos del equipo o None si no existe
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_maquinaria, codigo, nombre, tipo, marca, 
                       tipo_combustible, estado, ubicacion_actual, activo
                FROM Maquinaria
                WHERE codigo = ?
                """
                
                cursor.execute(query, (codigo,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                maquinaria = {
                    'id_maquinaria': int(row.id_maquinaria),
                    'codigo': str(row.codigo).strip(),
                    'nombre': str(row.nombre).strip(),
                    'tipo': str(row.tipo).strip(),
                    'marca': str(row.marca).strip(),
                    'tipo_combustible': str(row.tipo_combustible).strip() if row.tipo_combustible else "",
                    'estado': str(row.estado).strip(),
                    'ubicacion_actual': str(row.ubicacion_actual).strip() if row.ubicacion_actual else "",
                    'activo': bool(row.activo) if row.activo is not None else True
                }
                
                return maquinaria
                
        except Exception as e:
            logger.error(f"Error al obtener maquinaria por código {codigo}: {str(e)}")
            raise ErrorConsulta(f"Error al obtener maquinaria: {str(e)}")
    
    @cache_invalidator('maquinaria')
    def crear(self, datos: Dict) -> Tuple[bool, int]:
        """
        Crea un nuevo equipo de maquinaria.
        
        Args:
            datos: Diccionario con los datos del equipo
                - codigo (str, requerido): Código único
                - nombre (str, requerido): Nombre del equipo
                - tipo (str, requerido): Tipo de maquinaria
                - marca (str, requerido): Marca del equipo
                - tipo_combustible (str, opcional): Tipo de combustible
                - estado (str, opcional): Estado (default: 'Operativo')
                - ubicacion_actual (str, opcional): Ubicación actual
                - activo (bool, opcional): Si está activo (default: True)
                
        Returns:
            Tupla (éxito, id_generado)
        """
        try:
            # Validar campos requeridos
            campos_requeridos = ['codigo', 'nombre', 'tipo', 'marca']
            for campo in campos_requeridos:
                if campo not in datos or not datos[campo]:
                    raise ValueError(f"El campo '{campo}' es requerido")
            
            # Verificar código duplicado
            if self.obtener_por_codigo(datos['codigo']):
                raise ValueError(f"Ya existe un equipo con el código '{datos['codigo']}'")
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO Maquinaria 
                (codigo, nombre, tipo, marca, tipo_combustible, estado, 
                 ubicacion_actual, activo)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    datos['codigo'].strip(),
                    datos['nombre'].strip(),
                    datos['tipo'].strip(),
                    datos['marca'].strip(),
                    datos.get('tipo_combustible', '').strip() if datos.get('tipo_combustible') else None,
                    datos.get('estado', 'Operativo').strip(),
                    datos.get('ubicacion_actual', '').strip() if datos.get('ubicacion_actual') else None,
                    datos.get('activo', True)
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID generado
                cursor.execute("SELECT @@IDENTITY")
                id_generado = cursor.fetchone()[0]
                
                logger.info(f"Maquinaria creada exitosamente: {datos['codigo']} (ID: {id_generado})")
                return True, int(id_generado)
                
        except ValueError as ve:
            logger.warning(f"Validación fallida al crear maquinaria: {str(ve)}")
            raise ErrorConsulta(str(ve))
        except Exception as e:
            logger.error(f"Error al crear maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al crear maquinaria: {str(e)}")
    
    @cache_invalidator('maquinaria')
    def actualizar(self, id_maquinaria: int, datos: Dict) -> bool:
        """
        Actualiza un equipo de maquinaria existente.
        
        Args:
            id_maquinaria: ID del equipo a actualizar
            datos: Diccionario con campos a actualizar
            
        Returns:
            True si se actualizó correctamente
        """
        try:
            # Verificar que el equipo existe
            if not self.obtener_por_id(id_maquinaria):
                raise ValueError(f"No existe maquinaria con ID: {id_maquinaria}")
            
            # Verificar código duplicado si se está cambiando
            if 'codigo' in datos:
                equipo_existente = self.obtener_por_codigo(datos['codigo'])
                if equipo_existente and equipo_existente['id_maquinaria'] != id_maquinaria:
                    raise ValueError(f"Ya existe otro equipo con el código '{datos['codigo']}'")
            
            campos_actualizar = []
            valores = []
            
            # Campos actualizables
            campos_permitidos = {
                'codigo': 'codigo = ?',
                'nombre': 'nombre = ?',
                'tipo': 'tipo = ?',
                'marca': 'marca = ?',
                'tipo_combustible': 'tipo_combustible = ?',
                'estado': 'estado = ?',
                'ubicacion_actual': 'ubicacion_actual = ?',
                'activo': 'activo = ?'
            }
            
            for campo, sql in campos_permitidos.items():
                if campo in datos:
                    campos_actualizar.append(sql)
                    valor = datos[campo]
                    # Limpiar strings
                    if isinstance(valor, str):
                        valor = valor.strip() if valor else None
                    valores.append(valor)
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar")
                return False
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = f"UPDATE Maquinaria SET {', '.join(campos_actualizar)} WHERE id_maquinaria = ?"
                valores.append(id_maquinaria)
                
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                
                if filas_afectadas > 0:
                    logger.info(f"Maquinaria actualizada: ID {id_maquinaria}")
                    return True
                else:
                    logger.warning(f"No se actualizó ninguna fila para ID: {id_maquinaria}")
                    return False
                    
        except ValueError as ve:
            logger.warning(f"Validación fallida al actualizar maquinaria: {str(ve)}")
            raise ErrorConsulta(str(ve))
        except Exception as e:
            logger.error(f"Error al actualizar maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al actualizar maquinaria: {str(e)}")
    
    @cache_invalidator('maquinaria')
    def eliminar(self, id_maquinaria: int) -> bool:
        """
        Elimina físicamente un equipo de maquinaria.
        PRECAUCIÓN: Solo usar si no hay registros relacionados.
        
        Args:
            id_maquinaria: ID del equipo a eliminar
            
        Returns:
            True si se eliminó correctamente
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM Maquinaria WHERE id_maquinaria = ?"
                cursor.execute(query, (id_maquinaria,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                
                if filas_afectadas > 0:
                    logger.info(f"Maquinaria eliminada físicamente: ID {id_maquinaria}")
                    return True
                else:
                    logger.warning(f"No se eliminó ninguna fila para ID: {id_maquinaria}")
                    return False
                    
        except Exception as e:
            logger.error(f"Error al eliminar maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al eliminar maquinaria (puede tener registros relacionados): {str(e)}")
    
    @cache_invalidator('maquinaria')
    def desactivar(self, id_maquinaria: int) -> bool:
        """
        Desactiva un equipo (eliminación lógica).
        Recomendado sobre eliminación física.
        
        Args:
            id_maquinaria: ID del equipo a desactivar
            
        Returns:
            True si se desactivó correctamente
        """
        try:
            return self.actualizar(id_maquinaria, {'activo': False})
        except Exception as e:
            logger.error(f"Error al desactivar maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al desactivar maquinaria: {str(e)}")
    
    @cache_invalidator('maquinaria')
    def activar(self, id_maquinaria: int) -> bool:
        """
        Reactiva un equipo previamente desactivado.
        
        Args:
            id_maquinaria: ID del equipo a activar
            
        Returns:
            True si se activó correctamente
        """
        try:
            return self.actualizar(id_maquinaria, {'activo': True})
        except Exception as e:
            logger.error(f"Error al activar maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al activar maquinaria: {str(e)}")
    
    def filtrar(self, filtros: Dict) -> List[Dict]:
        """
        Filtra maquinaria según criterios específicos.
        
        Args:
            filtros: Diccionario con criterios de filtrado
                - tipo: Tipo de maquinaria
                - marca: Marca
                - estado: Estado del equipo
                - tipo_combustible: Tipo de combustible
                - activo: Si está activo
                
        Returns:
            Lista de equipos que cumplen los criterios
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT id_maquinaria, codigo, nombre, tipo, marca, 
                       tipo_combustible, estado, ubicacion_actual, activo
                FROM Maquinaria
                WHERE 1=1
                """
                
                valores = []
                
                if 'tipo' in filtros and filtros['tipo']:
                    query += " AND tipo = ?"
                    valores.append(filtros['tipo'])
                
                if 'marca' in filtros and filtros['marca']:
                    query += " AND marca = ?"
                    valores.append(filtros['marca'])
                
                if 'estado' in filtros and filtros['estado']:
                    query += " AND estado = ?"
                    valores.append(filtros['estado'])
                
                if 'tipo_combustible' in filtros and filtros['tipo_combustible']:
                    query += " AND tipo_combustible = ?"
                    valores.append(filtros['tipo_combustible'])
                
                if 'activo' in filtros and filtros['activo'] is not None:
                    query += " AND activo = ?"
                    valores.append(filtros['activo'])
                
                query += " ORDER BY codigo"
                
                cursor.execute(query, valores)
                
                maquinarias = []
                for row in cursor.fetchall():
                    maquinaria = {
                        'id_maquinaria': int(row.id_maquinaria),
                        'codigo': str(row.codigo).strip(),
                        'nombre': str(row.nombre).strip(),
                        'tipo': str(row.tipo).strip(),
                        'marca': str(row.marca).strip(),
                        'tipo_combustible': str(row.tipo_combustible).strip() if row.tipo_combustible else "",
                        'estado': str(row.estado).strip(),
                        'ubicacion_actual': str(row.ubicacion_actual).strip() if row.ubicacion_actual else "",
                        'activo': bool(row.activo) if row.activo is not None else True
                    }
                    maquinarias.append(maquinaria)
                
                logger.info(f"Filtro aplicado. {len(maquinarias)} equipos encontrados")
                return maquinarias
                
        except Exception as e:
            logger.error(f"Error al filtrar maquinaria: {str(e)}")
            raise ErrorConsulta(f"Error al filtrar maquinaria: {str(e)}")
    
    def obtener_estadisticas(self) -> Dict:
        """
        Obtiene estadísticas generales de la maquinaria.
        
        Returns:
            Diccionario con estadísticas
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Total de equipos
                cursor.execute("SELECT COUNT(*) FROM Maquinaria")
                total = cursor.fetchone()[0]
                
                # Equipos activos
                cursor.execute("SELECT COUNT(*) FROM Maquinaria WHERE activo = 1")
                activos = cursor.fetchone()[0]
                
                # Por estado
                cursor.execute("""
                SELECT estado, COUNT(*) as cantidad
                FROM Maquinaria
                WHERE activo = 1
                GROUP BY estado
                """)
                por_estado = {row.estado: row.cantidad for row in cursor.fetchall()}
                
                # Por tipo
                cursor.execute("""
                SELECT tipo, COUNT(*) as cantidad
                FROM Maquinaria
                WHERE activo = 1
                GROUP BY tipo
                """)
                por_tipo = {row.tipo: row.cantidad for row in cursor.fetchall()}
                
                estadisticas = {
                    'total_equipos': total,
                    'equipos_activos': activos,
                    'equipos_inactivos': total - activos,
                    'por_estado': por_estado,
                    'por_tipo': por_tipo
                }
                
                logger.info("Estadísticas de maquinaria generadas")
                return estadisticas
                
        except Exception as e:
            logger.error(f"Error al obtener estadísticas: {str(e)}")
            raise ErrorConsulta(f"Error al obtener estadísticas: {str(e)}")