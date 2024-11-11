# AlgoMon Installation Guide

## Prerequisites

### System Requirements
- Docker and Docker Compose
- 8GB RAM minimum
- 50GB SSD storage minimum for mainnet node (SSD strongly recommended)
  - SSD storage is highly recommended for optimal performance of Elasticsearch and the Algorand node
  - HDD storage may result in significantly degraded performance
- Available ports:
  - 3000 (Grafana)
  - 9090 (Prometheus)
  - 9200 (Elasticsearch)
  - 8080 (Algorand node API)
  - 7833 (Algorand KMD API)

### Required Software
- Docker and Docker Compose
- Git (optional)
- Curl
- Administrative/sudo access
- tar (Windows users may need to install this separately)

## Installation Steps

### 1. Create Installation Directory

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

### 2. Download Configuration Files

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

### 3. Set Up Permissions

Each Docker container in AlgoMon runs as a specific service user for security purposes:
- Elasticsearch runs as the 'elasticsearch' user
- Prometheus runs as the 'nobody' user
- Grafana runs as the 'grafana' user

For data persistence to work correctly, the folders on your host machine need to match these container permissions. The permission scripts handle this automatically for your operating system:

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

Why are permissions needed?
- The containers need to read and write data to these folders on your host machine
- Without correct permissions, the containers might fail to start or be unable to save data
- These permission settings ensure data persistence across container restarts
- The scripts are designed to set the correct permissions for each operating system's requirements

Note: You may need administrator/sudo access to set these permissions correctly.

### 4. Build and Start Services

All platforms:
```bash
# Build all containers
docker compose build

# Start services
docker compose up -d
```

### 5. Verify Installation

1. Check container status:

Linux/macOS:
```bash
docker compose ps
```

Windows CMD:
```cmd
docker compose ps
```

Windows PowerShell:
```powershell
docker compose ps
```

All containers should show as "healthy" in their status.

2. Verify service endpoints:
- Grafana: http://localhost:3000 (default password: AlgoMon)
- Prometheus: http://localhost:9090
- Elasticsearch: http://localhost:9200
- Algorand API: http://localhost:8080/health

### 6. Initial Access

1. Access Grafana:
   - URL: http://localhost:3000
   - Default password: AlgoMon
   - The default dashboard will load automatically

2. Verify data collection:
   - Check Prometheus targets are up
   - Verify Elasticsearch indices are being created
   - Confirm Grafana dashboard is showing data

## Troubleshooting

### Common Issues

1. Permission Errors
   ```
   Error: permission denied while trying to connect to the Docker daemon socket
   ```
   Linux solution:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```
   Windows solution:
   - Run PowerShell or CMD as Administrator

2. Port Conflicts
   ```
   Error: Ports are not available: listen tcp 0.0.0.0:3000: bind: address already in use
   ```
   Check for services using required ports:

   Linux/macOS:
   ```bash
   sudo lsof -i :3000
   sudo lsof -i :9090
   sudo lsof -i :9200
   ```

   Windows CMD:
   ```cmd
   netstat -ano | findstr :3000
   netstat -ano | findstr :9090
   netstat -ano | findstr :9200
   ```

   Windows PowerShell:
   ```powershell
   Get-NetTCPConnection -LocalPort 3000,9090,9200
   ```

3. Resource Issues
   ```
   Error: Elasticsearch exited with code 137
   ```
   - Ensure sufficient system resources
   - Check system memory and disk space
   - Adjust Elasticsearch JVM heap size if needed

4. Data Persistence
   ```
   Error: cannot create directory '/var/lib/grafana': Permission denied
   ```
   - Verify directory permissions
   - Rerun the permissions script
   - Check Docker volume mounts

### Checking Logs

View logs for specific services:

Linux/macOS/Windows:
```bash
docker compose logs [service-name]
```

View logs for all services:
```bash
docker compose logs
```

### Restarting Services

Restart a specific service:
```bash
docker compose restart [service-name]
```

Restart all services:
```bash
docker compose restart
```

### Complete Reset

Linux/macOS:
```bash
docker compose down -v
rm -rf ./*/data
./setup-permissions-linux.sh    # or setup-permissions-mac.sh for macOS
docker compose up -d
```

Windows CMD:
```cmd
docker compose down -v
rmdir /s /q elasticsearch\data prometheus\data grafana\data
setup-permissions-windows.bat
docker compose up -d
```

Windows PowerShell:
```powershell
docker compose down -v
Remove-Item -Recurse -Force elasticsearch\data, prometheus\data, grafana\data
.\setup-permissions-windows.bat
docker compose up -d
```

## Storage Considerations

### SSD vs HDD
AlgoMon strongly recommends using SSD storage for optimal performance:
- Elasticsearch performs many random reads/writes and benefits significantly from SSD
- Algorand node catchup and synchronization is much faster on SSD
- Prometheus metrics storage performs better on SSD
- Overall system responsiveness is improved with SSD storage

### Storage Location
Choose a location with:
- Sufficient free space (50GB minimum)
- SSD storage preferred
- Proper read/write permissions
- Regular backup capability

## Support

For additional support:
1. Check the [Configuration Guide](config.md)
2. Submit an issue on GitHub
3. Check the Docker logs for specific error messages

For more detailed configuration options, see [config.md](config.md).