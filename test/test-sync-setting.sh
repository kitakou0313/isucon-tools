#!/bin/bash

source ./hosts/hosts.txt

# Init test env
docker compose down

# Test after-bench.sh
docker compose up -d deploy-test-1 deploy-test-2

sleep 5

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  LOG_DIR="./configs/nginx/${FRONTEND_HOSTS_PATH[host_idx]}"
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir "${LOG_DIR}"
  fi
  cp "./configs/nginx/.gitkeep" "${LOG_DIR}"
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  LOG_DIR="./configs/mysql/${DB_HOSTS_PATH[host_idx]}"
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir "${LOG_DIR}"
  fi
  cp "./configs/mysql/.gitkeep" "${LOG_DIR}"
done

bash ./deploy/sync-settings.sh > /dev/null 2>&1


for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
    ssh -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PRIVATE_KEY[host_idx]} ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]} 'cat /etc/nginx/.gitkeep' | diff -s - "./configs/nginx/${FRONTEND_HOSTS_PATH[host_idx]}/.gitkeep"
    if [ $? -eq 0 ]; then
        echo "Success to sync nginx.cnf."
    elif [ $? -eq 1 ]; then
        echo "Detected nginx.conf content mismatch"
        exit 1
    else
        echo "Script error detected. Can't diff nginx.conf"
        exit 1
    fi
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
    ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]} ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]} 'cat /etc/mysql/.gitkeep' | diff -s - "./configs/mysql/${DB_HOSTS_PATH[host_idx]}/.gitkeep"
    if [ $? -eq 0 ]; then
        echo "Success to sync my.cnf."
    elif [ $? -eq 1 ]; then
        echo "Detected my.cnf content mismatch"
        exit 1
    else
        echo "Script error detected. Can't diff my.cnf"
        exit 1
    fi
done