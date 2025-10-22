# bd_conecciones/servicios/ClientesVentasServ/cliente_servicio.py

import logging
from ...repositories.ClientesVentasRep.cliente_repositorio import ClienteRepositorio
from ...repositories.ClientesVentasRep.relacion_cliente_venta_repositorio import RelacionClienteVentaRepositorio
from backend.repositories.ClientesVentasRep.cliente_repositorio import ClienteRepositorio
from backend.repositories.ClientesVentasRep.relacion_cliente_venta_repositorio import RelacionClienteVentaRepositorio
from backend.core.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste
)
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class ClienteServicio:
    """Servicio para lógica de negocio de clientes con caché optimizado."""
    
    def __init__(self):
        self.cliente_repo = ClienteRepositorio()
        self.relacion_repo = RelacionClienteVentaRepositorio()
    
    @cacheable('servicio_clientes', key_func=lambda pagina, por_pagina=8: f"paginado_{pagina}_{por_pagina}", ttl=900)  # 15 min
    def obtener_clientes_paginado(self, pagina, por_pagina=8):
        """
        Obtiene clientes con paginación y lógica de negocio aplicada.
        ⭐ OPTIMIZADO: Elimina el problema de N+1 queries cacheando el resultado completo enriquecido
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Resultado con clientes y metadatos.
        """
        try:
            resultado = self.cliente_repo.obtener_paginado(pagina, por_pagina)
            
            # Enriquecer datos con información adicional (OPTIMIZADO: resultado completo cacheado)
            clientes_enriquecidos = []
            for cliente in resultado['clientes']:
                cliente_enriquecido = cliente.copy()
                
                # Obtener datos adicionales (estos métodos ya están cacheados en repositorios)
                cliente_enriquecido['cantidad_ventas'] = self.relacion_repo.contar_ventas_por_cliente(cliente['id_cliente'])
                cliente_enriquecido['puede_eliminar'] = self._puede_eliminar_cliente_cached(cliente['id_cliente'])
                
                # Agregar metadatos de negocio
                cliente_enriquecido['es_cliente_activo'] = cliente['activo']
                cliente_enriquecido['tiene_ventas'] = cliente_enriquecido['cantidad_ventas'] > 0
                cliente_enriquecido['categoria'] = self._categorizar_cliente(cliente_enriquecido['cantidad_ventas'])
                
                clientes_enriquecidos.append(cliente_enriquecido)
            
            # Actualizar resultado con datos enriquecidos
            resultado['clientes'] = clientes_enriquecidos
            
            logger.info(f"Servicio: página {pagina} procesada con {len(resultado['clientes'])} clientes")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_clientes_paginado: {str(e)}")
            raise

    @cache_invalidator('servicio_clientes', pattern='paginado_')  # Invalidar paginación
    @cache_invalidator('servicio_clientes', pattern='busqueda_') # Invalidar búsquedas
    @cache_invalidator('validaciones_cliente')                   # Invalidar validaciones
    def crear_cliente(self, datos_cliente):
        """
        Crea un nuevo cliente con validaciones de negocio.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_cliente (dict): Datos del cliente.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Validaciones de negocio adicionales
            self._validar_reglas_negocio_creacion(datos_cliente)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_cliente(datos_cliente)
            
            # Crear cliente
            exito, id_cliente = self.cliente_repo.crear(datos_normalizados)
            
            if exito:
                resultado = {
                    'exito': True,
                    'id_cliente': id_cliente,
                    'mensaje': f"Cliente creado exitosamente con ID {id_cliente}",
                    'nombre_cliente': datos_normalizados['nombre'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: cliente creado con ID {id_cliente}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear cliente'}
                
        except (ErrorValidacion, RegistroYaExiste) as e:
            logger.error(f"Error de validación en crear_cliente: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_cliente: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_clientes', pattern='paginado_')  # Invalidar paginación
    @cache_invalidator('servicio_clientes', pattern='busqueda_') # Invalidar búsquedas
    @cache_invalidator('validaciones_cliente')                   # Invalidar validaciones
    @cache_invalidator('estados_cliente')                        # Invalidar estados
    def actualizar_cliente(self, id_cliente, datos_cliente):
        """
        Actualiza un cliente con validaciones de negocio.
        OPTIMIZADO: Invalidación específica del cliente actualizado.
        
        Args:
            id_cliente (int): ID del cliente.
            datos_cliente (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales para comparación
            cliente_actual = self.cliente_repo.obtener_por_id(id_cliente)
            
            # Validar cambios críticos
            self._validar_cambios_criticos(cliente_actual, datos_cliente)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_cliente(datos_cliente)
            
            # Actualizar cliente
            exito = self.cliente_repo.actualizar(id_cliente, datos_normalizados)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': 'Cliente actualizado exitosamente',
                    'nombre_cliente': datos_normalizados.get('nombre', cliente_actual['nombre']),
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: cliente {id_cliente} actualizado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar cliente'}
                
        except (ErrorValidacion, RegistroNoEncontrado, RegistroYaExiste) as e:
            logger.error(f"Error en actualizar_cliente: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_cliente: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_clientes', pattern='paginado_')  # Invalidar paginación
    @cache_invalidator('servicio_clientes', pattern='busqueda_') # Invalidar búsquedas
    @cache_invalidator('validaciones_cliente')                   # Invalidar validaciones
    @cache_invalidator('estados_cliente')                        # Invalidar estados
    def eliminar_cliente(self, id_cliente):
        """
        Elimina un cliente verificando dependencias y reglas de negocio.
        OPTIMIZADO: Invalidación completa ya que afecta listas.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            dict: Resultado detallado de la operación.
        """
        try:
            # Obtener información del cliente
            cliente = self.cliente_repo.obtener_por_id(id_cliente)
            
            # Verificar dependencias usando RelacionRepositorio (ya cacheado)
            dependencias = self.relacion_repo.verificar_dependencias_cliente(id_cliente)
            
            # Si tiene dependencias, no se puede eliminar
            if not dependencias['puede_eliminar']:
                return {
                    'exito': False,
                    'mensaje': f"No se puede eliminar a {cliente['nombre']}",
                    'razon': 'Tiene ventas asociadas',
                    'dependencias': dependencias,
                    'tipo_error': 'dependencias'
                }
            
            # Proceder con eliminación
            exito = self.cliente_repo.desactivar(id_cliente)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Cliente {cliente['nombre']} eliminado exitosamente",
                    'nombre_cliente': cliente['nombre'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: cliente {id_cliente} eliminado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al eliminar cliente'}
                
        except RegistroNoEncontrado as e:
            logger.error(f"Cliente no encontrado: {str(e)}")
            return {'exito': False, 'mensaje': str(e), 'tipo_error': 'no_encontrado'}
        except Exception as e:
            logger.error(f"Error en servicio eliminar_cliente: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema', 'tipo_error': 'interno'}

    @cacheable('servicio_clientes', key_func=lambda texto: f"busqueda_{texto.lower().replace(' ', '_')}", ttl=600)  # 10 min
    def buscar_clientes(self, texto_busqueda):
        """
        Busca clientes con lógica de negocio aplicada.
        ⭐ OPTIMIZADO: Resultado enriquecido completo cacheado para evitar N+1 queries
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de clientes encontrados con información adicional.
        """
        try:
            if not texto_busqueda or len(texto_busqueda.strip()) < 2:
                return []
            
            clientes = self.cliente_repo.buscar_por_criterio(texto_busqueda.strip())
            
            # Enriquecer resultados (OPTIMIZADO: resultado completo cacheado)
            clientes_enriquecidos = []
            for cliente in clientes:
                cliente_enriquecido = cliente.copy()
                
                # Agregar información adicional (métodos ya cacheados en repositorios)
                cliente_enriquecido['cantidad_ventas'] = self.relacion_repo.contar_ventas_por_cliente(cliente['id_cliente'])
                cliente_enriquecido['puede_eliminar'] = self._puede_eliminar_cliente_cached(cliente['id_cliente'])
                
                # Metadatos de negocio
                cliente_enriquecido['es_cliente_activo'] = cliente['activo']
                cliente_enriquecido['tiene_ventas'] = cliente_enriquecido['cantidad_ventas'] > 0
                cliente_enriquecido['categoria'] = self._categorizar_cliente(cliente_enriquecido['cantidad_ventas'])
                
                clientes_enriquecidos.append(cliente_enriquecido)
            
            logger.info(f"Servicio: búsqueda '{texto_busqueda}' retornó {len(clientes_enriquecidos)} resultados")
            return clientes_enriquecidos
            
        except Exception as e:
            logger.error(f"Error en servicio buscar_clientes: {str(e)}")
            return []

    @cacheable('estados_cliente', key_func=lambda id_cli: f"estado_completo_{id_cli}", ttl=1200)  # 20 min
    def verificar_estado_cliente(self, id_cliente):
        """
        Verifica el estado completo de un cliente.
        ⭐ OPTIMIZADO: Estado completo cacheado para evitar múltiples consultas
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            dict: Estado completo del cliente.
        """
        try:
            # Estos métodos ya están cacheados en repositorios
            cliente = self.cliente_repo.obtener_por_id(id_cliente)
            cantidad_ventas = self.relacion_repo.contar_ventas_por_cliente(id_cliente)
            
            # Obtener historial si tiene ventas
            historial = None
            if cantidad_ventas > 0:
                historial = self.relacion_repo.obtener_historial_compras_cliente(id_cliente)
            
            estado = {
                'cliente': cliente,
                'cantidad_ventas': cantidad_ventas,
                'puede_eliminar': cantidad_ventas == 0,
                'es_cliente_activo': cliente['activo'],
                'tiene_ventas': cantidad_ventas > 0,
                'historial_compras': historial,
                'timestamp_verificacion': self._get_timestamp(),
                
                # Información adicional de negocio
                'categoria': self._categorizar_cliente(cantidad_ventas),
                'requiere_atencion': self._requiere_atencion_cliente(cliente, cantidad_ventas)
            }
            
            return estado
            
        except RegistroNoEncontrado as e:
            logger.error(f"Cliente no encontrado: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Error en servicio verificar_estado_cliente: {str(e)}")
            return None

    @cacheable('metricas_servicio_clientes', key_func=lambda: 'resumen_clientes', ttl=1800)  # 30 min
    def obtener_resumen_clientes(self):
        """
        Obtiene un resumen completo de clientes para dashboard.
        ⭐ NUEVO: Método optimizado para dashboard
        
        Returns:
            dict: Resumen completo de clientes.
        """
        try:
            # Obtener clasificación de clientes (ya cacheada)
            clasificacion = self.relacion_repo.clasificar_clientes_por_volumen()
            
            # Calcular métricas por categoría
            categorias = {}
            total_clientes = len(clasificacion)
            
            for cliente in clasificacion:
                categoria = cliente['categoria']
                if categoria not in categorias:
                    categorias[categoria] = {
                        'cantidad': 0,
                        'monto_total': 0.0,
                        'ventas_total': 0
                    }
                
                categorias[categoria]['cantidad'] += 1
                categorias[categoria]['monto_total'] += cliente['monto_total']
                categorias[categoria]['ventas_total'] += cliente['total_ventas']
            
            # Obtener cliente top
            cliente_top = self.relacion_repo.obtener_cliente_top()
            
            resumen = {
                'totales': {
                    'clientes_activos': total_clientes,
                    'clientes_con_ventas': len([c for c in clasificacion if c['total_ventas'] > 0]),
                    'clientes_sin_ventas': len([c for c in clasificacion if c['total_ventas'] == 0])
                },
                'por_categoria': categorias,
                'cliente_top_mes': cliente_top,
                'timestamp': self._get_timestamp(),
                
                # Métricas de negocio
                'clientes_premium': len([c for c in clasificacion if c['categoria'] == 'Premium']),
                'clientes_nuevos': len([c for c in clasificacion if c['categoria'] == 'Nuevo']),
                'valor_promedio_cliente': sum(c['monto_total'] for c in clasificacion) / total_clientes if total_clientes > 0 else 0
            }
            
            logger.info(f"Resumen de clientes generado: {total_clientes} total")
            return resumen
            
        except Exception as e:
            logger.error(f"Error generando resumen de clientes: {str(e)}")
            return {}

    # ==================== MÉTODOS AUXILIARES OPTIMIZADOS ====================

    @cacheable('validaciones_cliente', key_func=lambda id_cli: f"puede_eliminar_{id_cli}", ttl=900)  # 15 min
    def _puede_eliminar_cliente_cached(self, id_cliente):
        """
        Verifica si un cliente puede ser eliminado (versión cacheada).
        ⭐ OPTIMIZADO: Evita consultar repetidamente la misma validación
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            bool: True si puede eliminarse.
        """
        try:
            cantidad_ventas = self.relacion_repo.contar_ventas_por_cliente(id_cliente)
            return cantidad_ventas == 0
        except Exception:
            return False

    def _validar_reglas_negocio_creacion(self, datos):
        """Valida reglas de negocio específicas para creación."""
        # Regla: Si se proporciona correo, debe ser válido
        if datos.get('correo'):
            import re
            email_regex = r'\w+([-+.\']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*'
            if not re.match(email_regex, datos['correo']):
                raise ErrorValidacion("El formato del correo electrónico no es válido")
        
        # Regla: El nombre debe tener al menos 2 caracteres
        if len(datos.get('nombre', '').strip()) < 2:
            raise ErrorValidacion("El nombre del cliente debe tener al menos 2 caracteres")
        
        return True

    def _validar_cambios_criticos(self, cliente_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad del sistema."""
        # Por ahora no hay cambios críticos específicos para clientes
        # Esta función está preparada para futuras validaciones
        pass

    def _normalizar_datos_cliente(self, datos):
        """Normaliza y limpia los datos del cliente."""
        datos_normalizados = datos.copy()
        
        # Limpiar espacios en strings
        for campo in ['nombre', 'direccion', 'ciudad', 'estado_provincia', 'telefono', 'correo', 'condiciones_pago']:
            if campo in datos_normalizados and datos_normalizados[campo]:
                datos_normalizados[campo] = datos_normalizados[campo].strip()
        
        # Normalizar correo a minúsculas
        if datos_normalizados.get('correo'):
            datos_normalizados['correo'] = datos_normalizados['correo'].lower()
        
        # Asegurar tipo booleano para activo
        if 'activo' in datos_normalizados:
            datos_normalizados['activo'] = bool(datos_normalizados['activo'])
        
        return datos_normalizados

    def _categorizar_cliente(self, cantidad_ventas):
        """Categoriza un cliente según su actividad de compras."""
        if cantidad_ventas >= 10:
            return 'frecuente'
        elif cantidad_ventas >= 5:
            return 'regular'
        elif cantidad_ventas >= 1:
            return 'ocasional'
        else:
            return 'nuevo'

    def _requiere_atencion_cliente(self, cliente, cantidad_ventas):
        """Determina si un cliente requiere atención especial."""
        # Clientes registrados hace más de 6 meses sin ventas
        if cantidad_ventas == 0:
            from datetime import datetime
            try:
                fecha_registro = datetime.strptime(cliente['fecha_registro'], '%Y-%m-%d')
                dias_desde_registro = (datetime.now() - fecha_registro).days
                if dias_desde_registro > 180:  # 6 meses
                    return True
            except:
                pass
        
        # Clientes sin datos de contacto completos
        if not cliente.get('telefono') and not cliente.get('correo'):
            return True
        
        return False

    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()