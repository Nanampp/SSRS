SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 06/08/2018
-- Description:	El reporte visualiza por localidad, la cantidad de bonos y valor total de la venta para aquellas ventas donde se usaron más bonos que los permitidos (1 bono por cada 20.000 pesos) en un rango de fechas específico.
-- =============================================
CREATE PROCEDURE Proc_Exc_VentasBonos
	-- Add the parameters for the stored procedure here
	@FechaInicial date, 
	@FechaFinal date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT  v.id_venta,
		l.cod_localidad as codigo,
		l.descrip as localidad,
		v.cod_terminal terminal,
		v.date_created Fecha,
		v.nro_transac,
		v.nro_fact, 
		v.prefijo,
		v.id_usuario,
		u.nombre + ' ' + u.apellido AS usuario,
		SUM(va.cantidad) AS CantBonos,
		v.bruto_pstv-v.bruto_ngtv as valor_venta
	FROM venta AS v
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	INNER JOIN usuario u ON u.id_usuario = v.id_usuario
	INNER JOIN ventas_articulo va ON v.id_venta = va.id_venta
	WHERE   v.id_tipo_transac = '0'
			AND bruto_pstv <> 0
			AND v.date_created BETWEEN DATEADD(dd,0,@fechaInicial)  AND DATEADD(dd,1,@fechaFinal)
			AND va.cod_imp = '2' --código del artículo correspondiente al bono.
	GROUP BY v.id_venta, l.cod_localidad, l.descrip, v.cod_terminal, v.date_created, v.nro_transac, v.nro_fact, v.prefijo, v.id_usuario, u.nombre + ' ' + u.apellido, v.bruto_pstv, v.bruto_ngtv
	HAVING  SUM(va.cantidad) > 0 
			AND SUM(va.cantidad) > ((v.bruto_pstv-v.bruto_ngtv) + (SUM(va.cantidad) * 1000)) / 20000 -- 1 bono de $ 1.000 por cada $20.000
END
GO

