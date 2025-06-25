import os
import yaml
import tempfile
import subprocess
import platform
from datetime import datetime
from typing import List, Dict
from collections import defaultdict

def run_ansible_playbook_on_hosts(host_list: List[Dict[str, str]]) -> bool:
    """
    Execute Ansible playbook on multiple hosts grouped by OS type.
    Cross-platform version using subprocess instead of ansible-runner.
    
    Args:
        host_list: List of dictionaries containing host information
                  Each dict should have: HOST_IDEN, HOST_ADDR, HOST_USER, HOST_PORT, HOST_SUPW, HOST_OS
    
    Returns:
        bool: True if all OS groups successful, False otherwise
    """

    # Create tmp folder
    if not os.path.exists('tmp'):
        os.makedirs('tmp')
    
    # Group hosts by OS type
    os_groups = group_hosts_by_os(host_list)
    
    overall_success = True
    
    # Process each OS group separately
    for os_type, hosts in os_groups.items():
        print(f"\n{'='*50}")
        print(f"Processing {len(hosts)} {os_type} hosts...")
        print(f"{'='*50}")
        
        # Check if script exists for this OS type
        script_path = get_script_path(os_type)
        if not os.path.exists(script_path):
            print(f"Warning: Script {script_path} not found. Skipping {os_type} hosts.")
            overall_success = False
            continue
        
        # Create temporary files for inventory and playbook
        try:
            with tempfile.NamedTemporaryFile(mode='w', suffix='.yml', delete=False, encoding='utf-8') as inv_file:
                inventory = create_os_inventory(hosts, os_type)
                yaml.dump(inventory, inv_file, default_flow_style=False)
                inventory_path = inv_file.name
            
            with tempfile.NamedTemporaryFile(mode='w', suffix='.yml', delete=False, encoding='utf-8') as pb_file:
                playbook = create_os_playbook(os_type)
                yaml.dump(playbook, pb_file, default_flow_style=False)
                playbook_path = pb_file.name
            
            # Execute ansible-playbook command
            success = execute_ansible_playbook(inventory_path, playbook_path, os_type)
            if not success:
                overall_success = False
                
        except Exception as e:
            print(f"✗ Error executing {os_type} playbook: {e}")
            overall_success = False
        finally:
            # Clean up temporary files
            try:
                if 'inventory_path' in locals():
                    os.unlink(inventory_path)
                if 'playbook_path' in locals():
                    os.unlink(playbook_path)
            except OSError:
                pass
    
    return overall_success

