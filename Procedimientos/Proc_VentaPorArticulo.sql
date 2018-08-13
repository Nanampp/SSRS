-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 13/08/2018
-- Description:	El reporte visualiza por artículo, las unidades vendidas, el valor total de la venta bruta (sin tener en cuenta devoluciones), y el valor del impuesto, en un rango de fechas específico y un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_VentaPorArticulo] 
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
		SELECT ng.descrip nivel, g.id_grupo, gp.descrip
		FROM grupo g
		INNER JOIN grupo gp ON g.cod_grupo = gp.cod_grupo AND gp.subgrupo1 = '00' AND gp.subgrupo2 = '00' AND gp.subgrupo3 = '00' AND gp.subgrupo4 = '00'
		INNER JOIN dbo.grupo_nivel ng ON ng.id_grupo_nivel = gp.grp_nivel_id
	)

	--detalle ventas no efectivas
	SELECT  c.descrip as ciudad,
			l.cod_localidad as codigo,
			l.descrip as localidad,
			CONVERT(DATE,v.date_created) fecha, 
			#g.nivel nivel,
			#g.descrip AS grupo,
			a.cod_imp Cod_art,
			a.descrip1 Descr_art,
			SUM(va.cantidad) AS cantidad,   
			SUM(va.valor_venta) AS valor, 
			va.pctj_impuesto AS pctj_impuesto,
			SUM(va.impuesto) AS impuesto
	FROM venta AS v
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	LEFT JOIN dbo.ciudad c ON c.id_ciudad = l.id_ciudad
	INNER JOIN ventas_articulo AS va ON va.id_venta = v.id_venta
	INNER JOIN articulo a ON va.id_articulo = a.id_articulo
	LEFT JOIN #g ON a.id_grupo = #g.id_grupo
	WHERE   (v.id_tipo_transac = '0')
			AND v.date_created BETWEEN DATEADD(dd,0,@fechaInicial) AND DATEADD(dd,1,@fechaFinal)
			AND bruto_pstv <> 0
			AND @Localidades LIKE ('%' + l.cod_localidad + '%')
	GROUP BY c.descrip, l.cod_localidad, l.descrip, CONVERT(DATE,v.date_created), #g.nivel, #g.descrip, a.cod_imp, a.descrip1, va.pctj_impuesto
	HAVING SUM(va.valor_venta) > 0
	ORDER BY fecha, codigo, cod_art
END
