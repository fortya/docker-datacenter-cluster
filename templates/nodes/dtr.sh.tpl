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
  else
    sleep 10s
  fi
done

echo "Wait until the file worker-token.txt is available in s3"
WORKER_TOKEN_FILE_IN_S3=s3://${S3_CONFIGURATIONS_BUCKET_NAME}/worker-token.txt
count=0
while [ $count -lt 1 ]
do
  echo "Checking if worker-token.txt file is ready"
  count=`aws s3 ls $WORKER_TOKEN_FILE_IN_S3 | wc -l`
  if [ $count -lt 1 ]; then
    sleep 10s
  fi
done

echo "Downloading worker-token.txt file"
aws s3 cp $WORKER_TOKEN_FILE_IN_S3 ~/join-token.txt
WORKER_TOKEN=$(cat ~/join-token.txt)

NODE_PUBLIC_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
NODE_PRIVATE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

# Before joining the swarm check if there is an instance of DTR already running
# We cannot do it after joining the swarm because then this node will be routing traffict to UCP and we will get a false possitive...tested
echo "Check if DTR is already up and running"
dtr_running=0
response=$(curl --write-out %{http_code} --silent --output /dev/null ${DTR_PUBLIC_ENDPOINT})
if [ $response == "200" ]; then
  dtr_running=1
fi

echo "Joining swarm"
docker swarm join --token $WORKER_TOKEN ${MANAGER_SWARM_DNS}:2377

echo "Downloading ucp-ca.pem cert"
curl -k https://${UCP_PUBLIC_ENDPOINT}/ca > ucp-ca.pem

# If this is the first DTR node, then we need to install it, otherwise just join existing DTR

if [ $dtr_running == "1" ]; then

  echo "Joining existing DTR"

  docker run -t --rm docker/dtr join \
    --existing-replica-id ${DTR_REPLICA_ID} \
    --ucp-username ${DOCKER_UCP_USERNAME} \
    --ucp-password ${DOCKER_UCP_PASSWORD} \
    --ucp-node $(hostname) \
    --ucp-url https://${UCP_PUBLIC_ENDPOINT} \
    --ucp-ca "$(cat ucp-ca.pem)" \
    --replica-http-port ${DTR_HTTP_PORT} \
    --replica-https-port ${DTR_HTTPS_PORT}

else

  echo "Installing DTR"

  docker run -t --rm docker/dtr install \
    --dtr-external-url https://${DTR_PUBLIC_ENDPOINT} \
    --replica-id ${DTR_REPLICA_ID} \
    --ucp-username ${DOCKER_UCP_USERNAME} \
    --ucp-password ${DOCKER_UCP_PASSWORD} \
    --ucp-node $(hostname) \
    --ucp-url https://${UCP_PUBLIC_ENDPOINT} \
    --ucp-ca "$(cat ucp-ca.pem)" \
    --replica-http-port ${DTR_HTTP_PORT} \
    --replica-https-port ${DTR_HTTPS_PORT}

fi
