#!/bin/bash
set -e

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  LOG_DIR="./alp/log/${FRONTEND_HOSTS_PATH[host_idx]}"

  OUTPUT_DIR="./alp/output/${FRONTEND_HOSTS_PATH[host_idx]}"
  if [ ! -d "${OUTPUT_DIR}" ]; then
    mkdir "${OUTPUT_DIR}"
  fi

  for LOG_FILE_NAME in ${LOG_DIR}/access.log.*
  do
    # TIMESTAMP=$(echo "${LOG_FILE_NAME}" | sed -e "s/\([0-9]\{8\}_[0-9]\{6\}\)\$/\1/g")
    TIMESTAMP=$(echo "${LOG_FILE_NAME}" | sed -e "s/.*\.\([0-9]\{8\}_[0-9]\{6\}\)/\1/g")
    OUTPUT_FILE_NAME="${OUTPUT_DIR}/alp.txt.${TIMESTAMP}"

    if [ ! -f "${OUTPUT_FILE_NAME}" ]; then
      docker compose run --rm alp bash -c "cat ${LOG_FILE_NAME} | alp -c ./alp/config/config.yaml regexp" > ${OUTPUT_FILE_NAME}
    fi

  done

done