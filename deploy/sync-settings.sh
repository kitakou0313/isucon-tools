#!/bin/bash
set -e
# This scripts is used to 
# - sync setting(nginx , mysql, systemd, etc...) to remote host.

echo "Start to sync config files"

source ./hosts/hosts.txt

for host in "${trghosts[@]}"
do
  echo "Send configs to ${host}"
  rsync -e "ssh -p 2222" -av ./kataribe/webserver-config/nginx.conf root@${host}:/etc/nginx/nginx.conf
done

echo "Finish to sync config files"