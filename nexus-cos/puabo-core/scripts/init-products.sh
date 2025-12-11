#!/bin/bash
echo "Initializing PUABO Core Products..."

# Create product configuration directory if it doesn't exist
mkdir -p ../config/products

# Create BLAC Personal Loan product
echo '{"name":"BLAC Personal Loan","type":"personal","maxAmount":50000,"interestRate":12.5,"term":36}' > ../config/products/blac_personal.json
echo "Created BLAC Personal Loan product"

# Create BLAC SBL Loan product
echo '{"name":"BLAC SBL Loan","type":"sbl","maxAmount":100000,"interestRate":10.5,"term":60}' > ../config/products/blac_sbl.json
echo "Created BLAC SBL Loan product"

# Create Nexus Fleet Loan product
echo '{"name":"Nexus Fleet Loan","type":"fleet","maxAmount":250000,"interestRate":9.5,"term":72}' > ../config/products/nexus_fleet.json
echo "Created Nexus Fleet Loan product"

echo "Products initialized successfully!"
