DELIMITER //

CREATE PROCEDURE USP_HOST_I(
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
    
    INSERT INTO host (
        HOST_ADDR, 
        HOST_PORT, 
        HOST_USER, 
        HOST_SUPW, 
        HOST_SUPW_SALT, 
        HOST_IMP, 
        HOST_OS, 
        HOST_DESC,
        REGDATE
    )
    VALUES (
        p_host_addr, 
        p_host_port, 
        p_host_user, 
        p_host_supw, 
        p_host_supw_salt, 
        p_host_imp, 
        p_host_os, 
        p_host_desc,
        NOW()
    );
    
    SELECT LAST_INSERT_ID() as new_host_id;
    
    COMMIT;
END //

DELIMITER ;
