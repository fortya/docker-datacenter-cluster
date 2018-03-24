#!/bin/bash

${DOCKER_INSTALL}

NODE_PUBLIC_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)


docker container run --rm -t --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:${DOCKER_UCP_VERSION} install \
  --host-address $NODE_PUBLIC_IP:2377 \
  --admin-username ${DOCKER_UCP_USERNAME} \
  --admin-password ${DOCKER_UCP_PASSWORD} \
  --san ${UCP_PUBLIC_ENDPOINT} \
  --san ${ELB_MASTER_NODES} \ 
  --san ${ELB_MANAGER_NODES} 

sleep 180

curl -k https://localhost/ca > ucp-ca.pem

docker run -t --rm docker/dtr install \
  --dtr-external-url https://${DTR_PUBLIC_ENDPOINT} \
  --ucp-username ${DOCKER_UCP_USERNAME} \
  --ucp-password ${DOCKER_UCP_PASSWORD} \
  --ucp-url https://${UCP_PUBLIC_ENDPOINT} \
  --ucp-ca "$(cat ucp-ca.pem)" \
  --replica-http-port ${DTR_HTTP_PORT} \
  --replica-https-port ${DTR_HTTPS_PORT} 
