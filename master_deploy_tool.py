#!/usr/bin/env python3
"""Master PF Deployment - AGGRESSIVE MODE | Requires: pip install paramiko"""
import paramiko
import time
import sys

VPS_HOST = "74.208.155.161"
VPS_USER = "root"
DIRS = ["/var/www/nexus-cos/casino/", "/var/www/vhosts/nexuscos.online/httpdocs/casino/"]
HTML = '<!DOCTYPE html><html><head><title>V5 Master - Vegas Floor</title></head><body><h1>Casino V5 Master</h1></body></html>'

def exec_cmd(ssh, cmd):
    """Execute command and check result"""
    stdin, stdout, stderr = ssh.exec_command(cmd)
    exit_status = stdout.channel.recv_exit_status()
    if exit_status != 0:
        raise Exception(f"Command failed: {cmd} - {stderr.read().decode()}")
    return stdout.read().decode()

def deploy_file(ssh, content, path):
    """Deploy file using SFTP for safer transfer"""
    sftp = ssh.open_sftp()
    with sftp.file(path, 'w') as f:
        f.write(content)
    sftp.close()

def deploy():
    attempt = 0
    while True:
        attempt += 1
        print(f"\n=== ATTEMPT #{attempt} ===")
        ssh = None
        try:
            ssh = paramiko.SSHClient()
            # Note: AutoAddPolicy used for aggressive mode to handle server reboots/key changes
            # This is intentional for deployment automation through server lockout cycles
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            print(f"Handshake: 77 -> 45 -> 17")
            ssh.connect(VPS_HOST, username=VPS_USER, timeout=10, look_for_keys=True)
            for d in DIRS:
                print(f"Creating {d}")
                exec_cmd(ssh, f"mkdir -p {d}")
            print("Deploying V5 Master (Vegas Floor)")
            deploy_file(ssh, HTML, f"{DIRS[0]}/index.html")
            deploy_file(ssh, HTML, f"{DIRS[1]}/index.html")
            print("Restarting Nginx")
            exec_cmd(ssh, "systemctl restart nginx")
            print("\n✓ SUCCESS!")
            return
        except Exception as e:
            print(f"✗ Failed: {e}")
            time.sleep(5)
        finally:
            if ssh:
                ssh.close()

if __name__ == "__main__":
    print("MASTER PF DEPLOYMENT - AGGRESSIVE MODE ENGAGED")
    deploy()
