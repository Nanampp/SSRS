-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 23/08/2018
-- Description: El reporte visualiza por localidad, la cantidad de clientes y el valor de la venta bruta, la venta neta, las anulaciones, las cancelaciones, los préstamos, las recogidas, y descuentos para un rango de fechas específico y para un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_ContabilidadConsolidada]  
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
	WITH ve AS (
		SELECT  v.id_venta,
				l.cod_localidad as codigo,
				l.descrip as localidad,
				convert(date,v.date_created) fecha, 
				case when v.cod_tipo_transac = '0' and v.bruto_pstv = 0 and v.bruto_ngtv <> 0 then '20' 
				else v.cod_tipo_transac end cod_tipo_transac,
				vr.descrip, 
				case when v.cod_tipo_transac = '3' then isnull(sum(vmp.valor),0) else v.bruto_pstv end pstv, 
				case when v.cod_tipo_transac = '4' then isnull(sum(vmp.valor),0) else v.bruto_ngtv end ngtv, 
				case when v.cod_tipo_transac = '0' then isnull(sum(vmp.valor),0) else 0 end valormp
		from venta v
		INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
		LEFT JOIN ventas_recogida vr on vr.id_venta = v.id_venta
		LEFT JOIN ventas_medios_pago vmp on vmp.id_venta = v.id_venta and (v.id_tipo_transac in ('3','4') or vmp.id_medio_pago <> '1')
		WHERE   @Localidades LIKE ('%' + l.cod_localidad + '%') 
				AND v.date_created between dateadd(dd,0,@fechaInicial) and dateadd(dd,1,@fechaFinal)
		GROUP BY v.id_venta, l.cod_localidad, l.descrip, convert(date,v.date_created), v.cod_tipo_transac, case when v.cod_tipo_transac = '0' and v.bruto_pstv = 0 and v.bruto_ngtv <>0 then '20' else v.cod_tipo_transac end, vr.descrip,v.bruto_pstv, v.bruto_ngtv
	)

	SELECT  inter.codigo,
			inter.localidad, 
			inter.fecha, 
			inter.cod_tipo_transac,  
			sum(inter.pstv) pstv,
			sum(inter.ngtv) ngtv, 
			sum(inter.valormp) valormp, 
			sum(inter.nro) nro, 
			sum(inter.cantidadPositiva) cantidadPositiva, 
			sum(inter.cantidadNegativa) cantidadNegativa
	FROM (	SELECT  ve.codigo,
					ve.localidad, 
					ve.fecha, 
					ve.cod_tipo_transac,  
					ve.pstv,
					ve.ngtv, 
					ve.valormp, 
					COUNT(DISTINCT ve.id_venta) nro, 
					SUM(case when va.cantidad > 0 then va.cantidad else 0 end) cantidadPositiva, 
					SUM(case when va.cantidad < 0 then va.cantidad else 0 end) cantidadNegativa 
			FROM ve
			LEFT JOIN ventas_articulo va on va.id_venta = ve.id_venta 
			GROUP BY ve.id_venta, ve.codigo, ve.localidad, ve.fecha, ve.cod_tipo_transac, ve.pstv, ve.ngtv, ve.valormp) as inter
	GROUP BY inter.codigo, inter.localidad, inter.fecha, inter.cod_tipo_transac
END
GO
