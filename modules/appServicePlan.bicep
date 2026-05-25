param name string
param location string = resourceGroup().location

param sku object = {
  name: 'S1'
  tier: 'Standard'
  capacity: 1
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: name
  location: location
  sku: sku
  kind: 'linux'
}

output id string = appServicePlan.id
