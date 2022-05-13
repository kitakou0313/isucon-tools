#!/bin/bash
set -e
# This scripts is used to 
# - sync setting(nginx , mysql, systemd, etc...) to remote host.

echo "Start to sync config files"

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  echo "Send configs to ${FRONTEND_HOSTS[host_idx]}:${FRONTEND_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PUB_KEY[host_idx]}" -av ./configs/nginx.conf ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]}:/etc/nginx/nginx.conf
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  echo "Send configs to ${DB_HOSTS[host_idx]}:${DB_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PUB_KEY[host_idx]}" -av ./configs/my.cnf ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]}:/etc/mysql/my.cnf
done

echo "Finish to sync config files"