DROP TABLE IF EXISTS pagos_cuotas;
DROP TABLE IF EXISTS prestamos_banco;
DROP TABLE IF EXISTS clientes_banco;
DROP TABLE IF EXISTS backup;

CREATE TABLE clientes_banco
(
    Codigo INT NOT NULL,
    Dni INT NOT NULL CHECK ( Dni > 0 ),
    Telefono TEXT,
    Nombre TEXT NOT NULL,
    Direccion TEXT,
    PRIMARY KEY (Codigo)
);

CREATE TABLE prestamos_banco
(
    Codigo INT NOT NULL,
    Fecha DATE NOT NULL,
    Codigo_Cliente INT NOT NULL,
    Importe FLOAT NOT NULL CHECK ( Importe > 0 ),
    PRIMARY KEY (Codigo),
    FOREIGN KEY (Codigo_Cliente) REFERENCES clientes_banco ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE pagos_cuotas
(
    Nro_Cuota INT NOT NULL,
    Codigo_Prestamo INT NOT NULL,
    Importe FLOAT NOT NULL CHECK (Importe > 0),
    Fecha DATE NOT NULL,
    FOREIGN KEY (Codigo_Prestamo) REFERENCES prestamos_banco ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE backup
(
    ENTRADA INT NOT NULL,
    DNI INT NOT NULL,
    NOMBRE TEXT NOT NULL,
    TELEFONO TEXT NOT NULL,
    CANT_PRESTAMOS INT NOT NULL,
    MONTO_PRESTAMOS FLOAT NOT NULL,
    MONTO_PAGO_CUOTAS FLOAT,
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
DROP SEQUENCE IF EXISTS backupID;
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
        NOMBRE  TEXT;
        TELEFONO    TEXT;
        CANT_PRESTAMOS  INT := 0;
        MONTO_PRESTAMOS FLOAT  := 0;
        MONTO_PAGO_CUOTAS   FLOAT  := 0;

        pago RECORD;
        prestamo RECORD;

        cPago CURSOR FOR
            SELECT pa.importe FROM pagos_cuotas pa WHERE pa.codigo_prestamo = prestamo.codigo;

        cPrestamo CURSOR FOR
            SELECT pr.importe, pr.codigo FROM prestamos_banco pr WHERE pr.codigo_cliente=OLD.Codigo;

        BEGIN
        ENTRADA=nextval('backupID');
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

                MONTO_PAGO_CUOTAS= MONTO_PAGO_CUOTAS+ pago.importe;

            END LOOP;
            CLOSE cPago;
        END LOOP;
        CLOSE cPrestamo;

        INSERT INTO backup values(ENTRADA, DNI, NOMBRE, TELEFONO, CANT_PRESTAMOS, MONTO_PRESTAMOS, MONTO_PAGO_CUOTAS, MONTO_PAGO_CUOTAS< MONTO_PRESTAMOS);
        RETURN OLD;
    END

$$ LANGUAGE plpgsql;

CREATE TRIGGER deleteTrigger
        BEFORE DELETE ON clientes_banco
    FOR EACH ROW
    EXECUTE PROCEDURE fillBackup();
END;