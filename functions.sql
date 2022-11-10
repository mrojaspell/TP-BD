DROP TABLE IF EXISTS clientes_banco;
DROP TABLE IF EXISTS prestamos_banco;
DROP TABLE IF EXISTS pagos_cuotas;
DROP TABLE IF EXISTS backup;

CREATE TABLE clientes_banco
(
    codigo INT NOT NULL,
    dni INT NOT NULL,
    telefono INT NOT NULL,
    nombre char(20) NOT NULL,
    direccion CHAR(25) NOT NULL,
    PRIMARY KEY (codigo, dni)
);

CREATE TABLE prestamos_banco
(
    codigo INT NOT NULL,
    fecha DATE NOT NULL,
    codigo_cliente INT NOT NULL,
    importe INT NOT NULL,
    PRIMARY KEY (codigo),
    FOREIGN KEY (codigo_cliente) REFERENCES clientes_banco
);

CREATE TABLE pagos_cuotas
(
    nro_cuota INT NOT NULL,
    codigo_prestamo INT NOT NULL,
    importe INT NOT NULL,
    fecha DATE NOT NULL,
    PRIMARY KEY (nro_cuota),
    FOREIGN KEY (codigo_prestamo) REFERENCES prestamos_banco
);

CREATE TABLE backup
(
    dni INT NOT NULL,
    nombre CHAR(20) NOT NULL,
    telefono INT NOT NULL,
    cant_prestamos INT NOT NULL,
    monto_prestamos INT NOT NULL,
    monto_pago_cuentas INT NOT NULL,
    pagos_pendientes BOOLEAN NOT NULL,
    PRIMARY KEY (dni)
);

COPY clientes_banco FROM 'C:\Users\machi\OneDrive\Escritorio\BD\TP-BD\clientes_banco.csv';
COPY prestamos_banco FROM 'C:\Users\machi\OneDrive\Escritorio\BD\TP-BD\prestamos_banco.csv';

