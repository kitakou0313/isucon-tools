#!/bin/bash
set -e
# This scripts is used to 
# - send bin and init SQL files to host with rsync

echo "Start to deploy apps"

source ./hosts/hosts.txt

for host in "${trghosts[@]}"
do
  echo "Deploy to ${host}"
  rsync -e "ssh -p 2222" -av ./webapp/sample-webapp/sample root@${host}:/home/root/webapp/main
  rsync -e "ssh -p 2222" -av ./webapp/sample-webapp/sql/ root@${host}:/home/root/webapp/isucon/sql
done

echo "Finish to deploy apps"