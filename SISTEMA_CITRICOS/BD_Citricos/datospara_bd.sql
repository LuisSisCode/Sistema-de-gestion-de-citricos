1. Roles y usuarios
Primero, vamos a insertar roles adicionales y usuarios:
-- Insertar roles adicionales
INSERT INTO Roles (nombre_rol, descripcion, fecha_creacion, activo) 
VALUES ('Admin', 'Supervisa operaciones de campo y producción', GETDATE(), 1);

INSERT INTO Roles (nombre_rol, descripcion, fecha_creacion, activo) 
VALUES ('supervisor', 'Manejo de tratamientos y control fitosanitario', GETDATE(), 1);
-- Crear un rol para trabajadores de campo
INSERT INTO Roles (nombre_rol, descripcion, fecha_creacion, activo) 
VALUES ('Trabajador de Campo', 'Personal que realiza labores agrícolas sin acceso completo al sistema', GETDATE(), 1);



-- Insertar usuarios adicionales
INSERT INTO Usuarios (id_rol, nombre, apellido, correo, telefono, direccion, usuario, contrasena, fecha_creacion, activo) 
VALUES (2, 'Carlos', 'Mendoza', 'cmendoza@citricos.com', '71502463', 'Yapacani - Barrio Central', 'cmendoza', HASHBYTES('SHA2_256', 'Cm12345'), GETDATE(), 1);

INSERT INTO Usuarios (id_rol, nombre, apellido, correo, telefono, direccion, usuario, contrasena, fecha_creacion, activo) 
VALUES (3, 'Maria', 'Gutierrez', 'mgutierrez@citricos.com', '73645201', 'Yapacani - Barrio Los Mangales', 'mgutierrez', HASHBYTES('SHA2_256', 'Mg12345'), GETDATE(), 1);

INSERT INTO Usuarios (id_rol, nombre, apellido, correo, telefono, direccion, usuario, contrasena, fecha_creacion, activo) 
VALUES (3, 'Juan', 'Perez', 'jperez@citricos.com', '75896321', 'Santa Cruz - Villa 1ro de Mayo', 'jperez', HASHBYTES('SHA2_256', 'Jp12345'), GETDATE(), 1);

Registrar trabajadores como usuarios con este rol
INSERT INTO Usuarios (id_rol, nombre, apellido, correo, telefono, direccion, usuario, contrasena, fecha_creacion, activo) 
VALUES (5, 'Jorge', 'Mamani', 'jmamani@gmail.com', '70125436', 'Yapacani - Barrio Los Pinos', 'jmamani', HASHBYTES('SHA2_256', 'Jm12345'), GETDATE(), 1);

INSERT INTO Usuarios (id_rol, nombre, apellido, correo, telefono, direccion, usuario, contrasena, fecha_creacion, activo) 
VALUES (5, 'Rosa', 'Flores', 'rflores@gmail.com', '73654189', 'Yapacani - Comunidad Río Nuevo', 'rflores', HASHBYTES('SHA2_256', 'Rf12345'), GETDATE(), 1);

2. Agricultores y Parcelas
-- Insertar agricultores
INSERT INTO Agricultores (nombre, apellido, identificacion, telefono, correo, direccion, fecha_registro, es_propietario, notas, activo)
VALUES ('Luis', 'López', '3245678', '67819004', 'llopezbeltran0@gmail.com', 'Yapacani - Barrio 24 de junio', '2018-05-15', 1, 'Propietario principal, gestiona todas las parcelas de cítricos', 1);

INSERT INTO Agricultores (nombre, apellido, identificacion, telefono, correo, direccion, fecha_registro, es_propietario, notas, activo)
VALUES ('Roberto', 'Mendez', '4578923', '70543218', 'rmendez@gmail.com', 'Yapacani - Barrio San Pedro', '2019-03-10', 0, 'Encargado de parcela norte, especialista en mandarinas', 1);

INSERT INTO Agricultores (nombre, apellido, identificacion, telefono, correo, direccion, fecha_registro, es_propietario, notas, activo)
VALUES ('Ana', 'Rojas', '6123458', '73214569', 'arojas@gmail.com', 'Yapacani - Comunidad Nueva Esperanza', '2020-02-18', 0, 'Manejo de limones, experta en injertos', 1);

