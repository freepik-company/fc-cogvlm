GIT_BRANCH=$$(git rev-parse --abbrev-ref HEAD)

IMAGE ?= $(shell yq '.image.repository' env/dev/values.yaml)
TAG ?= $(shell yq '.image.tag' env/dev/values.yaml)

LOCAL_PORT ?= 5000
CONTAINER_PORT ?= 5000

GPU_DEVICE ?= 0

MODEL_REPO ?= $(shell yq '.config.modelRepo' env/dev/values.yaml)
MODEL_PATH ?= ./model_data

KUBECONFIG ?= ${HOME}/.kube/config
NAMESPACE=$(shell echo $(USER)-${GIT_BRANCH} | cut -c 1-63 | tr "_" "-" | tr "/" "-" | tr '[:upper:]' '[:lower:]')

##
## HELP
##

help: ## This help
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-32s\033[0m %s\n", $$1, $$2}'


##
## DEV
##

build: ## Build a final image for development
	IMAGE=${IMAGE}:${TAG} skaffold build --push

dev: ## Run dev in kubernetes
	skaffold dev \
		--kubeconfig ${KUBECONFIG} \
		-n ${NAMESPACE}

run: ## Deploy in kuberentes for testing
	skaffold run \
		--kubeconfig ${KUBECONFIG} \
		-n ${NAMESPACE}

down:
	kubectl delete namespace ${NAMESPACE}

##
## LOCAL
##

docker_run: check_tools check_gpu download_model docker_build   ## Run docker locally
	docker run --rm \
		--gpus device=${GPU_DEVICE} \
		-v ${PWD}/${MODEL_PATH}:/src/model_data \
		-p ${LOCAL_PORT}:${CONTAINER_PORT} \
		${IMAGE}:${TAG}

docker_build:  ## Build an image just for running locally
	cog build -t ${IMAGE}:${TAG}

download_model:  ## Clone the git repository of the model
	git clone --depth=1 ${MODEL_REPO} ${MODEL_PATH} 2> /dev/null || \
		git --git-dir=${MODEL_PATH}/.git pull

check_gpu:  ## Check if is available a GPU in the system
	nvidia-smi > /dev/null

check_tools:  ## Check installed tools
	echo "TODO: Verficar que tenemos los comandos necesarios en el entorno local y especificar cómo instalarlos... brew, curl, etc.. etc..."
	#sudo wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq

##
## CLEAN
##

clean:  ## Clean the repository
	@echo -n "Se eliminará el directorio del modelo. ¿Estás seguro de realizar esta operación? (y/n): "
	@read answer; \
	if [ "$$answer" = "y" ]; then \
		rm -rf ${MODEL_PATH}; \
	else \
    		echo "Operación cancelada."; \
	fi	
