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
  -av "./configs/nginx/${FRONTEND_HOSTS_PATH[host_idx]}/" ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]}:/tmp/nginx
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  echo "Send configs to ${DB_HOSTS[host_idx]}:${DB_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av "./configs/mysql/${DB_HOSTS_PATH[host_idx]}/" ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]}:/tmp/mysql
done

# Below is sample code to sync setting file in APP server.
# Please use this to sync files, like env.sh

# for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
# do
#   echo "Send configs to ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
#   rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]}" -av $(file path in local) ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]}:$(file path in remote)
# done

# コピー

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  ssh -t -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PRIVATE_KEY[host_idx]} \
  ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]} 'sudo cp -r /tmp/nginx /etc'
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  ssh -t -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]} \
  ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]} 'sudo cp -r /tmp/mysql /etc'
done

echo "Finish to sync config files"