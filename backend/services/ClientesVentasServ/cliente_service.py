"""
Servicio de Clientes
Capa de lógica de negocio - Validaciones, análisis, orquestación
Usa ClienteRepositorio para acceso a datos
"""

import logging
from datetime import datetime, timedelta, date
from typing import List, Dict, Optional, Tuple
from backend.repositories.ClientesVentasRep.cliente_repositorio import ClienteRepositorio
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

# Configurar logging
logger = logging.getLogger('cliente_service')


class ClienteService:
    """
    Servicio de lógica de negocio para clientes.
    Responsabilidad: Validaciones, análisis, cálculos complejos, orquestación.
    """
    
    def __init__(self):
        """Inicializa el servicio con su repositorio."""
        self.repo = ClienteRepositorio()
        logger.info("✅ ClienteService inicializado correctamente.")
    
    # ==================== CRUD CON LÓGICA DE NEGOCIO ====================
    
    @cacheable('clientes', ttl=get_ttl('clientes'))
    def obtener_clientes(self) -> List[Dict]:
        """
        Obtiene todos los clientes activos con caché.
        
        Returns:
            List[Dict]: Lista de clientes.
        """
        try:
            clientes = self.repo.obtener_todos()
            logger.info(f"✅ Servicio: {len(clientes)} clientes obtenidos")
            return clientes
        except Exception as e:
            logger.error(f"❌ Error en servicio al obtener clientes: {str(e)}")
            return []
    
    @cacheable('clientes', key_func=lambda self, id_cli: f"id_{id_cli}")
    def obtener_cliente(self, id_cliente: int) -> Optional[Dict]:
        """
        Obtiene un cliente por ID con caché.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            Dict con información del cliente o None.
        """
        try:
            cliente = self.repo.obtener_por_id(id_cliente)
            
            if cliente:
                logger.info(f"✅ Cliente {id_cliente} obtenido")
            else:
                logger.warning(f"⚠️ Cliente {id_cliente} no encontrado")
            
            return cliente
        except Exception as e:
            logger.error(f"❌ Error al obtener cliente {id_cliente}: {str(e)}")
            return None
    
    @cache_invalidator('clientes')
    def crear_cliente(self, cliente_data: Dict, registrado_por: int) -> Tuple[bool, str, Optional[int]]:
        """
        Crea un nuevo cliente con validación.
        
        Args:
            cliente_data: Datos del cliente.
            registrado_por: ID del usuario que registra.
            
        Returns:
            Tuple[bool, str, Optional[int]]: (Éxito, Mensaje, ID del cliente)
        """
        try:
            # Validar datos
            valido, mensaje = self.validar_datos_cliente(cliente_data)
            if not valido:
                logger.warning(f"⚠️ Validación fallida: {mensaje}")
                return False, mensaje, None
            
            # Crear cliente
            exito, id_cliente = self.repo.crear(cliente_data, registrado_por)
            
            if exito:
                logger.info(f"✅ Cliente creado exitosamente: ID {id_cliente}")
                return True, "Cliente creado exitosamente", id_cliente
            else:
                logger.error("❌ Error al crear cliente en BD")
                return False, "Error al crear cliente en la base de datos", None
                
        except Exception as e:
            logger.error(f"❌ Error al crear cliente: {str(e)}")
            return False, f"Error al crear cliente: {str(e)}", None
    
    @cache_invalidator('clientes')
    def actualizar_cliente(self, id_cliente: int, cliente_data: Dict) -> Tuple[bool, str]:
        """
        Actualiza un cliente existente con validación.
        
        Args:
            id_cliente: ID del cliente a actualizar.
            cliente_data: Datos actualizados.
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que el cliente existe
            if not self.repo.existe_cliente(id_cliente):
                return False, f"Cliente {id_cliente} no encontrado"
            
            # Validar datos
            valido, mensaje = self.validar_datos_cliente(cliente_data)
            if not valido:
                logger.warning(f"⚠️ Validación fallida: {mensaje}")
                return False, mensaje
            
            # Actualizar
            exito = self.repo.actualizar(id_cliente, cliente_data)
            
            if exito:
                logger.info(f"✅ Cliente {id_cliente} actualizado")
                return True, "Cliente actualizado exitosamente"
            else:
                return False, "Error al actualizar cliente"
                
        except Exception as e:
            logger.error(f"❌ Error al actualizar cliente: {str(e)}")
            return False, f"Error al actualizar cliente: {str(e)}"
    
    @cache_invalidator('clientes')
    def eliminar_cliente(self, id_cliente: int) -> Tuple[bool, str]:
        """
        Elimina lógicamente un cliente con validaciones.
        
        Args:
            id_cliente: ID del cliente a eliminar.
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        try:
            # Verificar que existe
            if not self.repo.existe_cliente(id_cliente):
                return False, f"Cliente {id_cliente} no encontrado"
            
            # Verificar si tiene ventas (regla de negocio: advertir pero permitir)
            tiene_ventas = self.repo.verificar_tiene_ventas(id_cliente)
            if tiene_ventas:
                logger.warning(f"⚠️ Cliente {id_cliente} tiene ventas asociadas")
                # Podrías decidir si permitir o no la eliminación
                # Por ahora, permitimos pero registramos
            
            # Eliminar (soft delete)
            exito = self.repo.eliminar(id_cliente)
            
            if exito:
                mensaje = "Cliente eliminado exitosamente"
                if tiene_ventas:
                    mensaje += " (tenía ventas asociadas)"
                logger.info(f"✅ {mensaje}")
                return True, mensaje
            else:
                return False, "Error al eliminar cliente"
                
        except Exception as e:
            logger.error(f"❌ Error al eliminar cliente: {str(e)}")
            return False, f"Error al eliminar cliente: {str(e)}"
    
    # ==================== BÚSQUEDAS ====================
    
    @cacheable('clientes', key_func=lambda self, criterio: f"buscar_{criterio}", ttl=900)
    def buscar_clientes(self, criterio: str) -> List[Dict]:
        """
        Busca clientes por criterio con caché.
        
        Args:
            criterio: Texto a buscar.
            
        Returns:
            List[Dict]: Lista de clientes que coinciden.
        """
        try:
            if not criterio or len(criterio.strip()) < 2:
                logger.warning("⚠️ Criterio de búsqueda muy corto")
                return []
            
            clientes = self.repo.buscar_por_criterio(criterio.strip())
            logger.info(f"🔍 Búsqueda '{criterio}': {len(clientes)} resultados")
            return clientes
            
        except Exception as e:
            logger.error(f"❌ Error al buscar clientes: {str(e)}")
            return []
    
    # ==================== ANÁLISIS Y REPORTES ====================
    
    @cacheable('clientes_analisis', key_func=lambda self: 'clasificacion', ttl=1800)
    def clasificar_clientes_por_volumen(self) -> List[Dict]:
        """
        Clasifica clientes por volumen de compras en categorías.
        Lógica de negocio: Usa percentiles para clasificar.
        
        Returns:
            List[Dict]: Clientes con categoría asignada.
        """
        try:
            # Obtener clientes con estadísticas de ventas
            clientes = self.repo.obtener_con_estadisticas_ventas()
            
            if not clientes:
                return []
            
            # Extraer montos para calcular percentiles
            montos = [cliente['monto_total'] for cliente in clientes]
            montos.sort()
            
            # Calcular percentiles
            percentil_80 = self._calcular_percentil(montos, 80)
            percentil_50 = self._calcular_percentil(montos, 50)
            percentil_20 = self._calcular_percentil(montos, 20)
            
            # Clasificar cada cliente
            for cliente in clientes:
                monto = cliente['monto_total']
                
                if monto >= percentil_80:
                    cliente['categoria'] = "Premium"
                elif monto >= percentil_50:
                    cliente['categoria'] = "Regular"
                elif monto >= percentil_20:
                    cliente['categoria'] = "Ocasional"
                else:
                    cliente['categoria'] = "Nuevo"
            
            logger.info(f"📊 Clasificación completada: {len(clientes)} clientes")
            return clientes
            
        except Exception as e:
            logger.error(f"❌ Error al clasificar clientes: {str(e)}")
            return []
    
    @cacheable('clientes_inactivos', key_func=lambda self, dias: f"inactivos_{dias}", ttl=1800)
    def obtener_clientes_inactivos(self, dias_inactividad: int = 90) -> List[Dict]:
        """
        Obtiene clientes que no han comprado en X días.
        
        Args:
            dias_inactividad: Número de días sin compras.
            
        Returns:
            List[Dict]: Clientes inactivos.
        """
        try:
            fecha_limite = datetime.now().date() - timedelta(days=dias_inactividad)
            clientes = self.repo.obtener_inactivos_desde(fecha_limite)
            
            # Agregar días de inactividad si no viene calculado
            for cliente in clientes:
                if cliente.get('dias_inactividad') is None:
                    cliente['dias_inactividad'] = dias_inactividad
            
            logger.info(f"📊 {len(clientes)} clientes inactivos (>{dias_inactividad} días)")
            return clientes
            
        except Exception as e:
            logger.error(f"❌ Error al obtener clientes inactivos: {str(e)}")
            return []
    
    @cacheable('clientes_analisis', key_func=lambda self, limite: f"mejores_{limite}", ttl=1800)
    def obtener_mejores_clientes(self, limite: int = 10) -> List[Dict]:
        """
        Obtiene los N mejores clientes por volumen de compras.
        
        Args:
            limite: Número de clientes a retornar.
            
        Returns:
            List[Dict]: Top N clientes.
        """
        try:
            clientes = self.repo.obtener_con_estadisticas_ventas()
            
            # Ordenar por monto total descendente
            clientes_ordenados = sorted(
                clientes, 
                key=lambda x: x['monto_total'], 
                reverse=True
            )
            
            # Tomar solo los primeros N
            mejores = clientes_ordenados[:limite]
            
            # Agregar ranking
            for idx, cliente in enumerate(mejores, 1):
                cliente['ranking'] = idx
                cliente['categoria'] = self._clasificar_por_monto(cliente['monto_total'])
            
            logger.info(f"🏆 Top {limite} clientes obtenidos")
            return mejores
            
        except Exception as e:
            logger.error(f"❌ Error al obtener mejores clientes: {str(e)}")
            return []
    
    def calcular_estadisticas_cliente(self, id_cliente: int) -> Optional[Dict]:
        """
        Calcula estadísticas detalladas de un cliente.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            Dict con estadísticas o None.
        """
        try:
            # Obtener datos básicos del cliente
            cliente = self.repo.obtener_por_id(id_cliente)
            if not cliente:
                return None
            
            # Obtener estadísticas de ventas
            clientes_con_stats = self.repo.obtener_con_estadisticas_ventas()
            stats = next(
                (c for c in clientes_con_stats if c['id_cliente'] == id_cliente),
                None
            )
            
            if stats:
                stats['categoria'] = self._clasificar_por_monto(stats['monto_total'])
                
                # Calcular promedio por venta
                if stats['total_ventas'] > 0:
                    stats['promedio_venta'] = stats['monto_total'] / stats['total_ventas']
                else:
                    stats['promedio_venta'] = 0.0
                
                # Agregar datos del cliente
                stats.update(cliente)
                
                return stats
            
            return cliente
            
        except Exception as e:
            logger.error(f"❌ Error al calcular estadísticas: {str(e)}")
            return None
    
    # ==================== VALIDACIONES ====================
    
    def validar_datos_cliente(self, cliente_data: Dict) -> Tuple[bool, str]:
        """
        Valida los datos de un cliente antes de crear/actualizar.
        
        Args:
            cliente_data: Datos del cliente a validar.
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error)
        """
        # Validar nombre (obligatorio)
        if not cliente_data.get('nombre') or not cliente_data['nombre'].strip():
            return False, "El nombre del cliente es obligatorio"
        
        if len(cliente_data['nombre']) > 100:
            return False, "El nombre no puede exceder 100 caracteres"
        
        # Validar teléfono (opcional pero con formato si se proporciona)
        if cliente_data.get('telefono'):
            telefono = cliente_data['telefono'].strip()
            if len(telefono) > 20:
                return False, "El teléfono no puede exceder 20 caracteres"
        
        # Validar dirección (opcional)
        if cliente_data.get('direccion'):
            if len(cliente_data['direccion']) > 200:
                return False, "La dirección no puede exceder 200 caracteres"
        
        # Validar condiciones de pago (opcional)
        if cliente_data.get('condiciones_pago'):
            if len(cliente_data['condiciones_pago']) > 100:
                return False, "Las condiciones de pago no pueden exceder 100 caracteres"
        
        return True, "Datos válidos"
    
    def cliente_tiene_ventas(self, id_cliente: int) -> bool:
        """
        Verifica si un cliente tiene ventas asociadas.
        
        Args:
            id_cliente: ID del cliente.
            
        Returns:
            bool: True si tiene ventas.
        """
        return self.repo.verificar_tiene_ventas(id_cliente)
    
    # ==================== MÉTODOS AUXILIARES ====================
    
    def _calcular_percentil(self, valores: List[float], percentil: float) -> float:
        """
        Calcula un percentil específico para una lista de valores.
        
        Args:
            valores: Lista de valores numéricos ordenados.
            percentil: Percentil a calcular (0-100).
            
        Returns:
            float: Valor del percentil.
        """
        if not valores:
            return 0.0
        
        k = (len(valores) - 1) * percentil / 100
        f = int(k)
        c = f + 1 if k != f else f
        
        if f >= len(valores):
            return valores[-1]
        elif c >= len(valores):
            return valores[-1]
        else:
            return valores[f] + (valores[c] - valores[f]) * (k - f)
    
    def _clasificar_por_monto(self, monto_total: float) -> str:
        """
        Clasifica un cliente según su monto total de compras.
        
        Args:
            monto_total: Monto total de compras.
            
        Returns:
            str: Categoría del cliente.
        """
        if monto_total >= 100000:
            return 'Premium'
        elif monto_total >= 50000:
            return 'Gold'
        elif monto_total >= 20000:
            return 'Silver'
        elif monto_total >= 5000:
            return 'Regular'
        else:
            return 'Nuevo'


# Ejemplo de uso y testing
if __name__ == "__main__":
    try:
        service = ClienteService()
        
        # Obtener todos los clientes
        clientes = service.obtener_clientes()
        print(f"✅ Total de clientes: {len(clientes)}")
        
        # Clasificar clientes
        clasificados = service.clasificar_clientes_por_volumen()
        print(f"✅ Clientes clasificados: {len(clasificados)}")
        
        # Obtener mejores clientes
        mejores = service.obtener_mejores_clientes(5)
        print(f"🏆 Top 5 clientes:")
        for cliente in mejores:
            print(f"  {cliente['ranking']}. {cliente['nombre']} - ${cliente['monto_total']:,.2f} ({cliente['categoria']})")
        
    except Exception as e:
        print(f"❌ Error en prueba: {str(e)}")
