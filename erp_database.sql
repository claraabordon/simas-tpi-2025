-- =====================================================
-- SCRIPT SQL PARA ERP - SISTEMA INTEGRADO DE GESTIÓN
-- Base de datos: MariaDB/MySQL
-- =====================================================

-- Crear la base de datos
DROP DATABASE IF EXISTS erp_sistema;
CREATE DATABASE erp_sistema 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE erp_sistema;

-- =====================================================
-- MÓDULO: ABM USUARIOS
-- =====================================================

-- Tabla de roles de usuario
CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de permisos
CREATE TABLE permisos (
    id_permiso INT AUTO_INCREMENT PRIMARY KEY,
    nombre_permiso VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    modulo VARCHAR(50) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de relación roles-permisos
CREATE TABLE rol_permisos (
    id_rol INT,
    id_permiso INT,
    PRIMARY KEY (id_rol, id_permiso),
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE,
    FOREIGN KEY (id_permiso) REFERENCES permisos(id_permiso) ON DELETE CASCADE
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni_cuit VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    usuario_login VARCHAR(50) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fecha_baja TIMESTAMP NULL,
    motivo_baja TEXT,
    usuario_modificacion INT,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    FOREIGN KEY (usuario_modificacion) REFERENCES usuarios(id_usuario)
);

-- =====================================================
-- MÓDULO: ABM CLIENTES
-- =====================================================

-- Tabla de categorías de cliente
CREATE TABLE categorias_cliente (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    descuento_porcentaje DECIMAL(5,2) DEFAULT 0.00,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de formas de pago
CREATE TABLE formas_pago (
    id_forma_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre_forma_pago VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    requiere_aprobacion BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_razon_social VARCHAR(255) NOT NULL,
    cuit_cuil VARCHAR(20) NOT NULL UNIQUE,
    tipo_cliente ENUM('FISICA', 'JURIDICA') NOT NULL,
    email VARCHAR(255),
    telefono VARCHAR(20),
    direccion TEXT,
    id_categoria INT NOT NULL,
    id_forma_pago_preferida INT,
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fecha_baja TIMESTAMP NULL,
    motivo_baja TEXT,
    usuario_alta INT,
    usuario_modificacion INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias_cliente(id_categoria),
    FOREIGN KEY (id_forma_pago_preferida) REFERENCES formas_pago(id_forma_pago),
    FOREIGN KEY (usuario_alta) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (usuario_modificacion) REFERENCES usuarios(id_usuario)
);

-- Tabla de estados de reclamo
CREATE TABLE estados_reclamo (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    es_estado_final BOOLEAN DEFAULT FALSE
);

-- Tabla de reclamos
CREATE TABLE reclamos (
    id_reclamo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    numero_orden VARCHAR(50),
    id_sku INT, -- Se definirá cuando creemos la tabla de artículos
    motivo TEXT NOT NULL,
    descripcion_detallada TEXT,
    id_estado INT NOT NULL,
    fecha_reclamo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre TIMESTAMP NULL,
    usuario_asignado INT,
    usuario_creacion INT NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_estado) REFERENCES estados_reclamo(id_estado),
    FOREIGN KEY (usuario_asignado) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (usuario_creacion) REFERENCES usuarios(id_usuario)
);

-- =====================================================
-- MÓDULO: ABM ARTÍCULOS
-- =====================================================

-- Tabla de proveedores
CREATE TABLE proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_razon_social VARCHAR(255) NOT NULL,
    cuit VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255),
    telefono VARCHAR(20),
    direccion TEXT,
    contacto_responsable VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de categorías de artículo
CREATE TABLE categorias_articulo (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de artículos (SKU)
CREATE TABLE articulos (
    id_sku INT AUTO_INCREMENT PRIMARY KEY,
    codigo_sku VARCHAR(50) NOT NULL UNIQUE,
    nombre_articulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    id_categoria INT NOT NULL,
    id_proveedor_principal INT,
    precio_costo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    stock_minimo INT NOT NULL DEFAULT 0,
    stock_maximo INT DEFAULT NULL,
    unidad_medida VARCHAR(20) NOT NULL DEFAULT 'UNIDAD',
    peso DECIMAL(8,3) DEFAULT 0.000,
    volumen DECIMAL(8,3) DEFAULT 0.000,
    activo BOOLEAN DEFAULT TRUE,
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria) REFERENCES categorias_articulo(id_categoria),
    FOREIGN KEY (id_proveedor_principal) REFERENCES proveedores(id_proveedor)
);

