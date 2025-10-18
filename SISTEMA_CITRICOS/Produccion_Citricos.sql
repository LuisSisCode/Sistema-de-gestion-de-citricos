/****** Object:  Table [dbo].[Agricultores]    Script Date: 16/06/2025 0:07:32 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Agricultores](
	[id_agricultor] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[apellido] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[identificacion] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[telefono] [varchar](20) COLLATE Modern_Spanish_CI_AS NULL,
	[correo] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[direccion] [varchar](200) COLLATE Modern_Spanish_CI_AS NULL,
	[fecha_registro] [date] NOT NULL,
	[es_propietario] [bit] NOT NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_agricultor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[identificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Agricultores] ADD  DEFAULT ((0)) FOR [es_propietario]
ALTER TABLE [dbo].[Agricultores] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[CategoriaAgroquimicos]    Script Date: 16/06/2025 0:07:32 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CategoriaAgroquimicos](
	[id_categoria] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_categoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CategoriaAgroquimicos] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[CategoriasCalidad]    Script Date: 16/06/2025 0:07:33 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CategoriasCalidad](
	[id_categoria] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[criterios] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_categoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CategoriasCalidad] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[CategoriasCostos]    Script Date: 16/06/2025 0:07:33 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CategoriasCostos](
	[id_categoria] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_categoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CategoriasCostos] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[CiclosProduccion]    Script Date: 16/06/2025 0:07:33 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CiclosProduccion](
	[id_ciclo] [int] IDENTITY(1,1) NOT NULL,
	[id_parcela] [int] NOT NULL,
	[id_variedad] [int] NOT NULL,
	[fecha_siembra] [date] NULL,
	[fecha_cosecha_estimada] [date] NULL,
	[fecha_cosecha_real] [date] NULL,
	[area_sembrada] [decimal](10, 2) NOT NULL,
	[densidad_siembra] [int] NULL,
	[estado] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[activo] [bit] NOT NULL,
	[fecha_floracion] [date] NULL,
	[fecha_poda] [date] NULL,
	[fecha_limpieza] [date] NULL,
	[frecuencia_limpieza] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_ciclo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

/****** Object:  Index [IX_CiclosProduccion_IdParcela]    Script Date: 16/06/2025 0:07:33 ******/
CREATE NONCLUSTERED INDEX [IX_CiclosProduccion_IdParcela] ON [dbo].[CiclosProduccion]
(
	[id_parcela] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_CiclosProduccion_IdVariedad]    Script Date: 16/06/2025 0:07:33 ******/
