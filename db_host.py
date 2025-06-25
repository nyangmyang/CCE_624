from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
import mysql.connector
import os

class HostManager:
    def __init__(self, db_config):
        """
        Initialize with database configuration
        db_config example: {
            'host': 'localhost',
            'user': 'db_user', 
            'password': 'db_password',
            'database': 'your_database'
        }
        """
        self.conn = mysql.connector.connect(**db_config)
        self.iterations = 100000  # PBKDF2 iterations
    
    def _derive_key(self, master_password, salt):
        """Derive encryption key from master password and salt"""
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,  # 32 bytes for AES-256
            salt=salt,
            iterations=self.iterations,
        )
        return kdf.derive(master_password.encode())
    
    def _encrypt_password(self, password, master_password):
        """Encrypt password using AES-GCM with master password and unique salt"""
        # Generate unique random salt for this password
        salt = os.urandom(32)  # 32 bytes salt
        
        # Derive encryption key using master password + salt
        encryption_key = self._derive_key(master_password, salt)
        
        # Generate random nonce for AES-GCM
        nonce = os.urandom(12)  # 12 bytes for GCM
        
        # Encrypt password
        aesgcm = AESGCM(encryption_key)
        ciphertext = aesgcm.encrypt(nonce, password.encode(), None)
        
        # Combine nonce + ciphertext for storage
        encrypted_data = nonce + ciphertext
        
        return salt, encrypted_data
    
    def host_exists(self, host_addr, host_port):
        """
        Check if a host with the given address and port already exists
        
        Parameters:
        - host_addr (str): Host address (VARCHAR(75))
        - host_port (int): Host port (INT)
        
        Returns:
        - bool: True if host exists, False otherwise
        """
        try:
            cursor = self.conn.cursor()
            
            # Call MySQL stored procedure to check host existence
            cursor.callproc('USP_HOST_CHECK', [host_addr, host_port])
            
            # Get the results from stored procedure
            results = []
            for result in cursor.stored_results():
                results.extend(result.fetchall())
            
            # The stored procedure should return 1 if exists, 0 if not
            if results and len(results) > 0:
                exists_count = results[0][0]  # First column of first result
                return exists_count > 0
            else:
                return False
                
        except mysql.connector.Error as err:
            print(f"Database error in host_exists: {err}")
            return False
        except Exception as e:
            print(f"Error checking host existence: {str(e)}")
            return False
        finally:
            cursor.close()

    def submit_host(self, host_addr, host_port, host_user, host_supw, host_imp, host_os, host_desc, master_password):
        """
        Submit a host entry (create new or update existing) with encrypted password
        
        Parameters:
        - host_addr (str): Host address (VARCHAR(75))
        - host_port (int): Host port (INT)
        - host_user (str): Host user (VARCHAR(20))
        - host_supw (str or None): Host super user password (plain text) - can be None
        - host_imp (int or None): Host importance (INT) - can be None, has default value
        - host_os (str): Host operating system (VARCHAR(45))
        - host_desc (str or None): Host description (TEXT) - can be None
        - master_password (str): Master password for encryption (ignored if host_supw is None)
        
        Returns:
        - tuple: (success: bool, message: str, host_id: int or None)
        """
        try:
            cursor = self.conn.cursor()
            
            # Step 1: Check if host exists using stored procedure
            is_update = self.host_exists(host_addr, host_port)
            
            # Step 2: Handle password encryption (or pass NULL if host_supw is None)
            if host_supw is None:
                # Pass NULL for both encrypted password and salt
                salt = None
                encrypted_password = None
            else:
                # Encrypt the password
                salt, encrypted_password = self._encrypt_password(host_supw, master_password)
            
            # Step 3: Call appropriate stored procedure based on existence check
            if is_update:
                # Get the existing host ID first
                check_query = """
                SELECT HOST_IDEN FROM host 
                WHERE HOST_ADDR = %s AND HOST_PORT = %s
                """
                cursor.execute(check_query, (host_addr, host_port))
                result = cursor.fetchone()
                existing_host_id = result[0] if result else None
                
                if existing_host_id:
                    # Update existing host
                    cursor.callproc('USP_HOST_U', [
                        existing_host_id,    # HOST_IDEN (for WHERE clause)
                        host_addr,           # HOST_ADDR
                        host_port,           # HOST_PORT
                        host_user,           # HOST_USER
                        encrypted_password,  # HOST_SUPW (encrypted or None)
                        salt,                # HOST_SUPW_SALT (or None)
                        host_imp,            # HOST_IMP (or None for default)
                        host_os,             # HOST_OS
                        host_desc            # HOST_DESC (or None)
                    ])
                    
                    # Commit the transaction
                    self.conn.commit()
                    
                    return True, f"Host {host_addr}:{host_port} updated successfully", existing_host_id
                else:
                    return False, f"Host {host_addr}:{host_port} exists but couldn't retrieve ID", None
                
            else:
                # Create new host
                cursor.callproc('USP_HOST_I', [
                    host_addr,           # HOST_ADDR
                    host_port,           # HOST_PORT
                    host_user,           # HOST_USER
                    encrypted_password,  # HOST_SUPW (encrypted or None)
                    salt,                # HOST_SUPW_SALT (or None)
                    host_imp,            # HOST_IMP (or None for default)
                    host_os,             # HOST_OS
                    host_desc            # HOST_DESC (or None)
                ])
                
                # Get the results from stored procedure
                # Assuming the stored procedure returns the new HOST_IDEN
                results = []
                for result in cursor.stored_results():
                    results.extend(result.fetchall())
                
                # Commit the transaction
                self.conn.commit()
                
                # Extract the new host ID (assuming stored procedure returns it)
                if results and len(results) > 0:
                    new_host_id = results[0][0]  # First column of first result
                    return True, f"Host {host_addr}:{host_port} created successfully with ID {new_host_id}", new_host_id
                else:
                    # If stored procedure doesn't return ID, we can query for it
                    cursor.execute("SELECT LAST_INSERT_ID()")
                    new_host_id = cursor.fetchone()[0]
                    return True, f"Host {host_addr}:{host_port} created successfully with ID {new_host_id}", new_host_id
                
        except mysql.connector.Error as err:
            # Rollback on error
            self.conn.rollback()
            return False, f"Database error: {err}", None
        except Exception as e:
            # Rollback on any other error
            self.conn.rollback()
            return False, f"Error submitting host: {str(e)}", None
        finally:
            cursor.close()

    def load_host(self, host_iden, master_password):
        """
        Load a specific host by HOST_IDEN and return all information with decrypted password
        
        Parameters:
        - host_iden (int): Host identifier
        - master_password (str): Master password for decryption
        
        Returns:
        - dict or None: Dictionary containing all host info with decrypted password, or None if not found
        """
        try:
            cursor = self.conn.cursor()
            
            # Call stored procedure to load specific host
            cursor.callproc('USP_HOST_LOAD', [host_iden])
            
            # Get the results from stored procedure
            results = []
            for result in cursor.stored_results():
                results.extend(result.fetchall())
            
            if not results or len(results) == 0:
                return None
            
            # Extract all fields from the first (and only) result
            result = results[0]
            host_iden, host_addr, host_port, host_user, encrypted_password, salt, host_imp, host_os, host_desc, regdate = result
            
            # Decrypt password if it exists
            decrypted_password = None
            if encrypted_password and salt:
                try:
                    encryption_key = self._derive_key(master_password, salt)
                    nonce = encrypted_password[:12]
                    ciphertext = encrypted_password[12:]
                    
                    aesgcm = AESGCM(encryption_key)
                    plaintext = aesgcm.decrypt(nonce, ciphertext, None)
                    decrypted_password = plaintext.decode()
                except Exception as e:
                    print(f"Warning: Failed to decrypt password for host {host_iden}: {e}")
                    decrypted_password = None
            
            # Return dictionary with all host information
            return {
                'HOST_IDEN': host_iden,
                'HOST_ADDR': host_addr,
                'HOST_PORT': host_port,
                'HOST_USER': host_user,
                'HOST_SUPW': decrypted_password,  # Decrypted password instead of encrypted blob
                'HOST_IMP': host_imp,
                'HOST_OS': host_os,
                'HOST_DESC': host_desc,
                'REGDATE': regdate
            }
            
        except Exception as e:
            print(f"Error loading host {host_iden}: {e}")
            return None
        finally:
            cursor.close()

    def list_hosts(self, master_password):
        """
        List all hosts with decrypted passwords
        
        Parameters:
        - master_password (str): Master password for decryption
        
        Returns:
        - list: List of dictionaries, each containing all host info with decrypted passwords
        """
        try:
            cursor = self.conn.cursor()
            
            # Call stored procedure to list all hosts
            cursor.callproc('USP_HOST_LIST', [])
            
            # Get the results from stored procedure
            results = []
            for result in cursor.stored_results():
                results.extend(result.fetchall())
            
            hosts_list = []
            
            for result in results:
                host_iden, host_addr, host_port, host_user, encrypted_password, salt, host_imp, host_os, host_desc, regdate = result
                
                # Decrypt password if it exists
                decrypted_password = None
                if encrypted_password and salt:
                    try:
                        encryption_key = self._derive_key(master_password, salt)
                        nonce = encrypted_password[:12]
                        ciphertext = encrypted_password[12:]
                        
                        aesgcm = AESGCM(encryption_key)
                        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
                        decrypted_password = plaintext.decode()
                    except Exception as e:
                        print(f"Warning: Failed to decrypt password for host {host_iden}: {e}")
                        decrypted_password = None
                
                # Add host dictionary to list
                host_dict = {
                    'HOST_IDEN': host_iden,
                    'HOST_ADDR': host_addr,
                    'HOST_PORT': host_port,
                    'HOST_USER': host_user,
                    'HOST_SUPW': decrypted_password,  # Decrypted password instead of encrypted blob
                    'HOST_IMP': host_imp,
                    'HOST_OS': host_os,
                    'HOST_DESC': host_desc,
                    'REGDATE': regdate
                }
                hosts_list.append(host_dict)
            
            return hosts_list
            
        except Exception as e:
            print(f"Error listing hosts: {e}")
            return []
        finally:
            cursor.close()

    def delete_host(self, host_iden):
        """
        Delete a host by setting DFLAG to 'Y' (soft delete)
        
        Parameters:
        - host_iden (int): Host identifier
        
        Returns:
        - tuple: (success: bool, message: str)
        """
        try:
            cursor = self.conn.cursor()
            
            # Call stored procedure to soft delete host
            cursor.callproc('USP_HOST_D', [host_iden])
            
            # Get the results from stored procedure
            results = []
            for result in cursor.stored_results():
                results.extend(result.fetchall())
            
            # Commit the transaction
            self.conn.commit()
            
            # Check if any rows were affected
            if results and len(results) > 0:
                affected_rows = results[0][0]  # First column of first result
                if affected_rows > 0:
                    return True, f"Host {host_iden} deleted successfully"
                else:
                    return False, f"Host {host_iden} not found or already deleted"
            else:
                return False, f"Unable to determine result for host {host_iden}"
                
        except mysql.connector.Error as err:
            # Rollback on error
            self.conn.rollback()
            return False, f"Database error: {err}"
        except Exception as e:
            # Rollback on any other error
            self.conn.rollback()
            return False, f"Error deleting host: {str(e)}"
        finally:
            cursor.close()

    def decrypt_host_password(self, host_iden, master_password):
        """
        Utility function to decrypt and retrieve host password
        
        Parameters:
        - host_iden (int): Host identifier
        - master_password (str): Master password used for encryption
        
        Returns:
        - str or None: Decrypted password or None if not found/error/null
        """
        try:
            cursor = self.conn.cursor()
            
            query = """
            SELECT HOST_SUPW, HOST_SUPW_SALT 
            FROM host 
            WHERE HOST_IDEN = %s
            """
            cursor.execute(query, (host_iden,))
            result = cursor.fetchone()
            
            if not result:
                return None
            
            encrypted_data, salt = result
            
            # Check if password is NULL (no password stored)
            if encrypted_data is None or salt is None:
                return None
            
            # Derive same encryption key
            encryption_key = self._derive_key(master_password, salt)
            
            # Extract nonce and ciphertext
            nonce = encrypted_data[:12]
            ciphertext = encrypted_data[12:]
            
            # Decrypt
            aesgcm = AESGCM(encryption_key)
            plaintext = aesgcm.decrypt(nonce, ciphertext, None)
            
            return plaintext.decode()
            
        except Exception as e:
            print(f"Error decrypting password: {e}")
            return None
        finally:
            cursor.close()


