# Conexión entre SQL, MongoDB y Redis en el Sistema de Administración de Panadería

La panadería necesita tres cosas al mismo tiempo:

- Registrar **ventas e inventario** con total precisión.
- Consultar **información rica** (recetas, historiales, productividad) sin volver lento el sistema.
- Atender a clientes y vendedores con una **aplicación rápida**, incluso en horas pico.

Para lograrlo se usa **persistencia políglota**:  
SQL, MongoDB y Redis se usan **en conjunto**, pero cada uno con un rol muy claro.

---

## 1. Visión general de roles

- **SQL**  
  Es la **fuente de verdad**. Aquí viven los datos críticos: clientes, empleados, productos básicos, pedidos, detalle de pedidos y pagos.  
  Todo lo que afecta caja, inventario y reportes oficiales se registra primero y de forma confiable en SQL.

- **MongoDB**  
  Es el **repositorio de contenido enriquecido e historiales**.  
  Guarda información mucho más detallada y flexible: recetas con ingredientes, proveedores, historial de producción de empleados, pedidos con snapshot completo del cliente y sus estados, etc.

- **Redis**  
  Es la **capa de velocidad**.  
  Maneja datos temporales y de alta frecuencia: sesiones de usuarios, carritos de compra, colas de producción y rankings de productos más vendidos.

Los tres motores forman una sola solución:  
SQL asegura la exactitud, MongoDB aporta contexto profundo del negocio y Redis mantiene el sistema ágil.

---

## 2. Flujo integrado: de la sesión a la venta

### 2.1 Inicio de sesión y navegación (Redis + SQL)

1. El usuario (cliente o vendedor) inicia sesión.
2. La aplicación verifica usuario y contraseña en SQL (tablas `clientes` o `empleados`).
3. Si todo es correcto, se genera un token y se guarda en Redis con tiempo de expiración (TTL).  
   - A partir de ese momento, la app consulta a Redis para validar la sesión, no a SQL.
4. Cada vez que el usuario ve un producto, se incrementa un contador en Redis.  
   - Así se sabe qué artículos despiertan más interés **en tiempo real** sin tocar la base relacional.

**Resultado:**  
SQL confirma quién es el usuario; Redis mantiene la sesión y los contadores rápidos.

---

### 2.2 Carrito y confirmación de pedido (Redis → SQL)

1. El usuario agrega productos al carrito.  
   - El carrito se guarda como un `HASH` en Redis (producto y cantidad por usuario).
2. La app muestra el carrito leyendo directamente ese `HASH`.
3. Cuando el usuario confirma la compra:
   - Se lee el carrito desde Redis.
   - Se inicia una **transacción** en SQL:
     - Se inserta el pedido (`pedidos`).
     - Se insertan los detalles (`pedido_detalle`).
     - Se registra el pago (`pagos`).
4. Si la transacción en SQL se completa con éxito:
   - Se elimina el carrito en Redis.
   - Se actualiza un ranking de productos más vendidos en Redis (ZSET).

**Resultado:**  
Redis se usa como **almacén temporal** (carrito).  
SQL recibe solo los datos ya confirmados y los registra con garantías ACID.

---

### 2.3 Producción y operación interna (SQL → Redis)

1. Una vez creado el pedido en SQL, el sistema envía su identificador a una **cola de producción** en Redis (LIST).
2. Los panaderos consultan esa cola para saber qué pedido preparar a continuación.
3. El sistema actualiza en SQL el estado del pedido (pendiente, en preparación, entregado).
4. La cantidad de pedidos en cola o preparados se puede llevar con contadores en Redis para usar en paneles en vivo.

**Resultado:**  
SQL guarda la historia oficial de cada pedido.  
Redis organiza de forma muy simple el **orden de trabajo** en la panadería.

---

## 3. Replicación lógica a MongoDB para análisis

### 3.1 Construcción de documentos enriquecidos

Periódicamente (o justo después de la venta), la aplicación toma los datos de SQL y los transforma en documentos para MongoDB:

- **Colección `productos`**  
  - Además de los campos básicos que están en SQL (nombre, tipo, precio, stock), se añaden:
    - descripción, costo, calorías, tiempo de preparación,
    - ingredientes (array),
    - proveedores (subdocumentos).
- **Colección `pedidos`**  
  - Se guarda un “snapshot” completo del pedido:
    - número de pedido,
    - datos embebidos del cliente,
    - lista de ítems (producto, cantidad, precio, subtotal),
    - descuentos, notas, forma de pago,
    - historial de cambios de estado.
- **Colección `empleados`**  
  - Incluye:
    - especialidades,
    - turnos asignados,
    - historial de producción (día, producto, cantidad, horas),
    - documentos y capacitaciones.

La clave que conecta todo suele ser el mismo **identificador lógico** (por ejemplo, `numero_pedido`) o el `id` que viene de SQL.

---

### 3.2 Uso de MongoDB en el sistema

MongoDB se aprovecha sobre todo para:

- **Informes de negocio detallados**  
  - Ingresos potenciales por tipo de producto (precio × stock).  
  - Margen por categoría (precio vs costo).  
  - Ventas por cliente con detalle de productos.

- **Análisis de producción y personal**  
  - Productividad de cada panadero (unidades por hora, jornadas, productos elaborados).  
  - Historias completas de pedidos con todo su ciclo de estados.

- **Consultas rápidas de “ficha completa”**  
  - Ver toda la información de un producto (receta, proveedores, calorías).  
  - Ver todo el historial de un pedido o de un empleado en un solo documento.

MongoDB no reemplaza a SQL:  
trabaja **a partir** de los datos que SQL asegura, pero en un formato mucho más cómodo para exploración y análisis.

---

## 4. Relación lógica entre los tres motores

### 4.1 Quién manda en cada tipo de dato

- **Datos críticos y financieros** → SQL manda  
  - Pedidos, pagos, stock oficial, registros de clientes y empleados.
- **Datos enriquecidos e historiales** → MongoDB manda  
  - Recetas, ingredientes, proveedores, historiales de producción, snapshots de pedidos.
- **Datos temporales y de alta frecuencia** → Redis manda  
  - Sesiones, carritos, colas, contadores y rankings.

### 4.2 Flujo típico de un pedido

1. **Login**  
   - Verificación en SQL → token en Redis.

2. **Carrito**  
   - Ítems en Redis como HASH.

3. **Confirmar compra**  
   - Leer carrito de Redis → transacción en SQL → limpiar Redis → actualizar ranking en Redis.

4. **Producción**  
   - Encolar pedido en Redis → procesar → actualizar estado en SQL.

5. **Análisis posterior**  
   - Replicar/transformar datos relevantes de SQL a MongoDB.  
   - Ejecutar pipelines de agregación para obtener KPIs de ventas, márgenes y productividad.

En todo el recorrido, cada motor usa sus fortalezas sin invadir el rol de los otros.

---

## 5. Beneficios concretos para la panadería

- **Cierres de caja confiables**  
  SQL garantiza que las ventas, pagos y stock estén correctos y auditables.
- **Sistema rápido en mostrador y web**  
  Redis maneja sesiones, carritos y colas sin golpear las bases de datos pesadas.
- **Mejor toma de decisiones**  
  MongoDB ofrece análisis sobre qué productos son más rentables, qué clientes compran más y qué empleados son más productivos.
- **Evolución sencilla del sistema**  
  Se pueden agregar nuevos campos y análisis en MongoDB o nuevas métricas en Redis sin tener que rediseñar el modelo transaccional de SQL.

---

## 6. Resumen

- **SQL** = Registro oficial y relaciones críticas (ventas, stock, clientes, empleados).  
- **MongoDB** = Datos ricos, historiales y análisis.  
- **Redis** = Sesiones, carritos, colas y métricas en tiempo real.

Juntos forman un sistema de administración de panadería que es **confiable, rápido y flexible**, preparado tanto para el día a día del mostrador como para el análisis de negocio de mediano y largo plazo.
