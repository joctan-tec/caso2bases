-- Stored Procedures
/*
DROP PROCEDURE IF EXISTS spNombreProcedure;
DELIMITER $$

CREATE PROCEDURE spNombreProcedure()
BEGIN

END$$
DELIMITER ;

*/

DROP PROCEDURE IF EXISTS generaFechasEnRango;
DELIMITER $$

CREATE PROCEDURE generaFechasEnRango(IN fecha1 DATE, IN fecha2 DATE)
BEGIN
	DECLARE fechaIt DATE DEFAULT fecha1;
	WHILE fechaIt <= fecha2 DO
	SET fechaIt = DATE_ADD(fechaIt, INTERVAL 1 DAY);
	SELECT fechaIt AS Fecha;

	END WHILE;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS RevisaIngredientes;
DELIMITER $$

CREATE PROCEDURE RevisaIngredientes(in spIdProducto smallint, in spIdCarrito smallint, in spIdCopero int, in spFecha datetime)
BEGIN
-- Declarar variables para almacenar los valores de las columnas
	DECLARE spIngrediente INT;
	DECLARE spCantidad DECIMAL(8,2);
    DECLARE spCantidadDisponible DECIMAL(8,2);

	-- Declarar el cursor para seleccionar todos los ingredientes
	DECLARE RecetaCursor CURSOR FOR select idIngrediente,cantidad 
									from obtieneReceta 
									WHERE idProducto = 9;

	-- Abrir el cursor
	OPEN RecetaCursor;

	-- Fetch the first row
	FETCH RecetaCursor INTO spIngrediente, spCantidad;

	-- Procesar las filas mientras haya datos
	WHILE @@FETCH_STATUS = 0 DO
		SET spCantidadDisponible = (select SUM(cantidad)
								   from inventariocarritolog
								   where idCarrito = spIdCarrito AND
										 idIngrediente=spIngrediente AND
										 fecha BETWEEN '2022-01-01 08:00:00' AND spFecha);
		
        IF (spCantidadDiponible - spCantidad) < spCantidad THEN
			SET @CantidadIngredienteNuevo = (select cantidad from inventariocarritolog
											where idInventarioCarritoLog = spIngrediente);
			INSERT INTO inventariocarrito
            (IdIngrediente, IdCarrito, Fecha, Cantidad, IdCoperoResponsable, TipoOperacion, CheckSum)
            VALUES (spIngrediente, spCarrito, spFecha,@CantidadIngredienteNuevo,0, 
					SHA2(CONCAT(spIngrediente,spIdCarrito,spIdCopero,spFecha ,@CantidadIngredienteNuevo,0,"feliz navidad"), 256));
		END IF;
            
	  -- Fetch the next row
	  FETCH RecetaCursor INTO spIngrediente, spCantidad;
	END WHILE;

	-- Cerrar y liberar el cursor
	CLOSE RecetaCursor;
	DEALLOCATE PREPARE RecetaCursor;

END$$
DELIMITER ;

