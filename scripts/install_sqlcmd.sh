set -e

curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl -sSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

sudo apt-get update

sudo ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

export PATH="$PATH:/opt/mssql-tools/bin"
