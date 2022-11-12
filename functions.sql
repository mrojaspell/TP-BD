DROP TABLE IF EXISTS pagos_cuotas;
DROP TABLE IF EXISTS prestamos_banco;
DROP TABLE IF EXISTS clientes_banco;
DROP TABLE IF EXISTS backup;

CREATE TABLE clientes_banco
(
    Codigo INT NOT NULL,
    Dni INT NOT NULL,
    Telefono VARCHAR,
    Nombre VARCHAR NOT NULL,
    Direccion VARCHAR,
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
    FOREIGN KEY (Codigo_Prestamo) REFERENCES prestamos_banco
);

CREATE TABLE backup
(
    ENTRADA INT NOT NULL,
    DNI INT NOT NULL,
    NOMBRE VARCHAR NOT NULL,
    TELEFONO INT NOT NULL,
    CANT_PRESTAMOS INT NOT NULL,
    MONTO_PRESTAMOS INT NOT NULL,
    MONTO_PAGO_CUENTAS INT,
    IND_PAGOS_PENDIENTES BOOLEAN NOT NULL,
    PRIMARY KEY (ENTRADA)
);
/*

para correr estos es necesesario llevar los archivos .csv a pampero


ssh nombre@pampero.itba.edu.ar
psql -h bd1.it.itba.edu.ar -U nombre PROOF


\COPY clientes_banco FROM './clientes_banco.csv' DELIMITER ',' CSV HEADER;
\COPY prestamos_banco FROM './prestamos_banco.csv' DELIMITER ',' CSV HEADER;
\COPY pagos_cuotas FROM './pagos_cuotas.csv' DELIMITER ',' CSV HEADER;
*/


/* Pto D: TRIGGER */
CREATE TRIGGER deleteTrigger
        BEFORE DELETE ON clientes_banco
    FOR EACH ROW
    EXECUTE PROCEDURE fillBackup();
END;

CREATE SEQUENCE backupID
    START WITH 1
    INCREMENT BY 1;
END;


CREATE OR REPLACE FUNCTION fillBackup()
    RETURNS TRIGGER AS
$$
    DECLARE
        ENTRADA INT;
        DNI INT;
        NOMBRE  VARCHAR(36);
        TELEFONO    VARCHAR(18);
        CANT_PRESTAMOS  INT := 0;
        MONTO_PRESTAMOS INT  := 0;
        MONTO_PAGO_CUENTAS   INT  := 0;

        pago RECORD;
        prestamo RECORD;

        cPago CURSOR FOR
            SELECT pa.importe FROM pagos_cuotas pa WHERE pa.codigo_prestamo = prestamo.codigo;

        cPrestamo CURSOR FOR
            SELECT pr.importe, pr.codigo FROM prestamos_banco pr WHERE pr.codigo_cliente=OLD.Codigo;

        BEGIN
        ENTRADA=nextval(backupID);
        DNI=OLD.Dni;
        NOMBRE=OLD.Nombre;
        TELEFONO=OLD.telefono;

        OPEN cPrestamo;
        LOOP
            FETCH cPrestamo INTO prestamo;
            EXIT WHEN NOT FOUND;

            MONTO_PRESTAMOS= MONTO_PRESTAMOS + prestamo.importe;
            CANT_PRESTAMOS= CANT_PRESTAMOS +1;

            OPEN cPago;
            LOOP
                FETCH cPago INTO pago;
                EXIT WHEN NOT FOUND;

                MONTO_PAGO_CUENTAS= MONTO_PAGO_CUENTAS+ pago.importe;

            END LOOP;
            CLOSE cPago;
        END LOOP;
        CLOSE cPrestamo;

        INSERT INTO backup values(DNI, NOMBRE, TELEFONO, CANT_PRESTAMOS, MONTO_PRESTAMOS, MONTO_PAGO_CUENTAS, MONTO_PAGO_CUENTAS< MONTO_PRESTAMOS);
        RETURN OLD;
    END

$$ LANGUAGE plpgsql