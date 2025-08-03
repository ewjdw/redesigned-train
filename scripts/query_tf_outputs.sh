set -e

echo "Setting up sql_fqdn"
SQL_FQDN=$(terraform output -raw sql_server_fqdn)
echo "sql_fqdn=$SQL_FQDN" >> $GITHUB_OUTPUT

echo "Setting up sql_db"
SQL_DB=$(terraform output -raw sql_database_name)
echo "sql_db=$SQL_DB" >> $GITHUB_OUTPUT

echo "Setting up app_principal_id"
APP_PRINCIPAL_ID=$(terraform output -raw app_service_principal_id)
echo "app_principal_id=$APP_PRINCIPAL_ID" >> $GITHUB_OUTPUT
