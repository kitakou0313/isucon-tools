#!/bin/bash
set -e
# This scripts is used to 
# - fetch log files(nginx, mysql logs) to analyze in local.
# - fetch pprof output

echo "Start to fetch log file from localhost"

source ./hosts/hosts.txt

for host in "${trghosts[@]}"
do
  echo "Fetch log from ${host}"
  rsync -e "ssh -p 2222" -av root@${host}:/var/log/nginx/access.log ./kataribe/webserver-log/access.log

  # Fetch mysql slowquery-log
  echo "Fetch mysql slow query log from ${host}"
  rsync -e "ssh -p 2222" -av root@${host}:/var/log/mysql/mysql-slow.log ./mysql-slowquery/mysql-slowquery-log/mysql-slow.log
  
  # Fetch pprof logs
  echo "Fetch pprof log from ${host}"
  rsync -e "ssh -p 2222" -av root@${host}:/home/root/webapp/cpu.pprof ./pprof/profilefiles/cpu.pprof

done

echo "Finish to fetch log files"