SERVICE_TITLE=AI tool to check for prime numbers
SERVICE_NAME=is-prime-tool

TOOL_FILE=tool-service.py
IVCAP_SERVICE_FILE=service.json

PROJECT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PORT=8078
SERVICE_URL=http://localhost:${PORT}


include Makefile.common

run:
	env VERSION=$(VERSION) \
		python ${PROJECT_DIR}/tool-service.py --port ${PORT}

test-local:
	curl -i -X POST -H "content-type: application/json" --data "{\"number\": 997}" http://localhost:${PORT}

test-job: IVCAP_API=https://develop.ivcap.net
test-job:
	TOKEN=$(shell ivcap context get access-token --refresh-token); \
	curl \
	-X POST \
	-H "content-type: application/json" \
	-H "Timeout: 20" \
	-H "Authorization: Bearer $$TOKEN" \
	--data "{\"number\": 997}" \
	${IVCAP_API}/1/services2/${SERVICE_ID}/jobs?with-result-content=true | jq

test-job-minikube:
	@$(MAKE) IVCAP_API=http://ivcap.minikube test-job

test-job-ivcap:
	@$(MAKE) IVCAP_API=https://develop.ivcap.net test-job

install:
	pip install -r requirements.txt

docker-run: #docker-build
	docker run -it \
		-p ${PORT}:${PORT} \
		--platform=linux/${TARGET_ARCH} \
		-v ${PROJECT_DIR}:/data \
		--rm \
		${DOCKER_NAME}_${TARGET_ARCH} --port ${PORT}

docker-debug: #docker-build
	docker run -it \
		-p 8888:8080 \
		--user ${DOCKER_USER} \
		--platform=linux/${TARGET_ARCH} \
		--entrypoint bash \
		${DOCKER_NAME}_${TARGET_ARCH}

batch-service-register-minikube:
	make IVCAP_SERVICE_FILE=batch_service.json service-register-minikube

.PHONY: run
