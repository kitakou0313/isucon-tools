build:
	docker compose build kataribe slowquery pprof

.PHONY: kataribe
kataribe:
	docker compose run --rm kataribe bash -c "cat /logs/access.log | kataribe" > ./kataribe/output/kataribe.txt

.PHONY: pprof
pprof:
	docker compose run --rm pprof bash -c "go tool pprof -png /tmp/profile/fgprof.pprof > /tmp/output/cpu.png"

.PHONY: pprof-web
pprof-web:
	go tool pprof -http=:8888 ./pprof/profilefiles/isucon ./pprof/profilefiles/fgprof.pprof 

# Working on only Linux host!
.PHONY: pprof-web-docker
pprof-web-docker:
	docker compose run --rm pprof bash -c "go tool pprof -http=:8888 /tmp/profile/fgprof.pprof" 


.PHONY: pprof-cmd
pprof-cmd:
	docker compose run --rm pprof bash -c "go tool pprof /tmp/profile/fgprof.pprof"

.PHONY: slowquery
slowquery:
	docker compose run --rm slowquery mysqldumpslow -s t -t 5 /var/log/slowquery-log/mysql-slow.log

.PHONY: up-test-server
up-test-server:
	docker compose up -d deploy-test