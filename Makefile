all: start-db example

start-db:
	docker-compose up -d postgres

example:
	@echo "Running job script"
	docker-compose run pyspark python job.py

clean:
	docker-compose down

dev:
	pip3 install --upgrade wheel setuptools pip
	pip3 install --upgrade -r ./code/requirements.txt \
	            --ignore-installed \
	            --no-cache-dir \
	            --timeout 120