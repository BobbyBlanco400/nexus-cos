#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_yaml>"
    exit 1
fi

INPUT="$1"

python3 /opt/nexus-cos/scripts/generate_nginx.py "$INPUT"