#!/bin/bash
set -e

LOG_PATH=${1:-'./alp/log/host1/access.log'}

docker compose run --rm alp bash -c "cat ${LOG_PATH} | alp -c ./alp/config/config.yaml regexp"
