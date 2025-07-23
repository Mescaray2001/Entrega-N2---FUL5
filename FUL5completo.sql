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
  
  
  USE ful5;

INSERT INTO Cliente (nombre, apellido, email, telefono) VALUES
('Justo', 'Blanes', 'jblanes@gmail.com', '2214567870'),
('María', 'Gómez', 'maria.gomez@gmail.com', '2217894561'),
('Carlos', 'Lopez', 'carlos.lopez@hotmail.com', '2211234567'),
('Lucía', 'Martínez', 'lucia.martinez@gmail.com', '2219876543');

INSERT INTO Sede (nombre, direccion) VALUES
('Sede 1', 'Calle 123, La Plata'),
('Sede 2', 'Av. 44 y 7, La Plata');

INSERT INTO MetodoPago (descripcion) VALUES
('Transferencia Bancaria'),
('Efectivo'),
('Tarjeta de Crédito');

INSERT INTO Cancha (Cantidadjugadores, descripcion, id_sede) VALUES
(5, 'Techada con césped sintético', 1),
(7, 'Exterior con iluminación', 1),
(5, 'Techada con piso de madera', 2),
(11, 'Cancha profesional', 2);

INSERT INTO Reserva (id_cliente, id_cancha, id_metodopago, id_sede, fecha, hora, estado, monto) VALUES
(1, 1, 1, 1, '2025-06-20', '19:00:00', 'En espera', 20000.00),
(2, 2, 2, 1, '2025-07-01', '20:30:00', 'Confirmada', 25000.00),
(3, 3, 3, 2, '2025-07-05', '18:00:00', 'Cancelada', 18000.00),
(4, 4, 2, 2, '2025-07-10', '21:00:00', 'Confirmada', 30000.00);

SELECT * FROM Cliente;
SELECT * FROM Sede;
SELECT * FROM MetodoPago;
SELECT * FROM Cancha;
SELECT * FROM Reserva;

CREATE OR REPLACE VIEW vista_reservas_detalle AS
SELECT 
    r.id_reserva,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    s.nombre AS sede,
    ca.descripcion AS cancha,
    mp.descripcion AS metodo_pago,
    r.fecha,
    r.hora,
    r.estado,
    r.monto
FROM Reserva r
JOIN Cliente c ON r.id_cliente = c.id_cliente
JOIN Sede s ON r.id_sede = s.id_sede
JOIN Cancha ca ON r.id_cancha = ca.id_cancha
JOIN MetodoPago mp ON r.id_metodopago = mp.id_metodopago;


CREATE OR REPLACE VIEW vista_clientes_reservas AS
SELECT 
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    COUNT(r.id_reserva) AS cantidad_reservas
FROM Cliente c
LEFT JOIN Reserva r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente;

CREATE OR REPLACE VIEW vista_reservas_mensuales AS
SELECT 
    DATE_FORMAT(fecha, '%Y-%m') AS mes,
    COUNT(*) AS cantidad_reservas,
    SUM(monto) AS total_facturado
FROM Reserva
WHERE estado IN ('Confirmada', 'Finalizada')
GROUP BY mes
ORDER BY mes;

DELIMITER //
CREATE FUNCTION TotalGastadoPorCliente(cliente_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(monto) INTO total
    FROM Reserva
    WHERE id_cliente = cliente_id;
    RETURN IFNULL(total, 0);
END //
DELIMITER ;


DELIMITER //
CREATE FUNCTION EstaCanchaOcupada(cancha_id INT, fecha_ DATE, hora_ TIME)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE ocupado INT;
    SELECT COUNT(*) INTO ocupado
    FROM Reserva
    WHERE id_cancha = cancha_id AND fecha = fecha_ AND hora = hora_ AND estado IN ('En espera', 'Confirmada');
    RETURN ocupado > 0;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION EsClienteFrecuente(cliente_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE cantidad INT;
    SELECT COUNT(*) INTO cantidad
    FROM Reserva
    WHERE id_cliente = cliente_id AND estado = 'Confirmada';
    RETURN cantidad >= 3; 
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AgregarReserva(
    IN p_id_cliente INT,
    IN p_id_cancha INT,
    IN p_id_metodopago INT,
    IN p_id_sede INT,
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_estado VARCHAR(40),
    IN p_monto DECIMAL(10,2)
)
BEGIN
    DECLARE ya_ocupado BOOLEAN;
    SET ya_ocupado = EstaCanchaOcupada(p_id_cancha, p_fecha, p_hora);

    IF ya_ocupado THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cancha ya está reservada en ese horario.';
    ELSE
        INSERT INTO Reserva (id_cliente, id_cancha, id_metodopago, id_sede, fecha, hora, estado, monto)
        VALUES (p_id_cliente, p_id_cancha, p_id_metodopago, p_id_sede, p_fecha, p_hora, p_estado, p_monto);
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE HistorialReservasCliente(IN p_id_cliente INT)
BEGIN
    SELECT * FROM vista_reservas_detalle
    WHERE id_cliente = p_id_cliente;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CancelarReservasPasadas()
BEGIN
    UPDATE Reserva
    SET estado = 'Cancelada'
    WHERE fecha < CURDATE() AND estado = 'En espera';
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_insert_reserva
BEFORE INSERT ON Reserva
FOR EACH ROW
BEGIN
    IF NEW.estado IS NULL OR NEW.estado = '' THEN
        SET NEW.estado = 'En espera';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_delete_reserva
AFTER DELETE ON Reserva
FOR EACH ROW
BEGIN
    DECLARE msg VARCHAR(100);
    SET msg = CONCAT('Se eliminó la reserva ID: ', OLD.id_reserva);
    
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
END //
DELIMITER ;