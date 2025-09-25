#!/bin/bash
cp /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf.bak
sed -i '/default = default_sect/a legacy = legacy_sect' /etc/ssl/openssl.cnf
echo "" >> /etc/ssl/openssl.cnf
echo "[legacy_sect]" >> /etc/ssl/openssl.cnf
echo "activate = 1" >> /etc/ssl/openssl.cnf