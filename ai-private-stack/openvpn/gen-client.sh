#!/bin/bash
NAME=$1
docker-compose run --rm openvpn easyrsa build-client-full $NAME nopass
docker-compose run --rm openvpn ovpn_getclient $NAME > $NAME.ovpn

# Replace or comment out redirect-gateway if it exists
sed -i 's/^redirect-gateway.*/# redirect-gateway def1/' "$NAME.ovpn"

# Add split-tunnel lines at the end if not already present
if ! grep -q "route-nopull" "$NAME.ovpn"; then
  echo -e "\nroute-nopull" >> "$NAME.ovpn"
#  echo "route 192.168.255.0 255.255.255.0" >> "$NAME.ovpn"
#  echo "route 172.17.0.0 255.255.0.0" >> "$NAME.ovpn"
fi

echo "Generated and modified client config: $NAME.ovpn"
