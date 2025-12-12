#!/usr/bin/env bash
set -e

# ===================================
# Resolve script & project root
# ===================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==========================
# Configuration
# ==========================
PAYARA_DOMAIN_PATH="$SCRIPT_DIR/software/payara6/glassfish/domains/domain1"
CONFIG_DIR="$PAYARA_DOMAIN_PATH/config"
KEYSTORE_NAME="payara-keystore.jks"
ALIAS="payara"
PASSWORD="changeit"

TARGET="${1:-localhost}"

echo "SSL Setup for: $TARGET"
echo "Payara config: $CONFIG_DIR"
echo

# ==========================
# Check dependencies
# ==========================
for cmd in mkcert openssl keytool; do
  command -v $cmd >/dev/null || { echo "$cmd missing"; exit 1; }
done

[ -d "$CONFIG_DIR" ] || { echo "Payara config directory not found"; exit 1; }

# ==========================
# mkcert CA
# ==========================
mkcert -install

# ==========================
# Certificate
# ==========================
mkcert "$TARGET"

CERT_SAFE="${TARGET//./_}"

# ==========================
# PEM → PKCS12
# ==========================
openssl pkcs12 -export \
  -in "$TARGET.pem" \
  -inkey "$TARGET-key.pem" \
  -out "$CERT_SAFE.p12" \
  -name "$ALIAS" \
  -passout pass:$PASSWORD

# ==========================
# PKCS12 → JKS
# ==========================
keytool -importkeystore \
  -srckeystore "$CERT_SAFE.p12" \
  -srcstoretype PKCS12 \
  -srcstorepass $PASSWORD \
  -destkeystore "$KEYSTORE_NAME" \
  -deststoretype JKS \
  -deststorepass $PASSWORD \
  -destkeypass $PASSWORD \
  -alias "$ALIAS" \
  -noprompt

# ==========================
# Copy to Payara
# ==========================
cp "$KEYSTORE_NAME" "$CONFIG_DIR/"

echo "Done!"
echo "➡ $CONFIG_DIR/$KEYSTORE_NAME"
