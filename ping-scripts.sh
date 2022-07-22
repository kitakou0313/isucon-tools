#!/bin/bash
set -e
# This scripts is used to 
# - check connectablity to servers in comp env

echo "Ping to competitive env"

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  echo "ssh to ${FRONTEND_HOSTS[host_idx]}:${FRONTEND_HOSTS_SSH_PORT[host_idx]}"
  ssh -p ${FRONTEND_HOSTS_SSH_PORT[host_idx]} -i ${FRONTEND_HOSTS_SSH_PRIVATE_KEY[host_idx]} ${FRONTEND_HOSTS_SSH_USER[host_idx]}@${FRONTEND_HOSTS[host_idx]} 'bash -c echo ""' > /dev/null
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  echo "ssh to ${DB_HOSTS[host_idx]}:${DB_HOSTS_SSH_PORT[host_idx]}"
  ssh -p ${DB_HOSTS_SSH_PORT[host_idx]} -i ${DB_HOSTS_SSH_PRIVATE_KEY[host_idx]} ${DB_HOSTS_SSH_USER[host_idx]}@${DB_HOSTS[host_idx]} 'bash -c echo ""' > /dev/null
done

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do
  echo "ssh to ${APP_HOSTS[host_idx]}:${APP_HOSTS_SSH_PORT[host_idx]}"
  ssh -p ${APP_HOSTS_SSH_PORT[host_idx]} -i ${APP_HOSTS_SSH_PRIVATE_KEY[host_idx]} ${APP_HOSTS_SSH_USER[host_idx]}@${APP_HOSTS[host_idx]} 'bash -c echo ""' > /dev/null
done

echo "Can access to all servers!"