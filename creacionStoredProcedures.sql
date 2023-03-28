-- Stored Procedures
USE Caso2;
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

CREATE PROCEDURE RevisaIngredientes(in spIdProducto smallint, in spIdCarrito INT,
									in spIdCopero int, in spFecha datetime,IN spCantidadProd SMALLINT)
BEGIN
-- Declarar variables para almacenar los valores de las columnas
	DECLARE spIngrediente INT;
	DECLARE spCantidad DECIMAL(8,2);
    DECLARE spCantidadDisponible DECIMAL(8,2);

	-- Declarar el cursor para seleccionar todos los ingredientes
	DECLARE RecetaCursor CURSOR FOR select idIngrediente,cantidad 
									from obtieneReceta 
									WHERE idProducto = 9;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET @done = true;

	-- Abrir el cursor
	OPEN RecetaCursor;

	-- Fetch the first row
	FETCH RecetaCursor INTO spIngrediente, spCantidad;
    IF @done  THEN
		SET @done = false;
	  END IF;
	#SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "aqui abajo 1";
	-- Procesar las filas mientras haya datos
	read_loop : loop
		SET spCantidadDisponible = (select SUM(cantidad)
								   from inventariocarritolog
								   where idCarrito = spIdCarrito AND
										 idIngrediente=spIngrediente AND
										 fecha BETWEEN '2022-01-01 08:00:00' AND spFecha);
		
        IF (spCantidadDisponible - (spCantidad*spCantidadProd)) < spCantidad THEN
			SET @CantidadIngredienteNuevo = (select cantidad from inventariocarritolog
											where idInventarioCarritoLog = spIngrediente);
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = spIdCarrito;
			INSERT INTO inventariocarritolog
            (IdIngrediente, IdCarrito, Fecha, Cantidad, IdCoperoResponsable, TipoOperacion, CheckSum)
            VALUES (spIngrediente, spIdCarrito, spFecha,@CantidadIngredienteNuevo,spIdCopero,0, 
					SHA2(CONCAT(spIngrediente,spIdCarrito,spIdCopero,spFecha ,@CantidadIngredienteNuevo,0,"feliz navidad"), 256));
		END IF;
            
	  -- Fetch the next row
	  FETCH RecetaCursor INTO spIngrediente, spCantidad;
      IF @done  THEN
		LEAVE read_loop;
	  END IF;
	END LOOP;

	-- Cerrar y liberar el cursor
	CLOSE RecetaCursor;
	

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS spExtraerIngredientes;
DELIMITER $$

CREATE PROCEDURE spExtraerIngredientes(in spIdProducto smallint, in spIdCarrito INT,  in spIdCopero int, in spCantidadProd smallint,
										IN spFecha DATETIME)
BEGIN
-- Declarar variables para almacenar los valores de las columnas
	DECLARE spIngrediente INT;
	DECLARE spCantidad DECIMAL(8,2);

	-- Declarar el cursor para seleccionar todos los ingredientes
	DECLARE RecetaCursor CURSOR FOR select idIngrediente,cantidad 
									from obtieneReceta 
									WHERE idProducto = spIdProducto;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET @done = true;
	-- Abrir el cursor
	OPEN RecetaCursor;

	-- Fetch the first row
	FETCH RecetaCursor INTO spIngrediente, spCantidad;
    IF @done  THEN
		SET @done = false;
	  END IF;
	#SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "aqui abajo 2";
	-- Procesar las filas mientras haya datos
	read_loop : loop
			#SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "aqui abajo 1";
            
			INSERT INTO inventariocarritolog
            (IdIngrediente, IdCarrito, Fecha, Cantidad, IdCoperoResponsable, TipoOperacion, CheckSum)
            VALUES (spIngrediente, spIdCarrito, spFecha,(spCantidad * spCantidadProd * -1), spIdCopero, 1, 
					SHA2(CONCAT(spIngrediente,spIdCarrito,spIdCopero,spFecha , (spCantidad * spCantidadProd *-1) ,1,"feliz navidad"), 256));

	  -- Fetch the next row
	  FETCH RecetaCursor INTO spIngrediente, spCantidad;
      
	  IF @done  THEN
		LEAVE read_loop;
	  END IF;
	END LOOP;

	-- Cerrar y liberar el cursor
	CLOSE RecetaCursor;
	
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS spProductoXventa;
DELIMITER $$

