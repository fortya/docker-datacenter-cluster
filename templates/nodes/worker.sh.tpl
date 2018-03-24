#!/bin/bash

${DOCKER_INSTALL}

NODE_PUBLIC_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
NODE_PRIVATE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

docker swarm join --listen-addr $NODE_PRIVATE_IP:2377 --advertise-addr $NODE_PUBLIC_IP:2377 --token ${UCP_TOKEN} ${UCP_PUBLIC_ENDPOINT}:2377
