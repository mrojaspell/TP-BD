DROP TABLE IF EXISTS pagos_cuotas;
DROP TABLE IF EXISTS prestamos_banco;
DROP TABLE IF EXISTS clientes_banco;
DROP TABLE IF EXISTS backup;

CREATE TABLE clientes_banco
(
    Codigo INT NOT NULL,
    Dni INT NOT NULL,
    Telefono INT NOT NULL,
    Nombre char(20) NOT NULL,
    Direccion CHAR(25) NOT NULL,
    PRIMARY KEY (Codigo)
);

CREATE TABLE prestamos_banco
(
    Codigo INT NOT NULL,
    Fecha DATE NOT NULL,
    Codigo_Cliente INT NOT NULL,
    Importe INT NOT NULL,
    PRIMARY KEY (Codigo),
    FOREIGN KEY (Codigo_Cliente) REFERENCES clientes_banco
);

CREATE TABLE pagos_cuotas
(
    Nro_Cuota INT NOT NULL,
    Codigo_Prestamo INT NOT NULL,
    Importe INT NOT NULL,
    Fecha DATE NOT NULL,
    PRIMARY KEY (Nro_Cuota),
    FOREIGN KEY (Codigo_Prestamo) REFERENCES prestamos_banco
);

CREATE TABLE backup
(
    DNI INT NOT NULL,
    NOMBRE CHAR(20) NOT NULL,
    TELEFONO INT NOT NULL,
    CANT_PRESTAMOS INT NOT NULL,
    MONTO_PRESTAMOS INT NOT NULL,
    MONTO_PAGO_CUENTAS INT NOT NULL,
    IND_PAGOS_PENDIENTES BOOLEAN NOT NULL,
    PRIMARY KEY (DNI)
);

\COPY clientes_banco FROM './clientes_banco.csv' DELIMITER ',' CSV HEADER;
\COPY prestamos_banco FROM './prestamos_banco.csv' DELIMITER ',' CSV HEADER;
\COPY pagos_cuotas FROM './pagos_cuotas.csv' DELIMITER ',' CSV HEADER;