CREATE PROCEDURE spProductoXventa(in spIdVenta int)
BEGIN
	DECLARE Producto1 INT DEFAULT FLOOR(RAND() * 11) + 1;
    DECLARE Producto2 INT DEFAULT FLOOR(RAND() * 11) + 1;
    DECLARE Cantidad1 INT DEFAULT FLOOR(RAND() * 3) + 1;
    DECLARE Cantidad2 INT DEFAULT FLOOR(RAND() * 3) + 1;
    WHILE Producto1 = Producto2 DO
		SET Producto2 = FLOOR(RAND() * 11) + 1;
	END WHILE;
    INSERT INTO productosxventas (Idproducto, IdVenta, cantidad , checkSum) Values
    (Producto1, spIdVenta, Cantidad1 , SHA2(CONCAT(Producto1, Cantidad1, spIdVenta,"All For One"), 256)),
    (Producto2, spIdVenta, Cantidad2 , SHA2(CONCAT(Producto2, Cantidad1, spIdVenta,"All For One"), 256));

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS spReportes;
DELIMITER $$

CREATE PROCEDURE spReportes(IN spIdTurno SMALLINT, IN spFecha DATETIME )
BEGIN
	DECLARE spContador TINYINT DEFAULT 1;
    DECLARE spIdCopero INT;
    DECLARE spIdCarrito INT;
    DECLARE spIdReporte INT;
    
    WHILE spContador < 16 DO
		SET spIdCopero = spContador + (15 * (spIdTurno -1));
        SET spIdCarrito = (spIdCopero-15*(spIdTurno-1));
        INSERT INTO reportes (IdCopero, IdCarrito, IdTurno, Fecha, checkSum) Values
        (spIdCopero, spIdCarrito, spIdTurno, DATE(spFecha),SHA2(CONCAT(spIdCopero, spIdCarrito, spIdTurno, DATE(spFecha),"All For One"), 256));
        SET spIdReporte = last_insert_id();
        call spReporteCaja(spIdReporte,spIdTurno,spContador, spFecha ); 
        SET spContador = spContador +1;
    END WHILE;    

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS spReporteCaja;
DELIMITER $$

CREATE PROCEDURE spReporteCaja(IN spIdReporte INT, IN spTurno SMALLINT, IN spContador TINYINT, IN spFecha DATETIME)
BEGIN
	DECLARE spIdCoperoEntrega INT;
    DECLARE IsAgree BIT DEFAULT 1;
    DECLARE spDinero DECIMAL(11,2);
    DECLARE Fecha DATETIME DEFAULT spFecha;
    
    IF spTurno = 1 THEN 
		SET spTurno = 3;
        SET Fecha = DATE_ADD(spFecha, INTERVAL -1 DAY);
	END IF ;
    SET spIdCoperoEntrega = spContador + (15 * (spTurno -1));
    SET spDinero =COALESCE((SELECT SUM(COALESCE((Pago - Vuelto),0.00)) FROM Ventas
                        WHERE spIdCoperoEntrega = Ventas.IdCopero AND
                        DATE(spFecha)=DATE(fecha)),0.00);
                        
	
	INSERT INTO reportesxcajas (IdReporte, IdCoperoEntrega, IsAgree, Dinero, checkSum) VALUES
    (spIdReporte, spIdCoperoEntrega,1, spDinero,SHA2(CONCAT(spIdReporte, spIdCoperoEntrega,1, spDinero,"All For One"), 256));
    
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS spRegistraVentas;
DELIMITER $$

