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

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
    diff -s deploy-test/mysql-slow.log.example mysql-slowquery/mysql-slowquery-log/mysql-slow.log > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Success to fetch MySQL slow query log."
    elif [ $? -eq 1 ]; then
        echo "Script error detected. Can't fetch slow query log"
        exit 1
    fi
done

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do 
    diff -s deploy-test/cpu.pprof.example pprof/profilefiles/cpu.pprof > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Success to fetch cpu.pprof."
    elif [ $? -eq 1 ]; then
        echo "Script error detected. Can't fetch slow query log"
        exit 1
    fi
done

docker compose down deploy-test