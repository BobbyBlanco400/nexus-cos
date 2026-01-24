#!/bin/bash
# verify_full_stack_ports.sh
# Verifies the port configurations in docker-compose.full.yml matches N3XUS v-COS requirements.

FILE="docker-compose.full.yml"
echo "Verifying $FILE configuration..."

if [ ! -f "$FILE" ]; then
    echo "❌ $FILE not found!"
    exit 1
fi

# Function to check port mapping in the file
check_port_mapping() {
    local service=$1
    local expected_port=$2
    
    # We look for the service definition, then the ports section within it
    # This is a simple grep check, might need manual inspection if complex
    if grep -A 20 "$service:" "$FILE" | grep -q "$expected_port"; then
        echo "✅ $service is mapped to $expected_port"
    else
        echo "❌ $service port mapping mismatch! Expected $expected_port"
        # Print the actual found lines for debugging
        grep -A 20 "$service:" "$FILE" | grep "ports:" -A 1
        return 1
    fi
}

# Function to check environment variable
check_env_var() {
    local service=$1
    local env_var=$2
    
    if grep -A 20 "$service:" "$FILE" | grep -q "$env_var"; then
        echo "✅ $service has $env_var"
    else
        echo "❌ $service missing $env_var"
        return 1
    fi
}

echo "--- Checking Critical Services ---"

# 1. v-supercore
check_port_mapping "v-supercore" "3001:8080"
# Check healthcheck port in v-supercore (should be 8080)
if grep -A 30 "v-supercore:" "$FILE" | grep "healthcheck" -A 5 | grep -q "8080"; then
    echo "✅ v-supercore healthcheck uses port 8080"
else
    echo "❌ v-supercore healthcheck port mismatch (expected 8080)"
fi

# 2. auth-service
check_port_mapping "auth-service" "4052:3000"
check_env_var "auth-service" "PORT=3000"

# 3. puabo-nexus
check_port_mapping "puabo-nexus" "4056:3000"
check_env_var "puabo-nexus" "PORT=3000"

# 4. federation-spine
check_port_mapping "federation-spine" "3010:3000"
check_env_var "federation-spine" "PORT=3000"

# 5. jurisdiction-rules (Directory check)
if [ -d "services/nuisance/jurisdiction-rules" ]; then
    echo "✅ Jurisdiction service directory found: services/nuisance/jurisdiction-rules"
else
    echo "❌ Jurisdiction service directory NOT found!"
fi

echo "--- Verification Complete ---"
