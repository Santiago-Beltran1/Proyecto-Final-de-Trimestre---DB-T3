# Diseño de Colecciones MongoDB - Sistema de Panadería

## Colección 1: `productos`

### Estructura del Documento

{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "nombre": "Pan de trigo integral",
  "tipo": "pan",
  "descripcion": "Pan integral hecho con harina de trigo 100% natural",
  "precio": 2.50,
  "costo": 1.20,
  "stock": 50,
  "cantidad_minima": 10,
  "ingredientes": ["harina integral", "agua", "levadura", "sal", "mantequilla"],
  "tiempo_preparacion_minutos": 120,
  "calorias": 265,
  "proveedores": [
    {
      "nombre": "Harinera Central",
      "tipo_ingrediente": "harina",
      "telefono": "3001234567"
    }
  ],
}


### Campos Obligatorios
- **nombre** (String): Identificador único legible del producto
- **tipo** (String): Categoría del producto (pan, pastel, dona, galleta, etc.)
- **precio** (Double): Precio de venta al público
- **costo** (Double): Costo de producción
- **stock** (Integer): Cantidad disponible en inventario
- **ingredientes** (Array): Lista de ingredientes utilizados

### Campos Opcionales
- descripcion, calorias, tiempo_preparacion_minutos, proveedores  

### Justificación del uso de MongoDB
MongoDB es ideal para esta colección porque:
1. **Flexibilidad**: Diferentes tipos de productos pueden tener campos distintos (un pastel tiene decoración, un pan no)
2. **Arrays de ingredientes**: MongoDB maneja arrays nativamente sin necesidad de tablas separadas
3. **Información anidada**: Proveedores se guardan dentro del documento sin normalizaciones complejas
4. **Escalabilidad horizontal**: Fácil de distribuir cuando crece el catálogo
5. **Consultas rápidas**: Perfecta para filtrar por tipo, precio, stock en tiempo real

---

## Colección 2: `pedidos`

### Estructura del Documento
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "numero_pedido": "PED-2025-001",
  "fecha_pedido": ISODate("2025-12-09T10:30:00Z"),
  "fecha_entrega": ISODate("2025-12-09T14:00:00Z"),
  "cliente": {
    "nombre": "Juan García López",
    "email": "juan@email.com",
    "telefono": "3001234567",
    "direccion": "Calle 10 #20-30, Bogotá"
  },
  "items": [
    {
      "producto_nombre": "Pan de trigo integral",
      "cantidad": 5,
      "precio_unitario": 2.50,
      "subtotal": 12.50
    },
    {
      "producto_nombre": "Donas de vainilla",
      "cantidad": 10,
      "precio_unitario": 1.50,
      "subtotal": 15.00
    }
  ],
  "total": 27.50,
  "descuento": 0,
  "total_final": 27.50,
  "estado": "completado",
  "metodo_pago": "efectivo",
  "notas": "Entregar en el local principal",
  "empleado_asignado": "María López",
  "historial_estado": [
    {
      "estado": "pendiente",
      "fecha": ISODate("2025-12-09T10:30:00Z")
    },
    {
      "estado": "en_preparacion",
      "fecha": ISODate("2025-12-09T10:35:00Z")
    },
    {
      "estado": "completado",
      "fecha": ISODate("2025-12-09T14:00:00Z")
    }
  ]
}


### Campos Obligatorios
- **numero_pedido** (String): Identificador único del pedido
- **fecha_pedido** (Date): Fecha y hora de creación del pedido
- **cliente** (Object): Información del cliente (nombre, email, teléfono, dirección)
- **items** (Array): Lista de productos pedidos con cantidad y precio
- **total_final** (Double): Monto total a pagar
- **estado** (String): Estado actual del pedido (pendiente, en_preparacion, completado, cancelado)

### Campos Opcionales
- descuento, notas, empleado_asignado, historial_estado, metodo_pago

### Justificación del uso de MongoDB
MongoDB es ideal para pedidos porque:
1. **Denormalización controlada**: Almacena cliente e items dentro del mismo documento sin JOINs complejos
2. **Historial temporal**: El array `historial_estado` permite trackear cambios sin tabla separada
3. **Variabilidad**: Algunos pedidos pueden tener descuentos, otros no; MongoDB lo maneja naturalmente
4. **Rendimiento de lectura**: Toda la información del pedido en un solo documento = una sola consulta
5. **Transacciones complejas**: Ideal para guardar el estado completo de un pedido en un momento específico

---

## Colección 3: `empleados`

