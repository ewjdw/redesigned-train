$ErrorActionPreference = "Stop"

Write-Host "Creating or updating database user..."

try {
  $sqlCommand = @"
DROP USER IF EXISTS [$($env:APP_PRINCIPAL_ID)];
CREATE USER [$($env:APP_PRINCIPAL_ID)] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$($env:APP_PRINCIPAL_ID)];
ALTER ROLE db_datawriter ADD MEMBER [$($env:APP_PRINCIPAL_ID)];
"@

  az login --service-principal --username $env:AZURE_CLIENT_ID --password $env:AZURE_CLIENT_SECRET --tenant $env:AZURE_TENANT_ID
  $accessToken = az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv
  Invoke-Sqlcmd -Query $sqlCommand -ServerInstance $env:SQL_FQDN -Database $env:SQL_DB -AccessToken $accessToken

  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create or update database user."
    exit $LASTEXITCODE
  } else {
    Write-Host "Database user created or updated successfully."
  }
}
catch {
  throw $LASTEXITCODE
}
