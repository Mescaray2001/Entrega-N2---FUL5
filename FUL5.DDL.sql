CREATE SCHEMA ful5;
USE ful5;

CREATE TABLE Cliente(
    id_cliente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL
);

CREATE TABLE Sede(
    id_sede INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL
);

CREATE TABLE MetodoPago (
    id_metodopago INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(500)
);

CREATE TABLE Cancha (
    id_cancha INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Cantidadjugadores INT, 
    Descripcion VARCHAR(200),
    id_sede INT,
    FOREIGN KEY (id_sede) REFERENCES Sede(id_sede)
);

CREATE TABLE Reserva (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    id_cliente INT,
    id_cancha INT,
    id_metodopago INT,
    id_sede INT,
    fecha DATE,
    hora TIME,
    estado VARCHAR(40),
    monto DECIMAL(10,2), 
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_cancha) REFERENCES Cancha(id_cancha),
    FOREIGN KEY (id_metodopago) REFERENCES MetodoPago(id_metodopago),
    FOREIGN KEY (id_sede) REFERENCES Sede(id_sede)
);


INSERT INTO Cliente (nombre, apellido, email, telefono)
VALUES ('Juan', 'Pérez', 'juanp@gmail.com', '2214567890');

SELECT * FROM Cliente;

INSERT INTO Sede (nombre, direccion)
VALUES ('Sede 1', 'Calle 123, La Plata');

SELECT * FROM Sede;

INSERT INTO Cancha (Cantidadjugadores, descripcion, id_sede)
VALUES ('5', 'techada', 1);

SELECT * FROM Cancha;

INSERT INTO MetodoPago (descripcion)
VALUES ('Transferencia Bancaria');

SELECT * FROM MetodoPago;

INSERT INTO Reserva (id_cliente, id_cancha, id_metodopago, id_sede, fecha, hora, estado, monto)
VALUES (1, 1, 1, 1, '2025-06-20', '19:00:00', 'En espera', '20.000');

SELECT * FROM Reserva;

SELECT
  TABLE_NAME,
  COLUMN_NAME,
  CONSTRAINT_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME
FROM
  INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
  TABLE_SCHEMA = 'ful5';