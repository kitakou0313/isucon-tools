.PHONY: kataribe
kataribe:
	docker-compose run --rm kataribe bash -c "cat /logs/access.log | kataribe" > ./kataribe/output/kataribe.txt
