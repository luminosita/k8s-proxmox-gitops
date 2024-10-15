#!/bin/bash
mkdir -p ../output 
scp  -i \"~/.ssh/id_rsa\" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$IP:/home/ubuntu/.kube/config ../output/$NAME-kube-config.yaml

#FIXME sed -i is not working in this case
sed "s/127\.0\.0\.1/$IP/" ../output/$NAME-kube-config.yaml > ../output/temp.yaml
mv ../output/temp.yaml ../output/$NAME-kube-config.yaml