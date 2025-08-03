set -e

terraform output -json > terraform_output.json

declare -A tf_vars=(
[sql_fqdn]=sql_server_fqdn
[sql_db]=sql_database_name
[app_principal_id]=app_service_principal_id
)

for var_name in "${!tf_vars[@]}"; do
tf_output="${tf_vars[$var_name]}"
var_value=$(jq -r .${tf_output}.value terraform_output.json)
echo "$var_name=$var_value" >> $GITHUB_ENV
done
