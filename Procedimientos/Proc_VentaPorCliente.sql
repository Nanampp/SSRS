-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 17/08/2018
-- Description:	El reporte visualiza por cliente y factura, el valor de la venta en un rango de fechas específico y para un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_VentasCliente] 
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
	SELECT	l.cod_localidad as codigo,
			l.descrip as localidad,
			v.cod_terminal,
			CONVERT(date,v.date_created) Fecha,
			v.id_usuario,
			u.nombre + ' ' + u.apellido AS usuario,
			v.prefijo as prefijo, 
			v.nro_fact as nro_factura, 
			p.id_persona as id_cliente, 
			p.primer_nombre + ' ' + p.primer_apellido as cliente,
			SUM(v.bruto_pstv - v.bruto_ngtv) AS valor_venta
	FROM venta v
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	INNER JOIN usuario u ON u.id_usuario = v.id_usuario
	INNER JOIN ventas_cliente vc ON vc.id_venta = v.id_venta
	LEFT JOIN persona p ON p.id_persona = vc.cliente_id
	WHERE	v.id_tipo_transac = '0'
			AND v.date_created BETWEEN DATEADD(dd,0,@fechaInicial)  AND DATEADD(dd,1,@fechaFinal) 
			AND @Localidades LIKE ('%' + l.cod_localidad + '%')	
	GROUP BY l.cod_localidad, l.descrip, v.cod_terminal, CONVERT(date,v.date_created), v.id_usuario, u.nombre + ' ' + u.apellido, v.prefijo, v.nro_fact, p.id_persona, p.primer_nombre + ' ' + p.primer_apellido
	ORDER BY l.cod_localidad ASC, CONVERT(date,v.date_created) ASC
END
