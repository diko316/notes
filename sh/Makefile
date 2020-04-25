UBUNTU_18_IMAGE = ubuntu-18:latest
UBUNTU_18_CONTAINER = ubuntu-18
UBUNTU_18_CONTAINERS := $(shell docker ps -a | grep $(UBUNTU_18_IMAGE) | awk '{print $$1}')
UBUNTU_18_IMAGES := $(shell docker images | awk '{print $$1":"$$2}' | grep $(UBUNTU_18_IMAGE))

.PHONY:
	@echo "help here"

ubuntu-18-container-cleanup:
	@docker ps -a | grep -q $(UBUNTU_18_IMAGE) && \
		docker rm $(UBUNTU_18_CONTAINERS) || echo "no running $(UBUNTU_18_IMAGE) container."
	@docker container prune -f

ubuntu-18-image-cleanup: ubuntu-18-container-cleanup
	@docker images | awk '{print $$1":"$$2}' | grep -q $(UBUNTU_18_IMAGE) && \
		docker rmi $(UBUNTU_18_IMAGES) || echo "no $(UBUNTU_18_IMAGE) image built."
	@docker image prune -f

ubuntu-18-image: ubuntu-18-image-cleanup
	@docker build -f $(UBUNTU_18_CONTAINER).Dockerfile -t $(UBUNTU_18_IMAGE) .

ubuntu-18: ubuntu-18-container-cleanup
	@docker run \
		-ti \
		--name $(UBUNTU_18_CONTAINER) \
		$(UBUNTU_18_IMAGE) \
		/bin/bash || exit 0
