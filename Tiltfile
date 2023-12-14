print("""
-----------------------------------------------------------------
✨ Hello Tilt! This appears in the (Tiltfile) pane whenever Tilt
   evaluates this file.
-----------------------------------------------------------------
""".strip())

load('ext://namespace', 'namespace_create', 'namespace_inject')

allow_k8s_contexts('aime-k3s')

values = read_yaml('./env/dev/values.yaml')
image_name = values.get('image').get('repository')
namespace = str(local("echo $USER-$(git rev-parse --abbrev-ref HEAD) | cut -c 1-63 | tr '_' '-' | tr '/' '-' | tr '[:upper:]' '[:lower:]'", echo_off=True, quiet=True)).strip()


local_resource(
    'Download Docker image cache for COG',
    'docker pull ' + image_name + ':cache'
)

custom_build(
  image_name,
  'cog push $EXPECTED_REF',
  deps=['predict.py'],
)

namespace_create(namespace)
k8s_resource(new_name='Creating namespace: ' + namespace, objects=[ namespace+':Namespace:default'])
k8s_resource(new_name='Creating service-account: ', objects=['chart-cogvlm:ServiceAccount:'+ namespace])



k8s_yaml(helm('./chart/cogvlm', values=['./env/dev/values.yaml'], namespace=namespace))

k8s_resource(workload='chart-cogvlm', port_forwards=5001)