-- Insertar parcelas
INSERT INTO Parcelas (id_agricultor, nombre, ubicacion, area_total, coordenadas_gps, tipo_suelo, fuente_agua, fecha_adquisicion, precio_adquisicion, notas, activo)
VALUES (1, 'Parcela Principal', 'Yapacani km 10 vía a Santa Cruz', 12.5, '-17.4023,-63.8245', 'Franco Arcilloso', 'Río Yapacani', '2010-06-20', 85000.00, 'Primera parcela adquirida, cultivo principal de naranjas', 1);

INSERT INTO Parcelas (id_agricultor, nombre, ubicacion, area_total, coordenadas_gps, tipo_suelo, fuente_agua, fecha_adquisicion, precio_adquisicion, notas, activo)
VALUES (2, 'Lote Norte', 'Yapacani km 12 desvío a Buena Vista', 8.3, '-17.3856,-63.8123', 'Franco Arenoso', 'Canal de riego comunitario', '2015-08-14', 62000.00, 'Dedicado principalmente a mandarinas', 1);

INSERT INTO Parcelas (id_agricultor, nombre, ubicacion, area_total, coordenadas_gps, tipo_suelo, fuente_agua, fecha_adquisicion, precio_adquisicion, notas, activo)
VALUES (2, 'Lote El Limonal', 'Yapacani km 8 sector El Naranjal', 5.2, '-17.4125,-63.8345', 'Franco', 'Pozo profundo', '2018-03-10', 45000.00, 'Especializado en limones', 1);


3-- Tipos de Cultivo (actualizados para Yapacani)
INSERT INTO TiposCultivo (nombre, nombre_cientifico, tiempo_cosecha_min, tiempo_cosecha_max, activo)
VALUES 
('Naranja', 'Citrus sinensis', 270, 360, 1),
('Mandarina', 'Citrus reticulata', 210, 300, 1),
('Limón', 'Citrus limon', 150, 240, 1);

-- VariedadesCultivo (con nombres locales y nuevas variedades)
INSERT INTO VariedadesCultivo (id_tipo_cultivo, nombre, tiempo_produccion, rendimiento_esperado, resistencia_enfermedades, activo)
VALUES 
-- NARANJAS (ajustadas a Yapacani)
(1, 'Criolla Boliviana', 300, 16.5, 'Resistente a cancro cítrico', 1),
(1, 'Siete Sabores', 280, 18.0, 'Moderada resistencia a antracnosis', 1),

-- MANDARINAS (actualizado con Morocochi)
(2, 'Criolla', 240, 14.0, 'Sensible a minador de hojas', 1),
(2, 'Ponkan', 210, 17.0, 'Resistente a alternaria', 1),
(2, 'Japonesa', 200, 19.5, 'Tolerante a plagas', 1),
(2, 'Incor', 260, 20.0, 'Alta resistencia a virosis', 1),
(2, 'Morocochi', 330, 16.0, 'Resistente a heladas y antracnosis', 1),  -- Nueva variedad tardía

-- LIMONES (variedades locales)
(3, 'Criollo', 160, 12.0, 'Susceptible a gomosis', 1),
(3, 'Persa', 180, 22.5, 'Resistente a verrugosis', 1);

4. Categorías de Agroquímicos y Productos
-- Insertar categorías de agroquímicos
INSERT INTO CategoriaAgroquimicos (nombre, descripcion, activo)
VALUES ('Insecticida', 'Productos para el control de insectos plaga', 1);

INSERT INTO CategoriaAgroquimicos (nombre, descripcion, activo)
VALUES ('Fungicida', 'Productos para el control de enfermedades fúngicas', 1);

INSERT INTO CategoriaAgroquimicos (nombre, descripcion, activo)
VALUES ('Herbicida', 'Productos para el control de malezas', 1);

INSERT INTO CategoriaAgroquimicos (nombre, descripcion, activo)
VALUES ('Fertilizante', 'Productos para la nutrición de los cultivos', 1);

