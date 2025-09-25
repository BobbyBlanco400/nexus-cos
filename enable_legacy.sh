#!/bin/bash
cp /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf.bak
awk '/\[legacy_sect\]/ {print; print "activate = 1"; next} {print}' /etc/ssl/openssl.cnf > /etc/ssl/temp.cnf
mv /etc/ssl/temp.cnf /etc/ssl/openssl.cnf