
//USE PRODUCCION_CITRICOS;

-- 1. Gesti�n de Usuarios y Roles
CREATE TABLE Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    fecha_creacion DATETIME NOT NULL,
    activo BIT NOT NULL DEFAULT 1
);
CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    id_rol INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    direccion VARCHAR(200) NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    fecha_creacion DATETIME NOT NULL,
    ultimo_acceso DATETIME NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
);
-- 2. Gesti�n de Agricultores
CREATE TABLE Agricultores (
    id_agricultor INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    identificacion VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(100) NULL,
    direccion VARCHAR(200) NULL,
    fecha_registro DATE NOT NULL,
    es_propietario BIT NOT NULL DEFAULT 0,
    notas TEXT NULL,
    activo BIT NOT NULL DEFAULT 1
);

-- 3. Gesti�n de Parcelas
CREATE TABLE Parcelas (
    id_parcela INT IDENTITY(1,1) PRIMARY KEY,
    id_agricultor INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(200) NOT NULL,
    area_total DECIMAL(10,2) NOT NULL,
    coordenadas_gps VARCHAR(100) NULL,
    tipo_suelo VARCHAR(50) NULL,
    fuente_agua VARCHAR(100) NULL,
    fecha_adquisicion DATE NULL,
    precio_adquisicion DECIMAL(12,2) NULL,
    notas TEXT NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Parcelas_Agricultores FOREIGN KEY (id_agricultor) REFERENCES Agricultores(id_agricultor)
);

-- 4. Gesti�n de Tipos de Cultivo
CREATE TABLE TiposCultivo (
    id_tipo_cultivo INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    nombre_cientifico VARCHAR(100) NULL,
    descripcion TEXT NULL,
    tiempo_cosecha_min INT NULL,
    tiempo_cosecha_max INT NULL,
    activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE VariedadesCultivo (
    id_variedad INT IDENTITY(1,1) PRIMARY KEY,
    id_tipo_cultivo INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT NULL,
    caracteristicas TEXT NULL,
    tiempo_produccion INT NULL,
    rendimiento_esperado DECIMAL(10,2) NULL,
    resistencia_enfermedades VARCHAR(100) NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_VariedadesCultivo_TiposCultivo FOREIGN KEY (id_tipo_cultivo) REFERENCES TiposCultivo(id_tipo_cultivo)
);
-- 5. Gesti�n de Ciclos de Producci�n
CREATE TABLE CiclosProduccion (
    id_ciclo INT IDENTITY(1,1) PRIMARY KEY,
    id_parcela INT NOT NULL,
    id_variedad INT NOT NULL,
    nombre_ciclo VARCHAR(100) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_siembra DATE NULL,
    fecha_cosecha_estimada DATE NULL,
    fecha_cosecha_real DATE NULL,
    area_sembrada DECIMAL(10,2) NOT NULL,
    densidad_siembra INT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('Planificado', 'En Preparaci�n', 'Sembrado', 'En Desarrollo', 'En Cosecha', 'Finalizado', 'Cancelado')),
    notas TEXT NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_CiclosProduccion_Parcelas FOREIGN KEY (id_parcela) REFERENCES Parcelas(id_parcela),
    CONSTRAINT FK_CiclosProduccion_VariedadesCultivo FOREIGN KEY (id_variedad) REFERENCES VariedadesCultivo(id_variedad)
);

-- 6. Gesti�n de Productos Agroqu�micos
CREATE TABLE CategoriaAgroquimicos (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE ProductosAgroquimicos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    id_categoria INT NOT NULL,
    nombre_comercial VARCHAR(100) NOT NULL,
    fabricante VARCHAR(100) NULL,
    ingrediente_activo VARCHAR(100) NOT NULL,
    concentracion VARCHAR(50) NOT NULL,
    formulacion VARCHAR(50) NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    registro_oficial VARCHAR(50) NULL,
    periodo_reingreso INT NULL,
    periodo_carencia INT NULL,
    precio_unitario DECIMAL(10,2) NULL,
    stock_actual DECIMAL(10,2) DEFAULT 0,
    fecha_registro DATE NOT NULL,
    notas TEXT NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_ProductosAgroquimicos_CategoriaAgroquimicos FOREIGN KEY (id_categoria) REFERENCES CategoriaAgroquimicos(id_categoria)
);

