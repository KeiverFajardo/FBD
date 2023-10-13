
CREATE OR REPLACE FUNCTION ingreso_extra(codhotel integer, OUT tipohab smallint, OUT monto numeric(8, 2))
RETURNS SETOF record AS $$
BEGIN
    RETURN QUERY
	SELECT h.tipo_habitacion_codigo, 
		SUM(
            CASE
                WHEN ch.precio_noche IS NOT NULL THEN
                    ch.precio_noche * (e.check_out - e.check_in)
                ELSE
                    0
            END
        ) AS monto
		--SUM(ch.precio_noche * (e.check_out - e.check_in)) AS monto
	FROM hoteles a
	INNER JOIN habitaciones h 
		ON h.hotel_codigo = a.hotel_codigo AND h.hotel_codigo = codhotel
	INNER JOIN estadias_anteriores e 
		ON h.hotel_codigo = e.hotel_codigo AND h.nro_habitacion = e.nro_habitacion
	INNER JOIN costos_habitacion ch 	
		ON ch.hotel_codigo = e.hotel_codigo AND ch.nro_habitacion = e.nro_habitacion
	WHERE NOT EXISTS (SELECT * 
					  FROM reservas_anteriores r 
					  WHERE r.hotel_codigo = e.hotel_codigo 
					  AND r.nro_habitacion = e.nro_habitacion
					  AND r.check_in = e.check_in
					)
		AND e.check_in >= ch.fecha_desde
		AND NOT EXISTS 
			( SELECT 1
				FROM costos_habitacion c2
				WHERE e.hotel_codigo = c2.hotel_codigo
				AND e.nro_habitacion = c2.nro_habitacion
				AND e.check_in >= c2.fecha_desde
				AND c2.fecha_desde > ch.fecha_desde 
			)
	GROUP BY h.tipo_habitacion_codigo
	ORDER BY h.tipo_habitacion_codigo ASC;
    RETURN;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM ingreso_extra(2605099)
--SELECT * FROM ingreso_extra(6461800)
--SELECT * FROM ingreso_extra(6464350)

--select * from hoteles
--select * from tipos_habitacion  
--select * from costos_habitacion
--select * from habitaciones where hotel_codigo = 2605099
--select * from estadias_anteriores
--select * from reservas_anteriores