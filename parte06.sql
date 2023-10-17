CREATE SEQUENCE logidseq
 START WITH 1
 INCREMENT BY 1
 NO MAXVALUE
 NO CYCLE;

CREATE TABLE IF NOT EXISTS audit_estadia(
 idop integer default nextval('logidseq') NOT NULL,
 accion char(1) NOT NULL,
 fecha date NOT NULL,
 usuario text NOT NULL,
 cliente_documento integer NOT NULL,
 hotel_codigo integer NOT NULL,
 nro_habitacion smallint NOT NULL,
 check_in date NOT NULL,
 PRIMARY KEY (idop)
);

CREATE OR REPLACE FUNCTION auditoria_estadias_fun() RETURNS TRIGGER AS $$
DECLARE
    accion char(1);
    prev_cliente_documento integer;
    prev_hotel_codigo integer;
    prev_nro_habitacion smallint;
    prev_check_in date;
BEGIN
    IF TG_OP = 'INSERT' THEN
        accion = 'I';
        prev_cliente_documento = NEW.cliente_documento;
        prev_hotel_codigo = NEW.hotel_codigo;
        prev_nro_habitacion = NEW.nro_habitacion;
        prev_check_in = NEW.check_in;
    ELSIF TG_OP = 'UPDATE' THEN
        accion = 'U';
        prev_cliente_documento = OLD.cliente_documento;
        prev_hotel_codigo = OLD.hotel_codigo;
        prev_nro_habitacion = OLD.nro_habitacion;
        prev_check_in = OLD.check_in;
    ELSIF TG_OP = 'DELETE' THEN
        accion = 'D';
        prev_cliente_documento = OLD.cliente_documento;
        prev_hotel_codigo = OLD.hotel_codigo;
        prev_nro_habitacion = OLD.nro_habitacion;
        prev_check_in = OLD.check_in;
    END IF;

    -- Realizar un solo INSERT usando la variable
    INSERT INTO audit_estadia (accion, fecha, usuario, cliente_documento, hotel_codigo, nro_habitacion, check_in)
    VALUES (accion, current_date, current_user, prev_cliente_documento, prev_hotel_codigo, prev_nro_habitacion, prev_check_in);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auditoria_estadias
AFTER INSERT OR UPDATE OR DELETE ON estadias_anteriores
FOR EACH ROW
EXECUTE FUNCTION auditoria_estadias_fun();