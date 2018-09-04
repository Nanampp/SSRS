-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 27/08/2018
-- Description:	El reporte visualiza las unidades vendidas y el valor de la venta de los artículos que fueron vendidos por código de barra, consolidadas para un rango de fechas específico y para un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_VentaPorCodBarra] 
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
	SELECT	a.cod_imp Cod_art,
			a.descrip1 Descr_art,
			va.cod_barra,
			SUM(va.cantidad) AS cantidad,
			SUM(va.valor_venta) as TotalVenta
	FROM ventas_articulo va
	LEFT JOIN articulo a ON va.id_articulo = a.id_articulo
	INNER JOIN venta v ON va.id_venta = v.id_venta
	WHERE	va.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal)
			AND v.id_tipo_transac = '0'
			AND @Localidades LIKE ('%' + SUBSTRING(va.cod_terminal,1,3) + '%')
			and a.cod_imp != va.cod_barra
	GROUP BY a.cod_imp, a.descrip1, va.cod_barra
END