#!/bin/bash
set -e
# This scripts is used to 
# - fetch log files(nginx, mysql logs) to analyze in local.
# - fetch pprof output

echo "Start to fetch log file from localhost"

source ./hosts/hosts.txt

# curl http://${FRONTEND_HOSTS[0]}/api/bench/stop

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  LOG_DIR="./alp/log/${FRONTEND_HOSTS_PATH[host_idx]}"
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir "${LOG_DIR}"
  fi

  LOG_FILE_NAME="${LOG_DIR}/access.log"

  echo "Fetch log from ${FRONTEND_HOSTS[host_idx]}:${FRONTEND_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]}:/var/log/nginx/access.log "${LOG_FILE_NAME}.${TIMESTAMP}"
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  LOG_DIR="./mysql-slowquery/mysql-slowquery-log/${DB_HOSTS_PATH[host_idx]}"
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir "${LOG_DIR}"
  fi

  LOG_FILE_NAME="${LOG_DIR}/mysql-slow.log"

  # Fetch mysql slowquery-log
  echo "Fetch mysql slow query log from ${DB_HOSTS[host_idx]}:${DB_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]}:/var/log/mysql/mysql-slow.log "${LOG_FILE_NAME}.${TIMESTAMP}"
done

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do 
  LOG_DIR="./pprof/profilefiles/${APP_HOSTS_PATH[host_idx]}"
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir "${LOG_DIR}"
  fi

  LOG_FILE_NAME="${LOG_DIR}/fgprof.pprof"

  # Fetch pprof logs
  echo "Fetch pprof log from ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]}:/tmp/pprof/fgprof.pprof "${LOG_FILE_NAME}.${TIMESTAMP}"

done

echo "Finish to fetch log files"