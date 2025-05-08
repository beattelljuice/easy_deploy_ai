cd ~/ai-private-stack

sudo apt update
sudo apt install -y docker.io docker-compose git curl
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker  # apply group change immediately

chmod +x pull-model.sh
chmod +x openvpn/gen-client.sh

# Get the public IP address
PUBLIC_IP=$(curl -s ifconfig.me)

# Check if IP was retrieved
if [ -z "$PUBLIC_IP" ]; then
  echo "Failed to retrieve public IP address."
  exit 1
fi

echo "Using public IP: $PUBLIC_IP"

# Run OpenVPN configuration
docker-compose run --rm openvpn ovpn_genconfig -u udp://$PUBLIC_IP
docker-compose run --rm openvpn ovpn_initpki
./openvpn/gen-client.sh
docker-compose up -d
