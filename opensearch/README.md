# HomeLab -> OpenSearch

Local OpenSearch environment using Docker Compose 


## Courtesy

[Claude](https://claude.ai/new)

[CoPilot](https://copilot.cloud.microsoft/)

[PKI Authentication in OpenSearch](https://opster.com/guides/opensearch/opensearch-security/pki-authentication/)


## Installation procedure

1. Run following command from base directory:

```bash
# Rename environment file to .env
mv env.rename .env

# Generate self-signed certificates
scripts/generate-certificates.sh

# Generate encrypted admin password and update config/node/internal_users.yml file if password is changed
python3 opensearch/scripts/bcrypt-password.py

# Run docker 
docker compose up -d

# Wait for all containers to start

# Set admin password in environment variable
export PASSWORD=<admin password>

# Create index and validate
curl -X PUT --cacert certificates/root-ca.pem -u admin:$PASSWORD -H "Content-Type: application/json" --data-binary @./scripts/create-index.json https://localhost:9200/logs-index

curl --cacert certificates/root-ca.pem -u admin:$PASSWORD "https://localhost:9200/logs-index/_search?pretty"

# Send logs using admin password or client certificate
curl -X PUT "https://localhost:9200/_bulk" --cacert certificates/root-ca.pem -u admin:$PASSWORD -H "Content-Type: application/x-ndjson" --data-binary @./scripts/send-logs.json

curl -k --location --request POST 'https://localhost:9200/logs-index/_doc?pretty' --header 'Content-Type: application/json' --cert certificates/client.pem --key certificates/client-key.pem --data-raw '{"@timestamp": "2026-01-24T13:00:00Z", "level": "ERROR", "message": "Log 3" }'

# Login to http://localhost:5601/ from browser and create a new index pattern 'logs-index*'

# Go to Discover section and view the logs 

```