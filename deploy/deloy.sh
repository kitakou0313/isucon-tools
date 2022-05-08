#!/bin/bash
set -e
# This scripts is used to 
# - send bin and init SQL files to host with rsync

echo "Start to deploy apps"

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do
  echo "Deploy to ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]}" -av ./webapp/sample-webapp/sample root@${APP_HOSTS[host_idx]}:/home/root/webapp/main
  rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]}" -av ./webapp/sample-webapp/sql/ root@${APP_HOSTS[host_idx]}:/home/root/webapp/isucon/sql
done

echo "Finish to deploy apps"