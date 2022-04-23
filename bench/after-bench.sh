#!/bin/bash
set -e
# This scripts is used to 
# - fetch log files(nginx, mysql logs) to analyze in local.

echo "Start to fetch log file from localhost"

isu01="localhost"

trghosts=($isu01)

for host in "${trghosts[@]}"
do
  echo "Fetch log from ${host}"
  rsync -e "ssh -p 2222" -av root@${host}:/var/log/nginx/access.log ./kataribe/webserver-log/access.log
done

echo "Finish to fetch log files"