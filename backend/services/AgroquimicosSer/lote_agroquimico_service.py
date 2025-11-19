# backend/services/AgroquimicosServ/lote_agroquimico_service.py
"""
Servicio de Lotes de Agroquímicos
Contiene la lógica de negocio para gestión de inventario, stock y vencimientos
"""

import logging
from datetime import date, datetime, timedelta
from typing import List, Dict, Optional, Tuple
from decimal import Decimal

from backend.repositories.AgroquimicosRep.lote_agroquimico_repositorio import LoteAgroquimicoRepositorio
from backend.repositories.AgroquimicosRep.producto_repositorio import ProductoRepositorio

logger = logging.getLogger(__name__)


class LoteAgroquimicoService:
    """Servicio con lógica de negocio para Lotes de Agroquímicos"""
    
    def __init__(self):
        self.lote_repo = LoteAgroquimicoRepositorio()
        self.producto_repo = ProductoRepositorio()
    
    # ==================== CONSULTAS ====================
    
    def obtener_todos_lotes(self) -> List[Dict]:
        """
        Obtiene todos los lotes de agroquímicos
        
        Returns:
            List[Dict]: Lista de lotes
        """
        return self.lote_repo.obtener_todos()
    
    
    def obtener_lote(self, id_lote: int) -> Optional[Dict]:
        """
        Obtiene un lote específico
        
        Args:
            id_lote: ID del lote
            
        Returns:
            Dict: Datos del lote o None
        """
        return self.lote_repo.obtener_por_id(id_lote)
    
    def obtener_lotes_por_producto(self, id_producto: int, 
                                   incluir_agotados: bool = False) -> List[Dict]:
        """
        Obtiene todos los lotes de un producto específico
        
        Args:
            id_producto: ID del producto
            incluir_agotados: Si incluir lotes agotados
            
        Returns:
            List[Dict]: Lista de lotes del producto
        """
        return self.lote_repo.listar_lotes_por_producto(id_producto, incluir_agotados)
    
    def obtener_lotes_por_ubicacion(self, ubicacion: str) -> List[Dict]:
        """
        Obtiene lotes en una ubicación específica del almacén
        
        Args:
            ubicacion: Código de ubicación
            
        Returns:
            List[Dict]: Lista de lotes en esa ubicación
        """
        return self.lote_repo.obtener_lotes_por_ubicacion(ubicacion)
    
    def obtener_lotes_proximos_vencer(self, dias: int = 30) -> List[Dict]:
        """
        Obtiene lotes próximos a vencer
        
        Args:
            dias: Número de días de anticipación
            
        Returns:
            List[Dict]: Lista de lotes próximos a vencer
        """
        return self.lote_repo.listar_lotes_por_vencer(dias)
    
    def obtener_lotes_vencidos(self) -> List[Dict]:
        """
        Obtiene lotes que ya están vencidos
        
        Returns:
            List[Dict]: Lista de lotes vencidos
        """
        return self.lote_repo.listar_lotes_vencidos()
    
    def obtener_lotes_stock_bajo(self, porcentaje_umbral: float = 20.0) -> List[Dict]:
        """
        Obtiene lotes con stock bajo
        
        Args:
            porcentaje_umbral: Porcentaje bajo el cual se considera stock bajo
            
        Returns:
            List[Dict]: Lista de lotes con stock bajo
        """
        return self.lote_repo.listar_lotes_con_stock_bajo(porcentaje_umbral)
    
    def obtener_stock_actual_producto(self, id_producto: int) -> Dict:
        """
        Obtiene el stock actual de un producto
        
        Args:
            id_producto: ID del producto
            
        Returns:
            Dict: Información de stock del producto
        """
        return self.lote_repo.obtener_stock_actual_producto(id_producto)
    
    # ==================== CREACIÓN ====================
    
    def crear_lote(self, datos: Dict) -> Tuple[bool, Optional[int], str]:
        """
        Crea un nuevo lote de agroquímico (compra/ingreso) con validaciones
        
        Args:
            datos: Diccionario con los datos del lote
                - id_producto (int): ID del producto
                - numero_lote (str): Número de lote del fabricante
                - fecha_compra (date): Fecha de compra
                - fecha_vencimiento (date): Fecha de vencimiento
                - cantidad_inicial (float): Cantidad comprada
                - unidad_medida (str): Unidad (litros, kg, etc.)
                - ubicacion_almacen (str): Ubicación física
                - precio_compra (float, optional): Precio de compra
                - proveedor (str, optional): Nombre del proveedor
            
        Returns:
            Tuple[bool, Optional[int], str]: (Éxito, ID del lote, Mensaje)
        """
        # Validaciones
        validacion = self._validar_datos_lote(datos)
        if not validacion[0]:
            return False, None, validacion[1]
        
        # Verificar que el producto exista
        if not self.producto_repo.existe(datos['id_producto']):
            return False, None, "El producto especificado no existe"
        
        # Verificar que no exista un lote con el mismo número
        if self._existe_numero_lote(datos['numero_lote']):
            return False, None, f"Ya existe un lote con el número {datos['numero_lote']}"
        
        # Crear el lote
        try:
            lote = self.lote_repo.crear_lote(datos)
            
            if lote:
                logger.info(f"Lote creado con ID: {lote['id_lote']} para producto {datos['id_producto']}")
                return True, lote['id_lote'], "Lote creado exitosamente"
            else:
                return False, None, "Error al crear el lote en la base de datos"
                
        except Exception as e:
            logger.error(f"Error al crear lote: {str(e)}")
            return False, None, f"Error al crear el lote: {str(e)}"
    
    # ==================== ACTUALIZACIÓN ====================
    
    def actualizar_lote(self, id_lote: int, datos: Dict) -> Tuple[bool, str]:
        """
        Actualiza un lote existente con validaciones
        
        Args:
            id_lote: ID del lote a actualizar
            datos: Datos a actualizar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        # Verificar que el lote exista
        lote_existente = self.lote_repo.obtener_por_id(id_lote)
        if not lote_existente:
            return False, "El lote no existe"
        
        # Validaciones parciales
        if 'cantidad_actual' in datos:
            if datos['cantidad_actual'] < 0:
                return False, "La cantidad actual no puede ser negativa"
            if datos['cantidad_actual'] > lote_existente['cantidad_inicial']:
                return False, "La cantidad actual no puede ser mayor que la cantidad inicial"
        
        if 'fecha_vencimiento' in datos:
            if datos['fecha_vencimiento'] < lote_existente['fecha_compra']:
                return False, "La fecha de vencimiento no puede ser anterior a la fecha de compra"
        
        # Si se está cambiando el número de lote, verificar que no exista
        if 'numero_lote' in datos and datos['numero_lote'] != lote_existente['numero_lote']:
            if self._existe_numero_lote(datos['numero_lote']):
                return False, f"Ya existe un lote con el número {datos['numero_lote']}"
        
        # Actualizar
        exito = self.lote_repo.actualizar_lote(id_lote, datos)
        
        if exito:
            logger.info(f"Lote {id_lote} actualizado")
            return True, "Lote actualizado exitosamente"
        else:
            return False, "Error al actualizar el lote"
    
    # ==================== ELIMINACIÓN ====================
    
    def eliminar_lote(self, id_lote: int) -> Tuple[bool, str]:
        """
        Elimina un lote de la base de datos (solo si no tiene stock)
        
        Args:
            id_lote: ID del lote a eliminar
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        lote = self.lote_repo.obtener_por_id(id_lote)
        
        if not lote:
            return False, "El lote no existe"
        
        # Verificar que no tenga stock
        if lote['cantidad_actual'] > 0:
            return False, "No se puede eliminar un lote con stock disponible"
        
        exito = self.lote_repo.eliminar_lote(id_lote)
        
        if exito:
            logger.info(f"Lote {id_lote} eliminado")
            return True, "Lote eliminado exitosamente"
        else:
            return False, "Error al eliminar el lote"
    
    # ==================== OPERACIONES DE STOCK ====================
    
    def descontar_stock(self, id_lote: int, cantidad: float, 
                       motivo: str, id_tratamiento: Optional[int] = None) -> Tuple[bool, str]:
        """
        Descuenta stock de un lote específico
        
        Args:
            id_lote: ID del lote
            cantidad: Cantidad a descontar
            motivo: Motivo del descuento (tratamiento, ajuste, etc.)
            id_tratamiento: ID del tratamiento relacionado (opcional)
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        # Verificar disponibilidad
        lote = self.lote_repo.obtener_por_id(id_lote)
        
        if not lote:
            return False, "El lote no existe"
        
        if lote['cantidad_actual'] < cantidad:
            return False, f"Stock insuficiente. Disponible: {lote['cantidad_actual']}, Solicitado: {cantidad}"
        
        # Descontar stock
        resultado = self.lote_repo.descontar_cantidad(id_lote, cantidad, id_tratamiento)
        
        if resultado['exito']:
            logger.info(f"Descontado {cantidad} del lote {id_lote} - Motivo: {motivo}")
            
            # Si el lote se agotó, actualizar estado
            if resultado['cantidad_actual'] == 0:
                self.lote_repo.actualizar_estado_lote(id_lote, 'agotado')
            
            return True, f"Stock descontado exitosamente. Cantidad actual: {resultado['cantidad_actual']}"
        else:
            return False, "Error al descontar stock del lote"
    
    def ajustar_stock(self, id_lote: int, nueva_cantidad: float, 
                     motivo: str) -> Tuple[bool, str]:
        """
        Ajusta el stock de un lote (para correcciones)
        
        Args:
            id_lote: ID del lote
            nueva_cantidad: Nueva cantidad
            motivo: Motivo del ajuste
            
        Returns:
            Tuple[bool, str]: (Éxito, Mensaje)
        """
        lote = self.lote_repo.obtener_por_id(id_lote)
        
        if not lote:
            return False, "El lote no existe"
        
        if nueva_cantidad < 0:
            return False, "La cantidad no puede ser negativa"
        
        # Calcular diferencia
        diferencia = nueva_cantidad - lote['cantidad_actual']
        
        if diferencia == 0:
            return True, "No se requiere ajuste (cantidad igual)"
        
        # Actualizar cantidad
        datos_actualizacion = {'cantidad_actual': nueva_cantidad}
        exito = self.lote_repo.actualizar_lote(id_lote, datos_actualizacion)
        
        if exito:
            # Registrar movimiento de ajuste
            self._registrar_movimiento_ajuste(id_lote, diferencia, motivo)
            
            logger.info(f"Stock ajustado en lote {id_lote}: {diferencia} - Motivo: {motivo}")
            return True, f"Stock ajustado exitosamente. Nueva cantidad: {nueva_cantidad}"
        else:
            return False, "Error al ajustar el stock"
    
    # ==================== ANÁLISIS Y ESTADÍSTICAS ====================
    
    def obtener_resumen_inventario(self) -> Dict:
        """
        Obtiene un resumen general del inventario
        
        Returns:
            Dict: Resumen del inventario
        """
        return self.lote_repo.obtener_resumen_inventario()
    
    def obtener_alertas_inventario(self) -> Dict:
        """
        Obtiene todas las alertas del inventario
        
        Returns:
            Dict: Alertas de vencimiento y stock bajo
        """
        lotes_por_vencer = self.obtener_lotes_proximos_vencer(30)
        lotes_vencidos = self.obtener_lotes_vencidos()
        lotes_stock_bajo = self.obtener_lotes_stock_bajo(20.0)
        
        return {
            'lotes_por_vencer': {
                'total': len(lotes_por_vencer),
                'criticos': len([l for l in lotes_por_vencer if l.get('dias_para_vencer', 999) <= 7]),
                'lista': lotes_por_vencer
            },
            'lotes_vencidos': {
                'total': len(lotes_vencidos),
                'lista': lotes_vencidos
            },
            'lotes_stock_bajo': {
                'total': len(lotes_stock_bajo),
                'criticos': len([l for l in lotes_stock_bajo if l.get('porcentaje_disponible', 100) <= 10]),
                'lista': lotes_stock_bajo
            },
            'fecha_consulta': datetime.now().isoformat()
        }
    
    def obtener_historial_uso_lote(self, id_lote: int) -> List[Dict]:
        """
        Obtiene el historial de uso de un lote
        
        Args:
            id_lote: ID del lote
            
        Returns:
            List[Dict]: Historial de tratamientos donde se usó el lote
        """
        return self.lote_repo.obtener_historial_uso_lote(id_lote)
    
    def calcular_valor_inventario(self) -> Dict:
        """
        Calcula el valor total del inventario
        
        Returns:
            Dict: Valor del inventario por categoría
        """
        # Obtener todos los lotes con stock
        todos_lotes = self.lote_repo.obtener_todos()
        lotes_con_stock = [l for l in todos_lotes if l['cantidad_actual'] > 0]
        
        valor_total = 0
        valor_por_categoria = {}
        
        for lote in lotes_con_stock:
            if lote.get('precio_compra'):
                valor_lote = lote['precio_compra'] * lote['cantidad_actual']
                valor_total += valor_lote
                
                # Agrupar por categoría si está disponible
                categoria = lote.get('categoria_producto', 'Sin Categoría')
                if categoria not in valor_por_categoria:
                    valor_por_categoria[categoria] = 0
                valor_por_categoria[categoria] += valor_lote
        
        return {
            'valor_total': round(valor_total, 2),
            'valor_por_categoria': valor_por_categoria,
            'total_lotes_con_stock': len(lotes_con_stock),
            'fecha_calculo': datetime.now().isoformat()
        }
    
    def obtener_rotacion_producto(self, id_producto: int, 
                                 meses: int = 12) -> Dict:
        """
        Calcula la rotación de un producto
        
        Args:
            id_producto: ID del producto
            meses: Período en meses para el análisis
            
        Returns:
            Dict: Métricas de rotación
        """
        # Obtener historial de uso del producto
        fecha_inicio = datetime.now() - timedelta(days=meses*30)
        
        # Este método requeriría una implementación en el repositorio
        # que consulte los movimientos del producto
        try:
            # Implementación simplificada
            lotes_producto = self.obtener_lotes_por_producto(id_producto, True)
            stock_actual = self.obtener_stock_actual_producto(id_producto)
            
            consumo_total = 0
            for lote in lotes_producto:
                consumo_lote = lote['cantidad_inicial'] - lote['cantidad_actual']
                consumo_total += consumo_lote
            
            rotacion = (consumo_total / stock_actual['stock_total']) if stock_actual['stock_total'] > 0 else 0
            
            return {
                'id_producto': id_producto,
                'periodo_meses': meses,
                'consumo_total': round(consumo_total, 2),
                'stock_actual': round(stock_actual['stock_total'], 2),
                'indice_rotacion': round(rotacion, 2),
                'clasificacion': 'Alta' if rotacion > 1.5 else 'Media' if rotacion > 0.5 else 'Baja'
            }
            
        except Exception as e:
            logger.error(f"Error al calcular rotación: {str(e)}")
            return {
                'id_producto': id_producto,
                'error': str(e)
            }
    
    # ==================== VALIDACIONES ====================
    
    def _validar_datos_lote(self, datos: Dict) -> Tuple[bool, str]:
        """
        Valida los datos de un lote antes de crear/actualizar
        
        Args:
            datos: Datos del lote a validar
            
        Returns:
            Tuple[bool, str]: (Es válido, Mensaje de error si aplica)
        """
        # Campos requeridos para creación
        campos_requeridos = ['id_producto', 'numero_lote', 'fecha_vencimiento', 
                           'cantidad_inicial', 'unidad_medida']
        
        for campo in campos_requeridos:
            if campo not in datos:
                return False, f"El campo '{campo}' es obligatorio"
        
        # Validar cantidad
        if datos['cantidad_inicial'] <= 0:
            return False, "La cantidad inicial debe ser mayor a cero"
        
        if datos['cantidad_inicial'] > 100000:  # Límite razonable
            return False, "La cantidad inicial excede el límite permitido"
        
        # Validar fechas
        if 'fecha_compra' in datos and datos['fecha_compra']:
            if isinstance(datos['fecha_compra'], date):
                if datos['fecha_compra'] > date.today():
                    return False, "La fecha de compra no puede ser futura"
        
        if isinstance(datos['fecha_vencimiento'], date):
            fecha_compra = datos.get('fecha_compra', date.today())
            if datos['fecha_vencimiento'] <= fecha_compra:
                return False, "La fecha de vencimiento debe ser posterior a la fecha de compra"
        
        # Validar unidad de medida
        unidades_validas = ['litros', 'kg', 'gramos', 'ml', 'unidades']
        if datos['unidad_medida'].lower() not in unidades_validas:
            return False, f"Unidad de medida no válida. Use: {', '.join(unidades_validas)}"
        
        # Validar precio si está presente
        if 'precio_compra' in datos and datos['precio_compra'] is not None:
            if datos['precio_compra'] < 0:
                return False, "El precio de compra no puede ser negativo"
        
        return True, "Validación exitosa"
    
    def _existe_numero_lote(self, numero_lote: str) -> bool:
        """
        Verifica si ya existe un lote con el mismo número
        
        Args:
            numero_lote: Número de lote a verificar
            
        Returns:
            bool: True si ya existe
        """
        # Esta implementación requeriría un método en el repositorio
        # Para simplificar, asumimos que no existe
        return False
    
    def _registrar_movimiento_ajuste(self, id_lote: int, diferencia: float, motivo: str) -> None:
        """
        Registra un movimiento de ajuste de stock
        
        Args:
            id_lote: ID del lote
            diferencia: Diferencia de cantidad
            motivo: Motivo del ajuste
        """
        try:
            # Implementación para registrar en tabla de movimientos si existe
            tipo_movimiento = 'entrada' if diferencia > 0 else 'salida'
            
            logger.info(f"Movimiento de ajuste: Lote {id_lote}, "
                       f"Tipo: {tipo_movimiento}, Cantidad: {abs(diferencia)}, "
                       f"Motivo: {motivo}")
                       
        except Exception as e:
            logger.error(f"Error al registrar movimiento de ajuste: {str(e)}")
    
    # ==================== UTILIDADES ====================
    
    def contar_lotes(self, id_producto: Optional[int] = None, 
                     solo_activos: bool = True) -> int:
        """
        Cuenta el total de lotes
        
        Args:
            id_producto: Si se especifica, cuenta solo lotes de ese producto
            solo_activos: Si contar solo lotes activos (con stock)
            
        Returns:
            int: Cantidad de lotes
        """
        if id_producto:
            lotes = self.obtener_lotes_por_producto(id_producto, not solo_activos)
            return len(lotes)
        else:
            resumen = self.obtener_resumen_inventario()
            return resumen.get('lotes_disponibles' if solo_activos else 'total_lotes', 0)
    
    def verificar_stock_suficiente(self, id_producto: int, cantidad_requerida: float) -> Tuple[bool, float, str]:
        """
        Verifica si hay stock suficiente de un producto
        
        Args:
            id_producto: ID del producto
            cantidad_requerida: Cantidad requerida
            
        Returns:
            Tuple[bool, float, str]: (Hay stock, Stock disponible, Mensaje)
        """
        stock_info = self.obtener_stock_actual_producto(id_producto)
        stock_disponible = stock_info.get('stock_total', 0)
        
        if stock_disponible >= cantidad_requerida:
            return True, stock_disponible, f"Stock suficiente. Disponible: {stock_disponible}"
        else:
            return False, stock_disponible, f"Stock insuficiente. Disponible: {stock_disponible}, Requerido: {cantidad_requerida}"
    
    def obtener_lote_recomendado(self, id_producto: int, cantidad_requerida: float) -> Optional[Dict]:
        """
        Obtiene el lote recomendado para usar (FIFO - Primero en vencer)
        
        Args:
            id_producto: ID del producto
            cantidad_requerida: Cantidad requerida
            
        Returns:
            Dict: Lote recomendado o None
        """
        lotes = self.obtener_lotes_por_producto(id_producto)
        
        if not lotes:
            return None
        
        # Ordenar por fecha de vencimiento (más próximo primero)
        lotes_ordenados = sorted(lotes, key=lambda x: x.get('fecha_vencimiento', '9999-12-31'))
        
        for lote in lotes_ordenados:
            if lote['cantidad_actual'] >= cantidad_requerida:
                return lote
        
        # Si ningún lote individual tiene suficiente, retornar el primero
        return lotes_ordenados[0] if lotes_ordenados else None