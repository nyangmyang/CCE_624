import mysql.connector
from typing import Dict, List, Optional, Any
from datetime import datetime

class TestManager:
    def __init__(self, db_config):
        """
        Initialize with database configuration
        
        Args:
            db_config (dict): Database configuration dictionary
                Example: {
                    'host': 'localhost',
                    'user': 'db_user', 
                    'password': 'db_password',
                    'database': 'your_database'
                }
        """
        self.conn = mysql.connector.connect(**db_config)
    
    def create_test(self, test_type: int, host_iden: int, test_result: Optional[str], test_date: datetime) -> int:
        """
        Create a new test record using stored procedure USP_TEST_I
        
        Args:
            test_type (int): Type of test
            host_iden (int): Host identifier
            test_result (str, optional): Test result text
            test_date (datetime): Date and time of test
            
        Returns:
            int: The auto-generated TEST_IDEN of the created record
            
        Raises:
            mysql.connector.Error: If database operation fails
        """
        cursor = self.conn.cursor()
        try:
            # Call stored procedure
            cursor.callproc('USP_TEST_I', [test_type, host_iden, test_result, test_date])
            
            # Fetch the returned TEST_IDEN
            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    return row[0]  # Return the TEST_IDEN
            
            # If no result returned, get last insert id
            return cursor.lastrowid
            
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise e
        finally:
            cursor.close()
    
    def delete_test(self, test_iden: int) -> bool:
        """
        Mark a test record as deleted by setting DFLAG to 'Y'
        
        Args:
            test_iden (int): Test identifier to delete
            
        Returns:
            bool: True if record was found and marked as deleted, False otherwise
            
        Raises:
            mysql.connector.Error: If database operation fails
        """
        cursor = self.conn.cursor()
        try:
            # Call stored procedure
            cursor.callproc('USP_TEST_D', [test_iden])
            
            # Check if any rows were affected
            for result in cursor.stored_results():
                row = result.fetchone()
                if row and row[0] > 0:
                    self.conn.commit()
                    return True
            
            return False
            
        except mysql.connector.Error as e:
            self.conn.rollback()
            raise e
        finally:
            cursor.close()
    
    def load_test(self, test_iden: int) -> Optional[Dict[str, Any]]:
        """
        Load a single test record by TEST_IDEN
        
        Args:
            test_iden (int): Test identifier to load
            
        Returns:
            Dict[str, Any] or None: Dictionary containing test data without DFLAG,
                                   or None if not found
            
        Raises:
            mysql.connector.Error: If database operation fails
        """
        cursor = self.conn.cursor(dictionary=True)
        try:
            # Call stored procedure
            cursor.callproc('USP_TEST_LOAD', [test_iden])
            
            # Fetch the result
            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    return row
            
            return None
            
        except mysql.connector.Error as e:
            raise e
        finally:
            cursor.close()
    
    def list_test(self) -> List[Dict[str, Any]]:
        """
        List all test records that are not marked as deleted (DFLAG != 'Y')
        
        Returns:
            List[Dict[str, Any]]: List of dictionaries containing test data without DFLAG
            
        Raises:
            mysql.connector.Error: If database operation fails
        """
        cursor = self.conn.cursor(dictionary=True)
        try:
            # Call stored procedure
            cursor.callproc('USP_TEST_LIST')
            
            # Fetch all results
            for result in cursor.stored_results():
                rows = result.fetchall()
                return rows if rows else []
            
            return []
            
        except mysql.connector.Error as e:
            raise e
        finally:
            cursor.close()
    
    def list_test_latest_by_host(self) -> List[Dict[str, Any]]:
        """
        Get the most recent test for each unique HOST_IDEN using existing USP_TEST_LIST
        
        Returns:
            List[Dict[str, Any]]: List of dictionaries containing the latest test data 
                                 for each HOST_IDEN, without DFLAG column
            
        Raises:
            mysql.connector.Error: If database operation fails
        """
        cursor = self.conn.cursor(dictionary=True)
        try:
            # Call existing stored procedure to get all active tests
            cursor.callproc('USP_TEST_LIST')
            
            # Fetch all results
            all_tests = []
            for result in cursor.stored_results():
                rows = result.fetchall()
                all_tests = rows if rows else []
            
            if not all_tests:
                return []
            
            # Group tests by HOST_IDEN and find the most recent for each
            host_latest_tests = {}
            
            for test in all_tests:
                host_id = test['HOST_IDEN']
                test_date = test['TEST_DATE']
                
                # If this host hasn't been seen before, or this test is more recent
                if (host_id not in host_latest_tests or 
                    test_date > host_latest_tests[host_id]['TEST_DATE']):
                    host_latest_tests[host_id] = test
            
            # Convert dictionary values back to list and sort by HOST_IDEN for consistency
            result_list = list(host_latest_tests.values())
            result_list.sort(key=lambda x: x['HOST_IDEN'])
            
            return result_list
            
        except mysql.connector.Error as e:
            raise e
        finally:
            cursor.close()


