set -e

az login --service-principal \
  --username "$AZURE_CLIENT_ID" \
  --password "$AZURE_CLIENT_SECRET" \
  --tenant "$AZURE_TENANT_ID" \
  --allow-no-subscriptions

az account set --subscription "$AZURE_SUBSCRIPTION_ID"

sqlcmd -S "$SQL_FQDN" \
  -d "$SQL_DB" \
  -U "$SQL_ADMIN_LOGIN" \
  -P "$SQL_ADMIN_PASSWORD" \
  -Q "DROP USER IF EXISTS [$APP_PRINCIPAL_ID]; \
      CREATE USER [$APP_PRINCIPAL_ID] FROM EXTERNAL PROVIDER; \
      ALTER ROLE db_datareader ADD MEMBER [$APP_PRINCIPAL_ID]; \
      ALTER ROLE db_datawriter ADD MEMBER [$APP_PRINCIPAL_ID];"
