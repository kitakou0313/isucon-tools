#!/bin/bash

source ./hosts/hosts.txt

# Init test env
docker compose down

# Test after-bench.sh
docker compose up -d deploy-test-1 deploy-test-2

sleep 5

# deploy-test-1/2 are rebuilt from scratch on demand, which regenerates their
# SSH host keys each time. Refresh known_hosts so deploy/deloy.sh's plain ssh
# calls don't get rejected by a stale host key from a previous build.
for ((host_idx=0; host_idx<${ALL_HOSTS_NUMS}; host_idx++));
do
    ssh-keygen -R "[${ALL_HOSTS[host_idx]}]:${ALL_HOSTS_SSH_PORT[host_idx]}" > /dev/null 2>&1
    ssh-keyscan -p ${ALL_HOSTS_SSH_PORT[host_idx]} ${ALL_HOSTS[host_idx]} >> ~/.ssh/known_hosts 2>/dev/null
done

bash ./deploy/deloy.sh > /dev/null

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do
    ssh -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]} ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]} 'cat /root/webapp/.gitkeep' | diff -s - ./webapp/.gitkeep
    if [ $? -eq 0 ]; then
        echo "Success to deploy."
    elif [ $? -eq 1 ]; then
        echo "Detected web app bin content mismatch"
        exit 1
    else
        echo "Script error detected. Can't diff sample web app"
        exit 1
    fi
done