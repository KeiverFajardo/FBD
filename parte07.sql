CREATE TABLE IF NOT EXISTS finguitos_usuarios (
 cliente_documento int not null,
 hotel_codigo int not null,
 check_in date not null,
 check_out date not null,
 fecha_inicio date not null,
 fecha_fin date not null,
 finguitos integer not null,
 fecha_operacion timestamp not null,
 estado smallint not null,
 primary key (cliente_documento, hotel_codigo, check_in)
)

create or replace trigger finguitos
after insert or update or delete on estadias_anteriores
for each row
execute procedure finguitos_trigger();

create or replace function finguitos_trigger() returns trigger as $finguitos$
declare
 cant_finguitos int;
 precio_por_noche int;
 new_estado int;
begin
 select precio_noche
 into precio_por_noche
 from costos_habitacion ch
 where ch.hotel_codigo = new.hotel_codigo
 and ch.nro_habitacion = new.nro_habitacion
  and not exists (
   select 1
   from costos_habitacion ch2
   where ch2.hotel_codigo = ch.hotel_codigo
    and ch2.nro_habitacion = ch.nro_habitacion
    and ch2.fecha_desde > ch.fecha_desde
  );

 cant_finguitos := trunc((new.check_out - new.check_in) * precio_por_noche / 10);

 if TG_OP = 'INSERT' then
  -- Si existe una estadia previa en ese hotel, entonces le sumo 5 finguitos mas
  if (exists (
   select 1
   from estadias_anteriores ea
   where ea.hotel_codigo = new.hotel_codigo
    and ea.cliente_documento = new.cliente_documento
  )) then
   cant_finguitos := cant_finguitos + 5;
  end if;

  insert into finguitos_usuarios (
   cliente_documento,
   hotel_codigo,
   check_in,
   check_out,
   fecha_inicio,
   fecha_fin,
   finguitos,
   fecha_operacion,
   estado
  ) values (
   new.cliente_documento,
   new.hotel_codigo,
   new.check_in,
   new.check_out,
   new.check_in + interval '1 month',
   new.check_out + interval '1 month',
   cant_finguitos,
   now(),
   1
  );

  -- verificar finguitos vencidos
     update finguitos_usuarios
     set estado = 2
     where cliente_documento = new.cliente_documento
      and fecha_fin < current_date;
 return new;
    elsif TG_OP = 'UPDATE' then
     if (new.check_out + interval '1 month' > current_date) then
      new_estado = 1;
     else
      new_estado = 2;
     end if;

     update finguitos_usuarios
     set check_in = new.check_in,
      check_out = new.check_out,
      finguitos = cant_finguitos,
      fecha_inicio = new.check_in + interval '1 month',
   fecha_fin = new.check_out + interval '1 month',
   fecha_operacion = now(),
   estado = new_estado
     where hotel_codigo = old.hotel_codigo
      and cliente_documento = old.cliente_documento
      and check_in = old.check_in
      and check_out = old.check_out;

     -- verificar finguitos vencidos
     update finguitos_usuarios
     set estado = 2
     where cliente_documento = new.cliente_documento
      and fecha_fin < current_date;
    return new;
    elsif TG_OP = 'DELETE' then
     update finguitos_usuarios
     set estado = 3
     where hotel_codigo = old.hotel_codigo
      and cliente_documento = old.cliente_documento
      and check_in = old.check_in
      and check_out = old.check_out;
    return old;
    end if;
end;
$finguitos$ language plpgsql;