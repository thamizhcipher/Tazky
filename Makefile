build:
	docker compose build

run:
	docker compose up

kill:
	docker compose down

no_cache_build:
	docker compose build --no-cache