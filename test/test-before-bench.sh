#!/bin/bash
set -e

source ./hosts/hosts.txt

# Init test env
docker compose down

# Test after-bench.sh
docker compose up -d deploy-test

sleep 5

bash ./bench/before-bench.sh

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
    ACCESS_LOG_CONTENT=$(ssh -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PUB_KEY[host_idx]} ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]} 'cat /var/log/nginx/access.log')

    if [ -z ${ACCESS_LOG_CONTENT}];then
        echo "Success to init access.log"
    fi
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
    SLOW_QUERY_LOG_CONTENT=$(ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PUB_KEY[host_idx]} ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]} 'cat /var/log/mysql/mysql-slow.log')

    if [ -z ${SLOW_QUERY_LOG_CONTENT}];then
        echo "Success to init slow-query.log"
    fi
done
