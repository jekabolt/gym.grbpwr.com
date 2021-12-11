run:
	./bin/verless serve -w .
build:
	./bin/verless build .



REGISTRY					?= docker.io
IMAGE_NAME					:= gym.grbpwr.com

GIT_COMMIT					:= $(shell git describe --exact-match HEAD 2>/dev/null)
ifeq ($(GIT_COMMIT),)
	GIT_COMMIT				:= $(shell git describe --dirty=-unsupported --always --tags --long || echo pre-commit)
	IMAGE_VERSION			?= $(GIT_COMMIT)-j$(BUILD_NUMBER)
else
	IMAGE_VERSION			?= $(GIT_COMMIT)
endif


DOCKER_IMAGE				:= $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_VERSION)

image-build:  ## build the docker image
	docker build \
		-t $(DOCKER_IMAGE) .
	
image-clean: ## remove the last built image
	docker rmi -f $(shell docker images -q $(DOCKER_IMAGE)) || true
	docker image prune -f --filter label=stage=server-intermediate

image-publish: ## publish the built image to the registry
	docker tag $(DOCKER_IMAGE) registry.localhost:5000/$(DOCKER_IMAGE)
	docker push registry.localhost:5000/$(DOCKER_IMAGE)

image-run: ## runs image in docker 
	docker run \
		--name $(IMAGE_NAME) \
	   	-p 80:80 \
   	$(REGISTRY)/$(IMAGE_NAME):$(IMAGE_VERSION)

image-teardown: ## teardown image in docker 
	@docker rm -f $(IMAGE_NAME) || true