# MySQL Stored Procedures (you need to create these in your database)

# Stored procedure to check if host exists
USP_HOST_CHECK_sql = """
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
"""

# Stored procedure to create host
USP_HOST_I_sql = """
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
"""

# Stored procedure to update existing host
USP_HOST_U_sql = """
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
        HOST_DESC = p_host_desc
    WHERE HOST_IDEN = p_host_iden;
    
    SELECT ROW_COUNT() as affected_rows;  -- Return number of affected rows
    
    COMMIT;
END //

DELIMITER ;
"""

# Stored procedure to load specific host
USP_HOST_LOAD_sql = """
DELIMITER //

CREATE PROCEDURE USP_HOST_LOAD(
    IN p_host_iden INT
)
BEGIN
    SELECT HOST_IDEN, HOST_ADDR, HOST_PORT, HOST_USER, HOST_SUPW, 
           HOST_SUPW_SALT, HOST_IMP, HOST_OS, HOST_DESC, REGDATE
    FROM host 
    WHERE HOST_IDEN = p_host_iden;
END //

DELIMITER ;
"""

# Stored procedure to list all hosts
USP_HOST_LIST_sql = """
DELIMITER //

CREATE PROCEDURE USP_HOST_LIST()
BEGIN
    SELECT HOST_IDEN, HOST_ADDR, HOST_PORT, HOST_USER, HOST_SUPW, 
           HOST_SUPW_SALT, HOST_IMP, HOST_OS, HOST_DESC, REGDATE
    FROM host 
    WHERE DFLAG = 'N'
    ORDER BY HOST_IDEN;
END //

DELIMITER ;
"""