### Estructura del Documento
{
  "_id": ObjectId("507f1f77bcf86cd799439013"),
  "nombre": "María López Rodríguez",
  "cargo": "Panadero",
  "email": "maria@panaderia.com",
  "telefono": "3009876543",
  "salario_mensual": 1200000,
  "fecha_inicio": ISODate("2024-06-01T00:00:00Z"),
  "fecha_fin": null,
  "turnos_asignados": ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"],
  "especialidades": ["panes", "pasteles", "fermentacion"],
  "activo": true,
  "historial_produccion": [
    {
      "fecha": ISODate("2025-12-08T06:00:00Z"),
      "producto": "Pan integral",
      "cantidad_producida": 100,
      "tiempo_horas": 4,
      "calidad": "excelente"
    },
    {
      "fecha": ISODate("2025-12-08T10:00:00Z"),
      "producto": "Pasteles de chocolate",
      "cantidad_producida": 25,
      "tiempo_horas": 3,
      "calidad": "buena"
    }
  ],
  "documentos": [
    {
      "tipo": "cedula",
      "numero": "1234567890",
      "fecha_vencimiento": ISODate("2030-06-01T00:00:00Z")
    }
  ],
  "capacitaciones": [
    {
      "nombre": "Manejo de horno industrial",
      "fecha": ISODate("2024-07-15T00:00:00Z"),
      "certificado": true
    }
  ]
}

### Campos Obligatorios
- **nombre** (String): Nombre completo del empleado
- **cargo** (String): Puesto del empleado (Panadero, Pastelero, Vendedor, etc.)
- **email** (String): Correo corporativo
- **telefono** (String): Contacto principal
- **salario_mensual** (Double): Salario mensual
- **fecha_inicio** (Date): Fecha de contratación
- **activo** (Boolean): Indica si el empleado está trabajando actualmente

### Campos Opcionales
- especialidades, turnos_asignados, historial_produccion, documentos, capacitaciones, fecha_fin

### Justificación del uso de MongoDB
MongoDB es ideal para empleados porque:
1. **Información histórica anidada**: El `historial_produccion` crece con el tiempo sin afectar la estructura
2. **Documentos variados**: Cada empleado puede tener diferentes documentos (cédula, diploma, etc.)
3. **Evolución del esquema**: Nuevas capacitaciones se agregan sin ALTER TABLE
4. **Análisis de desempeño**: Arrays de producción permiten análisis complejos con aggregation
5. **Escalabilidad temporal**: Historial puede crecer sin impacto en performance de lectura

---

## Comparación: ¿Por qué no SQL puro?

Aunque SQL podría hacer esto, requeriría:
- Tabla `pedidos_items` separada (complejidad de JOINs)
- Tabla `historial_pedidos` para estados (auditoría adicional)
- Tabla `historial_produccion_empleados` (normalización excesiva)
- Cambios de esquema con ALTER TABLE si nuevos productos necesitan nuevos campos

**MongoDB lo simplifica**: todo en un documento, sin migraciones.

---

## CRUD Básicas por Colección

### CREATE - Insertar documentos
db.productos.insertOne({
  nombre: "Pan de trigo integral",
  tipo: "pan",
  precio: 2.50,
  costo: 1.20,
  stock: 50,
  ingredientes: ["harina integral", "agua", "levadura", "sal"],
  activo: true
})

// Insertar un pedido
db.pedidos.insertOne({
  numero_pedido: "PED-2025-001",
  cliente: { nombre: "Juan García", email: "juan@email.com" },
  items: [{ producto_nombre: "Pan de trigo", cantidad: 5, precio_unitario: 2.50 }],
  total_final: 12.50,
  estado: "completado"
})

// Insertar un empleado
db.empleados.insertOne({
  nombre: "María López",
  cargo: "Panadero",
  email: "maria@panaderia.com",
  salario_mensual: 1200000,
  especialidades: ["panes", "pasteles"],
  activo: true
})


### READ - Consultar documentos
// Obtener todos los panes activos
db.productos.find({ tipo: "pan", activo: true })

// Obtener un pedido específico
db.pedidos.findOne({ numero_pedido: "PED-2025-001" })

// Obtener empleados por cargo
db.empleados.find({ cargo: "Panadero" })

// Contar productos con stock bajo
db.productos.countDocuments({ stock: { $lt: 10 } })


### UPDATE - Actualizar documentos
// Actualizar stock de un producto
db.productos.updateOne(
  { nombre: "Pan de trigo integral" },
  { $set: { stock: 45 } }
)

// Restar stock cuando se vende
db.productos.updateOne(
  { nombre: "Pan de trigo integral" },
  { $inc: { stock: -5 } }
)

// Cambiar estado de pedido
db.pedidos.updateOne(
  { numero_pedido: "PED-2025-001" },
  { $set: { estado: "completado" } }
)

// Agregar historial de producción a empleado
db.empleados.updateOne(
  { nombre: "María López" },
  { $push: { 
      historial_produccion: {
        fecha: new Date(),
        producto: "Pan integral",
        cantidad_producida: 100,
        tiempo_horas: 4
      }
    }
  }
)


### DELETE - Eliminar documentos
// Eliminar un producto (mejor: marcar como inactivo)
db.productos.deleteOne({ nombre: "Producto antiguo" })

// Eliminar pedidos cancelados
db.productos.deleteMany({ estado: "cancelado" })

// Mejor práctica: Marcar como inactivo
db.productos.updateOne(
  { nombre: "Pan de trigo" },
  { $set: { activo: false } }
)

