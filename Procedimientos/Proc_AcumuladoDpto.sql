-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 09/08/2018
-- Description:	El reporte visualiza por departamento/grupo/categoría, la cantidad, el valor bruto, valor total y el porcentaje de participación de la venta, consolidado para un rango de fechas específico y para un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_AcumuladoDpto] 
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
	WITH #g AS
	(
		SELECT ng.descrip nivel, g.id_grupo, g.cod_grupo, gp.descrip
		FROM grupo g
		INNER JOIN grupo gp ON g.cod_grupo = gp.cod_grupo AND gp.subgrupo1 = '00' AND gp.subgrupo2 = '00' AND gp.subgrupo3 = '00' AND gp.subgrupo4 = '00'
		INNER JOIN dbo.grupo_nivel ng ON ng.id_grupo_nivel = gp.grp_nivel_id
	)

	--detalle ventas articulo
	SELECT  l.cod_localidad as codigo,
			l.descrip as localidad,
			#g.nivel nivel,
			#g.cod_grupo AS CodGrupo,
			#g.descrip AS grupo,
			SUM(va.cantidad) AS cantidad,   
			SUM(va.valor_venta) AS valor,
			(SUM(va.valor_venta)/
			   (SELECT sum(va.valor_venta)
				FROM ventas_articulo AS va 
				INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(va.cod_terminal,1,3)
				WHERE   va.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal)
						AND @Localidades LIKE ('%' + l.cod_localidad + '%')
			   )
			) AS PartVenta
	FROM ventas_articulo AS va
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(va.cod_terminal,1,3)
	INNER JOIN articulo a ON va.id_articulo = a.id_articulo
	LEFT JOIN #g ON a.id_grupo = #g.id_grupo
	WHERE   va.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal)
			AND @Localidades LIKE ('%' + l.cod_localidad + '%')
	GROUP BY l.cod_localidad, l.descrip, #g.nivel, #g.cod_grupo, #g.descrip	
END