-- Insertar productos agroquímicos
INSERT INTO ProductosAgroquimicos (id_categoria, nombre_comercial, fabricante, ingrediente_activo, concentracion, formulacion, unidad_medida, registro_oficial, periodo_reingreso, periodo_carencia, precio_unitario, stock_actual, fecha_registro, notas, activo)
VALUES (1, 'CiperPlus', 'AgroChemical', 'Cipermetrina', '25%', 'Concentrado Emulsionable', 'Litro', 'REG-123456', 24, 15, 180.00, 15.5, '2023-01-10', 'Efectivo contra mosca blanca y pulgones', 1);

INSERT INTO ProductosAgroquimicos (id_categoria, nombre_comercial, fabricante, ingrediente_activo, concentracion, formulacion, unidad_medida, registro_oficial, periodo_reingreso, periodo_carencia, precio_unitario, stock_actual, fecha_registro, notas, activo)
VALUES (2, 'FungiStop', 'BioProtect', 'Mancozeb', '80%', 'Polvo Mojable', 'Kilogramo', 'REG-234567', 48, 21, 95.00, 22.0, '2023-02-15', 'Prevención de antracnosis y gomosis', 1);

INSERT INTO ProductosAgroquimicos (id_categoria, nombre_comercial, fabricante, ingrediente_activo, concentracion, formulacion, unidad_medida, registro_oficial, periodo_reingreso, periodo_carencia, precio_unitario, stock_actual, fecha_registro, notas, activo)
VALUES (3, 'HerbaKill', 'GreenSolutions', 'Glifosato', '48%', 'Solución Concentrada', 'Litro', 'REG-345678', 12, 0, 120.00, 30.0, '2023-03-20', 'Control de malezas post-emergente', 1);

INSERT INTO ProductosAgroquimicos (id_categoria, nombre_comercial, fabricante, ingrediente_activo, concentracion, formulacion, unidad_medida, registro_oficial, periodo_reingreso, periodo_carencia, precio_unitario, stock_actual, fecha_registro, notas, activo)
VALUES (4, 'CitriGrow', 'NutriPlant', 'NPK + Microelementos', '20-10-10', 'Granulado', 'Kilogramo', 'REG-456789', 0, 0, 75.00, 150.0, '2023-04-05', 'Fertilizante balanceado para cítricos en desarrollo', 1);



5. Tipos de plagas y mezclas
-- Insertar tipos de plagas y malezas
INSERT INTO TiposPlagasMalezas (nombre, descripcion, categoria, activo)
VALUES ('Mosca blanca', 'Insecto chupador que afecta hojas nuevas y transmite virus', 'Plaga', 1);

INSERT INTO TiposPlagasMalezas (nombre, descripcion, categoria, activo)
VALUES ('Gomosis', 'Enfermedad fúngica que afecta el tronco y ramas principales', 'Enfermedad', 1);

INSERT INTO TiposPlagasMalezas (nombre, descripcion, categoria, activo)
VALUES ('Pasto estrella', 'Maleza invasiva de difícil control en cítricos', 'Maleza', 1);

-- Insertar mezclas de agroquímicos
INSERT INTO MezclasAgroquimicos (nombre, descripcion, cantidad_agua, area_aplicacion, objetivo, indicaciones, fecha_creacion, creado_por, activo)
VALUES ('Control Mosca Blanca', 'Mezcla para control efectivo de mosca blanca en cítricos', 200.0, 1.0, 'Control de mosca blanca en todas las etapas', 'Aplicar en horas tempranas o tarde, evitar días ventosos', '2023-05-10', 1, 1);

INSERT INTO MezclasAgroquimicos (nombre, descripcion, cantidad_agua, area_aplicacion, objetivo, indicaciones, fecha_creacion, creado_por, activo)
VALUES ('Prevención Gomosis', 'Tratamiento preventivo contra gomosis en troncos y ramas', 100.0, 0.5, 'Prevenir infecciones de gomosis', 'Aplicar directamente en troncos y base de ramas principales', '2023-06-15', 3, 1);

