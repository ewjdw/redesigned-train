set -e

curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl -sSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list

sudo sed -i 's|deb |deb [signed-by=/usr/share/keyrings/microsoft-prod.gpg] |' /etc/apt/sources.list.d/microsoft-prod.list

sudo apt-get update

sudo ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

export PATH="$PATH:/opt/mssql-tools/bin"
