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

  try {
    az role assignment create --assignee $env:SQL_PRINCIPAL_ID --role "88d8e3e3-8f55-4a1e-953a-9b9898b8876b" --scope "/"
    Start-Sleep -Seconds 30
  }
  catch {
    Write-Error "role assignment failed: $($_.Exception.Message)"
  }
  
  try {
    Invoke-Sqlcmd -Query $sqlCommand -ServerInstance $env:SQL_FQDN -Database $env:SQL_DB -AccessToken $accessToken
  }
  catch {
    Write-Error "invoke-sqlcmd failed: $($_.Exception.Message)"
    exit 1
  }

}
catch {
  Write-Error "$($_.Exception.Message)"
  exit 1
}
