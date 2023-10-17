create or replace trigger control_costos
before update or delete on costos_habitacion
for each row
execute function control_costos_trigger();

create or replace function control_costos_trigger() returns trigger as $control_costos$
begin
 if TG_OP = 'DELETE' then
 if (exists (
   select 1
   from estadias_anteriores ea natural join costos_habitacion ch
   where ea.hotel_codigo = old.hotel_codigo
    and ea.nro_habitacion = old.nro_habitacion
    and not exists (
     select 1
     from costos_habitacion ch2
     where ch2.hotel_codigo = ch.hotel_codigo
      and ch2.nro_habitacion = ch.nro_habitacion
      and ch2.fecha_desde <= ea.check_in
      and ch2.fecha_desde <> old.fecha_desde
    )
  )) then
   raise notice 'La operación de borrado no es correcta';
   return null;
  end if;
  return old;
 elseif TG_OP = 'UPDATE' then
  if (new.fecha_desde > old.fecha_desde) then
   if (exists (
    select 1
    from estadias_anteriores ea
    where ea.hotel_codigo = old.hotel_codigo
     and ea.nro_habitacion = old.nro_habitacion
     and not exists (
      select 1
      from costos_habitacion ch
      where ch.hotel_codigo = old.hotel_codigo
       and ch.nro_habitacion = old.nro_habitacion
       and (
         (ch.fecha_desde <= ea.check_in and ch.fecha_desde <> old.fecha_desde)
         or
         (new.fecha_desde <= ea.check_in)
        )
     )
   )) then
    raise notice 'La actualización no es correcta';
    return old;
   end if;
  end if;
  return new;
 end if;
end
$control_costos$ language plpgsql;