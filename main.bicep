param location string = 'westeurope'
param networkInterfaceName string = 'nestedkvmnic'
param networkSecurityGroupName string = 'nestedkvm-nsg'
param networkSecurityGroupRules array = [
  {
    name: 'SSH'
    properties: {
      priority: 300
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '22'
    }
  }
]
param subnetName string = 'default'
param virtualNetworkName string = 'nestedkvm-vnet'
param addressPrefixes array = [
  '10.0.0.0/16'
]
param subnets array = [
  {
    name: 'default'
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
]
param publicIpAddressName string = 'nestedkvm-ip'
param publicIpAddressType string = 'Static'
param publicIpAddressSku string = 'Standard'
param pipDeleteOption string = 'Detach'
param virtualMachineName string = 'nestedkvm'
param virtualMachineComputerName string = 'nestedkvm'
param osDiskType string = 'Premium_LRS'
param osDiskDeleteOption string = 'Detach'
param virtualMachineSize string = 'Standard_D4s_v3'
param nicDeleteOption string = 'Detach'
param imageId string
param adminUsername string

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetName = virtualNetworkName
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
            properties: {
              deleteOption: pipDeleteOption
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroup
    virtualNetwork
    publicIpAddress
  ]
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

resource publicIpAddress 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  sku: {
    name: publicIpAddressSku
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        id: imageId
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output adminUsername string = adminUsername
