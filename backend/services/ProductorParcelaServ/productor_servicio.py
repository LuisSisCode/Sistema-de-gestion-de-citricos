# bd_conecciones/servicios/productor_servicio.py

import logging
from ...repositories.Productor_Parcelas_rep.productor_repositorio import ProductorRepositorio
from ...repositories.Productor_Parcelas_rep.parcela_repositorio import ParcelaRepositorio
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
        self.parcela_repo = ParcelaRepositorio()
    
    @cacheable('servicio_productores', key_func=lambda pagina, por_pagina=8: f"paginado_{pagina}_{por_pagina}", ttl=900)
    def obtener_productores_paginado(self, pagina, por_pagina=5):
        """
        Obtiene productores con paginación (activos e inactivos).
        """
        try:
            resultado = self.productor_repo.obtener_paginado(pagina, por_pagina)
            
            # Enriquecer datos con información adicional
            productores_enriquecidos = []
            for productor in resultado['productores']:
                productor_enriquecido = productor.copy()
                
                # Obtener datos adicionales
                productor_enriquecido['cantidad_parcelas'] = self.productor_repo.contar_parcelas_por_productor(productor['id_productor'])
                productor_enriquecido['puede_eliminar'] = self._puede_eliminar_productor_cached(productor['id_productor'])
                
                # Agregar metadatos de negocio
                productor_enriquecido['tiene_parcelas'] = productor_enriquecido['cantidad_parcelas'] > 0
                productor_enriquecido['categoria'] = self._categorizar_productor(productor_enriquecido)
                
                productores_enriquecidos.append(productor_enriquecido)
            
            resultado['productores'] = productores_enriquecidos
            resultado['metadatos'] = {
                'timestamp': self._get_timestamp(),
                'total_con_parcelas': sum(1 for p in productores_enriquecidos if p['tiene_parcelas']),
                'total_activos': sum(1 for p in productores_enriquecidos if p.get('activo', True)),
                'total_inactivos': sum(1 for p in productores_enriquecidos if not p.get('activo', True))
            }
            
            logger.info(f"Servicio: página {pagina} procesada con {len(resultado['productores'])} productores (activos e inactivos)")
            return {
                'exito': True,
                'mensaje': f'Página {pagina} de productores obtenida',
                'datos': resultado,
                'metadatos': resultado['metadatos']
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_productores_paginado: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener productores',
                'datos': None
            }

    @cache_invalidator('servicio_productores', pattern='paginado_')
    @cache_invalidator('servicio_productores', pattern='busqueda_')
    @cache_invalidator('estadisticas_productores')
    @cache_invalidator('reportes_productores')
    def crear_productor(self, datos_productor):
        """
        Crea un nuevo productor con validaciones de negocio.
        """
        try:
            print(f"🎯 CREAR_PRODUCTOR - Datos recibidos: {datos_productor}")
            
            # Validaciones de negocio
            self._validar_reglas_negocio_creacion(datos_productor)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_productor(datos_productor)
            print(f"📦 CREAR_PRODUCTOR - Datos normalizados: {datos_normalizados}")
            
            # Crear productor
            exito, id_productor = self.productor_repo.crear(datos_normalizados)
            print(f"✅ CREAR_PRODUCTOR - Resultado repositorio: éxito={exito}, id={id_productor}")
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Productor creado exitosamente con ID {id_productor}",
                    'datos': {
                        'id_productor': id_productor,
                        'productor': datos_normalizados
                    },
                    'metadatos': {
                        'timestamp': self._get_timestamp(),
                        'requiere_actualizacion_listas': True
                    }
                }
                
                logger.info(f"Servicio: productor creado con ID {id_productor}")
                return resultado
            else:
                print("❌ CREAR_PRODUCTOR - Error en repositorio")
                return {
                    'exito': False,
                    'mensaje': 'Error al crear productor en la base de datos',
                    'datos': None
                }
                
        except (ErrorValidacion, RegistroYaExiste) as e:
            logger.error(f"Error de validación en crear_productor: {str(e)}")
            print(f"❌ CREAR_PRODUCTOR - Error validación: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except Exception as e:
            logger.error(f"Error en servicio crear_productor: {str(e)}")
            print(f"❌ CREAR_PRODUCTOR - Error general: {str(e)}")
            import traceback
            traceback.print_exc()
            return {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'datos': None
            }

    @cache_invalidator('servicio_productores', pattern='paginado_')
    @cache_invalidator('servicio_productores', pattern='busqueda_')
    @cache_invalidator('servicio_productores', pattern='id_')
    @cache_invalidator('estadisticas_productores')
    @cache_invalidator('reportes_productores')
    def actualizar_productor(self, id_productor, datos_productor):
        """
        Actualiza un productor con validaciones de negocio.
        """
        try:
            print(f"🎯 ACTUALIZAR_PRODUCTOR - ID: {id_productor}, Datos: {datos_productor}")
            
            # Obtener datos actuales para comparación
            productor_actual = self.productor_repo.obtener_por_id(id_productor)
            print(f"📋 ACTUALIZAR_PRODUCTOR - Datos actuales: {productor_actual}")
            
            # Validar cambios críticos
            self._validar_cambios_criticos(productor_actual, datos_productor)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_productor(datos_productor)
            print(f"📦 ACTUALIZAR_PRODUCTOR - Datos normalizados: {datos_normalizados}")
            
            # Actualizar productor
            exito = self.productor_repo.actualizar(id_productor, datos_normalizados)
            print(f"✅ ACTUALIZAR_PRODUCTOR - Resultado repositorio: éxito={exito}")
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': 'Productor actualizado exitosamente',
                    'datos': {
                        'id_productor': id_productor,
                        'cambios': datos_normalizados
                    },
                    'metadatos': {
                        'timestamp': self._get_timestamp(),
                        'requiere_actualizacion_listas': True
                    }
                }
                
                logger.info(f"Servicio: productor {id_productor} actualizado")
                return resultado
            else:
                print("❌ ACTUALIZAR_PRODUCTOR - Error en repositorio")
                return {
                    'exito': False,
                    'mensaje': 'Error al actualizar productor en la base de datos',
                    'datos': None
                }
                
        except (ErrorValidacion, RegistroNoEncontrado, RegistroYaExiste) as e:
            logger.error(f"Error en actualizar_productor: {str(e)}")
            print(f"❌ ACTUALIZAR_PRODUCTOR - Error específico: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except Exception as e:
            logger.error(f"Error en servicio actualizar_productor: {str(e)}")
            print(f"❌ ACTUALIZAR_PRODUCTOR - Error general: {str(e)}")
            import traceback
            traceback.print_exc()
            return {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'datos': None
            }

    @cache_invalidator('servicio_productores', pattern='paginado_')
    @cache_invalidator('servicio_productores', pattern='busqueda_')
    @cache_invalidator('servicio_productores', pattern='id_')
    @cache_invalidator('estadisticas_productores')
    @cache_invalidator('reportes_productores')
    def eliminar_productor(self, id_productor, eliminar_fisicamente=False):
        """
        Elimina un productor verificando dependencias.
        
        Args:
            id_productor (int): ID del productor.
            eliminar_fisicamente (bool): True para eliminación física (ADMIN ONLY).
                                        False para eliminación lógica (por defecto).
        
        Returns:
            dict: Resultado detallado de la operación.
        """
        try:
            # Obtener información del productor
            productor = self.productor_repo.obtener_por_id(id_productor)
            
            # Verificar dependencias
            dependencias = self.productor_repo.verificar_dependencias_productor(id_productor)
            
            resultado = {
                'exito': False,
                'mensaje': '',
                'datos': {
                    'productor': productor,
                    'dependencias': dependencias,
                    'eliminacion_fisica': eliminar_fisicamente
                }
            }
            
            # Lógica de eliminación basada en el tipo
            if eliminar_fisicamente:
                # ELIMINACIÓN FÍSICA (ADMIN)
                if not dependencias['puede_eliminar']:
                    resultado['mensaje'] = (
                        f"❌ NO SE PUEDE ELIMINAR FÍSICAMENTE: "
                        f"El productor {productor['nombre']} {productor['apellido']} "
                        f"tiene {dependencias['parcelas']} parcelas activas. "
                        f"Debe eliminar o transferir las parcelas primero."
                    )
                    resultado['datos']['tipo_error'] = 'dependencias_activas'
                    return resultado
                
                # Proceder con eliminación física
                exito = self.productor_repo.eliminar_fisico(id_productor)
                
                if exito:
                    resultado['exito'] = True
                    resultado['mensaje'] = (
                        f"⚠️ ELIMINACIÓN FÍSICA COMPLETADA: "
                        f"Productor {productor['nombre']} {productor['apellido']} "
                        f"eliminado permanentemente de la base de datos."
                    )
                    resultado['datos']['advertencia'] = 'Esta acción no se puede deshacer'
                else:
                    resultado['mensaje'] = 'Error al eliminar físicamente el productor'
                    resultado['datos']['tipo_error'] = 'error_ejecucion'
                    
            else:
                # ELIMINACIÓN LÓGICA (desactivación)
                exito = self.productor_repo.desactivar(id_productor)
                
                if exito:
                    resultado['exito'] = True
                    resultado['mensaje'] = (
                        f"✅ PRODUCTOR DESACTIVADO: "
                        f"{productor['nombre']} {productor['apellido']} "
                        f"ha sido marcado como inactivo."
                    )
                    resultado['datos']['estado_actual'] = 'inactivo'
                else:
                    resultado['mensaje'] = 'Error al desactivar el productor'
                    resultado['datos']['tipo_error'] = 'error_ejecucion'
            
            # Agregar metadatos
            resultado['metadatos'] = {
                'timestamp': self._get_timestamp(),
                'requiere_actualizacion_listas': resultado['exito'],
                'tipo_operacion': 'eliminacion_fisica' if eliminar_fisicamente else 'desactivacion_logica'
            }
            
            if resultado['exito']:
                logger.info(f"Servicio: productor {id_productor} procesado - {resultado['mensaje']}")
            else:
                logger.warning(f"Servicio: falló eliminación productor {id_productor} - {resultado['mensaje']}")
            
            return resultado
            
        except (RegistroNoEncontrado, ErrorValidacion) as e:
            logger.error(f"Error de validación en eliminar_productor: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': {
                    'tipo_error': 'validacion',
                    'detalles': str(e)
                }
            }
        except Exception as e:
            logger.error(f"Error en servicio eliminar_productor: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'datos': {
                    'tipo_error': 'interno',
                    'detalles': str(e)
                }
            }

    @cacheable('servicio_productores', key_func=lambda texto: f"busqueda_{texto.lower().replace(' ', '_')}", ttl=600)
    def buscar_productores(self, texto_busqueda):
        """
        Busca productores con lógica de negocio aplicada.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            dict: Lista de productores encontrados con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return {
                    'exito': True,
                    'mensaje': 'Texto de búsqueda muy corto',
                    'datos': [],
                    'metadatos': {'total_resultados': 0}
                }
            
            productores = self.productor_repo.buscar_por_nombre(texto_busqueda.strip())
            
            # Enriquecer resultados
            productores_enriquecidos = []
            for productor in productores:
                productor_enriquecido = productor.copy()
                
                # Agregar información adicional
                productor_enriquecido['cantidad_parcelas'] = self.productor_repo.contar_parcelas_por_productor(productor['id_productor'])
                productor_enriquecido['puede_eliminar'] = self._puede_eliminar_productor_cached(productor['id_productor'])
                productor_enriquecido['tiene_parcelas'] = productor_enriquecido['cantidad_parcelas'] > 0
                productor_enriquecido['categoria'] = self._categorizar_productor(productor_enriquecido)
                
                productores_enriquecidos.append(productor_enriquecido)
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(productores_enriquecidos)} resultados")
            
            return {
                'exito': True,
                'mensaje': f'Búsqueda completada con {len(productores_enriquecidos)} resultados',
                'datos': productores_enriquecidos,
                'metadatos': {
                    'total_resultados': len(productores_enriquecidos),
                    'termino_busqueda': texto_busqueda,
                    'timestamp': self._get_timestamp()
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_productores: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error en la búsqueda',
                'datos': [],
                'metadatos': {'total_resultados': 0}
            }

    @cacheable('servicio_productores', key_func=lambda id_prod: f"id_{id_prod}", ttl=1200)
    def obtener_productor_por_id(self, id_productor):
        """
        Obtiene un productor específico con información enriquecida.
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            dict: Información completa del productor.
        """
        try:
            productor = self.productor_repo.obtener_por_id(id_productor)
            
            # Enriquecer con información adicional
            productor['cantidad_parcelas'] = self.productor_repo.contar_parcelas_por_productor(id_productor)
            productor['puede_eliminar'] = self._puede_eliminar_productor_cached(id_productor)
            productor['tiene_parcelas'] = productor['cantidad_parcelas'] > 0
            productor['categoria'] = self._categorizar_productor(productor)
            productor['estado'] = self._evaluar_estado_productor(productor)
            
            return {
                'exito': True,
                'mensaje': 'Productor obtenido exitosamente',
                'datos': productor,
                'metadatos': {
                    'timestamp': self._get_timestamp(),
                    'tiene_parcelas': productor['tiene_parcelas']
                }
            }
            
        except RegistroNoEncontrado as e:
            logger.error(f"Productor no encontrado: {str(e)}")
            return {
                'exito': False,
                'mensaje': str(e),
                'datos': None
            }
        except Exception as e:
            logger.error(f"Error en servicio obtener_productor_por_id: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener productor',
                'datos': None
            }

    @cacheable('servicio_productores', key_func=lambda texto: f"con_parcelas_{texto.lower().replace(' ', '_')}", ttl=900)
    def obtener_productores_con_parcelas(self, texto_busqueda=None):
        """
        Obtiene productores que tienen parcelas, con información de sus propiedades.
        
        Args:
            texto_busqueda (str, optional): Texto para filtrar productores.
            
        Returns:
            dict: Lista de productores con información de parcelas.
        """
        try:
            if texto_busqueda:
                productores = self.productor_repo.buscar_productores_con_parcelas(texto_busqueda)
            else:
                # Obtener todos los productores con parcelas
                distribucion = self.obtener_distribucion_parcelas_por_productor()['datos']
                productores = [item for item in distribucion if item['cantidad_parcelas'] > 0]
            
            return {
                'exito': True,
                'mensaje': f'{len(productores)} productores con parcelas encontrados',
                'datos': productores,
                'metadatos': {
                    'total_productores': len(productores),
                    'filtro_busqueda': texto_busqueda,
                    'timestamp': self._get_timestamp()
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_productores_con_parcelas: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener productores con parcelas',
                'datos': [],
                'metadatos': {'total_productores': 0}
            }

    # ==================== ESTADÍSTICAS Y REPORTES ====================

    @cacheable('estadisticas_productores', key_func=lambda: 'completas', ttl=1800)
    def obtener_estadisticas_productores(self):
        """
        Obtiene estadísticas completas de productores.
        
        Returns:
            dict: Estadísticas detalladas de productores.
        """
        try:
            # Obtener estadísticas básicas
            total_productores = self.productor_repo._contar_registros_cached()
            distribucion = self.obtener_distribucion_parcelas_por_productor()['datos']
            
            # Calcular métricas
            productores_con_parcelas = len([p for p in distribucion if p['cantidad_parcelas'] > 0])
            productores_sin_parcelas = total_productores - productores_con_parcelas
            
            area_total = sum(p['area_total'] for p in distribucion)
            area_promedio = area_total / productores_con_parcelas if productores_con_parcelas > 0 else 0
            
            estadisticas = {
                'totales': {
                    'productores': total_productores,
                    'productores_con_parcelas': productores_con_parcelas,
                    'productores_sin_parcelas': productores_sin_parcelas
                },
                'areas': {
                    'area_total': round(area_total, 2),
                    'area_promedio': round(area_promedio, 2),
                    'area_maxima': max([p['area_total'] for p in distribucion]) if distribucion else 0,
                    'area_minima': min([p['area_total'] for p in distribucion if p['area_total'] > 0]) if distribucion else 0
                },
                'distribucion': {
                    'porcentaje_con_parcelas': round((productores_con_parcelas / total_productores * 100), 1) if total_productores > 0 else 0,
                    'concentracion_tierras': self._calcular_concentracion_tierras(distribucion)
                }
            }
            
            return {
                'exito': True,
                'mensaje': 'Estadísticas de productores generadas',
                'datos': estadisticas,
                'metadatos': {
                    'timestamp': self._get_timestamp(),
                    'total_calculos': len(estadisticas)
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_productores: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al generar estadísticas',
                'datos': {},
                'metadatos': {}
            }

    @cacheable('estadisticas_productores', key_func=lambda: 'distribucion_parcelas', ttl=2400)
    def obtener_distribucion_parcelas_por_productor(self):
        """
        Obtiene la distribución de parcelas por productor.
        
        Returns:
            dict: Distribución detallada de parcelas.
        """
        try:
            distribucion = self.productor_repo.obtener_distribucion_parcelas_por_productor()
            
            return {
                'exito': True,
                'mensaje': 'Distribución de parcelas obtenida',
                'datos': distribucion,
                'metadatos': {
                    'total_productores': len(distribucion),
                    'productores_con_parcelas': len([p for p in distribucion if p['cantidad_parcelas'] > 0]),
                    'timestamp': self._get_timestamp()
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_distribucion_parcelas_por_productor: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener distribución',
                'datos': [],
                'metadatos': {'total_productores': 0}
            }

    @cacheable('reportes_productores', key_func=lambda: 'completo', ttl=3600)
    def obtener_reporte_productores_parcelas(self):
        """
        Genera un reporte completo de productores y sus parcelas.
        
        Returns:
            dict: Reporte detallado por productor.
        """
        try:
            reporte = self.productor_repo.obtener_reporte_productores_parcelas()
            
            # Enriquecer reporte con métricas adicionales
            for item in reporte:
                item['categoria'] = self._categorizar_productor_por_area(item['area_total'])
                item['antiguedad'] = self._calcular_antiguedad(item['primera_adquisicion'])
            
            return {
                'exito': True,
                'mensaje': f'Reporte generado para {len(reporte)} productores',
                'datos': reporte,
                'metadatos': {
                    'total_productores': len(reporte),
                    'timestamp': self._get_timestamp(),
                    'resumen': {
                        'area_total_sistema': sum(item['area_total'] for item in reporte),
                        'parcelas_totales': sum(item['total_parcelas'] for item in reporte)
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_reporte_productores_parcelas: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al generar reporte',
                'datos': [],
                'metadatos': {'total_productores': 0}
            }

    @cacheable('reportes_productores', key_func=lambda limite=10: f"top_productores_{limite}", ttl=2400)
    def obtener_top_productores_por_area(self, limite=10):
        """
        Obtiene los top productores por área total.
        
        Args:
            limite (int): Número máximo de productores a retornar.
            
        Returns:
            dict: Lista de top productores.
        """
        try:
            top_productores = self.productor_repo.obtener_top_productores_por_area(limite)
            
            return {
                'exito': True,
                'mensaje': f'Top {len(top_productores)} productores por área',
                'datos': top_productores,
                'metadatos': {
                    'limite_aplicado': limite,
                    'timestamp': self._get_timestamp(),
                    'area_total_top': sum(p['area_total'] for p in top_productores)
                }
            }
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_top_productores_por_area: {str(e)}")
            return {
                'exito': False,
                'mensaje': 'Error al obtener top productores',
                'datos': [],
                'metadatos': {'limite_aplicado': limite}
            }

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('validaciones', key_func=lambda id_prod: f"puede_eliminar_{id_prod}", ttl=900)
    def _puede_eliminar_productor_cached(self, id_productor):
        """Verifica si un productor puede ser eliminado (versión cacheada)."""
        try:
            cantidad_parcelas = self.productor_repo.contar_parcelas_por_productor(id_productor)
            return cantidad_parcelas == 0
        except Exception:
            return False

    def _validar_reglas_negocio_creacion(self, datos):
        """Valida reglas de negocio específicas para creación."""
        print(f"🔍 VALIDACIÓN - Datos a validar: {datos}")
        
        if not datos.get('nombre') or not str(datos.get('nombre', '')).strip():
            raise ErrorValidacion("El nombre es obligatorio")
            
        if not datos.get('apellido') or not str(datos.get('apellido', '')).strip():
            raise ErrorValidacion("El apellido es obligatorio")
            
        if not datos.get('identificacion') or not str(datos.get('identificacion', '')).strip():
            raise ErrorValidacion("La identificación es obligatoria")
        
        print("✅ VALIDACIÓN - Datos válidos")

    def _validar_cambios_criticos(self, productor_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Validar cambios en identificación
        if 'identificacion' in datos_nuevos and datos_nuevos['identificacion'] != productor_actual['identificacion']:
            # La validación de duplicados se hace en el repositorio
            pass

    def _normalizar_datos_productor(self, datos):
        """Normaliza y limpia los datos del productor."""
        datos_normalizados = datos.copy()
        
        # Limpiar espacios en strings para todos los campos posibles
        campos_texto = ['nombre', 'apellido', 'identificacion', 'telefono', 'correo', 'direccion', 'notas']
        for campo in campos_texto:
            if campo in datos_normalizados and datos_normalizados[campo] is not None:
                if isinstance(datos_normalizados[campo], str):
                    datos_normalizados[campo] = datos_normalizados[campo].strip()
                else:
                    # Convertir a string si no lo es
                    datos_normalizados[campo] = str(datos_normalizados[campo]).strip()
        
        # Normalizar correo a minúsculas
        if datos_normalizados.get('correo'):
            datos_normalizados['correo'] = datos_normalizados['correo'].lower()
        
        # Manejar campo 'activo' - mapear a diferentes nombres posibles
        if 'activo' in datos_normalizados:
            datos_normalizados['activo'] = bool(datos_normalizados['activo'])
        elif 'estado' in datos_normalizados:
            # Si viene como 'Activo'/'Inactivo'
            if isinstance(datos_normalizados['estado'], str):
                datos_normalizados['activo'] = datos_normalizados['estado'].lower() == 'activo'
            else:
                datos_normalizados['activo'] = bool(datos_normalizados['estado'])
        else:
            # Por defecto, activo
            datos_normalizados['activo'] = True
        
        # Asegurar que los campos obligatorios tengan valores por defecto
        if not datos_normalizados.get('nombre'):
            datos_normalizados['nombre'] = 'Sin nombre'
        if not datos_normalizados.get('apellido'):
            datos_normalizados['apellido'] = 'Sin apellido'
        if not datos_normalizados.get('identificacion'):
            datos_normalizados['identificacion'] = 'Sin identificación'
        
        print(f"🔧 Datos normalizados: {datos_normalizados}")
        
        return datos_normalizados

    def _categorizar_productor(self, productor):
        """Categoriza un productor según su perfil."""
        cantidad_parcelas = productor.get('cantidad_parcelas', 0)
        
        if cantidad_parcelas == 0:
            return 'sin_parcelas'
        elif cantidad_parcelas == 1:
            return 'pequeño_productor'
        elif cantidad_parcelas <= 3:
            return 'productor_medio'
        else:
            return 'gran_productor'

    def _categorizar_productor_por_area(self, area_total):
        """Categoriza un productor según el área total."""
        if area_total <= 5:
            return 'micro_productor'
        elif area_total <= 20:
            return 'pequeño_productor'
        elif area_total <= 100:
            return 'productor_medio'
        else:
            return 'gran_productor'

    def _evaluar_estado_productor(self, productor):
        """Evalúa el estado general del productor."""
        if productor.get('cantidad_parcelas', 0) == 0:
            return 'sin_parcelas'
        elif not productor.get('telefono') or not productor.get('correo'):
            return 'informacion_incompleta'
        else:
            return 'activo'

    def _calcular_concentracion_tierras(self, distribucion):
        """Calcula la concentración de tierras."""
        if not distribucion or len(distribucion) < 2:
            return 0
        
        area_total = sum(p['area_total'] for p in distribucion)
        area_top_20 = sum(p['area_total'] for p in distribucion[:max(1, len(distribucion)//5)])
        
        return round((area_top_20 / area_total * 100), 1) if area_total > 0 else 0

    def _calcular_antiguedad(self, fecha_adquisicion):
        """Calcula la antigüedad en años."""
        if not fecha_adquisicion:
            return 0
        
        from datetime import datetime
        try:
            fecha = datetime.strptime(fecha_adquisicion, '%Y-%m-%d')
            hoy = datetime.now()
            antiguedad = hoy.year - fecha.year
            return max(0, antiguedad)
        except:
            return 0

    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()