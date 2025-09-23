@echo off
echo Generating SSH key for NEXUS COS VPS...
ssh-keygen -t rsa -b 4096 -f "%USERPROFILE%\.ssh\nexus-cos-vps" -N "" -C "nexus-cos-vps@%COMPUTERNAME%"
echo SSH key generation complete!
pause