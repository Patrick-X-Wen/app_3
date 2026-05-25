param name string
param location string = resourceGroup().location
param appServicePlanId string
param vnetIntegrationSubnetId string = ''
param userAssignedIdentityId string

resource webApp 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
    }
  }
}

// VNet Integration for outbound traffic
resource vnetIntegration 'Microsoft.Web/sites/networkConfig@2024-04-01' = if (!empty(vnetIntegrationSubnetId)) {
  parent: webApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

output id string = webApp.id
output defaultHostName string = webApp.properties.defaultHostName
