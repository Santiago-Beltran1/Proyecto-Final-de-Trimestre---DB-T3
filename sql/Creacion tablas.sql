CREATE SCHEMA IF NOT EXISTS panaderia;
SET search_path = panaderia, public;

-- CLIENTES
CREATE TABLE clientes (
  cliente_id SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  email VARCHAR(150) UNIQUE,
  telefono VARCHAR(20),
  direccion TEXT
);

-- EMPLEADOS
CREATE TABLE empleados (
  empleado_id SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  cargo VARCHAR(50) NOT NULL,
  email VARCHAR(150) UNIQUE,
  telefono VARCHAR(20),
  fecha_contratacion DATE NOT NULL,
  salario NUMERIC(12,2) NOT NULL CHECK (salario >= 0)
);

-- PRODUCTOS
CREATE TABLE productos (
  producto_id SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  tipo VARCHAR(50) NOT NULL,
  precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
  stock INT NOT NULL CHECK (stock >= 0),
  activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- PEDIDOS
CREATE TABLE pedidos (
  pedido_id SERIAL PRIMARY KEY,
  cliente_id INT REFERENCES clientes(cliente_id) ON DELETE SET NULL,
  empleado_id INT REFERENCES empleados(empleado_id) ON DELETE SET NULL,
  fecha TIMESTAMP NOT NULL DEFAULT NOW(),
  estado VARCHAR(20) NOT NULL DEFAULT 'pendiente', -- pendiente | preparando | entregado | cancelado
  total NUMERIC(12,2) NOT NULL CHECK (total >= 0)
);

-- DETALLE DEL PEDIDO
CREATE TABLE pedido_detalle (
  pedido_id INT REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
  producto_id INT REFERENCES productos(producto_id),
  cantidad INT NOT NULL CHECK (cantidad > 0),
  precio_unitario NUMERIC(10,2) NOT NULL,
  subtotal NUMERIC(12,2) NOT NULL,
  PRIMARY KEY (pedido_id, producto_id)
);

-- PAGOS
CREATE TABLE pagos (
  pago_id SERIAL PRIMARY KEY,
  pedido_id INT REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
  metodo VARCHAR(30),
  monto NUMERIC(12,2) NOT NULL CHECK (monto >= 0),
  fecha_pago TIMESTAMP DEFAULT NOW()
);

