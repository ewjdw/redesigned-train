$ErrorActionPreference = "Stop"

Write-Host "Creating or updating database user..."

try {
  az login --service-principal `
    --username $env:AZURE_CLIENT_ID `
    --password $env:AZURE_CLIENT_SECRET `
    --tenant $env:AZURE_TENANT_ID `
    --allow-no-subscriptions

  az account set --subscription $env:AZURE_SUBSCRIPTION_ID

  write-host "fqdn: $($env:SQL_FQDN)"
  write-host "db: $($env:SQL_DB)"
  write-host "app principal id: $($env:APP_PRINCIPAL_ID)"

  $sqlCommand = @"
DROP USER IF EXISTS [$($env:APP_PRINCIPAL_ID)];
CREATE USER [$($env:APP_PRINCIPAL_ID)] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$($env:APP_PRINCIPAL_ID)];
ALTER ROLE db_datawriter ADD MEMBER [$($env:APP_PRINCIPAL_ID)];
"@

  sqlcmd -S $env:SQL_FQDN `
    -d $env:SQL_DB `
    -U $env:SQL_ADMIN_LOGIN `
    -P $env:SQL_ADMIN_PASSWORD `
    -Q $sqlCommand

}
catch {
  throw $LASTEXITCODE
}
