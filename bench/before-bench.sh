#!/bin/bash
set -e
# This scripts is used to 
# - Backup log files(nginx log, mysql slowquery log, etc...)
# - Clean files(nginx log, mysql slowquery log, etc...)


echo "Start to clean logs in remote hosts"

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  echo "Backup log and clean log in ${FRONTEND_HOSTS[host_idx]}:${FRONTEND_HOSTS_SSH_PORT[host_idx]}"

  rsync -e "ssh -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ./bench/utils ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]}:/home/${FRONTEND_HOSTS_SSH_USER[host_idx]}

  ssh -t -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PRIVATE_KEY[host_idx]} \
  ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]} \
  "sudo bash /home/${FRONTEND_HOSTS_SSH_USER[host_idx]}/utils/nginx-backup-clean-log.sh"
done


for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  echo "Backup log and clean log in ${DB_HOSTS[host_idx]}:${DB_HOSTS_SSH_PORT[host_idx]}"

  rsync -e "ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ./bench/utils ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]}:/home/${DB_HOSTS_SSH_USER[host_idx]}

  ssh -t -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]} \
  ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]} \
  "sudo bash /home/${DB_HOSTS_SSH_USER[host_idx]}/utils/slowquery-backup-clean-log.sh"
done

# curl http://${FRONTEND_HOSTS[0]}/api/bench/start

echo "Finish to backup log and clean log"