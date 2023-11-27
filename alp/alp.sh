#!/bin/bash
set -ex

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
    TIMESTAMP=$(echo "${LOG_FILE_NAME}" | sed -E 's/access.log.(.*)/\1/')
    OUTPUT_FILE_NAME="${OUTPUT_DIR}/alp.txt.${TIMESTAMP}"

    docker compose run --rm alp bash -c "cat ${LOG_FILE_NAME} | alp -c ./alp/config/config.yaml regexp" > ${OUTPUT_FILE_NAME}
  done

done