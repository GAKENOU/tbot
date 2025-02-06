.phony = help install serve-dev

venv:
	@echo "Creating virtual environment..."
	python3 -m venv .venv

install:
	@echo "Installing dependencies..."
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install -r requirements.txt

build:
	@echo "Check if given container exists..."
	@if [ $(docker ps -a -q -f name=gak_bot) ]; then \
		echo "Stopping and removing existing container..."; \
		docker stop gak_bot; \
		docker rm gak_bot; \
	fi

	@echo "Building the project..."
	docker build --no-cache -t gakenoumessan/gak_bot .

make deploy:
	@echo "Checking if port 8005 is in use..."
	PORT_CONTAINER_ID=$(docker ps -q --filter "publish=8005") ; \
	if [ -n "$$PORT_CONTAINER_ID" ]; then \
		echo "Stopping container using port 8005..."; \
		docker stop $$PORT_CONTAINER_ID; \
		docker rm $$PORT_CONTAINER_ID; \
	fi
	@echo "Deploying the project..."
	docker run -d -p 8005:80 --name gak_bot gakenoumessan/gak_bot

serve:
	@echo "Starting development server..."
	.venv/bin/fastapi dev src/main.py

test:
	@echo "Running tests..."
	.venv/bin/pytest