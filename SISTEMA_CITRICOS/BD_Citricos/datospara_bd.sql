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
INSERT INTO Agricultores (nombre, apellido, identificacion, telefono, correo, direccion, fecha_registro, es_propietario, activo)
VALUES ('Luis', 'López', '3245678', '67819004', 'llopezbeltran0@gmail.com', 'Yapacani - Barrio 24 de junio', '2018-05-15', 1, 1);

INSERT INTO Agricultores (nombre, apellido, identificacion, telefono, correo, direccion, fecha_registro, es_propietario, activo)
VALUES ('Roberto', 'Mendez', '4578923', '70543218', 'rmendez@gmail.com', 'Yapacani - Barrio San Pedro', '2019-03-10', 0, 1);

INSERT INTO Agricultores (nombre, apellido, identificacion, telefono, correo, direccion, fecha_registro, es_propietario,  activo)
VALUES ('Ana', 'Rojas', '6123458', '73214569', 'arojas@gmail.com', 'Yapacani - Comunidad Nueva Esperanza', '2020-02-18', 0, 1);

-- Insertar parcelas
INSERT INTO Parcelas (id_agricultor, nombre, ubicacion, area_total, coordenadas_gps, tipo_suelo, fuente_agua, fecha_adquisicion, precio_adquisicion, activo)
VALUES (1, 'Parcela Principal', 'Yapacani km 10 vía a Santa Cruz', 12.5, '-17.4023,-63.8245', 'Franco Arcilloso', 'Río Yapacani', '2010-06-20', 85000.00, 1);

INSERT INTO Parcelas (id_agricultor, nombre, ubicacion, area_total, coordenadas_gps, tipo_suelo, fuente_agua, fecha_adquisicion, precio_adquisicion, activo)
VALUES (2, 'Lote Norte', 'Yapacani km 12 desvío a Buena Vista', 8.3, '-17.3856,-63.8123', 'Franco Arenoso', 'Canal de riego comunitario', '2015-08-14', 62000.00, 1);

INSERT INTO Parcelas (id_agricultor, nombre, ubicacion, area_total, coordenadas_gps, tipo_suelo, fuente_agua, fecha_adquisicion, precio_adquisicion, activo)
VALUES (2, 'Lote El Limonal', 'Yapacani km 8 sector El Naranjal', 5.2, '-17.4125,-63.8345', 'Franco', 'Pozo profundo', '2018-03-10', 45000.00, 1);

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

-- Ciclos de producción para Naranjas
INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(1, 1, '2022-03-15', '2023-01-25', NULL, 3.5, 250, 'En Desarrollo', 1, '2022-08-10', '2022-05-20', '2022-09-15', 3);

INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(1, 2, '2021-09-20', '2022-06-15', '2022-07-02', 2.8, 230, 'Finalizado', 1, '2022-01-15', '2021-11-10', '2022-02-20', 2);

-- Ciclos de producción para Mandarinas
INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(2, 3, '2023-04-10', '2024-01-05', NULL, 2.2, 280, 'Sembrado', 1, '2023-09-20', NULL, '2023-06-15', 2);

INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(2, 5, '2022-08-05', '2023-03-25', '2023-04-10', 1.8, 260, 'Finalizado', 1, '2023-01-10', '2022-11-20', '2023-02-05', 3);

INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(3, 7, '2023-02-20', '2024-01-15', NULL, 1.5, 240, 'En Desarrollo', 1, '2023-07-10', '2023-04-25', '2023-08-15', 2);

-- Ciclos de producción para Limones
INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(1, 8, '2023-05-10', '2023-10-15', NULL, 1.2, 300, 'En Desarrollo', 1, '2023-07-20', NULL, '2023-06-25', 1);

INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(3, 9, '2022-10-05', '2023-04-12', '2023-04-20', 1.0, 320, 'Finalizado', 1, '2023-01-05', '2022-12-10', '2023-02-15', 2);

-- Ciclo de producción planificado
INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(2, 4, '2023-09-15', '2024-04-22', NULL, 2.5, 270, 'Planificado', 1, NULL, NULL, NULL, 2);

-- Alternativa usando texto exacto de la restricción
INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(3, 6, '2023-08-10', '2024-05-15', NULL, 1.7, 250, 'En Preparaci?n', 1, NULL, NULL, NULL, 3);

