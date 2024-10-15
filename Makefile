include common.mk

#TERRAFORM

vm:
	$(info TERRAFORM: Creating VM)
	cd tf && \
		terraform init && \
		terraform plan -out vm.tfplan && \
		terraform apply vm.tfplan

destroy:
	$(info TERRAFORM: Destroying VM)
	cd tf && \
		terraform plan -destroy -out=destroy.tfplan && \
		terraform apply destroy.tfplan

