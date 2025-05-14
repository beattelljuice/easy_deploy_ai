#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
echo "Please run as root"
exit
fi

echo "Updating system..."
apt update && apt upgrade -y

echo "Installing OpenVPN and Easy-RSA..."
apt install -y openvpn easy-rsa

echo "Setting up Easy-RSA PKI..."
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
echo -ne "\n" | ./easyrsa build-ca nopass
./easyrsa gen-req server nopass
./easyrsa sign-req server server <<< "yes"
./easyrsa gen-dh
openvpn --genkey --secret ta.key
./easyrsa gen-crl

echo "Copying server certificates and keys..."
cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem ta.key /et                                           c/openvpn/
cp pki/crl.pem /etc/openvpn/

echo "Writing server configuration..."
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
crl-verify crl.pem
topology subnet
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-CBC
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

echo "Enabling IP forwarding..."
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

echo "Configuring NAT..."
IPTABLES_RULE="iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $(ip route get 8                                           .8.8.8 | awk '{print $5; exit}') -j MASQUERADE"
grep -qF "$IPTABLES_RULE" /etc/rc.local || echo "$IPTABLES_RULE" >> /etc/rc.loca                                           l
chmod +x /etc/rc.local
$IPTABLES_RULE

echo "Starting and enabling OpenVPN..."
systemctl enable openvpn@server
systemctl start openvpn@server

echo "Done! Run ./generate_client.sh <clientname> to create client configs."
