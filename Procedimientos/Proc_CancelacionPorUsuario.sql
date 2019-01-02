-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 28/11/2018
-- Description: El reporte visualiza por localidad, terminal, día, transacción y usuario, las cantidades y el valor de las cancelaciones para un rango de fechas específico y para un conjunto de localidades dadas. 
-- =============================================
CREATE PROCEDURE [dbo].[Proc_CancelacionesPorUsuario]  
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
			v.cod_terminal,
			v.nro_fact,
			v.nro_transac,
			v.id_usuario,
			u.nombre + ' ' + u.apellido AS usuario,
			a.cod_imp Cod_art,
			a.descrip1 Descr_art,
			va.cantidad,
			va.valor_venta,
			v.date_created AS fecha
	FROM  venta AS v
	INNER JOIN ventas_articulo AS va ON va.id_venta = v.id_venta
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	INNER JOIN usuario u ON u.id_usuario = v.id_usuario
	INNER JOIN articulo a ON va.id_articulo = a.id_articulo
	WHERE   v.date_created BETWEEN DATEADD(dd,0,@fechaInicial)  AND DATEADD(dd,1,@fechaFinal)
			AND @Localidades LIKE ('%' + l.cod_localidad + '%') 
			AND v.cod_tipo_transac = '0' AND v.bruto_pstv <> 0
			AND va.cantidad < 0
	ORDER BY v.date_created, v.id_usuario, a.descrip1 
	END
