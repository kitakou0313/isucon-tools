#!/bin/bash
set -e

source ./hosts/hosts.txt

# Init test env
docker compose down deploy-test

# Test after-bench.sh
docker compose up -d deploy-test

sleep 5

bash ./bench/after-bench.sh

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
    diff -s deploy-test/access.log.example kataribe/webserver-log/access.log > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Success to fetch access.log"
    elif [ $? -eq 1 ]; then
        echo "Script error detected. Can't fetch access.log"
        exit 1
    fi
done

# for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
# do
#   # Fetch mysql slowquery-log
#   echo "Fetch mysql slow query log from ${DB_HOSTS[host_idx]}:${DB_HOSTS_SSH_PORT[host_idx]}"
#   rsync -e "ssh -p ${DB_HOSTS_SSH_PORT[host_idx]}" -av root@${DB_HOSTS[host_idx]}:/var/log/mysql/mysql-slow.log ./mysql-slowquery/mysql-slowquery-log/mysql-slow.log
# done

# for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
# do 
#   # Fetch pprof logs
#   echo "Fetch pprof log from ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
#   rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]}" -av root@${APP_HOSTS[host_idx]}:/home/root/webapp/cpu.pprof ./pprof/profilefiles/cpu.pprof

# done

docker compose down deploy-test