#!/bin/bash
set -ex
# This scripts is used to
# - install docker on all hosts, following https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

echo "Start to install docker"

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${ALL_HOSTS_NUMS}; host_idx++));
do
  echo "Install docker on ${ALL_HOSTS[host_idx]}:${ALL_HOSTS_SSH_PORT[host_idx]}"
  ssh -p ${ALL_HOSTS_SSH_PORT[host_idx]} -i ${ALL_HOSTS_SSH_PRIVATE_KEY[host_idx]} \
  ${ALL_HOSTS_SSH_USER[host_idx]}@${ALL_HOSTS[host_idx]} \
  "sudo bash -s" <<'EOF'
set -ex

# Add Docker's official GPG key
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
EOF
done

echo "Finish to install docker"
