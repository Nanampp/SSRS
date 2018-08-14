-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 14/08/2018
-- Description:	El reporte visualiza por hora, la cantidad de transacciones, la cantidad de artículos vendidos, el promedio de artículos por transacción, el promedio del valor de la venta por transacción y el valor total de la venta en un rango de fechas específico y consolidado para un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_VentaPorHora] 
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
	SELECT  l.cod_localidad as codigo,
			l.descrip as localidad,
			convert(varchar(5),datepart(hour,va.date_created)) + ':00' as Hora, 
			DATEPART(HOUR, va.date_created) as HoraSort,  
			sum(va.cantidad) as NroArticulos,  
			count(v.id_venta) as NroTransacciones, 
			convert(date,va.date_created) FechaVenta, 
			SUM(va.valor_venta) / count(v.id_venta) as Precio_Articulo,
			SUM(va.cantidad) / count(v.id_venta) as Transaccion_Articulo, 
			sum(va.valor_venta) as VentaNeta
	FROM dbo.ventas_articulo va 
	INNER JOIN venta v  ON v.id_venta=va.id_venta
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(va.cod_terminal,1,3)
	WHERE   va.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal)
			AND @Localidades LIKE ('%' + l.cod_localidad + '%')
	GROUP by l.cod_localidad, l.descrip, convert(date,va.date_created), DATEPART(HOUR,va.date_created)
	order by l.cod_localidad, convert(date,va.date_created), DATEPART(HOUR,va.date_created)
END
