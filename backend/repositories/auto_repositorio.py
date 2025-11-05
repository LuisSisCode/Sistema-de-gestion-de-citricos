# backend/core/auto_repositorio.py
"""
Generador automático de repositorios desde tablas SQL
Permite crear repositorios dinámicamente sin código repetitivo
"""

from typing import Dict, List, Optional, Tuple, Any
from backend.core.repositorio_base import RepositorioBase
from backend.core.excepciones_bd import RegistroNoEncontrado, ErrorValidacion
from backend.core.cache_system import cacheable, cache_invalidator


class AutoRepositorio(RepositorioBase):
    """
    Repositorio base automático que genera métodos CRUD dinámicamente
    a partir de la estructura de una tabla SQL
    """
    
    def __init__(
        self, 
        nombre_tabla: str,
        nombre_id: str = None,
        campos_requeridos: List[str] = None,
        campos_unicos: List[str] = None,
        server=None,
        database=None,
        trusted_connection=None
    ):
        """
        Inicializa un repositorio automático
        
        Args:
            nombre_tabla: Nombre de la tabla en la BD
            nombre_id: Nombre del campo ID (ej: 'id_usuario', 'id_rol')
            campos_requeridos: Lista de campos que NO pueden ser NULL
            campos_unicos: Lista de campos que deben ser únicos
        """
        super().__init__(server, database, trusted_connection)
        
        self.nombre_tabla = nombre_tabla
        self.nombre_id = nombre_id or f"id_{nombre_tabla.lower()}"
        self.campos_requeridos = campos_requeridos or []
        self.campos_unicos = campos_unicos or []
        
        # Detectar estructura de la tabla automáticamente
        self.estructura = self._obtener_estructura_tabla()
        self.columnas = [col['nombre'] for col in self.estructura]
        
        print(f"✅ AutoRepositorio creado para tabla: {self.nombre_tabla}")
        print(f"   📋 Columnas detectadas: {len(self.columnas)}")
    
    def _obtener_estructura_tabla(self) -> List[Dict]:
        """
        Obtiene la estructura de la tabla desde la BD
        
        Returns:
            list: Lista de diccionarios con info de cada columna
        """
        query = """
        SELECT 
            COLUMN_NAME as nombre,
            DATA_TYPE as tipo,
            CHARACTER_MAXIMUM_LENGTH as longitud,
            IS_NULLABLE as nullable,
            COLUMN_DEFAULT as default_value
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = ?
        ORDER BY ORDINAL_POSITION
        """
        
        rows = self._ejecutar_consulta(query, (self.nombre_tabla,))
        
        estructura = []
        for row in rows:
            estructura.append({
                'nombre': row.nombre,
                'tipo': row.tipo,
                'longitud': row.longitud,
                'nullable': row.nullable == 'YES',
                'default': row.default_value
            })
        
        return estructura
    
    @cacheable('auto', ttl=3600)
    def obtener_todos(self, activo_solo=True) -> List[Dict]:
        """
        Obtiene todos los registros de la tabla
        
        Args:
            activo_solo: Si es True, solo obtiene registros activos
            
        Returns:
            list: Lista de registros
        """
        # Construir query dinámicamente
        columnas = ", ".join(self.columnas)
        query = f"SELECT {columnas} FROM {self.nombre_tabla}"
        
        # Si la tabla tiene columna 'activo', filtrar por activos
        if activo_solo and 'activo' in self.columnas:
            query += " WHERE activo = 1"
        
        rows = self._ejecutar_consulta(query)
        
        registros = []
        for row in rows:
            registro = {}
            for i, col in enumerate(self.columnas):
                valor = getattr(row, col)
                
                # Formatear fechas
                if 'fecha' in col.lower():
                    valor = self._formatear_fecha(valor)
                
                # Convertir bits a bool
                if isinstance(valor, int) and col in ['activo', 'es_propietario']:
                    valor = bool(valor)
                
                registro[col] = valor
            
            registros.append(registro)
        
        print(f"✅ Obtenidos {len(registros)} registros de {self.nombre_tabla}")
        return registros
    
    @cacheable('auto', ttl=3600)
    def obtener_por_id(self, id_registro: int) -> Dict:
        """
        Obtiene un registro por su ID
        
        Args:
            id_registro: ID del registro
            
        Returns:
            dict: Datos del registro
            
        Raises:
            RegistroNoEncontrado: Si el registro no existe
        """
        columnas = ", ".join(self.columnas)
        query = f"SELECT {columnas} FROM {self.nombre_tabla} WHERE {self.nombre_id} = ?"
        
        rows = self._ejecutar_consulta(query, (id_registro,))
        
        if not rows:
            raise RegistroNoEncontrado(
                f"Registro con {self.nombre_id} = {id_registro} no encontrado en {self.nombre_tabla}"
            )
        
        row = rows[0]
        registro = {}
        
        for col in self.columnas:
            valor = getattr(row, col)
            
            # Formatear fechas
            if 'fecha' in col.lower():
                valor = self._formatear_fecha(valor)
            
            # Convertir bits a bool
            if isinstance(valor, int) and col in ['activo', 'es_propietario']:
                valor = bool(valor)
            
            registro[col] = valor
        
        return registro
    
    @cache_invalidator('auto')
    def crear(self, datos: Dict) -> Tuple[bool, Optional[int]]:
        """
        Crea un nuevo registro
        
        Args:
            datos: Diccionario con los datos del registro
            
        Returns:
            tuple: (éxito: bool, id_creado: int o None)
            
        Raises:
            ErrorValidacion: Si los datos no son válidos
        """
        # Validar datos
        valido, errores = self._validar_datos(datos, es_nuevo=True)
        if not valido:
            raise ErrorValidacion(f"Datos inválidos: {', '.join(errores)}")
        
        # Filtrar solo columnas que existen en la tabla
        datos_filtrados = {k: v for k, v in datos.items() if k in self.columnas}
        
        # Excluir el ID (se genera automáticamente)
        if self.nombre_id in datos_filtrados:
            del datos_filtrados[self.nombre_id]
        
        # Construir query INSERT
        columnas = list(datos_filtrados.keys())
        placeholders = ", ".join(["?" for _ in columnas])
        columnas_str = ", ".join(columnas)
        
        query = f"INSERT INTO {self.nombre_tabla} ({columnas_str}) VALUES ({placeholders})"
        
        # Ejecutar
        valores = tuple(datos_filtrados[col] for col in columnas)
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        id_creado = self._obtener_ultimo_id()
        
        print(f"✅ Registro creado en {self.nombre_tabla} con ID: {id_creado}")
        return True, id_creado
    
    @cache_invalidator('auto')
    def actualizar(self, id_registro: int, datos: Dict) -> bool:
        """
        Actualiza un registro existente
        
        Args:
            id_registro: ID del registro a actualizar
            datos: Datos a actualizar
            
        Returns:
            bool: True si se actualizó
        """
        # Verificar que el registro existe
        self.obtener_por_id(id_registro)
        
        # Filtrar solo columnas que existen
        datos_filtrados = {k: v for k, v in datos.items() if k in self.columnas}
        
        # No actualizar el ID
        if self.nombre_id in datos_filtrados:
            del datos_filtrados[self.nombre_id]
        
        if not datos_filtrados:
            print("⚠️ No hay datos para actualizar")
            return False
        
        # Construir query UPDATE
        set_clause = ", ".join([f"{col} = ?" for col in datos_filtrados.keys()])
        query = f"UPDATE {self.nombre_tabla} SET {set_clause} WHERE {self.nombre_id} = ?"
        
        # Ejecutar
        valores = tuple(list(datos_filtrados.values()) + [id_registro])
        filas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        if filas > 0:
            print(f"✅ Registro {id_registro} actualizado en {self.nombre_tabla}")
            return True
        else:
            print(f"⚠️ No se actualizó el registro {id_registro}")
            return False
    
    @cache_invalidator('auto')
    def eliminar(self, id_registro: int) -> bool:
        """
        Elimina un registro físicamente
        
        Args:
            id_registro: ID del registro
            
        Returns:
            bool: True si se eliminó
        """
        query = f"DELETE FROM {self.nombre_tabla} WHERE {self.nombre_id} = ?"
        filas = self._ejecutar_consulta(query, (id_registro,), obtener_resultado=False)
        
        if filas > 0:
            print(f"✅ Registro {id_registro} eliminado de {self.nombre_tabla}")
            return True
        else:
            print(f"⚠️ No se pudo eliminar el registro {id_registro}")
            return False
    
    @cache_invalidator('auto')
    def desactivar(self, id_registro: int) -> bool:
        """
        Desactiva un registro (soft delete)
        
        Args:
            id_registro: ID del registro
            
        Returns:
            bool: True si se desactivó
        """
        if 'activo' not in self.columnas:
            print(f"⚠️ La tabla {self.nombre_tabla} no tiene columna 'activo'")
            return False
        
        return self.actualizar(id_registro, {'activo': 0})
    
    def _validar_datos(self, datos: Dict, es_nuevo: bool = False) -> Tuple[bool, List[str]]:
        """
        Valida los datos antes de crear/actualizar
        
        Args:
            datos: Datos a validar
            es_nuevo: True si es un registro nuevo
            
        Returns:
            tuple: (válido: bool, lista_errores: list)
        """
        errores = []
        
        # Validar campos requeridos (solo al crear)
        if es_nuevo:
            for campo in self.campos_requeridos:
                if campo not in datos or not datos[campo]:
                    errores.append(f"Campo '{campo}' es requerido")
        
        # Validar campos únicos
        for campo in self.campos_unicos:
            if campo in datos:
                # Verificar si ya existe
                count = self._contar_registros(
                    self.nombre_tabla,
                    f"{campo} = ?",
                    (datos[campo],)
                )
                if count > 0:
                    errores.append(f"Ya existe un registro con {campo} = '{datos[campo]}'")
        
        return len(errores) == 0, errores
    
    def buscar(self, campo: str, valor: Any) -> List[Dict]:
        """
        Busca registros por un campo específico
        
        Args:
            campo: Nombre del campo
            valor: Valor a buscar
            
        Returns:
            list: Lista de registros encontrados
        """
        if campo not in self.columnas:
            print(f"⚠️ Campo '{campo}' no existe en {self.nombre_tabla}")
            return []
        
        columnas = ", ".join(self.columnas)
        query = f"SELECT {columnas} FROM {self.nombre_tabla} WHERE {campo} = ?"
        
        if 'activo' in self.columnas:
            query += " AND activo = 1"
        
        rows = self._ejecutar_consulta(query, (valor,))
        
        registros = []
        for row in rows:
            registro = {}
            for col in self.columnas:
                valor_col = getattr(row, col)
                
                if 'fecha' in col.lower():
                    valor_col = self._formatear_fecha(valor_col)
                
                if isinstance(valor_col, int) and col in ['activo', 'es_propietario']:
                    valor_col = bool(valor_col)
                
                registro[col] = valor_col
            
            registros.append(registro)
        
        return registros


# ============================================
# EJEMPLO DE USO
# ============================================

def ejemplo_uso():
    """Ejemplo de cómo usar AutoRepositorio"""
    
    # Crear un repositorio para la tabla Roles
    roles_repo = AutoRepositorio(
        nombre_tabla='Roles',
        nombre_id='id_rol',
        campos_requeridos=['nombre_rol', 'nivel_acceso'],
        campos_unicos=['nombre_rol']
    )
    
    # Obtener todos los roles
    roles = roles_repo.obtener_todos()
    print(f"Roles: {roles}")
    
    # Obtener un rol por ID
    rol = roles_repo.obtener_por_id(5)
    print(f"Rol: {rol}")
    
    # Crear un nuevo rol
    nuevo_rol = {
        'nombre_rol': 'Contador',
        'descripcion': 'Rol para contabilidad',
        'nivel_acceso': 70,
        'activo': 1
    }
    exito, id_rol = roles_repo.crear(nuevo_rol)
    print(f"Rol creado: {exito}, ID: {id_rol}")
    
    # Actualizar
    roles_repo.actualizar(id_rol, {'descripcion': 'Rol actualizado'})
    
    # Desactivar
    roles_repo.desactivar(id_rol)