#!/bin/bash
set -e
# This scripts is used to 
# - send bin and init SQL files to host with rsync

echo "Start to deploy apps"

source ./hosts/hosts.txt
HOSTS_NUM=${#trghosts[@]}

for ((host_idx=0; host_idx<${HOSTS_NUM}; host_idx++));
do
  echo "Deploy to ${trghosts[host_idx]}:${trgports[host_idx]}"
  rsync -e "ssh -p ${trgports[host_idx]}" -av ./webapp/sample-webapp/sample root@${trghosts[host_idx]}:/home/root/webapp/main
  rsync -e "ssh -p ${trgports[host_idx]}" -av ./webapp/sample-webapp/sql/ root@${trghosts[host_idx]}:/home/root/webapp/isucon/sql
done

echo "Finish to deploy apps"