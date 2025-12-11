Modelo Relacional – Sistema de Panadería
🤷‍♂️Tabla clientes
Campo	                Tipo	        Descripción
id de cliente PK        entero          Identificador del cliente
nombre	                varchar	        Nombre del cliente
correo electrónico	    varchar	        Correo electrónico
teléfono	            varchar	        Número de contacto
direccion	            varchar	        Dirección física

👨‍🍳 Tabla empleados
Campo	                Tipo	        Descripción
empleado_id PK	        entero	        Identificador del empleado
nombre	                varchar	        Nombre completo
carga	                varchar	        Puesto (panadero, cajero, etc.)
correo electrónico	    varchar	        Correo laboral
teléfono	            varchar	        Teléfono
fecha_contratacion	    fecha	         Fecha de ingreso
salario	                decimal	         Salario del empleado

🍞 Tabla productos
Campo	                Tipo	        Descripción
producto_id PK	        entero	        Identificador del producto
nombre	                varchar	        Nombre del producto
tipo	                varchar	        Categoría (pan, torta, postre…)
precio	                decimal	        Precio unitario
existencias	            entero	        Cantidad disponible
activo	                booleano	    Indica si el producto está disponible

📦 Tabla pedidos
Campo	                Tipo	        Descripción
id de pedido PK	        entero	        Identificador del pedido
id de cliente FK	    entero	        Referencia a clientes
empleado_id FK	        entero	        Referencia a empleados
fecha	                fecha y hora	Fecha del pedido
estado	                varchar	        Estado (pendiente, entregado, cancelado)
total	                decimal	        Total calculado del pedido

🧾 Tabla pedido_detalle

PK compuesta: (pedido_id, producto_id)

Campo	                Tipo	        Descripción
id de pedido FK	        entero	        Referencia a pedidos
id del producto FK	    entero	        Referencia a productos
cantidad	            entero	        Número de unidades
precio_unitario	        decimal	        Precio individual
total parcial	        decimal	        cantidad × precio_unitario

💳 Tabla pagos
Campo	                Tipo	        Descripción
pago_id PK	            entero	        Identificador del pago
id de pedido FK	        entero	        Referencia a pedido
método	                varchar	        (efectivo, tarjeta, transferenci,otro)
monto	                decimal	        Total pagado
fecha_pago	            fecha y hora	Fecha del pago

