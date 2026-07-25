#!/bin/bash
set -ex
# This scripts is used to 
# - send bin and init SQL files to host with rsync

echo "Start to deploy apps"

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do
  echo "Deploy to ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ./webapp/ ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]}:${APP_HOSTS_APP_DEPLOY_DIR[host_idx]}

  ssh -t -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]} \
  ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]} \
  "sudo systemctl restart ${APP_HOSTS_SYSTEMCTL_SERVICE_NAME[host_idx]}"
done

echo "Start to deploy O11y tools"

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do
  echo "Deploy to ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
  rsync -e "ssh -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]}" \
  -av ./obi-setup ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]}:${APP_HOSTS_O11Y_TOOL_DEPLOY_DIR[host_idx]}

done

echo "Finish to deploy apps"