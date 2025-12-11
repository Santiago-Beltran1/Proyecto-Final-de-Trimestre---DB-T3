# Consultas Avanzadas - Aggregation Pipelines MongoDB Panadería
## PIPELINE 1: Ingresos Totales por Tipo de Producto
### Propósito
Calcular los ingresos potenciales (precio × stock) agrupados por tipo de producto, con el objetivo de identificar qué categoría genera más valor y tomar decisiones de reorden.

### Código
db.productos.aggregate([
  // Etapa 1: Filtrar solo productos activos
  {
    $match: { activo: true }
  },
  
  // Etapa 2: Calcular ingreso total por producto (precio * stock)
  {
    $project: {
      nombre: 1,
      tipo: 1,
      precio: 1,
      stock: 1,
      ingreso_total: { $multiply: ["$precio", "$stock"] }
    }
  },
  
  // Etapa 3: Agrupar por tipo y calcular KPIs
  {
    $group: {
      _id: "$tipo",
      total_ingresos: { $sum: "$ingreso_total" },
      cantidad_productos: { $sum: 1 },
      precio_promedio: { $avg: "$precio" },
      stock_total: { $sum: "$stock" },
      precio_minimo: { $min: "$precio" },
      precio_maximo: { $max: "$precio" }
    }
  },
  
  // Etapa 4: Ordenar por ingresos totales descendente
  {
    $sort: { total_ingresos: -1 }
  }
])

### Resultado Esperado
[
  {
    "_id": "pan",
    "total_ingresos": 137.50,
    "cantidad_productos": 2,
    "precio_promedio": 3.00,
    "stock_total": 58,
    "precio_minimo": 2.50,
    "precio_maximo": 3.50
  },
  {
    "_id": "pastel",
    "total_ingresos": 150.00,
    "cantidad_productos": 1,
    "precio_promedio": 15.00,
    "stock_total": 10,
    "precio_minimo": 15.00,
    "precio_maximo": 15.00
  },
  {
    "_id": "dona",
    "total_ingresos": 150.00,
    "cantidad_productos": 1,
    "precio_promedio": 1.50,
    "stock_total": 100,
    "precio_minimo": 1.50,
    "precio_maximo": 1.50
  },
  {
    "_id": "galleta",
    "total_ingresos": 225.00,
    "cantidad_productos": 1,
    "precio_promedio": 3.00,
    "stock_total": 75,
    "precio_minimo": 3.00,
    "precio_maximo": 3.00
  }
]

### Interpretación
- **Galletas** generan más ingresos potenciales ($225) por su alto stock
- **Pasteles** tienen el precio unitario más alto pero bajo stock
- **Donas** tienen alto stock pero precio bajo
- Útil para decidir en qué productos invertir producción

---

## PIPELINE 2: Análisis de Margen de Ganancia por Producto
### Propósito
Calcular el margen de ganancia (diferencia entre precio y costo) para cada producto y agrupar por categoría, permitiendo identificar cuáles productos son más rentables.

### Código
db.productos.aggregate([
  // Etapa 1: Filtrar productos activos con stock mínimo
  {
    $match: { 
      activo: true,
      stock: { $gte: 5 }
    }
  },
  
  // Etapa 2: Calcular margen de ganancia por unidad
  {
    $project: {
      nombre: 1,
      tipo: 1,
      precio: 1,
      costo: 1,
      stock: 1,
      margen_unitario: { $subtract: ["$precio", "$costo"] },
      porcentaje_margen: {
        $multiply: [
          { $divide: [{ $subtract: ["$precio", "$costo"] }, "$precio"] },
          100
        ]
      },
      ganancia_total: {
        $multiply: [
          { $subtract: ["$precio", "$costo"] },
          "$stock"
        ]
      }
    }
  },
  
  // Etapa 3: Agrupar por tipo de producto
  {
    $group: {
      _id: "$tipo",
      ganancia_total_tipo: { $sum: "$ganancia_total" },
      margen_promedio_porcentaje: { $avg: "$porcentaje_margen" },
      cantidad_productos: { $sum: 1 },
      margen_maximo: { $max: "$margen_unitario" },
      margen_minimo: { $min: "$margen_unitario" }
    }
  },
  
  // Etapa 4: Ordenar por ganancia total descendente
  {
    $sort: { ganancia_total_tipo: -1 }
  }
])


### Resultado Esperado
[
  {
    "_id": "galleta",
    "ganancia_total_tipo": 127.50,
    "margen_promedio_porcentaje": 56.67,
    "cantidad_productos": 1,
    "margen_maximo": 1.70,
    "margen_minimo": 1.70
  },
  {
    "_id": "dona",
    "ganancia_total_tipo": 80.00,
    "margen_promedio_porcentaje": 53.33,
    "cantidad_productos": 1,
    "margen_maximo": 0.80,
    "margen_minimo": 0.80
  },
  {
    "_id": "pastel",
    "ganancia_total_tipo": 90.00,
    "margen_promedio_porcentaje": 60.00,
    "cantidad_productos": 1,
    "margen_maximo": 9.00,
    "margen_minimo": 9.00
  },
  {
    "_id": "pan",
    "ganancia_total_tipo": 71.80,
    "margen_promedio_porcentaje": 51.58,
    "cantidad_productos": 2,
    "margen_maximo": 1.70,
    "margen_minimo": 1.30
  }
]

### Interpretación
- **Pasteles** tienen el mejor margen porcentual (60%)
- **Donas** tienen bajo margen unitario pero compensan con alto volumen
- Los márgenes están entre 51-60%, saludable para la industria
- Útil para negociar precios con proveedores

