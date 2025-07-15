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