-- Insertar detalles de mezcla
INSERT INTO DetallesMezcla (id_mezcla, id_producto, cantidad, unidad_medida, observaciones)
VALUES (1, 1, 0.5, 'Litro', 'Diluir primero en 5 litros de agua antes de completar el tanque');

INSERT INTO DetallesMezcla (id_mezcla, id_producto, cantidad, unidad_medida, observaciones)
VALUES (2, 2, 0.75, 'Kilogramo', 'Mezclar con adherente para mejor fijación');


6. Categorías de Calidad y Métodos de Pago
-- Insertar categorías de calidad
INSERT INTO CategoriasCalidad (nombre, descripcion, criterios, activo)
VALUES ('Premium', 'Frutos de máxima calidad para exportación', 'Tamaño uniforme grande, piel sin defectos, color intenso', 1);

INSERT INTO CategoriasCalidad (nombre, descripcion, criterios, activo)
VALUES ('Estándar', 'Frutos de buena calidad para mercado nacional', 'Tamaño mediano a grande, mínimos defectos aceptables', 1);

INSERT INTO CategoriasCalidad (nombre, descripcion, criterios, activo)
VALUES ('Procesamiento', 'Frutos destinados a industria de jugos', 'Cualquier tamaño, pueden tener defectos externos pero buen contenido de jugo', 1);

-- Insertar métodos de pago
INSERT INTO MetodosPago (nombre, descripcion, activo)
VALUES ('Efectivo', 'Pago en moneda física', 1);

INSERT INTO MetodosPago (nombre, descripcion, activo)
VALUES ('Transferencia', 'Transferencia bancaria electrónica', 1);

INSERT INTO MetodosPago (nombre, descripcion, activo)
VALUES ('Cheque', 'Pago con cheque bancario', 1);


7. Categorías de Costos y Estados de Venta
-- Insertar categorías de costos
INSERT INTO CategoriasCostos (nombre, descripcion, activo)
VALUES ('Insumos', 'Costos de agroquímicos, fertilizantes y otros insumos', 1);

INSERT INTO CategoriasCostos (nombre, descripcion, activo)
VALUES ('Mano de Obra', 'Pagos a trabajadores por labores en el cultivo', 1);

INSERT INTO CategoriasCostos (nombre, descripcion, activo)
VALUES ('Maquinaria', 'Costos de operación y mantenimiento de equipos', 1);

INSERT INTO CategoriasCostos (nombre, descripcion, activo)
VALUES ('Servicios', 'Costos de servicios como análisis, asesorías, etc.', 1);

-- Insertar estados de venta
INSERT INTO EstadosVenta (nombre, descripcion, activo)
VALUES ('Cotizada', 'Venta en proceso de cotización', 1);

INSERT INTO EstadosVenta (nombre, descripcion, activo)
VALUES ('Confirmada', 'Venta confirmada pendiente de entrega', 1);

INSERT INTO EstadosVenta (nombre, descripcion, activo)
VALUES ('Entregada', 'Productos entregados al cliente', 1);

INSERT INTO EstadosVenta (nombre, descripcion, activo)
VALUES ('Cancelada', 'Venta cancelada', 1);


8. Ciclos de producción
-- Insertar ciclos de producción
INSERT INTO CiclosProduccion (id_parcela, id_variedad, nombre_ciclo, fecha_inicio, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, notas, activo)
VALUES (1, 1, 'Naranja Valencia 2023', '2023-01-15', '2023-01-20', '2023-12-15', NULL, 4.5, 400, 'En Desarrollo', 'Ciclo con buen desarrollo, fertilización reforzada en marzo', 1);

INSERT INTO CiclosProduccion (id_parcela, id_variedad, nombre_ciclo, fecha_inicio, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, notas, activo)
VALUES (2, 3, 'Mandarina Clementina 2023', '2023-02-10', '2023-02-15', '2023-10-20', NULL, 3.2, 450, 'En Desarrollo', 'Ciclo con problemas iniciales de pulgón, controlado en abril', 1);

INSERT INTO CiclosProduccion (id_parcela, id_variedad, nombre_ciclo, fecha_inicio, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, notas, activo)
VALUES (3, 5, 'Limón Tahití 2023', '2023-03-05', '2023-03-10', '2023-09-15', NULL, 2.8, 500, 'En Desarrollo', 'Desarrollo acelerado por lluvias tempranas', 1);