-- Tabla de ubicaciones de almacén
CREATE TABLE ubicaciones_almacen (
    id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
    zona VARCHAR(50) NOT NULL,
    pasillo VARCHAR(50) NOT NULL,
    estante VARCHAR(50) NOT NULL,
    posicion VARCHAR(50),
    descripcion TEXT,
    capacidad_maxima INT DEFAULT NULL,
    activo BOOLEAN DEFAULT TRUE,
    UNIQUE KEY unique_ubicacion (zona, pasillo, estante, posicion)
);

-- Tabla de stock actual
CREATE TABLE stock_actual (
    id_sku INT,
    id_ubicacion INT,
    cantidad_disponible INT NOT NULL DEFAULT 0,
    cantidad_reservada INT NOT NULL DEFAULT 0,
    fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_sku, id_ubicacion),
    FOREIGN KEY (id_sku) REFERENCES articulos(id_sku) ON DELETE CASCADE,
    FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones_almacen(id_ubicacion) ON DELETE CASCADE
);

-- Tabla de movimientos de stock
CREATE TABLE movimientos_stock (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_sku INT NOT NULL,
    id_ubicacion INT NOT NULL,
    tipo_movimiento ENUM('INGRESO', 'EGRESO', 'TRANSFERENCIA', 'AJUSTE') NOT NULL,
    cantidad INT NOT NULL,
    cantidad_anterior INT NOT NULL,
    cantidad_nueva INT NOT NULL,
    motivo VARCHAR(255),
    numero_documento VARCHAR(100),
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_responsable INT NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (id_sku) REFERENCES articulos(id_sku),
    FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones_almacen(id_ubicacion),
    FOREIGN KEY (usuario_responsable) REFERENCES usuarios(id_usuario)
);

-- =====================================================
-- MÓDULO: GESTIÓN DE VENTAS Y STOCK
-- =====================================================

-- Tabla de estados de orden
CREATE TABLE estados_orden (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    es_estado_final BOOLEAN DEFAULT FALSE,
    orden_secuencia INT NOT NULL DEFAULT 0
);

-- Tabla de órdenes de pedido
CREATE TABLE ordenes_pedido (
    id_orden INT AUTO_INCREMENT PRIMARY KEY,
    numero_orden VARCHAR(50) NOT NULL UNIQUE,
    id_cliente INT NOT NULL,
    id_estado INT NOT NULL,
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega_estimada DATE,
    fecha_entrega_real DATE,
    total_orden DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento_porcentaje DECIMAL(5,2) DEFAULT 0.00,
    descuento_monto DECIMAL(10,2) DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuestos DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT,
    usuario_creacion INT NOT NULL,
    usuario_modificacion INT,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_estado) REFERENCES estados_orden(id_estado),
    FOREIGN KEY (usuario_creacion) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (usuario_modificacion) REFERENCES usuarios(id_usuario)
);

-- Tabla de detalle de órdenes de pedido
CREATE TABLE detalle_ordenes_pedido (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    id_sku INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_entregada INT NOT NULL DEFAULT 0,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento_porcentaje DECIMAL(5,2) DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (id_orden) REFERENCES ordenes_pedido(id_orden) ON DELETE CASCADE,
    FOREIGN KEY (id_sku) REFERENCES articulos(id_sku)
);

-- Tabla de órdenes de picking
CREATE TABLE ordenes_picking (
    id_picking INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    usuario_asignado INT,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_inicio_picking TIMESTAMP NULL,
    fecha_fin_picking TIMESTAMP NULL,
    estado ENUM('PENDIENTE', 'EN_PROCESO', 'COMPLETADO', 'CANCELADO') DEFAULT 'PENDIENTE',
    observaciones TEXT,
    FOREIGN KEY (id_orden) REFERENCES ordenes_pedido(id_orden),
    FOREIGN KEY (usuario_asignado) REFERENCES usuarios(id_usuario)
);

