#!/usr/bin/env bash
ufw default deny incoming
ufw allow 22
ufw allow 443
sysctl -w net.ipv4.conf.all.rp_filter=1
echo "HARDENED"
