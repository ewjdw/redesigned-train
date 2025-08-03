$ErrorActionPreference = "Stop"

Write-Host "Creating or updating database user..."

try {
  $sqlCommand = @"
DROP USER IF EXISTS [$($env:APP_PRINCIPAL_ID)];
CREATE USER [$($env:APP_PRINCIPAL_ID)] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$($env:APP_PRINCIPAL_ID)];
ALTER ROLE db_datawriter ADD MEMBER [$($env:APP_PRINCIPAL_ID)];
"@

  sqlcmd -S $env:SQL_FQDN `
    -d $env:SQL_DB `
    -U $env:AZURE_CLIENT_ID `
    -P $env:AZURE_CLIENT_SECRET `
    -Q $sqlCommand `
    --authentication-method ActiveDirectoryServicePrincipal

}
catch {
  throw $LASTEXITCODE
}
