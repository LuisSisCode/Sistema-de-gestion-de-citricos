# bd_conecciones/repositorio/ClientesVentasRep/cliente_repositorio.py

import logging
from datetime import datetime, timedelta
from ...core.repositorio_base import RepositorioBase
from ...core.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class ClienteRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de clientes con caché optimizado."""

    @cacheable('clientes', key_func=lambda: 'todos_activos', ttl=1800)  # 30 min
    def obtener_todos(self):
        """
        Obtiene todos los clientes activos.
        
        Returns:
            list: Lista de diccionarios con información de clientes.
        """
        query = """
        SELECT c.id_cliente, c.nombre, c.direccion, c.ciudad, c.estado_provincia,
               c.telefono, c.correo, c.condiciones_pago, c.fecha_registro,
               u.nombre AS registrado_por_nombre, c.activo
        FROM Clientes c
        LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
        WHERE c.activo = 1
        ORDER BY c.nombre
        """
        
        rows = self._ejecutar_consulta(query)
        clientes = []
        
        for row in rows:
            cliente = {
                'id_cliente': row.id_cliente,
                'nombre': row.nombre,
                'direccion': row.direccion,
                'ciudad': row.ciudad,
                'estado_provincia': row.estado_provincia,
                'telefono': row.telefono,
                'correo': row.correo,
                'condiciones_pago': row.condiciones_pago,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'registrado_por': row.registrado_por_nombre,
                'activo': bool(row.activo)
            }
            clientes.append(cliente)
        
        logger.info(f"Se obtuvieron {len(clientes)} clientes")
        return clientes

    @cacheable('clientes', key_func=lambda id_cli: f"id_{id_cli}", ttl=3600)  # 1 hora - datos específicos
    def obtener_por_id(self, id_cliente):
        """
        Obtiene un cliente por su ID.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            dict: Información del cliente.
            
        Raises:
            RegistroNoEncontrado: Si el cliente no existe.
        """
        query = """
        SELECT c.id_cliente, c.nombre, c.direccion, c.ciudad, c.estado_provincia,
               c.telefono, c.correo, c.condiciones_pago, c.fecha_registro,
               u.nombre AS registrado_por_nombre, c.activo
        FROM Clientes c
        LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
        WHERE c.id_cliente = ? AND c.activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_cliente,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Cliente con ID {id_cliente} no encontrado")
        
        row = rows[0]
        return {
            'id_cliente': row.id_cliente,
            'nombre': row.nombre,
            'direccion': row.direccion,
            'ciudad': row.ciudad,
            'estado_provincia': row.estado_provincia,
            'telefono': row.telefono,
            'correo': row.correo,
            'condiciones_pago': row.condiciones_pago,
            'fecha_registro': self._formatear_fecha(row.fecha_registro),
            'registrado_por': row.registrado_por_nombre,
            'activo': bool(row.activo)
        }

    @cacheable('clientes', key_func=lambda pagina, por_pagina=10: f"pagina_{pagina}_{por_pagina}", ttl=1200)  # 20 min
    def obtener_paginado(self, pagina, por_pagina=10):
        """
        Obtiene clientes con paginación.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Clientes, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Contar total de registros activos
        total_registros = self._contar_registros_cached()
        
        # Obtener registros paginados
        query = """
        SELECT c.id_cliente, c.nombre, c.direccion, c.ciudad, c.estado_provincia,
               c.telefono, c.correo, c.condiciones_pago, c.fecha_registro,
               u.nombre AS registrado_por_nombre, c.activo
        FROM Clientes c
        LEFT JOIN Usuarios u ON c.registrado_por = u.id_usuario
        WHERE c.activo = 1
        ORDER BY c.nombre
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        rows = self._ejecutar_consulta(query, (offset, por_pagina))
        clientes = []
        
        for row in rows:
            cliente = {
                'id_cliente': row.id_cliente,
                'nombre': row.nombre,
                'direccion': row.direccion,
                'ciudad': row.ciudad,
                'estado_provincia': row.estado_provincia,
                'telefono': row.telefono,
                'correo': row.correo,
                'condiciones_pago': row.condiciones_pago,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'registrado_por': row.registrado_por_nombre,
                'activo': bool(row.activo)
            }
            clientes.append(cliente)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'clientes': clientes,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina
        }
        
        logger.info(f"Página {pagina}: {len(clientes)} clientes de {total_registros} totales")
        return resultado

    @cacheable('clientes', key_func=lambda texto: f"buscar_{texto.lower().replace(' ', '_')}", ttl=900)  # 15 min
    def buscar_por_criterio(self, texto_busqueda):
        """
        Busca clientes que coincidan con el criterio en varios campos.
        
        Args:
            texto_busqueda (str): Texto a buscar en los campos del cliente.
            
        Returns:
            list: Lista de diccionarios con los clientes que coinciden con el criterio.
        """
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
        patron = f"%{texto_busqueda}%"
        params = (patron, patron, patron, patron, patron, patron)
        
        rows = self._ejecutar_consulta(query, params)
        clientes = []
        
        for row in rows:
            cliente = {
                'id_cliente': row.id_cliente,
                'nombre': row.nombre,
                'direccion': row.direccion,
                'ciudad': row.ciudad,
                'estado_provincia': row.estado_provincia,
                'telefono': row.telefono,
                'correo': row.correo,
                'condiciones_pago': row.condiciones_pago,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'registrado_por': row.registrado_por_nombre,
                'activo': bool(row.activo)
            }
            clientes.append(cliente)
        
        logger.info(f"Búsqueda '{texto_busqueda}': {len(clientes)} resultados")
        return clientes

    @cacheable('clientes', key_func=lambda dias: f"inactivos_{dias}", ttl=1800)  # 30 min
    def obtener_clientes_inactivos(self, dias_inactividad=90):
        """
        Obtiene los clientes que no han realizado compras en el período especificado.
        
        Args:
            dias_inactividad (int): Número de días sin compras para considerar inactivo.
            
        Returns:
            list: Lista de diccionarios con los clientes inactivos.
        """
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
        
        rows = self._ejecutar_consulta(query, (fecha_limite,))
        clientes_inactivos = []
        
        for row in rows:
            cliente = {
                'id_cliente': row.id_cliente,
                'nombre': row.nombre,
                'telefono': row.telefono,
                'correo': row.correo,
                'ultima_compra': self._formatear_fecha(row.ultima_compra),
                'dias_inactividad': row.dias_inactividad if row.dias_inactividad else dias_inactividad
            }
            clientes_inactivos.append(cliente)
        
        logger.info(f"Se obtuvieron {len(clientes_inactivos)} clientes inactivos")
        return clientes_inactivos

    @cacheable('conteos', key_func=lambda: 'total_clientes_activos', ttl=1800)  # 30 min
    def _contar_registros_cached(self):
        """
        Cuenta total de clientes activos (versión cacheada).
        
        Returns:
            int: Número total de clientes activos.
        """
        return self._contar_registros("Clientes", "activo = 1")

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('clientes', key='todos_activos')  # Invalidar lista completa
    @cache_invalidator('clientes', pattern='pagina_')    # Invalidar paginación
    @cache_invalidator('clientes', pattern='buscar_')    # Invalidar búsquedas
    @cache_invalidator('conteos', key='total_clientes_activos')  # Invalidar conteos
    def crear(self, datos_cliente):
        """
        Crea un nuevo cliente.
        OPTIMIZADO: Invalidación granular por tipos de caché.
        
        Args:
            datos_cliente (dict): Datos del cliente.
            
        Returns:
            tuple: (True, id_cliente) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
            RegistroYaExiste: Si ya existe un cliente con el mismo correo (opcional).
        """
        self._validar_datos_cliente(datos_cliente)
        
        # Verificar si el correo ya existe (solo si se proporciona)
        if datos_cliente.get('correo') and self._existe_correo(datos_cliente['correo']):
            raise RegistroYaExiste(f"Ya existe un cliente con correo {datos_cliente['correo']}")
        
        query = """
        INSERT INTO Clientes (nombre, direccion, ciudad, estado_provincia, telefono, correo,
                             condiciones_pago, fecha_registro, registrado_por, activo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        fecha_actual = datetime.now().date().strftime('%Y-%m-%d')
        valores = (
            datos_cliente['nombre'],
            datos_cliente.get('direccion'),
            datos_cliente.get('ciudad'),
            datos_cliente.get('estado_provincia'),
            datos_cliente.get('telefono'),
            datos_cliente.get('correo'),
            datos_cliente.get('condiciones_pago'),
            fecha_actual,
            datos_cliente['registrado_por'],  # ID del usuario que registra
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_cliente = self._obtener_ultimo_id()
        
        logger.info(f"Cliente creado con ID: {id_cliente}")
        return True, id_cliente

    @cache_invalidator('clientes', pattern='id_')        # Invalidar caché específico
    @cache_invalidator('clientes', key='todos_activos')  # Invalidar lista completa
    @cache_invalidator('clientes', pattern='pagina_')    # Invalidar paginación
    @cache_invalidator('clientes', pattern='buscar_')    # Invalidar búsquedas
    def actualizar(self, id_cliente, datos_cliente):
        """
        Actualiza un cliente existente.
        OPTIMIZADO: Invalidación específica del cliente y listas generales.
        
        Args:
            id_cliente (int): ID del cliente.
            datos_cliente (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el cliente no existe.
            ErrorValidacion: Si los datos no son válidos.
        """
        # Verificar que el cliente existe
        cliente_actual = self.obtener_por_id(id_cliente)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'nombre' in datos_cliente:
            campos_actualizar.append("nombre = ?")
            valores.append(datos_cliente['nombre'])
            
        if 'direccion' in datos_cliente:
            campos_actualizar.append("direccion = ?")
            valores.append(datos_cliente['direccion'])
            
        if 'ciudad' in datos_cliente:
            campos_actualizar.append("ciudad = ?")
            valores.append(datos_cliente['ciudad'])
            
        if 'estado_provincia' in datos_cliente:
            campos_actualizar.append("estado_provincia = ?")
            valores.append(datos_cliente['estado_provincia'])
            
        if 'telefono' in datos_cliente:
            campos_actualizar.append("telefono = ?")
            valores.append(datos_cliente['telefono'])
            
        if 'correo' in datos_cliente:
            # Verificar que el nuevo correo no exista (excluyendo el registro actual)
            if self._existe_correo_excepto(datos_cliente['correo'], id_cliente):
                raise RegistroYaExiste(f"Ya existe otro cliente con correo {datos_cliente['correo']}")
            campos_actualizar.append("correo = ?")
            valores.append(datos_cliente['correo'])
            
        if 'condiciones_pago' in datos_cliente:
            campos_actualizar.append("condiciones_pago = ?")
            valores.append(datos_cliente['condiciones_pago'])
        
        if 'activo' in datos_cliente:
            campos_actualizar.append("activo = ?")
            valores.append(1 if datos_cliente['activo'] else 0)
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        query = f"UPDATE Clientes SET {', '.join(campos_actualizar)} WHERE id_cliente = ?"
        valores.append(id_cliente)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Cliente {id_cliente} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('clientes', pattern='id_')        # Invalidar caché específico
    @cache_invalidator('clientes', key='todos_activos')  # Invalidar lista completa
    @cache_invalidator('clientes', pattern='pagina_')    # Invalidar paginación
    @cache_invalidator('clientes', pattern='buscar_')    # Invalidar búsquedas
    @cache_invalidator('conteos', key='total_clientes_activos')  # Invalidar conteos
    def desactivar(self, id_cliente):
        """
        Desactiva un cliente (eliminación lógica).
        OPTIMIZADO: Invalidación completa ya que afecta todas las listas.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            bool: True si se desactivó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el cliente no existe.
        """
        # Verificar que el cliente existe
        self.obtener_por_id(id_cliente)
        
        # Verificar si el cliente tiene ventas asociadas
        ventas_count = self._contar_registros("Ventas", "id_cliente = ?", (id_cliente,))
        
        if ventas_count > 0:
            logger.warning(f"Cliente {id_cliente} tiene {ventas_count} ventas asociadas, pero se procede con desactivación lógica")
        
        query = "UPDATE Clientes SET activo = 0 WHERE id_cliente = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_cliente,), obtener_resultado=False)
        
        logger.info(f"Cliente {id_cliente} desactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _validar_datos_cliente(self, datos):
        """
        Valida los datos del cliente.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('nombre') or not datos.get('nombre').strip():
            raise ErrorValidacion("El nombre del cliente es obligatorio")
        
        # Validar formato de correo si se proporciona
        if datos.get('correo'):
            import re
            email_regex = r'\w+([-+.\']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*'
            if not re.match(email_regex, datos['correo']):
                raise ErrorValidacion("El formato del correo electrónico no es válido")
        
        # Validar que registrado_por esté presente
        if not datos.get('registrado_por'):
            raise ErrorValidacion("El campo registrado_por es obligatorio")
    
    def _existe_correo(self, correo):
        """
        Verifica si un correo ya existe.
        
        Args:
            correo (str): Correo a verificar.
            
        Returns:
            bool: True si existe.
        """
        if not correo:
            return False
            
        count = self._contar_registros("Clientes", "correo = ? AND activo = 1", (correo,))
        return count > 0
    
    def _existe_correo_excepto(self, correo, id_excluir):
        """
        Verifica si un correo ya existe excluyendo un ID específico.
        
        Args:
            correo (str): Correo a verificar.
            id_excluir (int): ID a excluir de la búsqueda.
            
        Returns:
            bool: True si existe.
        """
        if not correo:
            return False
            
        count = self._contar_registros(
            "Clientes", 
            "correo = ? AND activo = 1 AND id_cliente != ?", 
            (correo, id_excluir)
        )
        return count > 0