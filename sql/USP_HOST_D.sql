DELIMITER //

CREATE PROCEDURE USP_HOST_D(
    IN p_host_iden INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    UPDATE host 
    SET DFLAG = 'Y'
    WHERE HOST_IDEN = p_host_iden AND DFLAG = 'N';
    
    SELECT ROW_COUNT() as affected_rows;  -- Return number of affected rows
    
    COMMIT;
END //

DELIMITER ;
