#!/bin/bash

${DOCKER_INSTALL}

NODE_PUBLIC_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
NODE_PRIVATE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

# We need to check whether this is the first manager or no
# If this is the first manager, then we need to install it, otherwise just join
response=$(curl --write-out %{http_code} --silent --output /dev/null ${UCP_PUBLIC_ENDPOINT})
if [ $response == "200" ]; then
  echo "Join existing swarm"
  # Download MANAGER_TOKEN
  # Just in case wait until the file manager-token.txt is available in s3
  MANAGER_TOKEN_FILE_IN_S3=s3://${S3_CONFIGURATIONS_BUCKET_NAME}/manager-token.txt
  count=0
  while [ $count -lt 1 ]
  do
    count=`aws s3 ls $MANAGER_TOKEN_FILE_IN_S3 | wc -l`
    if [ $count -lt 1 ]; then
      sleep 10s
    fi
  done

  aws s3 cp $MANAGER_TOKEN_FILE_IN_S3 ~/join-token.txt
  MANAGER_TOKEN=$(cat ~/join-token.txt)

  # join swarm
  docker swarm join --token $MANAGER_TOKEN ${MANAGER_SWARM_DNS}:2377
    
  docker container run --rm -t --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    docker/ucp:${DOCKER_UCP_VERSION} join \
    --replica \
    --host-address $NODE_PRIVATE_IP \
    --admin-username ${DOCKER_UCP_USERNAME} \
    --admin-password ${DOCKER_UCP_PASSWORD} \
    --san ${UCP_PUBLIC_ENDPOINT} \
    --san ${ELB_MANAGER_NODES}

else

  echo "This should be the first manager"
  # Install ddc
  docker container run --rm -t --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    docker/ucp:${DOCKER_UCP_VERSION} install \
    --host-address $NODE_PRIVATE_IP \
    --admin-username ${DOCKER_UCP_USERNAME} \
    --admin-password ${DOCKER_UCP_PASSWORD} \
    --controller-port ${UCP_PORT}
    --san ${UCP_PUBLIC_ENDPOINT} \
    --san ${ELB_MANAGER_NODES} 

  # Upload manager and worker tokens to S3
  docker swarm join-token -q worker > ~/worker-token.txt
  aws s3 cp ~/worker-token.txt s3://${S3_CONFIGURATIONS_BUCKET_NAME}/worker-token.txt --acl bucket-owner-full-control

  docker swarm join-token -q manager > ~/manager-token.txt
  aws s3 cp ~/manager-token.txt s3://${S3_CONFIGURATIONS_BUCKET_NAME}/manager-token.txt --acl bucket-owner-full-control
fi
