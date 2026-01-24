
import paramiko
import os
import sys

VPS_HOST = "72.62.86.217"
USERS = ["root", "admin_nexus", "ubuntu", "admin"]
PASSWORDS = ["WelcomeToVegas_25", "nexus_secure_password", "admin123"]
PUB_KEY_FILE = "temp_deploy_key.pub"

def install_key():
    try:
        with open(PUB_KEY_FILE, "r") as f:
            pub_key = f.read().strip()
    except Exception as e:
        print(f"Error reading public key: {e}")
        return False

    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    connected = False
    for user in USERS:
        for pwd in PASSWORDS:
            print(f"Trying {user} with {pwd}...")
            try:
                client.connect(VPS_HOST, username=user, password=pwd, timeout=5)
                print(f"Connected as {user}!")
                connected = True
                
                # If not root, we might need sudo
                # But for now, let's just try to install key for THIS user
                # If we need root, we can try sudo
                break
            except paramiko.AuthenticationException:
                pass
            except Exception as e:
                print(f"Connection error: {e}")
                # If connection error (not auth), likely host issue
                pass
        if connected:
            break
    
    if not connected:
        print("Could not connect with any user/password combination.")
        return False

    try:
        stdin, stdout, stderr = client.exec_command("mkdir -p ~/.ssh && chmod 700 ~/.ssh")
        stdout.channel.recv_exit_status()
        
        stdin, stdout, stderr = client.exec_command(f"grep -F '{pub_key}' ~/.ssh/authorized_keys")
        if stdout.channel.recv_exit_status() == 0:
            print("Key already exists.")
        else:
            print("Adding key...")
            stdin, stdout, stderr = client.exec_command(f"echo '{pub_key}' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys")
            if stdout.channel.recv_exit_status() != 0:
                print(f"Error adding key: {stderr.read().decode()}")
                return False
            print("Key added successfully.")

    except Exception as e:
        print(f"Error during key installation: {e}")
        return False
    finally:
        client.close()
    
    return True

if __name__ == "__main__":
    if install_key():
        print("SSH Key Installation Complete.")
        sys.exit(0)
    else:
        print("SSH Key Installation Failed.")
        sys.exit(1)
