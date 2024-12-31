build:
	docker-compose build

build-nc:
	docker-compose build --no-cache

build-progress:
	docker-compose build --no-cache --progress=plain

down:
	docker-compose down

run:
	docker-compose up -d

run-scaled:
	docker-compose up -d --scale spark-worker=$(workers)
# docker-compose up -d --scale spark-worker=2
run-d:
	make down && docker-compose up -d

stop:
	docker-compose stop

submit:
	docker exec spark-cluster spark-submit --master spark://spark-master:7077 --deploy-mode client ./apps/$(app)