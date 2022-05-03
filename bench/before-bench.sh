#!/bin/bash
set -e
# This scripts is used to 
# - Backup log files(nginx log, mysql slowquery log, etc...)
# - Clean files(nginx log, mysql slowquery log, etc...)


echo "Start to clean logs in remote hosts"

source ./hosts/hosts.txt
HOSTS_NUM=${#trghosts[@]}

for ((host_idx=0; host_idx<${HOSTS_NUM}; host_idx++));
do
  echo "Backup log and clean log in ${trghosts[host_idx]}:${trgports[host_idx]}"
  ssh -p ${trgports[host_idx]} root@${trghosts[host_idx]} 'sh -s ' < ./bench/utils/nginx-backup-clean-log.sh
  ssh -p ${trgports[host_idx]} root@${trghosts[host_idx]} 'sh -s ' < ./bench/utils/slowquery-backup-clean-log.sh
done

echo "Finish to backup log and clean log"