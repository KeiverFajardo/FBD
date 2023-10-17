CREATE TABLE IF NOT EXISTS resumen (
    pais_codigo character(2),
    cant_estrellas smallint,
    total_extra numeric(10, 2)
);

CREATE OR REPLACE FUNCTION generar_reporte()
RETURNS void AS $$
DECLARE
	codpais	integer;
    codhotel integer;
    record_data record;
	cant integer;
	dinerototal integer;
	montoTotal integer;
BEGIN
    DELETE FROM resumen;
	
    FOR codpais IN
        SELECT DISTINCT pais_codigo FROM paises
    LOOP
		FOR cant IN
        	SELECT DISTINCT estrellas FROM hoteles
		LOOP
			montoTotal := 0;
			FOR codhotel IN
				select hotel_codigo from hoteles h
					where h.pais_codigo = codpais.pais_codigo
				 	and h.estrellas = cant
			LOOP
				FOR dinerototal IN
					SELECT SUM(monto) as monto FROM ingreso_extra(codhotel)
				LOOP
					montoTotal := montoTotal + dinerototal.monto;
				END LOOP;
			END LOOP;
		INSERT INTO resumen (pais_codigo, cant_estrellas, total_extra) VALUES (codpais, cant, montoTotal);
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;