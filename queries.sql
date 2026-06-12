select 
		COUNT(customer_id) as customers_count
from customers;

--El codigo selecciona todas las filas de la columna customer_id, postriormente las cuenta con la funcion COUNT y por ultimo le asigna un nombre temporal con el alias customer_count, todo esto se seleeciona desde la tabla customers 
