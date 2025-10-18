# bd_conecciones/repositorios/agricultor_repositorio.py

import logging
from datetime import datetime
from ..nucleo.repositorio_base import RepositorioBase
from ..nucleo.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion

logger = logging.getLogger(__name__)

class AgricultorRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de agricultores."""
    
    def obtener_todos(self):
        """
        Obtiene todos los agricultores activos.
        
        Returns:
            list: Lista de diccionarios con información de agricultores.
        """
        query = """
        SELECT id_agricultor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               es_propietario, activo
        FROM Agricultores
        WHERE activo = 1
        ORDER BY id_agricultor
        """
        
        rows = self._ejecutar_consulta(query)
        agricultores = []
        
        for row in rows:
            agricultor = {
                'id_agricultor': row.id_agricultor,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'identificacion': row.identificacion,
                'telefono': row.telefono,
                'correo': row.correo,
                'direccion': row.direccion,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'esPropietario': bool(row.es_propietario),
                'activo': bool(row.activo)
            }
            agricultores.append(agricultor)
        
        logger.info(f"Se obtuvieron {len(agricultores)} agricultores")
        return agricultores
    
    def obtener_por_id(self, id_agricultor):
        """
        Obtiene un agricultor por su ID.
        
        Args:
            id_agricultor (int): ID del agricultor.
            
        Returns:
            dict: Información del agricultor.
            
        Raises:
            RegistroNoEncontrado: Si el agricultor no existe.
        """
        query = """
        SELECT id_agricultor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               es_propietario, activo
        FROM Agricultores
        WHERE id_agricultor = ? AND activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_agricultor,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Agricultor con ID {id_agricultor} no encontrado")
        
        row = rows[0]
        return {
            'id_agricultor': row.id_agricultor,
            'nombre': row.nombre,
            'apellido': row.apellido,
            'identificacion': row.identificacion,
            'telefono': row.telefono,
            'correo': row.correo,
            'direccion': row.direccion,
            'fecha_registro': self._formatear_fecha(row.fecha_registro),
            'esPropietario': bool(row.es_propietario),
            'activo': bool(row.activo)
        }
    
    def obtener_paginado(self, pagina, por_pagina=10):
        """
        Obtiene agricultores con paginación.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Agricultores, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Contar total de registros activos
        total_registros = self._contar_registros("Agricultores", "activo = 1")
        
        # Obtener registros paginados
        query = """
        SELECT id_agricultor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               es_propietario, activo
        FROM Agricultores
        WHERE activo = 1
        ORDER BY id_agricultor
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        rows = self._ejecutar_consulta(query, (offset, por_pagina))
        agricultores = []
        
        for row in rows:
            agricultor = {
                'id_agricultor': row.id_agricultor,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'identificacion': row.identificacion,
                'telefono': row.telefono,
                'correo': row.correo,
                'direccion': row.direccion,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'esPropietario': bool(row.es_propietario),
                'activo': bool(row.activo)
            }
            agricultores.append(agricultor)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'agricultores': agricultores,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina
        }
        
        logger.info(f"Página {pagina}: {len(agricultores)} agricultores de {total_registros} totales")
        return resultado
    
    def crear(self, datos_agricultor):
        """
        Crea un nuevo agricultor.
        
        Args:
            datos_agricultor (dict): Datos del agricultor.
            
        Returns:
            tuple: (True, id_agricultor) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
            RegistroYaExiste: Si la identificación ya existe.
        """
        self._validar_datos_agricultor(datos_agricultor)
        
        # Verificar si la identificación ya existe
        if self._existe_identificacion(datos_agricultor['identificacion']):
            raise RegistroYaExiste(f"Ya existe un agricultor con identificación {datos_agricultor['identificacion']}")
        
        query = """
        INSERT INTO Agricultores (nombre, apellido, identificacion, telefono, 
                              correo, direccion, fecha_registro, es_propietario, activo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        fecha_actual = datetime.now().date().strftime('%Y-%m-%d')
        valores = (
            datos_agricultor['nombre'],
            datos_agricultor['apellido'],
            datos_agricultor['identificacion'],
            datos_agricultor.get('telefono'),
            datos_agricultor.get('correo'),
            datos_agricultor.get('direccion'),
            fecha_actual,
            1 if datos_agricultor.get('esPropietario', False) else 0,
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_agricultor = self._obtener_ultimo_id()
        
        logger.info(f"Agricultor creado con ID: {id_agricultor}")
        return True, id_agricultor
    
    def actualizar(self, id_agricultor, datos_agricultor):
        """
        Actualiza un agricultor existente.
        
        Args:
            id_agricultor (int): ID del agricultor.
            datos_agricultor (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el agricultor no existe.
            ErrorValidacion: Si los datos no son válidos.
        """
        # Verificar que el agricultor existe
        self.obtener_por_id(id_agricultor)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'nombre' in datos_agricultor:
            campos_actualizar.append("nombre = ?")
            valores.append(datos_agricultor['nombre'])
            
        if 'apellido' in datos_agricultor:
            campos_actualizar.append("apellido = ?")
            valores.append(datos_agricultor['apellido'])
            
        if 'identificacion' in datos_agricultor:
            # Verificar que la nueva identificación no exista (excluyendo el registro actual)
            if self._existe_identificacion_excepto(datos_agricultor['identificacion'], id_agricultor):
                raise RegistroYaExiste(f"Ya existe otro agricultor con identificación {datos_agricultor['identificacion']}")
            campos_actualizar.append("identificacion = ?")
            valores.append(datos_agricultor['identificacion'])
            
        if 'telefono' in datos_agricultor:
            campos_actualizar.append("telefono = ?")
            valores.append(datos_agricultor['telefono'])
            
        if 'correo' in datos_agricultor:
            campos_actualizar.append("correo = ?")
            valores.append(datos_agricultor['correo'])
            
        if 'direccion' in datos_agricultor:
            campos_actualizar.append("direccion = ?")
            valores.append(datos_agricultor['direccion'])
            
        if 'esPropietario' in datos_agricultor:
            campos_actualizar.append("es_propietario = ?")
            valores.append(1 if datos_agricultor['esPropietario'] else 0)
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        query = f"UPDATE Agricultores SET {', '.join(campos_actualizar)} WHERE id_agricultor = ?"
        valores.append(id_agricultor)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Agricultor {id_agricultor} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0
    
    def desactivar(self, id_agricultor):
        """
        Desactiva un agricultor (eliminación lógica).
        
        Args:
            id_agricultor (int): ID del agricultor.
            
        Returns:
            bool: True si se desactivó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el agricultor no existe.
        """
        # Verificar que el agricultor existe
        self.obtener_por_id(id_agricultor)
        
        query = "UPDATE Agricultores SET activo = 0 WHERE id_agricultor = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_agricultor,), obtener_resultado=False)
        
        logger.info(f"Agricultor {id_agricultor} desactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0
    
    def buscar_por_nombre(self, texto_busqueda):
        """
        Busca agricultores por nombre o apellido.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de agricultores que coinciden.
        """
        query = """
        SELECT id_agricultor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               es_propietario, activo
        FROM Agricultores
        WHERE activo = 1 
        AND (nombre LIKE ? OR apellido LIKE ? OR CONCAT(nombre, ' ', apellido) LIKE ?)
        ORDER BY nombre, apellido
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
                'telefono': row.telefono,
                'correo': row.correo,
                'direccion': row.direccion,
                'fecha_registro': self._formatear_fecha(row.fecha_registro),
                'esPropietario': bool(row.es_propietario),
                'activo': bool(row.activo)
            }
            agricultores.append(agricultor)
        
        logger.info(f"Búsqueda '{texto_busqueda}': {len(agricultores)} resultados")
        return agricultores
    
    def obtener_propietarios(self):
        """
        Obtiene la lista de agricultores que son propietarios.
        
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
        
        logger.info(f"Se obtuvieron {len(propietarios)} propietarios")
        return propietarios
    
    def _validar_datos_agricultor(self, datos):
        """
        Valida los datos del agricultor.
        
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
        count = self._contar_registros("Agricultores", "identificacion = ? AND activo = 1", (identificacion,))
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
            "Agricultores", 
            "identificacion = ? AND activo = 1 AND id_agricultor != ?", 
            (identificacion, id_excluir)
        )
        return count > 0

x = AgricultorRepositorio("DESKTOP-NVQ729A", "Producto_CitricosS")
x.obtener_todos()