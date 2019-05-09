-- 1. Conocer los datos de las sucursales que tengan más de 15 años
SELECT * 
    FROM sucursal JOIN (
        SELECT id_sucursal
            FROM sucursal
            WHERE ((fund - SYSDATE)/365.25 > 15));

-- 2. Conocer el puesto, nombre, edad y la fecha en la que inicio a trabajar de todos
-- los empleados.
SELECT puesto, nombre, edad, fecha_reg
    FROM (empleado NATURAL JOIN persona);

-- 3. Conocer el nombre y edad de todos los empleados que trabajan en mas de una
-- sucursal.
SELECT nombre, (fecha_nac - SYSDATE)/365.25) edad 
    FROM (
        SELECT id_empledo, count(id_empleado)
            FROM trabajar
            GROUP BY id_empleado
            HAVING count(id_empleado) > 1
    ) JOIN persona USING curp;

-- 4. Conocer los productos que se venden dentro de cada sucursal, para esto se debe
-- regresar el identificados de la sucursal, seguido del identificador del producto y
-- la descripción de éste.
SELECT id_sucursal, id_prod, descripcion
    FROM departamento NATURAL JOIN producto;
    
-- 5. Conocer los departamentos que tienen cada una de las sucursales.
SELECT id_sucursal, tipo 
    FROM departamento;

-- 6.  Conocer cuales son los departamentos que tienen en común todas las sucursales.

-- 7. Conocer el cliente mas antiguo (el primero en ser registrado, según la fecha de
-- registro) en el programa de tarjeta digital de cada una de las sucursales registradas.
-- falta agregar la fecha de registro en los clientes.
SELECT id_cliente, max(SYSDATE-fecha_reg)/365.25 antig
    FROM clientes
    GROUP BY id_cliente;