-include .env
export

DJANGO_PRODUCTION_SETTINGS_MODULE = ${DJANGO_SETTINGS_MODULE}
IFACE ?= 127.0.0.1
PORT  ?= 8000

ifeq ($(OS),Windows_NT)
	OPEN_CMD = cmd /c start
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OPEN_CMD = xdg-open
	endif
	ifeq ($(UNAME_S),Darwin)
		OPEN_CMD = open
	endif
endif

#----------General----------#

# Extract arguments of the subcommand
.PHONY: _run_args
_run_args:
  # use the rest as arguments for the subcommand
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)

# target: help - Display callable targets.
.PHONY: help
help:
	@egrep "^# target:" [Mm]akefile

#----------Docker Application commands----------#

# target: up - Docker command: Start the hole application
.PHONY:
up:
	docker-compose up -d

# target: down - Docker command: Stop the application (all its containers)
.PHONY:
down:
	docker-compose down

# target: dc-createsuperuser - Docker command: Create a super user account
.PHONY: dc-createsuperuser
dc-createsuperuser:
	docker exec -it knowledge-base-app poetry run python -m todo_list.manage createsuperuser

# target: docker_shell - Docker command: open an interactive terminal for the application
.PHONY: docker_shell
docker_shell:
	docker exec -it knowledge-base /bin/bash


#----------Docker Database----------#

# target: initdb - Initialize the database container
.PHONY: initdb
initdb:
	docker run -d --name todo_list_db \
		-v todo_list_data:/var/lib/postgresql/data \
		-p 5436:5432 \
		-e POSTGRES_HOST_AUTH_METHOD=trust \
		postgres:14

# target: createdb - Create the Database
.PHONY: createdb
createdb:
	docker exec -it todo_list_db createdb -U postgres todo_list

# target: startdb - Start a postgres database for the todo_list
.PHONY: startdb
startdb:
	docker start todo_list_db

# target: stopdb - Stop the todo_list postgres database
.PHONY: stopdb
stopdb:
	docker stop todo_list_db

#----------Django commands----------#

# target: clean_pyc - Remove all ".pyc" files
.PHONY: clean_pyc
clean_pyc:
	poetry run python -m todo_list.manage clean_pyc --path=src/todo_list

# target: createsuperuser - Create a super user account
.PHONY: createsuperuser
createsuperuser:
	poetry run python -m todo_list.manage createsuperuser

# target: shell_plus - Enter interactive environment
.PHONY: shell_plus
shell_plus:
	poetry run python -m todo_list.manage shell_plus

# target: makemigrations - Create migration files
# and migrate database models
.PHONY: makemigrations
makemigrations:
	poetry run python -m todo_list.manage makemigrations

# target: migrate - Execute the migrations
# and migrate database models
.PHONY: migrate
migrate:
	poetry run python -m todo_list.manage migrate --run-syncdb


# target: start - Start the application
.PHONY: start
start:
	poetry run python -m todo_list.manage runserver $(IFACE):$(PORT)

# target: run - Executes any of the available django commands
.PHONY: run
run: _run_args
	poetry run python -m todo_list.manage $(RUN_ARGS)

# target: data_load - Executes kb_etl migration manually
.PHONY: data_load
data_load:
	poetry run python -m todo_list.kb_etl

# target: cleanup_data - *CAUTION* Remove all data from the database
.PHONY: cleanup_data
cleanup_data:
	poetry run python -m todo_list.manage migrate gazetteer 0002_initial

# target: start-production - Run server as in production
.PHONY: start-production
start-production:
	DJANGO_SETTINGS_MODULE=$(DJANGO_PRODUCTION_SETTINGS_MODULE) \
		poetry run python -m todo_list.manage runserver $(IFACE):$(PORT)

#
# Tests
#

# target: test - Run tests
.PHONY: test
test:
	poetry run pytest --cov=src --junitxml=junit/test-results.xml --cov-report=xml \
		--cov-report=html --cov-report=term tests

# target: coverage - Open the HTML report in the browser
.PHONY: coverage
coverage:
	$(OPEN_CMD) htmlcov/index.html