# Stored procedure to delete host (soft delete)
USP_HOST_D_sql = """
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
"""


def main():
    # Database configuration
    db_config = {
        'host': '192.168.203.32',
        'user': 'newuser',
        'password': 'easypw12',
        'database': 'itsec_01'
    }
    
    # Initialize host manager
    host_manager = HostManager(db_config)
    
    # Test host_exists function first
    print("=== Testing host_exists function ===")
    
    test_addresses = [
        ('192.168.1.100', 22),
        ('10.0.0.50', 22),
        ('172.16.0.10', 443),
        ('192.168.1.200', 80)  # This probably doesn't exist
    ]
    
    for addr, port in test_addresses:
        exists = host_manager.host_exists(addr, port)
        print(f"Host {addr}:{port} exists: {exists}")
    
    print("\n" + "="*50)
    
    # Test submitting hosts
    test_cases = [
        {
            'host_addr': '192.168.1.100',
            'host_port': 22,
            'host_user': 'admin',
            'host_supw': 'sudo_password_123',
            'host_imp': 1,
            'host_os': 'Ubuntu 22.04',
            'host_desc': 'Production web server',
            'master_password': 'my_master_password_2024'
        },
        {
            'host_addr': '10.0.0.50',
            'host_port': 22,
            'host_user': 'root',
            'host_supw': None,  # NULL password case
            'host_imp': None,   # Use default value
            'host_os': 'CentOS 8',
            'host_desc': None,  # NULL description
            'master_password': 'my_master_password_2024'  # Will be ignored
        },
        {
            'host_addr': '192.168.1.100',  # Same addr as first
            'host_port': 2222,             # Different port - should be allowed
            'host_user': 'deploy',
            'host_supw': 'different_password',
            'host_imp': 2,
            'host_os': 'Ubuntu 20.04',
            'host_desc': 'Staging server',
            'master_password': 'my_master_password_2024'
        },
        {
            'host_addr': '192.168.1.100',  # Same addr AND port as first
            'host_port': 22,               # Should update existing
            'host_user': 'admin',
            'host_supw': 'updated_password',
            'host_imp': 3,
            'host_os': 'Ubuntu 24.04',
            'host_desc': 'Updated production server',
            'master_password': 'my_master_password_2024'
        },
        {
            'host_addr': '172.16.0.10',
            'host_port': 443,
            'host_user': 'webapp',
            'host_supw': None,  # Another NULL password case
            'host_imp': 5,
            'host_os': 'Alpine Linux',
            'host_desc': 'Container host with no password',
            'master_password': 'any_password'  # Will be ignored
        }
    ]
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n--- Test Case {i} ---")
        
        # First check if host exists using new function
        exists_before = host_manager.host_exists(test_case['host_addr'], test_case['host_port'])
        print(f"Host {test_case['host_addr']}:{test_case['host_port']} exists before operation: {exists_before}")
        
        print(f"Submitting host: {test_case['host_addr']}:{test_case['host_port']}")
        print(f"User: {test_case['host_user']}")
        print(f"Password: {'NULL' if test_case['host_supw'] is None else 'PROVIDED'}")
        print(f"Importance: {test_case['host_imp']}")
        print(f"OS: {test_case['host_os']}")
        print(f"Description: {'NULL' if test_case['host_desc'] is None else test_case['host_desc']}")
        
        success, message, host_id = host_manager.submit_host(
            test_case['host_addr'],
            test_case['host_port'],
            test_case['host_user'],
            test_case['host_supw'],
            test_case['host_imp'],
            test_case['host_os'],
            test_case['host_desc'],
            test_case['master_password']
        )
        
        print(f"Result: {message}")
        
        # Check if host exists after operation
        exists_after = host_manager.host_exists(test_case['host_addr'], test_case['host_port'])
        print(f"Host exists after operation: {exists_after}")
        
        if success and host_id:
            print(f"Host ID: {host_id}")
            # Determine action based on exists_before flag
            action = "UPDATED" if exists_before else "CREATED"
            print(f"Action performed: {action}")
            
            # Test decryption only if password was provided
            if test_case['host_supw'] is not None:
                decrypted_pw = host_manager.decrypt_host_password(
                    host_id, 
                    test_case['master_password']
                )
                print(f"Decrypted password: {decrypted_pw}")
                print(f"Original password: {test_case['host_supw']}")
                print(f"Passwords match: {decrypted_pw == test_case['host_supw']}")
            else:
                decrypted_pw = host_manager.decrypt_host_password(
                    host_id, 
                    test_case['master_password']
                )
                print(f"Decrypted password: {decrypted_pw} (should be None)")
                print(f"Password correctly stored as NULL: {decrypted_pw is None}")


