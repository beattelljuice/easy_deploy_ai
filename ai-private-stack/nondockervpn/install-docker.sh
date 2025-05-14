sudo apt update
sudo apt install -y docker.io docker-compose git curl
sudo systemctl enable docker
sudo usermod -aG docker $USER
#newgrp docker  # apply group change immediately

chmod +x pull-model.sh
docker-compose up -d

./pull-model.sh qwen3:1.7b