CREATE PROCEDURE spRegistraVentas(IN spFecha DATETIME, in spTurno SMALLINT)
BEGIN
	DECLARE spIdPlaya SMALLINT DEFAULT (FLOOR(RAND() * 3) + 1);

    DECLARE spIdComision INT DEFAULT (SELECT idComisionLog FROM ComisionesLogs where enabled = 1);
    DECLARE spIdCopero INT DEFAULT (SELECT idCopero FROM Reportes 
                                    INNER JOIN CarritosXplayas ON Reportes.idCarrito = CarritosXplayas.idCarrito
                                    WHERE CarritosXplayas.idPlaya = spIdPlaya AND
                                    Reportes.fecha = DATE(spFecha) AND
                                    idTurno = spTurno
                                    ORDER BY RAND() LIMIT 1);
	DECLARE spIdCarrito INT DEFAULT (spIdCopero-15*(spTurno-1));
	
	INSERT INTO Ventas (idPlaya, idCopero, idComisionLog, fecha, deleted) VALUES
					  (spIdPlaya, spIdCopero, spIdComision, spFecha, 0);
	SET @idVenta = (SELECT last_insert_id());
    
    CALL spProductoXventa(@idVenta);
    
    SET @Prod1 = (SELECT idProducto FROM ObtieneProductosVenta WHERE idventa= @idVenta LIMIT 1);
    SET @Cantidad1 =  (SELECT Cantidad FROM ObtieneProductosVenta WHERE idventa= @idVenta LIMIT 1);
    SET @Prod2 = (SELECT idProducto FROM ObtieneProductosVenta WHERE idventa= @idVenta ORDER BY idProducto DESC Limit 1);
    SET @Cantidad2 = (SELECT Cantidad FROM ObtieneProductosVenta WHERE idventa= @idVenta ORDER BY idProducto DESC Limit 1);
    
    
    CALL RevisaIngredientes(@Prod1, spIdCarrito, spIdCopero, spFecha, @Cantidad1);
    CALL RevisaIngredientes(@Prod2, spIdCarrito, spIdCopero, spFecha, @Cantidad2);
    
    
    SET @CantiPagar = (select SUM(cantidad * (SELECT coalesce((select precio from PreciosProductosPlaya 
						where idproducto = pxv.idProducto
						AND idPlaya = spIdPlaya),
					  (select precio from PreciosProductos where idproducto = pxv.idProducto))))
					  from ProductosXventas pxv WHERE idVenta =  @idVenta);
                      
	SET @Pago = @CantiPagar + FLOOR((FLOOR(RAND() * 5) + 1)*1000)+1000;
    UPDATE Ventas SET pago = @Pago, vuelto = @CantiPagar-@Pago
    WHERE idVenta = @idVenta;
    
	CALL spExtraerIngredientes(@Prod1,spIdCarrito,spIdCopero,@Cantidad1,spFecha);
    CALL spExtraerIngredientes(@Prod2,spIdCarrito,spIdCopero,@Cantidad2, spFecha);

					
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS spGeneraVentas;
DELIMITER $$

CREATE PROCEDURE spGeneraVentas(IN spFechaInicio DATETIME, IN spFechaFin DATETIME)
BEGIN
	DECLARE contadorVentas BIGINT DEFAULT 1;
    DECLARE fechaActual DATETIME DEFAULT spFechaInicio ; 
    DECLARE CantiVentasDia SMALLINT;
    DECLARE VentasXturno SMALLINT;
    DECLARE ContadorTurno SMALLINT default 1;
    
    WHILE fechaActual <= spFechaFin DO
		SET CantiVentasDia = FLOOR(RAND() * 60) + 10;
        SET VentasXturno = FLOOR(CantiVentasDia/3)+4;
        SET ContadorTurno = 1;
        WHILE ContadorTurno < 4 DO
			CALL spReportes(ContadorTurno,fechaActual);
            SET @Contador = 0;
            WHILE  @Contador < VentasXturno DO
				CALL spRegistraVentas(fechaActual, ContadorTurno);
                SET @Contador = @Contador+1;
			END WHILE;
             SET ContadorTurno = ContadorTurno+1;
		END WHILE;
        SET fechaActual=DATE_ADD(fechaActual,INTERVAL 1 DAY);
	END WHILE;
        
END$$
DELIMITER ;

