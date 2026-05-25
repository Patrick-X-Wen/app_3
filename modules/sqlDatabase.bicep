param sqlServerName string
param databaseName string

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  name: '${sqlServerName}/${databaseName}'
  location: resourceGroup().location
  
  sku: {
    name: 'S0'
    tier: 'Standard'
  }

  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

output id string = sqlDatabase.id
