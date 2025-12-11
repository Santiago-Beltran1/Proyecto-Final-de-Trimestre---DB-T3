SET search_path = panaderia, public;

INSERT INTO clientes (nombre, email, telefono, direccion) VALUES
('Juan García', 'juan@email.com', '3001112222', 'Cra 10 #20-30'),
('María López', 'mlopez@mail.com', '3002223333', 'Cl 15 #8-12');

INSERT INTO empleados (nombre, cargo, email, telefono, fecha_contratacion, salario) VALUES
('María Rodríguez', 'Panadero', 'marod@panaderia.com', '3100000000', '2024-01-10', 1200000),
('Carlos Pérez', 'Vendedor', 'cperez@panaderia.com', '3111111111', '2024-03-15', 900000);

INSERT INTO productos (nombre, tipo, precio, stock) VALUES
('Pan de trigo integral', 'pan', 2.50, 50),
('Donas de vainilla', 'dona', 1.50, 100),
('Galletas de chocolate', 'galleta', 3.00, 75);

INSERT INTO pedidos (cliente_id, empleado_id, total, estado)
VALUES (1, 2, 27.50, 'entregado');

INSERT INTO pedido_detalle (pedido_id, producto_id, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 5, 2.50, 12.50),
(1, 2, 10, 1.50, 15.00);

