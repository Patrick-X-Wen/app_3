@description('Deployment environment (dev, qa, uat, prod)')
param env string = 'dev'

@description('Azure region')
param location string = resourceGroup().location

// ====================== Naming ======================
param appServicePlanName string = 'asp-${env}-${uniqueString(resourceGroup().id)}'
param webAppName string = 'app-${env}-${uniqueString(resourceGroup().id)}'
param sqlServerName string = 'sql-${env}-${uniqueString(resourceGroup().id)}'
param sqlDatabaseName string = 'mydb'
param vnetName string = 'vnet-${env}'
param managedIdentityName string = 'mi-${env}-${uniqueString(resourceGroup().id)}'

// ====================== SQL Admin ======================
@description('Azure AD Admin login name (user or group)')
param azureAdAdminLogin string = 'sqladmins'

@description('Azure AD Object ID of the admin user or group')
param azureAdAdminObjectId string

// ====================== Deploy User-Assigned Managed Identity ======================
module userIdentity './modules/userManagedIdentity.bicep' = {
  name: 'deployUserIdentity'
  params: {
    name: managedIdentityName
    location: location
  }
}

// ====================== Deploy VNet ======================
module vnet './modules/vnet.bicep' = {
  name: 'deployVnet'
  params: {
    name: vnetName
    location: location
  }
}

// ====================== Deploy App Service Plan ======================
module appPlan './modules/appServicePlan.bicep' = {
  name: 'deployAppServicePlan'
  params: {
    name: appServicePlanName
    location: location
  }
}

// ====================== Deploy Web App (with User-Assigned Identity) ======================
module webApp './modules/webApp.bicep' = {
  name: 'deployWebApp'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appPlan.outputs.id
    vnetIntegrationSubnetId: vnet.outputs.appSubnetId
    userAssignedIdentityId: userIdentity.outputs.id   // ← User Assigned Identity
  }
}

// ====================== Deploy SQL Server ======================
module sqlServer './modules/sqlServer.bicep' = {
  name: 'deploySqlServer'
  params: {
    name: sqlServerName
    location: location
    azureAdAdminLogin: azureAdAdminLogin
    azureAdAdminObjectId: azureAdAdminObjectId
  }
}

// ====================== Deploy SQL Database ======================
module sqlDatabase './modules/sqlDatabase.bicep' = {
  name: 'deploySqlDatabase'
  params: {
    sqlServerName: sqlServer.outputs.name
    databaseName: sqlDatabaseName
  }
}

// ====================== Deploy Private Endpoint ======================
module sqlPrivateEndpoint './modules/privateEndpoint.bicep' = {
  name: 'deploySqlPrivateEndpoint'
  params: {
    name: 'pe-${sqlServerName}'
    location: location
    subnetId: vnet.outputs.peSubnetId
    privateLinkResourceId: sqlServer.outputs.id
  }
}

// ====================== Outputs ======================
output webAppUrl string = 'https://${webApp.outputs.defaultHostName}'
output managedIdentityClientId string = userIdentity.outputs.clientId
output managedIdentityPrincipalId string = userIdentity.outputs.principalId
output sqlFullyQualifiedDomainName string = '${sqlServer.outputs.name}${environment().suffixes.sqlServerHostname}'