-- Ciclo en cosecha
INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES 
(1, 3, '2022-06-20', '2023-03-10', NULL, 2.0, 290, 'En Cosecha', 1, '2022-11-15', '2022-08-05', '2023-01-12', 2);


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

-- Productos con nombres locales y realistas para Yapacaní
INSERT INTO ProductosAgroquimicos 
(id_categoria, nombre_comercial, formulacion, unidad, precio, stock, registro, notas)
VALUES
-- Insecticida (Ej: para minador de hojas en cítricos)
(1, 'Cipertrina 25EC', 'Líquido', 'L', 85.00, 20.0, 'SENASAG-2023', 'Contra minador y mosca blanca (usar 2ml/L)'),

-- Fungicida (Ej: para antracnosis en mandarinas)
(2, 'Cobrestar WP', 'Polvo', 'Kg', 70.00, 15.0, 'SENASAG-4567', 'Mezclar 3g por litro de agua'),

-- Herbicida (Ej: para malezas en huertos)
(3, 'Glifosato 48SL', 'Líquido', 'L', 110.00, 25.0, 'SENASAG-8910', 'Aplicar con cuidado en base de árboles'),

-- Fertilizante (Ej: para limones y naranjas)
(4, 'CitroMag', 'Granulado', 'Kg', 90.00, 200.0, 'SENASAG-1122', '15-5-20 NPK + Magnesio para fruta jugosa');


5-- Plagas/Enfermedades con nombres locales
INSERT INTO TiposPlagasMalezas (nombre, descripcion, categoria, activo)
VALUES 
('Piojillo volador', 'Insecto que chupa savia en brotes nuevos. Se ve como polvo blanco', 'Plaga', 1),  -- Mosca blanca
('Sangrado de tronco', 'Hongo que hace rezumar el tronco con goma espesa', 'Enfermedad', 1),  -- Gomosis
('Yuyo estrella', 'Maleza dura que forma matas. Raíces profundas', 'Maleza', 1);  -- Pasto estrella

-- Mezclas comunes usadas por agricultores
INSERT INTO MezclasAgroquimicos 
(nombre, descripcion, cantidad_agua, area_aplicacion, objetivo, indicaciones, fecha_creacion, activo, nota)
VALUES 
('Caldo para piojillo','Mezcla económica con jabón para controlar piojillo en limón sutil', 20.0, 0.2, 'Control piojillo en post-cosecha', 'Aplicar con bomba de espalda. Repetir a los 7 días', '2023-10-01', 
 1, 'Incluir jabón agrícola como adherente'),  -- Nueva nota

('Lavado de troncos', 'Mezcla curativa para troncos con sangrado', 10.0, 0.1, 'Sanar heridas por gomosis', 'Cepillar tronco antes de aplicar', '2023-09-15', 1, 'Aplicar con brocha de cerdas naturales');  -- Nueva nota
-- Detalles de mezclas con productos locales

INSERT INTO DetallesMezcla (id_mezcla, id_producto, cantidad, unidad_medida, observaciones)
VALUES 
(2, 1, 100, 'ml', 'Cipertrina 25EC + 200g jabón agrícola'),  
(2, 4, 50, 'g', 'CitroMag como adherente (opcional)');   

INSERT INTO DetallesMezcla (id_mezcla, id_producto, cantidad, unidad_medida, observaciones)
VALUES 
(3, 2, 500, 'g', 'Cobrestar WP mezclado con 10L agua tibia'), 
(3, 3, 30, 'ml', 'Glifosato 48SL para limpiar maleza alrededor'); 


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
---- Insertar ciclos de producción
INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES (1, 1, '2023-01-20', '2023-12-15', NULL, 4.5, 400, 'En Desarrollo', 1, '2023-03-15', '2023-01-05', '2023-02-10', 30);

INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES (2, 3, '2023-02-15', '2023-10-20', NULL, 3.2, 450, 'En Desarrollo', 1, '2023-04-10', '2023-01-25', '2023-03-05', 45);

INSERT INTO CiclosProduccion (id_parcela, id_variedad, fecha_siembra, fecha_cosecha_estimada, fecha_cosecha_real, area_sembrada, densidad_siembra, estado, activo, fecha_floracion, fecha_poda, fecha_limpieza, frecuencia_limpieza)
VALUES (3, 5, '2023-03-10', '2023-09-15', NULL, 2.8, 500, 'En Desarrollo', 1, '2023-05-05', '2023-02-20', '2023-04-15', 30);


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


