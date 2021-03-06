-- ========================================================================== --
--                              CONSULTAS                                     --
-- ========================================================================== --


-- ========================================================================== --

-- 1. Conocer los datos de las sucursales que tengan más de 15 años
SELECT * 
    FROM sucursal NATURAL JOIN (
        SELECT id_sucursal
            FROM sucursal
            WHERE ((CURRENT_DATE - fecha_func)/365.25 > 15)
    );
-- ========================================================================== --

-- ========================================================================== --
-- 2. Conocer el puesto, nombre, edad y la fecha en la que inicio a trabajar de todos
-- los empleados.
SELECT puesto, nombre, (CURRENT_DATE - fecha_nac)/365.25 edad, registro fecha_inicio
    FROM (empleado NATURAL JOIN persona);
-- ========================================================================== --

-- ========================================================================== --
-- 3. Conocer el nombre y edad de todos los empleados que trabajan en mas de una
-- sucursal.
SELECT nombre, ((CURRENT_DATE - fecha_nac)/365.25) edad 
    FROM (
        SELECT id_empleado, COUNT(id_empleado)
            FROM trabajar
            GROUP BY id_empleado
            HAVING COUNT(id_empleado) > 1
    ) NATURAL JOIN persona;
-- ========================================================================== --

-- ========================================================================== --
-- 4. Conocer los productos que se venden dentro de cada sucursal, para esto se debe
-- regresar el identificados de la sucursal, seguido del identificador del producto y
-- la descripción de éste.
SELECT id_sucursal, id_producto, descripcion
    FROM instancia_producto
    ORDER BY id_sucursal, id_producto;

-- ========================================================================== --

-- ========================================================================== --
-- 5. Conocer los departamentos que tienen cada una de las sucursales.
SELECT *
    FROM tener_departamento;

-- ========================================================================== --

-- ========================================================================== --
-- 6.  Conocer cuales son los departamentos que tienen en comun todas las sucursales.
-- ========================================================================== --
SELECT id_tipo 
    FROM (
        SELECT DISTINCT id_tipo, COUNT(id_suc)
            FROM tener_departamento
            GROUP BY id_tipo
            HAVING COUNT(id_suc) = (SELECT COUNT(id_sucursal) FROM sucursal)
    );

-- ========================================================================== --
-- 7. Conocer el cliente mas antiguo (el primero en ser registrado, según la fecha de
-- registro) en el programa de tarjeta digital de cada una de las sucursales registradas.
-- falta agregar la fecha de registro en los clientes.
SELECT id_cliente, MAX(CURRENT_DATE - fecha_reg)/365.25 antig
    FROM cliente
    GROUP BY id_cliente;

-- ========================================================================== --

-- ========================================================================== --
-- 8. Conocer cuales son los productos que tienen en común cada uno de los departamentos de las diferentes sucursales.
SELECT DISTINCT id_producto
    FROM (SELECT COUNT(id_departamento) aa, id_producto
            FROM instancia_producto
            GROUP BY id_producto)
    WHERE aa = 3;
-- ========================================================================== --

-- ========================================================================== --
-- 9. Conocer cuales son TODOS los productos que se tienen en cada uno de los
--departamentos de las diferentes sucursales.
SELECT id_suc Sucursal, id_departamento Departamento, id_producto Producto
    FROM (tener_departamento NATURAL JOIN instancia_producto)
    ORDER BY id_suc, id_departamento;
-- ========================================================================== --

-- ========================================================================== --
-- 10. Conocer cuál es la sucursal con mayor número de productos registrados en sus
--diferentes departamentos.
--NOTA: en caso de empate, regresa todas las que cumplen el criterio (no única).
SELECT id_suc
    FROM ((SELECT id_suc, woop1
            FROM (
                SELECT id_suc, SUM(woop) woop1
                    FROM (SELECT id_suc, COUNT(id_producto) woop
                            FROM (tener_departamento NATURAL JOIN instancia_producto)
                            GROUP BY id_suc
                    )
                 GROUP BY id_suc
            )
            GROUP BY id_suc, woop1
        )CROSS JOIN (SELECT MAX(woop1) w
                        FROM ( SELECT SUM(woop) woop1
                                FROM (SELECT id_suc, COUNT(id_producto) woop
                                        FROM (tener_departamento NATURAL JOIN instancia_producto)
                                        GROUP BY id_suc
                                )
                        )
                    )
    )
    WHERE woop1 = w;
