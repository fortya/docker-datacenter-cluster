#!/bin/bash

${DOCKER_INSTALL}

NODE_PUBLIC_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
NODE_PRIVATE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

docker swarm join --listen-addr $NODE_PRIVATE_IP:2377 --advertise-addr $NODE_PUBLIC_IP:2377 --token ${UCP_TOKEN} ${UCP_PUBLIC_ENDPOINT}:2377


curl -k https://${UCP_PUBLIC_ENDPOINT}/ca > ucp-ca.pem

docker run -t --rm docker/dtr join \
  --existing-replica-id ${DTR_REPLICA_ID} \
  --ucp-username ${DOCKER_UCP_USERNAME} \
  --ucp-password ${DOCKER_UCP_PASSWORD} \
  --ucp-url https://${UCP_PUBLIC_ENDPOINT} \
  --ucp-ca "$(cat ucp-ca.pem)" \
  --replica-http-port ${DTR_HTTP_PORT} \
  --replica-https-port ${DTR_HTTPS_PORT}
