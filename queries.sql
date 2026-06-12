select 
		COUNT(customer_id) as customers_count
from customers;

--El codigo selecciona todas las filas de la columna customer_id, postriormente las cuenta con la funcion COUNT y por ultimo le asigna un nombre temporal con el alias customer_count, todo esto se seleeciona desde la tabla customers 



-- Top 10 vendedores con mayor cantidad de ventas
SELECT sale_person_id,              -- selecciona el identificador del vendedor
       SUM(quantity) AS total_sales -- suma la cantidad total vendida por ese vendedor
FROM sales                          -- de la tabla de ventas
GROUP BY sale_person_id             -- agrupa los registros por vendedor
ORDER BY total_sales DESC           -- ordena de mayor a menor según las ventas totales
LIMIT 10;                           -- limita el resultado a los 10 primeros vendedores


-- Vendedores con ventas por debajo del promedio general
WITH sales_totals AS (              -- CTE que calcula las ventas totales por vendedor
    SELECT sale_person_id,          -- selecciona el identificador del vendedor
           SUM(quantity) AS total_sales -- suma la cantidad total vendida
    FROM sales                      -- de la tabla de ventas
    GROUP BY sale_person_id         -- agrupa por vendedor
),
avg_sales AS (                      -- CTE que calcula el promedio de las ventas totales
    SELECT AVG(total_sales) AS avg_total -- obtiene el promedio de todas las ventas totales
    FROM sales_totals               -- usando el resultado del CTE anterior
)
SELECT s.sale_person_id, s.total_sales -- selecciona vendedor y sus ventas totales
FROM sales_totals s                 -- de la tabla temporal con totales
JOIN avg_sales a ON 1=1             -- une con el promedio (sin condición real)
WHERE s.total_sales < a.avg_total   -- filtra los vendedores con ventas menores al promedio
ORDER BY s.total_sales ASC;         -- ordena de menor a mayor venta






-- Ventas totales por vendedor y día de la semana (PostgreSQL)
WITH sales_by_day AS (              -- CTE que calcula ventas por día y vendedor
    SELECT sale_person_id,          -- selecciona el identificador del vendedor
           TRIM(TO_CHAR(sale_date, 'Day')) AS day_of_week -- convierte la fecha en nombre del día
           , FLOOR(SUM(quantity)) AS total_sales -- suma las cantidades y redondea hacia abajo
    FROM sales                      -- de la tabla de ventas
    GROUP BY sale_person_id, TO_CHAR(sale_date, 'Day') -- agrupa por vendedor y día de la semana
)
SELECT sale_person_id, day_of_week, total_sales -- selecciona vendedor, día y ventas totales
FROM sales_by_day                   -- de la tabla temporal creada
ORDER BY day_of_week ASC,           -- ordena primero por día de la semana
         sale_person_id ASC;        -- y luego por identificador del vendedor



-- Muestra siempre los tres grupos de edad, incluso si alguno no tiene clientes
WITH groups AS (                                -- crea una tabla temporal llamada "groups"
    SELECT '16-25' AS age_group                 -- primera fila: grupo de edades 16 a 25
    UNION ALL                                   -- une con otra fila
    SELECT '26-40'                              -- segunda fila: grupo de edades 26 a 40
    UNION ALL                                   -- une con otra fila
    SELECT '40+'                                -- tercera fila: grupo de edades mayores de 40
)
SELECT g.age_group,                             -- selecciona el nombre del grupo desde la tabla temporal
       COALESCE(COUNT(c.customer_id), 0) AS total_customers  
                                                -- cuenta cuántos clientes hay en ese grupo;
                                                -- si no hay ninguno, muestra 0 en lugar de NULL
FROM groups g                                   -- tabla temporal con los tres grupos
LEFT JOIN customers c                           -- une con la tabla real de clientes
    ON (                                        -- condición de unión: asigna cada cliente a su grupo
        (g.age_group = '16-25' AND c.age BETWEEN 16 AND 25)
        OR (g.age_group = '26-40' AND c.age BETWEEN 26 AND 40)
        OR (g.age_group = '40+' AND c.age > 40)
    )
GROUP BY g.age_group                            -- agrupa los resultados por cada grupo de edad
ORDER BY g.age_group;                           -- ordena los grupos en orden ascendente (16-25, 26-40, 40+)





-- Agrupa las ventas por mes y calcula clientes únicos e ingresos
SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS year_month,       -- convierte la fecha al formato AÑO-MES
    COUNT(DISTINCT s.customer_id) AS unique_customers,   -- cuenta clientes únicos en ese mes
    SUM(s.quantity * p.price) AS total_income            -- multiplica cantidad por precio para calcular ingresos
FROM sales s                                             -- tabla de ventas
JOIN products p ON s.product_id = p.product_id           -- une con productos para obtener el precio
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')                 -- agrupa por mes
ORDER BY year_month ASC;                                 -- ordena cronológicamente

