-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 24/08/2018
-- Description:	El reporte visualiza por artículo, las unidades vendidas, el valor de la venta y el porcentaje de participación de los artículos en la venta total, consolidadas para un rango de fechas específico y para un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_ParticipacionArticulo] 
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
			a.unid_med_fleje as UnidadMedida,
			SUM(va.cantidad) AS cantidad,
			sum(va.valor_venta) as TotalVenta,
			(sum(va.valor_venta)/t.totalArticulosVendidos*100) AS PorcentajeParticipacion						  
	FROM venta AS v
	INNER JOIN ventas_articulo va ON va.id_venta = v.id_venta
	INNER JOIN articulo a ON va.id_articulo = a.id_articulo
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	,(select SUM(va.valor_venta) as TotalArticulosVendidos 
		from ventas_articulo va
		INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(va.cod_terminal,1,3)
		where va.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal)
		AND @Localidades LIKE ('%' + l.cod_localidad + '%')) AS t
	WHERE (v.id_tipo_transac = '0' or v.id_tipo_transac = '20') 
		AND v.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal)
		AND @Localidades LIKE ('%' + l.cod_localidad + '%')
	GROUP BY a.cod_imp, a.descrip1, a.unid_med_fleje,t.totalArticulosVendidos
	HAVING SUM(va.valor_venta) > 0  
	ORDER BY SUM(va.valor_venta) DESC
END