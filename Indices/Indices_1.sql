--Los siguientes indices mejoran el rendimiento de los reportes:
--contabilidad consolidada
--cierre de caja
--impuesto diario
--ventas por usuario

--nuevo
CREATE NONCLUSTERED INDEX [idx_medio_pago] ON [ventas_medios_pago]
(
	[id_venta]
)
INCLUDE ( 	
	[id_medio_pago],
	[valor]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO

--nuevo
CREATE NONCLUSTERED INDEX [idx_descr_recogida] ON [ventas_recogida]
(
	[id_venta]
)
INCLUDE ( 	
	[descrip]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO


--reemplazar el anterior
DROP INDEX [idx_merca_fecha_creacion] ON [dbo].[venta]
GO

CREATE NONCLUSTERED INDEX [idx_merca_fecha_creacion] ON [dbo].[venta]
(
	[date_created] ASC
)
INCLUDE ( 	
	[id_venta],
	[bruto_ngtv],
	[bruto_pstv],
	[cod_terminal],
	[cod_tipo_transac],
	[id_tipo_transac],
	[id_terminal],
	[id_usuario]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO



--reemplazar el anterior
DROP INDEX [idx_ventas_articulo] ON [dbo].[ventas_articulo]
GO

CREATE NONCLUSTERED INDEX [idx_ventas_articulo] ON [dbo].[ventas_articulo]
(
	[date_created] ASC
)
INCLUDE ( 	[id_articulo],
	[cantidad],
	[cod_terminal],
	[impuesto],
	[valor_venta],
	[id_venta]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO
