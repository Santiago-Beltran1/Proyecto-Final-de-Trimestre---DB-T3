## 🚀 Explicación de Conexión entre SQL, MongoDB y Redis (Persistencia Políglota)

El uso de **Persistencia Políglota** significa seleccionar la base de datos más adecuada para cada tipo específico de dato o tarea, en lugar de forzar todos los datos a un solo modelo. Este enfoque maximiza la eficiencia, el rendimiento y la escalabilidad del sistema. 

---

## ✅ ¿Por qué SQL? (Fuente de Verdad e Integridad)

SQL (utilizando motores como PostgreSQL o MySQL) es fundamental en esta arquitectura por su capacidad de manejar información que requiere **máxima integridad y estructura**.

| Concepto Clave | Justificación Políglota | Rol en la Panadería |
| :--- | :--- | :--- |
| **Integridad Transaccional (ACID)** | Es la única base de datos que garantiza las propiedades **ACID** (Atomicidad, Consistencia, Aislamiento, Durabilidad) para transacciones financieras y de *stock* críticas. | **Registro de Pedidos Finales** y **Gestión del Inventario Crítico** de materias primas. |
| **Modelo Relacional Estricto** | La estructura de tablas, al estar separada y dependiente (normalizada), **evita la sobrecarga de información** y asegura que no haya redundancia en los datos críticos (como el costo de un producto). | **Registro Principal de Usuarios** y la vinculación inmutable de cada ítem en el pedido con el registro de venta. |
| **Fuente de Verdad (SSOT)** | SQL actúa como la **Fuente Única de Verdad** para la información financiera y legalmente relevante. Otros motores (como Redis o MongoDB) pueden tener copias temporales o extendidas de estos datos, pero SQL tiene el registro maestro. | **Reportes Financieros** y datos esenciales que garantizan la coherencia contable del negocio. |

## ✅ Rol Estratégico de SQL (PostgreSQL/MySQL)

El uso de SQL es crucial porque establece el **Modelo Relacional** y garantiza la **Integridad Transaccional (ACID)** para los datos más críticos del negocio de la panadería. Al centralizar la información esencial bajo este esquema:

1.  **Garantía de Integridad:** Se asegura la **coherencia contable** de las ventas y la precisión del **Inventario Crítico** (stock), lo cual es indispensable para la viabilidad financiera del negocio.
2.  **Optimización Estructural:** La **normalización** inherente de SQL previene la **redundancia de datos** y las **anomalías de actualización**, resultando en una base de datos fundamentalmente **limpia, auditable y eficiente** para la gestión gerencial.
3.  **Coherencia Global:** Al actuar como la **Fuente Única de Verdad (SSOT)** para los IDs maestros (clientes, pedidos, productos), SQL provee la base relacional necesaria para la **interoperabilidad** de todo el sistema políglota, permitiendo que Redis y MongoDB manejen sus tareas específicas sin riesgo de comprometer los registros financieros.

## 💾 ¿Por qué MongoDB? (Flexibilidad y Contenido Enriquecido)

MongoDB es esencial en la arquitectura políglota para gestionar los **datos semi-estructurados y evolutivos** que no encajan bien en el esquema rígido de SQL. Esto nos permite un **desarrollo ágil** y una gran eficiencia para la lectura de contenido.

1.  **Flexibilidad de Esquema:** Su modelo de documentos (BSON) permite que los registros varíen entre sí. Esto es crucial para la panadería, donde la **Colección de Recetas y Productos** puede tener campos distintos para un pastel (ej. `decoracion`) que para un pan.
2.  **Denormalización Controlada:** MongoDB sobresale al manejar **datos anidados** (como arrays de `ingredientes` o `documentos` de un empleado) dentro de un solo registro. Esto elimina la necesidad de múltiples *JOINs* complejos, resultando en una **lectura de datos más rápida** para el *backend*.
3.  **Rol Coherente:** MongoDB actúa como el **repositorio de contenido enriquecido**. En el flujo de pedidos, almacena el **registro completo y denormalizado del pedido** (con todos los detalles del cliente e ítems) para facilitar la consulta rápida del historial. No es el almacén temporal (ese rol es de Redis), sino el archivo de datos históricos detallados.

---

## ⚡️ ¿Por qué Redis? (Velocidad, Volatilidad y Flujo de Trabajo)

Redis es un almacén de datos **clave-valor en memoria** (in-memory) y es esencial para la arquitectura políglota porque maneja las operaciones de **alta frecuencia y baja latencia**. Su rol principal es **aliviar la carga** de las bases de datos de persistencia (SQL y MongoDB), gestionando datos **volátiles** y **temporales**.

1.  **Velocidad Extrema (Baja Latencia):** Al operar en la memoria principal del servidor (RAM), Redis puede gestionar millones de operaciones por segundo, siendo ideal para tareas donde el tiempo de respuesta es crítico, como la **gestión de sesiones** o el **carrito de compras**.
2.  **Estructuras de Datos Ricas:** A diferencia de un *cache* simple, Redis ofrece estructuras complejas (**HASH, LIST, ZSET**) que permiten implementar lógica de negocio avanzada (colas, clasificaciones) directamente en la capa de datos.
3.  **Gestión de Carga:** Asume el 100% de la carga de tareas volátiles (como contadores y sesiones con **TTL**), evitando que SQL y MongoDB se saturen con peticiones que no requieren persistencia a largo plazo ni integridad ACID.

---

## 📊 Comparación de Roles Operativos en la Panadería

Esta tabla resume la ventaja técnica de MongoDB al lado de los otros motores, justificando su uso dentro de la estrategia políglota.

| Característica | MongoDB (Documentos) | SQL (Relacional) | Redis (Key-Value) |
| :--- | :--- | :--- | :--- |
| **Integridad de Datos** | Transaccional a nivel de documento. | **Alta (ACID)** y consistente. | Baja (eventual). |
| **Latencia/Velocidad** | Moderada (mejor que SQL para lectura de documentos). | Moderada (lenta en *JOINs* complejos). | **Extremadamente Baja** (en memoria). |
| **Costo Operativo** | Bajo para cambios de estructura (Schema-less). | Alto para cambios de estructura (Requires `ALTER TABLE`). | Bajo (Cache y sesiones). |
| **Rol Principal en Proyecto** | **Contenido Enriquecido y Historial** (Recetas, Historiales de estado, Perfiles). | **Fuente de Verdad (SSOT)** (Inventario Crítico, Transacciones Finales). | **Velocidad/Volatilidad** (Carritos, Sesiones, Colas). |
| **Escenario Ideal** | Cargar un historial de pedidos completo en una sola consulta. | Registrar y asegurar una venta única. | Verificar si un usuario está logueado. |
