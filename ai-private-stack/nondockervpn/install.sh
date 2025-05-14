#!/bin/bash

# Move to root project directory
cd ~/ai-private-stack/nondockervpn

# Prepare permissions
chmod +x *.sh

# Deploy VPN
./install-vpn.sh
./generate_client.sh default-client

# Deploy docker + AI
./install-docker.sh