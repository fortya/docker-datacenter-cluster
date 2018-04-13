#!/bin/bash

${DOCKER_INSTALL}

# Wait until the file worker-token.txt is available in s3
WORKER_TOKEN_FILE_IN_S3=s3://${S3_CONFIGURATIONS_BUCKET_NAME}/worker-token.txt
count=0
while [ $count -lt 1 ]
do
    count=`aws s3 ls $WORKER_TOKEN_FILE_IN_S3 | wc -l`
    if [ $count -lt 1 ]; then
        sleep 10s
    fi
done

aws s3 cp $WORKER_TOKEN_FILE_IN_S3 ~/join-token.txt
WORKER_TOKEN=$(cat ~/join-token.txt)

NODE_PUBLIC_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
NODE_PRIVATE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

# join swarm
docker swarm join --token $WORKER_TOKEN ${MANAGER_SWARM_DNS}:2377
