.PHONY: kataribe
kataribe:
	docker-compose run --rm kataribe bash -c "cat /logs/access.log | kataribe" > ./kataribe/output/kataribe.txt

.PHONY: pprof
pprof:
	docker-compose run --rm pprof bash -c "go tool pprof -png /tmp/profile/cpu.pprof" > ./pprof/output/cpu.png
