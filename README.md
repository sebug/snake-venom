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

Set the following variables in your code space: build_client_id, build_client_secret, build_tenant_id, build_subscription_id

These environment variables are then referenced in the ubuntu.pkr.hcl file.

Now download packer (you can find the latest version [here](https://developer.hashicorp.com/packer/downloads))

    curl -O https://releases.hashicorp.com/packer/1.9.1/packer_1.9.1_linux_amd64.zip
    unzip packer_1.9.1_linux_amd64.zip
    ./packer --help

If that works you're ready to go.

    ./packer build ubuntu.pkr.hcl

note the generated image id (of the form /subscriptions/.../resourceGroups/ImageBuildRG/providers/Microsoft.Compute/images/nestedKVMImage ) - you'll need that once once you deploy the bicep template

Create a resource group SnakeVenomRG. Go back to the cloud shell

    git clone https://github.com/sebug/snake-venom
    cd snake-venom
    az deployment group create -f ./main.bicep -g SnakeVenomRG

After that you should be able to Bastion to your machine. startx so that you can deal with the different VMs you're going to create (I know this is a ridiculous amount of overhead to have the full desktop installed, but it's a tradeoff we make when we are not able to use a physical machine).
