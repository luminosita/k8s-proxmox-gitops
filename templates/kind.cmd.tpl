cat <<EOF | DOCKER_HOST=${ip} kind create cluster --image=kindest/node:v1.31.1 --name ${name} --config=-
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
networking:
  apiServerAddress: "${ip}"
  apiServerPort: 6443
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        listenAddress: "0.0.0.0"
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        listenAddress: "0.0.0.0"
        protocol: TCP
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:  
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
  - role: worker
EOF
