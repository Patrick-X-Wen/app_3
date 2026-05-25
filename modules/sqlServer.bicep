param name string
param location string = resourceGroup().location

@description('Azure AD Admin login name')
param azureAdAdminLogin string

@description('Azure AD Admin Object ID')
param azureAdAdminObjectId string

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: name
  location: location
  properties: {
    version: '12.0'
    publicNetworkAccess: 'Disabled'
    administrators: {
      login: azureAdAdminLogin
      sid: azureAdAdminObjectId
      azureADOnlyAuthentication: true
    }
  }
}

output id string = sqlServer.id
output name string = sqlServer.name
