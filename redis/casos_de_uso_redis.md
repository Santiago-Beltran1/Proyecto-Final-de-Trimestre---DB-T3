## Casos_de_uso_redis.md: Justificación e Integración Políglota

Redis se utiliza como la **capa de velocidad (caching, colas, sesiones)** para aliviar la carga de operaciones de alta frecuencia sobre la base de datos transaccional (SQL) y la base de datos de contenido (MongoDB).

---

### 1. 🤝 Coherencia Conceptual y Funcional con Otros Motores

La coherencia se demuestra porque las acciones críticas de Redis dependen directamente del flujo de datos iniciado o finalizado en las otras bases de datos.

| Motor Fuente | Motor Destino | Coherencia Funcional Demostrada |
| :--- | :--- | :--- |
| **SQL** (Transacción de Venta) | **Redis (ZSET)** | La clasificación de **Productos Más Vendidos** se actualiza inmediatamente después de que la transacción de venta se confirma en SQL, garantizando que el *ranking* es preciso. |
| **SQL** (Tabla de Usuarios) | **Redis (STRING)** | La sesión de usuario se guarda en Redis **solo después** de que el servidor verifica la existencia y credenciales del usuario en la tabla `clientes` de SQL. |
| **Redis (HASH)** | **SQL** (Tabla `pedidos`) | El contenido del **Carrito de Compras** (HASH) solo se migra a SQL para iniciar la **transacción ACID** (INSERT), asegurando que los datos temporales se conviertan en registros financieros. |
| **MongoDB** (Colección `productos`) | **Redis (STRING)** | El JSON de recetas o descripciones de productos se guarda en Redis para ser servido rápidamente como **caché** cuando se consulta, evitando la consulta directa a MongoDB. |

---

### 2. ⚡️ Uso Obligatorio de 4 Estructuras de Datos de Redis

Hemos integrado cuatro estructuras de datos de Redis para cubrir diversos escenarios de rendimiento en la panadería:

#### A. STRING: Estados Temporales y Contadores (Uso con TTL)

**Función:** Manejar la autenticación (sesiones) y métricas simples de alta frecuencia.

| Escenario | Comandos Clave | Justificación |
| :--- | :--- | :--- |
| **Sesiones con Expiración** | `SETEX sesion:user:404 1800 {token}` | Guarda el *token* por 30 minutos (1800 segundos), liberando automáticamente la memoria. |
| **Contador de Visitas** | `INCR visitas:pan_masa_madre` | Registra las visualizaciones de productos en tiempo real, sin impactar el rendimiento de SQL. |

#### B. HASH: Carrito de Compras (Configuraciones)

**Función:** Almacenar colecciones de campos-valor (objetos) bajo una única clave.

| Escenario | Comandos Clave | Justificación |
| :--- | :--- | :--- |
| **Gestión del Carrito** | `HSET carrito:user:101 producto_A 5` | Almacena los ítems del carrito (`producto_id` y `cantidad`) bajo la clave del cliente. |
| **Checkout (Lectura)** | `HGETALL carrito:user:101` | Recupera todos los datos del carrito en una sola llamada para transferirlos a la **transacción de venta en SQL**. |

#### C. LIST: Cola de Pedidos (Colas de Turnos)

**Función:** Implementar colas de mensajes (FIFO) para el flujo de trabajo de la panadería.

| Escenario | Comandos Clave | Justificación |
| :--- | :--- | :--- |
| **Entrada de Pedido** | `RPUSH cola:produccion_dia PED-2025-001` | El pedido, ya registrado y pagado en SQL, se añade al final de la cola de trabajo del panadero. |
| **Consumo de Pedido** | `LPOP cola:produccion_dia` | El proceso de producción saca el primer pedido pendiente de la cola para prepararlo. |

#### D. ZSET: Ranking de Ventas (Clasificación)

**Función:** Mantener una lista ordenada automáticamente por un puntaje (*score*) para rankings y *leaderboards*.

| Escenario | Comandos Clave | Justificación |
| :--- | :--- | :--- |
| **Actualización de Ranking** | `ZINCRBY top_vendidos 5 pan_trigo_integral` | Incrementa el contador de ventas de forma atómica. Esta acción sigue al éxito de la venta en SQL. |
| **Mostrar Ranking** | `ZRANGE top_vendidos 0 9 REV WITHSCORES` | Permite a la aplicación obtener el top 10 de productos más vendidos de manera instantánea. |