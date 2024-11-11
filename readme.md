# AlgoMon - Algorand Node Monitoring

AlgoMon is an integrated monitoring solution for Algorand nodes that combines Prometheus, Elasticsearch, and Grafana to provide comprehensive monitoring, alerting, and visualization capabilities.

## Features

- Real-time node monitoring with Prometheus
- Historical data storage with Elasticsearch
- Beautiful dashboards with Grafana
- Automatic data collection from Algorand node APIs
- Cross-platform support (Linux, Windows, macOS)

## System Requirements

- Docker and Docker Compose
- Docker Desktop (Windows/macOS)
- 8GB RAM minimum 
- 50GB storage minimum (SSD strongly recommended)
- Available ports:
  - 3000 (Grafana)
  - 9090 (Prometheus)
  - 9200 (Elasticsearch)
  - 8080 (Algorand API)
  - 7833 (Algorand KMD API)

## Quick Start

1. Create installation directory:

Linux/macOS:
```bash
mkdir algomon && cd algomon
```

Windows CMD:
```cmd
mkdir algomon && cd algomon
```

Windows PowerShell:
```powershell
New-Item -ItemType Directory -Name algomon; Set-Location algomon
```

2. Download configuration files:

Linux/macOS:
```bash
curl -L https://api.github.com/repos/tom-gnade/algorand-node-monitoring/tarball/main | tar xz --wildcards --strip=2 "*/src"
```

Windows CMD:
```cmd
curl -L https://api.github.com/repos/tom-gnade/algorand-node-monitoring/tarball/main | tar xz --wildcards --strip=2 "*/src"
```

Windows PowerShell:
```powershell
Invoke-WebRequest -Uri https://api.github.com/repos/tom-gnade/algorand-node-monitoring/tarball/main -OutFile temp.tar.gz
tar xz --wildcards --strip=2 "*/src" -f temp.tar.gz
Remove-Item temp.tar.gz
```

3. Set up permissions:

Linux:
```bash
sudo ./setup-permissions-linux.sh
```

Windows CMD/PowerShell (run as Administrator):
```cmd
setup-permissions-windows.bat
```

macOS:
```bash
sudo ./setup-permissions-mac.sh
```

4. Build and start services:

Linux/macOS/Windows:
```bash
# Build all containers
docker compose build

# Start services
docker compose up -d
```

5. Access the Grafana dashboard at `http://localhost:3000`

## Components

- **Algorand Node**: Participates in the Algorand network and provides API endpoints
- **Prometheus**: Collects and stores metrics from the node
- **Elasticsearch**: Stores historical data and API responses
- **Grafana**: Provides visualization and dashboards
- **API Caller**: Automated service that collects data from Algorand APIs

## Documentation

- [Installation Guide](docs/install.md) - Detailed installation and configuration instructions
- [Configuration Guide](docs/config.md) - Advanced configuration options
- [Architecture](docs/architecture.md) - System architecture and component details
- [Algorand Node Documentation](https://developer.algorand.org/docs/run-a-node/setup/types)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.