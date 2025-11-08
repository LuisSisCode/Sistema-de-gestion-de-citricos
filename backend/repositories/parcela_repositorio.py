# bd_conecciones/repositorios/parcela_repositorio.py

import logging
from datetime import datetime
from ..core.repositorio_base import RepositorioBase
from ..core.excepciones_bd import RegistroNoEncontrado, ErrorValidacion

logger = logging.getLogger(__name__)

class ParcelaRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de parcelas."""
    
    def obtener_todas(self):
        """
        Obtiene todas las parcelas activas con información de propietarios.
        
        Returns:
            list: Lista de diccionarios con información de parcelas.
        """
        query = """
        SELECT p.id_parcela, p.nombre, p.ubicacion, p.area_total,
            p.coordenadas_gps, p.tipo_suelo, p.fuente_agua,
            p.fecha_adquisicion, p.activo, 
            a.id_productor, a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM Parcelas p
        JOIN Productores a ON p.id_productor = a.id_productor
        WHERE p.activo = 1 AND a.activo = 1
        ORDER BY p.id_parcela
        """
        
        rows = self._ejecutar_consulta(query)
        parcelas = []
        
        for row in rows:
            parcela = self._construir_objeto_parcela(row)
            parcelas.append(parcela)
        
        logger.info(f"Se obtuvieron {len(parcelas)} parcelas")
        return parcelas
    
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
        SELECT p.id_parcela, p.nombre, p.ubicacion, p.area_total,
            p.coordenadas_gps, p.tipo_suelo, p.fuente_agua,
            p.fecha_adquisicion, p.activo, 
            a.id_productor, a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM Parcelas p
        JOIN Productores a ON p.id_productor = a.id_productor
        WHERE p.id_parcela = ? AND p.activo = 1 AND a.activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_parcela,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Parcela con ID {id_parcela} no encontrada")
        
        return self._construir_objeto_parcela(rows[0])
    
    def obtener_por_propietario(self, id_propietario):
        """
        Obtiene parcelas de un propietario específico.
        
        Args:
            id_propietario (int): ID del propietario.
            
        Returns:
            list: Lista de parcelas del propietario.
        """
        query = """
        SELECT p.id_parcela, p.nombre, p.ubicacion, p.area_total,
            p.coordenadas_gps, p.tipo_suelo, p.fuente_agua,
            p.fecha_adquisicion, p.activo, 
            a.id_productor a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM Parcelas p
        JOIN Productores a ON p.id_productor = a.id_productor
        WHERE p.id_productor = ? AND p.activo = 1 AND a.activo = 1
        ORDER BY p.nombre
        """
        
        rows = self._ejecutar_consulta(query, (id_propietario,))
        parcelas = []
        
        for row in rows:
            parcela = self._construir_objeto_parcela(row)
            parcelas.append(parcela)
        
        logger.info(f"Se obtuvieron {len(parcelas)} parcelas del propietario {id_propietario}")
        return parcelas
    
    def obtener_paginado(self, pagina, por_pagina=6, propietario_id=None):
        """
        Obtiene parcelas con paginación y filtro opcional por propietario.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            propietario_id (int, optional): ID del propietario para filtrar.
            
        Returns:
            dict: Parcelas, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Construir condiciones WHERE
        where_clause = "p.activo = 1 AND a.activo = 1"
        params_count = []
        params_data = []
        
        if propietario_id and propietario_id != 0:
            where_clause += " AND p.id_productor = ?"
            params_count.append(propietario_id)
            params_data.append(propietario_id)
        
        # Contar total de registros
        count_query = f"""
        SELECT COUNT(*)
        FROM Parcelas p
        JOIN Productores a ON p.id_productor = a.id_productor
        WHERE {where_clause}
        """
        total_registros = self._ejecutar_consulta_escalar(count_query, params_count)
        
        # Obtener registros paginados
        data_query = f"""
        SELECT p.id_parcela, p.nombre, p.ubicacion, p.area_total,
            p.coordenadas_gps, p.tipo_suelo, p.fuente_agua,
            p.fecha_adquisicion, p.activo, 
            a.id_productor a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM Parcelas p
        JOIN Productores a ON p.id_productor = a.id_productor
        WHERE {where_clause}
        ORDER BY p.id_parcela
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
        print(f"Total páginas calculadas: {total_paginas}")
        logger.info(f"Página {pagina}: {len(parcelas)} parcelas de {total_registros} totales")
        return resultado
    
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
                            coordenadas_gps, tipo_suelo, fuente_agua,
                            fecha_adquisicion, activo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        # Preparar coordenadas GPS
        coordenadas_gps = None
        if datos_parcela.get('latitud') and datos_parcela.get('longitud'):
            coordenadas_gps = f"{datos_parcela['latitud']},{datos_parcela['longitud']}"
        elif datos_parcela.get('coordenadasGPS'):
            coordenadas_gps = datos_parcela['coordenadasGPS']
        
        fecha_actual = datetime.now().date().strftime('%Y-%m-%d')
        valores = (
            datos_parcela['propietarioId'],
            datos_parcela['nombre'],
            datos_parcela['ubicacion'],
            datos_parcela['area'],
            coordenadas_gps,
            datos_parcela.get('tipoSuelo'),
            datos_parcela.get('fuenteAgua'),
            fecha_actual,
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_parcela = self._obtener_ultimo_id()
        
        logger.info(f"Parcela creada con ID: {id_parcela}")
        return True, id_parcela
    
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
            
        if 'propietarioId' in datos_parcela:
            campos_actualizar.append("id_productor = ?")
            valores.append(datos_parcela['propietarioId'])
            
        if 'ubicacion' in datos_parcela:
            campos_actualizar.append("ubicacion = ?")
            valores.append(datos_parcela['ubicacion'])
            
        if 'area' in datos_parcela:
            campos_actualizar.append("area_total = ?")
            valores.append(datos_parcela['area'])
        
        # Manejar coordenadas GPS
        if 'latitud' in datos_parcela and 'longitud' in datos_parcela:
            coordenadas_gps = f"{datos_parcela['latitud']},{datos_parcela['longitud']}"
            campos_actualizar.append("coordenadas_gps = ?")
            valores.append(coordenadas_gps)
        elif 'coordenadasGPS' in datos_parcela:
            campos_actualizar.append("coordenadas_gps = ?")
            valores.append(datos_parcela['coordenadasGPS'])
        
        if 'tipoSuelo' in datos_parcela:
            campos_actualizar.append("tipo_suelo = ?")
            valores.append(datos_parcela['tipoSuelo'])
            
        if 'fuenteAgua' in datos_parcela:
            campos_actualizar.append("fuente_agua = ?")
            valores.append(datos_parcela['fuenteAgua'])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        query = f"UPDATE Parcelas SET {', '.join(campos_actualizar)} WHERE id_parcela = ?"
        valores.append(id_parcela)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Parcela {id_parcela} actualizada. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0
    
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
    
    def buscar_por_nombre(self, texto_busqueda):
        """
        Busca parcelas por nombre o ubicación.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de parcelas que coinciden.
        """
        query = """
        SELECT p.id_parcela, p.nombre, p.ubicacion, p.area_total,
            p.coordenadas_gps, p.tipo_suelo, p.fuente_agua,
            p.fecha_adquisicion, p.activo, 
            a.id_productor a.nombre + ' ' + a.apellido AS nombre_propietario
        FROM Parcelas p
        JOIN Productores a ON p.id_productor = a.id_productor
        WHERE p.activo = 1 AND a.activo = 1 
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
            COUNT(DISTINCT id_productor) as propietarios_distintos
        FROM Parcelas 
        WHERE activo = 1
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        estadisticas = {
            'total_parcelas': row.total_parcelas,
            'area_total': float(row.area_total),
            'area_promedio': float(row.area_promedio),
            'propietarios_distintos': row.propietarios_distintos
        }
        
        logger.info(f"Estadísticas calculadas: {estadisticas}")
        return estadisticas
    
    def _construir_objeto_parcela(self, row):
        """
        Construye un objeto parcela a partir de una fila de la base de datos.
        
        Args:
            row: Fila de la consulta.
            
        Returns:
            dict: Objeto parcela estructurado.
        """
        # Extraer coordenadas GPS
        latitud = None
        longitud = None
        if row.coordenadas_gps:
            try:
                coord_parts = row.coordenadas_gps.split(',')
                if len(coord_parts) == 2:
                    latitud = float(coord_parts[0].strip())
                    longitud = float(coord_parts[1].strip())
            except (ValueError, AttributeError):
                pass
        
        # Calcular porcentaje de uso (temporal - debería venir de cultivos)
        from random import randint
        porcentaje_uso = randint(0, 100)
        
        return {
            'parcelaId': row.id_parcela,
            'nombre': row.nombre,
            'propietario': row.nombre_propietario,
            'propietarioId': row.id_productor,
            'ubicacion': row.ubicacion,
            'area': float(row.area_total),
            'coordenadasGPS': row.coordenadas_gps,
            'latitud': latitud,
            'longitud': longitud,
            'tipoSuelo': row.tipo_suelo,
            'fuenteAgua': row.fuente_agua,
            'fechaAdquisicion': self._formatear_fecha(row.fecha_adquisicion),
            'porcentajeUso': porcentaje_uso,
            'activo': bool(row.activo)
        }
    
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
        
        if not datos.get('propietarioId'):
            raise ErrorValidacion("El propietario es obligatorio")
        
        if not datos.get('area') or datos.get('area') <= 0:
            raise ErrorValidacion("El área debe ser mayor a 0")
        
        # Validar coordenadas si se proporcionan
        if datos.get('latitud') is not None or datos.get('longitud') is not None:
            lat = datos.get('latitud')
            lng = datos.get('longitud')
            
            if lat is None or lng is None:
                raise ErrorValidacion("Si proporciona coordenadas, debe incluir latitud y longitud")
            
            try:
                lat = float(lat)
                lng = float(lng)
                
                # Validar rangos aproximados para Bolivia
                if not (-25 <= lat <= -9):
                    raise ErrorValidacion("La latitud debe estar entre -25 y -9 grados")
                    
                if not (-70 <= lng <= -57):
                    raise ErrorValidacion("La longitud debe estar entre -70 y -57 grados")
                    
            except (ValueError, TypeError):
                raise ErrorValidacion("Las coordenadas deben ser números válidos")