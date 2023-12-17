# Description
This repository is for a project that uses a machine learning model to generate responses based on user input and an image. The project is written in Python and uses several libraries such as Streamlit, Requests, and PyTorch.  

The main application (app.py) is a Streamlit app that allows users to input an image URL and a query. The app sends these inputs to a machine learning model, which generates a response. The response is then displayed in the app.  

The machine learning model (predict.py) uses a pre-trained model from the Hugging Face Transformers library to generate responses. It takes an image and a query as input, processes the image, and uses the pre-trained model to generate a response.  

The Makefile contains various commands for managing the project. These include commands for setting up the project, deploying the project to Kubernetes, running the project locally using Docker, and cleaning up the project.  

The README.md file provides documentation on how to use the Makefile, including descriptions of the various variables and commands.  

The project appears to be designed to run either locally using Docker or in a Kubernetes environment. It also seems to be set up for development using the Tilt tool, which helps with running services in a Kubernetes cluster during development.

## Makefile Documentation

### Variables

- **GIT_BRANCH:** Current Git branch.
- **IMAGE:** Docker image repository obtained from env/dev/values.yaml.
- **TAG:** Docker image tag obtained from env/dev/values.yaml.
- **LOCAL_PORT:** Local port for running the Docker container.
- **CONTAINER_PORT:** Container port to expose.
- **GPU_DEVICE:** GPU device number (default: 0).
- **MODEL_REPO:** Git repository URL for the model.
- **MODEL_PATH:** Local path for storing the model data.
- **KUBECONFIG:** Path to the Kubernetes configuration file.
- **CONTEXT:** Kubernetes context name.
- **NAMESPACE:** Kubernetes namespace based on the user and Git branch.
- **APP_NAME:** Application name obtained from env/dev/values.yaml.

### Help

To view available Makefile targets and their descriptions, use:

```bash
make help
```

### Setup

- `get-kubeconfig`: Fetch the kubeconfig file from gcloud secrets.

### Development
- `up`: Deploy in Kubernetes using Tilt.
- `ci`: Deploy an unattended version of the deployment in Kubernetes.
- `down`: Delete the deployment in Kubernetes, removing the namespace.
- `port-forward`: Forward the port of the deployment in Kubernetes to the local port.
Application
- `app`: Run the Streamlit app locally using Kubernetes node IP and NodePort.

### Local Docker

- `docker_run`: Run Docker locally with GPU support.
- `docker_build`: Build a Docker image for local running.
- `docker_cache`: Build and push an image to the registry for caching.
- `download_model`: Clone or pull the Git repository of the model.
- `download_docker_cache`: Download the Docker cache image.
- `check_gpu`: Check if a GPU is available in the system.

### Clean
- `clean`: Clean the repository, prompting for confirmation.

## How to use the model

1. Use `make get-kubeconfig` to get the kubeconfig file for the k8s server if you don't have it already. This file is used to interact with the k8s server.
2. If this model it's going to used by first time you'll need to use `make cache` to create an image for cache the model. This image will be used to cache the model in the first execution.
3. Run the model remotely using the makefile target `make up`. This will deploy the model in the k8s server.
4. Send a request to the model server: You can use curl to send a request to the model server. The request should be a POST request with a JSON body that includes the image and query. The image should be the URL of the image, and the query should be the question you want the model to answer about the image.

Here is an example of how you might use curl to send a request to the model server:

```bash 
curl -X POST -H "Content-Type: application/json" -d '{"input": {"image": "https://i.imgur.com/3QZ7T4p.jpg", "query": "What is in this image?"}}' http://localhost:5000/predictions
```

Replace http://localhost:5000/predictions with the actual address and port of your model server.

5. Run the Streamlit app: You can run the Streamlit app using the command `make app`. This starts the app and opens it in your web browser.
6. Use the Streamlit app: In the Streamlit app, you can enter an image URL and a query, and then click the "Submit" button to send these inputs to the model server. The app then displays the response from the model server.

## TODO

- [ ] Add support for multiple images for the model
