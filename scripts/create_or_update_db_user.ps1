$ErrorActionPreference = "Stop"

Write-Host "Creating or updating database user..."

try {
  sqlcmd -S $env:SQL_FQDN `
    -d $env:SQL_DB `
    --authentication-method ActiveDirectoryServicePrincipal `
    -U $env:AZURE_CLIENT_ID `
    -P $env:AZURE_CLIENT_SECRET `
    -Q DROP USER IF EXISTS [$($env:APP_PRINCIPAL_ID)]; `
    -Q CREATE USER [$($env:APP_PRINCIPAL_ID)] FROM EXTERNAL PROVIDER; `
    -Q ALTER ROLE db_datareader ADD MEMBER [$($env:APP_PRINCIPAL_ID)]; `
    -Q ALTER ROLE db_datawriter ADD MEMBER [$($env:APP_PRINCIPAL_ID)];

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
