include common.mk

#TERRAFORM

vm:
	$(info TERRAFORM: Creating VM)
	cd tf && \
		tofu init && \
		tofu plan -out vm.tfplan && \
		tofu apply vm.tfplan

destroy:
	$(info TERRAFORM: Destroying VM)
	cd tf && \
		tofu plan -destroy -out=destroy.tfplan && \
		tofu apply destroy.tfplan

