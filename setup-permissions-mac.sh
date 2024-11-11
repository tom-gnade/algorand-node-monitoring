#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

echo "Setting up permissions for AlgoMon persistent storage on macOS..."

# Create data directories if they don't exist
mkdir -p elasticsearch/data prometheus/data grafana/data

# Set permissions for each service's data directory
echo "Setting Elasticsearch permissions..."
chown -R 1000:1000 ./elasticsearch/data
chmod -R 755 ./elasticsearch/data

echo "Setting Prometheus permissions..."
chown -R 65534:65534 ./prometheus/data
chmod -R 755 ./prometheus/data

echo "Setting Grafana permissions..."
chown -R 472:472 ./grafana/data
chmod -R 755 ./grafana/data

echo "Done! All permissions have been set correctly."
echo "You can now run 'docker compose up -d' to start AlgoMon."