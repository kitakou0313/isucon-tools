#!/bin/bash
set -e

LOG_PATH=${1:-'./mysql-slowquery/mysql-slowquery-log/host1/mysql-slow.log'}

docker compose run --rm pt-query-digest pt-query-digest "${LOG_PATH}"

