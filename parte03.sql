QUERY INCOMPLETA

-- Creación de la tabla "resumen"
CREATE TABLE IF NOT EXISTS resumen (
    pais_codigo character(2),
    cant_estrellas smallint,
    total_extra numeric(10, 2)
);

CREATE OR REPLACE FUNCTION generar_reporte()
RETURNS void AS $$
DECLARE
    codhotel integer;
    record_data record;
	cant integer;
BEGIN
    -- Elimina datos existentes en la tabla "resumen"
    DELETE FROM resumen;

    -- Llama a la función "ingreso_extra" para obtener los ingresos por tipo de habitación
    FOR codhotel IN
        SELECT DISTINCT hotel_codigo FROM hoteles
    LOOP
        -- Llama a la función "ingreso_extra" para obtener los ingresos por tipo de habitación
        FOR record_data IN
            SELECT * FROM ingreso_extra(codhotel)
        LOOP
			FOR cant IN
        		SELECT DISTINCT estrellas FROM hoteles
			LOOP	
				-- Inserta los resultados en la tabla "resumen"
				INSERT INTO resumen (pais_codigo, cant_estrellas, total_extra)
				SELECT p.pais_codigo, h.estrellas, SUM(record_data.monto) AS total_extra
				FROM paises p
				INNER JOIN hoteles h ON h.pais_codigo = p.pais_codigo
				WHERE h.hotel_codigo = codhotel AND h.estrellas = cant
				GROUP BY p.pais_codigo, h.estrellas;
				IF NOT FOUND THEN
					INSERT INTO resumen (pais_codigo, cant_estrellas, total_extra)
					SELECT p.pais_codigo, cant AS cant_estrellas, 0 AS total_extra
					FROM paises p
					INNER JOIN hoteles h ON h.pais_codigo = p.pais_codigo
					WHERE h.hotel_codigo = codhotel AND h.estrellas = cant
					GROUP BY p.pais_codigo, cant;
				END IF;
			END LOOP;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


SELECT generar_reporte();
select * from resumen order by pais_codigo, cant_estrellas desc
--select * from paises
--select * from hoteles
--select * from tipos_habitacion  
--select * from costos_habitacion
--select * from habitaciones where hotel_codigo = 2605099
--select * from estadias_anteriores
--select * from reservas_anteriores