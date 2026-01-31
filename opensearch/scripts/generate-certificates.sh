#!/bin/bash
# This script generates self-signed certificates for OpenSearch cluster
set -e

CERT_DIR="./certificates"
COUNTRY="CA"
STATE="Ontario"
CITY="Toronto"
ORG="Homelab"
UNIT="Opensearch"
DAYS_VALID=3650

echo "Creating certificates directory…"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Generate Root CA

echo "Generating Root CA…"
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -out root-ca.pem -days $DAYS_VALID -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$UNIT/CN=ROOT"

# Generate Admin Certificate

echo "Generating Admin Certificate…"
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -out admin.csr -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$UNIT/CN=admin"
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem -days $DAYS_VALID

# Generate Node Certificate

echo "Generating Node Certificate…"
openssl genrsa -out node1-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node1-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node1-key.pem
openssl req -new -key node1-key.pem -out node1.csr -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$UNIT/CN=node1"

# Create extension file for SAN

cat > node1.ext << EOF
subjectAltName = DNS:opensearch-node1,DNS:localhost,IP:127.0.0.1
EOF

openssl x509 -req -in node1.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node1.pem -days $DAYS_VALID -extfile node1.ext

# Generate Client Certificate (optional but included)

echo "Generating Client Certificate…"
openssl genrsa -out client-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in client-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out client-key.pem
openssl req -new -key client-key.pem -out client.csr -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/OU=$UNIT/CN=client"
openssl x509 -req -in client.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out client.pem -days $DAYS_VALID

# Clean up temporary files

echo "Cleaning up temporary files…"
rm -f admin-key-temp.pem node1-key-temp.pem client-key-temp.pem
rm -f admin.csr node1.csr client.csr node1.ext

# Set appropriate permissions

chmod 644 *.pem
chmod 600 *-key.pem

echo "Certificates generated successfully in $CERT_DIR"
echo ""
echo "Generated files:"
ls -lh

cd ..
