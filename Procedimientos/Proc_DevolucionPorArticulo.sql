-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 15/08/2018
-- Description:	El reporte visualiza por artículo, las unidades vendidas, el valor total y el valor del impuesto de las devoluciones, en un rango de fechas específico y un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_DevolucionPorArticulo] 
	-- Add the parameters for the stored procedure here
	@FechaInicial date, 
	@FechaFinal date,
	@Localidades varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--devoluciones
	SELECT  l.cod_localidad as codigo,
			l.descrip as localidad,
			v.cod_terminal,
			CONVERT(date,v.date_created) Fecha,
			v.id_usuario,
			u.nombre + ' ' + u.apellido AS usuario,
			a.cod_imp Cod_art,
			a.descrip1 Descr_art,
			SUM(va.cantidad) AS cantidad,
			SUM(va.valor_venta) AS valor,
			va.pctj_impuesto AS pctj_impuesto,
			SUM(va.impuesto) AS impuesto
	FROM venta v
	INNER JOIN ventas_articulo AS va on va.id_venta = v.id_venta
	LEFT JOIN articulo a ON va.id_articulo = a.id_articulo
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	INNER JOIN usuario u ON u.id_usuario = v.id_usuario
	WHERE	((v.id_tipo_transac = '0' AND bruto_pstv = 0 AND bruto_ngtv > 0) OR v.id_tipo_transac = '20') 
			AND v.date_created BETWEEN DATEADD(dd,0,@fechaInicial)  AND DATEADD(dd,1,@fechaFinal)
			AND @Localidades LIKE ('%' + l.cod_localidad + '%')
	GROUP BY l.cod_localidad, l.descrip, v.cod_terminal, CONVERT(DATE,v.date_created), v.id_usuario, u.nombre + ' ' + u.apellido,  a.cod_imp, a.descrip1,va.pctj_impuesto
	ORDER BY l.cod_localidad, v.cod_terminal, a.cod_imp
END
