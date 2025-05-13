#!/bin/bash
#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <client-name>"
  exit 1
fi

CLIENT_NAME=$1
OVPN_DIR="./openvpn-data"

echo "➡️  Generating client profile for: $CLIENT_NAME"

# Build client cert (no password)
docker run --rm -v "${PWD}/openvpn-data:/etc/openvpn" kylemanna/openvpn \
  easyrsa build-client-full "$CLIENT_NAME" nopass

# Generate the .ovpn file
docker run --rm -v "${PWD}/openvpn-data:/etc/openvpn" kylemanna/openvpn \
  ovpn_getclient "$CLIENT_NAME" > "${CLIENT_NAME}.ovpn"

echo "✅ Client profile saved to: ${CLIENT_NAME}.ovpn"


# Replace or comment out redirect-gateway if it exists
sed -i 's/^redirect-gateway.*/# redirect-gateway def1/' "$CLIENT_NAME.ovpn"

# Add split-tunnel lines at the end if not already present
if ! grep -q "route-nopull" "$CLIENT_NAME.ovpn"; then
  echo -e "\nroute-nopull" >> "$CLIENT_NAME.ovpn"
#  echo "route 192.168.255.0 255.255.255.0" >> "$NAME.ovpn"
#  echo "route 172.17.0.0 255.255.0.0" >> "$NAME.ovpn"
fi

echo "Generated and modified client config: $CLIENT_NAME.ovpn"
