-- insertar los datos de catalogo del anexo 1
INSERT INTO categorias (nombre)
VALUES
    ('Muebles'),
    ('Electrónica'),
    ('Accesorios');

INSERT INTO subcategorias (id_categoria, nombre)
SELECT c.id_categoria, datos.subcategoria
FROM (
    VALUES
        ('Electrónica', 'Monitores'),
        ('Electrónica', 'Periféricos'),
        ('Muebles', 'Oficina'),
        ('Accesorios', 'Periféricos'),
        ('Accesorios', 'Cables')
) AS datos (categoria, subcategoria)
JOIN categorias AS c ON c.nombre = datos.categoria;

INSERT INTO proveedores (nombre, contacto_principal, telefono, pais)
VALUES
    ('Tech Supplies Co.', 'Carlos Ruiz', '+506 8888-1111', 'Costa Rica'),
    ('Muebles & Confort', 'Ana Gómez', '+506 8888-2222', 'Costa Rica'),
    ('Importadora Global', 'Luis Mora', '+506 8888-3333', 'Costa Rica');

INSERT INTO almacenes (nombre, ubicacion)
VALUES
    ('Almacén Central', 'Cartago, Costa Rica'),
    ('Bodega Norte', 'San José, Costa Rica');

-- insertar los productos del anexo 1
INSERT INTO productos (
    sku, nombre, id_subcategoria, id_proveedor, costo_unitario, precio_venta
)
SELECT
    datos.sku,
    datos.producto,
    s.id_subcategoria,
    p.id_proveedor,
    datos.costo_unitario,
    datos.precio_venta
FROM (
    VALUES
        ('ELE-101', 'Monitor Gamer 27" 144Hz', 'Electrónica', 'Monitores',
         'Tech Supplies Co.', 180.00, 280.00),
        ('ELE-102', 'Teclado Mecánico RGB', 'Electrónica', 'Periféricos',
         'Tech Supplies Co.', 35.00, 65.00),
        ('OFF-201', 'Silla Ergonómica Ejecutiva', 'Muebles', 'Oficina',
         'Muebles & Confort', 110.00, 195.00),
        ('OFF-202', 'Escritorio Ajustable de Pie', 'Muebles', 'Oficina',
         'Muebles & Confort', 210.00, 350.00),
        ('ACC-301', 'Mousepad XL Antideslizante', 'Accesorios', 'Periféricos',
         'Importadora Global', 6.50, 15.00),
        ('ACC-302', 'Cable HDMI 2.1 2m', 'Accesorios', 'Cables',
         'Importadora Global', 3.00, 8.00)
) AS datos (
    sku, producto, categoria, subcategoria, proveedor, costo_unitario, precio_venta
)
JOIN categorias AS c ON c.nombre = datos.categoria
JOIN subcategorias AS s
    ON s.id_categoria = c.id_categoria
   AND s.nombre = datos.subcategoria
JOIN proveedores AS p ON p.nombre = datos.proveedor
RETURNING sku, nombre;


-- insertar las existencias del anexo 1
-- Datos de prueba: stock optimo = doble del minimo, unidades pendientes = 0
INSERT INTO existencias (
    id_producto, id_almacen, stock_actual, stock_minimo,
    stock_optimo, unidades_pendientes, pasillo, estante
)
SELECT
    p.id_producto,
    a.id_almacen,
    datos.stock_actual,
    datos.stock_minimo,
    datos.stock_minimo * 2,
    0,
    datos.pasillo,
    datos.estante
FROM (
    VALUES
        ('ELE-101', 'Almacén Central', 15,  5, 'A', '01'),
        ('ELE-102', 'Almacén Central',  4, 10, 'A', '02'),
        ('OFF-201', 'Almacén Central',  8,  3, 'B', '05'),
        ('OFF-202', 'Almacén Central',  0,  2, 'B', '06'),
        ('ACC-301', 'Bodega Norte',    45, 15, 'C', '01'),
        ('ACC-302', 'Bodega Norte',     8, 12, 'C', '03')
) AS datos (sku, almacen, stock_actual, stock_minimo, pasillo, estante)
JOIN productos AS p ON p.sku = datos.sku
JOIN almacenes AS a ON a.nombre = datos.almacen
RETURNING id_producto, id_almacen, stock_actual, stock_minimo;

-- registrar las ultimas entradas del anexo 1
INSERT INTO movimientos_inventario (
    id_producto, id_almacen, fecha_movimiento, tipo_movimiento, cantidad
)
SELECT
    p.id_producto,
    a.id_almacen,
    datos.fecha_entrada,
    'ENTRADA',
    datos.cantidad
FROM (
    VALUES
        ('ELE-101', 'Almacén Central', DATE '2026-10-15', 10),
        ('ELE-102', 'Almacén Central', DATE '2026-09-20', 20),
        ('OFF-201', 'Almacén Central', DATE '2026-10-01',  5),
        ('OFF-202', 'Almacén Central', DATE '2026-08-10',  2),
        ('ACC-301', 'Bodega Norte',    DATE '2026-10-18', 50),
        ('ACC-302', 'Bodega Norte',    DATE '2026-09-05', 30)
) AS datos (sku, almacen, fecha_entrada, cantidad)
JOIN productos AS p ON p.sku = datos.sku
JOIN almacenes AS a ON a.nombre = datos.almacen
RETURNING id_producto, id_almacen, fecha_movimiento, tipo_movimiento, cantidad;

