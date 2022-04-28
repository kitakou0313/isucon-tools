#!/bin/bash
set -e
# This scripts is used to 
# - Backup log files(nginx log, mysql slowquery log, etc...)
# - Clean files(nginx log, mysql slowquery log, etc...)


echo "Start to clean logs in remote hosts"

source ./hosts/hosts.txt

for host in "${trghosts[@]}"
do
  echo "Backup log file in ${host}"
  ssh -p 2222 root@${host} 'sh -s ' < ./bench/utils/backup-clean-log.sh
done

echo "Finish to bk log files"