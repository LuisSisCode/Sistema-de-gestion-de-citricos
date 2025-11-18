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
            for productor in resultado['productores']:
                productor_enriquecido = productor.copy()
                
                # Obtener datos adicionales (estos métodos ya están cacheados en repositorios)
                productor_enriquecido['cantidad_parcelas'] = self.relacion_repo.contar_parcelas_por_productor(productor['id_productor'])
                productor_enriquecido['puede_eliminar'] = self._puede_eliminar_productorcached(productor['id_productor'])
                
                # Agregar metadatos de negocio
                productor_enriquecido['tiene_parcelas'] = productor_enriquecido['cantidad_parcelas'] > 0
                
                productores_enriquecidos.append(productor_enriquecido)
            
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
    def crear_productor(self, datos_productor):
        """
        Crea un nuevo productor con validaciones de negocio.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_productor (dict): Datos del productor.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio adicionales
            self._validar_reglas_negocio_creacion(datos_productor)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_productor(datos_productor)
            
            # Crear productor
            exito, id_productor = self.productor_repo.crear(datos_normalizados)
            
            if exito:
                resultado = {
                    'exito': True,
                    'id_productor': id_productor,
                    'mensaje': f"Agricultor creado exitosamente con ID {id_productor}",
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: productor creado con ID {id_productor}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear productor'}
                
        except (ErrorValidacion, RegistroYaExiste) as e:
            logger.error(f"Error de validación en crear_productor: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_productor: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_productores', pattern='paginado_')  # Invalidar paginación
    @cache_invalidator('servicio_productores', pattern='busqueda_') # Invalidar búsquedas
    @cache_invalidator('validaciones')                               # Invalidar validaciones
    @cache_invalidator('estados_productor')                         # Invalidar estados
    def actualizar_productor(self, id_productor, datos_productor):
        """
        Actualiza un productor con validaciones de negocio.
        OPTIMIZADO: Invalidación específica del productor actualizado.
        
        Args:
            id_productor (int): ID del productor.
            datos_productor (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales para comparación
            productor_actual = self.productor_repo.obtener_por_id(id_productor)
            
            # Validar cambios críticos
            self._validar_cambios_criticos(productor_actual, datos_productor)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_productor(datos_productor)
            
            # Actualizar productor
            exito = self.productor_repo.actualizar(id_productor, datos_normalizados)
            
            if exito:
                # Verificar si cambió el estado de propietario
                cambio_propietario = self._verificar_cambio_propietario(productor_actual, datos_normalizados)
                
                resultado = {
                    'exito': True,
                    'mensaje': 'Agricultor actualizado exitosamente',
                    'cambio_propietario': cambio_propietario,
                    'requiere_actualizacion_propietarios': cambio_propietario,
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: productor {id_productor} actualizado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar productor'}
                
        except (ErrorValidacion, RegistroNoEncontrado, RegistroYaExiste) as e:
            logger.error(f"Error en actualizar_productor: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_productor: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_productores', pattern='paginado_')  # Invalidar paginación
    @cache_invalidator('servicio_productores', pattern='busqueda_') # Invalidar búsquedas
    @cache_invalidator('validaciones')                               # Invalidar validaciones
    @cache_invalidator('estados_productor')                         # Invalidar estados
    def eliminar_productor(self, id_productor):
        """
        Elimina un productor verificando dependencias y reglas de negocio.
        OPTIMIZADO: Invalidación completa ya que afecta listas y estadísticas.
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            dict: Resultado detallado de la operación.
        """
        try:
            # Obtener información del productor
            productor = self.productor_repo.obtener_por_id(id_productor)
            
            # Verificar dependencias usando RelacionRepositorio (ya cacheado)
            dependencias = self.relacion_repo.verificar_dependencias_productor(id_productor)
            
            # Si tiene dependencias, no se puede eliminar
            if not dependencias['puede_eliminar']:
                return {
                    'exito': False,
                    'mensaje': f"No se puede eliminar a {productor['nombre']} {productor['apellido']}",
                    'razon': 'Tiene parcelas asociadas',
                    'dependencias': dependencias,
                    'tipo_error': 'dependencias'
                }
            
            # Proceder con eliminación
            exito = self.productor_repo.desactivar(id_productor)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Agricultor {productor['nombre']} {productor['apellido']} eliminado exitosamente",
                    'era_propietario': productor['esPropietario'],
                    'requiere_actualizacion_propietarios': productor['esPropietario'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: productor {id_productor} eliminado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al eliminar productor'}
                
        except RegistroTieneDependencias as e:
            logger.error(f"No se puede eliminar productor: {str(e)}")
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
            logger.error(f"Error en servicio eliminar_productor: {str(e)}")
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
            for productor in productores:
                productor_enriquecido = productor.copy()
                
                # Agregar información adicional (métodos ya cacheados en repositorios)
                productor_enriquecido['cantidad_parcelas'] = self.relacion_repo.contar_parcelas_por_productor(productor['id_productor'])
                productor_enriquecido['puede_eliminar'] = self._puede_eliminar_productor_cached(productor['id_productor'])
                
                # Metadatos de negocio
                productor_enriquecido['tiene_parcelas'] = productor_enriquecido['cantidad_parcelas'] > 0
                
                productores_enriquecidos.append(productor_enriquecido)
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(productores_enriquecidos)} resultados")
            return productores_enriquecidos
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_productores: {str(e)}")
            return []

    @cacheable('estados_productor', key_func=lambda id_agr: f"estado_completo_{id_agr}", ttl=1200)  # 20 min
    def verificar_estado_productor(self, id_productor):
        """
        Verifica el estado completo de un productor.
        ⭐ OPTIMIZADO: Estado completo cacheado para evitar múltiples consultas
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            dict: Estado completo del productor.
        """
        try:
            # Estos métodos ya están cacheados en repositorios
            productor = self.productor_repo.obtener_por_id(id_productor)
            cantidad_parcelas = self.relacion_repo.contar_parcelas_por_productor(id_productor)
            
            estado = {
                'productor': productor,
                'cantidad_parcelas': cantidad_parcelas,
                'puede_eliminar': cantidad_parcelas == 0,
                'tiene_parcelas': cantidad_parcelas > 0,
                'timestamp_verificacion': self._get_timestamp(),
                
                # Información adicional de negocio
                'categoria': self._categorizar_productor(productor, cantidad_parcelas),
                'requiere_atencion': self._requiere_atencion_productor(productor, cantidad_parcelas)
            }
            
            return estado
            
        except RegistroNoEncontrado as e:
            logger.error(f"Agricultor no encontrado: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Error en servicio verificar_estado_productor: {str(e)}")
            return None

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('validaciones', key_func=lambda id_agr: f"puede_eliminar_{id_agr}", ttl=900)  # 15 min
    def _puede_eliminar_productor_cached(self, id_productor):
        """
        Verifica si un productor puede ser eliminado (versión cacheada).
        ⭐ OPTIMIZADO: Evita consultar repetidamente la misma validación
        
        Args:
            id_productor (int): ID del productor.
            
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
    
    def _validar_cambios_criticos(self, productor_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Si está cambiando de propietario a no propietario, verificar que no tenga parcelas
        if (productor_actual['esPropietario'] and 
            'esPropietario' in datos_nuevos and 
            not datos_nuevos['esPropietario']):
            
            cantidad_parcelas = self.relacion_repo.contar_parcelas_por_productor(productor_actual['id_productor'])
            if cantidad_parcelas > 0:
                raise ErrorValidacion(f"No se puede quitar el estado de propietario. Tiene {cantidad_parcelas} parcelas asociadas")
    
    def _normalizar_datos_productor(self, datos):
        """Normaliza y limpia los datos del productor."""
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
    
    def _verificar_cambio_propietario(self, productor_actual, datos_nuevos):
        """Verifica si cambió el estado de propietario."""
        return (productor_actual['esPropietario'] != datos_nuevos.get('esPropietario', productor_actual['esPropietario']))
    
    def _categorizar_productor(self, productor, cantidad_parcelas):
        """Categoriza un productor según su perfil."""
        if productor['esPropietario']:
            if cantidad_parcelas >= 5:
                return 'gran_propietario'
            elif cantidad_parcelas >= 2:
                return 'propietario_medio'
            else:
                return 'pequeño_propietario'
        else:
            return 'trabajador'
    
    def _requiere_atencion_productor(self, productor, cantidad_parcelas):
        """Determina si un productor requiere atención especial."""
        # Propietarios sin parcelas
        if productor['esPropietario'] and cantidad_parcelas == 0:
            return True
        
        # Agricultores sin contacto completo
        if productor['esPropietario'] and (not productor.get('telefono') or not productor.get('correo')):
            return True
        
        return False
    
    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()