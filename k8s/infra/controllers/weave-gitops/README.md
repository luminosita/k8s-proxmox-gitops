# Configure Weave Gitops 

```bash
NAMESPACE=flux-system
PASSWORD="<your password>"
echo -n $PASSWORD | htpasswd -niBC 10 User
User:$2a$10$OS5NJmPNEb13UgTOSKnMxOWlmS7mlxX77hv4yAiISvZ71Dc7IuN3q
```
Now create a Kubernetes secret to store your chosen username and the password hash:

```bash
$ kubectl create secret generic cluster-user-auth \
    --from-literal=username=admin \
    --from-literal=password='$2y$10$FU6NtYFxidoyq1gw8aW6HeneBjZ.OlaPTPRnALhkx8QStbztKubyy' \
    -n ${NAMESPACE} --dry-run=client -o yaml | \
    kubeseal --controller-namespace=sealed-secrets \
    --format=yaml - > ../k8s/infra/controllers/weave-gitops/credentials.yaml
```