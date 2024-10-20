# Configure OpenLDAP

### Setup Environment Variables

```bash
NAMESPACE=flux-system \
IDENTITY_FILE=./tmp/identity \
IDENTITY_PUB_FILE=./tmp/identity.pub \
KNOWN_HOSTS_FILE=./tmp/known_hosts
```
### Create Sealed Secret

```bash
kubectl create secret generic flux-system \
  --from-file=identity=${IDENTITY_FILE} \
  --from-file=identity.pub=${IDENTITY_PUB_FILE} \
  --from-file=known_hosts=${KNOWN_HOSTS_FILE} \
  -n ${NAMESPACE} --dry-run=client -o yaml | \
  kubeseal --controller-namespace=sealed-secrets \
  --format=yaml - > ../k8s/infra/controllers/flux/gotk-secret.yaml
```
