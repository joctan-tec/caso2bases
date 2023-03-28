-- vistas
USE Caso2;
/*
DROP VIEW IF EXISTS spNombreProcedure;

CREATE VIEW nombreVista AS
SELECT
FROM
;
*/

DROP VIEW IF EXISTS obtieneReceta;
CREATE VIEW obtieneReceta AS
SELECT prod.idProducto idProducto, prod.nombre Producto, ing.idIngrediente, ing.nombre Ingrediente, ingXprod.cantidad, um.nombre UnidadMedida  FROM Productos prod
INNER JOIN IngredientesXproductos ingXprod ON ingXprod.idProducto = prod.idProducto
INNER JOIN Ingredientes ing ON ingXprod.idIngrediente = ing.idIngrediente
INNER JOIN UnidadesMedida um ON um.idUnidadeMedida = ing.idUnidadeMedida;

#select * from obtieneReceta WHERE idProducto = 9;

DROP view IF EXISTS PreciosProductos;
CREATE VIEW PreciosProductos AS
SELECT valor as precio , productos.idProducto AS idproducto
FROM logprecios INNER JOIN productos ON productos.idProducto = logprecios.idProducto
WHERE logprecios.active = 1;


DROP view if exists PreciosProductosPlaya;
CREATE VIEW PreciosProductosPlaya AS
SELECT valor as precio , productos.idProducto AS idproducto, idPlaya
FROM precioproductoxplaya INNER JOIN productos ON productos.idProducto = precioproductoxplaya.idProducto 
WHERE precioproductoxplaya.active = 1 ;


DROP VIEW IF EXISTS ObtieneProductosVenta;

CREATE VIEW ObtieneProductosVenta AS
SELECT idProducto, cantidad, idventa FROM ProductosXventas;
