print("""
-----------------------------------------------------------------
✨ Hello Tilt! This appears in the (Tiltfile) pane whenever Tilt
   evaluates this file.
-----------------------------------------------------------------
""".strip())
load('ext://helm_remote', 'helm_remote')

# Contexts allowed for this Tiltfile
allow_k8s_contexts('aime-k3s')

# Setup
values = read_yaml('./env/dev/values.yaml')
image_name = values.get('image').get('repository')
release_name = values.get('name')
namespace = str(local("echo $USER-$(git rev-parse --abbrev-ref HEAD) | cut -c 1-63 | tr '_' '-' | tr '/' '-' | tr '[:upper:]' '[:lower:]'", echo_off=True, quiet=True)).strip()
chart_name = "cog-ai-model"

# Download the Docker image cache for COG
local_resource(
    'Download Docker image cache for COG',
    'docker pull ' + image_name + ':cache'
)

# Build the COG image
custom_build(
  image_name,
  'cog push $EXPECTED_REF',
  deps=['predict.py'],
)


helm_remote(
    chart_name,
    repo_url='https://freepik-company.github.io/internal-helm-charts',
    values=['./env/dev/values.yaml'],
    release_name=release_name,
    namespace=namespace,
    create_namespace=True,
)

k8s_resource(
    workload=release_name + '-' + chart_name,
    port_forwards=port_forward(5001,5000,name='Local Port Forward'),
    links = [
        link('http://fobar.com', 'HTTP sandbox Domain'),
        link('tcp://fobar.com', 'GRPC sandbox Domain')
    ]
)

k8s_resource(new_name='Creating service-account', objects=[release_name + '-' + chart_name + ':ServiceAccount:'+ namespace, namespace+':Namespace:default'])
