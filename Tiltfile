print("""
-----------------------------------------------------------------
✨ Hello Tilt! This appears in the (Tiltfile) pane whenever Tilt
   evaluates this file.
-----------------------------------------------------------------
""".strip())

load('ext://namespace', 'namespace_create', 'namespace_inject')
load('ext://color', 'color')
load('ext://helm_resource', 'helm_resource')

# Contexts allowed for this Tiltfile
allow_k8s_contexts('aime-k3s')
allow_k8s_contexts('default')

# Setup
values = read_yaml('./env/dev/values.yaml')
image_name = values.get('image').get('repository')
namespace = str(local("echo $USER-$(git rev-parse --abbrev-ref HEAD) | cut -c 1-63 | tr '_' '-' | tr '/' '-' | tr '[:upper:]' '[:lower:]'", echo_off=True, quiet=True)).strip()
release_name = 'cogvlm-model-chart'

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

# Create the namespace and service account
#namespace_create(namespace)

# Inject the namespace into the Helm chart
#k8s_resource(new_name='Creating sandbox resources: ' + namespace, objects=[namespace+':Namespace:default'])

helm_resource(
    'Sandbox helm release',
    './chart/cogvlm',
    namespace=namespace,
    release_name=release_name,
    deps=['./chart/cogvlm', './env/dev'],
    image_selector=image_name,
    image_deps=[image_name],
    image_keys=[('image.repository', 'image.tag')],
    flags=[
        '--create-namespace',
        '--values=./env/dev/values.yaml'
    ]
)

#k8s_yaml(helm('./chart/cogvlm', values=['./env/dev/values.yaml'], namespace=namespace, name=release_name))
# Resolves undefined

"""
k8s_resource(    workload='cogvlm-model-chart',
    port_forwards="5001:5000",
)

local_resource(
    "Access URL",
    "echo " + str(os.putenv('NODEPORT' ,"$(kubectl get svc " + release_name + " -n " + namespace + " -o=jsonpath='{.spec.ports[0].nodePort'}")),
    resource_deps = [release_name],
)

local_resource(
    "print env",
    "printenv",
    resource_deps = ['Access URL'],
)


#k8s_resource(new_name='cogVLM Model', objects=['cogvlm-model-chart:ServiceAccount:apalma-main'])
"""

"""

# Deploy the COG Helm chart


"""

"""


# Forward the COG service

k8s_resource(
    workload='CogVLM Model',
    port_forwards="5001:5000",
    links=[
        link('http://95.173.102.51:' + str(server_port).strip(), 'Public URL')
    ],
)


print(""
-----------------------------------------------------------------

✨ To access the api, use the IP 95.173.102.51, and the port: "" + str(server_port).strip() + ""

http://95.173.102.51:"" + str(server_port).strip() + ""

-----------------------------------------------------------------
"")

"""
