# controllers/login_controller.py
"""
Controlador para la vista de login
"""

from PySide6.QtCore import QObject, Slot, Signal, Property
from backend.services.UsuarioServ.auth_service import auth_service
from backend.core.config import Config


class LoginController(QObject):
    """Controlador para la pantalla de login"""
    
    # Señales para comunicación con QML
    loginExitoso = Signal(dict)  # Emite datos del usuario autenticado
    loginFallido = Signal(str)   # Emite mensaje de error
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._cargando = False
        self._mensaje_error = ""
        self._recordar_usuario = False
        self._ultimo_usuario = ""
    
    # Señales para notificar cambios en propiedades
    cargandoChanged = Signal()
    mensajeErrorChanged = Signal()
    recordarUsuarioChanged = Signal()
    ultimoUsuarioChanged = Signal()
    
    # Propiedad: cargando
    @Property(bool, notify=cargandoChanged)
    def cargando(self):
        """Indica si está en proceso de login"""
        return self._cargando
    
    @cargando.setter
    def cargando(self, value):
        if self._cargando != value:
            self._cargando = value
            self.cargandoChanged.emit()
    
    # Propiedad: mensajeError
    @Property(str, notify=mensajeErrorChanged)
    def mensajeError(self):
        """Mensaje de error a mostrar"""
        return self._mensaje_error
    
    @mensajeError.setter
    def mensajeError(self, value):
        if self._mensaje_error != value:
            self._mensaje_error = value
            self.mensajeErrorChanged.emit()
    
    # Propiedad: recordarUsuario
    @Property(bool, notify=recordarUsuarioChanged)
    def recordarUsuario(self):
        """Checkbox para recordar usuario"""
        return self._recordar_usuario
    
    @recordarUsuario.setter
    def recordarUsuario(self, value):
        if self._recordar_usuario != value:
            self._recordar_usuario = value
            self.recordarUsuarioChanged.emit()
    
    # Propiedad: ultimoUsuario
    @Property(str, notify=ultimoUsuarioChanged)
    def ultimoUsuario(self):
        """Último usuario que inició sesión"""
        return self._ultimo_usuario
    
    @ultimoUsuario.setter
    def ultimoUsuario(self, value):
        if self._ultimo_usuario != value:
            self._ultimo_usuario = value
            self.ultimoUsuarioChanged.emit()
    
    @Slot(str, str)
    def intentarLogin(self, usuario: str, password: str):
        """
        Intenta autenticar al usuario
        
        Args:
            usuario: Nombre de usuario
            password: Contraseña en texto plano
        """
        print(f"\n🔐 Intentando login: {usuario}")
        
        self.cargando = True
        self.mensajeError = ""
        
        try:
            # Validar que los campos no estén vacíos
            if not usuario or not usuario.strip():
                self.mensajeError = "Ingrese su usuario"
                self.loginFallido.emit(self.mensajeError)
                return
            
            if not password or not password.strip():
                self.mensajeError = "Ingrese su contraseña"
                self.loginFallido.emit(self.mensajeError)
                return
            
            # Intentar autenticar con el servicio
            exito, datos_usuario, mensaje = auth_service.login(usuario, password)
            
            if exito:
                # Login exitoso
                print(f"✅ Login exitoso para: {usuario}")
                
                # Guardar último usuario si se marcó recordar
                if self._recordar_usuario:
                    self.ultimoUsuario = usuario
                
                # Emitir señal de éxito con datos del usuario
                self.loginExitoso.emit(datos_usuario)
            else:
                # Login fallido
                self.mensajeError = mensaje
                self.loginFallido.emit(mensaje)
                print(f"❌ Login fallido: {mensaje}")
                
        except Exception as e:
            error_msg = f"Error inesperado: {str(e)}"
            self.mensajeError = error_msg
            self.loginFallido.emit(error_msg)
            print(f"❌ {error_msg}")
            
        finally:
            self.cargando = False
    
    @Slot(result=str)
    def obtenerNombreEmpresa(self):
        """
        Obtiene el nombre de la empresa desde la configuración
        
        Returns:
            str: Nombre de la empresa
        """
        return Config.EMPRESA_NOMBRE
    
    @Slot(result=str)
    def obtenerVersionApp(self):
        """
        Obtiene la versión de la aplicación
        
        Returns:
            str: Versión de la aplicación
        """
        return f"v{Config.APP_VERSION}"
    
    @Slot(result=str)
    def obtenerNombreApp(self):
        """
        Obtiene el nombre de la aplicación
        
        Returns:
            str: Nombre de la aplicación
        """
        return Config.APP_NAME
    
    @Slot()
    def limpiarError(self):
        """Limpia el mensaje de error"""
        self.mensajeError = ""
    
    @Slot(result=bool)
    def esPrimeraVez(self):
        """
        Verifica si es la primera ejecución
        
        Returns:
            bool: True si es primera vez
        """
        return Config.is_first_time()