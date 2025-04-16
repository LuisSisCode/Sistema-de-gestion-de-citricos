 """ Ejemplo mínimo de cómo sería la conexión a base de datos SQL Server
    // (este código es solo ilustrativo y se debe implementar en el archivo Python)
    // En tu archivo Python principal:"""
    
    import pyodbc
    from PySide2.QtCore import QObject, Slot, Signal, Property
    
    class DatabaseConnection(QObject):
        # Señales para actualizar modelos
        ventasModelChanged = Signal()
        clientesModelChanged = Signal()
        
        def __init__(self):
            super().__init__()
            self._ventas = []
            self._clientes = []
            self.connect_to_database()
            
        def connect_to_database(self):
            try:
                # Configura tu cadena de conexión
                conn_str = (
                    "DRIVER={ODBC Driver 17 for SQL Server};"
                    "SERVER=your_server;"
                    "DATABASE=citricos_db;"
                    "UID=your_username;"
                    "PWD=your_password"
                )
                self.conn = pyodbc.connect(conn_str)
                self.cursor = self.conn.cursor()
                print("Conexión exitosa a SQL Server")
                
                # Cargar datos iniciales
                self.load_ventas()
                self.load_clientes()
                
            except Exception as e:
                print(f"Error de conexión: {e}")
                
        def load_ventas(self):
            try:
                self.cursor.execute("SELECT * FROM Ventas")
                rows = self.cursor.fetchall()
                
                ventas = []
                for row in rows:
                    venta = {
                        "ventaId": row[0],
                        "codigo": row[1],
                        "fecha": row[2],
                        "cliente": row[3],
                        "total": row[4],
                        "estado": row[5]
                    }
                    ventas.append(venta)
                    
                self._ventas = ventas
                self.ventasModelChanged.emit()
                
            except Exception as e:
                print(f"Error al cargar ventas: {e}")
                
        def load_clientes(self):
            try:
                self.cursor.execute("SELECT * FROM Clientes")
                rows = self.cursor.fetchall()
                
                clientes = []
                for row in rows:
                    cliente = {
                        "clienteId": row[0],
                        "tipo": row[1],
                        "nombre": row[2],
                        "identificacion": row[3],
                        "telefono": row[4],
                        "ciudad": row[5],
                        "totalCompras": row[6],
                        "pendiente": row[7]
                    }
                    clientes.append(cliente)
                    
                self._clientes = clientes
                self.clientesModelChanged.emit()
                
            except Exception as e:
                print(f"Error al cargar clientes: {e}")
                
        @Slot(str, str, str, float, str)
        def insert_venta(self, codigo, fecha, cliente, total, estado):
            try:
                query = "INSERT INTO Ventas (codigo, fecha, cliente, total, estado) VALUES (?, ?, ?, ?, ?)"
                self.cursor.execute(query, (codigo, fecha, cliente, total, estado))
                self.conn.commit()
                
                # Recargar ventas
                self.load_ventas()
                
                return True
            except Exception as e:
                print(f"Error al insertar venta: {e}")
                return False
                
        @Slot(str, str, str, str, str, float, float)
        def insert_cliente(self, tipo, nombre, identificacion, telefono, ciudad, totalCompras, pendiente):
            try:
                query = "INSERT INTO Clientes (tipo, nombre, identificacion, telefono, ciudad, totalCompras, pendiente) VALUES (?, ?, ?, ?, ?, ?, ?)"
                self.cursor.execute(query, (tipo, nombre, identificacion, telefono, ciudad, totalCompras, pendiente))
                self.conn.commit()
                
                # Recargar clientes
                self.load_clientes()
                
                return True
            except Exception as e:
                print(f"Error al insertar cliente: {e}")
                return False
                
        @Property(list, notify=ventasModelChanged)
        def ventas(self):
            return self._ventas
            
        @Property(list, notify=clientesModelChanged)
        def clientes(self):
            return self._clientes
    
    # En tu archivo principal:
    db_connection = DatabaseConnection()
    engine.rootContext().setContextProperty("dbConnection", db_connection)
    
}