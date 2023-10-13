-- Creación del trigger control_costos
CREATE OR REPLACE FUNCTION before_delete_or_update_costos_habitacion()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si la operación de borrado o actualización afectará a alguna estadía
    IF EXISTS (
        SELECT 1
        FROM estadias_anteriores e
        WHERE e.nro_habitacion = OLD.nro_habitacion
        AND e.check_in <= OLD.fecha_desde
    ) THEN
        -- Si afecta una estadía, mostrar mensaje de error y evitar la operación
        IF TG_OP = 'DELETE' THEN
            RAISE NOTICE 'La operación de borrado no es correcta';
        ELSIF TG_OP = 'UPDATE' THEN
            RAISE NOTICE 'La actualización no es correcta';
        END IF;
    END IF;

    -- Si no afecta ninguna estadía, permitir la operación
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creación del trigger en la tabla costos_habitacion
CREATE TRIGGER control_costos
BEFORE DELETE OR UPDATE ON costos_habitacion
FOR EACH ROW
EXECUTE FUNCTION before_delete_or_update_costos_habitacion();

--select max(costo_noche) from costos_habitacion
--DELETE FROM costos_habitacion where costo_noche > 49
--DELETE FROM costos_habitacion where costo_noche > 50
