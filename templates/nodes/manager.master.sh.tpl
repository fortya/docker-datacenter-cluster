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
  --san ${ELB_MANAGER_NODES} 

curl -k https://localhost/ca > ucp-ca.pem

docker run -t --rm docker/dtr install \
  --dtr-external-url https://${DTR_PUBLIC_ENDPOINT} \
  --ucp-username ${DOCKER_UCP_USERNAME} \
  --ucp-password ${DOCKER_UCP_PASSWORD} \
  --ucp-url https://$NODE_PUBLIC_IP \
  --ucp-ca "$(cat ucp-ca.pem)" \
  --replica-http-port ${DTR_HTTP_PORT} \
  --replica-https-port ${DTR_HTTPS_PORT} \
  --replica-id ${DTR_REPLICA_ID}

docker swarm join-token -q worker > ~/worker-token.txt
aws s3 cp ~/worker-token.txt s3://${S3_CONFIGURATIONS_BUCKET_NAME}/worker-token.txt --acl bucket-owner-full-control

docker swarm join-token -q manager > ~/manager-token.txt
aws s3 cp ~/manager-token.txt s3://${S3_CONFIGURATIONS_BUCKET_NAME}/manager-token.txt --acl bucket-owner-full-control