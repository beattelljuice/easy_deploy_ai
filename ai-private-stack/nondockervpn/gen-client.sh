#!/bin/bash
# Usage: ./generate_client.sh <clientname>

set -e

CLIENT=$1
if [ -z "$CLIENT" ]; then
  echo "Usage: $0 <clientname>"
  exit 1
fi

EASYRSA_DIR="/etc/openvpn/easy-rsa"
OUTPUT_DIR="/root/client-configs"
SERVER_IP=$(curl -4 ifconfig.me)

cd "$EASYRSA_DIR"

# Generate client key and certificate
./easyrsa gen-req "$CLIENT" nopass
./easyrsa sign-req client "$CLIENT" <<< "yes"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate client .ovpn config
cat > "$OUTPUT_DIR/${CLIENT}.ovpn" <<EOF
client
dev tun
proto udp
remote $SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
key-direction 1
verb 3

<ca>
$(cat "$EASYRSA_DIR/pki/ca.crt")
</ca>
<cert>
$(cat "$EASYRSA_DIR/pki/issued/${CLIENT}.crt")
</cert>
<key>
$(cat "$EASYRSA_DIR/pki/private/${CLIENT}.key")
</key>
<tls-auth>
$(cat /etc/openvpn/ta.key)
</tls-auth>
EOF

echo "Client config generated at: $OUTPUT_DIR/${CLIENT}.ovpn"