# Example usage of new functions
def example_load_and_list_hosts():
    """Example demonstrating load_host and list_hosts functions"""
    print("=== Load and List Hosts Example ===")
    
    db_config = {
        'host': '192.168.203.32',
        'user': 'newuser',
        'password': 'easypw12',
        'database': 'itsec_01'
    }
    
    host_manager = HostManager(db_config)
    master_password = 'my_master_password_2024'
    
    # Example 1: Load specific host
    print("\n--- Load Specific Host (ID: 1) ---")
    host_info = host_manager.load_host(1, master_password)
    
    if host_info:
        print("Host Information:")
        for key, value in host_info.items():
            if key == 'HOST_SUPW' and value:
                print(f"  {key}: {'*' * len(value)} (decrypted)")
            else:
                print(f"  {key}: {value}")
    else:
        print("Host not found or error occurred")
    
    # Example 2: List all hosts
    print("\n--- List All Hosts ---")
    all_hosts = host_manager.list_hosts(master_password)
    
    if all_hosts:
        print(f"Found {len(all_hosts)} host(s):")
        for i, host in enumerate(all_hosts, 1):
            print(f"\nHost {i}:")
            print(f"  ID: {host['HOST_IDEN']}")
            print(f"  Address: {host['HOST_ADDR']}:{host['HOST_PORT']}")
            print(f"  User: {host['HOST_USER']}")
            print(f"  Password: {'SET' if host['HOST_SUPW'] else 'NULL'}")
            print(f"  Importance: {host['HOST_IMP']}")
            print(f"  OS: {host['HOST_OS']}")
            print(f"  Description: {host['HOST_DESC'] or 'None'}")
            print(f"  Registered: {host['REGDATE']}")
    else:
        print("No hosts found or error occurred")
    
    # Example 3: Test with non-existent host
    print("\n--- Test Non-existent Host ---")
    non_existent = host_manager.load_host(9999, master_password)
    print(f"Non-existent host result: {non_existent}")
    
    # Example 4: Test delete host functionality
    print("\n--- Test Delete Host ---")
    if all_hosts and len(all_hosts) > 0:
        host_to_delete = all_hosts[0]['HOST_IDEN']
        print(f"Attempting to delete host ID: {host_to_delete}")
        
        success, message = host_manager.delete_host(host_to_delete)
        print(f"Delete result: {message}")
        
        if success:
            # Check if host is still in the list after deletion
            updated_hosts = host_manager.list_hosts(master_password)
            deleted_host_still_visible = any(h['HOST_IDEN'] == host_to_delete for h in updated_hosts)
            print(f"Host still visible in list after deletion: {deleted_host_still_visible}")
            
            # Try to load the deleted host directly
            deleted_host_info = host_manager.load_host(host_to_delete, master_password)
            print(f"Can still load deleted host directly: {deleted_host_info is not None}")
    else:
        print("No hosts available to test deletion")
    
    return host_manager


# Example usage of host_exists function standalone
def example_host_exists():
    """Example demonstrating the host_exists function"""
    print("=== Host Exists Function Example ===")

    db_config = {
        'host': '192.168.203.32',
        'user': 'newuser',
        'password': 'easypw12',
        'database': 'itsec_01'
    }
    
    host_manager = HostManager(db_config)
    
    # Check multiple hosts
    hosts_to_check = [
        ('192.168.1.100', 22),
        ('10.0.0.50', 80),
        ('172.16.1.1', 443),
        ('127.0.0.1', 3306),
        ('nonexistent.server.com', 22)
    ]
    
    for addr, port in hosts_to_check:
        exists = host_manager.host_exists(addr, port)
        status = "EXISTS" if exists else "NOT FOUND"
        print(f"Host {addr}:{port} - {status}")
    
    return host_manager


if __name__ == "__main__":
    main()
    
    # Uncomment below to test host_exists function standalone
    # print("\n" + "="*50)
    # example_host_exists()
    
    # Uncomment below to test load_host and list_hosts functions
    # print("\n" + "="*50)
    # example_load_and_list_hosts()
