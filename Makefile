GIT_BRANCH=$$(git rev-parse --abbrev-ref HEAD)

IMAGE ?= $(shell yq '.image.repository' env/dev/values.yaml)
TAG ?= $(shell yq '.image.tag' env/dev/values.yaml)

LOCAL_PORT ?= 5001
CONTAINER_PORT ?= 5000

GPU_DEVICE ?= 0

MODEL_REPO ?= $(shell yq '.config.modelRepo' env/dev/values.yaml)
MODEL_PATH ?= ./model_data

KUBECONFIG ?= ~/.kube/config
CONTEXT ?= aime-k3s
NAMESPACE=$(shell echo $(USER)-${GIT_BRANCH} | cut -c 1-63 | tr "_" "-" | tr "/" "-" | tr '[:upper:]' '[:lower:]')
APP_NAME=$(shell yq '.name' env/dev/values.yaml)

##
## HELP
##

help: ## This help
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-32s\033[0m %s\n", $$1, $$2}'

#
# SETUP
#
get-kubeconfig: ## Get the kubeconfig file from gcloud secrets
	gcloud secrets versions access 1 --secret=aime-k3s-kubeconfig --project fc-it-cross-sbx-rev1 > .kubeconfig
	cp ${KUBECONFIG} ${KUBECONFIG}.bkp
	KUBECONFIG=${KUBECONFIG}:.kubeconfig \
		kubectl config view --flatten > ${KUBECONFIG}
	rm .kubeconfig

##
## DEV
##

up: ## Deploy in kubernetes
	KUBECONFIG=${KUBECONFIG} tilt --context ${CONTEXT} up && \
	KUBECONFIG=${KUBECONFIG} tilt --context ${CONTEXT} down \
		--delete-namespaces

ci: ## Deploy an unattended version of the deployment in kubernetes
	KUBECONFIG=${KUBECONFIG} tilt --context ${CONTEXT} ci

down: ## Delete the deployment in kubernetes removing the namespace
	KUBECONFIG=${KUBECONFIG} tilt --context ${CONTEXT} down \
		--delete-namespaces

port-forward: ## Forward the port of the deployment in kubernetes to the local port
	kubectl --kubeconfig ${KUBECONFIG} --context ${CONTEXT} \
		port-forward \
		--namespace ${NAMESPACE} \
		$$(kubectl --kubeconfig ${KUBECONFIG} get pods \
			--namespace ${NAMESPACE} \
			--selector="app.kubernetes.io/name=${APP_NAME}" \
			--output jsonpath='{.items[0].metadata.name}') \
		${LOCAL_PORT}:${CONTAINER_PORT}

app:
	@streamlit run app.py \
		$$(kubectl --kubeconfig ${KUBECONFIG} --context ${CONTEXT} \
			get nodes -o jsonpath='{.items[0].status.addresses[0].address}'\
			):$$(kubectl --kubeconfig ${KUBECONFIG} --context ${CONTEXT} -n ${NAMESPACE} \
			  get svc ${APP_NAME}-cog-ai-model -o jsonpath='{.spec.ports[0].nodePort}') || \
			  echo "\nError initializing the app. Ensure that all dependencies are installed.\n\n$$ pip install streamlit requests watchgod\n"

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

docker_cache: ## Build an image and push to registry for caching
	cog push ${IMAGE}:cache

download_model:  ## Clone the git repository of the model
	git clone --depth=1 ${MODEL_REPO} ${MODEL_PATH} 2> /dev/null || \
		git --git-dir=${MODEL_PATH}/.git pull

download_docker_cache: ## Download the docker cache image
	docker pull ${IMAGE}:cache

check_gpu:  ## Check if is available a GPU in the system
	nvidia-smi > /dev/null

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
