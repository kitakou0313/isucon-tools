#!/bin/bash
set -e
# This scripts is used to 
# - Backup log files(nginx log, mysql slowquery log, etc...)
# - Clean files(nginx log, mysql slowquery log, etc...)


echo "Start to clean logs in remote hosts"

source ./hosts/hosts.txt

for host in "${trghosts[@]}"
do
  echo "Backup log and clean log in ${host}"
  ssh -p 2222 root@${host} 'sh -s ' < ./bench/utils/nginx-backup-clean-log.sh
  ssh -p 2222 root@${host} 'sh -s ' < ./bench/utils/slowquery-backup-clean-log.sh
done

echo "Finish to backup log and clean log"