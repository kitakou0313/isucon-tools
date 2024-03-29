#!/bin/bash

source ./hosts/hosts.txt

# Init test env
docker compose down

# Test after-bench.sh
docker compose up -d deploy-test-1 deploy-test-2

sleep 5

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
    LOG_DIR="alp/log/${FRONTEND_HOSTS_PATH[host_idx]}"
    if [ -d "${LOG_DIR}" ]; then
        rm -rf "${LOG_DIR}"
    fi
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
    LOG_DIR="mysql-slowquery/mysql-slowquery-log/${DB_HOSTS_PATH[host_idx]}"
    if [ -d "${LOG_DIR}" ]; then
        rm -rf "${LOG_DIR}"
    fi
done

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do
    LOG_DIR="pprof/profilefiles/${APP_HOSTS_PATH}"
    if [ -d "${LOG_DIR}" ]; then
        rm -rf "${LOG_DIR}"
    fi
done

bash ./bench/after-bench.sh > /dev/null 2>&1

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
    diff -s deploy-test/access.log.example alp/log/${FRONTEND_HOSTS_PATH[host_idx]}/access.log.* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Success to fetch access.log"
    elif [ $? -eq 1 ]; then
        echo "Script error detected. Can't fetch access.log"
        exit 1
    else
        echo "Fail to exec diff command to access.log"
        exit 1
    fi
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
    diff -s deploy-test/mysql-slow.log.example mysql-slowquery/mysql-slowquery-log/${DB_HOSTS_PATH[host_idx]}/mysql-slow.log.* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Success to fetch MySQL slow query log."
    elif [ $? -eq 1 ]; then
        echo "Script error detected. Can't fetch slow query log"
        exit 1
    else
        echo "Fail to exec diff command to slow query log"
        exit 1
    fi
done

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do 
    diff -s deploy-test/fgprof.pprof.example pprof/profilefiles/${APP_HOSTS_PATH}/fgprof.pprof.* > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "Success to fetch fgprof.pprof."
    elif [ $? -eq 1 ]; then
        echo "Script error detected. Can't fetch fgprof.pprof"
        exit 1
    else
        echo "Fail to exec diff command to fgprof.pprof"
        exit 1
    fi
done

docker compose down