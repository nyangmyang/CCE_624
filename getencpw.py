from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import hashlib
import os
import random
import json

class PasswordBlobManager:
    def __init__(self):
        self.blob_size = 1024 * 1024  # 1MB
        
    def _prepare_key(self, key_string):
        """Convert key string to 32-byte AES key"""
        return hashlib.sha256(key_string.encode('utf-8')).digest()
    
    def _encrypt_password(self, password, key):
        """Encrypt password using Direct AES-GCM"""
        encryption_key = self._prepare_key(key)
        nonce = os.urandom(12)  # 12-byte nonce for GCM
        
        aesgcm = AESGCM(encryption_key)
        ciphertext = aesgcm.encrypt(nonce, password.encode('utf-8'), None)
        
        # Return nonce + ciphertext as binary blob
        return nonce + ciphertext
    
    def _decrypt_password(self, encrypted_blob, key):
        """Decrypt password using Direct AES-GCM"""
        encryption_key = self._prepare_key(key)
        
        nonce = encrypted_blob[:12]
        ciphertext = encrypted_blob[12:]
        
        aesgcm = AESGCM(encryption_key)
        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
        
        return plaintext.decode('utf-8')
    
    def _get_random_non_overlapping_positions(self, encrypted_blobs):
        """Generate random start positions that don't overlap"""
        positions = []
        max_attempts = 1000
        
        for encrypted_blob in encrypted_blobs:
            blob_length = len(encrypted_blob)
            max_start = self.blob_size - blob_length
            
            for _ in range(max_attempts):
                start_pos = random.randint(0, max_start)
                end_pos = start_pos + blob_length
                
                # Check if this position overlaps with existing positions
                overlaps = False
                for existing_start, existing_end in positions:
                    if not (end_pos <= existing_start or start_pos >= existing_end):
                        overlaps = True
                        break
                
                if not overlaps:
                    positions.append((start_pos, end_pos))
                    break
            else:
                raise Exception(f"Could not find non-overlapping position for blob {len(positions) + 1}")
        
        return positions
    
    def create_password_blob(self):
        """Interactive function to create 1MB blob with encrypted passwords"""
        print("=== Password Blob Creator ===")
        
        # Step 1: Ask how many passwords
        while True:
            try:
                num_passwords = int(input("How many passwords do you want to save? "))
                if num_passwords <= 0:
                    print("Please enter a positive number.")
                    continue
                break
            except ValueError:
                print("Please enter a valid number.")
        
        print(f"\nYou will save {num_passwords} password(s).")
        
        # Step 2: Collect passwords and keys
        passwords_data = []
        encrypted_blobs = []
        
        for i in range(num_passwords):
            print(f"\n--- Password {i + 1} ---")
            password = input(f"Enter password {i + 1}: ")
            key = input(f"Enter key for password {i + 1}: ")
            
            # Step 3: Encrypt each password
            encrypted_blob = self._encrypt_password(password, key)
            
            passwords_data.append({
                'password': password,
                'key': key,
                'encrypted_length': len(encrypted_blob)
            })
            encrypted_blobs.append(encrypted_blob)
            
            print(f"Password {i + 1} encrypted successfully (size: {len(encrypted_blob)} bytes)")
        
        # Step 4: Generate random positions and create 1MB blob
        print("\nGenerating random positions for encrypted passwords...")
        positions = self._get_random_non_overlapping_positions(encrypted_blobs)
        
        # Create 1MB blob filled with random data
        blob = bytearray(os.urandom(self.blob_size))
        
        # Insert encrypted passwords at random positions
        for i, (encrypted_blob, (start_pos, end_pos)) in enumerate(zip(encrypted_blobs, positions)):
            blob[start_pos:end_pos] = encrypted_blob
            passwords_data[i]['start_position'] = start_pos
            passwords_data[i]['end_position'] = end_pos
        
        # Save blob to file
        blob_filename = "password_blob.bin"
        with open(blob_filename, 'wb') as f:
            f.write(blob)
        
        # Save metadata to JSON file
        metadata_filename = "password_metadata.json"
        metadata = {
            'blob_size': self.blob_size,
            'blob_filename': blob_filename,
            'passwords': [
                {
                    'index': i + 1,
                    'start_position': data['start_position'],
                    'end_position': data['end_position'],
                    'encrypted_length': data['encrypted_length']
                }
                for i, data in enumerate(passwords_data)
            ]
        }
        
        with open(metadata_filename, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        # Step 5: Display positions
        print(f"\n=== Blob Created Successfully ===")
        print(f"Blob file: {blob_filename} (size: {self.blob_size:,} bytes)")
        print(f"Metadata file: {metadata_filename}")
        print("\nPassword locations in blob:")
        
        for i, data in enumerate(passwords_data):
            print(f"Password {i + 1}:")
            print(f"  Start position: {data['start_position']:,}")
            print(f"  End position: {data['end_position']:,}")
            print(f"  Length: {data['encrypted_length']} bytes")
            print(f"  Key: {data['key']}")
        
        return blob_filename, metadata_filename, passwords_data
    
    def decrypt_password_from_blob(self, blob_filename, start_pos, end_pos, key):
        """Decrypt a specific password from the blob file"""
        with open(blob_filename, 'rb') as f:
            f.seek(start_pos)
            encrypted_blob = f.read(end_pos - start_pos)
        
        return self._decrypt_password(encrypted_blob, key)
    
    def decrypt_all_passwords_from_metadata(self, blob_filename, metadata_filename, keys):
        """Decrypt all passwords using metadata file and provided keys"""
        with open(metadata_filename, 'r') as f:
            metadata = json.load(f)
        
        decrypted_passwords = []
        
        for i, password_info in enumerate(metadata['passwords']):
            if i < len(keys):
                try:
                    decrypted = self.decrypt_password_from_blob(
                        blob_filename,
                        password_info['start_position'],
                        password_info['end_position'],
                        keys[i]
                    )
                    decrypted_passwords.append({
                        'index': password_info['index'],
                        'password': decrypted,
                        'key': keys[i]
                    })
                    print(f"Password {password_info['index']}: {decrypted}")
                except Exception as e:
                    print(f"Failed to decrypt password {password_info['index']}: {e}")
            else:
                print(f"No key provided for password {password_info['index']}")
        
        return decrypted_passwords


def main():
    """Example main function demonstrating blob creation and decryption"""
    manager = PasswordBlobManager()
    
    print("Choose an option:")
    print("1. Create new password blob")
    print("2. Decrypt passwords from existing blob")
    
    choice = input("Enter choice (1 or 2): ")
    
    if choice == "1":
        # Create password blob
        blob_filename, metadata_filename, passwords_data = manager.create_password_blob()
        
        print(f"\n=== Creation Complete ===")
        print("Files created:")
        print(f"- {blob_filename}")
        print(f"- {metadata_filename}")
        
    elif choice == "2":
        # Decrypt existing blob
        blob_filename = input("Enter blob filename (default: password_blob.bin): ") or "password_blob.bin"
        metadata_filename = input("Enter metadata filename (default: password_metadata.json): ") or "password_metadata.json"
        
        try:
            with open(metadata_filename, 'r') as f:
                metadata = json.load(f)
            
            num_passwords = len(metadata['passwords'])
            print(f"\nFound {num_passwords} encrypted password(s) in blob.")
            
            keys = []
            for i in range(num_passwords):
                key = input(f"Enter key for password {i + 1}: ")
                keys.append(key)
            
            print("\n=== Decrypting Passwords ===")
            decrypted = manager.decrypt_all_passwords_from_metadata(blob_filename, metadata_filename, keys)
            
            print(f"\nSuccessfully decrypted {len(decrypted)} password(s).")
            
        except FileNotFoundError as e:
            print(f"File not found: {e}")
        except Exception as e:
            print(f"Error: {e}")
    
    else:
        print("Invalid choice.")


# Example with hardcoded 2 password pairs for testing
def example_with_two_passwords():
    """Example specifically with 2 password and key pairs"""
    print("=== Example with 2 Passwords ===")
    
    manager = PasswordBlobManager()
    
    # Simulate user input for 2 passwords
    test_data = [
        {"password": "whereisthis", "key": "whatisthis"},
        {"password": "admin123", "key": "serverkey"}
    ]
    
    print("Creating blob with 2 test passwords...")
    
    # Encrypt passwords
    encrypted_blobs = []
    for data in test_data:
        encrypted_blob = manager._encrypt_password(data["password"], data["key"])
        encrypted_blobs.append(encrypted_blob)
        print(f"Encrypted '{data['password']}' with key '{data['key']}' (size: {len(encrypted_blob)} bytes)")
    
    # Generate positions
    positions = manager._get_random_non_overlapping_positions(encrypted_blobs)
    
    # Create 1MB blob
    blob = bytearray(os.urandom(manager.blob_size))
    
    # Insert encrypted passwords
    for i, (encrypted_blob, (start_pos, end_pos)) in enumerate(zip(encrypted_blobs, positions)):
        blob[start_pos:end_pos] = encrypted_blob
        test_data[i]['start_position'] = start_pos
        test_data[i]['end_position'] = end_pos
    
    # Save blob
    blob_filename = "example_blob.bin"
    with open(blob_filename, 'wb') as f:
        f.write(blob)
    
    print(f"\nBlob saved to {blob_filename}")
    print("Password locations:")
    for i, data in enumerate(test_data):
        print(f"Password {i + 1}: '{data['password']}'")
        print(f"  Start: {data['start_position']:,}, End: {data['end_position']:,}")
        print(f"  Key: '{data['key']}'")
    
    # Test decryption
    print("\n=== Testing Decryption ===")
    for i, data in enumerate(test_data):
        decrypted = manager.decrypt_password_from_blob(
            blob_filename,
            data['start_position'],
            data['end_position'],
            data['key']
        )
        print(f"Password {i + 1} decrypted: '{decrypted}' (Original: '{data['password']}')")
        print(f"Match: {decrypted == data['password']}")


def get2staticpw():
    """Example with static keys and positions - returns two decoded passwords"""
    print("=== Static Decode Example ===")
    
    # Static variables (pretend these are correct)
    blob_filename = "blob/blobber.bin"
    
    # Password 1 static data
    key1 = "equationselfdepart"
    start_pos1 = 170643
    end_pos1 = 170685
    
    # Password 2 static data
    key2 = "assaultaccountantmaster"
    start_pos2 = 535304
    end_pos2 = 535347
    
    manager = PasswordBlobManager()
    
    print(f"Decoding from blob file: {blob_filename}")
    print(f"Password 1: positions {start_pos1:,} to {end_pos1:,} with key '{key1}'")
    print(f"Password 2: positions {start_pos2:,} to {end_pos2:,} with key '{key2}'")
    
    try:
        # Decode password 1
        password1 = manager.decrypt_password_from_blob(blob_filename, start_pos1, end_pos1, key1)
        print(f"Decoded Password 1: '{password1}'")
        
        # Decode password 2
        password2 = manager.decrypt_password_from_blob(blob_filename, start_pos2, end_pos2, key2)
        print(f"Decoded Password 2: '{password2}'")
        
        # Return both passwords
        return password1, password2
        
    except Exception as e:
        print(f"Decoding failed: {e}")
        return None, None


if __name__ == "__main__":
    # Run the main interactive function
    # main()
    
    # Uncomment below to run the 2-password example
    # print("\n" + "="*50)
    # example_with_two_passwords()
    
    # Uncomment below to run the static decode example
    # print("\n" + "="*50)
    # password1, password2 = get2staticpw()
    # if password1 and password2:
    #     print(f"Returned passwords: '{password1}' and '{password2}'")

    get2staticpw()
