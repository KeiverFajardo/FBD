CREATE OR REPLACE FUNCTION actividad_cliente(codigo char(1), clientedoc integer, anio integer)
RETURNS integer AS $$
DECLARE
	cantidad integer;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM clientes WHERE cliente_documento = clientedoc) THEN
        RAISE NOTICE 'No existe el cliente';
        RETURN -1;
    END IF;
    IF codigo NOT IN ('R', 'r', 'E', 'e') THEN
        RAISE NOTICE 'Código de operación incorrecto';
        RETURN -1;
    END IF;
	
	IF codigo IN ('R', 'r') THEN
        SELECT DISTINCT COUNT(*) INTO cantidad
        FROM reservas_anteriores
        WHERE cliente_documento = clientedoc AND EXTRACT(YEAR FROM fecha_reserva) = anio;
    ELSE
        SELECT DISTINCT COUNT(*) INTO cantidad
        FROM estadias_anteriores
        WHERE cliente_documento = clientedoc AND EXTRACT(YEAR FROM check_in) = anio;
    END IF;
	RETURN cantidad;
END;
$$ LANGUAGE plpgsql;


