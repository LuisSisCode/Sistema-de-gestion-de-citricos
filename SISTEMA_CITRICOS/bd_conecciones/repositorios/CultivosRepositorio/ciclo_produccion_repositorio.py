# bd_conecciones/repositorios/ciclo_produccion_repositorio.py

import logging
from datetime import datetime, date
from ...nucleo.repositorio_base import RepositorioBase
from ...nucleo.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class CicloProduccionRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de ciclos de producción con caché optimizado."""

    # Estados válidos para ciclos de producción
    ESTADOS_VALIDOS = [
        'Planificado', 'En Preparación', 'Sembrado', 
        'En Desarrollo', 'En Cosecha', 'Finalizado', 'Cancelado'
    ]

    @cacheable('ciclos_produccion', key_func=lambda: 'todos_activos', ttl=900)  # 15 min
    def obtener_todos(self):
        """
        Obtiene todos los ciclos de producción activos con información completa.
        
        Returns:
            list: Lista de diccionarios con información de ciclos de producción.
        """
        query = """
        SELECT c.id_ciclo, c.id_parcela, c.id_variedad, c.fecha_siembra, 
               c.fecha_cosecha_estimada, c.fecha_cosecha_real, c.area_sembrada,
               c.densidad_siembra, c.estado, c.activo,
               c.fecha_floracion, c.fecha_poda, c.fecha_limpieza, c.frecuencia_limpieza,
               p.nombre AS nombre_parcela, 
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
        WHERE c.activo = 1 AND p.activo = 1 AND v.activo = 1 AND t.activo = 1 AND a.activo = 1
        ORDER BY c.fecha_siembra DESC
        """
        
        rows = self._ejecutar_consulta(query)
        ciclos = []
        
        for row in rows:
            ciclo = self._construir_objeto_ciclo_produccion(row)
            ciclos.append(ciclo)
        
        logger.info(f"Se obtuvieron {len(ciclos)} ciclos de producción")
        return ciclos

    @cacheable('ciclos_produccion', key_func=lambda id_ciclo: f"id_{id_ciclo}", ttl=1800)  # 30 min
    def obtener_por_id(self, id_ciclo):
        """
        Obtiene un ciclo de producción por su ID.
        
        Args:
            id_ciclo (int): ID del ciclo de producción.
            
        Returns:
            dict: Información del ciclo de producción.
            
        Raises:
            RegistroNoEncontrado: Si el ciclo no existe.
        """
        query = """
        SELECT c.id_ciclo, c.id_parcela, c.id_variedad, c.fecha_siembra, 
               c.fecha_cosecha_estimada, c.fecha_cosecha_real, c.area_sembrada,
               c.densidad_siembra, c.estado, c.activo,
               c.fecha_floracion, c.fecha_poda, c.fecha_limpieza, c.frecuencia_limpieza,
               p.nombre AS nombre_parcela, 
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
        WHERE c.id_ciclo = ? AND c.activo = 1 AND p.activo = 1 AND v.activo = 1 AND t.activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_ciclo,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Ciclo de producción con ID {id_ciclo} no encontrado")
        
        return self._construir_objeto_ciclo_produccion(rows[0])

    @cacheable('ciclos_produccion', key_func=lambda id_parcela: f"parcela_{id_parcela}", ttl=900)  # 15 min
    def obtener_por_parcela(self, id_parcela):
        """
        Obtiene ciclos de producción de una parcela específica.
        
        Args:
            id_parcela (int): ID de la parcela.
            
        Returns:
            list: Lista de ciclos de la parcela.
        """
        query = """
        SELECT c.id_ciclo, c.id_parcela, c.id_variedad, c.fecha_siembra, 
               c.fecha_cosecha_estimada, c.fecha_cosecha_real, c.area_sembrada,
               c.densidad_siembra, c.estado, c.activo,
               c.fecha_floracion, c.fecha_poda, c.fecha_limpieza, c.frecuencia_limpieza,
               p.nombre AS nombre_parcela, 
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
        WHERE c.id_parcela = ? AND c.activo = 1 AND p.activo = 1 AND v.activo = 1 AND t.activo = 1
        ORDER BY c.fecha_siembra DESC
        """
        
        rows = self._ejecutar_consulta(query, (id_parcela,))
        ciclos = []
        
        for row in rows:
            ciclo = self._construir_objeto_ciclo_produccion(row)
            ciclos.append(ciclo)
        
        logger.info(f"Se obtuvieron {len(ciclos)} ciclos de la parcela {id_parcela}")
        return ciclos

    @cacheable('ciclos_produccion', key_func=lambda estado: f"estado_{estado}", ttl=600)  # 10 min
    def obtener_por_estado(self, estado):
        """
        Obtiene ciclos de producción filtrados por estado.
        
        Args:
            estado (str): Estado del ciclo.
            
        Returns:
            list: Lista de ciclos con el estado especificado.
        """
        if estado not in self.ESTADOS_VALIDOS:
            raise ErrorValidacion(f"Estado no válido: {estado}. Estados válidos: {self.ESTADOS_VALIDOS}")
        
        query = """
        SELECT c.id_ciclo, c.id_parcela, c.id_variedad, c.fecha_siembra, 
               c.fecha_cosecha_estimada, c.fecha_cosecha_real, c.area_sembrada,
               c.densidad_siembra, c.estado, c.activo,
               c.fecha_floracion, c.fecha_poda, c.fecha_limpieza, c.frecuencia_limpieza,
               p.nombre AS nombre_parcela, 
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
        WHERE c.estado = ? AND c.activo = 1 AND p.activo = 1 AND v.activo = 1 AND t.activo = 1
        ORDER BY c.fecha_siembra DESC
        """
        
        rows = self._ejecutar_consulta(query, (estado,))
        ciclos = []
        
        for row in rows:
            ciclo = self._construir_objeto_ciclo_produccion(row)
            ciclos.append(ciclo)
        
        logger.info(f"Se obtuvieron {len(ciclos)} ciclos en estado '{estado}'")
        return ciclos

    @cacheable('ciclos_produccion', key_func=lambda pagina, por_pagina=10, filtros=None: f"pag_{pagina}_{por_pagina}_{hash(str(filtros or {}))}", ttl=600)  # 10 min
    def obtener_paginado(self, pagina, por_pagina=10, filtros=None):
        """
        Obtiene ciclos con paginación y filtros opcionales.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            filtros (dict, optional): Filtros a aplicar (estado, parcela, fecha_desde, fecha_hasta).
            
        Returns:
            dict: Ciclos, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Construir condiciones WHERE
        where_clauses = ["c.activo = 1 AND p.activo = 1 AND v.activo = 1 AND t.activo = 1"]
        params_count = []
        params_data = []
        
        if filtros:
            if filtros.get('estado'):
                where_clauses.append("c.estado = ?")
                params_count.append(filtros['estado'])
                params_data.append(filtros['estado'])
                
            if filtros.get('id_parcela'):
                where_clauses.append("c.id_parcela = ?")
                params_count.append(filtros['id_parcela'])
                params_data.append(filtros['id_parcela'])
                
            if filtros.get('fecha_desde'):
                where_clauses.append("c.fecha_siembra >= ?")
                params_count.append(filtros['fecha_desde'])
                params_data.append(filtros['fecha_desde'])
                
            if filtros.get('fecha_hasta'):
                where_clauses.append("c.fecha_siembra <= ?")
                params_count.append(filtros['fecha_hasta'])
                params_data.append(filtros['fecha_hasta'])
        
        where_clause = " AND ".join(where_clauses)
        
        # Contar total de registros
        total_registros = self._contar_registros_cached(filtros)
        
        # Obtener registros paginados
        data_query = f"""
        SELECT c.id_ciclo, c.id_parcela, c.id_variedad, c.fecha_siembra, 
               c.fecha_cosecha_estimada, c.fecha_cosecha_real, c.area_sembrada,
               c.densidad_siembra, c.estado, c.activo,
               c.fecha_floracion, c.fecha_poda, c.fecha_limpieza, c.frecuencia_limpieza,
               p.nombre AS nombre_parcela, 
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
        WHERE {where_clause}
        ORDER BY c.fecha_siembra DESC
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        params_data.extend([offset, por_pagina])
        rows = self._ejecutar_consulta(data_query, params_data)
        
        ciclos = []
        for row in rows:
            ciclo = self._construir_objeto_ciclo_produccion(row)
            ciclos.append(ciclo)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'ciclos': ciclos,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina,
            'filtros_aplicados': filtros or {}
        }
        
        logger.info(f"Página {pagina}: {len(ciclos)} ciclos de {total_registros} totales")
        return resultado

    @cacheable('ciclos_produccion', key_func=lambda: 'ciclos_activos', ttl=600)  # 10 min
    def obtener_ciclos_activos(self):
        """
        Obtiene ciclos de producción que están en proceso (no finalizados ni cancelados).
        
        Returns:
            list: Lista de ciclos activos.
        """
        estados_activos = ['Planificado', 'En Preparación', 'Sembrado', 'En Desarrollo', 'En Cosecha']
        placeholders = ','.join(['?' for _ in estados_activos])
        
        query = f"""
        SELECT c.id_ciclo, c.id_parcela, c.id_variedad, c.fecha_siembra, 
               c.fecha_cosecha_estimada, c.fecha_cosecha_real, c.area_sembrada,
               c.densidad_siembra, c.estado, c.activo,
               c.fecha_floracion, c.fecha_poda, c.fecha_limpieza, c.frecuencia_limpieza,
               p.nombre AS nombre_parcela, 
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
        WHERE c.estado IN ({placeholders}) AND c.activo = 1 AND p.activo = 1 AND v.activo = 1 AND t.activo = 1
        ORDER BY c.fecha_siembra DESC
        """
        
        rows = self._ejecutar_consulta(query, estados_activos)
        ciclos = []
        
        for row in rows:
            ciclo = self._construir_objeto_ciclo_produccion(row)
            ciclos.append(ciclo)
        
        logger.info(f"Se obtuvieron {len(ciclos)} ciclos activos")
        return ciclos

    @cacheable('estadisticas_ciclos', key_func=lambda filtros=None: f"conteo_{hash(str(filtros or {}))}", ttl=900)  # 15 min
    def _contar_registros_cached(self, filtros=None):
        """
        Cuenta registros de ciclos con filtros opcionales (versión cacheada).
        
        Args:
            filtros (dict, optional): Filtros a aplicar.
            
        Returns:
            int: Número total de ciclos.
        """
        where_clauses = ["c.activo = 1 AND p.activo = 1 AND v.activo = 1 AND t.activo = 1"]
        params = []
        
        if filtros:
            if filtros.get('estado'):
                where_clauses.append("c.estado = ?")
                params.append(filtros['estado'])
                
            if filtros.get('id_parcela'):
                where_clauses.append("c.id_parcela = ?")
                params.append(filtros['id_parcela'])
                
            if filtros.get('fecha_desde'):
                where_clauses.append("c.fecha_siembra >= ?")
                params.append(filtros['fecha_desde'])
                
            if filtros.get('fecha_hasta'):
                where_clauses.append("c.fecha_siembra <= ?")
                params.append(filtros['fecha_hasta'])
        
        where_clause = " AND ".join(where_clauses)
        
        count_query = f"""
        SELECT COUNT(*)
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE {where_clause}
        """
        
        return self._ejecutar_consulta_escalar(count_query, params)

    @cacheable('estadisticas_ciclos', key_func=lambda: 'estadisticas_basicas', ttl=900)  # 15 min
    def obtener_estadisticas(self):
        """
        Obtiene estadísticas básicas de ciclos de producción.
        
        Returns:
            dict: Estadísticas de ciclos.
        """
        query = """
        SELECT 
            COUNT(*) as total_ciclos,
            COUNT(DISTINCT c.id_parcela) as parcelas_con_ciclos,
            COUNT(DISTINCT c.id_variedad) as variedades_utilizadas,
            SUM(c.area_sembrada) as area_total_sembrada,
            AVG(c.area_sembrada) as area_promedio_ciclo,
            COUNT(CASE WHEN c.estado IN ('Planificado', 'En Preparación', 'Sembrado', 'En Desarrollo', 'En Cosecha') THEN 1 END) as ciclos_activos,
            COUNT(CASE WHEN c.estado = 'Finalizado' THEN 1 END) as ciclos_finalizados,
            COUNT(CASE WHEN c.estado = 'Cancelado' THEN 1 END) as ciclos_cancelados
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        WHERE c.activo = 1 AND p.activo = 1 AND v.activo = 1
        """
        
        rows = self._ejecutar_consulta(query)
        if rows:
            row = rows[0]
            stats = {
                'total_ciclos': row.total_ciclos,
                'parcelas_con_ciclos': row.parcelas_con_ciclos,
                'variedades_utilizadas': row.variedades_utilizadas,
                'area_total_sembrada': float(row.area_total_sembrada) if row.area_total_sembrada else 0,
                'area_promedio_ciclo': float(row.area_promedio_ciclo) if row.area_promedio_ciclo else 0,
                'ciclos_activos': row.ciclos_activos,
                'ciclos_finalizados': row.ciclos_finalizados,
                'ciclos_cancelados': row.ciclos_cancelados
            }
        else:
            stats = {
                'total_ciclos': 0, 'parcelas_con_ciclos': 0, 'variedades_utilizadas': 0,
                'area_total_sembrada': 0, 'area_promedio_ciclo': 0,
                'ciclos_activos': 0, 'ciclos_finalizados': 0, 'ciclos_cancelados': 0
            }
        
        # Obtener distribución por estado
        estado_query = """
        SELECT estado, COUNT(*) as cantidad
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        WHERE c.activo = 1 AND p.activo = 1
        GROUP BY estado
        ORDER BY cantidad DESC
        """
        
        estado_rows = self._ejecutar_consulta(estado_query)
        stats['distribucion_estados'] = {row.estado: row.cantidad for row in estado_rows}
        
        logger.info(f"Estadísticas ciclos de producción: {stats}")
        return stats

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('ciclos_produccion', key='todos_activos')       # Lista completa
    @cache_invalidator('ciclos_produccion', pattern='pag_')            # Paginación
    @cache_invalidator('ciclos_produccion', pattern='parcela_')        # Por parcela
    @cache_invalidator('ciclos_produccion', pattern='estado_')         # Por estado
    @cache_invalidator('ciclos_produccion', key='ciclos_activos')      # Ciclos activos
    @cache_invalidator('estadisticas_ciclos')                          # Estadísticas
    def crear(self, datos_ciclo):
        """
        Crea un nuevo ciclo de producción.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_ciclo (dict): Datos del ciclo.
            
        Returns:
            tuple: (True, id_ciclo) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        self._validar_datos_ciclo(datos_ciclo)
        
        query = """
        INSERT INTO CiclosProduccion (
            id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, 
            fecha_cosecha_real, area_sembrada, densidad_siembra, estado, 
            fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza, activo
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        valores = (
            datos_ciclo['id_parcela'],
            datos_ciclo['id_variedad'],
            datos_ciclo.get('fecha_siembra'),
            datos_ciclo.get('fecha_cosecha_estimada'),
            datos_ciclo.get('fecha_cosecha_real'),
            datos_ciclo['area_sembrada'],
            datos_ciclo.get('densidad_siembra'),
            datos_ciclo.get('estado', 'Planificado'),
            datos_ciclo.get('fecha_floracion'),
            datos_ciclo.get('fecha_poda'),
            datos_ciclo.get('fecha_limpieza'),
            datos_ciclo.get('frecuencia_limpieza'),
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_ciclo = self._obtener_ultimo_id()
        
        logger.info(f"Ciclo de producción creado con ID: {id_ciclo}")
        return True, id_ciclo

    @cache_invalidator('ciclos_produccion', pattern='id_')             # Específico
    @cache_invalidator('ciclos_produccion', key='todos_activos')       # Lista completa
    @cache_invalidator('ciclos_produccion', pattern='pag_')            # Paginación
    @cache_invalidator('ciclos_produccion', pattern='parcela_')        # Por parcela
    @cache_invalidator('ciclos_produccion', pattern='estado_')         # Por estado
    @cache_invalidator('ciclos_produccion', key='ciclos_activos')      # Ciclos activos
    @cache_invalidator('estadisticas_ciclos')                          # Estadísticas
    def actualizar(self, id_ciclo, datos_ciclo):
        """
        Actualiza un ciclo de producción existente.
        OPTIMIZADO: Invalidación específica y general.
        
        Args:
            id_ciclo (int): ID del ciclo.
            datos_ciclo (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
        """
        # Verificar que el ciclo existe
        ciclo_actual = self.obtener_por_id(id_ciclo)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        campos_permitidos = [
            'id_parcela', 'id_variedad', 'fecha_siembra', 'fecha_cosecha_estimada',
            'fecha_cosecha_real', 'area_sembrada', 'densidad_siembra', 'estado',
            'fecha_floracion', 'fecha_poda', 'fecha_limpieza', 'frecuencia_limpieza'
        ]
        
        for campo in campos_permitidos:
            if campo in datos_ciclo:
                campos_actualizar.append(f"{campo} = ?")
                valores.append(datos_ciclo[campo])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        # Validar datos antes de actualizar
        datos_para_validar = ciclo_actual.copy()
        datos_para_validar.update(datos_ciclo)
        self._validar_datos_ciclo(datos_para_validar)
        
        query = f"UPDATE CiclosProduccion SET {', '.join(campos_actualizar)} WHERE id_ciclo = ?"
        valores.append(id_ciclo)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Ciclo {id_ciclo} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('ciclos_produccion', pattern='id_')             # Específico
    @cache_invalidator('ciclos_produccion', pattern='estado_')         # Por estado
    @cache_invalidator('ciclos_produccion', key='ciclos_activos')      # Ciclos activos
    @cache_invalidator('estadisticas_ciclos')                          # Estadísticas
    def cambiar_estado(self, id_ciclo, nuevo_estado):
        """
        Cambia el estado de un ciclo de producción.
        OPTIMIZADO: Invalidación específica por estado.
        
        Args:
            id_ciclo (int): ID del ciclo.
            nuevo_estado (str): Nuevo estado.
            
        Returns:
            bool: True si se cambió correctamente.
        """
        if nuevo_estado not in self.ESTADOS_VALIDOS:
            raise ErrorValidacion(f"Estado no válido: {nuevo_estado}. Estados válidos: {self.ESTADOS_VALIDOS}")
        
        # Verificar que el ciclo existe
        ciclo_actual = self.obtener_por_id(id_ciclo)
        
        # Validar transición de estado
        self._validar_transicion_estado(ciclo_actual['estado'], nuevo_estado)
        
        query = "UPDATE CiclosProduccion SET estado = ? WHERE id_ciclo = ?"
        filas_afectadas = self._ejecutar_consulta(query, (nuevo_estado, id_ciclo), obtener_resultado=False)
        
        logger.info(f"Estado del ciclo {id_ciclo} actualizado de '{ciclo_actual['estado']}' a '{nuevo_estado}'")
        return filas_afectadas > 0

    @cache_invalidator('ciclos_produccion', pattern='id_')             # Específico
    @cache_invalidator('ciclos_produccion', key='todos_activos')       # Lista completa
    @cache_invalidator('ciclos_produccion', pattern='pag_')            # Paginación
    @cache_invalidator('ciclos_produccion', pattern='parcela_')        # Por parcela
    @cache_invalidator('ciclos_produccion', pattern='estado_')         # Por estado
    @cache_invalidator('ciclos_produccion', key='ciclos_activos')      # Ciclos activos
    @cache_invalidator('estadisticas_ciclos')                          # Estadísticas
    def desactivar(self, id_ciclo):
        """
        Desactiva un ciclo de producción (eliminación lógica).
        
        Args:
            id_ciclo (int): ID del ciclo.
            
        Returns:
            bool: True si se desactivó correctamente.
        """
        # Verificar que el ciclo existe
        self.obtener_por_id(id_ciclo)
        
        query = "UPDATE CiclosProduccion SET activo = 0 WHERE id_ciclo = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_ciclo,), obtener_resultado=False)
        
        logger.info(f"Ciclo {id_ciclo} desactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _construir_objeto_ciclo_produccion(self, row):
        """
        Construye un objeto ciclo de producción a partir de una fila de la base de datos.
        
        Args:
            row: Fila de la consulta.
            
        Returns:
            dict: Objeto ciclo estructurado.
        """
        return {
            'id_ciclo': row.id_ciclo,
            'id': row.id_ciclo,  # Alias para compatibilidad
            'id_parcela': row.id_parcela,
            'id_variedad': row.id_variedad,
            'area_sembrada': float(row.area_sembrada),
            'densidad_siembra': row.densidad_siembra,
            'estado': row.estado,
            'activo': bool(row.activo),
            'frecuencia_limpieza': row.frecuencia_limpieza,
            
            # Fechas formateadas
            'fecha_siembra': self._formatear_fecha(row.fecha_siembra),
            'fecha_cosecha_estimada': self._formatear_fecha(row.fecha_cosecha_estimada),
            'fecha_cosecha_real': self._formatear_fecha(row.fecha_cosecha_real),
            'fecha_floracion': self._formatear_fecha(row.fecha_floracion),
            'fecha_poda': self._formatear_fecha(row.fecha_poda),
            'fecha_limpieza': self._formatear_fecha(row.fecha_limpieza),
            
            # Información relacionada
            'nombre_parcela': row.nombre_parcela or '',
            'nombre_variedad': row.nombre_variedad or '',
            'nombre_tipo_cultivo': row.nombre_tipo_cultivo or '',
            'nombre_propietario': row.nombre_propietario or '',
            'cultivo_completo': f"{row.nombre_tipo_cultivo} - {row.nombre_variedad}" if row.nombre_tipo_cultivo else row.nombre_variedad,
            
            # Campos calculados
            'es_activo': row.estado in ['Planificado', 'En Preparación', 'Sembrado', 'En Desarrollo', 'En Cosecha'],
            'esta_finalizado': row.estado in ['Finalizado', 'Cancelado'],
            'progreso_estimado': self._calcular_progreso_estimado(row.estado),
            'dias_desde_siembra': self._calcular_dias_desde_siembra(row.fecha_siembra),
            'area_texto': f"{float(row.area_sembrada):,.2f} ha",
            'estado_color': self._obtener_color_estado(row.estado)
        }
    
    def _validar_datos_ciclo(self, datos):
        """
        Valida los datos del ciclo de producción.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('id_parcela'):
            raise ErrorValidacion("La parcela es obligatoria")
        
        if not datos.get('id_variedad'):
            raise ErrorValidacion("La variedad es obligatoria")
        
        if not datos.get('area_sembrada') or datos.get('area_sembrada') <= 0:
            raise ErrorValidacion("El área sembrada debe ser mayor a 0")
        
        # Validar estado
        estado = datos.get('estado', 'Planificado')
        if estado not in self.ESTADOS_VALIDOS:
            raise ErrorValidacion(f"Estado no válido: {estado}")
        
        # Validar fechas
        self._validar_fechas_ciclo(datos)
        
        # Validar densidad de siembra si se proporciona
        densidad = datos.get('densidad_siembra')
        if densidad is not None and densidad < 0:
            raise ErrorValidacion("La densidad de siembra debe ser positiva")
    
    def _validar_fechas_ciclo(self, datos):
        """
        Valida las fechas del ciclo de producción.
        
        Args:
            datos (dict): Datos con fechas a validar.
            
        Raises:
            ErrorValidacion: Si las fechas no son válidas.
        """
        fecha_siembra = datos.get('fecha_siembra')
        fecha_cosecha_estimada = datos.get('fecha_cosecha_estimada')
        fecha_cosecha_real = datos.get('fecha_cosecha_real')
        
        # La fecha de siembra no puede ser futura
        if fecha_siembra and isinstance(fecha_siembra, (date, datetime)):
            if fecha_siembra > date.today():
                raise ErrorValidacion("La fecha de siembra no puede ser futura")
        
        # La cosecha estimada debe ser posterior a la siembra
        if (fecha_siembra and fecha_cosecha_estimada and 
            isinstance(fecha_siembra, (date, datetime)) and 
            isinstance(fecha_cosecha_estimada, (date, datetime))):
            if fecha_cosecha_estimada <= fecha_siembra:
                raise ErrorValidacion("La fecha de cosecha estimada debe ser posterior a la siembra")
        
        # La cosecha real debe ser posterior a la siembra
        if (fecha_siembra and fecha_cosecha_real and 
            isinstance(fecha_siembra, (date, datetime)) and 
            isinstance(fecha_cosecha_real, (date, datetime))):
            if fecha_cosecha_real <= fecha_siembra:
                raise ErrorValidacion("La fecha de cosecha real debe ser posterior a la siembra")
    
    def _validar_transicion_estado(self, estado_actual, nuevo_estado):
        """
        Valida que la transición de estado sea lógica.
        
        Args:
            estado_actual (str): Estado actual.
            nuevo_estado (str): Estado destino.
            
        Raises:
            ErrorValidacion: Si la transición no es válida.
        """
        # Definir transiciones válidas
        transiciones_validas = {
            'Planificado': ['En Preparación', 'Cancelado'],
            'En Preparación': ['Sembrado', 'Cancelado'],
            'Sembrado': ['En Desarrollo', 'Cancelado'],
            'En Desarrollo': ['En Cosecha', 'Cancelado'],
            'En Cosecha': ['Finalizado', 'Cancelado'],
            'Finalizado': [],  # Estado final
            'Cancelado': []    # Estado final
        }
        
        if nuevo_estado not in transiciones_validas.get(estado_actual, []):
            raise ErrorValidacion(f"No se puede cambiar de '{estado_actual}' a '{nuevo_estado}'")
    
    def _calcular_progreso_estimado(self, estado):
        """
        Calcula el progreso estimado basado en el estado.
        
        Args:
            estado (str): Estado del ciclo.
            
        Returns:
            int: Porcentaje de progreso (0-100).
        """
        progresos = {
            'Planificado': 0,
            'En Preparación': 20,
            'Sembrado': 40,
            'En Desarrollo': 70,
            'En Cosecha': 90,
            'Finalizado': 100,
            'Cancelado': 0
        }
        return progresos.get(estado, 0)
    
    def _calcular_dias_desde_siembra(self, fecha_siembra):
        """
        Calcula los días transcurridos desde la siembra.
        
        Args:
            fecha_siembra: Fecha de siembra.
            
        Returns:
            int: Días desde siembra o None si no hay fecha.
        """
        if not fecha_siembra:
            return None
        
        if isinstance(fecha_siembra, str):
            try:
                fecha_siembra = datetime.strptime(fecha_siembra, '%Y-%m-%d').date()
            except:
                return None
        elif isinstance(fecha_siembra, datetime):
            fecha_siembra = fecha_siembra.date()
        
        if isinstance(fecha_siembra, date):
            return (date.today() - fecha_siembra).days
        
        return None
    
    def _obtener_color_estado(self, estado):
        """
        Obtiene el color asociado al estado para UI.
        
        Args:
            estado (str): Estado del ciclo.
            
        Returns:
            str: Color en formato CSS.
        """
        colores = {
            'Planificado': '#6B7280',      # Gris
            'En Preparación': '#F59E0B',   # Amarillo
            'Sembrado': '#10B981',         # Verde claro
            'En Desarrollo': '#3B82F6',    # Azul
            'En Cosecha': '#8B5CF6',       # Púrpura
            'Finalizado': '#059669',       # Verde
            'Cancelado': '#EF4444'         # Rojo
        }
        return colores.get(estado, '#6B7280')
    
    # ==================== MÉTODOS DE RENTABILIDAD ====================

    @cacheable('rentabilidad_ciclos', key_func=lambda id_ciclo: f"rentabilidad_detallada_{id_ciclo}", ttl=1800)
    def obtener_rentabilidad_ciclo(self, id_ciclo):
        """Obtiene rentabilidad detallada de un ciclo completado."""
        try:
            # Usar el método del repositorio de relaciones
            rentabilidad_basica = self.relacion_repo.obtener_rentabilidad_por_ciclo(id_ciclo)
            
            if not rentabilidad_basica:
                return {'error': 'Ciclo no encontrado o no finalizado'}
            
            # Enriquecer con análisis adicional
            ciclo_actual = self.ciclo_repo.obtener_por_id(id_ciclo)
            
            # Obtener ciclos similares para comparación
            ciclos_similares = self.comparar_ciclos_similares(id_ciclo)
            
            # Análisis de costos detallado
            analisis_costos = self._analizar_costos_detallado(id_ciclo)
            
            # Análisis de ingresos
            analisis_ingresos = self._analizar_ingresos_detallado(id_ciclo)
            
            rentabilidad_completa = {
                **rentabilidad_basica,
                'analisis_comparativo': {
                    'vs_promedio_variedad': self._comparar_vs_promedio_variedad(rentabilidad_basica, ciclos_similares),
                    'vs_promedio_parcela': self._comparar_vs_promedio_parcela(rentabilidad_basica, ciclos_similares),
                    'ranking_historico': self._calcular_ranking_historico(id_ciclo, ciclos_similares)
                },
                'desglose_costos': analisis_costos,
                'desglose_ingresos': analisis_ingresos,
                'metricas_eficiencia': {
                    'costo_por_hectarea': analisis_costos['total'] / rentabilidad_basica['area_sembrada'] if rentabilidad_basica['area_sembrada'] > 0 else 0,
                    'ingreso_por_hectarea': analisis_ingresos['total'] / rentabilidad_basica['area_sembrada'] if rentabilidad_basica['area_sembrada'] > 0 else 0,
                    'margen_utilidad': (rentabilidad_basica['ganancia_neta'] / rentabilidad_basica['ingresos_total']) * 100 if rentabilidad_basica['ingresos_total'] > 0 else 0,
                    'tiempo_retorno_inversion': rentabilidad_basica['duracion_dias'] if rentabilidad_basica['roi_porcentaje'] > 0 else None
                },
                'factores_exito': self._identificar_factores_exito_ciclo(rentabilidad_basica, analisis_costos, analisis_ingresos),
                'recomendaciones_mejora': self._generar_recomendaciones_mejora_ciclo(rentabilidad_basica, ciclos_similares),
                'timestamp_analisis': self._get_timestamp()
            }
            
            return rentabilidad_completa
            
        except Exception as e:
            logger.error(f"Error obteniendo rentabilidad del ciclo {id_ciclo}: {str(e)}")
            return {'error': str(e)}

    def comparar_ciclos_similares(self, id_ciclo):
        """Compara rentabilidad con ciclos similares (misma variedad/parcela)."""
        try:
            # Obtener información del ciclo actual
            ciclo_actual = self.ciclo_repo.obtener_por_id(id_ciclo)
            
            # Buscar ciclos similares (misma variedad O misma parcela)
            query_similares = """
            SELECT 
                c.id_ciclo,
                c.id_variedad,
                c.id_parcela,
                c.area_sembrada,
                c.fecha_cosecha_real,
                v.nombre as variedad,
                p.nombre as parcela,
                
                -- Rentabilidad
                COALESCE(SUM(dv.cantidad * dv.precio_unitario), 0) as ingresos,
                COALESCE(SUM(cp.costo_total), 0) as costos,
                CASE 
                    WHEN SUM(cp.costo_total) > 0 THEN
                        ((SUM(dv.cantidad * dv.precio_unitario) - SUM(cp.costo_total)) / SUM(cp.costo_total)) * 100
                    ELSE 0
                END as roi,
                
                -- Tipo de similitud
                CASE 
                    WHEN c.id_variedad = ? AND c.id_parcela = ? THEN 'exacta'
                    WHEN c.id_variedad = ? THEN 'misma_variedad'
                    WHEN c.id_parcela = ? THEN 'misma_parcela'
                    ELSE 'otra'
                END as tipo_similitud
                
            FROM CiclosProduccion c
            JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
            JOIN Parcelas p ON c.id_parcela = p.id_parcela
            LEFT JOIN LotesCosecha l ON c.id_ciclo = l.id_ciclo AND l.activo = 1
            LEFT JOIN DetallesVenta dv ON l.id_lote = dv.id_lote
            LEFT JOIN CostosProduccion cp ON c.id_ciclo = cp.id_ciclo
            
            WHERE c.activo = 1 AND c.estado = 'Finalizado' 
            AND c.id_ciclo != ?
            AND (c.id_variedad = ? OR c.id_parcela = ?)
            
            GROUP BY c.id_ciclo, c.id_variedad, c.id_parcela, c.area_sembrada, 
                    c.fecha_cosecha_real, v.nombre, p.nombre
            ORDER BY tipo_similitud, c.fecha_cosecha_real DESC
            """
            
            parametros = (
                ciclo_actual['id_variedad'], ciclo_actual['id_parcela'],  # Para CASE exacta
                ciclo_actual['id_variedad'],  # Para CASE misma_variedad
                ciclo_actual['id_parcela'],   # Para CASE misma_parcela
                id_ciclo,  # Para excluir ciclo actual
                ciclo_actual['id_variedad'], ciclo_actual['id_parcela']  # Para WHERE
            )
            
            ciclos_similares = self.ciclo_repo._ejecutar_consulta(query_similares, parametros)
            
            # Organizar por tipo de similitud
            comparacion = {
                'ciclo_actual': {
                    'id_ciclo': id_ciclo,
                    'variedad': ciclo_actual['nombre_variedad'],
                    'parcela': ciclo_actual['nombre_parcela']
                },
                'ciclos_exactos': [],      # Misma variedad Y parcela
                'misma_variedad': [],      # Misma variedad, diferente parcela
                'misma_parcela': [],       # Misma parcela, diferente variedad
                'estadisticas_comparativas': {}
            }
            
            # Clasificar ciclos similares
            for ciclo in ciclos_similares:
                ciclo_data = {
                    'id_ciclo': ciclo.id_ciclo,
                    'variedad': ciclo.variedad,
                    'parcela': ciclo.parcela,
                    'area_sembrada': float(ciclo.area_sembrada),
                    'fecha_cosecha': ciclo.fecha_cosecha_real,
                    'ingresos': float(ciclo.ingresos),
                    'costos': float(ciclo.costos),
                    'ganancia': float(ciclo.ingresos) - float(ciclo.costos),
                    'roi': float(ciclo.roi)
                }
                
                if ciclo.tipo_similitud == 'exacta':
                    comparacion['ciclos_exactos'].append(ciclo_data)
                elif ciclo.tipo_similitud == 'misma_variedad':
                    comparacion['misma_variedad'].append(ciclo_data)
                elif ciclo.tipo_similitud == 'misma_parcela':
                    comparacion['misma_parcela'].append(ciclo_data)
            
            # Calcular estadísticas comparativas
            comparacion['estadisticas_comparativas'] = self._calcular_estadisticas_comparativas(comparacion)
            
            # Generar insights
            comparacion['insights'] = self._generar_insights_comparacion(comparacion)
            
            return comparacion
            
        except Exception as e:
            logger.error(f"Error comparando ciclos similares para {id_ciclo}: {str(e)}")
            return {'error': str(e)}

    # Métodos auxiliares para rentabilidad de ciclos
    def _analizar_costos_detallado(self, id_ciclo):
        """Analiza costos detallados del ciclo."""
        query_costos = """
        SELECT 
            cc.nombre as categoria,
            SUM(cp.costo_total) as total_categoria,
            COUNT(cp.id_costo) as cantidad_registros,
            AVG(cp.costo_total) as promedio_registro
        FROM CostosProduccion cp
        JOIN CategoriasCostos cc ON cp.id_categoria = cc.id_categoria
        WHERE cp.id_ciclo = ?
        GROUP BY cc.id_categoria, cc.nombre
        ORDER BY total_categoria DESC
        """
        
        costos = self.ciclo_repo._ejecutar_consulta(query_costos, (id_ciclo,))
        
        total_costos = sum(float(c.total_categoria) for c in costos)
        
        return {
            'total': total_costos,
            'por_categoria': [
                {
                    'categoria': c.categoria,
                    'monto': float(c.total_categoria),
                    'porcentaje': round((float(c.total_categoria) / total_costos) * 100, 1) if total_costos > 0 else 0,
                    'cantidad_registros': c.cantidad_registros,
                    'promedio_registro': round(float(c.promedio_registro), 2)
                } for c in costos
            ],
            'categoria_mayor_gasto': costos[0].categoria if costos else None
        }

    def _analizar_ingresos_detallado(self, id_ciclo):
        """Analiza ingresos detallados del ciclo."""
        query_ingresos = """
        SELECT 
            v.codigo_venta,
            v.fecha_venta,
            c.nombre as cliente,
            dv.cantidad,
            dv.precio_unitario,
            dv.cantidad * dv.precio_unitario as subtotal
        FROM LotesCosecha l
        JOIN DetallesVenta dv ON l.id_lote = dv.id_lote
        JOIN Ventas v ON dv.id_venta = v.id_venta
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        WHERE l.id_ciclo = ? AND l.activo = 1
        ORDER BY v.fecha_venta DESC
        """
        
        ventas = self.ciclo_repo._ejecutar_consulta(query_ingresos, (id_ciclo,))
        
        total_ingresos = sum(float(v.subtotal) for v in ventas)
        total_cantidad_vendida = sum(float(v.cantidad) for v in ventas)
        
        return {
            'total': total_ingresos,
            'cantidad_total_vendida': total_cantidad_vendida,
            'precio_promedio': round(total_ingresos / total_cantidad_vendida, 2) if total_cantidad_vendida > 0 else 0,
            'numero_ventas': len(ventas),
            'detalle_ventas': [
                {
                    'codigo_venta': v.codigo_venta,
                    'fecha': v.fecha_venta,
                    'cliente': v.cliente,
                    'cantidad': float(v.cantidad),
                    'precio_unitario': float(v.precio_unitario),
                    'subtotal': float(v.subtotal)
                } for v in ventas
            ],
            'cliente_principal': max(ventas, key=lambda x: x.subtotal).cliente if ventas else None
        }

    def _calcular_estadisticas_comparativas(self, comparacion):
        """Calcula estadísticas comparativas entre ciclos similares."""
        estadisticas = {}
        
        for categoria, ciclos in comparacion.items():
            if categoria in ['ciclos_exactos', 'misma_variedad', 'misma_parcela'] and ciclos:
                rois = [c['roi'] for c in ciclos]
                ingresos = [c['ingresos'] for c in ciclos]
                
                estadisticas[categoria] = {
                    'total_ciclos': len(ciclos),
                    'roi_promedio': round(sum(rois) / len(rois), 1),
                    'roi_maximo': round(max(rois), 1),
                    'roi_minimo': round(min(rois), 1),
                    'ingreso_promedio': round(sum(ingresos) / len(ingresos), 2),
                    'mejor_ciclo': max(ciclos, key=lambda x: x['roi'])['id_ciclo']
                }
        
        return estadisticas