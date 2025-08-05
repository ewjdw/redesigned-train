$ErrorActionPreference = "Stop"

Write-Host "Creating or updating database user..."

try {
  $sqlCommand = @"
DROP USER IF EXISTS [$($env:APP_PRINCIPAL_ID)];
CREATE USER [$($env:APP_PRINCIPAL_ID)] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$($env:APP_PRINCIPAL_ID)];
ALTER ROLE db_datawriter ADD MEMBER [$($env:APP_PRINCIPAL_ID)];
"@

  # az login --service-principal --username $env:AZURE_CLIENT_ID --password $env:AZURE_CLIENT_SECRET --tenant $env:AZURE_TENANT_ID
  $accessToken = az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv
  
  try {
    Invoke-Sqlcmd -Query $sqlCommand -ServerInstance $env:SQL_FQDN -Database $env:SQL_DB -AccessToken $accessToken
    # sqlcmd -S $env:SQL_FQDN -d $env:SQL_DB --authenticationMethod ActiveDirectoryServicePrincipal -U $env:APP_PRINCIPAL_ID -P $env:APP_PRINCIPAL_ID -Q $sqlCommand
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
