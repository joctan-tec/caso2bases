-- vistas
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

DROP view PreciosProductos;
CREATE VIEW PreciosProductos AS
SELECT valor as precio , productos.idProducto AS idproducto
FROM logprecios INNER JOIN productos ON productos.idProducto = logprecios.idProducto
WHERE logprecios.active = 1;

select precio from PreciosProductos where idproducto = 9 ;

DROP view if exists PreciosProductosPlaya;
CREATE VIEW PreciosProductosPlaya AS
SELECT valor as precio , productos.idProducto AS idproducto, idPlaya
FROM precioproductoxplaya INNER JOIN productos ON productos.idProducto = precioproductoxplaya.idProducto 
WHERE precioproductoxplaya.active = 1 ;

SELECT coalesce((select precio from PreciosProductosPlaya where idproducto = 9 AND idPlaya = 2), (select precio from PreciosProductos where idproducto = 9 )) Precio ;