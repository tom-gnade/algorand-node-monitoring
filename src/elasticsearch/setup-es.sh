#!/bin/bash
until curl -s http://localhost:9200 > /dev/null; do
    echo 'Waiting for Elasticsearch to start...'
    sleep 1
done

echo 'Setting up Elasticsearch template for new indices...'
curl -XPUT -H "Content-Type: application/json" "http://localhost:9200/_template/default" -d '{
    "index_patterns": ["*"],
    "mappings": {
        "_doc": {  
            "dynamic": true
        }
    },
    "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0,
        "auto_expand_replicas": false
    }
}'

echo 'Setting up index lifecycle policy...'
curl -XPUT -H "Content-Type: application/json" "http://localhost:9200/_ilm/policy/cleanup_policy" -d '{
    "policy": {
        "phases": {
            "hot": {
                "actions": {
                    "rollover": {
                        "max_size": "5GB",
                        "max_age": "7d"
                    }
                }
            },
            "delete": {
                "min_age": "30d",
                "actions": {
                    "delete": {}
                }
            }
        }
    }
}'

echo 'Updating settings for existing indices...'
curl -XPUT -H "Content-Type: application/json" "http://localhost:9200/_all/_settings" -d '{
    "index": {
        "number_of_replicas": 0
    }
}'