-- Tabla de estados de orden de compra
CREATE TABLE estados_orden_compra (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    es_estado_final BOOLEAN DEFAULT FALSE,
    orden_secuencia INT NOT NULL DEFAULT 0
);

-- Tabla de órdenes de compra
CREATE TABLE ordenes_compra (
    id_orden_compra INT AUTO_INCREMENT PRIMARY KEY,
    numero_orden_compra VARCHAR(50) NOT NULL UNIQUE,
    id_proveedor INT NOT NULL,
    id_estado INT NOT NULL,
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_aprobacion TIMESTAMP NULL,
    fecha_entrega_estimada DATE,
    fecha_entrega_real DATE,
    total_orden DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT,
    usuario_solicitante INT NOT NULL,
    usuario_aprobador INT,
    usuario_receptor INT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
    FOREIGN KEY (id_estado) REFERENCES estados_orden_compra(id_estado),
    FOREIGN KEY (usuario_solicitante) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (usuario_aprobador) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (usuario_receptor) REFERENCES usuarios(id_usuario)
);

-- Tabla de detalle de órdenes de compra
CREATE TABLE detalle_ordenes_compra (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_orden_compra INT NOT NULL,
    id_sku INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_recibida INT NOT NULL DEFAULT 0,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (id_orden_compra) REFERENCES ordenes_compra(id_orden_compra) ON DELETE CASCADE,
    FOREIGN KEY (id_sku) REFERENCES articulos(id_sku)
);

-- Tabla de trazabilidad de envíos
CREATE TABLE trazabilidad_envios (
    id_envio INT AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    codigo_seguimiento VARCHAR(100) NOT NULL UNIQUE,
    empresa_transporte VARCHAR(100),
    fecha_despacho TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_estimada_entrega DATE,
    fecha_entrega_real TIMESTAMP NULL,
    estado_envio ENUM('PREPARADO', 'EN_TRANSITO', 'EN_DISTRIBUCION', 'ENTREGADO', 'DEVUELTO') DEFAULT 'PREPARADO',
    observaciones TEXT,
    FOREIGN KEY (id_orden) REFERENCES ordenes_pedido(id_orden)
);

-- Tabla de puntos de control de envío
CREATE TABLE puntos_control_envio (
    id_punto_control INT AUTO_INCREMENT PRIMARY KEY,
    id_envio INT NOT NULL,
    ubicacion VARCHAR(255) NOT NULL,
    descripcion_evento TEXT,
    fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT,
    FOREIGN KEY (id_envio) REFERENCES trazabilidad_envios(id_envio) ON DELETE CASCADE
);

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices para tabla usuarios
CREATE INDEX idx_usuarios_login ON usuarios(usuario_login);
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_dni ON usuarios(dni_cuit);
CREATE INDEX idx_usuarios_activo ON usuarios(activo);

-- Índices para tabla clientes
CREATE INDEX idx_clientes_cuit ON clientes(cuit_cuil);
CREATE INDEX idx_clientes_nombre ON clientes(nombre_razon_social);
CREATE INDEX idx_clientes_activo ON clientes(activo);
CREATE INDEX idx_clientes_categoria ON clientes(id_categoria);

-- Índices para tabla artículos
CREATE INDEX idx_articulos_codigo ON articulos(codigo_sku);
CREATE INDEX idx_articulos_nombre ON articulos(nombre_articulo);
CREATE INDEX idx_articulos_categoria ON articulos(id_categoria);
CREATE INDEX idx_articulos_proveedor ON articulos(id_proveedor_principal);
CREATE INDEX idx_articulos_activo ON articulos(activo);

-- Índices para tabla stock
CREATE INDEX idx_stock_sku ON stock_actual(id_sku);
CREATE INDEX idx_stock_ubicacion ON stock_actual(id_ubicacion);
CREATE INDEX idx_movimientos_stock_sku ON movimientos_stock(id_sku);
CREATE INDEX idx_movimientos_stock_fecha ON movimientos_stock(fecha_movimiento);

