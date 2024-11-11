# -~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-+-~-
# !/bin/bash

# note: chmod +x set-permissions.sh && ./set-permissions.sh;

# apply permissions to data directories
chown -R nobody:nogroup ./prometheus/data # Prometheus
chown -R 1000:1000 ./elasticsearch/data #Elasticsearch