def execute_ansible_playbook(inventory_path: str, playbook_path: str, os_type: str) -> bool:
    """Execute ansible-playbook command using subprocess."""
    
    # Build ansible-playbook command
    cmd = ['ansible-playbook', '-i', inventory_path, playbook_path, '-v']
    
    try:
        print(f"Executing {os_type} playbook...")
        
        # Use different subprocess parameters based on OS
        if platform.system() == 'Windows':
            # Windows-specific subprocess configuration
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                shell=True,
                encoding='utf-8',
                timeout=300  # 5 minute timeout
            )
        else:
            # Linux/Unix subprocess configuration
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
        
        if result.returncode == 0:
            print(f"✓ {os_type} playbook executed successfully!")
            # Print relevant output lines
            output_lines = result.stdout.split('\n')
            for line in output_lines:
                if 'TASK' in line or 'ok:' in line or 'changed:' in line:
                    print(f"  {line}")
            return True
        else:
            print(f"✗ {os_type} playbook failed with return code: {result.returncode}")
            print(f"Error output: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        print(f"✗ {os_type} playbook timed out after 5 minutes")
        return False
    except FileNotFoundError:
        print("✗ ansible-playbook command not found. Please ensure Ansible is installed and in PATH.")
        return False
    except Exception as e:
        print(f"✗ Error executing {os_type} playbook: {e}")
        return False

def check_ansible_connectivity(host_list: List[Dict[str, str]]) -> Dict[str, Dict[str, any]]:
    """
    Check if hosts are reachable and manageable by Ansible.
    Cross-platform version using subprocess.
    """
    
    # Group hosts by OS for connectivity testing
    os_groups = group_hosts_by_os(host_list)
    results = {}
    
    for os_type, hosts in os_groups.items():
        print(f"\nTesting connectivity for {os_type} hosts...")
        
        try:
            # Create temporary inventory for connectivity test
            with tempfile.NamedTemporaryFile(mode='w', suffix='.yml', delete=False, encoding='utf-8') as inv_file:
                inventory = create_os_inventory(hosts, os_type)
                yaml.dump(inventory, inv_file, default_flow_style=False)
                inventory_path = inv_file.name
            
            # Create connectivity test playbook
            with tempfile.NamedTemporaryFile(mode='w', suffix='.yml', delete=False, encoding='utf-8') as pb_file:
                if os_type == 'Windows':
                    playbook = create_windows_connectivity_playbook(f"{os_type.lower()}_hosts")
                else:
                    playbook = create_unix_connectivity_playbook(f"{os_type.lower()}_hosts")
                yaml.dump(playbook, pb_file, default_flow_style=False)
                playbook_path = pb_file.name
            
            # Execute connectivity test
            cmd = ['ansible-playbook', '-i', inventory_path, playbook_path]
            
            if platform.system() == 'Windows':
                result = subprocess.run(cmd, capture_output=True, text=True, shell=True, encoding='utf-8')
            else:
                result = subprocess.run(cmd, capture_output=True, text=True)
            
            # Process results for each host in this OS group
            for i, host in enumerate(hosts):
                host_iden = host['HOST_IDEN']
                
                results[host_iden] = {
                    'reachable': False,
                    'ssh_accessible': False,
                    'sudo_accessible': False,
                    'hostname': None,
                    'os': os_type,
                    'os_full': host.get('HOST_OS_FULL', 'N/A'),
                    'detected_os': None,
                    'error': None,
                    'host_addr': host['HOST_ADDR']
                }
                
                # Simple success/failure detection based on return code
                if result.returncode == 0:
                    results[host_iden]['reachable'] = True
                    results[host_iden]['ssh_accessible'] = True
                    results[host_iden]['sudo_accessible'] = True
                else:
                    # Parse error from stderr
                    error_msg = result.stderr if result.stderr else "Connection failed"
                    results[host_iden]['error'] = error_msg
                
        except Exception as e:
            # If the entire run failed, mark all hosts in this group as unreachable
            for host in hosts:
                host_iden = host['HOST_IDEN']
                results[host_iden] = {
                    'reachable': False,
                    'ssh_accessible': False,
                    'sudo_accessible': False,
                    'hostname': None,
                    'os': os_type,
                    'os_full': host.get('HOST_OS_FULL', 'N/A'),
                    'detected_os': None,
                    'error': f'Connectivity test failed: {str(e)}',
                    'host_addr': host['HOST_ADDR']
                }
        finally:
            # Clean up temporary files
            try:
                if 'inventory_path' in locals():
                    os.unlink(inventory_path)
                if 'playbook_path' in locals():
                    os.unlink(playbook_path)
            except OSError:
                pass
    
    return results

def group_hosts_by_os(host_list: List[Dict[str, str]]) -> Dict[str, List[Dict[str, str]]]:
    """Group hosts by their OS type, extracting base OS from version strings."""
    os_groups = defaultdict(list)
    
    for host in host_list:
        os_full = host.get('HOST_OS', 'else')
        
        # Extract base OS type from full OS string (e.g., "Ubuntu 24.04" -> "ubuntu")
        os_base = extract_base_os_type(os_full)
        
        # Normalize OS names to standard categories
        if os_base in ['ubuntu', 'debian']:
            os_type = 'Ubuntu'
        elif os_base in ['centos', 'rhel', 'redhat', 'fedora', 'rocky', 'almalinux']:
            os_type = 'CentOS'
        elif os_base in ['windows', 'win']:
            os_type = 'Windows'
        else:
            os_type = 'else'
        
        # Update the host dict with normalized OS and keep original
        host_copy = host.copy()
        host_copy['HOST_OS_TYPE'] = os_type  # Normalized type for scripts
        host_copy['HOST_OS_FULL'] = os_full  # Original full OS string
        os_groups[os_type].append(host_copy)
    
    return dict(os_groups)

def extract_base_os_type(os_string: str) -> str:
    """
    Extract base OS type from full OS string.
    
    Examples:
        "Ubuntu 24.04" -> "ubuntu"
        "CentOS 8.5" -> "centos"
        "Windows Server 2019" -> "windows"
        "Red Hat Enterprise Linux 9.2" -> "redhat"
    """
    if not os_string:
        return 'else'
    
    # Convert to lowercase and split by spaces
    os_parts = os_string.lower().split()
    
    if not os_parts:
        return 'else'
    
    first_word = os_parts[0]
    
    # Handle special cases
    if first_word == 'red' and len(os_parts) > 1 and os_parts[1] == 'hat':
        return 'redhat'
    elif first_word == 'windows':
        return 'windows'
    elif first_word in ['ubuntu', 'debian', 'centos', 'fedora', 'rocky', 'almalinux']:
        return first_word
    elif 'rhel' in first_word or 'redhat' in first_word:
        return 'redhat'
    elif 'win' in first_word:
        return 'windows'
    else:
        return 'else'

def get_script_path(os_type: str) -> str:
    """Get the script path for the given OS type."""
    script_names = {
        'Ubuntu': 'script/Ubuntu/Ubuntu_cce.sh',
        'CentOS': 'script/CentOS/CentOS_cce.sh', 
        'Windows': 'script/Windows/Windows_cce.bat',
        'else': 'script/else/else_cce.sh'
    }
    
    return os.path.join(os.getcwd(), script_names.get(os_type, 'script/else/else_cce.sh'))

def create_os_inventory(host_list: List[Dict[str, str]], os_type: str) -> dict:
    """Create Ansible inventory dictionary for specific OS type."""
    group_name = f"{os_type.lower()}_hosts"
    
    inventory = {
        group_name: {
            'hosts': {}
        }
    }
    
    for i, host in enumerate(host_list):
        host_name = f"{os_type.lower()}_host_{i}"
        host_config = {
            'ansible_host': host['HOST_ADDR'],
            'ansible_user': host['HOST_USER'],
            'ansible_port': int(host['HOST_PORT']),
            'ansible_become_password': host['HOST_SUPW'],
            'ansible_ssh_common_args': '-o StrictHostKeyChecking=no',
            'host_os_type': host['HOST_OS_TYPE'],
            'host_os_full': host['HOST_OS_FULL'],
            'host_ip': host['HOST_ADDR'],
            'host_identifier': host['HOST_IDEN']
        }
        
        # Windows-specific configuration
        if os_type == 'Windows':
            host_config.update({
                'ansible_connection': 'winrm',
                'ansible_winrm_transport': 'basic',
                'ansible_winrm_server_cert_validation': 'ignore'
            })
        
        inventory[group_name]['hosts'][host_name] = host_config
    
    return inventory

def create_os_playbook(os_type: str) -> list:
    """Create the Ansible playbook for specific OS type."""
    group_name = f"{os_type.lower()}_hosts"
    script_name = get_script_filename(os_type)
    
    if os_type == 'Windows':
        return create_windows_playbook(group_name, script_name)
    elif os_type == 'else':
        return create_else_playbook(group_name)
    else:
        return create_unix_playbook(group_name, script_name)

def get_script_filename(os_type: str) -> str:
    """Get script filename for the OS type."""
    script_names = {
        'Ubuntu': 'Ubuntu_cce.sh',
        'CentOS': 'CentOS_cce.sh',
        'Windows': 'Windows_cce.bat',
        'else': 'else_cce.sh'
    }
    return script_names.get(os_type, 'else_cce.sh')

def create_unix_playbook(group_name: str, script_name: str) -> list:
    """Create playbook for Unix-like systems (Ubuntu, CentOS)."""
    # Extract OS type from group_name (e.g., "ubuntu_hosts" -> "Ubuntu")
    os_type = group_name.replace('_hosts', '')
    if os_type == 'ubuntu':
        os_type = 'Ubuntu'
    elif os_type == 'centos':
        os_type = 'CentOS'
    
    script_path = get_script_path(os_type)
    
    playbook = [{
        'name': f'Execute {script_name} on {group_name}',
        'hosts': group_name,
        'become': True,
        'gather_facts': True,
        'vars': {
            'script_name': script_name,
            'script_path': script_path,
            'local_dir': os.getcwd(),
            'tmp_dir': os.path.join(os.getcwd(), 'tmp')
        },
        'tasks': [
            {
                'name': 'Create tmp directory on control node',
                'local_action': {
                    'module': 'file',
                    'path': "{{ tmp_dir }}",
                    'state': 'directory'
                },
                'become': False,
                'run_once': True
            },
            {
                'name': f'Copy {script_name} to host',
                'copy': {
                    'src': "{{ script_path }}",
                    'dest': "/tmp/{{ script_name }}",
                    'mode': '0755'
                }
            },
            {
                'name': f'Execute {script_name}',
                'command': f'/tmp/{script_name}',
                'args': {
                    'chdir': '/tmp'
                },
                'register': 'script_result'
            },
            {
                'name': 'Find generated JSON files',
                'find': {
                    'paths': ['/tmp'],
                    'patterns': ['{{ host_os_type }}_*.json']
                },
                'register': 'json_files'
            },
            {
                'name': 'Fetch JSON files to control node tmp directory',
                'fetch': {
                    'src': "{{ item.path }}",
                    'dest': "{{ tmp_dir }}/",
                    'flat': True
                },
                'loop': "{{ json_files.files }}"
            },
            {
                'name': 'Rename JSON files to use HOST_IDEN',
                'local_action': {
                    'module': 'copy',
                    'src': "{{ tmp_dir }}/{{ item.path | basename }}",
                    'dest': "{{ tmp_dir }}/{{ host_identifier }}.json"
                },
                'loop': "{{ json_files.files }}",
                'become': False
            },
            {
                'name': 'Remove original JSON files from tmp directory',
                'local_action': {
                    'module': 'file',
                    'path': "{{ tmp_dir }}/{{ item.path | basename }}",
                    'state': 'absent'
                },
                'loop': "{{ json_files.files }}",
                'become': False
            },
            {
                'name': 'Remove script from host',
                'file': {
                    'path': "/tmp/{{ script_name }}",
                    'state': 'absent'
                }
            },
            {
                'name': 'Remove JSON files from host',
                'file': {
                    'path': "{{ item.path }}",
                    'state': 'absent'
                },
                'loop': "{{ json_files.files }}"
            }
        ]
    }]
    
    return playbook

def create_windows_playbook(group_name: str, script_name: str) -> list:
    """Create playbook for Windows systems."""
    script_path = get_script_path('Windows')
    
    playbook = [{
        'name': f'Execute {script_name} on {group_name}',
        'hosts': group_name,
        'gather_facts': True,
        'vars': {
            'script_name': script_name,
            'script_path': script_path,
            'local_dir': os.getcwd(),
            'tmp_dir': os.path.join(os.getcwd(), 'tmp')
        },
        'tasks': [
            {
                'name': 'Create tmp directory on control node',
                'local_action': {
                    'module': 'file',
                    'path': "{{ tmp_dir }}",
                    'state': 'directory'
                },
                'become': False,
                'run_once': True
            },
            {
                'name': f'Copy {script_name} to host',
                'win_copy': {
                    'src': "{{ script_path }}",
                    'dest': "C:\\temp\\{{ script_name }}"
                }
            },
            {
                'name': f'Execute {script_name}',
                'win_command': 'C:\\temp\\{{ script_name }}',
                'args': {
                    'chdir': 'C:\\temp'
                },
                'register': 'script_result'
            },
            {
                'name': 'Find generated JSON files',
                'win_find': {
                    'paths': ['C:\\temp'],
                    'patterns': ['{{ host_os_type }}_*.json']
                },
                'register': 'json_files'
            },
            {
                'name': 'Fetch JSON files to control node tmp directory',
                'fetch': {
                    'src': "{{ item.path }}",
                    'dest': "{{ tmp_dir }}/",
                    'flat': True
                },
                'loop': "{{ json_files.files }}"
            },
            {
                'name': 'Rename JSON files to use HOST_IDEN',
                'local_action': {
                    'module': 'copy',
                    'src': "{{ tmp_dir }}/{{ item.path | win_basename }}",
                    'dest': "{{ tmp_dir }}/{{ host_identifier }}.json"
                },
                'loop': "{{ json_files.files }}",
                'become': False
            },
            {
                'name': 'Remove original JSON files from tmp directory',
                'local_action': {
                    'module': 'file',
                    'path': "{{ tmp_dir }}/{{ item.path | win_basename }}",
                    'state': 'absent'
                },
                'loop': "{{ json_files.files }}",
                'become': False
            },
            {
                'name': 'Remove script from host',
                'win_file': {
                    'path': "C:\\temp\\{{ script_name }}",
                    'state': 'absent'
                }
            },
            {
                'name': 'Remove JSON files from host',
                'win_file': {
                    'path': "{{ item.path }}",
                    'state': 'absent'
                },
                'loop': "{{ json_files.files }}"
            }
        ]
    }]
    
    return playbook

def create_else_playbook(group_name: str) -> list:
    """Create a no-op playbook for 'else' OS type."""
    playbook = [{
        'name': f'No operation for {group_name} (else OS type)',
        'hosts': group_name,
        'gather_facts': False,
        'tasks': [
            {
                'name': 'Display message for unsupported OS',
                'debug': {
                    'msg': "This host has an unsupported OS type. No operations performed."
                }
            }
        ]
    }]
    
    return playbook

def create_unix_connectivity_playbook(group_name: str) -> list:
    """Create connectivity test playbook for Unix systems."""
    return [{
        'name': 'Test Unix connectivity',
        'hosts': group_name,
        'gather_facts': False,
        'tasks': [
            {
                'name': 'Test connection',
                'ping': {},
                'register': 'ping_result'
            },
            {
                'name': 'Test sudo access',
                'command': 'whoami',
                'become': True,
                'register': 'sudo_result'
            }
        ]
    }]

def create_windows_connectivity_playbook(group_name: str) -> list:
    """Create connectivity test playbook for Windows systems."""
    return [{
        'name': 'Test Windows connectivity',
        'hosts': group_name,
        'gather_facts': False,
        'tasks': [
            {
                'name': 'Test connection',
                'win_ping': {},
                'register': 'ping_result'
            },
            {
                'name': 'Test admin access',
                'win_whoami': {},
                'register': 'whoami_result'
            }
        ]
    }]

def create_extravars(host_list: List[Dict[str, str]]) -> dict:
    """Create extra variables for the playbook."""
    return {
        'local_dir': os.getcwd(),
        'current_time': datetime.now().strftime("%Y%m%d_%H%M%S")
    }

def print_connectivity_report(connectivity_results: Dict[str, Dict[str, any]]) -> None:
    """Print a formatted connectivity report with OS information."""
    print("\n" + "="*70)
    print("ANSIBLE CONNECTIVITY REPORT")
    print("="*70)
    
    # Group results by OS
    os_groups = defaultdict(list)
    for host_iden, result in connectivity_results.items():
        os_groups[result['os']].append((host_iden, result))
    
    total_reachable = 0
    total_hosts = len(connectivity_results)
    
    for os_type, host_results in os_groups.items():
        print(f"\n{os_type.upper()} HOSTS:")
        print("-" * 50)
        
        for host_iden, result in host_results:
            print(f"\nHost ID: {host_iden} ({result['host_addr']})")
            print(f"  Full OS: {result.get('os_full', 'N/A')}")
            
            if result['reachable']:
                total_reachable += 1
                print("  ✓ Connection: SUCCESS")
                
                if result['sudo_accessible']:
                    print("  ✓ Privilege Access: SUCCESS")
                else:
                    print("  ✗ Privilege Access: FAILED")
                    
                if result['hostname']:
                    print(f"  Hostname: {result['hostname']}")
                if result['detected_os']:
                    print(f"  Detected OS: {result['detected_os']}")
                        
            else:
                print("  ✗ Connection: FAILED")
                print("  ✗ Privilege Access: N/A")
                if result['error']:
                    print(f"  Error: {result['error']}")
    
    print("\n" + "="*70)
    print(f"SUMMARY: {total_reachable}/{total_hosts} hosts are manageable by Ansible")
    
    # Check for required scripts
    print("\nSCRIPT AVAILABILITY:")
    print("-" * 30)
    required_os_types = set(result['os'] for result in connectivity_results.values())
    for os_type in required_os_types:
        script_path = get_script_path(os_type)
        if os.path.exists(script_path):
            print(f"  ✓ {script_path}")
        else:
            print(f"  ✗ {script_path} (MISSING)")
    
    print("="*70)

def get_manageable_hosts(host_list: List[Dict[str, str]]) -> List[Dict[str, str]]:
    """Filter host list to return only hosts that are manageable by Ansible."""
    connectivity_results = check_ansible_connectivity(host_list)
    manageable_hosts = []
    
    for host in host_list:
        host_iden = host['HOST_IDEN']
        if (connectivity_results[host_iden]['reachable'] and 
            connectivity_results[host_iden]['sudo_accessible']):
            manageable_hosts.append(host)
    
    return manageable_hosts

def get_unreachable_hosts(host_list: List[Dict[str, str]]) -> List[Dict[str, any]]:
    """
    Filter host list to return only hosts that are NOT reachable by Ansible with reasons.
    
    Args:
        host_list: List of dictionaries containing host information
                  Each dict should have: HOST_IDEN, HOST_ADDR, HOST_USER, HOST_PORT, HOST_SUPW, HOST_OS
    
    Returns:
        List of dictionaries containing host info and unreachability reasons:
        {
            'host': original_host_dict,
            'reason': 'connection_failed' | 'sudo_failed',
            'error': error_message_if_available
        }
    """
    connectivity_results = check_ansible_connectivity(host_list)
    unreachable_hosts = []
    
    for host in host_list:
        host_iden = host['HOST_IDEN']
        result = connectivity_results[host_iden]
       
        if not result['reachable']:
            unreachable_hosts.append({
                'host': host,
                'reason': 'connection_failed',
                'error': result.get('error', 'Unknown connection error')
            })
        elif not result['sudo_accessible']:
            unreachable_hosts.append({
                'host': host,
                'reason': 'sudo_failed',
                'error': result.get('error', 'Sudo/privilege escalation failed')
            })
           
    return unreachable_hosts

def create_sample_scripts():
    """Create sample scripts for different OS types."""
    
    # Ubuntu script
    ubuntu_script = '''#!/bin/bash
# Ubuntu_cce.sh - Sample script for Ubuntu systems

HOST_IP=$(hostname -I | awk '{print $1}')
JSON_FILE="/tmp/Ubuntu_${HOST_IP}.json"

# Collect system information
cat > "$JSON_FILE" << EOF
{
    "collection_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "hostname": "$(hostname)",
    "os": "$(lsb_release -d | cut -f2)",
    "kernel": "$(uname -r)",
    "architecture": "$(uname -m)",
    "ip_address": "$HOST_IP",
    "uptime": "$(uptime -p)",
    "memory_total": "$(free -h | awk '/^Mem:/ {print $2}')",
    "disk_usage": "$(df -h / | awk 'NR==2 {print $5}')",
    "cpu_cores": "$(nproc)",
    "load_average": "$(uptime | awk -F'load average:' '{print $2}')"
}
EOF

echo "Ubuntu system information collected in $JSON_FILE"
'''
    
    # CentOS script
    centos_script = '''#!/bin/bash
# CentOS_cce.sh - Sample script for CentOS/RHEL systems

HOST_IP=$(hostname -I | awk '{print $1}')
JSON_FILE="/tmp/CentOS_${HOST_IP}.json"

# Collect system information
cat > "$JSON_FILE" << EOF
{
    "collection_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "hostname": "$(hostname)",
    "os": "$(cat /etc/redhat-release)",
    "kernel": "$(uname -r)",
    "architecture": "$(uname -m)",
    "ip_address": "$HOST_IP",
    "uptime": "$(uptime -p)",
    "memory_total": "$(free -h | awk '/^Mem:/ {print $2}')",
    "disk_usage": "$(df -h / | awk 'NR==2 {print $5}')",
    "cpu_cores": "$(nproc)",
    "load_average": "$(uptime | awk -F'load average:' '{print $2}')"
}
EOF

echo "CentOS system information collected in $JSON_FILE"
'''
    
    # Windows script
    windows_script = '''@echo off
REM Windows_cce.bat - Sample script for Windows systems

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set HOST_IP=%%a
set HOST_IP=%HOST_IP: =%
set JSON_FILE=C:\\temp\\Windows_%HOST_IP%.json

(
echo {
echo   "collection_time": "%date% %time%",
echo   "hostname": "%COMPUTERNAME%",
echo   "os": "%OS%",
echo   "architecture": "%PROCESSOR_ARCHITECTURE%",
echo   "ip_address": "%HOST_IP%",
echo   "user": "%USERNAME%",
echo   "domain": "%USERDOMAIN%"
echo }
) > "%JSON_FILE%"

echo Windows system information collected in %JSON_FILE%
'''
    
    # Else script (no-op)
    else_script = '''#!/bin/bash
# else_cce.sh - No-op script for unsupported OS types

echo "This OS type is not supported. No operations performed."
exit 0
'''
    
    # Write scripts to current directory
    scripts = {
        'script/Ubuntu/Ubuntu_cce.sh': ubuntu_script,
        'script/CentOS/CentOS_cce.sh': centos_script,
        'script/Windows/Windows_cce.bat': windows_script,
        'script/else/else_cce.sh': else_script
    }
    
    for script_path, script_content in scripts.items():
        full_script_path = os.path.join(os.getcwd(), script_path)
        
        # Create directory if it doesn't exist
        script_dir = os.path.dirname(full_script_path)
        os.makedirs(script_dir, exist_ok=True)
        
        if not os.path.exists(full_script_path):
            with open(full_script_path, 'w', encoding='utf-8') as f:
                f.write(script_content)
            
            # Make Unix scripts executable
            if script_path.endswith('.sh'):
                os.chmod(full_script_path, 0o755)
            
            print(f"Created sample script: {full_script_path}")
        else:
            print(f"Script already exists: {full_script_path}")

# Example usage
if __name__ == "__main__":
    # Create sample scripts if they don't exist
    print("Checking for required scripts...")
    create_sample_scripts()
    
    # Example host list with OS and identifier information
    hosts = [
        {
            'HOST_IDEN': 1,
            'HOST_ADDR': '192.168.203.32',
            'HOST_USER': 'ubuntu',
            'HOST_PORT': '2020',
            'HOST_SUPW': '0630',
            'HOST_OS': 'Ubuntu 24.04'
        },
        {
            'HOST_IDEN': 2,
            'HOST_ADDR': '192.168.203.32', 
            'HOST_USER': 'centos',
            'HOST_PORT': '2021',
            'HOST_SUPW': '20250630!',
            'HOST_OS': 'CentOS 8.5'
        },
        {
            'HOST_IDEN': 3,
            'HOST_ADDR': '192.168.1.102',
            'HOST_USER': 'Administrator',
            'HOST_PORT': '5985',  # WinRM port
            'HOST_SUPW': 'windows_password',
            'HOST_OS': 'Windows Server 2019'
        },
        {
            'HOST_IDEN': 4,
            'HOST_ADDR': '192.168.1.103',
            'HOST_USER': 'root',
            'HOST_PORT': '22',
            'HOST_SUPW': 'root_password',
            'HOST_OS': 'Red Hat Enterprise Linux 9.2'
        }
    ]
    
    # First, check connectivity to all hosts
    print("\nChecking Ansible connectivity...")
    connectivity_results = check_ansible_connectivity(hosts)
    print_connectivity_report(connectivity_results)
    
    # Get only manageable hosts
    manageable_hosts = get_manageable_hosts(hosts)
    
    if manageable_hosts:
        print(f"\nProceeding with {len(manageable_hosts)} manageable hosts...")
        success = run_ansible_playbook_on_hosts(manageable_hosts)
        
        if success:
            print("\nJSON files should now be in your tmp directory!")
            print("Check for files like: tmp/1.json, tmp/2.json, tmp/3.json, tmp/4.json")
        else:
            print("Failed to execute playbook on some hosts.")
    else:
        print("NOTHING TO DO")
