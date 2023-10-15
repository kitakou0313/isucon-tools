#!/bin/bash
set -ex

source ./hosts/hosts.txt

for ((host_idx=0; host_idx<${FRONTEND_HOSTS_NUMS}; host_idx++));
do
  tmux new -s "${FRONTEND_HOSTS[host_idx]}-${FRONTEND_HOSTS_SSH_PORT[host_idx]}-front" -d
done

for ((host_idx=0; host_idx<${DB_HOSTS_NUMS}; host_idx++));
do
  tmux new -s "${DB_HOSTS[host_idx]}-${DB_HOSTS_SSH_PORT[host_idx]}-db" -d
done

for ((host_idx=0; host_idx<${APP_HOSTS_NUMS}; host_idx++));
do
  tmux new -s "${APP_HOSTS[host_idx]}-${APP_HOSTS_SSH_PORT[host_idx]}-app" -d
done

# topでの監視用に全hostへのSSH
tmux new-session -s "all-hosts" -d ssh -p ${ALL_HOSTS_SSH_PORT[0]} -i ${ALL_HOSTS_SSH_PRIVATE_KEY[0]} ${ALL_HOSTS_SSH_USER[0]}@${ALL_HOSTS[0]} &&\
for ((host_idx=1; host_idx<${ALL_HOSTS_NUMS}; host_idx++));
do
  tmux split-window
  tmux send-keys "ssh -p ${ALL_HOSTS_SSH_PORT[host_idx]} -i ${ALL_HOSTS_SSH_PRIVATE_KEY[host_idx]} ${ALL_HOSTS_SSH_USER[host_idx]}@${ALL_HOSTS[host_idx]}" C-m
done
tmux select-layout even-vertical

tmux ls