---

## PIPELINE 3: Ventas por Cliente con Detalles de Productos
### Propósito
Unir información de pedidos con productos usando `$lookup` para ver qué compró cada cliente, la ganancia generada y el estado de la orden.

### Código
db.pedidos.aggregate([
  // Etapa 1: Filtrar pedidos completados
  {
    $match: { 
      estado: "completado"
    }
  },
  
  // Etapa 2: Descomponer el array de items
  {
    $unwind: "$items"
  },
  
  // Etapa 3: Buscar información del producto en la colección productos
  {
    $lookup: {
      from: "productos",
      localField: "items.producto_nombre",
      foreignField: "nombre",
      as: "info_producto"
    }
  },
  
  // Etapa 4: Descomponer el array resultante de lookup
  {
    $unwind: "$info_producto"
  },
  
  // Etapa 5: Proyectar campos necesarios y calcular ganancia
  {
    $project: {
      numero_pedido: 1,
      cliente_nombre: "$cliente.nombre",
      cliente_email: "$cliente.email",
      producto: "$items.producto_nombre",
      cantidad: "$items.cantidad",
      precio_venta: "$items.precio_unitario",
      costo_unitario: "$info_producto.costo",
      ganancia_item: {
        $multiply: [
          "$items.cantidad",
          { 
            $subtract: [
              "$items.precio_unitario",
              "$info_producto.costo"
            ]
          }
        ]
      },
      fecha_pedido: 1
    }
  },
  
  // Etapa 6: Ordenar por cliente y fecha
  {
    $sort: { 
      cliente_nombre: 1,
      fecha_pedido: -1
    }
  }
])

### Resultado Esperado
[
  {
    "_id": ObjectId("..."),
    "numero_pedido": "PED-2025-001",
    "cliente_nombre": "Juan García López",
    "cliente_email": "juan@email.com",
    "producto": "Pan de trigo integral",
    "cantidad": 5,
    "precio_venta": 2.50,
    "costo_unitario": 1.20,
    "ganancia_item": 6.50,
    "fecha_pedido": ISODate("2025-12-08T10:30:00Z")
  },
  {
    "_id": ObjectId("..."),
    "numero_pedido": "PED-2025-001",
    "cliente_nombre": "Juan García López",
    "cliente_email": "juan@email.com",
    "producto": "Donas de vainilla",
    "cantidad": 10,
    "precio_venta": 1.50,
    "costo_unitario": 0.70,
    "ganancia_item": 8.00,
    "fecha_pedido": ISODate("2025-12-08T10:30:00Z")
  }
]


### Interpretación
- Permite rastrear qué vendió a cada cliente
- Calcula ganancia real por item vendido
- Útil para análisis de clientes más rentables
- Puede servir para recomendaciones de productos

---

## PIPELINE 4: Productividad de Empleados (BONUS)

### Propósito
Analizar la producción de cada empleado en los últimos días, calculando eficiencia (cantidad/horas) y calidad promedio.

### Código
db.empleados.aggregate([
  // Etapa 1: Filtrar empleados activos
  {
    $match: { activo: true }
  },
  
  // Etapa 2: Descomponer historial de producción
  {
    $unwind: "$historial_produccion"
  },
  
  // Etapa 3: Filtrar producciones recientes (últimos 7 días)
  {
    $match: {
      "historial_produccion.fecha": {
        $gte: ISODate("2025-12-02T00:00:00Z")
      }
    }
  },
  
  // Etapa 4: Agrupar por empleado y calcular KPIs
  {
    $group: {
      _id: {
        empleado: "$nombre",
        cargo: "$cargo"
      },
      total_producido: { $sum: "$historial_produccion.cantidad_producida" },
      total_horas: { $sum: "$historial_produccion.tiempo_horas" },
      numero_jornadas: { $sum: 1 },
      productos_diferentes: { 
        $addToSet: "$historial_produccion.producto"
      }
    }
  },
  
  // Etapa 5: Calcular eficiencia (unidades por hora)
  {
    $project: {
      _id: 0,
      empleado: "$_id.empleado",
      cargo: "$_id.cargo",
      total_producido: 1,
      total_horas: 1,
      numero_jornadas: 1,
      productos_diferentes: 1,
      eficiencia_por_hora: {
        $round: [
          { $divide: ["$total_producido", "$total_horas"] },
          2
        ]
      },
      promedio_por_jornada: {
        $round: [
          { $divide: ["$total_producido", "$numero_jornadas"] },
          2
        ]
      }
    }
  },
  
  // Etapa 6: Ordenar por eficiencia descendente
  {
    $sort: { eficiencia_por_hora: -1 }
  }
])

### Resultado Esperado
[
  {
    "empleado": "Sofia Ramirez Torres",
    "cargo": "Panadero",
    "total_producido": 270,
    "total_horas": 7.5,
    "numero_jornadas": 2,
    "productos_diferentes": ["Pan de trigo integral", "Donas de vainilla"],
    "eficiencia_por_hora": 36.00,
    "promedio_por_jornada": 135.00
  },
  {
    "empleado": "María López Rodríguez",
    "cargo": "Panadero",
    "total_producido": 205,
    "total_horas": 10.5,
    "numero_jornadas": 3,
    "productos_diferentes": ["Pan integral", "Pasteles de chocolate", "Pan de queso"],
    "eficiencia_por_hora": 19.52,
    "promedio_por_jornada": 68.33
  }
]
