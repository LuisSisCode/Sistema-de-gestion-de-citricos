from PySide6.QtCore import QObject, Signal, Property, Slot, QTimer
from backend.core.database import DatabaseConnection
import logging
from datetime import datetime, timedelta
import hashlib

logger = logging.getLogger('DashboardModel')

class DashboardModel(QObject):
    """Modelo del Dashboard mejorado con consultas reales a la BD"""
    
    dataChanged = Signal()
    errorOccurred = Signal(str)
    loadingChanged = Signal(bool)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        try:
            self.db = DatabaseConnection()
            print("✅ DashboardModel inicializado con conexión a BD")
        except Exception as e:
            print(f"⚠️ DashboardModel inicializado SIN conexión a BD: {e}")
            self.db = None
        
        self._loading = False
        self._inicializar_propiedades()
    
    def _inicializar_propiedades(self):
        """Inicializa todas las propiedades con valores por defecto"""
        # KPIs Principales
        self._total_productores = 0
        self._total_parcelas = 0
        self._produccion_total = 0.0
        self._ventas_totales = 0.0
        
        # Métricas Operativas
        self._ciclos_activos = 0
        self._hectareas_cultivo = 0.0
        self._proximas_cosechas = 0
        self._total_empleados = 0
        self._maquinaria_operativa = 0
        self._total_maquinaria = 0
        
        # Recursos e Inventario
        self._productos_agroquimicos = 0
        self._total_clientes = 0
        self._gastos_mes = 0.0
        
        # Alertas
        self._alertas_cosechas = 0
        self._alertas_stock = 0
        self._alertas_mantenimiento = 0
        self._alertas_pagos = 0
        
        # Estadísticas Anuales
        self._produccion_anual = []
        self._ventas_anuales = []
        self._max_produccion_anual = 0
        self._max_ventas_anual = 0
        self._crecimiento_produccion = 0
        self._crecimiento_ventas = 0
        self._anos_operacion = 0
        
        # Datos para gráficas de variedades
        self._tendencia_produccion_variedades = []
        self._tendencia_ventas_variedades = []
        self._nombres_variedades = []
        self._colores_variedades = {}
        
        # Listas detalladas para el dashboard
        self._lista_productores = []
        self._lista_parcelas = []
        self._lista_ciclos = []
        self._lista_ventas = []
        self._lista_cosechas = []
        self._lista_alertas = []
        self._lista_produccion_cultivos = []
        
        # Datos para gráficos
        self._produccion_mensual = []
        self._ventas_mensuales = []
        self._gastos_mensuales = []
        
        # Datos para tablas
        self._ultimas_ventas = []
        self._proximos_mantenimientos = []
        self._colores_base = [
            "#4f46e5", "#0ea5e9", "#10b981", "#f59e0b", "#84cc16",
            "#f97316", "#ef4444", "#8b5cf6", "#ec4899", "#06b6d4",
            "#14b8a6", "#64748b", "#a855f7", "#22c55e", "#eab308",
            "#dc2626", "#6366f1", "#3b82f6", "#059669", "#d97706",
            "#7c3aed", "#0d9488", "#65a30d", "#ca8a04", "#ea580c",
            "#c026d3", "#db2777", "#4338ca", "#0369a1", "#0f766e"
        ]
        
    def _asignar_colores_unicos(self, variedades):
        """Asigna colores únicos a una lista de variedades"""
        colores_asignados = {}
        colores_disponibles = self._colores_base.copy()
        
        for i, variedad in enumerate(variedades):
            if i < len(colores_disponibles):
                color = colores_disponibles[i]
            else:
                # Generar color HSL único si se necesitan más colores
                hue = (i * 137) % 360  # 137 es un número primo para buena distribución
                color = f"hsl({hue}, 70%, 50%)"
            
            colores_asignados[variedad] = color
        
        return colores_asignados 
    # ============================================
    # PROPIEDADES PRINCIPALES
    # ============================================
    
    @Property(int, notify=dataChanged)
    def totalProductores(self):
        return self._total_productores
    
    @Property(int, notify=dataChanged)
    def totalParcelas(self):
        return self._total_parcelas
    
    @Property(float, notify=dataChanged)
    def produccionTotal(self):
        return self._produccion_total
    
    @Property(float, notify=dataChanged)
    def ventasTotales(self):
        return self._ventas_totales
    
    @Property(int, notify=dataChanged)
    def ciclosActivos(self):
        return self._ciclos_activos
    
    @Property(float, notify=dataChanged)
    def hectareasCultivo(self):
        return self._hectareas_cultivo
    
    @Property(int, notify=dataChanged)
    def proximasCosechas(self):
        return self._proximas_cosechas
    
    @Property(int, notify=dataChanged)
    def totalEmpleados(self):
        return self._total_empleados
    
    @Property(int, notify=dataChanged)
    def maquinariaOperativa(self):
        return self._maquinaria_operativa
    
    @Property(int, notify=dataChanged)
    def totalMaquinaria(self):
        return self._total_maquinaria
    
    @Property(int, notify=dataChanged)
    def productosAgroquimicos(self):
        return self._productos_agroquimicos
    
    @Property(int, notify=dataChanged)
    def totalClientes(self):
        return self._total_clientes
    
    @Property(float, notify=dataChanged)
    def gastosMes(self):
        return self._gastos_mes
    
    @Property(int, notify=dataChanged)
    def alertasCosechas(self):
        return self._alertas_cosechas
    
    @Property(int, notify=dataChanged)
    def alertasStock(self):
        return self._alertas_stock
    
    @Property(int, notify=dataChanged)
    def alertasMantenimiento(self):
        return self._alertas_mantenimiento
    
    @Property(int, notify=dataChanged)
    def alertasPagos(self):
        return self._alertas_pagos
    
    # ============================================
    # PROPIEDADES DE ESTADÍSTICAS ANUALES
    # ============================================
    
    @Property(list, notify=dataChanged)
    def produccionAnual(self):
        return self._produccion_anual
    
    @Property(list, notify=dataChanged)
    def ventasAnuales(self):
        return self._ventas_anuales
    
    @Property(float, notify=dataChanged)
    def maxProduccionAnual(self):
        return self._max_produccion_anual
    
    @Property(float, notify=dataChanged)
    def maxVentasAnual(self):
        return self._max_ventas_anual
    
    @Property(float, notify=dataChanged)
    def crecimientoProduccion(self):
        return self._crecimiento_produccion
    
    @Property(float, notify=dataChanged)
    def crecimientoVentas(self):
        return self._crecimiento_ventas
    
    @Property(int, notify=dataChanged)
    def anosOperacion(self):
        return self._anos_operacion
    
    # PROPIEDADES PARA GRÁFICAS DE VARIEDADES
    @Property(list, notify=dataChanged)
    def tendenciaProduccionVariedades(self):
        return self._tendencia_produccion_variedades
    
    @Property(list, notify=dataChanged)
    def tendenciaVentasVariedades(self):
        return self._tendencia_ventas_variedades
    
    @Property(list, notify=dataChanged)
    def nombresVariedades(self):
        return self._nombres_variedades
    
    @Property('QVariant', notify=dataChanged)
    def coloresVariedades(self):
        return self._colores_variedades
    
    @Property(bool, notify=loadingChanged)
    def loading(self):
        return self._loading
    
    # ============================================
    # PROPIEDADES DE LISTAS PARA EL DASHBOARD
    # ============================================
    
    @Property(list, notify=dataChanged)
    def listaProductores(self):
        return self._lista_productores
    
    @Property(list, notify=dataChanged)
    def listaParcelas(self):
        return self._lista_parcelas
    
    @Property(list, notify=dataChanged)
    def listaCiclos(self):
        return self._lista_ciclos
    
    @Property(list, notify=dataChanged)
    def listaVentas(self):
        return self._lista_ventas
    
    @Property(list, notify=dataChanged)
    def listaCosechas(self):
        return self._lista_cosechas
    
    @Property(list, notify=dataChanged)
    def listaAlertas(self):
        return self._lista_alertas
    
    @Property(list, notify=dataChanged)
    def listaProduccionCultivos(self):
        return self._lista_produccion_cultivos
    
    def _set_loading(self, value: bool):
        if self._loading != value:
            self._loading = value
            self.loadingChanged.emit(value)
    
    # ============================================
    # MÉTODOS DE CARGA DE DATOS
    # ============================================
    
    @Slot()
    def loadAllData(self):
        """Carga todos los datos del dashboard con manejo de errores"""
        print("🔄 [Dashboard] Iniciando carga de datos...")
        self._set_loading(True)
        
        if not self.db:
            print("❌ [Dashboard] Sin conexión a BD")
            self._set_loading(False)
            self.errorOccurred.emit("Sin conexión a base de datos")
            return
        
        try:
            QTimer.singleShot(100, self._cargarDatosEnBackground)
        except Exception as e:
            error_msg = f"Error iniciando carga: {str(e)}"
            logger.error(error_msg)
            self.errorOccurred.emit(error_msg)
            self._set_loading(False)
    
    def _cargarDatosEnBackground(self):
        """Carga datos en background para no bloquear la UI"""
        try:
            # Cargar todos los métodos necesarios
            self._load_kpis_principales_safe()
            self._load_metricas_operativas_safe()
            self._load_recursos_inventario_safe()
            self._load_alertas_safe()
            self._load_listas_detalladas_safe()
            self._load_produccion_por_cultivo_safe()
            self._load_estadisticas_anuales_safe()
            self._load_tendencias_variedades_safe()
            self._load_graficos_data_safe()
            self._load_tablas_data_safe()
            
            # Verificación final de datos
            print(f"📊 VERIFICACIÓN FINAL:")
            print(f"  - Producción series: {len(self._tendencia_produccion_variedades)}")
            print(f"  - Ventas series: {len(self._tendencia_ventas_variedades)}")
            
            if self._tendencia_produccion_variedades:
                primera = self._tendencia_produccion_variedades[0]
                print(f"  - Primera serie producción: {primera['variedad']}, {len(primera['datos'])} puntos, Color: {primera['color']}")
            
            if self._tendencia_ventas_variedades:
                primera = self._tendencia_ventas_variedades[0]
                print(f"  - Primera serie ventas: {primera['variedad']}, {len(primera['datos'])} puntos, Color: {primera['color']}")
            
            print("🔔 Emitiendo señal dataChanged...")
            self.dataChanged.emit()
            print("✅ [Dashboard] Datos cargados correctamente")
            
        except Exception as e:
            error_msg = f"Error cargando datos: {str(e)}"
            logger.error(error_msg)
            print(f"❌ {error_msg}")
            self.errorOccurred.emit(error_msg)
        finally:
            self._set_loading(False)
    
    def _execute_scalar_safe(self, query: str, params: tuple = (), default=0, descripcion=""):
        """Ejecuta consulta escalar con manejo de errores"""
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params)
                result = cursor.fetchone()
                if result and result[0] is not None:
                    return result[0]
                return default
        except Exception as e:
            print(f"⚠️ [Dashboard] Error en {descripcion}: {e}")
            return default
    
    def _execute_query_safe(self, query: str, params: tuple = (), descripcion=""):
        """Ejecuta consulta con manejo de errores"""
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params)
                return cursor.fetchall()
        except Exception as e:
            print(f"⚠️ [Dashboard] Error en {descripcion}: {e}")
            return []
    
    def _load_kpis_principales_safe(self):
        """Carga KPIs principales con consultas robustas"""
        print("  📊 Cargando KPIs principales...")
        
        # Total Productores
        query = "SELECT COUNT(*) FROM Productores WHERE activo = 1"
        self._total_productores = self._execute_scalar_safe(query, descripcion="productores activos")
        
        # Total Parcelas
        query = "SELECT COUNT(*) FROM Parcelas WHERE activo = 1"
        self._total_parcelas = self._execute_scalar_safe(query, descripcion="parcelas activas")
        
        # Producción Total - Último mes
        query = """
            SELECT ISNULL(SUM(lc.cantidad_cosechada), 0)
            FROM LotesCosecha lc
            WHERE lc.fecha_cosecha >= DATEADD(MONTH, -1, GETDATE())
                AND lc.activo = 1
        """
        result = self._execute_scalar_safe(query, default=0.0, descripcion="producción total")
        self._produccion_total = float(result) if result else 0.0
        
        # Ventas Totales - Último mes
        query = """
            SELECT ISNULL(SUM(total), 0)
            FROM Ventas 
            WHERE fecha_venta >= DATEADD(MONTH, -1, GETDATE())
        """
        result = self._execute_scalar_safe(query, default=0.0, descripcion="ventas totales")
        self._ventas_totales = float(result) if result else 0.0
        
        print(f"  ✅ KPIs: Productores={self._total_productores}, Parcelas={self._total_parcelas}, Producción={self._produccion_total:.1f} ton")
    
    def _load_metricas_operativas_safe(self):
        """Carga métricas operativas"""
        print("  ⚙️ Cargando métricas operativas...")
        
        # Ciclos Activos y Hectáreas
        query = """
            SELECT 
                COUNT(*) as ciclos,
                ISNULL(SUM(area_sembrada), 0) as hectareas
            FROM CiclosProduccion 
            WHERE estado IN ('Sembrado', 'En Desarrollo', 'En Cosecha', 'en produccion', 'en cosecha')
        """
        results = self._execute_query_safe(query, descripcion="ciclos activos")
        if results and len(results) > 0:
            self._ciclos_activos = results[0][0] or 0
            self._hectareas_cultivo = float(results[0][1]) if results[0][1] else 0.0
        
        # Próximas Cosechas (30 días) - CORREGIDO: Consulta simplificada y más robusta
        query = """
            SELECT COUNT(*) 
            FROM CiclosProduccion 
            WHERE fecha_cosecha_estimada BETWEEN GETDATE() AND DATEADD(day, 30, GETDATE())
                AND estado NOT IN ('Finalizado', 'Cancelado')
        """
        self._proximas_cosechas = self._execute_scalar_safe(query, descripcion="próximas cosechas")
        
        # Empleados activos
        query = "SELECT COUNT(*) FROM Empleados WHERE activo = 1"
        self._total_empleados = self._execute_scalar_safe(query, descripcion="empleados activos")
        
        # Maquinaria
        query = """
            SELECT 
                COUNT(*) as total,
                COUNT(CASE WHEN estado = 'operativo' THEN 1 END) as operativas
            FROM Maquinaria 
            WHERE activo = 1
        """
        results = self._execute_query_safe(query, descripcion="maquinaria")
        if results and len(results) > 0:
            self._total_maquinaria = results[0][0] or 0
            self._maquinaria_operativa = results[0][1] or 0
        
        print(f"  ✅ Métricas: Ciclos={self._ciclos_activos}, Hectáreas={self._hectareas_cultivo:.1f}, Próximas Cosechas={self._proximas_cosechas}")
    
    def _load_recursos_inventario_safe(self):
        """Carga recursos e inventario"""
        print("  📦 Cargando recursos...")
        
        # Productos agroquímicos distintos en stock
        query = """
            SELECT COUNT(DISTINCT id_producto)
            FROM LotesAgroquimicos
            WHERE cantidad_actual > 0 AND activo = 1
        """
        self._productos_agroquimicos = self._execute_scalar_safe(query, descripcion="agroquímicos en stock")
        
        # Clientes activos
        query = "SELECT COUNT(*) FROM Clientes WHERE activo = 1"
        self._total_clientes = self._execute_scalar_safe(query, descripcion="clientes activos")
        
        # Gastos del último mes
        query = """
            SELECT ISNULL(SUM(monto), 0)
            FROM Gastos 
            WHERE fecha_gasto >= DATEADD(MONTH, -1, GETDATE())
        """
        result = self._execute_scalar_safe(query, default=0.0, descripcion="gastos del mes")
        self._gastos_mes = float(result) if result else 0.0
        
        print(f"  ✅ Recursos: Clientes={self._total_clientes}, Agroquímicos={self._productos_agroquimicos}")
    
    def _load_alertas_safe(self):
        """Carga alertas del sistema"""
        print("  🔔 Cargando alertas...")
        
        # Alertas de Cosechas próximas (7 días)
        query = """
            SELECT COUNT(*)
            FROM CiclosProduccion
            WHERE fecha_cosecha_estimada BETWEEN GETDATE() 
                AND DATEADD(day, 7, GETDATE())
                AND estado NOT IN ('Finalizado', 'Cancelado')
        """
        self._alertas_cosechas = self._execute_scalar_safe(query, descripcion="alertas cosechas")
        
        # Alertas de Stock bajo
        query = """
            SELECT COUNT(*)
            FROM LotesAgroquimicos
            WHERE cantidad_actual <= 5 AND activo = 1
        """
        self._alertas_stock = self._execute_scalar_safe(query, descripcion="alertas stock")
        
        # Alertas de Mantenimiento
        query = """
            SELECT COUNT(DISTINCT m.id_maquinaria)
            FROM Maquinaria m
            LEFT JOIN Mantenimientos man ON m.id_maquinaria = man.id_maquinaria
            WHERE m.activo = 1
            GROUP BY m.id_maquinaria
            HAVING MAX(man.fecha_realizada) IS NULL 
                OR DATEDIFF(DAY, MAX(man.fecha_realizada), GETDATE()) > 60
        """
        self._alertas_mantenimiento = self._execute_scalar_safe(query, descripcion="alertas mantenimiento programado")
        
        # Alertas de Pagos vencidos
        query = """
            SELECT COUNT(*)
            FROM Ventas
            WHERE estado_pago = 'pendiente' 
                AND fecha_venta <= DATEADD(day, -30, GETDATE())
        """
        self._alertas_pagos = self._execute_scalar_safe(query, descripcion="alertas pagos")
        
        total_alertas = self._alertas_cosechas + self._alertas_stock + self._alertas_mantenimiento + self._alertas_pagos
        print(f"  ✅ Alertas: Total={total_alertas}")

    def _load_listas_detalladas_safe(self):
        """Carga listas detalladas para mostrar en el dashboard"""
        print("  📋 Cargando listas detalladas...")
        
        # Lista de Productores activos
        query = """
            SELECT nombre + ' ' + ISNULL(apellido, '')
            FROM Productores 
            WHERE activo = 1
            ORDER BY nombre
        """
        results = self._execute_query_safe(query, descripcion="lista productores")
        self._lista_productores = [row[0] for row in results] if results else []
        
        # Lista de Parcelas activas
        query = """
            SELECT nombre
            FROM Parcelas 
            WHERE activo = 1
            ORDER BY nombre
        """
        results = self._execute_query_safe(query, descripcion="lista parcelas")
        self._lista_parcelas = [row[0] for row in results] if results else []
        
        # Lista de Ciclos Activos con área
        query = """
            SELECT 
                'Ciclo ' + CAST(cp.id_ciclo as VARCHAR) + ' - ' + vc.nombre,
                CAST(cp.area_sembrada as VARCHAR) + ' Ha'
            FROM CiclosProduccion cp
            INNER JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
            WHERE cp.estado IN ('Sembrado', 'En Desarrollo', 'En Cosecha', 'en produccion', 'en cosecha')
            ORDER BY cp.fecha_siembra DESC
        """
        results = self._execute_query_safe(query, descripcion="lista ciclos")
        self._lista_ciclos = [{"name": row[0], "area": row[1]} for row in results] if results else []
        
        # Lista de Ventas recientes (último mes)
        query = """
            SELECT TOP 10
                'Venta ' + codigo_venta,
                'Bs ' + FORMAT(total, 'N2')
            FROM Ventas 
            WHERE fecha_venta >= DATEADD(MONTH, -1, GETDATE())
            ORDER BY fecha_venta DESC
        """
        results = self._execute_query_safe(query, descripcion="lista ventas")
        self._lista_ventas = [{"product": row[0], "amount": row[1]} for row in results] if results else []
        
        # CORRECCIÓN CRÍTICA: Lista de Próximas Cosechas - Consulta mejorada
        query = """
            SELECT 
                vc.nombre,
                FORMAT(cp.fecha_cosecha_estimada, 'dd/MM/yyyy') as fecha
            FROM CiclosProduccion cp
            INNER JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
            WHERE cp.fecha_cosecha_estimada BETWEEN GETDATE() AND DATEADD(day, 30, GETDATE())
                AND cp.estado NOT IN ('Finalizado', 'Cancelado')
            ORDER BY cp.fecha_cosecha_estimada ASC
        """
        results = self._execute_query_safe(query, descripcion="lista cosechas")
        self._lista_cosechas = [{"name": row[0], "quantity": row[1]} for row in results] if results else []
        
        # Log para debug de próximas cosechas
        print(f"  🔍 Próximas cosechas encontradas: {len(results)}")
        for i, row in enumerate(results):
            print(f"    🌱 {i+1}. {row[0]} - {row[1]}")
        
        # Lista de Alertas combinadas
        self._lista_alertas = self._generar_lista_alertas()
        
        print(f"  ✅ Listas: Productores={len(self._lista_productores)}, Parcelas={len(self._lista_parcelas)}, Cosechas={len(self._lista_cosechas)}")
    
    def _generar_lista_alertas(self):
        """Genera lista de mensajes de alerta combinados con detalles específicos"""
        alertas = []
        
        # Alertas de Cosechas con detalles
        if self._alertas_cosechas > 0:
            query = """
                SELECT TOP 3
                    vc.nombre + ' en ' + p.nombre,
                    FORMAT(cp.fecha_cosecha_estimada, 'dd/MM/yyyy')
                FROM CiclosProduccion cp
                INNER JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
                INNER JOIN Parcelas p ON cp.id_parcela = p.id_parcela
                WHERE cp.fecha_cosecha_estimada BETWEEN GETDATE() AND DATEADD(day, 7, GETDATE())
                    AND cp.estado NOT IN ('Finalizado', 'Cancelado')
                ORDER BY cp.fecha_cosecha_estimada ASC
            """
            results = self._execute_query_safe(query, descripcion="detalles cosechas próximas")
            for row in results:
                alertas.append(f"🌾 Cosecha {row[0]} - {row[1]}")
        
        # Alertas de Stock con detalles
        if self._alertas_stock > 0:
            query = """
                SELECT TOP 3
                    pa.nombre_comercial,
                    la.cantidad_actual
                FROM LotesAgroquimicos la
                INNER JOIN ProductosAgroquimicos pa ON la.id_producto = pa.id_producto
                WHERE la.cantidad_actual <= 5 AND la.activo = 1
                ORDER BY la.cantidad_actual ASC
            """
            results = self._execute_query_safe(query, descripcion="detalles stock bajo")
            for row in results:
                alertas.append(f"📦 Stock bajo {row[0]} - {row[1]} unidades")
        
        # Alertas de Mantenimiento
        if self._alertas_mantenimiento > 0:
            query = """
                SELECT TOP 3
                    m.nombre,
                    FORMAT(DATEADD(DAY, 30, MAX(man.fecha_realizada)), 'dd/MM/yyyy') as fecha_sugerida
                FROM Maquinaria m
                LEFT JOIN Mantenimientos man ON m.id_maquinaria = man.id_maquinaria
                WHERE m.activo = 1
                GROUP BY m.id_maquinaria, m.nombre
                HAVING MAX(man.fecha_realizada) IS NULL 
                    OR DATEDIFF(DAY, MAX(man.fecha_realizada), GETDATE()) > 60
                ORDER BY MAX(man.fecha_realizada) ASC
            """
            results = self._execute_query_safe(query, descripcion="detalles mantenimiento programado")
            for row in results:
                alertas.append(f"{row[0]} - {row[1]}")
                
        # Alertas de Pagos con detalles
        if self._alertas_pagos > 0:
            query = """
                SELECT TOP 3
                    codigo_venta,
                    FORMAT(fecha_venta, 'dd/MM/yyyy'),
                    total
                FROM Ventas
                WHERE estado_pago = 'pendiente' 
                    AND fecha_venta <= DATEADD(day, -30, GETDATE())
                ORDER BY fecha_venta ASC
            """
            results = self._execute_query_safe(query, descripcion="detalles pagos vencidos")
            for row in results:
                alertas.append(f"💰 Venta {row[0]} - Bs {float(row[2]):.2f} - {row[1]}")
        
        # Si no hay alertas, mostrar mensaje positivo
        if not alertas:
            alertas.append("✅ No hay alertas activas - Todo en orden")
        
        return alertas
        
    def _load_produccion_por_cultivo_safe(self):
        """Carga la producción desglosada por cultivo desde la base de datos"""
        print("  🌱 Cargando producción por cultivo...")
        
        query = """
            SELECT 
                vc.nombre as cultivo,
                ISNULL(SUM(lc.cantidad_cosechada), 0) as cantidad,
                COUNT(DISTINCT lc.id_lote) as lotes
            FROM LotesCosecha lc
            INNER JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
            INNER JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
            WHERE lc.fecha_cosecha >= DATEADD(MONTH, -1, GETDATE())
                AND lc.activo = 1
            GROUP BY vc.nombre
            ORDER BY cantidad DESC
        """
        
        results = self._execute_query_safe(query, descripcion="producción por cultivo")
        
        self._lista_produccion_cultivos = []
        
        if results:
            total_produccion = sum(float(row[1]) for row in results if row[1])
            
            if total_produccion > 0:
                for row in results:
                    cultivo = row[0] or "Cultivo Sin Nombre"
                    cantidad = float(row[1]) if row[1] else 0.0
                    lotes = row[2] or 0
                    
                    # Calcular porcentaje
                    porcentaje = (cantidad / total_produccion * 100) if total_produccion > 0 else 0.0
                    
                    # Generar colores únicos para cada cultivo
                    color1, color2 = self._generar_colores_para_cultivo(cultivo)
                    
                    self._lista_produccion_cultivos.append({
                        "cultivo": cultivo,
                        "cantidad": round(cantidad, 2),
                        "lotes": lotes,
                        "porcentaje": round(porcentaje, 1),
                        "color1": color1,
                        "color2": color2
                    })
                
                print(f"  ✅ Producción por cultivo: {len(self._lista_produccion_cultivos)} cultivos encontrados")
            else:
                print("  ℹ️ Total de producción es 0")
        else:
            print("  ℹ️ No se encontraron datos de producción por cultivo")
    
    def _generar_colores_para_cultivo(self, nombre_cultivo: str):
        """Genera colores consistentes basados en el hash del nombre del cultivo"""
        hash_obj = hashlib.md5(nombre_cultivo.encode('utf-8'))
        hash_int = int(hash_obj.hexdigest()[:8], 16)
        
        # Paleta de colores agrícolas
        colores_base = [
            ["#0ea5e9", "#06b6d4"],  # Azul
            ["#10b981", "#34d399"],  # Verde
            ["#f59e0b", "#fbbf24"],  # Amarillo
            ["#84cc16", "#a3e635"],  # Verde lima
            ["#f97316", "#fb923c"],  # Naranja
            ["#ef4444", "#f87171"],  # Rojo
            ["#8b5cf6", "#a78bfa"],  # Violeta
            ["#ec4899", "#f472b6"],  # Rosa
            ["#06b6d4", "#22d3ee"],  # Cian
            ["#14b8a6", "#2dd4bf"]   # Turquesa
        ]
        
        # Seleccionar color basado en el hash
        index = hash_int % len(colores_base)
        return colores_base[index]
    
    def _load_estadisticas_anuales_safe(self):
        """Carga estadísticas anuales para gráficas de tendencias"""
        print("  📈 Cargando estadísticas anuales...")
        
        # Producción anual (últimos 5 años)
        query = """
            SELECT 
                YEAR(lc.fecha_cosecha) as anio,
                ISNULL(SUM(lc.cantidad_cosechada), 0) as produccion_total
            FROM LotesCosecha lc
            WHERE lc.fecha_cosecha >= DATEADD(YEAR, -5, GETDATE())
                AND lc.activo = 1
            GROUP BY YEAR(lc.fecha_cosecha)
            ORDER BY anio
        """
        
        results = self._execute_query_safe(query, descripcion="producción anual")
        self._produccion_anual = []
        
        if results:
            for row in results:
                anio = row[0] or datetime.now().year
                produccion = float(row[1]) if row[1] else 0.0
                
                self._produccion_anual.append({
                    "anio": anio,
                    "total": round(produccion, 2)
                })
            
            # Calcular máximo para escalado de gráficas
            if self._produccion_anual:
                self._max_produccion_anual = max(item["total"] for item in self._produccion_anual)
                
                # Calcular crecimiento vs año anterior
                if len(self._produccion_anual) >= 2:
                    prod_actual = self._produccion_anual[-1]["total"]
                    prod_anterior = self._produccion_anual[-2]["total"]
                    if prod_anterior > 0:
                        self._crecimiento_produccion = round(((prod_actual - prod_anterior) / prod_anterior) * 100, 1)
                    else:
                        self._crecimiento_produccion = 100.0 if prod_actual > 0 else 0.0
                else:
                    self._crecimiento_produccion = 0.0
        
        # CORRECCIÓN CRÍTICA: Ventas anuales - Consulta simplificada y más robusta
        query = """
            SELECT 
                YEAR(fecha_venta) as anio,
                ISNULL(SUM(total), 0) as ventas_total
            FROM Ventas
            WHERE fecha_venta >= DATEADD(YEAR, -5, GETDATE())
            GROUP BY YEAR(fecha_venta)
            ORDER BY anio
        """
        
        results = self._execute_query_safe(query, descripcion="ventas anuales")
        self._ventas_anuales = []
        
        if results:
            for row in results:
                anio = row[0] or datetime.now().year
                ventas = float(row[1]) if row[1] else 0.0
                
                self._ventas_anuales.append({
                    "anio": anio,
                    "total": round(ventas, 2)
                })
            
            # Calcular máximo para escalado de gráficas
            if self._ventas_anuales:
                self._max_ventas_anual = max(item["total"] for item in self._ventas_anuales)
                
                # Calcular crecimiento vs año anterior
                if len(self._ventas_anuales) >= 2:
                    ventas_actual = self._ventas_anuales[-1]["total"]
                    ventas_anterior = self._ventas_anuales[-2]["total"]
                    if ventas_anterior > 0:
                        self._crecimiento_ventas = round(((ventas_actual - ventas_anterior) / ventas_anterior) * 100, 1)
                    else:
                        self._crecimiento_ventas = 100.0 if ventas_actual > 0 else 0.0
                else:
                    self._crecimiento_ventas = 0.0
        
        # Calcular años de operación
        if self._produccion_anual:
            self._anos_operacion = len(self._produccion_anual)
        elif self._ventas_anuales:
            self._anos_operacion = len(self._ventas_anuales)
        else:
            self._anos_operacion = 0
        
        print(f"  ✅ Estadísticas anuales: Producción={len(self._produccion_anual)} años, Ventas={len(self._ventas_anuales)} años")
    
    def _load_tendencias_variedades_safe(self):
        """Carga datos de tendencias por variedad para gráficas de líneas - VERSIÓN COMPLETAMENTE CORREGIDA"""
        print("  📈 Cargando tendencias por variedad...")
        
        # Obtener lista de variedades únicas
        query_variedades = """
            SELECT DISTINCT vc.id_variedad, vc.nombre
            FROM VariedadesCultivo vc
            WHERE vc.activo = 1
            ORDER BY vc.nombre
        """
        
        results_variedades = self._execute_query_safe(query_variedades, descripcion="todas las variedades activas")
        
        if not results_variedades:
            print("  ⚠️ No se encontraron variedades en la base de datos")
            self._nombres_variedades = []
            self._tendencia_produccion_variedades = []
            self._tendencia_ventas_variedades = []
            return
        
        self._nombres_variedades = [row[1] for row in results_variedades]
        print(f"  🔍 Encontradas {len(self._nombres_variedades)} variedades activas")
        
        # LIMPIAR diccionario de colores antes de generar nuevos
        self._colores_variedades = {}
        
        # PRIMERO: Generar todos los colores para todas las variedades
        for variedad in self._nombres_variedades:
            color = self._generar_color_para_variedad(variedad)
            self._colores_variedades[variedad] = color
        
        # Verificar que no hay colores duplicados
        colores_utilizados = list(self._colores_variedades.values())
        colores_unicos = set(colores_utilizados)
        
        if len(colores_utilizados) != len(colores_unicos):
            print("  ⚠️ ADVERTENCIA: Hay colores duplicados!")
            # Reasignar colores únicos
            for i, variedad in enumerate(self._nombres_variedades):
                if i < len(self._colores_base):
                    self._colores_variedades[variedad] = self._colores_base[i]
                else:
                    # Generar color alternativo si se necesitan más
                    self._colores_variedades[variedad] = f"hsl({(i * 137) % 360}, 70%, 50%)"
        
        # Inicializar listas de tendencias
        self._tendencia_produccion_variedades = []
        self._tendencia_ventas_variedades = []
        
        current_year = datetime.now().year
        
        # CARGAR DATOS REALES DE PRODUCCIÓN POR VARIEDAD
        print("  🎯 Cargando datos de producción por variedad...")
        for variedad in self._nombres_variedades:
            query_produccion = """
                SELECT 
                    YEAR(lc.fecha_cosecha) as anio,
                    ISNULL(SUM(lc.cantidad_cosechada), 0) as produccion_total
                FROM LotesCosecha lc
                INNER JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
                INNER JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
                WHERE vc.nombre = ?
                    AND lc.activo = 1
                    AND lc.fecha_cosecha IS NOT NULL
                GROUP BY YEAR(lc.fecha_cosecha)
                ORDER BY anio
            """
            
            results = self._execute_query_safe(query_produccion, (variedad,), descripcion=f"producción {variedad}")
            
            # USAR EL MISMO COLOR PARA AMBAS GRÁFICAS
            color_variedad = self._colores_variedades.get(variedad, "#64748b")
            
            datos_produccion = {
                "variedad": variedad,
                "color": color_variedad,  # MISMO COLOR QUE VENTAS
                "visible": True,
                "datos": []
            }
            
            if results and len(results) > 0:
                print(f"    ✅ {variedad}: {len(results)} años de producción - Color: {color_variedad}")
                for row in results:
                    anio = int(row[0]) if row[0] else current_year
                    produccion = float(row[1]) if row[1] else 0.0
                    
                    datos_produccion["datos"].append({
                        "anio": anio,
                        "valor": round(produccion, 2)
                    })
            else:
                # Crear datos vacíos para los últimos 3 años para mantener la estructura
                for year in range(current_year - 2, current_year + 1):
                    datos_produccion["datos"].append({
                        "anio": year,
                        "valor": 0.0
                    })
            
            self._tendencia_produccion_variedades.append(datos_produccion)
        
        # CARGAR DATOS REALES DE VENTAS POR VARIEDAD
        print("  🎯 Cargando datos de ventas por variedad...")
        for variedad in self._nombres_variedades:
            query_ventas = """
                SELECT 
                    YEAR(v.fecha_venta) as anio,
                    ISNULL(SUM(dv.subtotal), 0) as ventas_total
                FROM Ventas v
                INNER JOIN DetallesVenta dv ON v.id_venta = dv.id_venta
                INNER JOIN LotesCosecha lc ON dv.id_lote = lc.id_lote
                INNER JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
                INNER JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
                WHERE vc.nombre = ?
                    AND v.fecha_venta IS NOT NULL
                GROUP BY YEAR(v.fecha_venta)
                ORDER BY anio
            """
            
            results = self._execute_query_safe(query_ventas, (variedad,), descripcion=f"ventas {variedad}")
            
            # USAR EXACTAMENTE EL MISMO COLOR QUE EN PRODUCCIÓN
            color_variedad = self._colores_variedades.get(variedad, "#64748b")
            
            datos_ventas = {
                "variedad": variedad,
                "color": color_variedad,  # MISMO COLOR QUE PRODUCCIÓN
                "visible": True,
                "datos": []
            }
            
            if results and len(results) > 0:
                print(f"    ✅ {variedad}: {len(results)} años de ventas - Color: {color_variedad}")
                for row in results:
                    anio = int(row[0]) if row[0] else current_year
                    ventas = float(row[1]) if row[1] else 0.0
                    
                    datos_ventas["datos"].append({
                        "anio": anio,
                        "valor": round(ventas, 2)
                    })
            else:
                # Crear datos vacíos para los últimos 3 años
                for year in range(current_year - 2, current_year + 1):
                    datos_ventas["datos"].append({
                        "anio": year,
                        "valor": 0.0
                    })
            
            self._tendencia_ventas_variedades.append(datos_ventas)
        
        # VERIFICACIÓN FINAL DE CONSISTENCIA DE COLORES
        print("  🎨 VERIFICACIÓN FINAL DE COLORES:")
        for variedad in self._nombres_variedades:
            color_produccion = None
            color_ventas = None
            
            # Buscar color en producción
            for serie in self._tendencia_produccion_variedades:
                if serie["variedad"] == variedad:
                    color_produccion = serie["color"]
                    break
            
            # Buscar color en ventas
            for serie in self._tendencia_ventas_variedades:
                if serie["variedad"] == variedad:
                    color_ventas = serie["color"]
                    break
            
            if color_produccion and color_ventas and color_produccion == color_ventas:
                print(f"    ✅ '{variedad}': {color_produccion} ✓")
            else:
                print(f"    ❌ '{variedad}': Producción={color_produccion}, Ventas={color_ventas} ✗")
    
    def _generar_color_para_variedad(self, nombre_variedad: str):
        """Genera un color consistente y único basado en el nombre de la variedad - VERSIÓN CORREGIDA"""
        # Usar una semilla consistente basada en el nombre
        hash_obj = hashlib.md5(nombre_variedad.encode('utf-8'))
        hash_int = int(hash_obj.hexdigest()[:8], 16)
        
        # Paleta de colores ampliada y mejor distribuida
        colores = [
            "#4f46e5", "#0ea5e9", "#10b981", "#f59e0b", "#84cc16",
            "#f97316", "#ef4444", "#8b5cf6", "#ec4899", "#06b6d4",
            "#14b8a6", "#64748b", "#a855f7", "#22c55e", "#eab308",
            "#dc2626", "#6366f1", "#3b82f6", "#059669", "#d97706",
            "#7c3aed", "#0d9488", "#65a30d", "#ca8a04", "#ea580c",
            "#c026d3", "#db2777", "#4338ca", "#0369a1", "#0f766e"
        ]
        
        # Seleccionar color basado en el hash - MÉTODO MEJORADO
        index = hash_int % len(colores)
        
        # Verificar que no se repita el color para variedades diferentes
        color_seleccionado = colores[index]
        
        # Si el color ya está asignado a otra variedad, buscar el siguiente disponible
        if color_seleccionado in self._colores_variedades.values():
            # Buscar el primer color no utilizado
            for color in colores:
                if color not in self._colores_variedades.values():
                    color_seleccionado = color
                    break
        
        return color_seleccionado
    
    def _load_graficos_data_safe(self):
        """Carga datos para gráficos mensuales del dashboard"""
        print("  📊 Cargando datos de gráficos mensuales...")
        
        try:
            # Producción mensual (últimos 6 meses)
            query = """
                SELECT 
                    FORMAT(lc.fecha_cosecha, 'yyyy-MM') as mes,
                    ISNULL(SUM(lc.cantidad_cosechada), 0) as produccion
                FROM LotesCosecha lc
                WHERE lc.fecha_cosecha >= DATEADD(MONTH, -6, GETDATE())
                    AND lc.activo = 1
                GROUP BY FORMAT(lc.fecha_cosecha, 'yyyy-MM')
                ORDER BY mes
            """
            results = self._execute_query_safe(query, descripcion="producción mensual")
            
            self._produccion_mensual = []
            if results:
                for row in results:
                    self._produccion_mensual.append({
                        "mes": row[0],
                        "valor": float(row[1]) if row[1] else 0.0
                    })
                print(f"    ✅ Producción mensual: {len(self._produccion_mensual)} meses")
            else:
                print("    ℹ️ No hay datos de producción mensual")
            
            # Ventas mensuales (últimos 6 meses)
            query = """
                SELECT 
                    FORMAT(v.fecha_venta, 'yyyy-MM') as mes,
                    ISNULL(SUM(v.total), 0) as ventas
                FROM Ventas v
                WHERE v.fecha_venta >= DATEADD(MONTH, -6, GETDATE())
                GROUP BY FORMAT(v.fecha_venta, 'yyyy-MM')
                ORDER BY mes
            """
            results = self._execute_query_safe(query, descripcion="ventas mensuales")
            
            self._ventas_mensuales = []
            if results:
                for row in results:
                    self._ventas_mensuales.append({
                        "mes": row[0],
                        "valor": float(row[1]) if row[1] else 0.0
                    })
                print(f"    ✅ Ventas mensuales: {len(self._ventas_mensuales)} meses")
            else:
                print("    ℹ️ No hay datos de ventas mensuales")
            
            # Gastos mensuales (últimos 6 meses)
            query = """
                SELECT 
                    FORMAT(mf.fecha_movimiento, 'yyyy-MM') as mes,
                    ISNULL(SUM(mf.monto), 0) as gastos
                FROM MovimientosFinancieros mf
                WHERE mf.fecha_movimiento >= DATEADD(MONTH, -6, GETDATE())
                GROUP BY FORMAT(mf.fecha_movimiento, 'yyyy-MM')
                ORDER BY mes
            """
            results = self._execute_query_safe(query, descripcion="gastos mensuales")
            
            self._gastos_mensuales = []
            if results:
                for row in results:
                    self._gastos_mensuales.append({
                        "mes": row[0],
                        "valor": float(row[1]) if row[1] else 0.0
                    })
                print(f"    ✅ Gastos mensuales: {len(self._gastos_mensuales)} meses")
            else:
                print("    ℹ️ No hay datos de gastos mensuales")
                
        except Exception as e:
            print(f"⚠️ Error cargando datos de gráficos mensuales: {e}")
            self._produccion_mensual = []
            self._ventas_mensuales = []
            self._gastos_mensuales = []
    
    def _load_tablas_data_safe(self):
        """Carga datos para tablas del dashboard"""
        print("  📋 Cargando datos de tablas...")
        
        try:
            # Últimas ventas
            query = """
                SELECT TOP 5
                    v.codigo_venta,
                    c.nombre,
                    FORMAT(v.fecha_venta, 'dd/MM/yyyy') as fecha,
                    v.total,
                    v.estado_pago
                FROM Ventas v
                INNER JOIN Clientes c ON v.id_cliente = c.id_cliente
                ORDER BY v.fecha_venta DESC
            """
            results = self._execute_query_safe(query, descripcion="últimas ventas")
            
            self._ultimas_ventas = []
            if results:
                for row in results:
                    self._ultimas_ventas.append({
                        "codigo": row[0] or "",
                        "cliente": row[1] or "",
                        "fecha": row[2] or "",
                        "total": float(row[3]) if row[3] else 0.0,
                        "estado": row[4] or ""
                    })
                print(f"    ✅ Últimas ventas: {len(self._ultimas_ventas)} registros")
            else:
                print("    ℹ️ No hay datos de últimas ventas")
            
            # Próximos mantenimientos
            query = """
                SELECT TOP 5
                    m.codigo,
                    m.nombre,
                    m.tipo,
                    FORMAT(DATEADD(DAY, 30, MAX(man.fecha_realizada)), 'dd/MM/yyyy') as fecha,
                    CASE 
                        WHEN MAX(man.fecha_realizada) IS NULL THEN 'Nunca mantenido'
                        WHEN DATEDIFF(DAY, MAX(man.fecha_realizada), GETDATE()) > 60 THEN 'Urgente'
                        ELSE 'Programado'
                    END as estado
                FROM Maquinaria m
                LEFT JOIN Mantenimientos man ON m.id_maquinaria = man.id_maquinaria
                WHERE m.activo = 1
                GROUP BY m.id_maquinaria, m.codigo, m.nombre, m.tipo
                HAVING MAX(man.fecha_realizada) IS NOT NULL
                    AND DATEDIFF(DAY, MAX(man.fecha_realizada), GETDATE()) BETWEEN 30 AND 90
                ORDER BY MAX(man.fecha_realizada) ASC
            """
            results = self._execute_query_safe(query, descripcion="próximos mantenimientos")
            
            self._proximos_mantenimientos = []
            if results:
                for row in results:
                    self._proximos_mantenimientos.append({
                        "codigo": row[0] or "",
                        "nombre": row[1] or "",
                        "tipo": row[2] or "",
                        "fecha": row[3] or "",
                        "estado": row[4] or ""
                    })
                print(f"    ✅ Próximos mantenimientos: {len(self._proximos_mantenimientos)} registros")
                
                # Log detallado para debug
                for mantenimiento in self._proximos_mantenimientos:
                    print(f"      🔧 {mantenimiento['nombre']} - {mantenimiento['fecha']} - {mantenimiento['estado']}")
            else:
                print("    ℹ️ No hay mantenimientos programados en los próximos 30 días")
                    
        except Exception as e:
            print(f"⚠️ Error cargando datos de tablas: {e}")
            self._ultimas_ventas = []
            self._proximos_mantenimientos = []
        
    # ============================================
    # MÉTODOS PÚBLICOS
    # ============================================
    
    @Slot(result=list)
    def getProduccionMensual(self):
        """Retorna datos de producción mensual"""
        return self._produccion_mensual
    
    @Slot(result=list)
    def getVentasMensuales(self):
        """Retorna datos de ventas mensuales"""
        return self._ventas_mensuales
    
    @Slot(result=list)
    def getGastosMensuales(self):
        """Retorna datos de gastos mensuales"""
        return self._gastos_mensuales
    
    @Slot(result=list)
    def getUltimasVentas(self):
        """Retorna últimas ventas registradas"""
        return self._ultimas_ventas
    
    @Slot(result=list)
    def getProximosMantenimientos(self):
        """Retorna próximos mantenimientos programados"""
        return self._proximos_mantenimientos
    
    @Slot()
    def refresh(self):
        """Refresca todos los datos del dashboard"""
        print("🔄 [Dashboard] Refrescando datos...")
        self.loadAllData()
    
    @Slot(result=int)
    def getTotalAlertas(self):
        """Retorna el total de alertas activas"""
        return (self._alertas_cosechas + 
                self._alertas_stock + 
                self._alertas_mantenimiento + 
                self._alertas_pagos)
    
    @Slot(str, result=str)
    def getColorVariedad(self, nombre_variedad: str):
        """Retorna el color asignado a una variedad específica"""
        return self._colores_variedades.get(nombre_variedad, "#64748b")


def create_dashboard_model():
    """Factory function para crear instancia del modelo"""
    return DashboardModel()