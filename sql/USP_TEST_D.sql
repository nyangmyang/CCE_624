DELIMITER $$
CREATE PROCEDURE USP_TEST_D(
    IN p_TEST_IDEN INT
)
BEGIN
    UPDATE test 
    SET DFLAG = 'Y' 
    WHERE TEST_IDEN = p_TEST_IDEN;
    
    -- Return number of affected rows
    SELECT ROW_COUNT() AS affected_rows;
END$$
DELIMITER ;
