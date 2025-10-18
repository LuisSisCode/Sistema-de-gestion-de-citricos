# bd_conecciones/nucleo/excepciones_bd.py

class ExcepcionBaseDatos(Exception):
    """Excepción base para errores de base de datos."""
    pass

class ErrorConexion(ExcepcionBaseDatos):
    """Error al conectar con la base de datos."""
    pass

class ErrorConsulta(ExcepcionBaseDatos):
    """Error al ejecutar una consulta."""
    pass

class RegistroNoEncontrado(ExcepcionBaseDatos):
    """Registro no encontrado en la base de datos."""
    pass

class RegistroYaExiste(ExcepcionBaseDatos):
    """Registro ya existe en la base de datos."""
    pass

class ErrorValidacion(ExcepcionBaseDatos):
    """Error de validación de datos."""
    pass

class RegistroTieneDependencias(ExcepcionBaseDatos):
    """No se puede eliminar porque tiene dependencias."""
    def __init__(self, mensaje, cantidad_dependencias=0):
        super().__init__(mensaje)
        self.cantidad_dependencias = cantidad_dependencias