# bd_conecciones/repositorio/ClientesVentasRep/estado_venta_repositorio.py

import logging
from ...nucleo.repositorio_base import RepositorioBase
from ...nucleo.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class EstadoVentaRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de estados de venta con caché optimizado."""

    @cacheable('estados_venta', key_func=lambda: 'todos_activos', ttl=7200)  # 2 horas - datos semi-estáticos
    def obtener_todos(self):
        """
        Obtiene todos los estados de venta activos.
        
        Returns:
            list: Lista de diccionarios con información de estados de venta.
        """
        query = """
        SELECT id_estado, nombre, descripcion, activo
        FROM EstadosVenta
        WHERE activo = 1
        ORDER BY id_estado
        """
        
        rows = self._ejecutar_consulta(query)
        estados = []
        
        for row in rows:
            estado = {
                'id_estado': row.id_estado,
                'nombre': row.nombre,
                'descripcion': row.descripcion,
                'activo': bool(row.activo)
            }
            estados.append(estado)
        
        logger.info(f"Se obtuvieron {len(estados)} estados de venta")
        return estados

    @cacheable('estados_venta', key_func=lambda: 'todos_incluido_inactivos', ttl=7200)  # 2 horas
    def obtener_todos_incluido_inactivos(self):
        """
        Obtiene todos los estados de venta, incluyendo los inactivos.
        
        Returns:
            list: Lista de diccionarios con información de todos los estados.
        """
        query = """
        SELECT id_estado, nombre, descripcion, activo
        FROM EstadosVenta
        ORDER BY activo DESC, id_estado
        """
        
        rows = self._ejecutar_consulta(query)
        estados = []
        
        for row in rows:
            estado = {
                'id_estado': row.id_estado,
                'nombre': row.nombre,
                'descripcion': row.descripcion,
                'activo': bool(row.activo)
            }
            estados.append(estado)
        
        logger.info(f"Se obtuvieron {len(estados)} estados de venta (incluyendo inactivos)")
        return estados

    @cacheable('estados_venta', key_func=lambda id_estado: f"id_{id_estado}", ttl=3600)  # 1 hora
    def obtener_por_id(self, id_estado):
        """
        Obtiene un estado de venta por su ID.
        
        Args:
            id_estado (int): ID del estado de venta.
            
        Returns:
            dict: Información del estado de venta.
            
        Raises:
            RegistroNoEncontrado: Si el estado no existe.
        """
        query = """
        SELECT id_estado, nombre, descripcion, activo
        FROM EstadosVenta
        WHERE id_estado = ?
        """
        
        rows = self._ejecutar_consulta(query, (id_estado,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Estado de venta con ID {id_estado} no encontrado")
        
        row = rows[0]
        return {
            'id_estado': row.id_estado,
            'nombre': row.nombre,
            'descripcion': row.descripcion,
            'activo': bool(row.activo)
        }

    @cacheable('estados_venta', key_func=lambda nombre: f"nombre_{nombre.lower()}", ttl=3600)  # 1 hora
    def obtener_por_nombre(self, nombre):
        """
        Obtiene un estado de venta por su nombre.
        
        Args:
            nombre (str): Nombre del estado de venta.
            
        Returns:
            dict: Información del estado de venta o None si no existe.
        """
        query = """
        SELECT id_estado, nombre, descripcion, activo
        FROM EstadosVenta
        WHERE nombre = ? AND activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (nombre,))
        
        if not rows:
            return None
        
        row = rows[0]
        return {
            'id_estado': row.id_estado,
            'nombre': row.nombre,
            'descripcion': row.descripcion,
            'activo': bool(row.activo)
        }

    @cacheable('estados_venta', key_func=lambda texto: f"buscar_{texto.lower().replace(' ', '_')}", ttl=1800)  # 30 min
    def buscar_por_nombre_similar(self, texto_busqueda):
        """
        Busca estados de venta que coincidan con el texto de búsqueda.
        
        Args:
            texto_busqueda (str): Texto a buscar en nombre o descripción.
            
        Returns:
            list: Lista de estados que coinciden con el criterio.
        """
        query = """
        SELECT id_estado, nombre, descripcion, activo
        FROM EstadosVenta
        WHERE activo = 1 AND (
            nombre LIKE ? OR descripcion LIKE ?
        )
        ORDER BY nombre
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron))
        
        estados = []
        for row in rows:
            estado = {
                'id_estado': row.id_estado,
                'nombre': row.nombre,
                'descripcion': row.descripcion,
                'activo': bool(row.activo)
            }
            estados.append(estado)
        
        logger.info(f"Búsqueda '{texto_busqueda}': {len(estados)} estados encontrados")
        return estados

    @cacheable('estados_venta', key_func=lambda: 'estados_especiales', ttl=7200)  # 2 horas
    def obtener_estados_especiales(self):
        """
        Obtiene estados de venta especiales (Cancelado, Finalizado, etc.).
        
        Returns:
            dict: Diccionario con estados especiales por nombre.
        """
        estados_especiales = ['Cancelado', 'Finalizado', 'Entregado', 'Pendiente', 'En Proceso']
        
        query = """
        SELECT id_estado, nombre, descripcion, activo
        FROM EstadosVenta
        WHERE nombre IN ({}) AND activo = 1
        """.format(','.join(['?' for _ in estados_especiales]))
        
        rows = self._ejecutar_consulta(query, estados_especiales)
        
        estados = {}
        for row in rows:
            estados[row.nombre] = {
                'id_estado': row.id_estado,
                'nombre': row.nombre,
                'descripcion': row.descripcion,
                'activo': bool(row.activo)
            }
        
        logger.info(f"Se obtuvieron {len(estados)} estados especiales")
        return estados

    @cacheable('conteos', key_func=lambda: 'total_estados_activos', ttl=3600)  # 1 hora
    def _contar_registros_cached(self):
        """
        Cuenta total de estados de venta activos (versión cacheada).
        
        Returns:
            int: Número total de estados activos.
        """
        return self._contar_registros("EstadosVenta", "activo = 1")

    def obtener_usos_estado(self, id_estado):
        """
        Obtiene la cantidad de ventas que usan un estado específico.
        
        Args:
            id_estado (int): ID del estado.
            
        Returns:
            int: Número de ventas que usan este estado.
        """
        return self._contar_registros("Ventas", "id_estado = ?", (id_estado,))

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('estados_venta', key='todos_activos')           # Invalidar lista activos
    @cache_invalidator('estados_venta', key='todos_incluido_inactivos') # Invalidar lista completa
    @cache_invalidator('estados_venta', key='estados_especiales')      # Invalidar especiales
    @cache_invalidator('conteos', key='total_estados_activos')         # Invalidar conteos
    def crear(self, datos_estado):
        """
        Crea un nuevo estado de venta.
        
        Args:
            datos_estado (dict): Datos del estado.
            
        Returns:
            tuple: (True, id_estado) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
            RegistroYaExiste: Si ya existe un estado con el mismo nombre.
        """
        self._validar_datos_estado(datos_estado)
        
        # Verificar si el nombre ya existe
        if self._existe_nombre(datos_estado['nombre']):
            raise RegistroYaExiste(f"Ya existe un estado con nombre '{datos_estado['nombre']}'")
        
        query = """
        INSERT INTO EstadosVenta (nombre, descripcion, activo)
        VALUES (?, ?, ?)
        """
        
        valores = (
            datos_estado['nombre'],
            datos_estado.get('descripcion'),
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_estado = self._obtener_ultimo_id()
        
        logger.info(f"Estado de venta creado con ID: {id_estado}")
        return True, id_estado

    @cache_invalidator('estados_venta', pattern='id_')                 # Invalidar caché específico
    @cache_invalidator('estados_venta', pattern='nombre_')             # Invalidar búsquedas por nombre
    @cache_invalidator('estados_venta', key='todos_activos')           # Invalidar lista activos
    @cache_invalidator('estados_venta', key='todos_incluido_inactivos') # Invalidar lista completa
    @cache_invalidator('estados_venta', key='estados_especiales')      # Invalidar especiales
    def actualizar(self, id_estado, datos_estado):
        """
        Actualiza un estado de venta existente.
        
        Args:
            id_estado (int): ID del estado.
            datos_estado (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el estado no existe.
            ErrorValidacion: Si los datos no son válidos.
        """
        # Verificar que el estado existe
        estado_actual = self.obtener_por_id(id_estado)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'nombre' in datos_estado:
            # Verificar que el nuevo nombre no exista (excluyendo el registro actual)
            if self._existe_nombre_excepto(datos_estado['nombre'], id_estado):
                raise RegistroYaExiste(f"Ya existe otro estado con nombre '{datos_estado['nombre']}'")
            campos_actualizar.append("nombre = ?")
            valores.append(datos_estado['nombre'])
        
        if 'descripcion' in datos_estado:
            campos_actualizar.append("descripcion = ?")
            valores.append(datos_estado['descripcion'])
        
        if 'activo' in datos_estado:
            # Validar que no se desactive un estado en uso
            if not datos_estado['activo']:
                usos = self.obtener_usos_estado(id_estado)
                if usos > 0:
                    raise ErrorValidacion(f"No se puede desactivar el estado. Está siendo usado por {usos} ventas")
            campos_actualizar.append("activo = ?")
            valores.append(1 if datos_estado['activo'] else 0)
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        query = f"UPDATE EstadosVenta SET {', '.join(campos_actualizar)} WHERE id_estado = ?"
        valores.append(id_estado)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Estado {id_estado} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('estados_venta', pattern='id_')                 # Invalidar caché específico
    @cache_invalidator('estados_venta', key='todos_activos')           # Invalidar lista activos
    @cache_invalidator('estados_venta', key='todos_incluido_inactivos') # Invalidar lista completa
    @cache_invalidator('estados_venta', key='estados_especiales')      # Invalidar especiales
    @cache_invalidator('conteos', key='total_estados_activos')         # Invalidar conteos
    def desactivar(self, id_estado):
        """
        Desactiva un estado de venta (eliminación lógica).
        
        Args:
            id_estado (int): ID del estado.
            
        Returns:
            bool: True si se desactivó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el estado no existe.
            ErrorValidacion: Si el estado está siendo usado.
        """
        # Verificar que el estado existe
        self.obtener_por_id(id_estado)
        
        # Verificar que el estado no está siendo usado
        usos = self.obtener_usos_estado(id_estado)
        if usos > 0:
            raise ErrorValidacion(f"No se puede desactivar el estado. Está siendo usado por {usos} ventas")
        
        query = "UPDATE EstadosVenta SET activo = 0 WHERE id_estado = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_estado,), obtener_resultado=False)
        
        logger.info(f"Estado {id_estado} desactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    def reactivar(self, id_estado):
        """
        Reactiva un estado de venta desactivado.
        
        Args:
            id_estado (int): ID del estado.
            
        Returns:
            bool: True si se reactivó correctamente.
        """
        # Verificar que el estado existe (incluyendo inactivos)
        query_existe = "SELECT COUNT(*) FROM EstadosVenta WHERE id_estado = ?"
        existe = self._ejecutar_consulta_escalar(query_existe, (id_estado,))
        
        if not existe:
            raise RegistroNoEncontrado(f"Estado con ID {id_estado} no encontrado")
        
        query = "UPDATE EstadosVenta SET activo = 1 WHERE id_estado = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_estado,), obtener_resultado=False)
        
        # Invalidar cachés relevantes
        self.cache_invalidate('todos_activos')
        self.cache_invalidate('todos_incluido_inactivos')
        self.cache_invalidate('estados_especiales')
        self.cache_invalidate(f'id_{id_estado}')
        
        logger.info(f"Estado {id_estado} reactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _validar_datos_estado(self, datos):
        """
        Valida los datos del estado de venta.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('nombre') or not datos.get('nombre').strip():
            raise ErrorValidacion("El nombre del estado es obligatorio")
        
        # Validar longitud del nombre
        if len(datos['nombre'].strip()) > 50:
            raise ErrorValidacion("El nombre del estado no puede exceder 50 caracteres")
        
        # Validar caracteres especiales en nombre
        import re
        if not re.match(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-\_]+$', datos['nombre'].strip()):
            raise ErrorValidacion("El nombre del estado contiene caracteres no válidos")
    
    def _existe_nombre(self, nombre):
        """
        Verifica si un nombre de estado ya existe.
        
        Args:
            nombre (str): Nombre a verificar.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros("EstadosVenta", "nombre = ?", (nombre.strip(),))
        return count > 0
    
    def _existe_nombre_excepto(self, nombre, id_excluir):
        """
        Verifica si un nombre de estado ya existe excluyendo un ID específico.
        
        Args:
            nombre (str): Nombre a verificar.
            id_excluir (int): ID a excluir de la búsqueda.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros(
            "EstadosVenta", 
            "nombre = ? AND id_estado != ?", 
            (nombre.strip(), id_excluir)
        )
        return count > 0
    
    def obtener_estado_por_defecto(self):
        """
        Obtiene el estado por defecto para nuevas ventas.
        
        Returns:
            dict: Estado por defecto o None si no existe.
        """
        # Buscar primero "Pendiente", luego el primer estado activo
        estado = self.obtener_por_nombre('Pendiente')
        if estado:
            return estado
        
        # Si no existe "Pendiente", obtener el primer estado activo
        estados = self.obtener_todos()
        if estados:
            return estados[0]
        
        return None
    
    def obtener_estados_finales(self):
        """
        Obtiene los estados que representan ventas finalizadas.
        
        Returns:
            list: Lista de estados finales.
        """
        estados_finales = ['Finalizado', 'Entregado', 'Completado', 'Cerrado']
        
        query = """
        SELECT id_estado, nombre, descripcion, activo
        FROM EstadosVenta
        WHERE nombre IN ({}) AND activo = 1
        """.format(','.join(['?' for _ in estados_finales]))
        
        rows = self._ejecutar_consulta(query, estados_finales)
        
        estados = []
        for row in rows:
            estado = {
                'id_estado': row.id_estado,
                'nombre': row.nombre,
                'descripcion': row.descripcion,
                'activo': bool(row.activo)
            }
            estados.append(estado)
        
        return estados