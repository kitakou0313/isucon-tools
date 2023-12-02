#!/bin/bash
set -e

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  LOG_DIR="./mysql-slowquery/mysql-slowquery-log/${DB_HOSTS_PATH[host_idx]}"

  OUTPUT_DIR="./pt-query-digest/output/${DB_HOSTS_PATH[host_idx]}"
  if [ ! -d "${OUTPUT_DIR}" ]; then
    mkdir "${OUTPUT_DIR}"
  fi

  for LOG_FILE_NAME in ${LOG_DIR}/mysql-slow.log.*
  do
    TIMESTAMP=$(echo "${LOG_FILE_NAME}" | sed -e "s/.*\.\([0-9]\{8\}_[0-9]\{6\}\)/\1/g")
    OUTPUT_FILE_NAME="${OUTPUT_DIR}/pt-query-digest.txt.${TIMESTAMP}"

    if [ ! -f "${OUTPUT_FILE_NAME}" ]; then
      docker compose run --rm pt-query-digest pt-query-digest "${LOG_FILE_NAME}" > ${OUTPUT_FILE_NAME}
    fi

  done

done