-- Índices para tabla órdenes
CREATE INDEX idx_ordenes_numero ON ordenes_pedido(numero_orden);
CREATE INDEX idx_ordenes_cliente ON ordenes_pedido(id_cliente);
CREATE INDEX idx_ordenes_estado ON ordenes_pedido(id_estado);
CREATE INDEX idx_ordenes_fecha ON ordenes_pedido(fecha_orden);

-- Índices para tabla reclamos
CREATE INDEX idx_reclamos_cliente ON reclamos(id_cliente);
CREATE INDEX idx_reclamos_estado ON reclamos(id_estado);
CREATE INDEX idx_reclamos_fecha ON reclamos(fecha_reclamo);

-- =====================================================
-- DATOS INICIALES (INSERTS)
-- =====================================================

-- Insertar roles básicos
INSERT INTO roles (nombre_rol, descripcion) VALUES
('ADMINISTRADOR', 'Administrador del sistema con acceso completo'),
('GERENTE', 'Gerente con acceso a reportes y gestión'),
('VENDEDOR', 'Vendedor con acceso a clientes y ventas'),
('OPERARIO_DEPOSITO', 'Operario de depósito con acceso a stock y picking'),
('COMPRAS', 'Personal del área de compras'),
('ATENCION_CLIENTES', 'Personal de atención al cliente y reclamos');

-- Insertar permisos básicos
INSERT INTO permisos (nombre_permiso, descripcion, modulo) VALUES
-- Permisos módulo usuarios
('usuarios_crear', 'Crear usuarios', 'USUARIOS'),
('usuarios_editar', 'Editar usuarios', 'USUARIOS'),
('usuarios_eliminar', 'Eliminar usuarios', 'USUARIOS'),
('usuarios_ver', 'Ver usuarios', 'USUARIOS'),
('usuarios_cambiar_rol', 'Cambiar roles de usuario', 'USUARIOS'),

-- Permisos módulo clientes
('clientes_crear', 'Crear clientes', 'CLIENTES'),
('clientes_editar', 'Editar clientes', 'CLIENTES'),
('clientes_eliminar', 'Eliminar clientes', 'CLIENTES'),
('clientes_ver', 'Ver clientes', 'CLIENTES'),
('reclamos_gestionar', 'Gestionar reclamos', 'CLIENTES'),

-- Permisos módulo artículos
('articulos_crear', 'Crear artículos', 'ARTICULOS'),
('articulos_editar', 'Editar artículos', 'ARTICULOS'),
('articulos_eliminar', 'Eliminar artículos', 'ARTICULOS'),
('articulos_ver', 'Ver artículos', 'ARTICULOS'),
('stock_gestionar', 'Gestionar stock', 'ARTICULOS'),
('ubicaciones_gestionar', 'Gestionar ubicaciones', 'ARTICULOS'),

-- Permisos módulo ventas
('ordenes_crear', 'Crear órdenes de venta', 'VENTAS'),
('ordenes_editar', 'Editar órdenes de venta', 'VENTAS'),
('ordenes_ver', 'Ver órdenes de venta', 'VENTAS'),
('picking_gestionar', 'Gestionar picking', 'VENTAS'),
('envios_gestionar', 'Gestionar envíos', 'VENTAS'),

-- Permisos módulo compras
('compras_crear', 'Crear órdenes de compra', 'COMPRAS'),
('compras_aprobar', 'Aprobar órdenes de compra', 'COMPRAS'),
('compras_recibir', 'Recibir mercadería', 'COMPRAS'),
('compras_ver', 'Ver órdenes de compra', 'COMPRAS'),

-- Permisos reportes
('reportes_ver', 'Ver reportes', 'REPORTES'),
('reportes_exportar', 'Exportar reportes', 'REPORTES');

-- Asignar permisos a roles
-- Administrador: todos los permisos
INSERT INTO rol_permisos (id_rol, id_permiso)
SELECT 1, id_permiso FROM permisos;

