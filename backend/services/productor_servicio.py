# bd_conecciones/servicios/productor_servicio.py

import logging
from ..repositories.productor_repositorio import ProductorRepositorio
from ..repositories.relacion_repositorio import RelacionRepositorio
from ..core.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste,
    RegistroTieneDependencias
)

logger = logging.getLogger(__name__)

class ProductorServicio:
    """Servicio para lógica de negocio de productores."""
    
    def __init__(self):
        self.productor_repo =  ProductorRepositorio()
        self.relacion_repo = RelacionRepositorio()
    
    def obtener_productores_paginado(self, pagina, por_pagina = 8):
        """
        Obtiene productores con paginación y lógica de negocio aplicada.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Resultado con productores y metadatos.
        """
        try:
            resultado = self.productor_repo.obtener_paginado(pagina, por_pagina)
            
            # Enriquecer datos con información adicional
            for agricultor in resultado['productores']:
                agricultor['puede_eliminar'] = self._puede_eliminar_agricultor(agricultor['id_productor'])
                agricultor['cantidad_parcelas'] = self.relacion_repo.contar_parcelas_por_productor(agricultor['id_productor'])
            
            logger.info(f"Servicio: página {pagina} procesada con {len(resultado['productores'])} productores")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_productores_paginado: {str(e)}")
            raise
    
    def crear_agricultor(self, datos_agricultor):
        """
        Crea un nuevo agricultor con validaciones de negocio.
        
        Args:
            datos_agricultor (dict): Datos del agricultor.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio adicionales
            self._validar_reglas_negocio_creacion(datos_agricultor)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_agricultor(datos_agricultor)
            
            # Crear agricultor
            exito, id_productor = self.productor_repo.crear(datos_normalizados)
            
            if exito:
                resultado = {
                    'exito': True,
                    'id_productor': id_productor,
                    'mensaje': f"Agricultor creado exitosamente con ID {id_productor}"
                }
                
                logger.info(f"Servicio: agricultor creado con ID {id_productor}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear agricultor'}
                
        except (ErrorValidacion, RegistroYaExiste) as e:
            logger.error(f"Error de validación en crear_agricultor: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_agricultor: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
    
    def actualizar_agricultor(self, id_productor, datos_agricultor):
        """
        Actualiza un agricultor con validaciones de negocio.
        
        Args:
            id_productor (int): ID del agricultor.
            datos_agricultor (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales para comparación
            agricultor_actual = self.productor_repo.obtener_por_id(id_productor)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_agricultor(datos_agricultor)
            
            # Actualizar agricultor
            exito = self.productor_repo.actualizar(id_productor, datos_normalizados)
            
            if exito:
                # Verificar si cambió el estado de propietario
                cambio_propietario = self._verificar_cambio_propietario(agricultor_actual, datos_normalizados)
                
                resultado = {
                    'exito': True,
                    'mensaje': 'Agricultor actualizado exitosamente',
                    'cambio_propietario': cambio_propietario,
                    'requiere_actualizacion_propietarios': cambio_propietario
                }
                
                logger.info(f"Servicio: agricultor {id_productor} actualizado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar agricultor'}
                
        except (ErrorValidacion, RegistroNoEncontrado, RegistroYaExiste) as e:
            logger.error(f"Error en actualizar_agricultor: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_agricultor: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
    
    def eliminar_agricultor(self, id_productor):
        """
        Elimina un agricultor verificando dependencias y reglas de negocio.
        
        Args:
            id_productor (int): ID del agricultor.
            
        Returns:
            dict: Resultado detallado de la operación.
        """
        try:
            # Obtener información del agricultor
            agricultor = self.productor_repo.obtener_por_id(id_productor)
            
            # Verificar dependencias usando RelacionRepositorio
            dependencias = self.relacion_repo.verificar_dependencias_agricultor(id_productor)
            
            # Si tiene dependencias, no se puede eliminar
            if not dependencias['puede_eliminar']:
                return {
                    'exito': False,
                    'mensaje': f"No se puede eliminar a {agricultor['nombre']} {agricultor['apellido']}",
                    'razon': 'Tiene parcelas asociadas',
                    'dependencias': dependencias,
                    'tipo_error': 'dependencias'
                }
            
            # Proceder con eliminación
            exito = self.productor_repo.desactivar(id_productor)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Agricultor {agricultor['nombre']} {agricultor['apellido']} eliminado exitosamente",
                    'era_propietario': agricultor['esPropietario'],
                    'requiere_actualizacion_propietarios': agricultor['esPropietario']
                }
                
                logger.info(f"Servicio: agricultor {id_productor} eliminado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al eliminar agricultor'}
                
        except RegistroTieneDependencias as e:
            logger.error(f"No se puede eliminar agricultor: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'razon': 'Tiene dependencias',
                'dependencias': {'parcelas': e.cantidad_dependencias},
                'tipo_error': 'dependencias'
            }
        except RegistroNoEncontrado as e:
            logger.error(f"Agricultor no encontrado: {str(e)}")
            return {'exito': False, 'mensaje': str(e), 'tipo_error': 'no_encontrado'}
        except Exception as e:
            logger.error(f"Error en servicio eliminar_agricultor: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema', 'tipo_error': 'interno'}
    
    def buscar_productores(self, texto_busqueda):
        """
        Busca productores con lógica de negocio aplicada.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de productores encontrados con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return []
            
            productores = self.productor_repo.buscar_por_nombre(texto_busqueda.strip())
            
            # Enriquecer resultados
            for productor in productores:
                productor['puede_eliminar'] = self._puede_eliminar_agricultor(productor['id_productor'])
                productor['cantidad_parcelas'] = self.relacion_repo.contar_parcelas_por_productor(productor['id_productor'])
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(productores)} resultados")
            return productores
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_productores: {str(e)}")
            return []
    
    def verificar_estado_agricultor(self, id_productor):
        """
        Verifica el estado completo de un agricultor.
        
        Args:
            id_productor(int): ID del agricultor.
            
        Returns:
            dict: Estado completo del agricultor.
        """
        try:
            agricultor = self.productor_repo.obtener_por_id(id_productor)
            cantidad_parcelas = self.relacion_repo.contar_parcelas_por_productor(id_productor)
            
            estado = {
                'agricultor': agricultor,
                'cantidad_parcelas': cantidad_parcelas,
                'puede_eliminar': cantidad_parcelas == 0
            }
            
            return estado
            
        except RegistroNoEncontrado as e:
            logger.error(f"Agricultor no encontrado: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Error en servicio verificar_estado_agricultor: {str(e)}")
            return None
    
    def _puede_eliminar_agricultor(self, id_productor):
        """Verifica si un agricultor puede ser eliminado."""
        try:
            cantidad_parcelas = self.relacion_repo.contar_parcelas_por_productor(id_productor)
            return cantidad_parcelas == 0
        except Exception:
            return False
    
    def _validar_reglas_negocio_creacion(self, datos):
        """Valida reglas de negocio específicas para creación."""
        # Regla: Los propietarios deben tener correo electrónico
        if datos.get('esPropietario', False) and not datos.get('correo'):
            raise ErrorValidacion("Los propietarios deben tener correo electrónico registrado")
        
        # Regla: Los propietarios deben tener teléfono
        if datos.get('esPropietario', False) and not datos.get('telefono'):
            raise ErrorValidacion("Los propietarios deben tener teléfono registrado")
    
    def _normalizar_datos_agricultor(self, datos):
        """Normaliza y limpia los datos del agricultor."""
        datos_normalizados = datos.copy()
        
        # Limpiar espacios en strings
        for campo in ['nombre', 'apellido', 'identificacion', 'telefono', 'correo', 'direccion']:
            if campo in datos_normalizados and datos_normalizados[campo]:
                datos_normalizados[campo] = datos_normalizados[campo].strip()
        
        # Normalizar correo a minúsculas
        if datos_normalizados.get('correo'):
            datos_normalizados['correo'] = datos_normalizados['correo'].lower()
        
        # Asegurar tipo booleano para esPropietario
        if 'esPropietario' in datos_normalizados:
            datos_normalizados['esPropietario'] = bool(datos_normalizados['esPropietario'])
        
        return datos_normalizados
    