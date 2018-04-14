apt-get -y update

apt-get install -y apt-transport-https ca-certificates curl software-properties-common awscli

curl -fsSL "${DOCKER_EE_URL}/ubuntu/gpg" | sudo apt-key add -
add-apt-repository "deb [arch=amd64] ${DOCKER_EE_URL}/ubuntu $(lsb_release -cs) ${DOCKER_EE_VERSION}"

apt-get -y update

apt-get install -y docker-ee

apt-get -y update

usermod -aG docker ubuntu

mkdir -p /home/ubuntu/.docker
chown ubuntu:ubuntu /home/ubuntu/.docker -R
chmod g+rwx "/home/ubuntu/.docker" -R