-- 7. Gesti�n de Mezclas de Agroqu�micos
CREATE TABLE MezclasAgroquimicos (
    id_mezcla INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NULL,
    cantidad_agua DECIMAL(10,2) NULL,
    area_aplicacion DECIMAL(10,2) NULL,
    objetivo VARCHAR(100) NULL,
    indicaciones TEXT NULL,
    fecha_creacion DATE NOT NULL,
    creado_por INT NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_MezclasAgroquimicos_Usuarios FOREIGN KEY (creado_por) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE DetallesMezcla (
    id_detalle_mezcla INT IDENTITY(1,1) PRIMARY KEY,
    id_mezcla INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT FK_DetallesMezcla_MezclasAgroquimicos FOREIGN KEY (id_mezcla) REFERENCES MezclasAgroquimicos(id_mezcla),
    CONSTRAINT FK_DetallesMezcla_ProductosAgroquimicos FOREIGN KEY (id_producto) REFERENCES ProductosAgroquimicos(id_producto)
);

-- 8. Control de Malezas y Plagas (Tratamientos Fitosanitarios)
CREATE TABLE TiposPlagasMalezas (
    id_tipo INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    categoria VARCHAR(20) NOT NULL CHECK (categoria IN ('Plaga', 'Maleza', 'Enfermedad')),
    activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE TratamientosFitosanitarios (
    id_tratamiento INT IDENTITY(1,1) PRIMARY KEY,
    id_ciclo INT NOT NULL,
    id_tipo_plaga INT NULL,
    fecha_aplicacion DATE NOT NULL,
    area_tratada DECIMAL(10,2) NOT NULL,
    metodo_aplicacion VARCHAR(100) NULL,
    condiciones_climaticas VARCHAR(100) NULL,
    id_mezcla INT NULL,
    cantidad_agua DECIMAL(10,2) NULL,
    costo_total DECIMAL(10,2) NULL,
    realizado_por INT NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT FK_TratamientosFitosanitarios_CiclosProduccion FOREIGN KEY (id_ciclo) REFERENCES CiclosProduccion(id_ciclo),
    CONSTRAINT FK_TratamientosFitosanitarios_TiposPlagasMalezas FOREIGN KEY (id_tipo_plaga) REFERENCES TiposPlagasMalezas(id_tipo),
    CONSTRAINT FK_TratamientosFitosanitarios_MezclasAgroquimicos FOREIGN KEY (id_mezcla) REFERENCES MezclasAgroquimicos(id_mezcla),
    CONSTRAINT FK_TratamientosFitosanitarios_Usuarios FOREIGN KEY (realizado_por) REFERENCES Usuarios(id_usuario)
);

-- 9. Gesti�n de Costos de Producci�n
CREATE TABLE CategoriasCostos (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE CostosProduccion (
    id_costo INT IDENTITY(1,1) PRIMARY KEY,
    id_ciclo INT NOT NULL,
    id_categoria INT NOT NULL,
    id_tratamiento INT NULL,
    concepto VARCHAR(200) NOT NULL,
    fecha DATE NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    unidad_medida VARCHAR(20) NULL,
    costo_unitario DECIMAL(10,2) NOT NULL,
    costo_total DECIMAL(10,2) NOT NULL,
    comprobante VARCHAR(100) NULL,
    registrado_por INT NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT FK_CostosProduccion_CiclosProduccion FOREIGN KEY (id_ciclo) REFERENCES CiclosProduccion(id_ciclo),
    CONSTRAINT FK_CostosProduccion_CategoriasCostos FOREIGN KEY (id_categoria) REFERENCES CategoriasCostos(id_categoria),
    CONSTRAINT FK_CostosProduccion_TratamientosFitosanitarios FOREIGN KEY (id_tratamiento) REFERENCES TratamientosFitosanitarios(id_tratamiento),
    CONSTRAINT FK_CostosProduccion_Usuarios FOREIGN KEY (registrado_por) REFERENCES Usuarios(id_usuario)
);

-- 11. Gesti�n de Pagos
CREATE TABLE MetodosPago (
    id_metodo INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    activo BIT NOT NULL DEFAULT 1
);

-- 12. Gesti�n de Producci�n (Lotes de Cosecha)
CREATE TABLE CategoriasCalidad (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    criterios TEXT NULL,
    activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE LotesCosecha (
    id_lote INT IDENTITY(1,1) PRIMARY KEY,
    id_ciclo INT NOT NULL,
    id_categoria_calidad INT NOT NULL,
    codigo_lote VARCHAR(20) NOT NULL UNIQUE,
    fecha_cosecha DATE NOT NULL,
    cantidad_inicial DECIMAL(10,2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    cantidad_disponible DECIMAL(10,2) NOT NULL,
    precio_unitario_sugerido DECIMAL(10,2) NULL,
    costo_produccion_unitario DECIMAL(10,2) NULL,
    fecha_vencimiento DATE NULL,
    ubicacion_almacenamiento VARCHAR(100) NULL,
    registrado_por INT NOT NULL,
    observaciones TEXT NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_LotesCosecha_CiclosProduccion FOREIGN KEY (id_ciclo) REFERENCES CiclosProduccion(id_ciclo),
    CONSTRAINT FK_LotesCosecha_CategoriasCalidad FOREIGN KEY (id_categoria_calidad) REFERENCES CategoriasCalidad(id_categoria),
    CONSTRAINT FK_LotesCosecha_Usuarios FOREIGN KEY (registrado_por) REFERENCES Usuarios(id_usuario)
);

-- 13. Gesti�n de Clientes
CREATE TABLE Clientes (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('Persona', 'Empresa')),
    nombre VARCHAR(100) NOT NULL,
    identificacion VARCHAR(20) NOT NULL UNIQUE,
    direccion VARCHAR(200) NULL,
    ciudad VARCHAR(100) NULL,
    estado_provincia VARCHAR(100) NULL,
    codigo_postal VARCHAR(20) NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(100) NULL,
    contacto_principal VARCHAR(100) NULL,
    telefono_contacto VARCHAR(20) NULL,
    condiciones_pago VARCHAR(100) NULL,
    limite_credito DECIMAL(12,2) NULL,
    notas TEXT NULL,
    fecha_registro DATE NOT NULL,
    registrado_por INT NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Clientes_Usuarios FOREIGN KEY (registrado_por) REFERENCES Usuarios(id_usuario)
);

-- 14. Gesti�n de Ventas
CREATE TABLE EstadosVenta (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE Ventas (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    codigo_venta VARCHAR(20) NOT NULL UNIQUE,
    fecha_venta DATE NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    impuestos DECIMAL(12,2) NOT NULL,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0,
    total DECIMAL(12,2) NOT NULL,
    condiciones_pago VARCHAR(100) NULL,
    fecha_entrega DATE NULL,
    lugar_entrega VARCHAR(200) NULL,
    id_estado INT NOT NULL,
    estado_pago VARCHAR(10) NOT NULL DEFAULT 'Pendiente' CHECK (estado_pago IN ('Pendiente', 'Parcial', 'Pagado')),
    registrado_por INT NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT FK_Ventas_Clientes FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    CONSTRAINT FK_Ventas_EstadosVenta FOREIGN KEY (id_estado) REFERENCES EstadosVenta(id_estado),
    CONSTRAINT FK_Ventas_Usuarios FOREIGN KEY (registrado_por) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE DetallesVenta (
    id_detalle_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT NOT NULL,
    id_lote INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    impuesto DECIMAL(12,2) NULL,
    descuento DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT FK_DetallesVenta_Ventas FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    CONSTRAINT FK_DetallesVenta_LotesCosecha FOREIGN KEY (id_lote) REFERENCES LotesCosecha(id_lote)
);

-- Ahora que tenemos la tabla Ventas creada, podemos definir la tabla Pagos con la referencia
CREATE TABLE Pagos (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT NULL,
    id_agricultor INT NOT NULL,
    id_metodo INT NOT NULL,
    fecha_pago DATE NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    concepto VARCHAR(200) NOT NULL,
    referencia VARCHAR(100) NULL,
    estado VARCHAR(10) NOT NULL DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Confirmado', 'Rechazado')),
    recibido_por INT NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT FK_Pagos_Ventas FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    CONSTRAINT FK_Pagos_Agricultores FOREIGN KEY (id_agricultor) REFERENCES Agricultores(id_agricultor),
    CONSTRAINT FK_Pagos_MetodosPago FOREIGN KEY (id_metodo) REFERENCES MetodosPago(id_metodo),
    CONSTRAINT FK_Pagos_Usuarios FOREIGN KEY (recibido_por) REFERENCES Usuarios(id_usuario)
);

-- 15. Gesti�n de herramientas y combustible
CREATE TABLE Maquinaria (
    id_maquinaria INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    tipo_combustible VARCHAR(50) NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('Operativo', 'En mantenimiento', 'Fuera de servicio')),
    ubicacion_actual VARCHAR(100) NULL,
    activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE UsoMaquinaria (
    id_uso INT IDENTITY(1,1) PRIMARY KEY,
    id_maquinaria INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    actividad_realizada VARCHAR(200) NOT NULL,
    parcela VARCHAR(100) NULL,
    combustible_consumido DECIMAL(10,2) NULL,
    CONSTRAINT FK_UsoMaquinaria_Maquinaria FOREIGN KEY (id_maquinaria) REFERENCES Maquinaria(id_maquinaria),
    CONSTRAINT FK_UsoMaquinaria_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Mantenimientos (
    id_mantenimiento INT IDENTITY(1,1) PRIMARY KEY,
    id_maquinaria INT NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Preventivo', 'Correctivo')),
    fecha_realizada DATE NULL,
    descripcion TEXT NOT NULL,
    costo_total DECIMAL(10,2) NOT NULL,
    responsable INT NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('Programado', 'Completado')),
    CONSTRAINT FK_Mantenimientos_Maquinaria FOREIGN KEY (id_maquinaria) REFERENCES Maquinaria(id_maquinaria),
    CONSTRAINT FK_Mantenimientos_Usuarios FOREIGN KEY (responsable) REFERENCES Usuarios(id_usuario)
);
CREATE TABLE ComprasCombustible (
    id_compra INT IDENTITY(1,1) PRIMARY KEY,
    tipo_combustible VARCHAR(50) NOT NULL,
    fecha_compra DATE NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    precio_total DECIMAL(10,2) NOT NULL,
    proveedor VARCHAR(100) NULL,
    responsable INT NOT NULL,
    observaciones TEXT NULL,
    CONSTRAINT FK_ComprasCombustible_Usuarios FOREIGN KEY (responsable) REFERENCES Usuarios(id_usuario)
);
-- Creaci�n de �ndices para optimizar consultas frecuentes
CREATE INDEX IX_Parcelas_IdAgricultor ON Parcelas(id_agricultor);
CREATE INDEX IX_CiclosProduccion_IdParcela ON CiclosProduccion(id_parcela);
CREATE INDEX IX_CiclosProduccion_IdVariedad ON CiclosProduccion(id_variedad);
CREATE INDEX IX_CiclosProduccion_FechaInicio ON CiclosProduccion(fecha_inicio);
CREATE INDEX IX_TratamientosFitosanitarios_IdCiclo ON TratamientosFitosanitarios(id_ciclo);
CREATE INDEX IX_TratamientosFitosanitarios_FechaAplicacion ON TratamientosFitosanitarios(fecha_aplicacion);
CREATE INDEX IX_LotesCosecha_IdCiclo ON LotesCosecha(id_ciclo);
CREATE INDEX IX_LotesCosecha_FechaCosecha ON LotesCosecha(fecha_cosecha);
CREATE INDEX IX_Ventas_IdCliente ON Ventas(id_cliente);
CREATE INDEX IX_Ventas_FechaVenta ON Ventas(fecha_venta);
CREATE INDEX IX_Pagos_IdVenta ON Pagos(id_venta);
CREATE INDEX IX_Pagos_IdAgricultor ON Pagos(id_agricultor);
CREATE INDEX IX_Pagos_FechaPago ON Pagos(fecha_pago);
CREATE INDEX IX_UsoMaquinaria_IdMaquinaria ON UsoMaquinaria(id_maquinaria);
CREATE INDEX IX_Mantenimientos_IdMaquinaria ON Mantenimientos(id_maquinaria);

-- Insertar datos iniciales para tablas b�sicas
INSERT INTO Roles (nombre_rol, descripcion, fecha_creacion, activo) 
VALUES ('Administrador', 'Control total del sistema', GETDATE(), 1);

INSERT INTO Roles (nombre_rol, descripcion, fecha_creacion, activo) 
VALUES ('Empleado', 'Acceso limitado a funciones operativas', GETDATE(), 1);
INSERT INTO Roles (nombre_rol, descripcion, fecha_creacion, activo) 
VALUES ('Empleado2', 'Acceso limitado a funciones operativas', GETDATE(), 1);


-- Usuario administrador por defecto (contrase�a debe ser cambiada en primera sesi�n)
INSERT INTO Usuarios (id_rol, nombre, apellido, correo, telefono, direccion, usuario, contrasena, fecha_creacion, activo) 
VALUES (1, 'Luis', 'Lopez Beltran', 'llopezbeltran0@gmail.com', 67819004, 'Yapacani- Barrio 24 de junio', 'admin','223109762L', GETDATE(), 1);