#!/bin/bash
NAME=$1
docker-compose run --rm openvpn easyrsa build-client-full $NAME nopass
docker-compose run --rm openvpn ovpn_getclient $NAME > $NAME.ovpn