-- Gerente: permisos de gestión y reportes
INSERT INTO rol_permisos (id_rol, id_permiso) VALUES
(2, 1), (2, 2), (2, 4), (2, 7), (2, 8), (2, 10), (2, 12), (2, 13), (2, 15), 
(2, 17), (2, 19), (2, 20), (2, 21), (2, 23), (2, 25), (2, 26), (2, 27), (2, 28);

-- Vendedor: permisos de clientes y ventas
INSERT INTO rol_permisos (id_rol, id_permiso) VALUES
(3, 7), (3, 8), (3, 10), (3, 11), (3, 13), (3, 14), (3, 17), (3, 18), (3, 19);

-- Operario de depósito: permisos de stock y picking
INSERT INTO rol_permisos (id_rol, id_permiso) VALUES
(4, 13), (4, 14), (4, 15), (4, 16), (4, 20), (4, 21);

-- Compras: permisos de compras
INSERT INTO rol_permisos (id_rol, id_permiso) VALUES
(5, 13), (5, 14), (5, 23), (5, 24), (5, 25), (5, 26);

-- Atención al cliente: permisos de clientes y reclamos
INSERT INTO rol_permisos (id_rol, id_permiso) VALUES
(6, 7), (6, 8), (6, 10), (6, 11), (6, 17), (6, 18);

-- Insertar categorías de cliente
INSERT INTO categorias_cliente (nombre_categoria, descripcion, descuento_porcentaje) VALUES
('MINORISTA', 'Cliente minorista - compra pequeñas cantidades', 0.00),
('MAYORISTA', 'Cliente mayorista - compra grandes cantidades', 5.00),
('EMPRESA', 'Cliente empresa con descuentos especiales', 10.00),
('PARTICULAR', 'Cliente particular - sin descuentos', 0.00);

-- Insertar formas de pago
INSERT INTO formas_pago (nombre_forma_pago, descripcion, requiere_aprobacion) VALUES
('EFECTIVO', 'Pago en efectivo', FALSE),
('TARJETA_CREDITO', 'Pago con tarjeta de crédito', FALSE),
('TARJETA_DEBITO', 'Pago con tarjeta de débito', FALSE),
('TRANSFERENCIA', 'Transferencia bancaria', FALSE),
('CUENTA_CORRIENTE', 'Pago a cuenta corriente', TRUE),
('CHEQUE', 'Pago con cheque', TRUE);

-- Insertar estados de reclamo
INSERT INTO estados_reclamo (nombre_estado, descripcion, es_estado_final) VALUES
('NUEVO', 'Reclamo recién ingresado', FALSE),
('EN_PROCESO', 'Reclamo siendo procesado', FALSE),
('ESPERANDO_CLIENTE', 'Esperando respuesta del cliente', FALSE),
('SOLUCIONADO', 'Reclamo solucionado', TRUE),
('RECHAZADO', 'Reclamo rechazado', TRUE);

-- Insertar categorías de artículo
INSERT INTO categorias_articulo (nombre_categoria, descripcion) VALUES
('ELECTRONICA', 'Productos electrónicos'),
('ROPA', 'Indumentaria y accesorios'),
('HOGAR', 'Artículos para el hogar'),
('DEPORTES', 'Artículos deportivos'),
('LIBROS', 'Libros y material educativo'),
('AUTOMOTOR', 'Repuestos y accesorios para vehículos');

-- Insertar estados de orden
INSERT INTO estados_orden (nombre_estado, descripcion, es_estado_final, orden_secuencia) VALUES
('PENDIENTE', 'Orden pendiente de validación', FALSE, 1),
('CONFIRMADA', 'Orden confirmada y lista para picking', FALSE, 2),
('EN_PICKING', 'Orden siendo procesada en depósito', FALSE, 3),
('LISTA_DESPACHO', 'Orden lista para despacho', FALSE, 4),
('ENVIADA', 'Orden enviada al cliente', FALSE, 5),
('ENTREGADA', 'Orden entregada al cliente', TRUE, 6),
('CANCELADA', 'Orden cancelada', TRUE, 7);

