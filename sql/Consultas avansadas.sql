--INNER JOIN
SELECT p.pedido_id, c.nombre AS cliente, e.nombre AS empleado, p.total
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.cliente_id
INNER JOIN empleados e ON p.empleado_id = e.empleado_id;

--LEFT JOIN
SELECT p.pedido_id, pd.producto_id, pd.cantidad
FROM pedidos p
LEFT JOIN pedido_detalle pd ON p.pedido_id = pd.pedido_id;

--RIGHT JOIN
SELECT pr.nombre AS producto, pd.pedido_id
FROM productos pr
RIGHT JOIN pedido_detalle pd ON pr.producto_id = pd.producto_id;

--FULL JOIN
SELECT c.nombre, p.pedido_id
FROM clientes c
FULL JOIN pedidos p ON c.cliente_id = p.cliente_id;

--GROUP BY + HAVING
SELECT pr.tipo, SUM(pr.stock) AS total_stock
FROM productos pr
GROUP BY pr.tipo
HAVING SUM(pr.stock) > 50;

--SUBCONSULTA
SELECT nombre
FROM productos
WHERE producto_id IN (
  SELECT producto_id FROM pedido_detalle WHERE cantidad >= 5
);

--CTE
WITH ventas AS (
  SELECT pedido_id, SUM(subtotal) AS total
  FROM pedido_detalle
  GROUP BY pedido_id
)
SELECT * FROM ventas ORDER BY total DESC;
