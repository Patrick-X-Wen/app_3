param name string
param location string = resourceGroup().location
param subnetId string
param privateLinkResourceId string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: name
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: privateLinkResourceId
          groupIds: ['sqlServer']
        }
      }
    ]
  }
}

output id string = privateEndpoint.id
