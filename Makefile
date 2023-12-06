build:
	docker compose build alp pt-query-digest pprof ansible

.PHONY: kataribe
kataribe:
	docker compose run --rm alp bash -c "cat /logs/access.log | kataribe" > ./kataribe/output/kataribe.txt

.PHONY: alp
alp:
	bash alp/alp.sh

.PHONY: pprof
pprof:
	docker compose run --rm pprof bash -c "go tool pprof -png /tmp/profile/fgprof.pprof > /tmp/output/cpu.png"

.PHONY: pprof-web
pprof-web:
	go tool pprof -http=:8888 ./pprof/profilefiles/isucon ./pprof/profilefiles/host1/fgprof.pprof 

# Working on only Linux host!
.PHONY: pprof-web-docker
pprof-web-docker:
	docker compose run --rm pprof bash -c "go tool pprof -http=:8888 /tmp/profile/fgprof.pprof" 


.PHONY: pprof-cmd
pprof-cmd:
	docker compose run --rm pprof bash -c "go tool pprof /tmp/profile/fgprof.pprof"

.PHONY: slowquery
slowquery:
	docker compose run --rm slowquery mysqldumpslow -s t -t 5 ./mysql-slowquery/mysql-slowquery-log/host1/mysql-slow.log

.PHONY: pt-query-digest
pt-query-digest:
	bash pt-query-digest/pt-query-digest.sh 

.PHONY: ansible
ansible:
	docker compose run --rm -it ansible bash


.PHONY: up-test-server
up-test-server:
	docker compose up -d deploy-test-1 deploy-test-2