-- Insertar estados de orden de compra
INSERT INTO estados_orden_compra (nombre_estado, descripcion, es_estado_final, orden_secuencia) VALUES
('PENDIENTE', 'Orden pendiente de aprobación', FALSE, 1),
('APROBADA', 'Orden aprobada y enviada al proveedor', FALSE, 2),
('CONFIRMADA', 'Orden confirmada por el proveedor', FALSE, 3),
('EN_TRANSITO', 'Productos en tránsito', FALSE, 4),
('RECIBIDA', 'Productos recibidos', TRUE, 5),
('CANCELADA', 'Orden cancelada', TRUE, 6);

-- Insertar ubicaciones de almacén de ejemplo
INSERT INTO ubicaciones_almacen (zona, pasillo, estante, posicion, descripcion) VALUES
('A', '01', '01', '01', 'Zona A - Pasillo 1 - Estante 1 - Posición 1'),
('A', '01', '01', '02', 'Zona A - Pasillo 1 - Estante 1 - Posición 2'),
('A', '01', '02', '01', 'Zona A - Pasillo 1 - Estante 2 - Posición 1'),
('B', '01', '01', '01', 'Zona B - Pasillo 1 - Estante 1 - Posición 1'),
('B', '01', '01', '02', 'Zona B - Pasillo 1 - Estante 1 - Posición 2'),
('C', '01', '01', '01', 'Zona C - Pasillo 1 - Estante 1 - Posición 1');

-- Crear usuario administrador por defecto
INSERT INTO usuarios (nombre, apellido, dni_cuit, email, usuario_login, contrasena_hash, id_rol) VALUES
('Administrador', 'Sistema', '12345678901', 'admin@empresa.com', 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1);

-- =====================================================
-- TRIGGERS PARA AUDITORÍA Y LÓGICA DE NEGOCIO
-- =====================================================

-- Trigger para actualizar stock cuando se registra un movimiento
DELIMITER //
CREATE TRIGGER tr_actualizar_stock_after_movimiento
AFTER INSERT ON movimientos_stock
FOR EACH ROW
BEGIN
    IF NEW.tipo_movimiento = 'INGRESO' THEN
        INSERT INTO stock_actual (id_sku, id_ubicacion, cantidad_disponible)
        VALUES (NEW.id_sku, NEW.id_ubicacion, NEW.cantidad)
        ON DUPLICATE KEY UPDATE
        cantidad_disponible = cantidad_disponible + NEW.cantidad;
    ELSEIF NEW.tipo_movimiento = 'EGRESO' THEN
        UPDATE stock_actual 
        SET cantidad_disponible = cantidad_disponible - NEW.cantidad
        WHERE id_sku = NEW.id_sku AND id_ubicacion = NEW.id_ubicacion;
    END IF;
END//
DELIMITER ;

-- Trigger para validar stock mínimo y generar alerta
DELIMITER //
CREATE TRIGGER tr_validar_stock_minimo
AFTER UPDATE ON stock_actual
FOR EACH ROW
BEGIN
    DECLARE stock_minimo_sku INT;
    DECLARE stock_total INT;
    
    -- Obtener stock mínimo del artículo
    SELECT stock_minimo INTO stock_minimo_sku
    FROM articulos 
    WHERE id_sku = NEW.id_sku;
    
    -- Calcular stock total del SKU en todas las ubicaciones
    SELECT SUM(cantidad_disponible) INTO stock_total
    FROM stock_actual 
    WHERE id_sku = NEW.id_sku;
    
    -- Si el stock total es menor al mínimo, se podría generar una alerta
    -- (aquí se podría insertar en una tabla de alertas)
    IF stock_total <= stock_minimo_sku THEN
        -- Log de alerta de stock bajo (podría expandirse)
        INSERT INTO movimientos_stock (id_sku, id_ubicacion, tipo_movimiento, cantidad, cantidad_anterior, cantidad_nueva, motivo, usuario_responsable)
        VALUES (NEW.id_sku, NEW.id_ubicacion, 'AJUSTE', 0, NEW.cantidad_disponible, NEW.cantidad_disponible, 'ALERTA: Stock por debajo del mínimo', 1);
    END IF;
