DELIMITER //

CREATE PROCEDURE USP_HOST_U(
    IN p_host_iden INT,
    IN p_host_addr VARCHAR(75),
    IN p_host_port INT,
    IN p_host_user VARCHAR(20),
    IN p_host_supw BLOB,
    IN p_host_supw_salt BINARY(32),
    IN p_host_imp INT,
    IN p_host_os VARCHAR(45),
    IN p_host_desc TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    UPDATE host SET
        HOST_ADDR = p_host_addr,
        HOST_PORT = p_host_port,
        HOST_USER = p_host_user,
        HOST_SUPW = p_host_supw,
        HOST_SUPW_SALT = p_host_supw_salt,
        HOST_IMP = p_host_imp,
        HOST_OS = p_host_os,
        HOST_DESC = p_host_desc,
	HOST_DFLAG = 'N'
    WHERE HOST_IDEN = p_host_iden;
    
    SELECT ROW_COUNT() as affected_rows;  -- Return number of affected rows
    
    COMMIT;
END //

DELIMITER ;