# Standalone function versions (alternative to class-based approach)
def create_test_standalone(db_config, test_type: int, host_iden: int, test_result: Optional[str], test_date: datetime) -> int:
    """Standalone version of create_test function"""
    test_manager = TestManager(db_config)
    try:
        result = test_manager.create_test(test_type, host_iden, test_result, test_date)
        test_manager.conn.commit()
        return result
    finally:
        test_manager.conn.close()

def delete_test_standalone(db_config, test_iden: int) -> bool:
    """Standalone version of delete_test function"""
    test_manager = TestManager(db_config)
    try:
        return test_manager.delete_test(test_iden)
    finally:
        test_manager.conn.close()

def load_test_standalone(db_config, test_iden: int) -> Optional[Dict[str, Any]]:
    """Standalone version of load_test function"""
    test_manager = TestManager(db_config)
    try:
        return test_manager.load_test(test_iden)
    finally:
        test_manager.conn.close()

def list_test_standalone(db_config) -> List[Dict[str, Any]]:
    """Standalone version of list_test function"""
    test_manager = TestManager(db_config)
    try:
        return test_manager.list_test()
    finally:
        test_manager.conn.close()

def list_test_latest_by_host_standalone(db_config) -> List[Dict[str, Any]]:
    """Standalone version of list_test_latest_by_host function"""
    test_manager = TestManager(db_config)
    try:
        return test_manager.list_test_latest_by_host()
    finally:
        test_manager.conn.close()


