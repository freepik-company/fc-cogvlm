## 0.1.0 (2023-12-15)

### Feat

- include the context download from secret in the kubeconfig of the user
- write customs links and log lines to showcase the IP  port that must be used
- get kubeconfig from secret with Makefile
- change service type to NodePort to work properly with AIME
- update Makefile to work with tilt
- create base tiltfile

### Fix

- remove temporarily the info of ip:port in tilt due to a bug
- remove depth=1 to download the whole repository
