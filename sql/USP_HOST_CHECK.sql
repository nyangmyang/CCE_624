DELIMITER //

CREATE PROCEDURE USP_HOST_CHECK(
    IN p_host_addr VARCHAR(75),
    IN p_host_port INT
)
BEGIN
    SELECT COUNT(*) as host_count
    FROM host 
    WHERE HOST_ADDR = p_host_addr AND HOST_PORT = p_host_port;
END //

DELIMITER ;