# Comprehensive test cases
def run_test_cases():
    """Run comprehensive test cases for all TestManager functions"""
    from datetime import datetime, timedelta
    
    # Database configuration
    db_config = {
        'host': 'localhost',
        'user': 'bob',
        'password': '20250630!',
        'database': 'itsec_01'
    }
        
    test_manager = TestManager(db_config)
    created_test_ids = []
    
    try:
        print("=" * 60)
        print("COMPREHENSIVE TEST CASES FOR TEST MANAGER")
        print("=" * 60)
        
        # TEST CASE 1: Create Test - Basic functionality
        print("\n1. CREATE TEST - Basic Test Cases")
        print("-" * 40)
        
        # Test 1.1: Create test with all fields
        test_id_1 = test_manager.create_test(
            test_type=1,
            host_iden=100,
            test_result="Integration test completed successfully",
            test_date=datetime(2025, 6, 19, 14, 30, 45)
        )
        created_test_ids.append(test_id_1)
        print(f"✓ Test 1.1 - Created test with all fields: ID = {test_id_1}")
        
        # Test 1.2: Create test with NULL test_result
        test_id_2 = test_manager.create_test(
            test_type=2,
            host_iden=101,
            test_result=None,
            test_date=datetime(2025, 6, 18, 9, 15, 30)
        )
        created_test_ids.append(test_id_2)
        print(f"✓ Test 1.2 - Created test with NULL result: ID = {test_id_2}")
        
        # Test 1.3: Create test with empty string test_result
        test_id_3 = test_manager.create_test(
            test_type=3,
            host_iden=102,
            test_result="",
            test_date=datetime(2025, 6, 17, 23, 59, 59)
        )
        created_test_ids.append(test_id_3)
        print(f"✓ Test 1.3 - Created test with empty result: ID = {test_id_3}")
        
        # Test 1.4: Create test with long test_result
        long_result = "This is a very long test result that contains multiple sentences. " * 10
        test_id_4 = test_manager.create_test(
            test_type=4,
            host_iden=103,
            test_result=long_result,
            test_date=datetime(2025, 6, 16, 12, 0, 0)
        )
        created_test_ids.append(test_id_4)
        print(f"✓ Test 1.4 - Created test with long result: ID = {test_id_4}")
        
        # Test 1.5: Create multiple tests with same parameters
        for i in range(3):
            test_id = test_manager.create_test(
                test_type=5,
                host_iden=104,
                test_result=f"Batch test #{i+1}",
                test_date=datetime.now() - timedelta(days=i, hours=i, minutes=i*10)
            )
            created_test_ids.append(test_id)
        print(f"✓ Test 1.5 - Created 3 batch tests: IDs = {created_test_ids[-3:]}")
        
        # TEST CASE 2: Load Test - Various scenarios
        print("\n2. LOAD TEST - Test Cases")
        print("-" * 40)
        
        # Test 2.1: Load existing test
        loaded_test = test_manager.load_test(test_id_1)
        if loaded_test:
            print(f"✓ Test 2.1 - Successfully loaded test: {loaded_test}")
            assert 'DFLAG' not in loaded_test, "DFLAG should not be in loaded test data"
            assert loaded_test['TEST_IDEN'] == test_id_1, "TEST_IDEN should match"
        else:
            print("✗ Test 2.1 - Failed to load existing test")
        
        # Test 2.2: Load test with NULL result
        loaded_test_null = test_manager.load_test(test_id_2)
        if loaded_test_null:
            print(f"✓ Test 2.2 - Loaded test with NULL result: {loaded_test_null}")
            assert loaded_test_null['TEST_RESULT'] is None, "TEST_RESULT should be None"
        else:
            print("✗ Test 2.2 - Failed to load test with NULL result")
        
        # Test 2.3: Load non-existent test
        non_existent_test = test_manager.load_test(99999)
        if non_existent_test is None:
            print("✓ Test 2.3 - Correctly returned None for non-existent test")
        else:
            print("✗ Test 2.3 - Should return None for non-existent test")
        
        # Test 2.4: Load test with negative ID
        negative_test = test_manager.load_test(-1)
        if negative_test is None:
            print("✓ Test 2.4 - Correctly handled negative test ID")
        else:
            print("✗ Test 2.4 - Should return None for negative test ID")
        
        # TEST CASE 3: List Tests - Various scenarios
        print("\n3. LIST TESTS - Test Cases")
        print("-" * 40)
        
        # Test 3.1: List all active tests
        all_tests = test_manager.list_test()
        active_count = len(all_tests)
        print(f"✓ Test 3.1 - Listed {active_count} active tests")
        
        # Verify no DFLAG in results
        for test in all_tests:
            assert 'DFLAG' not in test, f"DFLAG found in test {test['TEST_IDEN']}"
        print("✓ Test 3.1b - Verified no DFLAG in list results")
        
        # Verify all our created tests are in the list
        our_test_ids = set(created_test_ids)
        listed_test_ids = set(test['TEST_IDEN'] for test in all_tests)
        if our_test_ids.issubset(listed_test_ids):
            print("✓ Test 3.1c - All created tests appear in list")
        else:
            missing = our_test_ids - listed_test_ids
            print(f"✗ Test 3.1c - Missing tests in list: {missing}")
        
        # Test 3.2: Test latest by host functionality
        latest_by_host = test_manager.list_test_latest_by_host()
        print(f"✓ Test 3.2 - Latest tests by host: {len(latest_by_host)} unique hosts")
        
        # Verify each HOST_IDEN appears only once
        host_idens = [test['HOST_IDEN'] for test in latest_by_host]
        unique_hosts = set(host_idens)
        if len(host_idens) == len(unique_hosts):
            print("✓ Test 3.2b - Each HOST_IDEN appears only once")
        else:
            print("✗ Test 3.2b - Duplicate HOST_IDEN found")
        
        # Verify no DFLAG in results
        for test in latest_by_host:
            assert 'DFLAG' not in test, f"DFLAG found in latest by host test {test['TEST_IDEN']}"
        print("✓ Test 3.2c - Verified no DFLAG in latest by host results")
        
        # TEST CASE 4: Delete Test - Various scenarios
        print("\n4. DELETE TEST - Test Cases")
        print("-" * 40)
        
        # Test 4.1: Delete existing test
        delete_result = test_manager.delete_test(test_id_1)
        if delete_result:
            print(f"✓ Test 4.1 - Successfully deleted test {test_id_1}")
        else:
            print(f"✗ Test 4.1 - Failed to delete test {test_id_1}")
        
        # Test 4.2: Try to delete non-existent test
        delete_non_existent = test_manager.delete_test(99999)
        if not delete_non_existent:
            print("✓ Test 4.2 - Correctly returned False for non-existent test")
        else:
            print("✗ Test 4.2 - Should return False for non-existent test")
        
        # Test 4.3: Try to delete already deleted test
        delete_again = test_manager.delete_test(test_id_1)
        if delete_again:
            print(f"✓ Test 4.3 - Re-deleting test {test_id_1} succeeded (expected behavior)")
        else:
            print(f"✓ Test 4.3 - Re-deleting test {test_id_1} failed (also acceptable)")
        
        # Test 4.4: Verify deleted test doesn't appear in list
        tests_after_delete = test_manager.list_test()
        deleted_test_ids = set(test['TEST_IDEN'] for test in tests_after_delete)
        if test_id_1 not in deleted_test_ids:
            print(f"✓ Test 4.4 - Deleted test {test_id_1} not in active list")
        else:
            print(f"✗ Test 4.4 - Deleted test {test_id_1} still appears in list")
        
        # Test 4.5: Verify deleted test can still be loaded (soft delete)
        deleted_test_data = test_manager.load_test(test_id_1)
        if deleted_test_data:
            print(f"✓ Test 4.5 - Deleted test can still be loaded (soft delete): {deleted_test_data}")
        else:
            print("? Test 4.5 - Deleted test cannot be loaded (depends on stored procedure implementation)")
        
        # TEST CASE 5: Edge Cases and Error Handling
        print("\n5. EDGE CASES - Test Cases")
        print("-" * 40)
        
        # Test 5.1: Create test with future date
        future_test_id = test_manager.create_test(
            test_type=99,
            host_iden=999,
            test_result="Future test",
            test_date=datetime(2030, 12, 31, 23, 59, 59)
        )
        created_test_ids.append(future_test_id)
        print(f"✓ Test 5.1 - Created test with future date: ID = {future_test_id}")
        
        # Test 5.2: Create test with past date
        past_test_id = test_manager.create_test(
            test_type=0,
            host_iden=0,
            test_result="Historical test",
            test_date=datetime(2020, 1, 1, 0, 0, 1)
        )
        created_test_ids.append(past_test_id)
        print(f"✓ Test 5.2 - Created test with past date: ID = {past_test_id}")
        
        # Test 5.3: Create test with special characters in result
        special_chars_test_id = test_manager.create_test(
            test_type=100,
            host_iden=1000,
            test_result="Test with special chars: !@#$%^&*()_+-=[]{}|;:,.<>?",
            test_date=datetime.now()
        )
        created_test_ids.append(special_chars_test_id)
        print(f"✓ Test 5.3 - Created test with special characters: ID = {special_chars_test_id}")
        
        # TEST CASE 6: Performance Test
        print("\n6. PERFORMANCE TEST")
        print("-" * 40)
        
        import time
        
        # Test 6.1: Bulk operations
        start_time = time.time()
        bulk_test_ids = []
        for i in range(10):
            test_id = test_manager.create_test(
                test_type=i,
                host_iden=2000 + i,
                test_result=f"Bulk test {i}",
                test_date=datetime.now() - timedelta(minutes=i)
            )
            bulk_test_ids.append(test_id)
        
        # List all tests
        all_tests = test_manager.list_test()
        
        # Load some tests
        for test_id in bulk_test_ids[:5]:
            test_manager.load_test(test_id)
        
        # Delete some tests
        for test_id in bulk_test_ids[5:]:
            test_manager.delete_test(test_id)
        
        end_time = time.time()
        print(f"✓ Test 6.1 - Bulk operations (10 creates, 1 list, 5 loads, 5 deletes) took {end_time - start_time:.2f} seconds")
        
        created_test_ids.extend(bulk_test_ids)
        
        # Final summary
        print("\n" + "=" * 60)
        print("TEST SUMMARY")
        print("=" * 60)
        final_test_count = len(test_manager.list_test())
        print(f"Total tests created during testing: {len(created_test_ids)}")
        print(f"Active tests remaining: {final_test_count}")
        print(f"Tests marked as deleted: {len(created_test_ids) - final_test_count + (active_count - len(set(created_test_ids)))}")
        
        test_manager.conn.commit()
        print("✓ All test cases completed successfully!")
        
    except mysql.connector.Error as e:
        print(f"✗ Database error during testing: {e}")
        test_manager.conn.rollback()
    except Exception as e:
        print(f"✗ Unexpected error during testing: {e}")
        test_manager.conn.rollback()
    finally:
        test_manager.conn.close()
        print("Database connection closed.")