END//
DELIMITER ;

-- =====================================================
-- VISTAS ÚTILES PARA REPORTES
-- =====================================================

-- Vista de clientes activos con información completa
CREATE VIEW v_clientes_activos AS
SELECT 
    c.id_cliente,
    c.nombre_razon_social,
    c.cuit_cuil,
    c.tipo_cliente,
    c.email,
    c.telefono,
    cc.nombre_categoria,
    fp.nombre_forma_pago,
    c.fecha_alta
FROM clientes c
JOIN categorias_cliente cc ON c.id_categoria = cc.id_categoria
LEFT JOIN formas_pago fp ON c.id_forma_pago_preferida = fp.id_forma_pago
WHERE c.activo = TRUE;

-- Vista de stock actual con información de artículos
CREATE VIEW v_stock_actual_detalle AS
SELECT 
    s.id_sku,
    a.codigo_sku,
    a.nombre_articulo,
    ca.nombre_categoria,
    ua.zona,
    ua.pasillo,
    ua.estante,
    ua.posicion,
    s.cantidad_disponible,
    s.cantidad_reservada,
    a.stock_minimo,
    a.stock_maximo,
    (s.cantidad_disponible <= a.stock_minimo) AS stock_bajo
FROM stock_actual s
JOIN articulos a ON s.id_sku = a.id_sku
JOIN categorias_articulo ca ON a.id_categoria = ca.id_categoria
JOIN ubicaciones_almacen ua ON s.id_ubicacion = ua.id_ubicacion
WHERE a.activo = TRUE;

-- Vista de órdenes de venta con información completa
CREATE VIEW v_ordenes_venta_detalle AS
SELECT 
    o.id_orden,
    o.numero_orden,
    c.nombre_razon_social AS cliente,
    eo.nombre_estado,
    o.fecha_orden,
    o.fecha_entrega_estimada,
    o.total_orden,
    u.usuario_login AS vendedor
FROM ordenes_pedido o
JOIN clientes c ON o.id_cliente = c.id_cliente
JOIN estados_orden eo ON o.id_estado = eo.id_estado
JOIN usuarios u ON o.usuario_creacion = u.id_usuario;

-- =====================================================
-- PROCEDIMIENTOS ALMACENADOS ÚTILES
-- =====================================================

-- Procedimiento para generar número de orden automático
DELIMITER //
CREATE PROCEDURE sp_generar_numero_orden(OUT numero_orden VARCHAR(50))
BEGIN
    DECLARE contador INT DEFAULT 1;
    DECLARE fecha_actual VARCHAR(8);
    
    SET fecha_actual = DATE_FORMAT(NOW(), '%Y%m%d');
    
    -- Buscar el último número del día
    SELECT COALESCE(MAX(CAST(SUBSTRING(numero_orden, 10) AS UNSIGNED)), 0) + 1
    INTO contador
    FROM ordenes_pedido
    WHERE numero_orden LIKE CONCAT('ORD-', fecha_actual, '-%');
    
    SET numero_orden = CONCAT('ORD-', fecha_actual, '-', LPAD(contador, 4, '0'));
END//
DELIMITER ;

-- Procedimiento para verificar disponibilidad de stock
DELIMITER //
CREATE PROCEDURE sp_verificar_disponibilidad_stock(
    IN p_id_sku INT,
    IN p_cantidad_solicitada INT,
    OUT p_disponible BOOLEAN,
    OUT p_cantidad_disponible INT
)
BEGIN
    DECLARE stock_total INT DEFAULT 0;
    
    -- Calcular stock total disponible
    SELECT COALESCE(SUM(cantidad_disponible - cantidad_reservada), 0)
    INTO stock_total
    FROM stock_actual
    WHERE id_sku = p_id_sku;
    
    SET p_cantidad_disponible = stock_total;
    SET p_disponible = (stock_total >= p_cantidad_solicitada);
END//
DELIMITER ;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Mostrar mensaje de finalización
SELECT 'Base de datos ERP creada exitosamente' AS mensaje;
