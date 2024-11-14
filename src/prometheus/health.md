# Monitoring Stack Health Checks

Quick reference guide for checking the health of each service in the Algorand monitoring stack.

## Algorand Node
```bash
# Node status via goal
docker exec algomon-algonode goal node status -d /var/lib/algorand

# API status with fixed token
curl -s -H "X-Algo-API-Token: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" \
    http://localhost:8080/v2/status | jq

# Recent logs
docker logs algomon-algonode --tail 100
```

## Elasticsearch
```bash
# Cluster health
curl -s http://localhost:9200/_cluster/health?pretty

# List indices
curl -s http://localhost:9200/_cat/indices?v

# Recent Algorand logs
curl -s -X GET "http://localhost:9200/algorand-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 20,
  "sort": [{ "@timestamp": { "order": "desc" } }],
  "query": { "match_all": {} }
}'

# Recent errors
curl -s -X GET "http://localhost:9200/algorand-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match": { "level": "error" } },
  "size": 20,
  "sort": [{ "@timestamp": { "order": "desc" } }]
}'
```

## Prometheus
```bash
# Health check
curl -s http://localhost:9090/-/healthy

# List targets and their status
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {target: .labels.instance, health: .health}'
```

## Custom Metrics Exporter
```bash
# Health endpoint
curl -s http://localhost:9102/health

# Metrics endpoint
curl -s http://localhost:9101/metrics | grep algorand
```

## Grafana
```bash
# Health check
curl -s http://localhost:3000/api/health

# List data sources (default admin/admin)
curl -s -u admin:admin http://localhost:3000/api/datasources
```

## Quick Status Script
```bash
#!/bin/bash

echo "=== Stack Health Check ==="

echo -e "\n1. Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}"

echo -e "\n2. Algorand Node:"
docker exec algomon-algonode goal node status -d /var/lib/algorand | grep -E "Sync Time:|Last committed block:"

echo -e "\n3. Elasticsearch:"
curl -s http://localhost:9200/_cluster/health?pretty | grep status

echo -e "\n4. Prometheus Targets:"
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {target: .labels.instance, health: .health}'

echo -e "\n5. Port Status:"
for port in 8080 9200 9090 9100 9101 9102 3000; do
    nc -z localhost $port 2>/dev/null && echo "Port $port: OPEN" || echo "Port $port: CLOSED"
done
```

## Service Ports

| Service | Port |
|---------|------|
| Algorand API | 8080 |
| Elasticsearch | 9200 |
| Prometheus | 9090 |
| Node Exporter | 9100 |
| Custom Metrics | 9101 |
| Health API | 9102 |
| Grafana | 3000 |