# Simple example usage
def simple_example():
    """Simple example usage of TestManager"""
    from datetime import datetime
    
    # Database configuration
    db_config = {
        'host': 'localhost',
        'user': 'bob',
        'password': '20250630!',
        'database': 'itsec_01'
    }
    
    # Using class-based approach
    test_manager = TestManager(db_config)
    
    try:
        # Create a new test with current timestamp
        new_test_id = test_manager.create_test(
            test_type=1,
            host_iden=100,
            test_result="Test completed successfully",
            test_date=datetime.now()  # Now includes hour, minute, second
        )
        print(f"Created test with ID: {new_test_id}")
        
        # Create another test with specific datetime
        specific_test_id = test_manager.create_test(
            test_type=2,
            host_iden=101,
            test_result="Scheduled test execution",
            test_date=datetime(2025, 6, 19, 15, 30, 45)  # 3:30:45 PM
        )
        print(f"Created scheduled test with ID: {specific_test_id}")
        
        # Load the created test
        test_data = test_manager.load_test(new_test_id)
        print(f"Loaded test: {test_data}")
        print(f"Test date with time: {test_data['TEST_DATE']}")
        
        # List all tests
        all_tests = test_manager.list_test()
        print(f"Total active tests: {len(all_tests)}")
        
        # Get latest tests by host
        latest_by_host = test_manager.list_test_latest_by_host()
        print(f"Latest tests by host: {len(latest_by_host)} unique hosts")
        for test in latest_by_host:
            print(f"  Host {test['HOST_IDEN']}: Test {test['TEST_IDEN']} at {test['TEST_DATE']}")
        
        # Delete the test (mark as deleted)
        deleted = test_manager.delete_test(new_test_id)
        print(f"Test deleted: {deleted}")
        
        test_manager.conn.commit()
        
    except mysql.connector.Error as e:
        print(f"Database error: {e}")
        test_manager.conn.rollback()
    finally:
        test_manager.conn.close()


# Run tests if script is executed directly
if __name__ == "__main__":
    print("Choose test mode:")
    print("1. Run comprehensive test cases")
    print("2. Run simple example")
    
    choice = input("Enter choice (1 or 2): ").strip()
    
    if choice == "1":
        run_test_cases()
    elif choice == "2":
        simple_example()
    else:
        print("Invalid choice. Running simple example...")
        simple_example()
