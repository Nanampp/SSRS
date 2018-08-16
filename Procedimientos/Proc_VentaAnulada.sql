-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 16/08/2018
-- Description:	El reporte visualiza, el detalle de las anulaciones en un rango de fechas específico y un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_VentaAnulada] 
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
			CONVERT(varchar(19),v.date_created,20) Fecha,
			v.id_usuario,
			u.nombre + ' ' + u.apellido AS usuario,
			v.bruto_pstv AS TotalVenta 
	FROM venta v
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	INNER JOIN usuario u ON u.id_usuario = v.id_usuario
	where	v.id_tipo_transac = '7' 
			AND v.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal) 
			AND @Localidades LIKE ('%' + l.cod_localidad + '%')
	ORDER BY l.cod_localidad,v.cod_terminal, CONVERT(varchar(19),v.date_created,20) desc
END
