# bd_conecciones/servicios/ClientesVentasServ/venta_servicio.py

import logging
import json
from datetime import datetime
from ...repositorios.ClientesVentasRep.venta_repositorio import VentaRepositorio
from ...repositorios.ClientesVentasRep.detalle_venta_repositorio import DetalleVentaRepositorio
from ...repositorios.ClientesVentasRep.estado_venta_repositorio import EstadoVentaRepositorio
from ...repositorios.ClientesVentasRep.relacion_cliente_venta_repositorio import RelacionClienteVentaRepositorio
from ...nucleo.excepciones_bd import (
    ErrorValidacion, 
    RegistroNoEncontrado, 
    RegistroYaExiste
)
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class VentaServicio:
    """Servicio para lógica de negocio de ventas con caché optimizado."""
    
    def __init__(self):
        self.venta_repo = VentaRepositorio()
        self.detalle_repo = DetalleVentaRepositorio()
        self.estado_repo = EstadoVentaRepositorio()
        self.relacion_repo = RelacionClienteVentaRepositorio()
    
    @cacheable('servicio_ventas', key_func=lambda pagina, por_pagina=10: f"paginado_{pagina}_{por_pagina}", ttl=600)  # 10 min
    def obtener_ventas_paginado(self, pagina, por_pagina=10):
        """
        Obtiene ventas con paginación y lógica de negocio aplicada.
        ⭐ OPTIMIZADO: Resultado completo enriquecido cacheado
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Resultado con ventas y metadatos.
        """
        try:
            resultado = self.venta_repo.obtener_paginado(pagina, por_pagina)
            
            # Enriquecer datos con información adicional
            ventas_enriquecidas = []
            for venta in resultado['ventas']:
                venta_enriquecida = venta.copy()
                
                # Agregar metadatos de negocio
                venta_enriquecida['puede_cancelar'] = self._puede_cancelar_venta(venta)
                venta_enriquecida['puede_editar'] = self._puede_editar_venta(venta)
                venta_enriquecida['esta_vencida'] = self._esta_venta_vencida(venta)
                venta_enriquecida['dias_desde_venta'] = self._calcular_dias_desde_venta(venta['fecha_venta'])
                
                ventas_enriquecidas.append(venta_enriquecida)
            
            resultado['ventas'] = ventas_enriquecidas
            
            logger.info(f"Servicio: página {pagina} procesada con {len(resultado['ventas'])} ventas")
            return resultado
            
        except Exception as e:
            logger.error(f"Error en servicio obtener_ventas_paginado: {str(e)}")
            raise

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    @cache_invalidator('servicio_ventas', pattern='busqueda_')  # Invalidar búsquedas
    @cache_invalidator('validaciones_venta')                    # Invalidar validaciones
    def crear_venta(self, venta_data_json, detalles_data_json):
        """
        Crea una nueva venta con sus detalles y validaciones de negocio.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            venta_data_json (str): Datos de la venta en JSON.
            detalles_data_json (str): Detalles de la venta en JSON.
            
        Returns:
            dict: Resultado con éxito e información adicional.
        """
        try:
            # Convertir JSON a diccionarios
            venta_data = json.loads(venta_data_json) if isinstance(venta_data_json, str) else venta_data_json
            detalles_data = json.loads(detalles_data_json) if isinstance(detalles_data_json, str) else detalles_data_json
            
            # Validaciones de negocio adicionales
            self._validar_reglas_negocio_venta(venta_data, detalles_data)
            
            # Normalizar datos
            venta_normalizada = self._normalizar_datos_venta(venta_data)
            detalles_normalizados = self._normalizar_datos_detalles(detalles_data)
            
            # Verificar que el cliente existe y está activo
            self._verificar_cliente_valido(venta_normalizada['id_cliente'])
            
            # Verificar que el estado existe
            self._verificar_estado_valido(venta_normalizada['id_estado'])
            
            # Crear venta
            exito, id_venta = self.venta_repo.crear(venta_normalizada, detalles_normalizados)
            
            if exito:
                resultado = {
                    'exito': True,
                    'id_venta': id_venta,
                    'mensaje': f"Venta creada exitosamente con ID {id_venta}",
                    'codigo_venta': venta_normalizada['codigo_venta'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: venta creada con ID {id_venta}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al crear venta'}
                
        except (ErrorValidacion, RegistroYaExiste) as e:
            logger.error(f"Error de validación en crear_venta: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio crear_venta: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    @cache_invalidator('servicio_ventas', pattern='busqueda_')  # Invalidar búsquedas
    @cache_invalidator('validaciones_venta')                    # Invalidar validaciones
    @cache_invalidator('estados_venta')                         # Invalidar estados
    def actualizar_venta(self, id_venta, venta_data):
        """
        Actualiza una venta con validaciones de negocio.
        
        Args:
            id_venta (int): ID de la venta.
            venta_data (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener datos actuales para validación
            venta_actual = self.venta_repo.obtener_por_id(id_venta)
            
            # Validar que se puede actualizar
            if not self._puede_editar_venta(venta_actual):
                return {
                    'exito': False,
                    'mensaje': 'La venta no puede ser editada en su estado actual',
                    'tipo_error': 'estado_invalido'
                }
            
            # Validar cambios críticos
            self._validar_cambios_criticos_venta(venta_actual, venta_data)
            
            # Normalizar datos
            datos_normalizados = self._normalizar_datos_venta(venta_data)
            
            # Actualizar venta
            exito = self.venta_repo.actualizar(id_venta, datos_normalizados)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': 'Venta actualizada exitosamente',
                    'codigo_venta': venta_actual['codigo_venta'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: venta {id_venta} actualizada")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar venta'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en actualizar_venta: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio actualizar_venta: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    @cache_invalidator('validaciones_venta')                    # Invalidar validaciones
    @cache_invalidator('estados_venta')                         # Invalidar estados
    def cambiar_estado_venta(self, id_venta, nuevo_estado_id):
        """
        Cambia el estado de una venta con validaciones de negocio.
        
        Args:
            id_venta (int): ID de la venta.
            nuevo_estado_id (int): ID del nuevo estado.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener venta y estado actual
            venta_actual = self.venta_repo.obtener_por_id(id_venta)
            nuevo_estado = self.estado_repo.obtener_por_id(nuevo_estado_id)
            
            # Validar transición de estado
            if not self._validar_transicion_estado(venta_actual, nuevo_estado):
                return {
                    'exito': False,
                    'mensaje': f"No se puede cambiar al estado '{nuevo_estado['nombre']}'",
                    'tipo_error': 'transicion_invalida'
                }
            
            # Cambiar estado
            exito = self.venta_repo.cambiar_estado_venta(id_venta, nuevo_estado_id)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Estado cambiado a '{nuevo_estado['nombre']}'",
                    'nuevo_estado': nuevo_estado['nombre'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: estado de venta {id_venta} cambiado a {nuevo_estado['nombre']}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al cambiar estado'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en cambiar_estado_venta: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio cambiar_estado_venta: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    @cache_invalidator('validaciones_venta')                    # Invalidar validaciones
    def cambiar_estado_pago(self, id_venta, nuevo_estado_pago):
        """
        Cambia el estado de pago de una venta.
        
        Args:
            id_venta (int): ID de la venta.
            nuevo_estado_pago (str): Nuevo estado de pago.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener venta actual
            venta_actual = self.venta_repo.obtener_por_id(id_venta)
            
            # Validar nuevo estado de pago
            if nuevo_estado_pago not in ['Pendiente', 'Parcial', 'Pagado']:
                return {
                    'exito': False,
                    'mensaje': f"Estado de pago '{nuevo_estado_pago}' no es válido",
                    'tipo_error': 'estado_invalido'
                }
            
            # Cambiar estado de pago
            exito = self.venta_repo.cambiar_estado_pago(id_venta, nuevo_estado_pago)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Estado de pago cambiado a '{nuevo_estado_pago}'",
                    'nuevo_estado_pago': nuevo_estado_pago,
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: estado de pago de venta {id_venta} cambiado a {nuevo_estado_pago}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al cambiar estado de pago'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en cambiar_estado_pago: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio cambiar_estado_pago: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    @cache_invalidator('validaciones_venta')                    # Invalidar validaciones
    def cancelar_venta(self, id_venta, motivo_cancelacion):
        """
        Cancela una venta con validaciones de negocio.
        
        Args:
            id_venta (int): ID de la venta.
            motivo_cancelacion (str): Motivo de la cancelación.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener venta actual
            venta_actual = self.venta_repo.obtener_por_id(id_venta)
            
            # Validar que se puede cancelar
            if not self._puede_cancelar_venta(venta_actual):
                return {
                    'exito': False,
                    'mensaje': 'La venta no puede ser cancelada en su estado actual',
                    'tipo_error': 'estado_invalido'
                }
            
            # Validar motivo
            if not motivo_cancelacion or len(motivo_cancelacion.strip()) < 5:
                return {
                    'exito': False,
                    'mensaje': 'El motivo de cancelación debe tener al menos 5 caracteres',
                    'tipo_error': 'validacion'
                }
            
            # Cancelar venta
            exito = self.venta_repo.cancelar_venta(id_venta, motivo_cancelacion)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Venta {venta_actual['codigo_venta']} cancelada exitosamente",
                    'codigo_venta': venta_actual['codigo_venta'],
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: venta {id_venta} cancelada")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al cancelar venta'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en cancelar_venta: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio cancelar_venta: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    def duplicar_venta(self, id_venta, nuevo_codigo=None, nueva_fecha=None):
        """
        Duplica una venta existente con validaciones.
        
        Args:
            id_venta (int): ID de la venta a duplicar.
            nuevo_codigo (str): Código para la nueva venta.
            nueva_fecha (str): Fecha para la nueva venta.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener venta actual
            venta_actual = self.venta_repo.obtener_por_id(id_venta)
            
            # Validar que se puede duplicar
            if not self._puede_duplicar_venta(venta_actual):
                return {
                    'exito': False,
                    'mensaje': 'La venta no puede ser duplicada',
                    'tipo_error': 'operacion_invalida'
                }
            
            # Generar código si no se proporciona
            if not nuevo_codigo:
                nuevo_codigo = self.venta_repo.generar_codigo_venta()
            
            # Duplicar venta
            exito, nueva_venta_id = self.venta_repo.duplicar_venta(id_venta, nuevo_codigo, nueva_fecha)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': f"Venta duplicada exitosamente",
                    'nueva_venta_id': nueva_venta_id,
                    'nuevo_codigo': nuevo_codigo,
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: venta {id_venta} duplicada con ID {nueva_venta_id}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al duplicar venta'}
                
        except (ErrorValidacion, RegistroNoEncontrado) as e:
            logger.error(f"Error en duplicar_venta: {str(e)}")
            return {'exito': False, 'mensaje': str(e)}
        except Exception as e:
            logger.error(f"Error en servicio duplicar_venta: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    # ==================== MÉTODOS PARA DETALLES DE VENTA ====================

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    @cache_invalidator('detalles_venta')                         # Invalidar detalles
    def agregar_detalle_venta(self, id_venta, detalle_data):
        """
        Agrega un detalle a una venta existente.
        
        Args:
            id_venta (int): ID de la venta.
            detalle_data (dict): Datos del detalle.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener venta actual
            venta_actual = self.venta_repo.obtener_por_id(id_venta)
            
            # Validar que se puede agregar detalle
            if not self._puede_editar_venta(venta_actual):
                return {
                    'exito': False,
                    'mensaje': 'No se pueden agregar detalles a esta venta',
                    'tipo_error': 'estado_invalido'
                }
            
            # Preparar datos del detalle
            detalle_completo = detalle_data.copy()
            detalle_completo['id_venta'] = id_venta
            
            # Crear detalle
            exito, id_detalle = self.detalle_repo.crear(detalle_completo)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': 'Detalle agregado exitosamente',
                    'id_detalle': id_detalle,
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: detalle agregado a venta {id_venta}")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al agregar detalle'}
                
        except Exception as e:
            logger.error(f"Error en servicio agregar_detalle_venta: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    @cache_invalidator('detalles_venta')                         # Invalidar detalles
    def actualizar_detalle_venta(self, id_detalle_venta, detalle_data):
        """
        Actualiza un detalle de venta.
        
        Args:
            id_detalle_venta (int): ID del detalle.
            detalle_data (dict): Datos actualizados.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener detalle actual
            detalle_actual = self.detalle_repo.obtener_por_id(id_detalle_venta)
            
            # Obtener venta asociada
            venta_actual = self.venta_repo.obtener_por_id(detalle_actual['id_venta'])
            
            # Validar que se puede editar
            if not self._puede_editar_venta(venta_actual):
                return {
                    'exito': False,
                    'mensaje': 'No se pueden editar detalles de esta venta',
                    'tipo_error': 'estado_invalido'
                }
            
            # Actualizar detalle
            exito = self.detalle_repo.actualizar(id_detalle_venta, detalle_data)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': 'Detalle actualizado exitosamente',
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: detalle {id_detalle_venta} actualizado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al actualizar detalle'}
                
        except Exception as e:
            logger.error(f"Error en servicio actualizar_detalle_venta: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    @cache_invalidator('servicio_ventas', pattern='paginado_')   # Invalidar paginación
    @cache_invalidator('detalles_venta')                         # Invalidar detalles
    def eliminar_detalle_venta(self, id_detalle_venta):
        """
        Elimina un detalle de venta.
        
        Args:
            id_detalle_venta (int): ID del detalle.
            
        Returns:
            dict: Resultado de la operación.
        """
        try:
            # Obtener detalle actual
            detalle_actual = self.detalle_repo.obtener_por_id(id_detalle_venta)
            
            # Obtener venta asociada
            venta_actual = self.venta_repo.obtener_por_id(detalle_actual['id_venta'])
            
            # Validar que se puede eliminar
            if not self._puede_editar_venta(venta_actual):
                return {
                    'exito': False,
                    'mensaje': 'No se pueden eliminar detalles de esta venta',
                    'tipo_error': 'estado_invalido'
                }
            
            # Verificar que no sea el último detalle
            detalles_venta = self.detalle_repo.obtener_por_venta(venta_actual['id_venta'])
            if len(detalles_venta) <= 1:
                return {
                    'exito': False,
                    'mensaje': 'No se puede eliminar el último detalle de la venta',
                    'tipo_error': 'validacion'
                }
            
            # Eliminar detalle
            exito = self.detalle_repo.desactivar(id_detalle_venta)
            
            if exito:
                resultado = {
                    'exito': True,
                    'mensaje': 'Detalle eliminado exitosamente',
                    'requiere_actualizacion_listas': True
                }
                
                logger.info(f"Servicio: detalle {id_detalle_venta} eliminado")
                return resultado
            else:
                return {'exito': False, 'mensaje': 'Error al eliminar detalle'}
                
        except Exception as e:
            logger.error(f"Error en servicio eliminar_detalle_venta: {str(e)}")
            return {'exito': False, 'mensaje': 'Error interno del sistema'}

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _validar_reglas_negocio_venta(self, venta_data, detalles_data):
        """Valida reglas de negocio específicas para ventas."""
        # Validar que tiene al menos un detalle
        if not detalles_data or len(detalles_data) == 0:
            raise ErrorValidacion("La venta debe tener al menos un detalle")
        
        # Validar cada detalle
        for i, detalle in enumerate(detalles_data):
            if not detalle.get('cantidad') or float(detalle['cantidad']) <= 0:
                raise ErrorValidacion(f"Detalle #{i+1}: La cantidad debe ser mayor que cero")
            
            if not detalle.get('precio_unitario') or float(detalle['precio_unitario']) <= 0:
                raise ErrorValidacion(f"Detalle #{i+1}: El precio unitario debe ser mayor que cero")
        
        return True
    
    def _normalizar_datos_venta(self, datos):
        """Normaliza y limpia los datos de la venta."""
        datos_normalizados = datos.copy()
        
        # Asegurar fecha de venta
        if 'fecha_venta' not in datos_normalizados:
            datos_normalizados['fecha_venta'] = datetime.now().strftime('%Y-%m-%d')
        
        # Limpiar strings
        for campo in ['codigo_venta', 'condiciones_pago', 'lugar_entrega', 'observaciones']:
            if campo in datos_normalizados and datos_normalizados[campo]:
                datos_normalizados[campo] = datos_normalizados[campo].strip()
        
        # Asegurar estado por defecto si no se proporciona
        if 'id_estado' not in datos_normalizados:
            estado_default = self.estado_repo.obtener_estado_por_defecto()
            if estado_default:
                datos_normalizados['id_estado'] = estado_default['id_estado']
        
        return datos_normalizados
    
    def _normalizar_datos_detalles(self, detalles_data):
        """Normaliza los datos de los detalles."""
        detalles_normalizados = []
        
        for detalle in detalles_data:
            detalle_normalizado = detalle.copy()
            
            # Asegurar tipos numéricos
            detalle_normalizado['cantidad'] = float(detalle['cantidad'])
            detalle_normalizado['precio_unitario'] = float(detalle['precio_unitario'])
            
            # Calcular subtotal y total si no están presentes
            if 'subtotal' not in detalle_normalizado:
                detalle_normalizado['subtotal'] = detalle_normalizado['cantidad'] * detalle_normalizado['precio_unitario']
            
            if 'total' not in detalle_normalizado:
                detalle_normalizado['total'] = detalle_normalizado['subtotal']  # Ajustar según reglas de negocio
            
            detalles_normalizados.append(detalle_normalizado)
        
        return detalles_normalizados
    
    def _verificar_cliente_valido(self, id_cliente):
        """Verifica que el cliente existe y está activo."""
        count = self.venta_repo._contar_registros("Clientes", "id_cliente = ? AND activo = 1", (id_cliente,))
        if count == 0:
            raise ErrorValidacion(f"El cliente con ID {id_cliente} no existe o no está activo")
    
    def _verificar_estado_valido(self, id_estado):
        """Verifica que el estado existe y está activo."""
        try:
            estado = self.estado_repo.obtener_por_id(id_estado)
            if not estado['activo']:
                raise ErrorValidacion(f"El estado con ID {id_estado} no está activo")
        except RegistroNoEncontrado:
            raise ErrorValidacion(f"El estado con ID {id_estado} no existe")
    
    def _puede_cancelar_venta(self, venta):
        """Determina si una venta puede ser cancelada."""
        estados_no_cancelables = ['Cancelado', 'Finalizado', 'Entregado']
        return venta['estado_nombre'] not in estados_no_cancelables
    
    def _puede_editar_venta(self, venta):
        """Determina si una venta puede ser editada."""
        estados_no_editables = ['Cancelado', 'Finalizado', 'Entregado']
        return venta['estado_nombre'] not in estados_no_editables
    
    def _puede_duplicar_venta(self, venta):
        """Determina si una venta puede ser duplicada."""
        # Se puede duplicar cualquier venta excepto las canceladas
        return venta['estado_nombre'] != 'Cancelado'
    
    def _esta_venta_vencida(self, venta):
        """Determina si una venta está vencida."""
        if not venta.get('fecha_entrega'):
            return False
        
        try:
            fecha_entrega = datetime.strptime(venta['fecha_entrega'], '%Y-%m-%d').date()
            hoy = datetime.now().date()
            return fecha_entrega < hoy and venta['estado_nombre'] not in ['Entregado', 'Finalizado', 'Cancelado']
        except:
            return False
    
    def _calcular_dias_desde_venta(self, fecha_venta):
        """Calcula los días desde que se realizó la venta."""
        try:
            fecha = datetime.strptime(fecha_venta, '%Y-%m-%d').date()
            hoy = datetime.now().date()
            return (hoy - fecha).days
        except:
            return 0
    
    def _validar_transicion_estado(self, venta_actual, nuevo_estado):
        """Valida si es válida la transición de estado."""
        # Reglas básicas de transición
        estado_actual = venta_actual['estado_nombre']
        estado_nuevo = nuevo_estado['nombre']
        
        # No se puede cambiar desde estados finales
        if estado_actual in ['Cancelado', 'Finalizado']:
            return False
        
        # Se puede cambiar a cualquier estado desde Pendiente
        if estado_actual == 'Pendiente':
            return True
        
        # Lógica adicional según necesidades del negocio
        return True
    
    def _validar_cambios_criticos_venta(self, venta_actual, datos_nuevos):
        """Valida cambios que podrían afectar la integridad."""
        # No permitir cambiar cliente en ventas con pagos
        if 'id_cliente' in datos_nuevos and datos_nuevos['id_cliente'] != venta_actual['id_cliente']:
            if venta_actual['estado_pago'] in ['Parcial', 'Pagado']:
                raise ErrorValidacion("No se puede cambiar el cliente en una venta con pagos registrados")
        
        # Validar cambios de fecha
        if 'fecha_venta' in datos_nuevos:
            try:
                nueva_fecha = datetime.strptime(datos_nuevos['fecha_venta'], '%Y-%m-%d').date()
                hoy = datetime.now().date()
                if nueva_fecha > hoy:
                    raise ErrorValidacion("La fecha de venta no puede ser futura")
            except ValueError:
                raise ErrorValidacion("Formato de fecha inválido")
        
        return True