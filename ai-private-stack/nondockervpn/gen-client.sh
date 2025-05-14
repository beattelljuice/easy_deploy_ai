#!/bin/bash
set -e

CLIENT=$1
if [ -z "$CLIENT" ]; then
echo "Usage: $0 <clientname>"
exit 1
fi

cd /etc/openvpn/easy-rsa
./easyrsa gen-req "$CLIENT" nopass
./easyrsa sign-req client "$CLIENT" <<< "yes"

mkdir -p /root/client-configs
cat > /root/client-configs/"$CLIENT".ovpn <<EOF
client
dev tun
proto udp
remote $(curl -s ifconfig.me) 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
key-direction 1
verb 3

<ca> $(cat pki/ca.crt) </ca> <cert> $(cat pki/issued/"$CLIENT".crt) </cert> <key> $(cat pki/private/"$CLIENT".key) </key> <tls-auth> $(cat ta.key) </tls-auth> EOF
echo "Client config generated at: /root/client-configs/${CLIENT}.ovpn"
