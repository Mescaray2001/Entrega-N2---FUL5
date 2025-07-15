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