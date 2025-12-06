# bd_conecciones/repositorios/parcela_repositorio.py

import logging
from datetime import datetime
from ...core.repositorio_base import RepositorioBase
from ...core.excepciones_bd import RegistroNoEncontrado, ErrorValidacion
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class ParcelaRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de parcelas con funcionalidades extendidas."""
    
    @cacheable('parcelas', key_func=lambda: 'todas_activas', ttl=1800)  # 30 min
    def obtener_todas(self):
        """
        Obtiene todas las parcelas activas con información de productores.
        
        Returns:
            list: Lista de diccionarios con información de parcelas.
        """
        query = """
        SELECT 
            p.id_parcela, 
            p.nombre, 
            p.ubicacion, 
            p.area_total,
            p.fecha_adquisicion, 
            p.activo, 
            p.id_productor,
            prod.nombre as nombre_productor,
            prod.apellido as apellido_productor,
            CONCAT(prod.nombre, ' ', prod.apellido) AS nombre_productor_completo
        FROM Parcelas p
        JOIN Productores prod ON p.id_productor = prod.id_productor
        ORDER BY p.id_parcelas DESC
        """
        
        try:
            rows = self._ejecutar_consulta(query)
            parcelas = []
            
            for row in rows:
                parcela = self._construir_objeto_parcela(row)
                parcelas.append(parcela)
            
            logger.info(f"Se obtuvieron {len(parcelas)} parcelas correctamente")
            return parcelas
            
        except Exception as e:
            logger.error(f"Error en obtener_todas: {str(e)}")
            raise

    @cacheable('parcelas', key_func=lambda id_parcela: f"id_{id_parcela}", ttl=3600)  # 1 hora
    def obtener_por_id(self, id_parcela):
        """
        Obtiene una parcela por su ID.
        
        Args:
            id_parcela (int): ID de la parcela.
            
        Returns:
            dict: Información de la parcela.
            
        Raises:
            RegistroNoEncontrado: Si la parcela no existe.
        """
        query = """
        SELECT 
            p.id_parcela, 
            p.nombre, 
            p.ubicacion, 
            p.area_total,
            p.fecha_adquisicion, 
            p.activo, 
            p.id_productor,
            prod.nombre as nombre_productor,
            prod.apellido as apellido_productor,
            CONCAT(prod.nombre, ' ', prod.apellido) AS nombre_productor_completo
        FROM Parcelas p
        JOIN Productores prod ON p.id_productor = prod.id_productor
        WHERE p.id_parcela = ? AND p.activo = 1 AND prod.activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_parcela,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Parcela con ID {id_parcela} no encontrada")
        
        return self._construir_objeto_parcela(rows[0])

    @cacheable('parcelas', key_func=lambda id_prod: f"productor_{id_prod}", ttl=1800)  # 30 min
    def obtener_por_productor(self, id_productor):
        """
        Obtiene parcelas de un productor específico.
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            list: Lista de parcelas del productor.
        """
        query = """
        SELECT 
            p.id_parcela, 
            p.nombre, 
            p.ubicacion, 
            p.area_total,
            p.fecha_adquisicion, 
            p.activo, 
            p.id_productor,
            prod.nombre as nombre_productor,
            prod.apellido as apellido_productor,
            CONCAT(prod.nombre, ' ', prod.apellido) AS nombre_productor_completo
        FROM Parcelas p
        JOIN Productores prod ON p.id_productor = prod.id_productor
        WHERE p.id_productor = ? AND p.activo = 1 AND prod.activo = 1
        ORDER BY p.nombre
        """
        
        rows = self._ejecutar_consulta(query, (id_productor,))
        parcelas = []
        
        for row in rows:
            parcela = self._construir_objeto_parcela(row)
            parcelas.append(parcela)
        
        logger.info(f"Se obtuvieron {len(parcelas)} parcelas del productor {id_productor}")
        return parcelas

    @cacheable('parcelas', key_func=lambda pagina, por_pagina=6, prod_id=None: f"pag_{pagina}_{por_pagina}_{prod_id or 'all'}", ttl=1200)  # 20 min
    def obtener_paginado(self, pagina, por_pagina=6, productor_id=None):
        """
        Obtiene parcelas con paginación y filtro opcional por productor.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            productor_id (int, optional): ID del productor para filtrar.
            
        Returns:
            dict: Parcelas, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Construir condiciones WHERE
        where_clause = "p.activo = 1 AND prod.activo = 1"
        params_count = []
        params_data = []
        
        if productor_id and productor_id != 0:
            where_clause += " AND p.id_productor = ?"
            params_count.append(productor_id)
            params_data.append(productor_id)
        
        # Contar total de registros (ahora cacheado)
        total_registros = self._contar_registros_cached(productor_id)
        
        # Obtener registros paginados
        data_query = f"""
        SELECT 
            p.id_parcela, 
            p.nombre, 
            p.ubicacion, 
            p.area_total,
            p.fecha_adquisicion, 
            p.activo, 
            p.id_productor,
            prod.nombre as nombre_productor,
            prod.apellido as apellido_productor,
            CONCAT(prod.nombre, ' ', prod.apellido) AS nombre_productor_completo
        FROM Parcelas p
        JOIN Productores prod ON p.id_productor = prod.id_productor
        WHERE {where_clause}
        ORDER BY p.nombre
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        params_data.extend([offset, por_pagina])
        rows = self._ejecutar_consulta(data_query, params_data)
        
        parcelas = []
        for row in rows:
            parcela = self._construir_objeto_parcela(row)
            parcelas.append(parcela)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'parcelas': parcelas,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina
        }
        
        logger.info(f"Página {pagina}: {len(parcelas)} parcelas de {total_registros} totales")
        return resultado

    @cacheable('busquedas', key_func=lambda texto: f"parcelas_{texto.lower().replace(' ', '_')}", ttl=900)  # 15 min
    def buscar_por_nombre(self, texto_busqueda):
        """
        Busca parcelas por nombre o ubicación.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de parcelas que coinciden.
        """
        query = """
        SELECT 
            p.id_parcela, 
            p.nombre, 
            p.ubicacion, 
            p.area_total,
            p.fecha_adquisicion, 
            p.activo, 
            p.id_productor,
            prod.nombre as nombre_productor,
            prod.apellido as apellido_productor,
            CONCAT(prod.nombre, ' ', prod.apellido) AS nombre_productor_completo
        FROM Parcelas p
        JOIN Productores prod ON p.id_productor = prod.id_productor
        WHERE p.activo = 1 AND prod.activo = 1 
        AND (p.nombre LIKE ? OR p.ubicacion LIKE ?)
        ORDER BY p.nombre
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron))
        
        parcelas = []
        for row in rows:
            parcela = self._construir_objeto_parcela(row)
            parcelas.append(parcela)
        
        logger.info(f"Búsqueda '{texto_busqueda}': {len(parcelas)} resultados")
        return parcelas

    @cacheable('estadisticas', key_func=lambda: 'parcelas_basicas', ttl=1800)  # 30 min
    def obtener_estadisticas_basicas(self):
        """
        Obtiene estadísticas básicas de las parcelas.
        
        Returns:
            dict: Estadísticas de parcelas.
        """
        query = """
        SELECT 
            COUNT(*) as total_parcelas,
            COALESCE(SUM(area_total), 0) as area_total,
            COALESCE(AVG(area_total), 0) as area_promedio,
            COUNT(DISTINCT id_productor) as productores_distintos
        FROM Parcelas 
        WHERE activo = 1
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        estadisticas = {
            'total_parcelas': row.total_parcelas,
            'area_total': float(row.area_total),
            'area_promedio': float(row.area_promedio),
            'productores_distintos': row.productores_distintos
        }
        
        logger.info(f"Estadísticas calculadas: {estadisticas}")
        return estadisticas

    @cacheable('estadisticas', key_func=lambda: 'generales_completas', ttl=1800)  # 30 min
    def obtener_estadisticas_generales(self):
        """
        Obtiene estadísticas generales del sistema.
        
        Returns:
            dict: Estadísticas completas del sistema.
        """
        query = """
        SELECT 
            (SELECT COUNT(*) FROM Productores WHERE activo = 1) as total_productores,
            (SELECT COUNT(*) FROM Parcelas WHERE activo = 1) as total_parcelas,
            (SELECT COALESCE(SUM(area_total), 0) FROM Parcelas WHERE activo = 1) as area_total,
            (SELECT COALESCE(AVG(area_total), 0) FROM Parcelas WHERE activo = 1) as area_promedio
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        estadisticas = {
            'productores': {
                'total': row.total_productores
            },
            'parcelas': {
                'total': row.total_parcelas,
                'area_total': float(row.area_total),
                'area_promedio': float(row.area_promedio)
            }
        }
        
        logger.info(f"Estadísticas generales calculadas: {estadisticas}")
        return estadisticas

    @cacheable('validaciones', key_func=lambda id_parcela, nuevo_prod: f"transfer_{id_parcela}_{nuevo_prod}", ttl=300)  # 5 min
    def validar_transferencia_parcela(self, id_parcela, nuevo_productor_id):
        """
        Valida si se puede transferir una parcela a un nuevo productor.
        
        Args:
            id_parcela (int): ID de la parcela.
            nuevo_productor_id (int): ID del nuevo productor.
            
        Returns:
            dict: Información de validación.
            
        Raises:
            RegistroNoEncontrado: Si la parcela o productor no existen.
        """
        # Verificar que la parcela existe y está activa
        parcela_query = "SELECT id_productor, nombre FROM Parcelas WHERE id_parcela = ? AND activo = 1"
        parcela_rows = self._ejecutar_consulta(parcela_query, (id_parcela,))
        
        if not parcela_rows:
            raise RegistroNoEncontrado(f"Parcela con ID {id_parcela} no encontrada")
        
        productor_actual_id = parcela_rows[0].id_productor
        nombre_parcela = parcela_rows[0].nombre
        
        # Verificar que el nuevo productor existe y está activo
        productor_query = """
        SELECT nombre, apellido 
        FROM Productores
        WHERE id_productor = ? AND activo = 1
        """
        productor_rows = self._ejecutar_consulta(productor_query, (nuevo_productor_id,))
        
        if not productor_rows:
            raise RegistroNoEncontrado(f"Productor con ID {nuevo_productor_id} no encontrado")
        
        nuevo_productor_nombre = f"{productor_rows[0].nombre} {productor_rows[0].apellido}"
        
        # Obtener información del productor actual
        productor_actual_query = """
        SELECT nombre, apellido 
        FROM Productores 
        WHERE id_productor = ?
        """
        productor_actual_rows = self._ejecutar_consulta(productor_actual_query, (productor_actual_id,))
        productor_actual_nombre = f"{productor_actual_rows[0].nombre} {productor_actual_rows[0].apellido}"
        
        validacion = {
            'puede_transferir': productor_actual_id != nuevo_productor_id,
            'parcela_nombre': nombre_parcela,
            'productor_actual': {
                'id': productor_actual_id,
                'nombre': productor_actual_nombre
            },
            'nuevo_productor': {
                'id': nuevo_productor_id,
                'nombre': nuevo_productor_nombre
            }
        }
        
        if not validacion['puede_transferir']:
            logger.warning(f"Intento de transferir parcela {id_parcela} al mismo productor")
        else:
            logger.info(f"Transferencia validada: parcela {id_parcela} puede pasar de {productor_actual_nombre} a {nuevo_productor_nombre}")
        
        return validacion

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('parcelas', key='todas_activas')           # Lista completa
    @cache_invalidator('parcelas', pattern='pag_')               # Paginación
    @cache_invalidator('parcelas', pattern='productor_')         # Por productor
    @cache_invalidator('estadisticas', key='parcelas_basicas')   # Estadísticas
    @cache_invalidator('estadisticas', key='generales_completas') # Estadísticas generales
    @cache_invalidator('conteos')                                # Conteos
    def crear(self, datos_parcela):
        """
        Crea una nueva parcela.
        
        Args:
            datos_parcela (dict): Datos de la parcela.
            
        Returns:
            tuple: (True, id_parcela) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        self._validar_datos_parcela(datos_parcela)
        
        query = """
        INSERT INTO Parcelas (id_productor, nombre, ubicacion, area_total,
                            fecha_adquisicion, activo)
        VALUES (?, ?, ?, ?, ?, ?)
        """
        
        fecha_actual = datetime.now().date().strftime('%Y-%m-%d')
        valores = (
            datos_parcela['id_productor'],
            datos_parcela['nombre'],
            datos_parcela['ubicacion'],
            datos_parcela['area_total'],
            datos_parcela.get('fecha_adquisicion', fecha_actual),
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_parcela = self._obtener_ultimo_id()
        
        logger.info(f"Parcela creada con ID: {id_parcela}")
        return True, id_parcela

    @cache_invalidator('parcelas', pattern='id_')                # Específica
    @cache_invalidator('parcelas', key='todas_activas')          # Lista completa
    @cache_invalidator('parcelas', pattern='pag_')              # Paginación
    @cache_invalidator('parcelas', pattern='productor_')        # Por productor
    @cache_invalidator('estadisticas', key='parcelas_basicas')  # Estadísticas
    @cache_invalidator('estadisticas', key='generales_completas') # Estadísticas generales
    @cache_invalidator('conteos')                               # Conteos
    def actualizar(self, id_parcela, datos_parcela):
        """
        Actualiza una parcela existente.
        
        Args:
            id_parcela (int): ID de la parcela.
            datos_parcela (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si la parcela no existe.
            ErrorValidacion: Si los datos no son válidos.
        """
        # Verificar que la parcela existe
        self.obtener_por_id(id_parcela)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'nombre' in datos_parcela:
            campos_actualizar.append("nombre = ?")
            valores.append(datos_parcela['nombre'])
            
        if 'id_productor' in datos_parcela:
            campos_actualizar.append("id_productor = ?")
            valores.append(datos_parcela['id_productor'])
            
        if 'ubicacion' in datos_parcela:
            campos_actualizar.append("ubicacion = ?")
            valores.append(datos_parcela['ubicacion'])
            
        if 'area_total' in datos_parcela:
            campos_actualizar.append("area_total = ?")
            valores.append(datos_parcela['area_total'])
            
        if 'fecha_adquisicion' in datos_parcela:
            campos_actualizar.append("fecha_adquisicion = ?")
            valores.append(datos_parcela['fecha_adquisicion'])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        query = f"UPDATE Parcelas SET {', '.join(campos_actualizar)} WHERE id_parcela = ?"
        valores.append(id_parcela)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Parcela {id_parcela} actualizada. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('parcelas', pattern='id_')                # Específica
    @cache_invalidator('parcelas', key='todas_activas')          # Lista completa
    @cache_invalidator('parcelas', pattern='pag_')              # Paginación  
    @cache_invalidator('parcelas', pattern='productor_')        # Por productor
    @cache_invalidator('estadisticas', key='parcelas_basicas')  # Estadísticas
    @cache_invalidator('estadisticas', key='generales_completas') # Estadísticas generales
    @cache_invalidator('conteos')                               # Conteos
    def desactivar(self, id_parcela):
        """
        Desactiva una parcela (eliminación lógica).
        
        Args:
            id_parcela (int): ID de la parcela.
            
        Returns:
            bool: True si se desactivó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si la parcela no existe.
        """
        # Verificar que la parcela existe
        self.obtener_por_id(id_parcela)
        
        query = "UPDATE Parcelas SET activo = 0 WHERE id_parcela = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_parcela,), obtener_resultado=False)
        
        logger.info(f"Parcela {id_parcela} desactivada. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('conteos', key_func=lambda prod_id=None: f"total_{prod_id or 'all'}", ttl=1800)  # 30 min
    def _contar_registros_cached(self, productor_id=None):
        """
        Cuenta registros de parcelas (versión cacheada).
        
        Args:
            productor_id (int, optional): ID del productor para filtrar.
            
        Returns:
            int: Número total de parcelas.
        """
        if productor_id and productor_id != 0:
            count_query = """
            SELECT COUNT(*)
            FROM Parcelas p
            JOIN Productores prod ON p.id_productor = prod.id_productor
            WHERE p.activo = 1 AND prod.activo = 1 AND p.id_productor = ?
            """
            return self._ejecutar_consulta_escalar(count_query, (productor_id,))
        else:
            count_query = """
            SELECT COUNT(*)
            FROM Parcelas p
            JOIN Productores prod ON p.id_productor = prod.id_productor
            WHERE p.activo = 1 AND prod.activo = 1
            """
            return self._ejecutar_consulta_escalar(count_query)

    def _construir_objeto_parcela(self, row):
        """
        Construye un objeto parcela a partir de una fila de la base de datos.
        Incluye información del estado del productor.
        
        Args:
            row: Fila de la consulta.
            
        Returns:
            dict: Objeto parcela estructurado.
        """
        from random import randint
        porcentaje_uso = randint(50, 100)
        
        area_total = float(row.area_total) if row.area_total else 0.0
        
        # Determinar si el productor está activo
        productor_activo = bool(getattr(row, 'productor_activo', 1))
        
        return {
            'id_parcela': row.id_parcela,
            'id': row.id_parcela,
            'parcelaId': row.id_parcela,
            'nombre': row.nombre or 'Sin nombre',
            
            # Información del productor
            'productor': getattr(row, 'nombre_productor_completo', '') or 'Productor desconocido',
            'nombre_productor': getattr(row, 'nombre_productor', ''),
            'apellido_productor': getattr(row, 'apellido_productor', ''),
            'id_productor': row.id_productor,
            'productor_activo': productor_activo,
            'estado_productor': 'Activo' if productor_activo else 'Inactivo',
            
            # Ubicación y área
            'ubicacion': row.ubicacion or '',
            'area': area_total,
            'area_total': area_total,
            'area_texto': f"{area_total:,.2f} ha",

            'fecha_adquisicion': self._formatear_fecha(row.fecha_adquisicion),
            'porcentaje_uso': porcentaje_uso,
            'activo': bool(row.activo)
        }

    # ==================== MÉTODOS DE VALIDACIÓN ====================
    
    def _validar_datos_parcela(self, datos):
        """
        Valida los datos de la parcela.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('nombre') or not datos.get('nombre').strip():
            raise ErrorValidacion("El nombre de la parcela es obligatorio")
            
        if not datos.get('ubicacion') or not datos.get('ubicacion').strip():
            raise ErrorValidacion("La ubicación es obligatoria")
        
        if not datos.get('id_productor'):
            raise ErrorValidacion("El productor es obligatorio")
        
        if not datos.get('area_total') or datos.get('area_total') <= 0:
            raise ErrorValidacion("El área total debe ser mayor a 0")