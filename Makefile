.PHONY: kataribe
kataribe:
	docker-compose run --rm kataribe bash -c "cat /logs/access.log | kataribe" > ./kataribe/output/kataribe.txt

.PHONY: pprof
pprof:
	docker-compose run --rm pprof bash -c "go tool pprof -png cpu /tmp/profile/cpu.pprof > /tmp/output/cpu.png"

.PHONY: pprof-cmd
pprof-cmd:
	docker-compose run --rm pprof bash -c "go tool pprof /tmp/profile/cpu.pprof"
