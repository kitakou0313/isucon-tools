#!/bin/bash
set -e
# This scripts is used to 
# - fetch log files(nginx, mysql logs) to analyze in local.
# - fetch pprof output

echo "Start to fetch log file from localhost"

source ./hosts/hosts.txt

# curl http://${FRONTEND_HOSTS[0]}/api/bench/stop

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  LOG_DIR="./alp/log/${FRONTEND_HOSTS_PATH[host_idx]}"
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir "${LOG_DIR}"
  fi

  if [ -f "${LOG_DIR}/access.log" ]; then 
    cp "${LOG_DIR}/access.log" "${LOG_DIR}/access.log.bk.$(date '+%Y%m%d_%H%M%S')"
  fi

  echo "Fetch log from ${FRONTEND_HOSTS[host_idx]}:${FRONTEND_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]}:/var/log/nginx/access.log "${LOG_DIR}/access.log"
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  LOG_DIR="./mysql-slowquery/mysql-slowquery-log/${DB_HOSTS_PATH[host_idx]}"
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir "${LOG_DIR}"
  fi

  LOG_FILE_NAME="${LOG_DIR}/mysql-slow.log"
  if [ -f "${LOG_FILE_NAME}" ]; then 
    cp "${LOG_FILE_NAME}" "${LOG_FILE_NAME}.bk.$(date '+%Y%m%d_%H%M%S')"
  fi
  # Fetch mysql slowquery-log
  echo "Fetch mysql slow query log from ${DB_HOSTS[host_idx]}:${DB_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]}:/var/log/mysql/mysql-slow.log ${LOG_FILE_NAME}
done

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do 
  LOG_DIR="./pprof/profilefiles/${APP_HOSTS_PATH[host_idx]}"
  if [ ! -d "${LOG_DIR}" ]; then
    mkdir "${LOG_DIR}"
  fi

  LOG_FILE_NAME="${LOG_DIR}/fgprof.pprof"
  if [ -f "${LOG_FILE_NAME}" ]; then 
    cp "${LOG_FILE_NAME}" "${LOG_FILE_NAME}.bk.$(date '+%Y%m%d_%H%M%S')"
  fi

  # Fetch pprof logs
  echo "Fetch pprof log from ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]}:/etc/pprof/fgprof.pprof "${LOG_FILE_NAME}"

done

echo "Finish to fetch log files"