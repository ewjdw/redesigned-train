$ErrorActionPreference = "Stop"

Write-Host "Creating or updating database user..."

try {
  $accessToken = az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv

  $sqlCommand = @"
DROP USER IF EXISTS [$($env:APP_SERVICE_NAME)];
CREATE USER [$($env:APP_SERVICE_NAME)] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$($env:APP_SERVICE_NAME)];
ALTER ROLE db_datawriter ADD MEMBER [$($env:APP_SERVICE_NAME)];
"@
  
  try {
    Invoke-Sqlcmd -Query $sqlCommand -ServerInstance $env:SQL_FQDN -Database $env:SQL_DB -AccessToken $accessToken
    Write-Host "Database user [$($env:APP_SERVICE_NAME)] created or updated successfully."
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
