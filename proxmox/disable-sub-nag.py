#!/usr/bin/env python3
import re
import os
import subprocess
import sys

PVE_LIB_FILE = '/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js'
PVE_LIB_BACKUP = '/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.backup'

pattern = re.compile(r'if\s*\(\s*res\s*===\s*null\s*\|\|\s*res\s*===\s*undefined\s*\|\|\s*!res\s*\|\|\s*res\.data\.status\.toLowerCase\(\s*\)\s*!==\s*\'active\'\s*\)')
replacement = 'if (false)'

# Read the file first to check if pattern exists
try:
    with open(PVE_LIB_FILE, 'r') as f:
        content = f.read()
    
    # Check if pattern exists in the file
    if not pattern.search(content):
        print(f"Error: The expected pattern was not found in {PVE_LIB_FILE}")
        sys.exit(1)
        
except FileNotFoundError:
    print(f"Error: File {PVE_LIB_FILE} not found.")
    sys.exit(1)
except Exception as e:
    print(f"Error reading file: {str(e)}")
    sys.exit(1)

# Delete existing backup
if os.path.exists(PVE_LIB_BACKUP):
    subprocess.run(['sudo', 'rm', '-f', PVE_LIB_BACKUP], check=True)

# Create new backup with sudo
subprocess.run(['sudo', 'cp', '-fp', PVE_LIB_FILE, PVE_LIB_BACKUP], check=True)  # -p preserves permissions

# Modify the content
new_content = pattern.sub(replacement, content)

# Write the file with sudo using a temporary file
temp_file = '/tmp/proxmoxlib.js.tmp'
with open(temp_file, 'w') as f:
    f.write(new_content)

# Force move and set permissions
subprocess.run(['sudo', 'mv', '-f', temp_file, PVE_LIB_FILE], check=True)
subprocess.run(['sudo', 'chmod', '644', PVE_LIB_FILE], check=True)

# Show differences between modified file and backup
print("\nDifferences between the original and the modified file:")
subprocess.run(['sudo', 'diff', '--color=always', PVE_LIB_BACKUP, PVE_LIB_FILE])

# Restart pveproxy
print("\nRestarting pveproxy service...")
subprocess.run(['sudo', 'systemctl', 'restart', 'pveproxy'], check=True)
print("Done!")
