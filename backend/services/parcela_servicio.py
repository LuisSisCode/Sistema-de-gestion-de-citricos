# bd_conecciones/servicios/parcela_servicio.py

import logging
from ..repositories.parcela_repositorio import ParcelaRepositorio
from ..repositories.relacion_repositorio import RelacionRepositorio
from ..repositories.productor_repositorio import ProductorRepositorio
from ..core.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste
)

logger = logging.getLogger(__name__)

class ParcelaServicio:
    """Servicio para lógica de negocio de parcelas."""
    
    def __init__(self):
        self.parcela_repo = ParcelaRepositorio()
        self.relacion_repo = RelacionRepositorio()
        self.productor_repo = ProductorRepositorio()
    
    def obtener_parcelas_paginado(self, pagina, por_pagina = 5, propietario_id=None):
        """
        Obtiene parcelas con paginación y lógica de negocio aplicada.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            propietario_id (int, optional): Filtro por propietario.
            
        Returns:
            dict: Resultado con parcelas y metadatos.
        """
        try:
            resultado = self.parcela_repo.obtener_paginado(pagina, por_pagina, propietario_id)
            
            # Enriquecer datos con información adicional
            for parcela in resultado['parcelas']:
                parcela['tiene_coordenadas'] = bool(parcela['latitud'] and parcela['longitud'])
                parcela['area_hectareas_texto'] = f"{parcela['area']} ha"
                parcela['estado_coordenadas'] = self._evaluar_estado_coordenadas(parcela)
                
            # Agregar metadatos adicionales
            resultado['filtro_propietario'] = propietario_id
            resultado['estadisticas_pagina'] = self._calcular_estadisticas_pagina(resultado['parcelas'])
            
            logger.info(f"Servicio: página {pagina} de parcelas procesada con {len(resultado['parcelas'])} registros")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_parcelas_paginado: {str(e)}")
            raise
    
    def crear_parcela(self, datos_parcela):
        """
        Crea una nueva parcela con validaciones de negocio.
        
        Args:
            datos_parcela (dict): Datos de la parcela.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio específicas
            self._validar_reglas_negocio_creacion(datos_parcela)
            
            # Normalizar y enriquecer datos
            datos_normalizados = self._normalizar_datos_parcela(datos_parcela)
            
            # Validar propietario
            self._validar_propietario(datos_normalizados['propietarioId'])
            
            # Crear parcela
            exito, id_parcela = self.parcela_repo.crear(datos_normalizados)
            
            if exito:
                # Obtener información de la parcela creada
                parcela_creada = self.parcela_repo.obtener_por_id(id_parcela)
                
                resultado = {
                    'exito': True,
                    'id_parcela': id_parcela,
                    'mensaje': f"Parcela '{datos_normalizados['nombre']}' creada exitosamente",
                    'parcela': parcela_creada,
                    'tiene_coordenadas': bool(datos_normalizados.get('latitud'))
                }
                
                logger.info(f"Servicio: parcela creada con ID {id_parcela}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear parcela'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error de validación en crear_parcela: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_parcela: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
    
    def actualizar_parcela(self, id_parcela, datos_parcela):
        """
        Actualiza una parcela con validaciones de negocio.
        
        Args:
            id_parcela (int): ID de la parcela.
            datos_parcela (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales
            parcela_actual = self.parcela_repo.obtener_por_id(id_parcela)
            
            # Validar cambios críticos
            self._validar_cambios_criticos(parcela_actual, datos_parcela)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_parcela(datos_parcela)
            
            # Validar nuevo propietario si cambió
            if 'propietarioId' in datos_normalizados:
                self._validar_propietario(datos_normalizados['propietarioId'])
            
            # Actualizar parcela
            exito = self.parcela_repo.actualizar(id_parcela, datos_normalizados)
            
            if exito:
                # Verificar cambios importantes
                
                resultado = {
                    'exito': True,
                    'mensaje': f"Parcela '{parcela_actual['nombre']}' actualizada exitosamente"
                }
                
                logger.info(f"Servicio: parcela {id_parcela} actualizada")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar parcela'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en actualizar_parcela: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_parcela: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
    
    def eliminar_parcela(self, id_parcela):
        """
        Elimina una parcela con validaciones de negocio.
        
        Args:
            id_parcela (int): ID de la parcela.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener información de la parcela
            parcela = self.parcela_repo.obtener_por_id(id_parcela)
            
            # Validar si se puede eliminar (reglas de negocio futuras)
            self._validar_eliminacion_parcela(parcela)
            
            # Proceder con eliminación
            exito = self.parcela_repo.desactivar(id_parcela)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Parcela '{parcela['nombre']}' eliminada exitosamente",
                    'propietario': parcela['propietario'],
                    'area': parcela['area']
                }
                
                logger.info(f"Servicio: parcela {id_parcela} eliminada")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al eliminar parcela'}
                
        except RegistroNoEncontrado as e:
            logger.error(f"Parcela no encontrada: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except ErrorValidacion as e:
            logger.error(f"No se puede eliminar parcela: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio eliminar_parcela: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}
    
    def buscar_parcelas(self, texto_busqueda):
        """
        Busca parcelas con lógica de negocio aplicada.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de parcelas encontradas con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return []
            
            parcelas = self.parcela_repo.buscar_por_nombre(texto_busqueda.strip())
            
            # Enriquecer resultados
            for parcela in parcelas:
                parcela['tiene_coordenadas'] = bool(parcela['latitud'] and parcela['longitud'])
                parcela['area_hectareas_texto'] = f"{parcela['area']} ha"
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(parcelas)} parcelas")
            return parcelas
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_parcelas: {str(e)}")
            return []
    
    def obtener_estadisticas_parcelas(self):
        """
        Obtiene estadísticas completas de parcelas.
        
        Returns:
            dict: Estadísticas detalladas.
        """
        try:
            estadisticas_basicas = self.parcela_repo.obtener_estadisticas_basicas()
            parcelas_sin_coords = self.relacion_repo.obtener_parcelas_sin_coordenadas()
            distribucion = self.relacion_repo.obtener_distribución_parcelas_por_propietario()
            
            estadisticas = {
                **estadisticas_basicas,
                'parcelas_sin_coordenadas': len(parcelas_sin_coords),
                'distribucion_por_propietario': distribucion,
                'porcentaje_con_coordenadas': self._calcular_porcentaje_coordenadas(estadisticas_basicas, parcelas_sin_coords)
            }
            
            return estadisticas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_estadisticas_parcelas: {str(e)}")
            return {}
    
    def obtener_parcelas_por_propietario(self, propietario_id):
        """
        Obtiene parcelas de un propietario específico con información enriquecida.
        
        Args:
            propietario_id (int): ID del propietario.
            
        Returns:
            list: Lista de parcelas del propietario.
        """
        try:
            if propietario_id == 0:
                parcelas = self.parcela_repo.obtener_todas()
            else:
                parcelas = self.parcela_repo.obtener_por_propietario(propietario_id)
            
            # Enriquecer datos
            for parcela in parcelas:
                parcela['tiene_coordenadas'] = bool(parcela['latitud'] and parcela['longitud'])
                parcela['area_hectareas_texto'] = f"{parcela['area']} ha"
            
            return parcelas
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_parcelas_por_propietario: {str(e)}")
            return []
    
    def _validar_reglas_negocio_creacion(self, datos):
        """Valida reglas de negocio específicas para creación."""
        # Regla: Área mínima
        if datos.get('area', 0) < 0.1:
            raise ErrorValidacion("El área mínima de una parcela debe ser 0.1 hectáreas")
        
        # Regla: Área máxima razonable
        if datos.get('area', 0) > 10000:
            raise ErrorValidacion("El área máxima permitida es 10,000 hectáreas")
    
    def _validar_cambios_criticos(self, parcela_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Validar reducción drástica de área
        if 'area' in datos_nuevos:
            area_nueva = datos_nuevos['area']
            area_actual = parcela_actual['area']
            
            if area_nueva < area_actual * 0.1:  # Reducción mayor al 90%
                raise ErrorValidacion("No se puede reducir el área en más del 90% de una sola vez")
    
    def _validar_eliminacion_parcela(self, parcela):
        """Valida si una parcela puede ser eliminada."""
        # En el futuro, verificar cultivos activos, contratos, etc.
        # Por ahora, todas las parcelas pueden eliminarse
        pass
    
    def _validar_propietario(self, propietario_id):
        """Valida que el propietario existe y es válido."""
        try:
            productor = self.productor_repo.obtener_por_id(propietario_id)
            if not productor['esPropietario']:
                raise ErrorValidacion("El productor seleccionado no está marcado como propietario")
        except RegistroNoEncontrado:
            raise ErrorValidacion("El propietario seleccionado no existe")
    
    def _normalizar_datos_parcela(self, datos):
        """Normaliza y limpia los datos de la parcela."""
        datos_normalizados = datos.copy()
        
        # Limpiar espacios en strings
        for campo in ['nombre', 'ubicacion', 'tipoSuelo', 'fuenteAgua']:
            if campo in datos_normalizados and datos_normalizados[campo]:
                datos_normalizados[campo] = datos_normalizados[campo].strip()
        
        # Normalizar área
        if 'area' in datos_normalizados:
            datos_normalizados['area'] = round(float(datos_normalizados['area']), 2)
        
        # Normalizar coordenadas
        if 'latitud' in datos_normalizados and datos_normalizados['latitud']:
            datos_normalizados['latitud'] = round(float(datos_normalizados['latitud']), 6)
        
        if 'longitud' in datos_normalizados and datos_normalizados['longitud']:
            datos_normalizados['longitud'] = round(float(datos_normalizados['longitud']), 6)
        
        return datos_normalizados
    
    def _verificar_cambio_propietario(self, parcela_actual, datos_nuevos):
        """Verifica si cambió el propietario."""
        return ('propietarioId' in datos_nuevos and 
                parcela_actual['propietarioId'] != datos_nuevos['propietarioId'])
    
    def _verificar_cambio_coordenadas(self, parcela_actual, datos_nuevos):
        """Verifica si cambiaron las coordenadas."""
        return (('latitud' in datos_nuevos and parcela_actual['latitud'] != datos_nuevos.get('latitud')) or
                ('longitud' in datos_nuevos and parcela_actual['longitud'] != datos_nuevos.get('longitud')))
    
    def _evaluar_estado_coordenadas(self, parcela):
        """Evalúa el estado de las coordenadas de una parcela."""
        if not parcela['latitud'] or not parcela['longitud']:
            return 'sin_coordenadas'
        
        # Verificar si las coordenadas están dentro de Bolivia
        lat, lng = parcela['latitud'], parcela['longitud']
        if -25 <= lat <= -9 and -70 <= lng <= -57:
            return 'coordenadas_validas'
        else:
            return 'coordenadas_sospechosas'
    
    def _calcular_estadisticas_pagina(self, parcelas):
        """Calcula estadísticas de la página actual."""
        if not parcelas:
            return {'area_total_pagina': 0, 'area_promedio_pagina': 0}
        
        area_total = sum(p['area'] for p in parcelas)
        area_promedio = area_total / len(parcelas)
        
        return {
            'area_total_pagina': round(area_total, 2),
            'area_promedio_pagina': round(area_promedio, 2)
        }
    
    def _calcular_porcentaje_coordenadas(self, estadisticas_basicas, parcelas_sin_coords):
        """Calcula el porcentaje de parcelas con coordenadas."""
        total = estadisticas_basicas.get('total_parcelas', 0)
        sin_coords = len(parcelas_sin_coords)
        
        if total == 0:
            return 0
        
        return round(((total - sin_coords) / total) * 100, 1)