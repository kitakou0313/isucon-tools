#!/bin/bash
set -e
# This scripts is used to 
# - sync setting(nginx , mysql, systemd, etc...) to remote host.

echo "Start to sync config files"

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  echo "Send configs to ${FRONTEND_HOSTS[host_idx]}:${FRONTEND_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ./configs/nginx.conf ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]}:/etc/nginx/nginx.conf
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  echo "Send configs to ${DB_HOSTS[host_idx]}:${DB_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ./configs/my.cnf ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]}:/etc/mysql/my.cnf
done

# Below is sample code to sync setting file in APP server.
# Please use this to sync files, like env.sh

# for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
# do
#   echo "Send configs to ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
#   rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]}" -av $(file path in local) ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]}:$(file path in remote)
# done

echo "Finish to sync config files"