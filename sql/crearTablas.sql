CREATE TABLE categorias (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE
);

CREATE TABLE subcategorias (
    id_subcategoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_categoria INTEGER NOT NULL REFERENCES categorias (id_categoria),
    nombre TEXT NOT NULL,
    UNIQUE (id_categoria, nombre)
);

CREATE TABLE proveedores (
    id_proveedor INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL,
    contacto_principal TEXT NOT NULL,
    telefono TEXT NOT NULL,
    pais TEXT NOT NULL
);

CREATE TABLE almacenes (
    id_almacen INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL,
    ubicacion TEXT NOT NULL
);

CREATE TABLE productos (
    id_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL,
    id_subcategoria INTEGER NOT NULL REFERENCES subcategorias (id_subcategoria),
    id_proveedor INTEGER NOT NULL REFERENCES proveedores (id_proveedor),
    costo_unitario NUMERIC(12, 2) NOT NULL CHECK (costo_unitario >= 0),
    precio_venta NUMERIC(12, 2) NOT NULL CHECK (precio_venta >= 0)
);

--  crear las tablas de existencias y movimientos
CREATE TABLE existencias (
    id_producto INTEGER NOT NULL REFERENCES productos (id_producto),
    id_almacen INTEGER NOT NULL REFERENCES almacenes (id_almacen),
    stock_actual INTEGER NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo INTEGER NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0),
    stock_optimo INTEGER NOT NULL DEFAULT 0 CHECK (stock_optimo >= stock_minimo),
    unidades_pendientes INTEGER NOT NULL DEFAULT 0 CHECK (unidades_pendientes >= 0),
    pasillo TEXT,
    estante TEXT,
    PRIMARY KEY (id_producto, id_almacen)
);

CREATE TABLE movimientos_inventario (
    id_movimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    id_almacen INTEGER NOT NULL,
    fecha_movimiento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA')),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    saldo_posterior INTEGER CHECK (saldo_posterior >= 0),
    valor_unitario NUMERIC(12, 2) CHECK (valor_unitario >= 0),
    FOREIGN KEY (id_producto, id_almacen)
        REFERENCES existencias (id_producto, id_almacen)
);

-- crear las tablas de ventas y transferencias
CREATE TABLE ventas (
    id_venta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_almacen INTEGER NOT NULL REFERENCES almacenes (id_almacen),
    fecha_venta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE detalle_venta (
    id_venta INTEGER NOT NULL REFERENCES ventas (id_venta),
    id_producto INTEGER NOT NULL REFERENCES productos (id_producto),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12, 2) NOT NULL CHECK (precio_unitario >= 0),
    PRIMARY KEY (id_venta, id_producto)
);

CREATE TABLE transferencias (
    id_transferencia INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL REFERENCES productos (id_producto),
    id_almacen_origen INTEGER NOT NULL REFERENCES almacenes (id_almacen),
    id_almacen_destino INTEGER NOT NULL REFERENCES almacenes (id_almacen),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    fecha_transferencia TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_responsable TEXT NOT NULL,
    CHECK (id_almacen_origen <> id_almacen_destino)
);