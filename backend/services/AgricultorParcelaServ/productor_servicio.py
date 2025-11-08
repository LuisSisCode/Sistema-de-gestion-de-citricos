# bd_conecciones/servicios/productor_servicio.py

import logging
from ...repositories.Productor_Parcelas_rep.productor_repositorio import ProductorRepositorio
from ...repositories.Productor_Parcelas_rep.relacion_AgriPar_repositorio import RelacionRepositorio
from ...core.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste,
    RegistroTieneDependencias
)
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class ProductorServicio:
    """Servicio para lógica de negocio de productores con caché optimizado."""
    
    def __init__(self):
        self.productor_repo = ProductorRepositorio()
        self.relacion_repo = RelacionRepositorio()
    
    @cacheable('servicio_productores', key_func=lambda pagina, por_pagina=8: f"paginado_{pagina}_{por_pagina}", ttl=900)  # 15 min
    def obtener_productores_paginado(self, pagina, por_pagina=8):
        """
        Obtiene productores con paginación y lógica de negocio aplicada.
        ⭐ MUY OPTIMIZADO: Elimina el problema de N+1 queries cacheando el resultado completo enriquecido
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Resultado con productores y metadatos.
        """
        try:
            resultado = self.productor_repo.obtener_paginado(pagina, por_pagina)
            
            # Enriquecer datos con información adicional (OPTIMIZADO: resultado completo cacheado)
            productores_enriquecidos = []
            for agricultor in resultado['productores']:
                agricultor_enriquecido = agricultor.copy()
                
                # Obtener datos adicionales (estos métodos ya están cacheados en repositorios)
                agricultor_enriquecido['cantidad_parcelas'] = self.relacion_repo.contar_parcelas_por_productor(agricultor['id_productor'])
                agricultor_enriquecido['puede_eliminar'] = self._puede_eliminar_agricultor_cached(agricultor['id_productor'])
                
                # Agregar metadatos de negocio
                agricultor_enriquecido['tiene_parcelas'] = agricultor_enriquecido['cantidad_parcelas'] > 0
                
                productores_enriquecidos.append(agricultor_enriquecido)
            
            # Actualizar resultado con datos enriquecidos
            resultado['productores'] = productores_enriquecidos
            
            logger.info(f"Servicio: página {pagina} procesada con {len(resultado['productores'])} productores")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_productores_paginado: {str(e)}")
            raise

    @cache_invalidator('servicio_productores', pattern='paginado_')  # Invalidar paginación
    @cache_invalidator('servicio_productores', pattern='busqueda_') # Invalidar búsquedas
    @cache_invalidator('validaciones')                               # Invalidar validaciones
    def crear_agricultor(self, datos_agricultor):
        """
        Crea un nuevo agricultor con validaciones de negocio.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
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
                    'mensaje': f"Agricultor creado exitosamente con ID {id_productor}",
                    'requiere_actualizacion_listas': True
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

    @cache_invalidator('servicio_productores', pattern='paginado_')  # Invalidar paginación
    @cache_invalidator('servicio_productores', pattern='busqueda_') # Invalidar búsquedas
    @cache_invalidator('validaciones')                               # Invalidar validaciones
    @cache_invalidator('estados_agricultor')                         # Invalidar estados
    def actualizar_agricultor(self, id_productor, datos_agricultor):
        """
        Actualiza un agricultor con validaciones de negocio.
        OPTIMIZADO: Invalidación específica del agricultor actualizado.
        
        Args:
            id_productor (int): ID del agricultor.
            datos_agricultor (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales para comparación
            agricultor_actual = self.productor_repo.obtener_por_id(id_productor)
            
            # Validar cambios críticos
            self._validar_cambios_criticos(agricultor_actual, datos_agricultor)
            
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
                    'requiere_actualizacion_propietarios': cambio_propietario,
                    'requiere_actualizacion_listas': True
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

    @cache_invalidator('servicio_productores', pattern='paginado_')  # Invalidar paginación
    @cache_invalidator('servicio_productores', pattern='busqueda_') # Invalidar búsquedas
    @cache_invalidator('validaciones')                               # Invalidar validaciones
    @cache_invalidator('estados_agricultor')                         # Invalidar estados
    def eliminar_agricultor(self, id_productor):
        """
        Elimina un agricultor verificando dependencias y reglas de negocio.
        OPTIMIZADO: Invalidación completa ya que afecta listas y estadísticas.
        
        Args:
            id_productor (int): ID del agricultor.
            
        Returns:
            dict: Resultado detallado de la operación.
        """
        try:
            # Obtener información del agricultor
            agricultor = self.productor_repo.obtener_por_id(id_productor)
            
            # Verificar dependencias usando RelacionRepositorio (ya cacheado)
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
                    'requiere_actualizacion_propietarios': agricultor['esPropietario'],
                    'requiere_actualizacion_listas': True
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

    @cacheable('servicio_productores', key_func=lambda texto: f"busqueda_{texto.lower().replace(' ', '_')}", ttl=600)  # 10 min
    def buscar_productores(self, texto_busqueda):
        """
        Busca productores con lógica de negocio aplicada.
        ⭐ OPTIMIZADO: Resultado enriquecido completo cacheado para evitar N+1 queries
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de productores encontrados con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return []
            
            productores = self.productor_repo.buscar_por_nombre(texto_busqueda.strip())
            
            # Enriquecer resultados (OPTIMIZADO: resultado completo cacheado)
            productores_enriquecidos = []
            for agricultor in productores:
                agricultor_enriquecido = agricultor.copy()
                
                # Agregar información adicional (métodos ya cacheados en repositorios)
                agricultor_enriquecido['cantidad_parcelas'] = self.relacion_repo.contar_parcelas_por_productor(agricultor['id_productor'])
                agricultor_enriquecido['puede_eliminar'] = self._puede_eliminar_agricultor_cached(agricultor['id_productor'])
                
                # Metadatos de negocio
                agricultor_enriquecido['tiene_parcelas'] = agricultor_enriquecido['cantidad_parcelas'] > 0
                
                productores_enriquecidos.append(agricultor_enriquecido)
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(productores_enriquecidos)} resultados")
            return productores_enriquecidos
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_productores: {str(e)}")
            return []

    @cacheable('estados_agricultor', key_func=lambda id_agr: f"estado_completo_{id_agr}", ttl=1200)  # 20 min
    def verificar_estado_agricultor(self, id_productor):
        """
        Verifica el estado completo de un agricultor.
        ⭐ OPTIMIZADO: Estado completo cacheado para evitar múltiples consultas
        
        Args:
            id_productor (int): ID del agricultor.
            
        Returns:
            dict: Estado completo del agricultor.
        """
        try:
            # Estos métodos ya están cacheados en repositorios
            agricultor = self.productor_repo.obtener_por_id(id_productor)
            cantidad_parcelas = self.relacion_repo.contar_parcelas_por_productor(id_productor)
            
            estado = {
                'agricultor': agricultor,
                'cantidad_parcelas': cantidad_parcelas,
                'puede_eliminar': cantidad_parcelas == 0,
                'tiene_parcelas': cantidad_parcelas > 0,
                'timestamp_verificacion': self._get_timestamp(),
                
                # Información adicional de negocio
                'categoria': self._categorizar_agricultor(agricultor, cantidad_parcelas),
                'requiere_atencion': self._requiere_atencion_agricultor(agricultor, cantidad_parcelas)
            }
            
            return estado
            
        except RegistroNoEncontrado as e:
            logger.error(f"Agricultor no encontrado: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Error en servicio verificar_estado_agricultor: {str(e)}")
            return None

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('validaciones', key_func=lambda id_agr: f"puede_eliminar_{id_agr}", ttl=900)  # 15 min
    def _puede_eliminar_agricultor_cached(self, id_productor):
        """
        Verifica si un agricultor puede ser eliminado (versión cacheada).
        ⭐ OPTIMIZADO: Evita consultar repetidamente la misma validación
        
        Args:
            id_productor (int): ID del agricultor.
            
        Returns:
            bool: True si puede eliminarse.
        """
        try:
            cantidad_parcelas = self.relacion_repo.contar_parcelas_por_productor(id_productor)
            return cantidad_parcelas == 0
        except Exception:
            return False

    @cacheable('validaciones', key_func=lambda datos: f"reglas_negocio_{hash(str(sorted(datos.items())))}", ttl=3600)  # 1 hora
    def _validar_reglas_negocio_creacion_cached(self, datos):
        """
        Valida reglas de negocio específicas para creación (versión cacheada).
        
        Args:
            datos (dict): Datos a validar.
            
        Returns:
            bool: True si pasa todas las validaciones.
            
        Raises:
            ErrorValidacion: Si alguna regla falla.
        """
        # Regla: Los propietarios deben tener correo electrónico
        if datos.get('esPropietario', False) and not datos.get('correo'):
            raise ErrorValidacion("Los propietarios deben tener correo electrónico registrado")
        
        # Regla: Los propietarios deben tener teléfono
        if datos.get('esPropietario', False) and not datos.get('telefono'):
            raise ErrorValidacion("Los propietarios deben tener teléfono registrado")
        
        return True

    @cacheable('metricas_servicio', key_func=lambda: 'resumen_productores', ttl=1800)  # 30 min
    def obtener_resumen_productores(self):
        """
        Obtiene un resumen completo de productores para dashboard.
        ⭐ NUEVO: Método optimizado para dashboard
        
        Returns:
            dict: Resumen completo de productores.
        """
        try:
            # Obtener estadísticas básicas (ya cacheadas)
            estadisticas = self.relacion_repo.obtener_estadisticas_generales()
            
            # Calcular métricas adicionales
            total_productores = estadisticas['productores']['total']
            total_trabajadores = total_productores
            
            resumen = {
                'totales': {
                    'productores': total_productores,
                    'trabajadores': total_trabajadores
                },
                'estadisticas': estadisticas,
                'timestamp': self._get_timestamp(),
                
            }
            
            logger.info(f"Resumen de productores generado: {total_productores} total")
            return resumen
            
        except Exception as e:
            logger.error(f"Error generando resumen de productores: {str(e)}")
            return {}

    # ==================== MÉTODOS AUXILIARES PRIVADOS ====================
    
    def _validar_reglas_negocio_creacion(self, datos):
        """Valida reglas de negocio específicas para creación."""
        return self._validar_reglas_negocio_creacion_cached(datos)
    
    def _validar_cambios_criticos(self, agricultor_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Si está cambiando de propietario a no propietario, verificar que no tenga parcelas
        if (agricultor_actual['esPropietario'] and 
            'esPropietario' in datos_nuevos and 
            not datos_nuevos['esPropietario']):
            
            cantidad_parcelas = self.relacion_repo.contar_parcelas_por_productor(agricultor_actual['id_productor'])
            if cantidad_parcelas > 0:
                raise ErrorValidacion(f"No se puede quitar el estado de propietario. Tiene {cantidad_parcelas} parcelas asociadas")
    
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
    
    def _verificar_cambio_propietario(self, agricultor_actual, datos_nuevos):
        """Verifica si cambió el estado de propietario."""
        return (agricultor_actual['esPropietario'] != datos_nuevos.get('esPropietario', agricultor_actual['esPropietario']))
    
    def _categorizar_agricultor(self, agricultor, cantidad_parcelas):
        """Categoriza un agricultor según su perfil."""
        if agricultor['esPropietario']:
            if cantidad_parcelas >= 5:
                return 'gran_propietario'
            elif cantidad_parcelas >= 2:
                return 'propietario_medio'
            else:
                return 'pequeño_propietario'
        else:
            return 'trabajador'
    
    def _requiere_atencion_agricultor(self, agricultor, cantidad_parcelas):
        """Determina si un agricultor requiere atención especial."""
        # Propietarios sin parcelas
        if agricultor['esPropietario'] and cantidad_parcelas == 0:
            return True
        
        # Agricultores sin contacto completo
        if agricultor['esPropietario'] and (not agricultor.get('telefono') or not agricultor.get('correo')):
            return True
        
        return False
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()