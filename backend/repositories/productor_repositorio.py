# bd_conecciones/repositorios/productor_repositorio.py

import logging
from datetime import datetime
from ..core.repositorio_base import RepositorioBase
from ..core.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion

logger = logging.getLogger(__name__)

class ProductorRepositorio(RepositorioBase):
    #ProductorRepositorio
    """Repositorio para operaciones CRUD de productores."""
    
    def obtener_todos(self):
        """
        Obtiene todos los productores activos.
        
        Returns:
            list: Lista de diccionarios con información de productores.
        """
        query = """
        SELECT id_productor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               activo
        FROM Productores
        WHERE activo = 1
        ORDER BY id_productor
        """
        
        rows = self._ejecutar_consulta(query)
        productores = []
        
        for row in rows:
            productor = {
                'id_productor': row.id_productor,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'identificacion': row.identificacion,
                'telefono': row.telefono,
                'correo': row.correo,
                'direccion': row.direccion,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'activo': bool(row.activo)
            }
            productores.append(productor)
        
        logger.info(f"Se obtuvieron {len(productores)} productores activos")
        return productores
    
    def obtener_por_id(self, id_productor):
        """
        Obtiene un productor por su ID.
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            dict: Información del productor.
            
        Raises:
            RegistroNoEncontrado: Si el productor no existe.
        """
        query = """
        SELECT id_productor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               activo
        FROM Productores
        WHERE id_productor = ? AND activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_productor,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Productor con ID {id_productor} no encontrado")
        
        row = rows[0]
        return {
            'id_productor': row.id_productor,
            'nombre': row.nombre,
            'apellido': row.apellido,
            'identificacion': row.identificacion,
            'telefono': row.telefono,
            'correo': row.correo,
            'direccion': row.direccion,
            'fecha_registro': self._formatear_fecha(row.fecha_registro),
            'activo': bool(row.activo)
        }
    
    def obtener_paginado(self, pagina, por_pagina=10):
        """
        Obtiene Productores con paginación.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Productores, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Contar total de registros activos
        total_registros = self._contar_registros("Productores", "activo = 1")
        
        # Obtener registros paginados
        query = """
        SELECT id_productor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               activo
        FROM Productores
        WHERE activo = 1
        ORDER BY id_productor
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        rows = self._ejecutar_consulta(query, (offset, por_pagina))
        productores = []
        
        for row in rows:
            productor = {
                'id_productor': row.id_productor,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'identificacion': row.identificacion,
                'telefono': row.telefono,
                'correo': row.correo,
                'direccion': row.direccion,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'activo': bool(row.activo)
            }
            productores.append(productor)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'productores': productores,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina
        }
        
        logger.info(f"Página {pagina}: {len(productores)} productores de {total_registros} totales")
        return resultado
    
    def crear(self, datos_productor):
        """
        Crea un nuevo productor.
        
        Args:
            datos_productor (dict): Datos del productor .
            
        Returns:
            tuple: (True, id_productor) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
            RegistroYaExiste: Si la identificación ya existe.
        """
        self._validar_datos_productor(datos_productor)
        
        # Verificar si la identificación ya existe
        if self._existe_identificacion(datos_productor['identificacion']):
            raise RegistroYaExiste(f"Ya existe un productor con identificación {datos_productor['identificacion']}")
        
        query = """
        INSERT INTO Productores (nombre, apellido, identificacion, telefono, 
                              correo, direccion, fecha_registro, activo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        fecha_actual = datetime.now().date().strftime('%Y-%m-%d')
        valores = (
            datos_productor['nombre'],
            datos_productor['apellido'],
            datos_productor['identificacion'],
            datos_productor.get('telefono'),
            datos_productor.get('correo'),
            datos_productor.get('direccion'),
            fecha_actual,
            1 if datos_productor.get('esPropietario', False) else 0,
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_productor = self._obtener_ultimo_id()
        
        logger.info(f"Agricultor creado con ID: {id_productor}")
        return True, id_productor
    
    def actualizar(self, id_productor, datos_productor):
        """
        Actualiza un productor existente.
        
        Args:
            id_productor (int): ID del productor.
            datos_productor (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el productor no existe.
            ErrorValidacion: Si los datos no son válidos.
        """
        # Verificar que el productor existe
        self.obtener_por_id(id_productor)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'nombre' in datos_productor:
            campos_actualizar.append("nombre = ?")
            valores.append(datos_productor['nombre'])
            
        if 'apellido' in datos_productor:
            campos_actualizar.append("apellido = ?")
            valores.append(datos_productor['apellido'])
            
        if 'identificacion' in datos_productor:
            # Verificar que la nueva identificación no exista (excluyendo el registro actual)
            if self._existe_identificacion_excepto(datos_productor['identificacion'], id_productor):
                raise RegistroYaExiste(f"Ya existe otro productor con identificación {datos_productor['identificacion']}")
            campos_actualizar.append("identificacion = ?")
            valores.append(datos_productor['identificacion'])
            
        if 'telefono' in datos_productor:
            campos_actualizar.append("telefono = ?")
            valores.append(datos_productor['telefono'])
            
        if 'correo' in datos_productor:
            campos_actualizar.append("correo = ?")
            valores.append(datos_productor['correo'])
            
        if 'direccion' in datos_productor:
            campos_actualizar.append("direccion = ?")
            valores.append(datos_productor['direccion'])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        query = f"UPDATE Productores SET {', '.join(campos_actualizar)} WHERE id_productor = ?"
        valores.append(id_productor)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Agricultor {id_productor} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0
    
    def desactivar(self, id_productor):
        """
        Desactiva un productor (eliminación lógica).
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            bool: True si se desactivó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el productor no existe.
        """
        # Verificar que el productor existe
        self.obtener_por_id(id_productor)
        
        query = "UPDATE Productores SET activo = 0 WHERE id_productor = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_productor,), obtener_resultado=False)
        
        logger.info(f"Agricultor {id_productor} desactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0
    
    def buscar_por_nombre(self, texto_busqueda):
        """
        Busca productores por nombre o apellido.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de productores que coinciden.
        """
        query = """
        SELECT id_productor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               activo
        FROM Productores
        WHERE activo = 1 
        AND (nombre LIKE ? OR apellido LIKE ? OR CONCAT(nombre, ' ', apellido) LIKE ?)
        ORDER BY nombre, apellido
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
                'telefono': row.telefono,
                'correo': row.correo,
                'direccion': row.direccion,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'activo': bool(row.activo)
            }
            productores.append(productor)
        
        logger.info(f"Búsqueda '{texto_busqueda}': {len(productores)} resultados")
        return productores
    
    def _validar_datos_productor(self, datos):
        """
        Valida los datos del productor.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('nombre') or not datos.get('nombre').strip():
            raise ErrorValidacion("El nombre es obligatorio")
            
        if not datos.get('apellido') or not datos.get('apellido').strip():
            raise ErrorValidacion("El apellido es obligatorio")
            
        if not datos.get('identificacion') or not datos.get('identificacion').strip():
            raise ErrorValidacion("La identificación es obligatoria")
        
        # Validar formato de correo si se proporciona
        if datos.get('correo'):
            import re
            email_regex = r'\w+([-+.\']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*'
            if not re.match(email_regex, datos['correo']):
                raise ErrorValidacion("El formato del correo electrónico no es válido")
    
    def _existe_identificacion(self, identificacion):
        """
        Verifica si una identificación ya existe.
        
        Args:
            identificacion (str): Identificación a verificar.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros("Productores", "identificacion = ? AND activo = 1", (identificacion,))
        return count > 0
    
    def _existe_identificacion_excepto(self, identificacion, id_excluir):
        """
        Verifica si una identificación ya existe excluyendo un ID específico.
        
        Args:
            identificacion (str): Identificación a verificar.
            id_excluir (int): ID a excluir de la búsqueda.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros(
            "Productores", 
            "identificacion = ? AND activo = 1 AND id_productor != ?", 
            (identificacion, id_excluir)
        )
        return count > 0