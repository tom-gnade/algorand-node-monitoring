#!/bin/bash

# Check if we're on Linux
if [ "$(uname)" = "Linux" ]; then
    echo "Setting up Grafana permissions..."
    sudo chown -R 472:472 ./grafana/data
    sudo chown 472:472 ./grafana/dashboard-provider.yaml
    sudo chown 472:472 ./grafana/datasource-manifest.yaml
    echo "Done!"
else
    echo "Not on Linux - skipping permission setup"
fi