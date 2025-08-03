set -e

terraform output -json > terraform_output.json

declare -A tf_vars=(
[SQL_FQDN]=sql_server_fqdn
[SQL_DB]=sql_database_name
[APP_PRINCIPAL_ID]=app_service_principal_id
)

for var_name in "${!tf_vars[@]}"; do
tf_output="${tf_vars[$var_name]}"
var_value=$(jq -r .${tf_output}.value terraform_output.json)
echo "$var_name=$var_value" >> $GITHUB_ENV
done