9. Clientes
-- Insertar clientes
INSERT INTO Clientes (tipo, nombre, identificacion, direccion, ciudad, estado_provincia, codigo_postal, telefono, correo, contacto_principal, telefono_contacto, condiciones_pago, limite_credito, notas, fecha_registro, registrado_por, activo)
VALUES ('Empresa', 'Cítricos del Valle S.A.', '1023456789', 'Av. Banzer km 12', 'Santa Cruz', 'Santa Cruz', '0000', '33445566', 'compras@citricosdelvalle.com', 'Pedro Sánchez', '71234567', 'Pago a 30 días', 50000.00, 'Comprador regular de naranja premium para exportación', '2020-05-15', 1, 1);

INSERT INTO Clientes (tipo, nombre, identificacion, direccion, ciudad, estado_provincia, codigo_postal, telefono, correo, contacto_principal, telefono_contacto, condiciones_pago, limite_credito, notas, fecha_registro, registrado_por, activo)
VALUES ('Empresa', 'Jugos Naturales Ltda.', '2034567890', 'Parque Industrial PI-14', 'Santa Cruz', 'Santa Cruz', '0000', '33556677', 'adquisiciones@jugosnaturales.com', 'Laura Mendoza', '73456789', 'Pago contra entrega', 25000.00, 'Comprador de fruta para procesamiento industrial', '2021-03-10', 1, 1);

INSERT INTO Clientes (tipo, nombre, identificacion, direccion, ciudad, estado_provincia, codigo_postal, telefono, correo, contacto_principal, telefono_contacto, condiciones_pago, limite_credito, notas, fecha_registro, registrado_por, activo)
VALUES ('Persona', 'Miguel Flores', '5647382910', 'Mercado Abasto puesto 45', 'Santa Cruz', 'Santa Cruz', '0000', '70123456', 'miguelflores@gmail.com', NULL, NULL, 'Pago efectivo', 10000.00, 'Distribuidor en mercado local', '2022-06-18', 4, 1);



10. Maquinaria (Complementando la que ya aparece en tu interfaz)
-- Insertar maquinaria adicional
INSERT INTO Maquinaria (codigo, nombre, tipo, marca, tipo_combustible, estado, ubicacion_actual, activo)
VALUES ('ASP-006', 'Aspersor de Arrastre', 'Aspersor', 'Jacto', 'No aplica', 'Operativo', 'Galpón Principal', 1);

INSERT INTO Maquinaria (codigo, nombre, tipo, marca, tipo_combustible, estado, ubicacion_actual, activo)
VALUES ('CAM-007', 'Camión de Carga', 'Vehículo', 'Isuzu', 'Diésel', 'Operativo', 'Estacionamiento', 1);

-- Insertar uso de maquinaria
INSERT INTO UsoMaquinaria (id_maquinaria, id_usuario, fecha_inicio, fecha_fin, actividad_realizada, parcela, combustible_consumido)
VALUES (1, 1, '2023-04-15 07:00:00', '2023-04-15 12:00:00', 'Preparación de terreno', 'Parcela Principal', 25.5);

INSERT INTO UsoMaquinaria (id_maquinaria, id_usuario, fecha_inicio, fecha_fin, actividad_realizada, parcela, combustible_consumido)
VALUES (2, 3, '2023-04-20 08:00:00', '2023-04-20 16:00:00', 'Aplicación de fungicida', 'Lote Norte', 12.3);

-- Insertar mantenimientos
INSERT INTO Mantenimientos (id_maquinaria, tipo, fecha_realizada, descripcion, costo_total, responsable, estado)
VALUES (1, 'Preventivo', '2023-03-10', 'Cambio de aceite y filtros', 350.00, 1, 'Completado');

INSERT INTO Mantenimientos (id_maquinaria, tipo, fecha_realizada, descripcion, costo_total, responsable, estado)
VALUES (3, 'Correctivo', '2023-03-25', 'Reparación de sistema de riego', 820.00, 1, 'Completado');


