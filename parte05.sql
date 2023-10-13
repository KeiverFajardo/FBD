-- Creación de la tabla "registro_uso"
CREATE TABLE IF NOT EXISTS registro_uso (
    usuario text NOT NULL,
    tabla name NOT NULL,
    fecha date NOT NULL,
    cantidad integer NOT NULL,
    PRIMARY KEY (usuario, tabla, fecha)
);

-- Trigger para las tablas "estadias_anteriores", "reservas_anteriores" y "clientes"
CREATE OR REPLACE FUNCTION registro_operaciones_triggers()
RETURNS TRIGGER AS $$
BEGIN
    -- Incrementa la cantidad de operaciones en la tabla "registro_uso"
    INSERT INTO registro_uso (usuario, tabla, fecha, cantidad)
    VALUES (current_user, TG_TABLE_NAME::name, current_date, 1)
    ON CONFLICT (usuario, tabla, fecha)
    DO UPDATE
    SET cantidad = registro_uso.cantidad + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Asociar el trigger a las tres tablas
CREATE TRIGGER registro_operaciones
AFTER INSERT OR UPDATE OR DELETE ON reservas_anteriores
FOR EACH STATEMENT
EXECUTE FUNCTION registro_operaciones_triggers();

CREATE TRIGGER registro_operaciones
AFTER INSERT OR UPDATE OR DELETE ON estadias_anteriores
FOR EACH STATEMENT
EXECUTE FUNCTION registro_operaciones_triggers();

CREATE TRIGGER registro_operaciones
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH STATEMENT
EXECUTE FUNCTION registro_operaciones_triggers();

select * from estadias_anteriores

delete from estadias_anteriores where hotel_codigo = 6255143 and cliente_documento = 4676498

select * from registro_uso
