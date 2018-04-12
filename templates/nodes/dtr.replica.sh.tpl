#!/bin/bash

${DOCKER_INSTALL}

echo "Wait until we have UCP running"
count=0
while [ $count -lt 1 ]
do
  echo "Checking if UCP is up and running"
  response=$(curl --write-out %{http_code} --silent --output /dev/null https://${UCP_PUBLIC_ENDPOINT})
  if [ $response == "200" ]; then
    count=1
  fi
done

echo "Wait until the file worker-token.txt is available in s3"
WORKER_TOKEN_FILE_IN_S3=s3://${S3_CONFIGURATIONS_BUCKET_NAME}/worker-token.txt
count=0
while [ $count -lt 1 ]
do
  echo "Checking if worker-token.txt file is ready"
  count=`aws s3 ls $WORKER_TOKEN_FILE_IN_S3 | wc -l`
done

echo "Downloading worker-token.txt file"
aws s3 cp $WORKER_TOKEN_FILE_IN_S3 ~/join-token.txt
WORKER_TOKEN=$(cat ~/join-token.txt)

echo "Joining swarm"
docker swarm join --listen-addr $NODE_PRIVATE_IP:2377 --advertise-addr $NODE_PRIVATE_IP:2377 --token $WORKER_TOKEN ${MANAGER_SWARM_DNS}:2377

NODE_PUBLIC_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
NODE_PRIVATE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

echo "Downloading upc-ca.pem cert"
curl -k https://${UCP_PUBLIC_ENDPOINT}/ca > ucp-ca.pem

# We need to check whether this is the first dtr node or no
# If this is the first dtr node, then we need to install it, otherwise just join
echo "Check if DTR is already up and running"

response=$(curl --write-out %{http_code} --silent --output /dev/null ${DTR_PUBLIC_ENDPOINT})
if [ $response == "200" ]; then

  docker run -t --rm docker/dtr join \
    --existing-replica-id ${DTR_REPLICA_ID} \
    --ucp-username ${DOCKER_UCP_USERNAME} \
    --ucp-password ${DOCKER_UCP_PASSWORD} \
    --ucp-url https://${UCP_PUBLIC_ENDPOINT} \
    --ucp-ca "$(cat ucp-ca.pem)" \
    --replica-http-port ${DTR_HTTP_PORT} \ 
    --replica-https-port ${DTR_HTTPS_PORT}

else

  docker run -t --rm docker/dtr install \
    --dtr-external-url https://${DTR_PUBLIC_ENDPOINT} \
    --replica-id ${DTR_REPLICA_ID}
    --ucp-username ${DOCKER_UCP_USERNAME} \
    --ucp-password ${DOCKER_UCP_PASSWORD} \
    --ucp-url https://${UCP_PUBLIC_ENDPOINT} \
    --ucp-ca "$(cat ucp-ca.pem)" \
    --replica-http-port ${DTR_HTTP_PORT} \
    --replica-https-port ${DTR_HTTPS_PORT}
    
fi