-- ========================================================================== --

-- ========================================================================== --
-- 11. Eliminar a los empleados que tengan más de 3 trabajos en diferentes sucursales.
DELETE FROM Empleado
    WHERE  id_empleado 
        IN ( SELECT id_empleado
                FROM (SELECT id_empleado
                        FROM trabajar
                        GROUP BY id_empleado
                        HAVING COUNT(id_empleado) > 3
                ) NATURAL JOIN persona
        );
-- ========================================================================== --

-- ========================================================================== --
-- 12. Eliminar a las sucursales que tengan menos de 1 departamentos registrados.
DELETE FROM sucursal 
    WHERE id_sucursal NOT IN (
         SELECT id_suc FROM tener_departamento 
    );
-- ========================================================================== --

-- ========================================================================== --
-- 13. Eliminar a los clientes que no hayan utilizado su tarjeta digital en los �ltimos 3
--     meses.
DELETE FROM cliente 
    WHERE id_cliente IN (
        SELECT id_cliente 
            FROM tarjeta
            WHERE num_tarjeta IN (
                SELECT num_tarjeta
                    FROM venta
                    WHERE TO_CHAR(fecha, 'YEAR') LIKE TO_CHAR(CURRENT_DATE, 'YEAR')
                        AND EXTRACT(MONTH FROM fecha) >= (EXTRACT(MONTH FROM CURRENT_DATE)-3)
            )
        );
-- ========================================================================== --

-- ========================================================================== --
-- 14. Insertar una sucursal en el estado de M�xico.
INSERT INTO sucursal (fecha_func, calle, numero, cp, estado) VALUES
  (CURRENT_DATE, 'Urawa', '100', '50150', 'MEX');
-- ========================================================================== --

-- ========================================================================== --
-- 15. Insertar la informacion de 3 departamentos a la sucursal que fue insertada anteriormente
INSERT INTO tener_departamento
    SELECT id_sucursal, tipo
    FROM (
        SELECT id_sucursal 
            FROM sucursal 
            WHERE calle = 'Urawa' AND numero = '100' AND cp = '50150'
    )
    , tipo_departamento
    WHERE ROWNUM <= 3;
-- ========================================================================== --

-- ========================================================================== --
-- 16. Actualizar el numero de departamentos de la sucursal con menor numero de
--     estos, para que ahora tenga la misma cantidad de departamentos que la sucursal
--     con mayor numero de departamentos.

INSERT INTO tener_departamento(id_suc, id_tipo)
 SELECT id_suc, id_tipo 
 FROM ((SELECT id_suc
        FROM(SELECT id_suc, COUNT(id_suc) as num_tipo 
             FROM tener_departamento 
             GROUP BY id_suc ) 
        WHERE num_tipo = (SELECT MIN(num_tipo) AS minimos
                          FROM(SELECT COUNT(id_suc) AS num_tipo 
                               FROM tener_departamento 
                               GROUP BY id_suc )))),
      ((SELECT id_tipo 
        FROM tener_departamento
        WHERE id_suc = (SELECT id_suc 
                        FROM (SELECT id_suc
                               FROM(SELECT id_suc, COUNT(id_suc) AS num_tipo 
                                    FROM tener_departamento 
                                    GROUP BY id_suc )
                               WHERE num_tipo = (SELECT MAX(num_tipo) AS maximos
                                                  FROM(SELECT COUNT(id_suc) AS num_tipo 
                                                        FROM tener_departamento 
                                                        GROUP BY id_suc )))
                        WHERE ROWNUM = 1))
         MINUS                                                                   
         (SELECT id_tipo 
          FROM tener_departamento                                                                    
          WHERE id_suc = (SELECT id_suc
                          FROM(SELECT id_suc, COUNT(id_suc) as num_tipo 
                               FROM tener_departamento 
                               GROUP BY id_suc ) 
                          WHERE num_tipo = (SELECT MIN(num_tipo) AS minimos
                                           FROM(SELECT COUNT(id_suc) AS num_tipo 
                                                FROM tener_departamento 
                                                GROUP BY id_suc ))
                          AND ROWNUM = 1)));
                                      
-- ========================================================================== --
-- ========================================================================== --
