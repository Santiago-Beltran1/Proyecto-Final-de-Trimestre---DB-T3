INNER JOIN
SELECT p.pedido_id, c.nombre AS cliente, e.nombre AS empleado, p.total
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.cliente_id
INNER JOIN empleados e ON p.empleado_id = e.empleado_id;

¿Qué hace?

Devuelve solo los pedidos que tienen coincidencia tanto en clientes como en empleados.

Une:

pedidos con clientes

pedidos con empleados

👉 Si un pedido no tiene cliente o empleado asociado, NO aparece.

✅ LEFT JOIN
SELECT p.pedido_id, pd.producto_id, pd.cantidad
FROM pedidos p
LEFT JOIN pedido_detalle pd ON p.pedido_id = pd.pedido_id;

¿Qué hace?

Devuelve todos los pedidos, incluso si no tienen detalles en pedido_detalle.

Si no hay detalles, las columnas de pd salen en NULL.

👉 Útil para ver “pedidos vacíos”.

✅ RIGHT JOIN
SELECT pr.nombre AS producto, pd.pedido_id
FROM productos pr
RIGHT JOIN pedido_detalle pd ON pr.producto_id = pd.producto_id;

¿Qué hace?

Devuelve todos los registros de pedido_detalle.

Solo muestra productos si coinciden con el detalle.

👉 Si un detalle tiene un producto que ya no existe en la tabla productos, la columna producto será NULL.

✅ FULL JOIN
SELECT c.nombre, p.pedido_id
FROM clientes c
FULL JOIN pedidos p ON c.cliente_id = p.cliente_id;

¿Qué hace?

Devuelve:

Clientes con pedidos

Clientes sin pedidos

Pedidos sin cliente (si existiera)

👉 El FULL JOIN combina LEFT + RIGHT.

✅ GROUP BY + HAVING
SELECT pr.tipo, SUM(pr.stock) AS total_stock
FROM productos pr
GROUP BY pr.tipo
HAVING SUM(pr.stock) > 50;

¿Qué hace?

Agrupa productos por tipo.

Suma el stock de cada tipo.

Muestra solo los tipos donde el stock total sea mayor a 50.

👉 HAVING es un filtro para agregaciones (SUM, COUNT…).

✅ SUBCONSULTA
SELECT nombre
FROM productos
WHERE producto_id IN (
  SELECT producto_id FROM pedido_detalle WHERE cantidad >= 5
);

¿Qué hace?

Muestra nombres de productos que aparecen en pedidos con cantidad mínima de 5 unidades.

La subconsulta busca esos producto_id dentro del detalle.

👉 Funciona como un filtro inteligente.

✅ CTE (Common Table Expression)
WITH ventas AS (
  SELECT pedido_id, SUM(subtotal) AS total
  FROM pedido_detalle
  GROUP BY pedido_id
)

¿Qué hace?

Crea una tabla temporal llamada ventas.

En esa tabla pone el total vendido por cada pedido.

👉 Sirve para hacer consultas más limpias y reutilizar resultados.