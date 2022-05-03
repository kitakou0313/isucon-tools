#!/bin/bash
set -e
# This scripts is used to 
# - fetch log files(nginx, mysql logs) to analyze in local.
# - fetch pprof output

echo "Start to fetch log file from localhost"

source ./hosts/hosts.txt
HOSTS_NUM=${#trghosts[@]}

for ((host_idx=0; host_idx<${HOSTS_NUM}; host_idx++));
do
  echo "Fetch log from ${trghosts[host_idx]}:${trgports[host_idx]}"
  rsync -e "ssh -p ${trgports[host_idx]}" -av root@${trghosts[host_idx]}:/var/log/nginx/access.log ./kataribe/webserver-log/access.log

  # Fetch mysql slowquery-log
  echo "Fetch mysql slow query log from ${trghosts[host_idx]}:${trgports[host_idx]}"
  rsync -e "ssh -p ${trgports[host_idx]}" -av root@${trghosts[host_idx]}:/var/log/mysql/mysql-slow.log ./mysql-slowquery/mysql-slowquery-log/mysql-slow.log
  
  # Fetch pprof logs
  echo "Fetch pprof log from ${trghosts[host_idx]}:${trgports[host_idx]}"
  rsync -e "ssh -p ${trgports[host_idx]}" -av root@${trghosts[host_idx]}:/home/root/webapp/cpu.pprof ./pprof/profilefiles/cpu.pprof

done

echo "Finish to fetch log files"