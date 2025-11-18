# bd_conecciones/repositorios/relacion_repositorio.py

import logging
from ...core.repositorio_base import RepositorioBase
from ...core.excepciones_bd import RegistroNoEncontrado, RegistroTieneDependencias
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class RelacionRepositorio(RepositorioBase):
    """Repositorio para consultas que involucran múltiples tablas con caché optimizado."""
    
    @cacheable('relaciones', key_func=lambda id_agr: f"parcelas_count_{id_agr}", ttl=1800)  # 30 min
    def contar_parcelas_por_productor(self, id_productor):
        """
        Cuenta las parcelas activas de un productor específico.
        ⭐ MUY OPTIMIZADO: Era la consulta más repetida en logs (16+ veces)
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            int: Número de parcelas activas del productor.
        """
        count = self._contar_registros(
            "Parcelas", 
            "id_productor = ? AND activo = 1", 
            (id_productor)
        )
        
        logger.info(f"Agricultor {id_productor} tiene {count} parcelas activas")
        return count
    
    @cacheable('relaciones', key_func=lambda id_agr: f"dependencias_{id_agr}", ttl=1200)  # 20 min
    def verificar_dependencias_productor(self, id_productor):
        """
        Verifica todas las dependencias de un productor antes de eliminarlo.
        
        Args:
            id_productor(int): ID del productor.
            
        Returns:
            dict: Información detallada de dependencias.
            
        Raises:
            RegistroTieneDependencias: Si tiene dependencias que impiden la eliminación.
        """
        # Contar parcelas (ahora cacheado)
        parcelas = self.contar_parcelas_por_productor(id_productor)
        
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
            mensaje = f"No se puede eliminar el productor. Tiene {parcelas} parcelas asociadas."
            raise RegistroTieneDependencias(mensaje, parcelas)
        
        logger.info(f"Agricultor {id_productor} puede ser eliminado - sin dependencias")
        return dependencias
    
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
            (SELECT COUNT(*) FROM Productores WHERE activo = 1) as total_productores,
            (SELECT COUNT(*) FROM Parcelas WHERE activo = 1) as total_parcelas,
            (SELECT COALESCE(SUM(area_total), 0) FROM Parcelas WHERE activo = 1) as area_total,
            (SELECT COALESCE(AVG(area_total), 0) FROM Parcelas WHERE activo = 1) as area_promedio
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        estadisticas = {
            'productores': {
                'total': row.total_productores,
                'trabajadores': row.total_productores
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
            a.id_productor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            COUNT(p.id_parcela) as cantidad_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total
        FROM Productores a
        LEFT JOIN Parcelas p ON a.id_productor = p.id_productor AND p.activo = 1
        WHERE a.activo = 1
        GROUP BY a.id_productor, a.nombre, a.apellido
        ORDER BY cantidad_parcelas DESC, area_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        distribución = []
        
        for row in rows:
            item = {
                'id_productor': row.id_productor,
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
        JOIN Productores a ON p.id_productor = a.id_productor
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
    def buscar_productores_con_parcelas(self, texto_busqueda):
        """
        Busca productores que tengan parcelas, incluyendo información de sus propiedades.
        
        Args:
            texto_busqueda (str): Texto a buscar en nombre o apellido.
            
        Returns:
            list: Lista de productores con información de sus parcelas.
        """
        query = """
        SELECT 
            a.id_productor,
            a.nombre,
            a.apellido,
            a.identificacion,
            COUNT(p.id_parcela) as cantidad_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total
        FROM Productores a
        LEFT JOIN Parcelas p ON a.id_productor= p.id_productorAND p.activo = 1
        WHERE a.activo = 1 
        AND (a.nombre LIKE ? OR a.apellido LIKE ? OR CONCAT(a.nombre, ' ', a.apellido) LIKE ?)
        GROUP BY a.id_productor a.nombre, a.apellido, a.identificacion
        HAVING COUNT(p.id_parcela) > 0
        ORDER BY a.nombre, a.apellido
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron, patron))
        
        productores = []
        for row in rows:
            productor = {
                'id_productor': row.id_productor,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'identificacion': row.identificacion,
                'cantidad_parcelas': row.cantidad_parcelas,
                'area_total': float(row.area_total)
            }
            productores.append(productor)
        
        logger.info(f"Búsqueda '{texto_busqueda}' con parcelas: {len(productores)} resultados")
        return productores
    
    @cacheable('reportes', key_func=lambda: 'propietarios_parcelas_completo', ttl=3600)  # 1 hora
    def obtener_reporte_propietarios_parcelas(self):
        """
        Genera un reporte completo de propietarios y sus parcelas.
        
        Returns:
            list: Reporte detallado por propietario.
        """
        query = """
        SELECT 
            a.id_productor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            a.identificacion,
            a.telefono,
            a.correo,
            COUNT(p.id_parcela) as total_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total,
            COALESCE(AVG(p.area_total), 0) as area_promedio,
            MIN(p.fecha_adquisicion) as primera_adquisicion,
            MAX(p.fecha_adquisicion) as ultima_adquisicion
        FROM Productores a
        LEFT JOIN Parcelas p ON a.id_productor = p.id_productor AND p.activo = 1
        WHERE a.activo = 1
        GROUP BY a.id_productor, a.nombre, a.apellido, a.identificacion, a.telefono, a.correo
        ORDER BY area_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        reporte = []
        
        for row in rows:
            item = {
                'id_productor': row.id_productor,
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
        parcela_query = "SELECT id_productor, nombre FROM Parcelas WHERE id_parcela = ? AND activo = 1"
        parcela_rows = self._ejecutar_consulta(parcela_query, (id_parcela,))
        
        if not parcela_rows:
            raise RegistroNoEncontrado(f"Parcela con ID {id_parcela} no encontrada")
        
        propietario_actual_id = parcela_rows[0].id_productor
        nombre_parcela = parcela_rows[0].nombre
        
        # Verificar que el nuevo propietario existe y es propietario activo
        propietario_query = """
        SELECT nombre, apellido 
        FROM Productores
        WHERE id_productor = ? AND activo = 1
        """
        propietario_rows = self._ejecutar_consulta(propietario_query, (nuevo_propietario_id,))
        
        if not propietario_rows:
            raise RegistroNoEncontrado(f"Propietario con ID {nuevo_propietario_id} no encontrado o no es propietario activo")
        
        nuevo_propietario_nombre = f"{propietario_rows[0].nombre} {propietario_rows[0].apellido}"
        
        # Obtener información del propietario actual
        propietario_actual_query = """
        SELECT nombre, apellido 
        FROM Productores 
        WHERE id_productor = ?
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
            COUNT(DISTINCT a.id_productor) as productores_con_parcelas,
            COUNT(p.id_parcela) as total_parcelas_activas,
            AVG(parcelas_por_productor.cantidad) as promedio_parcelas_por_productor
        FROM Productores a
        JOIN Parcelas p ON a.id_productor= p.id_productorAND p.activo = 1
        JOIN (
            SELECT id_productor, COUNT(*) as cantidad
            FROM Parcelas 
            WHERE activo = 1 
            GROUP BY id_productor
        ) parcelas_por_productor ON a.id_productor = parcelas_por_productor.id_productor
        WHERE a.activo = 1
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        metricas = {
            'productores_con_parcelas': row.productores_con_parcelas,
            'propietarios_con_parcelas': row.propietarios_con_parcelas,
            'total_parcelas_activas': row.total_parcelas_activas,
            'promedio_parcelas_por_productor': float(row.promedio_parcelas_por_productor) if row.promedio_parcelas_por_productor else 0
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
            a.id_productor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            COUNT(p.id_parcela) as total_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total
        FROM Productores a
        JOIN Parcelas p ON a.id_productor = p.id_productor AND p.activo = 1
        WHERE a.activo = 1
        GROUP BY a.id_productor a.nombre, a.apellido
        ORDER BY area_total DESC
        """
        
        rows = self._ejecutar_consulta(query, (limite,))
        top_propietarios = []
        
        for i, row in enumerate(rows, 1):
            propietario = {
                'ranking': i,
                'id_productor': row.id_productor,
                'nombre_propietario': row.nombre_propietario,
                'total_parcelas': row.total_parcelas,
                'area_total': float(row.area_total)
            }
            top_propietarios.append(propietario)
        
        logger.info(f"Top {len(top_propietarios)} propietarios por área calculado")
        return top_propietarios