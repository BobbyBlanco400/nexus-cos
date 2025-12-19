#!/usr/bin/env python3
"""Master PF Deployment - AGGRESSIVE MODE | Requires: pip install paramiko"""
import paramiko
import time

VPS_HOST = "74.208.155.161"
VPS_USER = "root"
DIRS = ["/var/www/nexus-cos/casino/", "/var/www/vhosts/nexuscos.online/httpdocs/casino/"]
HTML = '<!DOCTYPE html><html><head><title>V5 Master - Vegas Floor</title></head><body><h1>Casino V5 Master</h1></body></html>'

def deploy():
    attempt = 0
    while True:
        attempt += 1
        print(f"\n=== ATTEMPT #{attempt} ===")
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            print(f"Handshake: 77 -> 45 -> 17")
            ssh.connect(VPS_HOST, username=VPS_USER, timeout=10)
            for d in DIRS:
                print(f"Creating {d}")
                ssh.exec_command(f"mkdir -p {d}")
            print("Deploying V5 Master (Vegas Floor)")
            ssh.exec_command(f"echo '{HTML}' > {DIRS[0]}/index.html")
            ssh.exec_command(f"echo '{HTML}' > {DIRS[1]}/index.html")
            print("Restarting Nginx")
            ssh.exec_command("systemctl restart nginx")
            print("\n✓ SUCCESS!")
            ssh.close()
            return
        except Exception as e:
            print(f"✗ Failed: {e}")
            time.sleep(5)

if __name__ == "__main__":
    print("MASTER PF DEPLOYMENT - AGGRESSIVE MODE ENGAGED")
    deploy()