CREATE NONCLUSTERED INDEX [IX_CiclosProduccion_IdVariedad] ON [dbo].[CiclosProduccion]
(
	[id_variedad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[CiclosProduccion] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[CiclosProduccion]  WITH CHECK ADD  CONSTRAINT [FK_CiclosProduccion_Parcelas] FOREIGN KEY([id_parcela])
REFERENCES [dbo].[Parcelas] ([id_parcela])
ALTER TABLE [dbo].[CiclosProduccion] CHECK CONSTRAINT [FK_CiclosProduccion_Parcelas]
ALTER TABLE [dbo].[CiclosProduccion]  WITH CHECK ADD  CONSTRAINT [FK_CiclosProduccion_VariedadesCultivo] FOREIGN KEY([id_variedad])
REFERENCES [dbo].[VariedadesCultivo] ([id_variedad])
ALTER TABLE [dbo].[CiclosProduccion] CHECK CONSTRAINT [FK_CiclosProduccion_VariedadesCultivo]
ALTER TABLE [dbo].[CiclosProduccion]  WITH CHECK ADD CHECK  (([estado]='Cancelado' OR [estado]='Finalizado' OR [estado]='En Cosecha' OR [estado]='En Desarrollo' OR [estado]='Sembrado' OR [estado]='En Preparaci?n' OR [estado]='Planificado'))
/****** Object:  Table [dbo].[Clientes]    Script Date: 16/06/2025 0:07:33 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Clientes](
	[id_cliente] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[direccion] [varchar](200) COLLATE Modern_Spanish_CI_AS NULL,
	[ciudad] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[estado_provincia] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[telefono] [varchar](20) COLLATE Modern_Spanish_CI_AS NULL,
	[correo] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[condiciones_pago] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[fecha_registro] [date] NOT NULL,
	[registrado_por] [int] NOT NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Clientes] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[Clientes]  WITH CHECK ADD  CONSTRAINT [FK_Clientes_Usuarios] FOREIGN KEY([registrado_por])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[Clientes] CHECK CONSTRAINT [FK_Clientes_Usuarios]
/****** Object:  Table [dbo].[ComprasCombustible]    Script Date: 16/06/2025 0:07:34 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ComprasCombustible](
	[id_compra] [int] IDENTITY(1,1) NOT NULL,
	[tipo_combustible] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[fecha_compra] [date] NOT NULL,
	[cantidad] [decimal](10, 2) NOT NULL,
	[unidad_medida] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[precio_unitario] [decimal](10, 2) NOT NULL,
	[precio_total] [decimal](10, 2) NOT NULL,
	[proveedor] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[responsable] [int] NOT NULL,
	[observaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id_compra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[ComprasCombustible]  WITH CHECK ADD  CONSTRAINT [FK_ComprasCombustible_Usuarios] FOREIGN KEY([responsable])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[ComprasCombustible] CHECK CONSTRAINT [FK_ComprasCombustible_Usuarios]
/****** Object:  Table [dbo].[CostosProduccion]    Script Date: 16/06/2025 0:07:34 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CostosProduccion](
	[id_costo] [int] IDENTITY(1,1) NOT NULL,
	[id_ciclo] [int] NOT NULL,
	[id_categoria] [int] NOT NULL,
	[id_tratamiento] [int] NULL,
	[concepto] [varchar](200) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[fecha] [date] NOT NULL,
	[cantidad] [decimal](10, 2) NOT NULL,
	[unidad_medida] [varchar](20) COLLATE Modern_Spanish_CI_AS NULL,
	[costo_unitario] [decimal](10, 2) NOT NULL,
	[costo_total] [decimal](10, 2) NOT NULL,
	[comprobante] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[registrado_por] [int] NOT NULL,
	[observaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id_costo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[CostosProduccion]  WITH CHECK ADD  CONSTRAINT [FK_CostosProduccion_CategoriasCostos] FOREIGN KEY([id_categoria])
REFERENCES [dbo].[CategoriasCostos] ([id_categoria])
ALTER TABLE [dbo].[CostosProduccion] CHECK CONSTRAINT [FK_CostosProduccion_CategoriasCostos]
ALTER TABLE [dbo].[CostosProduccion]  WITH CHECK ADD  CONSTRAINT [FK_CostosProduccion_CiclosProduccion] FOREIGN KEY([id_ciclo])
REFERENCES [dbo].[CiclosProduccion] ([id_ciclo])
ALTER TABLE [dbo].[CostosProduccion] CHECK CONSTRAINT [FK_CostosProduccion_CiclosProduccion]
ALTER TABLE [dbo].[CostosProduccion]  WITH CHECK ADD  CONSTRAINT [FK_CostosProduccion_TratamientosFitosanitarios] FOREIGN KEY([id_tratamiento])
REFERENCES [dbo].[TratamientosFitosanitarios] ([id_tratamiento])
ALTER TABLE [dbo].[CostosProduccion] CHECK CONSTRAINT [FK_CostosProduccion_TratamientosFitosanitarios]
ALTER TABLE [dbo].[CostosProduccion]  WITH CHECK ADD  CONSTRAINT [FK_CostosProduccion_Usuarios] FOREIGN KEY([registrado_por])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[CostosProduccion] CHECK CONSTRAINT [FK_CostosProduccion_Usuarios]
/****** Object:  Table [dbo].[DetallesMezcla]    Script Date: 16/06/2025 0:07:34 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DetallesMezcla](
	[id_detalle_mezcla] [int] IDENTITY(1,1) NOT NULL,
	[id_mezcla] [int] NOT NULL,
	[id_producto] [int] NOT NULL,
	[cantidad] [decimal](10, 2) NOT NULL,
	[unidad_medida] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[observaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id_detalle_mezcla] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[DetallesMezcla]  WITH CHECK ADD  CONSTRAINT [FK_DetallesMezcla_MezclasAgroquimicos] FOREIGN KEY([id_mezcla])
REFERENCES [dbo].[MezclasAgroquimicos] ([id_mezcla])
ALTER TABLE [dbo].[DetallesMezcla] CHECK CONSTRAINT [FK_DetallesMezcla_MezclasAgroquimicos]
ALTER TABLE [dbo].[DetallesMezcla]  WITH CHECK ADD  CONSTRAINT [FK_DetallesMezcla_ProductosAgroquimicos] FOREIGN KEY([id_producto])
REFERENCES [dbo].[ProductosAgroquimicos] ([id_producto])
ALTER TABLE [dbo].[DetallesMezcla] CHECK CONSTRAINT [FK_DetallesMezcla_ProductosAgroquimicos]
/****** Object:  Table [dbo].[DetallesVenta]    Script Date: 16/06/2025 0:07:34 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DetallesVenta](
	[id_detalle_venta] [int] IDENTITY(1,1) NOT NULL,
	[id_venta] [int] NOT NULL,
	[cantidad] [decimal](10, 2) NOT NULL,
	[unidad_medida] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[precio_unitario] [decimal](10, 2) NOT NULL,
	[subtotal] [decimal](12, 2) NOT NULL,
	[total] [decimal](12, 2) NOT NULL,
	[observaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id_detalle_venta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[DetallesVenta]  WITH CHECK ADD  CONSTRAINT [FK_DetallesVenta_Ventas] FOREIGN KEY([id_venta])
REFERENCES [dbo].[Ventas] ([id_venta])
ALTER TABLE [dbo].[DetallesVenta] CHECK CONSTRAINT [FK_DetallesVenta_Ventas]
/****** Object:  Table [dbo].[EstadosVenta]    Script Date: 16/06/2025 0:07:34 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EstadosVenta](
	[id_estado] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_estado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[EstadosVenta] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[LotesCosecha]    Script Date: 16/06/2025 0:07:35 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LotesCosecha](
	[id_lote] [int] IDENTITY(1,1) NOT NULL,
	[id_ciclo] [int] NOT NULL,
	[id_categoria_calidad] [int] NOT NULL,
	[codigo_lote] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[fecha_cosecha] [date] NOT NULL,
	[cantidad_cosechada] [decimal](10, 2) NOT NULL,
	[unidad_medida] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[precio_unitario_sugerido] [decimal](10, 2) NULL,
	[costo_produccion_unitario] [decimal](10, 2) NULL,
	[registrado_por] [int] NOT NULL,
	[observaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_lote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[codigo_lote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/****** Object:  Index [IX_LotesCosecha_FechaCosecha]    Script Date: 16/06/2025 0:07:35 ******/
CREATE NONCLUSTERED INDEX [IX_LotesCosecha_FechaCosecha] ON [dbo].[LotesCosecha]
(
	[fecha_cosecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_LotesCosecha_IdCiclo]    Script Date: 16/06/2025 0:07:35 ******/
CREATE NONCLUSTERED INDEX [IX_LotesCosecha_IdCiclo] ON [dbo].[LotesCosecha]
(
	[id_ciclo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[LotesCosecha] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[LotesCosecha]  WITH CHECK ADD  CONSTRAINT [FK_LotesCosecha_CategoriasCalidad] FOREIGN KEY([id_categoria_calidad])
REFERENCES [dbo].[CategoriasCalidad] ([id_categoria])
ALTER TABLE [dbo].[LotesCosecha] CHECK CONSTRAINT [FK_LotesCosecha_CategoriasCalidad]
ALTER TABLE [dbo].[LotesCosecha]  WITH CHECK ADD  CONSTRAINT [FK_LotesCosecha_CiclosProduccion] FOREIGN KEY([id_ciclo])
REFERENCES [dbo].[CiclosProduccion] ([id_ciclo])
ALTER TABLE [dbo].[LotesCosecha] CHECK CONSTRAINT [FK_LotesCosecha_CiclosProduccion]
ALTER TABLE [dbo].[LotesCosecha]  WITH CHECK ADD  CONSTRAINT [FK_LotesCosecha_Usuarios] FOREIGN KEY([registrado_por])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[LotesCosecha] CHECK CONSTRAINT [FK_LotesCosecha_Usuarios]
/****** Object:  Table [dbo].[Mantenimientos]    Script Date: 16/06/2025 0:07:35 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Mantenimientos](
	[id_mantenimiento] [int] IDENTITY(1,1) NOT NULL,
	[id_maquinaria] [int] NOT NULL,
	[tipo] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[fecha_realizada] [date] NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NOT NULL,
	[costo_total] [decimal](10, 2) NOT NULL,
	[responsable] [int] NOT NULL,
	[estado] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_mantenimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/****** Object:  Index [IX_Mantenimientos_IdMaquinaria]    Script Date: 16/06/2025 0:07:35 ******/
CREATE NONCLUSTERED INDEX [IX_Mantenimientos_IdMaquinaria] ON [dbo].[Mantenimientos]
(
	[id_maquinaria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[Mantenimientos]  WITH CHECK ADD  CONSTRAINT [FK_Mantenimientos_Maquinaria] FOREIGN KEY([id_maquinaria])
REFERENCES [dbo].[Maquinaria] ([id_maquinaria])
ALTER TABLE [dbo].[Mantenimientos] CHECK CONSTRAINT [FK_Mantenimientos_Maquinaria]
ALTER TABLE [dbo].[Mantenimientos]  WITH CHECK ADD  CONSTRAINT [FK_Mantenimientos_Usuarios] FOREIGN KEY([responsable])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[Mantenimientos] CHECK CONSTRAINT [FK_Mantenimientos_Usuarios]
ALTER TABLE [dbo].[Mantenimientos]  WITH CHECK ADD CHECK  (([estado]='Completado' OR [estado]='Programado'))
ALTER TABLE [dbo].[Mantenimientos]  WITH CHECK ADD CHECK  (([tipo]='Correctivo' OR [tipo]='Preventivo'))
/****** Object:  Table [dbo].[Maquinaria]    Script Date: 16/06/2025 0:07:35 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Maquinaria](
	[id_maquinaria] [int] IDENTITY(1,1) NOT NULL,
	[codigo] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[nombre] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[tipo] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[marca] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[tipo_combustible] [varchar](50) COLLATE Modern_Spanish_CI_AS NULL,
	[estado] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[ubicacion_actual] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_maquinaria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Maquinaria] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[Maquinaria]  WITH CHECK ADD CHECK  (([estado]='Fuera de servicio' OR [estado]='En mantenimiento' OR [estado]='Operativo'))
/****** Object:  Table [dbo].[MetodosPago]    Script Date: 16/06/2025 0:07:35 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MetodosPago](
	[id_metodo] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_metodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MetodosPago] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[MezclasAgroquimicos]    Script Date: 16/06/2025 0:07:35 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MezclasAgroquimicos](
	[id_mezcla] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[cantidad_agua] [decimal](10, 2) NULL,
	[area_aplicacion] [decimal](10, 2) NULL,
	[objetivo] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[indicaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[fecha_creacion] [date] NOT NULL,
	[activo] [bit] NOT NULL,
	[nota] [varchar](255) COLLATE Modern_Spanish_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id_mezcla] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MezclasAgroquimicos] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[Pagos]    Script Date: 16/06/2025 0:07:35 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Pagos](
	[id_pago] [int] IDENTITY(1,1) NOT NULL,
	[id_venta] [int] NULL,
	[id_agricultor] [int] NOT NULL,
	[id_metodo] [int] NOT NULL,
	[fecha_pago] [date] NOT NULL,
	[monto] [decimal](12, 2) NOT NULL,
	[concepto] [varchar](200) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[referencia] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[estado] [varchar](10) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[recibido_por] [int] NOT NULL,
	[observaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id_pago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/****** Object:  Index [IX_Pagos_FechaPago]    Script Date: 16/06/2025 0:07:35 ******/
CREATE NONCLUSTERED INDEX [IX_Pagos_FechaPago] ON [dbo].[Pagos]
(
	[fecha_pago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Pagos_IdAgricultor]    Script Date: 16/06/2025 0:07:35 ******/
CREATE NONCLUSTERED INDEX [IX_Pagos_IdAgricultor] ON [dbo].[Pagos]
(
	[id_agricultor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Pagos_IdVenta]    Script Date: 16/06/2025 0:07:35 ******/
CREATE NONCLUSTERED INDEX [IX_Pagos_IdVenta] ON [dbo].[Pagos]
(
	[id_venta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[Pagos] ADD  DEFAULT ('Pendiente') FOR [estado]
ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [FK_Pagos_Agricultores] FOREIGN KEY([id_agricultor])
REFERENCES [dbo].[Agricultores] ([id_agricultor])
ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [FK_Pagos_Agricultores]
ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [FK_Pagos_MetodosPago] FOREIGN KEY([id_metodo])
REFERENCES [dbo].[MetodosPago] ([id_metodo])
ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [FK_Pagos_MetodosPago]
ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [FK_Pagos_Usuarios] FOREIGN KEY([recibido_por])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [FK_Pagos_Usuarios]
ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [FK_Pagos_Ventas] FOREIGN KEY([id_venta])
REFERENCES [dbo].[Ventas] ([id_venta])
ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [FK_Pagos_Ventas]
ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD CHECK  (([estado]='Rechazado' OR [estado]='Confirmado' OR [estado]='Pendiente'))
/****** Object:  Table [dbo].[Parcelas]    Script Date: 16/06/2025 0:07:35 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Parcelas](
	[id_parcela] [int] IDENTITY(1,1) NOT NULL,
	[id_agricultor] [int] NOT NULL,
	[nombre] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[ubicacion] [varchar](200) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[area_total] [decimal](10, 2) NOT NULL,
	[coordenadas_gps] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[tipo_suelo] [varchar](50) COLLATE Modern_Spanish_CI_AS NULL,
	[fuente_agua] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[fecha_adquisicion] [date] NULL,
	[precio_adquisicion] [decimal](12, 2) NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_parcela] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

/****** Object:  Index [IX_Parcelas_IdAgricultor]    Script Date: 16/06/2025 0:07:35 ******/
CREATE NONCLUSTERED INDEX [IX_Parcelas_IdAgricultor] ON [dbo].[Parcelas]
(
	[id_agricultor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[Parcelas] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[Parcelas]  WITH CHECK ADD  CONSTRAINT [FK_Parcelas_Agricultores] FOREIGN KEY([id_agricultor])
REFERENCES [dbo].[Agricultores] ([id_agricultor])
ALTER TABLE [dbo].[Parcelas] CHECK CONSTRAINT [FK_Parcelas_Agricultores]
/****** Object:  Table [dbo].[ProductosAgroquimicos]    Script Date: 16/06/2025 0:07:36 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductosAgroquimicos](
	[id_producto] [int] IDENTITY(1,1) NOT NULL,
	[id_categoria] [int] NOT NULL,
	[nombre_comercial] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[formulacion] [varchar](20) COLLATE Modern_Spanish_CI_AS NULL,
	[unidad] [char](3) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[registro] [varchar](15) COLLATE Modern_Spanish_CI_AS NULL,
	[precio] [decimal](8, 2) NOT NULL,
	[stock] [decimal](10, 2) NULL,
	[fecha_registro] [date] NOT NULL,
	[notas] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_producto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[ProductosAgroquimicos] ADD  CONSTRAINT [DF_ProductosAgroquimicos_Formulacion]  DEFAULT ('Líquido') FOR [formulacion]
ALTER TABLE [dbo].[ProductosAgroquimicos] ADD  CONSTRAINT [DF_ProductosAgroquimicos_Registro]  DEFAULT ('PENDIENTE') FOR [registro]
ALTER TABLE [dbo].[ProductosAgroquimicos] ADD  DEFAULT ((0)) FOR [stock]
ALTER TABLE [dbo].[ProductosAgroquimicos] ADD  CONSTRAINT [DF_ProductosAgroquimicos_FechaRegistro]  DEFAULT (getdate()) FOR [fecha_registro]
ALTER TABLE [dbo].[ProductosAgroquimicos] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[ProductosAgroquimicos]  WITH CHECK ADD  CONSTRAINT [FK_ProductosAgroquimicos_CategoriaAgroquimicos] FOREIGN KEY([id_categoria])
REFERENCES [dbo].[CategoriaAgroquimicos] ([id_categoria])
ALTER TABLE [dbo].[ProductosAgroquimicos] CHECK CONSTRAINT [FK_ProductosAgroquimicos_CategoriaAgroquimicos]
ALTER TABLE [dbo].[ProductosAgroquimicos]  WITH CHECK ADD  CONSTRAINT [CK_ProductosAgroquimicos_Unidad] CHECK  (([unidad]='Kg' OR [unidad]='L'))
ALTER TABLE [dbo].[ProductosAgroquimicos] CHECK CONSTRAINT [CK_ProductosAgroquimicos_Unidad]
/****** Object:  Table [dbo].[Roles]    Script Date: 16/06/2025 0:07:36 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Roles](
	[id_rol] [int] IDENTITY(1,1) NOT NULL,
	[nombre_rol] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[fecha_creacion] [datetime] NOT NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_rol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre_rol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[Roles] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[TiposCultivo]    Script Date: 16/06/2025 0:07:36 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TiposCultivo](
	[id_tipo_cultivo] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[nombre_cientifico] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[tiempo_cosecha_min] [int] NULL,
	[tiempo_cosecha_max] [int] NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_tipo_cultivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[TiposCultivo] ADD  DEFAULT ((1)) FOR [activo]
/****** Object:  Table [dbo].[TiposPlagasMalezas]    Script Date: 16/06/2025 0:07:36 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TiposPlagasMalezas](
	[id_tipo] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[descripcion] [text] COLLATE Modern_Spanish_CI_AS NULL,
	[categoria] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_tipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[TiposPlagasMalezas] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[TiposPlagasMalezas]  WITH CHECK ADD CHECK  (([categoria]='Enfermedad' OR [categoria]='Maleza' OR [categoria]='Plaga'))
/****** Object:  Table [dbo].[TratamientosFitosanitarios]    Script Date: 16/06/2025 0:07:36 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TratamientosFitosanitarios](
	[id_tratamiento] [int] IDENTITY(1,1) NOT NULL,
	[id_ciclo] [int] NOT NULL,
	[id_tipo_plaga] [int] NULL,
	[fecha_aplicacion] [date] NOT NULL,
	[area_tratada] [decimal](10, 2) NOT NULL,
	[metodo_aplicacion] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[condiciones_climaticas] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[id_mezcla] [int] NULL,
	[cantidad_agua] [decimal](10, 2) NULL,
	[costo_total] [decimal](10, 2) NULL,
	[realizado_por] [int] NOT NULL,
	[observaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id_tratamiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/****** Object:  Index [IX_TratamientosFitosanitarios_FechaAplicacion]    Script Date: 16/06/2025 0:07:36 ******/
CREATE NONCLUSTERED INDEX [IX_TratamientosFitosanitarios_FechaAplicacion] ON [dbo].[TratamientosFitosanitarios]
(
	[fecha_aplicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_TratamientosFitosanitarios_IdCiclo]    Script Date: 16/06/2025 0:07:36 ******/
CREATE NONCLUSTERED INDEX [IX_TratamientosFitosanitarios_IdCiclo] ON [dbo].[TratamientosFitosanitarios]
(
	[id_ciclo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[TratamientosFitosanitarios]  WITH CHECK ADD  CONSTRAINT [FK_TratamientosFitosanitarios_CiclosProduccion] FOREIGN KEY([id_ciclo])
REFERENCES [dbo].[CiclosProduccion] ([id_ciclo])
ALTER TABLE [dbo].[TratamientosFitosanitarios] CHECK CONSTRAINT [FK_TratamientosFitosanitarios_CiclosProduccion]
ALTER TABLE [dbo].[TratamientosFitosanitarios]  WITH CHECK ADD  CONSTRAINT [FK_TratamientosFitosanitarios_MezclasAgroquimicos] FOREIGN KEY([id_mezcla])
REFERENCES [dbo].[MezclasAgroquimicos] ([id_mezcla])
ALTER TABLE [dbo].[TratamientosFitosanitarios] CHECK CONSTRAINT [FK_TratamientosFitosanitarios_MezclasAgroquimicos]
ALTER TABLE [dbo].[TratamientosFitosanitarios]  WITH CHECK ADD  CONSTRAINT [FK_TratamientosFitosanitarios_TiposPlagasMalezas] FOREIGN KEY([id_tipo_plaga])
REFERENCES [dbo].[TiposPlagasMalezas] ([id_tipo])
ALTER TABLE [dbo].[TratamientosFitosanitarios] CHECK CONSTRAINT [FK_TratamientosFitosanitarios_TiposPlagasMalezas]
ALTER TABLE [dbo].[TratamientosFitosanitarios]  WITH CHECK ADD  CONSTRAINT [FK_TratamientosFitosanitarios_Usuarios] FOREIGN KEY([realizado_por])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[TratamientosFitosanitarios] CHECK CONSTRAINT [FK_TratamientosFitosanitarios_Usuarios]
/****** Object:  Table [dbo].[UsoMaquinaria]    Script Date: 16/06/2025 0:07:36 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UsoMaquinaria](
	[id_uso] [int] IDENTITY(1,1) NOT NULL,
	[id_maquinaria] [int] NOT NULL,
	[id_usuario] [int] NOT NULL,
	[fecha_inicio] [datetime] NOT NULL,
	[fecha_fin] [datetime] NULL,
	[actividad_realizada] [varchar](200) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[parcela] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[combustible_consumido] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_uso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

/****** Object:  Index [IX_UsoMaquinaria_IdMaquinaria]    Script Date: 16/06/2025 0:07:36 ******/
CREATE NONCLUSTERED INDEX [IX_UsoMaquinaria_IdMaquinaria] ON [dbo].[UsoMaquinaria]
(
	[id_maquinaria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[UsoMaquinaria]  WITH CHECK ADD  CONSTRAINT [FK_UsoMaquinaria_Maquinaria] FOREIGN KEY([id_maquinaria])
REFERENCES [dbo].[Maquinaria] ([id_maquinaria])
ALTER TABLE [dbo].[UsoMaquinaria] CHECK CONSTRAINT [FK_UsoMaquinaria_Maquinaria]
ALTER TABLE [dbo].[UsoMaquinaria]  WITH CHECK ADD  CONSTRAINT [FK_UsoMaquinaria_Usuarios] FOREIGN KEY([id_usuario])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[UsoMaquinaria] CHECK CONSTRAINT [FK_UsoMaquinaria_Usuarios]
/****** Object:  Table [dbo].[Usuarios]    Script Date: 16/06/2025 0:07:37 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Usuarios](
	[id_usuario] [int] IDENTITY(1,1) NOT NULL,
	[id_rol] [int] NOT NULL,
	[nombre] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[apellido] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[correo] [varchar](100) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[telefono] [varchar](20) COLLATE Modern_Spanish_CI_AS NULL,
	[direccion] [varchar](200) COLLATE Modern_Spanish_CI_AS NULL,
	[usuario] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[contrasena] [varchar](255) COLLATE Modern_Spanish_CI_AS NULL,
	[fecha_creacion] [datetime] NOT NULL,
	[ultimo_acceso] [datetime] NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[correo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[Usuarios]  WITH CHECK ADD  CONSTRAINT [FK_Usuarios_Roles] FOREIGN KEY([id_rol])
REFERENCES [dbo].[Roles] ([id_rol])
ALTER TABLE [dbo].[Usuarios] CHECK CONSTRAINT [FK_Usuarios_Roles]
/****** Object:  Table [dbo].[VariedadesCultivo]    Script Date: 16/06/2025 0:07:37 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[VariedadesCultivo](
	[id_variedad] [int] IDENTITY(1,1) NOT NULL,
	[id_tipo_cultivo] [int] NOT NULL,
	[nombre] [varchar](50) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[tiempo_produccion] [int] NULL,
	[rendimiento_esperado] [decimal](10, 2) NULL,
	[resistencia_zona] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[activo] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_variedad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[VariedadesCultivo] ADD  DEFAULT ((1)) FOR [activo]
ALTER TABLE [dbo].[VariedadesCultivo]  WITH CHECK ADD  CONSTRAINT [FK_VariedadesCultivo_TiposCultivo] FOREIGN KEY([id_tipo_cultivo])
REFERENCES [dbo].[TiposCultivo] ([id_tipo_cultivo])
ALTER TABLE [dbo].[VariedadesCultivo] CHECK CONSTRAINT [FK_VariedadesCultivo_TiposCultivo]
/****** Object:  Table [dbo].[Ventas]    Script Date: 16/06/2025 0:07:37 ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Ventas](
	[id_venta] [int] IDENTITY(1,1) NOT NULL,
	[id_cliente] [int] NOT NULL,
	[codigo_venta] [varchar](20) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[fecha_venta] [date] NOT NULL,
	[subtotal] [decimal](12, 2) NOT NULL,
	[total] [decimal](12, 2) NOT NULL,
	[condiciones_pago] [varchar](100) COLLATE Modern_Spanish_CI_AS NULL,
	[fecha_entrega] [date] NULL,
	[lugar_entrega] [varchar](200) COLLATE Modern_Spanish_CI_AS NULL,
	[id_estado] [int] NOT NULL,
	[estado_pago] [varchar](10) COLLATE Modern_Spanish_CI_AS NOT NULL,
	[registrado_por] [int] NOT NULL,
	[observaciones] [text] COLLATE Modern_Spanish_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id_venta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[codigo_venta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/****** Object:  Index [IX_Ventas_FechaVenta]    Script Date: 16/06/2025 0:07:37 ******/
CREATE NONCLUSTERED INDEX [IX_Ventas_FechaVenta] ON [dbo].[Ventas]
(
	[fecha_venta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
/****** Object:  Index [IX_Ventas_IdCliente]    Script Date: 16/06/2025 0:07:37 ******/
CREATE NONCLUSTERED INDEX [IX_Ventas_IdCliente] ON [dbo].[Ventas]
(
	[id_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE [dbo].[Ventas] ADD  DEFAULT ('Pendiente') FOR [estado_pago]
ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD  CONSTRAINT [FK_Ventas_Clientes] FOREIGN KEY([id_cliente])
REFERENCES [dbo].[Clientes] ([id_cliente])
ALTER TABLE [dbo].[Ventas] CHECK CONSTRAINT [FK_Ventas_Clientes]
ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD  CONSTRAINT [FK_Ventas_EstadosVenta] FOREIGN KEY([id_estado])
REFERENCES [dbo].[EstadosVenta] ([id_estado])
ALTER TABLE [dbo].[Ventas] CHECK CONSTRAINT [FK_Ventas_EstadosVenta]
ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD  CONSTRAINT [FK_Ventas_Usuarios] FOREIGN KEY([registrado_por])
REFERENCES [dbo].[Usuarios] ([id_usuario])
ALTER TABLE [dbo].[Ventas] CHECK CONSTRAINT [FK_Ventas_Usuarios]
ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD CHECK  (([estado_pago]='Pagado' OR [estado_pago]='Parcial' OR [estado_pago]='Pendiente'))
