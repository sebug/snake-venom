# snaKe VenoM - nested KVM lab environment
This launches a single-VM KVM instance in the cloud that has nested VMs - inspired by https://www.exoscale.com/syslog/install-kvm-on-a-virtual-machine-to-get-nested-instances/

Basically just so I have a lab environment to test out KVM.

There will be quite a lot to install on the VM, so I'm thinking of creating a template with [Packer](https://www.packer.io/)

[Microsoft Learn how-to](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer)

Launch a cloud shell

Set the right subscription:

    az account set --subscription ...
    az group create -n ImageBuildRG -l westeurope
    az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription_id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
    az account show --query "{ subscription_id: id }"

Set the following variables in your code space: client_id, client_secret, tenant_id, subscription_id