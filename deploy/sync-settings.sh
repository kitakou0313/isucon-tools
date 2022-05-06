#!/bin/bash
set -e
# This scripts is used to 
# - sync setting(nginx , mysql, systemd, etc...) to remote host.

echo "Start to sync config files"

source ./hosts/hosts.txt
HOSTS_NUM=${#trghosts[@]}

for ((host_idx=0; host_idx<${HOSTS_NUM}; host_idx++));
do
  echo "Send configs to ${trghosts[host_idx]}:${trgports[host_idx]}"
  rsync -e "ssh -p ${trgports[host_idx]}" -av ./configs/nginx.conf root@${trghosts[host_idx]}:/etc/nginx/nginx.conf
  rsync -e "ssh -p ${trgports[host_idx]}" -av ./configs/my.cnf root@${trghosts[host_idx]}:/etc/mysql/my.cnf
done

echo "Finish to sync config files"