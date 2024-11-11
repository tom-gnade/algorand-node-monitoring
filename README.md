# algorand-monitoring

## Monitoring Your Algorand Node

This repository contains all of the files required to run a Dockerized Algorand node monitoring stack. The Algorand node is optional. Some configuration is needed to point to one or more Algorand nodes, including the optional Dockerized "one click" node. The monitoring toolset includes:
- Prometheus container - stores time-series data from the metrics endpoint
- Elasticsearch container - stores telemetry and optional REST API endpoint response data
- Api Caller container - calls REST APIs and stores the response in Elasticsearch
- Grafana container - presents a graphical user interface to monitor node metrics and telemetry
- Algorand container - an optional "one click node" with metrics and telemetry stored by default

The Docker install has been tested on Ubuntu 23.10. It should run on any operating system with Docker installed, including Windows, MacOS, and Linux. The included dashboard presents information about your node host or hosts, including resource utilization and key metrics related to the Algorand blockchain. The materials in this repository are open-source and free to use or modify.

Happy node running!

## Install
create a target folder on your disk, and navigate to that location
install docker compose
clone git repository to taret folder:
   curl -L https://api.github.com/repos/tom-gnade/algorand-node-monitoring/tarball/main | tar xz --wildcards --strip=2 "*/src"
assign permissions to specific folders for container persistent storage
   In Linux:
      sudo chown -R 1000:1000 ./elasticsearch/data
      chown -R 65534:65534 ./prometheus/data
      chown -R 472:472 ./grafana
   In Windows:
      PowerShell to assign permissions?
   In MacOS:
      Not tested.
docker compose build in root folder with compose.yaml
docker compose up -d to run containers


## Key Components

This solution is a monitoring and analytics stack for Algorand nodes, called "AlgoMon". Here's the key components:

### Algorand Node (algomon-algonode)

Runs the main Algorand node using the official algod image
Configured for mainnet with fast catchup enabled
Exposes API endpoints on port 8080
Has KMD (Key Management Daemon) enabled
Uses custom logging and node configuration
Optional - you do not have to run a containerized node

### Prometheus (algomon-prometheus)

Metrics collection system
Scrapes metrics every 15 seconds
Currently configured to collect from:

Prometheus itself (localhost:9090)
Node metrics (localhost:9100)

### Elasticsearch (algomon-elasticsearch)

Running version 6.8.23 for compatibility reasons
Single node setup
Security features disabled
Used for storing API call data and logs

### API Caller (algomon-api-caller)

Custom Ubuntu-based container
Runs on a cron schedule to poll Algorand node APIs
Calls both algod and kmd endpoints
Stores responses in Elasticsearch
Uses a structured YAML configuration for endpoints and origins

### Grafana (algomon-grafana)

Visualization platform
Configured with:

Prometheus datasource
Elasticsearch datasource
Custom dashboards
Anonymous access enabled
Dark theme default
Email notifications via Gmail
Geospatial mapping capability (has a node location in Maryland)

## Key Features:

Open-source and free implementation using tools aligned with Algorand implementation.

Cross-platform compatibility using Docker Compose:
   All services use host networking mode
   Health checks implemented for all services
   Services have proper startup dependencies
   Data persistence through Docker volumes
   Automated metrics collection and API polling
   Security tokens configured for Algorand APIs

Designed to:
   Run an Algorand node
   Collect performance metrics
   Monitor API endpoints
   Store historical data
   Visualize everything through Grafana dashboards