-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 08/08/2018
-- Description:	El reporte visualiza por localidad y día, el valor total/promedio de los impuestos y la cantidad total/promedio de clientes en un rango de fechas específico y para un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_VentaDiaria]  
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
	--detalle ventas efectivas (menos devoluciones)
	SELECT  c.descrip as ciudad,
			l.cod_localidad as codigo,
			l.descrip as localidad,
			l.fecha_apertura,
			convert(date,v.date_created) as fecha,
			SUM(v.bruto_pstv-v.bruto_ngtv) as valor,
			COUNT(v.id_venta) AS cantidad
	FROM venta AS v
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	LEFT JOIN ciudad c ON c.id_ciudad = l.id_ciudad
	WHERE   (v.id_tipo_transac = '0' OR v.id_tipo_transac = '20')
			AND (v.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal))
			AND @Localidades LIKE ('%' + l.cod_localidad + '%')
	GROUP BY c.descrip, l.cod_localidad, l.descrip, l.fecha_apertura, convert(date,v.date_created)
END
GO
