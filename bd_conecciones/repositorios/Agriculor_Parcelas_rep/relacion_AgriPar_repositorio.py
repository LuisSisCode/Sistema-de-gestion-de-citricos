# bd_conecciones/repositorios/relacion_repositorio.py

import logging
from ...nucleo.repositorio_base import RepositorioBase
from ...nucleo.excepciones_bd import RegistroNoEncontrado, RegistroTieneDependencias
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class RelacionRepositorio(RepositorioBase):
    """Repositorio para consultas que involucran múltiples tablas con caché optimizado."""
    
    @cacheable('relaciones', key_func=lambda id_agr: f"parcelas_count_{id_agr}", ttl=1800)  # 30 min
    def contar_parcelas_por_agricultor(self, id_agricultor):
        """
        Cuenta las parcelas activas de un agricultor específico.
        ⭐ MUY OPTIMIZADO: Era la consulta más repetida en logs (16+ veces)
        
        Args:
            id_agricultor (int): ID del agricultor.
            
        Returns:
            int: Número de parcelas activas del agricultor.
        """
        count = self._contar_registros(
            "Parcelas", 
            "id_agricultor = ? AND activo = 1", 
            (id_agricultor,)
        )
        
        logger.info(f"Agricultor {id_agricultor} tiene {count} parcelas activas")
        return count
    
    @cacheable('relaciones', key_func=lambda id_agr: f"dependencias_{id_agr}", ttl=1200)  # 20 min
    def verificar_dependencias_agricultor(self, id_agricultor):
        """
        Verifica todas las dependencias de un agricultor antes de eliminarlo.
        
        Args:
            id_agricultor (int): ID del agricultor.
            
        Returns:
            dict: Información detallada de dependencias.
            
        Raises:
            RegistroTieneDependencias: Si tiene dependencias que impiden la eliminación.
        """
        # Contar parcelas (ahora cacheado)
        parcelas = self.contar_parcelas_por_agricultor(id_agricultor)
        
        # En futuras versiones podríamos verificar otras dependencias:
        # - Cultivos asociados
        # - Transacciones de ventas
        # - Contratos
        
        dependencias = {
            'parcelas': parcelas,
            'total_dependencias': parcelas,
            'puede_eliminar': parcelas == 0
        }
        
        if not dependencias['puede_eliminar']:
            mensaje = f"No se puede eliminar el agricultor. Tiene {parcelas} parcelas asociadas."
            raise RegistroTieneDependencias(mensaje, parcelas)
        
        logger.info(f"Agricultor {id_agricultor} puede ser eliminado - sin dependencias")
        return dependencias
    
    @cacheable('propietarios', key_func=lambda: 'activos_lista', ttl=2400)  # 40 min - semi-estático
    def obtener_propietarios_activos(self):
        """
        Obtiene la lista de agricultores que son propietarios activos.
        ⭐ OPTIMIZADO: Consultado frecuentemente según logs
        
        Returns:
            list: Lista de propietarios con formato {id, nombre}.
        """
        query = """
        SELECT id_agricultor, nombre, apellido
        FROM Agricultores
        WHERE es_propietario = 1 AND activo = 1
        ORDER BY nombre, apellido
        """
        
        rows = self._ejecutar_consulta(query)
        propietarios = []
        
        for row in rows:
            propietario = {
                'id': row.id_agricultor,
                'nombre': f"{row.nombre} {row.apellido}"
            }
            propietarios.append(propietario)
        
        logger.info(f"Se obtuvieron {len(propietarios)} propietarios activos")
        return propietarios
    
    @cacheable('estadisticas', key_func=lambda: 'generales_completas', ttl=1800)  # 30 min
    def obtener_estadisticas_generales(self):
        """
        Obtiene estadísticas generales del sistema.
        ⭐ MUY OPTIMIZADO: "Estadísticas generales calculadas" se repetía múltiples veces
        
        Returns:
            dict: Estadísticas completas del sistema.
        """
        query = """
        SELECT 
            (SELECT COUNT(*) FROM Agricultores WHERE activo = 1) as total_agricultores,
            (SELECT COUNT(*) FROM Agricultores WHERE es_propietario = 1 AND activo = 1) as total_propietarios,
            (SELECT COUNT(*) FROM Parcelas WHERE activo = 1) as total_parcelas,
            (SELECT COALESCE(SUM(area_total), 0) FROM Parcelas WHERE activo = 1) as area_total,
            (SELECT COALESCE(AVG(area_total), 0) FROM Parcelas WHERE activo = 1) as area_promedio
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        estadisticas = {
            'agricultores': {
                'total': row.total_agricultores,
                'propietarios': row.total_propietarios,
                'trabajadores': row.total_agricultores - row.total_propietarios
            },
            'parcelas': {
                'total': row.total_parcelas,
                'area_total': float(row.area_total),
                'area_promedio': float(row.area_promedio)
            }
        }
        
        logger.info(f"Estadísticas generales calculadas: {estadisticas}")
        return estadisticas
    
    @cacheable('distribuciones', key_func=lambda: 'parcelas_por_propietario', ttl=2400)  # 40 min
    def obtener_distribución_parcelas_por_propietario(self):
        """
        Obtiene la distribución de parcelas por propietario.
        ⭐ OPTIMIZADO: "Distribución calculada para X propietarios" repetida en logs
        
        Returns:
            list: Lista con propietarios y cantidad de parcelas.
        """
        query = """
        SELECT 
            a.id_agricultor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            COUNT(p.id_parcela) as cantidad_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total
        FROM Agricultores a
        LEFT JOIN Parcelas p ON a.id_agricultor = p.id_agricultor AND p.activo = 1
        WHERE a.es_propietario = 1 AND a.activo = 1
        GROUP BY a.id_agricultor, a.nombre, a.apellido
        ORDER BY cantidad_parcelas DESC, area_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        distribución = []
        
        for row in rows:
            item = {
                'id_agricultor': row.id_agricultor,
                'nombre_propietario': row.nombre_propietario,
                'cantidad_parcelas': row.cantidad_parcelas,
                'area_total': float(row.area_total)
            }
            distribución.append(item)
        
        logger.info(f"Distribución calculada para {len(distribución)} propietarios")
        return distribución
    
    @cacheable('parcelas', key_func=lambda: 'sin_coordenadas', ttl=3600)  # 1 hora - cambia poco
    def obtener_parcelas_sin_coordenadas(self):
        """
        Obtiene parcelas que no tienen coordenadas GPS registradas.
        ⭐ OPTIMIZADO: "Se encontraron 0 parcelas sin coordenadas" constante en logs
        
        Returns:
            list: Lista de parcelas sin coordenadas.
        """
        query = """
        SELECT 
            p.id_parcela,
            p.nombre,
            p.ubicacion,
            a.nombre + ' ' + a.apellido as propietario
        FROM Parcelas p
        JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
        WHERE p.activo = 1 
        AND a.activo = 1
        AND (p.coordenadas_gps IS NULL OR p.coordenadas_gps = '')
        ORDER BY p.nombre
        """
        
        rows = self._ejecutar_consulta(query)
        parcelas_sin_coords = []
        
        for row in rows:
            parcela = {
                'id_parcela': row.id_parcela,
                'nombre': row.nombre,
                'ubicacion': row.ubicacion,
                'propietario': row.propietario
            }
            parcelas_sin_coords.append(parcela)
        
        logger.info(f"Se encontraron {len(parcelas_sin_coords)} parcelas sin coordenadas")
        return parcelas_sin_coords
    
    @cacheable('busquedas', key_func=lambda texto: f"agric_parcelas_{texto.lower().replace(' ', '_')}", ttl=900)  # 15 min
    def buscar_agricultores_con_parcelas(self, texto_busqueda):
        """
        Busca agricultores que tengan parcelas, incluyendo información de sus propiedades.
        
        Args:
            texto_busqueda (str): Texto a buscar en nombre o apellido.
            
        Returns:
            list: Lista de agricultores con información de sus parcelas.
        """
        query = """
        SELECT 
            a.id_agricultor,
            a.nombre,
            a.apellido,
            a.identificacion,
            COUNT(p.id_parcela) as cantidad_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total
        FROM Agricultores a
        LEFT JOIN Parcelas p ON a.id_agricultor = p.id_agricultor AND p.activo = 1
        WHERE a.activo = 1 
        AND (a.nombre LIKE ? OR a.apellido LIKE ? OR CONCAT(a.nombre, ' ', a.apellido) LIKE ?)
        GROUP BY a.id_agricultor, a.nombre, a.apellido, a.identificacion
        HAVING COUNT(p.id_parcela) > 0
        ORDER BY a.nombre, a.apellido
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron, patron))
        
        agricultores = []
        for row in rows:
            agricultor = {
                'id_agricultor': row.id_agricultor,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'identificacion': row.identificacion,
                'cantidad_parcelas': row.cantidad_parcelas,
                'area_total': float(row.area_total)
            }
            agricultores.append(agricultor)
        
        logger.info(f"Búsqueda '{texto_busqueda}' con parcelas: {len(agricultores)} resultados")
        return agricultores
    
    @cacheable('reportes', key_func=lambda: 'propietarios_parcelas_completo', ttl=3600)  # 1 hora
    def obtener_reporte_propietarios_parcelas(self):
        """
        Genera un reporte completo de propietarios y sus parcelas.
        
        Returns:
            list: Reporte detallado por propietario.
        """
        query = """
        SELECT 
            a.id_agricultor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            a.identificacion,
            a.telefono,
            a.correo,
            COUNT(p.id_parcela) as total_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total,
            COALESCE(AVG(p.area_total), 0) as area_promedio,
            MIN(p.fecha_adquisicion) as primera_adquisicion,
            MAX(p.fecha_adquisicion) as ultima_adquisicion
        FROM Agricultores a
        LEFT JOIN Parcelas p ON a.id_agricultor = p.id_agricultor AND p.activo = 1
        WHERE a.es_propietario = 1 AND a.activo = 1
        GROUP BY a.id_agricultor, a.nombre, a.apellido, a.identificacion, a.telefono, a.correo
        ORDER BY area_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        reporte = []
        
        for row in rows:
            item = {
                'id_agricultor': row.id_agricultor,
                'nombre_propietario': row.nombre_propietario,
                'identificacion': row.identificacion,
                'telefono': row.telefono,
                'correo': row.correo,
                'total_parcelas': row.total_parcelas,
                'area_total': float(row.area_total),
                'area_promedio': float(row.area_promedio) if row.area_promedio else 0,
                'primera_adquisicion': self._formatear_fecha(row.primera_adquisicion),
                'ultima_adquisicion': self._formatear_fecha(row.ultima_adquisicion)
            }
            reporte.append(item)
        
        logger.info(f"Reporte generado para {len(reporte)} propietarios")
        return reporte
    
    # ==================== MÉTODOS DE VALIDACIÓN Y TRANSFERENCIA ====================
    
    @cacheable('validaciones', key_func=lambda id_parcela, nuevo_prop: f"transfer_{id_parcela}_{nuevo_prop}", ttl=300)  # 5 min
    def validar_transferencia_parcela(self, id_parcela, nuevo_propietario_id):
        """
        Valida si se puede transferir una parcela a un nuevo propietario.
        
        Args:
            id_parcela (int): ID de la parcela.
            nuevo_propietario_id (int): ID del nuevo propietario.
            
        Returns:
            dict: Información de validación.
            
        Raises:
            RegistroNoEncontrado: Si la parcela o propietario no existen.
        """
        # Verificar que la parcela existe y está activa
        parcela_query = "SELECT id_agricultor, nombre FROM Parcelas WHERE id_parcela = ? AND activo = 1"
        parcela_rows = self._ejecutar_consulta(parcela_query, (id_parcela,))
        
        if not parcela_rows:
            raise RegistroNoEncontrado(f"Parcela con ID {id_parcela} no encontrada")
        
        propietario_actual_id = parcela_rows[0].id_agricultor
        nombre_parcela = parcela_rows[0].nombre
        
        # Verificar que el nuevo propietario existe y es propietario activo
        propietario_query = """
        SELECT nombre, apellido 
        FROM Agricultores 
        WHERE id_agricultor = ? AND es_propietario = 1 AND activo = 1
        """
        propietario_rows = self._ejecutar_consulta(propietario_query, (nuevo_propietario_id,))
        
        if not propietario_rows:
            raise RegistroNoEncontrado(f"Propietario con ID {nuevo_propietario_id} no encontrado o no es propietario activo")
        
        nuevo_propietario_nombre = f"{propietario_rows[0].nombre} {propietario_rows[0].apellido}"
        
        # Obtener información del propietario actual
        propietario_actual_query = """
        SELECT nombre, apellido 
        FROM Agricultores 
        WHERE id_agricultor = ?
        """
        propietario_actual_rows = self._ejecutar_consulta(propietario_actual_query, (propietario_actual_id,))
        propietario_actual_nombre = f"{propietario_actual_rows[0].nombre} {propietario_actual_rows[0].apellido}"
        
        validacion = {
            'puede_transferir': propietario_actual_id != nuevo_propietario_id,
            'parcela_nombre': nombre_parcela,
            'propietario_actual': {
                'id': propietario_actual_id,
                'nombre': propietario_actual_nombre
            },
            'nuevo_propietario': {
                'id': nuevo_propietario_id,
                'nombre': nuevo_propietario_nombre
            }
        }
        
        if not validacion['puede_transferir']:
            logger.warning(f"Intento de transferir parcela {id_parcela} al mismo propietario")
        else:
            logger.info(f"Transferencia validada: parcela {id_parcela} puede pasar de {propietario_actual_nombre} a {nuevo_propietario_nombre}")
        
        return validacion
    
    @cache_invalidator('relaciones', pattern='parcelas_count_')  # Invalidar conteos de parcelas
    @cache_invalidator('estadisticas')                          # Invalidar estadísticas
    @cache_invalidator('distribuciones')                       # Invalidar distribuciones  
    @cache_invalidator('reportes')                             # Invalidar reportes
    @cache_invalidator('validaciones', pattern='transfer_')    # Invalidar validaciones de transferencia
    def ejecutar_transferencia_parcela(self, id_parcela, nuevo_propietario_id):
        """
        Ejecuta la transferencia de una parcela a un nuevo propietario.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            id_parcela (int): ID de la parcela.
            nuevo_propietario_id (int): ID del nuevo propietario.
            
        Returns:
            bool: True si la transferencia fue exitosa.
        """
        # Validar la transferencia primero
        validacion = self.validar_transferencia_parcela(id_parcela, nuevo_propietario_id)
        
        if not validacion['puede_transferir']:
            logger.error("Transferencia no válida")
            return False
        
        # Ejecutar la transferencia
        query = "UPDATE Parcelas SET id_agricultor = ? WHERE id_parcela = ?"
        filas_afectadas = self._ejecutar_consulta(query, (nuevo_propietario_id, id_parcela), obtener_resultado=False)
        
        if filas_afectadas > 0:
            logger.info(f"Parcela {id_parcela} transferida exitosamente al propietario {nuevo_propietario_id}")
            return True
        else:
            logger.error(f"Error en la transferencia de parcela {id_parcela}")
            return False

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================
    
    @cacheable('metricas', key_func=lambda: 'uso_sistema', ttl=1800)  # 30 min
    def obtener_metricas_uso_sistema(self):
        """
        Obtiene métricas de uso del sistema.
        
        Returns:
            dict: Métricas de uso del sistema.
        """
        query = """
        SELECT 
            COUNT(DISTINCT a.id_agricultor) as agricultores_con_parcelas,
            COUNT(DISTINCT CASE WHEN a.es_propietario = 1 THEN a.id_agricultor END) as propietarios_con_parcelas,
            COUNT(p.id_parcela) as total_parcelas_activas,
            AVG(parcelas_por_agricultor.cantidad) as promedio_parcelas_por_agricultor
        FROM Agricultores a
        JOIN Parcelas p ON a.id_agricultor = p.id_agricultor AND p.activo = 1
        JOIN (
            SELECT id_agricultor, COUNT(*) as cantidad
            FROM Parcelas 
            WHERE activo = 1 
            GROUP BY id_agricultor
        ) parcelas_por_agricultor ON a.id_agricultor = parcelas_por_agricultor.id_agricultor
        WHERE a.activo = 1
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        metricas = {
            'agricultores_con_parcelas': row.agricultores_con_parcelas,
            'propietarios_con_parcelas': row.propietarios_con_parcelas,
            'total_parcelas_activas': row.total_parcelas_activas,
            'promedio_parcelas_por_agricultor': float(row.promedio_parcelas_por_agricultor) if row.promedio_parcelas_por_agricultor else 0
        }
        
        logger.info(f"Métricas de uso calculadas: {metricas}")
        return metricas

    @cacheable('ranking', key_func=lambda: 'top_propietarios', ttl=2400)  # 40 min
    def obtener_top_propietarios_por_area(self, limite=10):
        """
        Obtiene los top propietarios por área total.
        
        Args:
            limite (int): Número máximo de propietarios a retornar.
            
        Returns:
            list: Lista de top propietarios.
        """
        query = """
        SELECT TOP (?)
            a.id_agricultor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            COUNT(p.id_parcela) as total_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total
        FROM Agricultores a
        JOIN Parcelas p ON a.id_agricultor = p.id_agricultor AND p.activo = 1
        WHERE a.es_propietario = 1 AND a.activo = 1
        GROUP BY a.id_agricultor, a.nombre, a.apellido
        ORDER BY area_total DESC
        """
        
        rows = self._ejecutar_consulta(query, (limite,))
        top_propietarios = []
        
        for i, row in enumerate(rows, 1):
            propietario = {
                'ranking': i,
                'id_agricultor': row.id_agricultor,
                'nombre_propietario': row.nombre_propietario,
                'total_parcelas': row.total_parcelas,
                'area_total': float(row.area_total)
            }
            top_propietarios.append(propietario)
        
        logger.info(f"Top {len(top_propietarios)} propietarios por área calculado")
        return top_propietarios