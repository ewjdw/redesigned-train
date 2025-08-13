# TodoApi - REST API with Azure Deployment

A lightweight Todo REST API built with .NET 9, designed for cloud deployment with Infrastructure-as-Code.

## Tech Stack

- **.NET 9** - ASP.NET Core Minimal APIs
- **Docker** - Containerized deployment
- **Azure** - App Service and SQL Database
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD pipeline

## API Endpoints

| Method | Endpoint          | Description    |
| ------ | ----------------- | -------------- |
| GET    | `/health`         | Health check   |
| GET    | `/api/todos`      | Get all todos  |
| GET    | `/api/todos/{id}` | Get todo by ID |
| POST   | `/api/todos`      | Create todo    |
| PUT    | `/api/todos/{id}` | Update todo    |
| DELETE | `/api/todos/{id}` | Delete todo    |

## Local Development

### Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Docker on wsl](https://get.docker.com)

### Quick Start

```bash
# Clone repository
git clone <repository-url>
cd redesigned-train/src

# Run application
dotnet run --project TodoApi

# Application runs on http://localhost:5293
# Test: curl http://localhost:5293/health
# POST with curl: curl -X POST http://localhost:5293/api/todos -H "Content-Type: application/json" -d "{\"title\":\"My first todo\"}"
# Post with PS: Invoke-WebRequest -Uri "http://localhost:5293/api/todos" -Method POST -ContentType "application/json" -Body '{"title":"My first todo"}'
# GET all todos: curl http://localhost:5293/api/todos
# GET todo by id: Invoke-WebRequest -Uri "http://localhost:5293/api/todos/1"
# PUT todo 1: curl -X PUT http://localhost:5293/api/todos/1 -H "Content-Type: application/json" -d "{\"isCompleted\":true}"
```

### Run with Docker

```bash
# Build and run
docker build -t todo-api:latest .
docker run -d -p 8080:8080 todo-api:latest

```

### Testing

```bash
cd src/TodoApi.Tests
dotnet test
```

## Infrastructure

### Architecture

The application uses Terraform for infrastructure management with the following resources:

- **App Service** - Linux container hosting
- **SQL Database** - Production data storage
- **SQL Server** - Database server (MSSQL)
- **Container Registry** - Docker image storage
- **Service Plan** - App Service hosting plan

Specifically, App Service and Service Plan are deployed through **appservice** module, whereas SQL Database is deployed through **sql** module along the SQL server.

### Environment Configuration

- **Development environments** (dev, test, staging): `ASPNETCORE_ENVIRONMENT=Development`
- **Production environments** (prod, uat): `ASPNETCORE_ENVIRONMENT=Production`

### Database Connectivity

The application supports dual-mode operation:

- **Database mode**: Uses SQL Server with managed identity authentication
- **In-memory mode**: Automatic fallback if database is unavailable

## Deployment

### Pipeline Architecture

The CI/CD pipeline implements a "build once, deploy everywhere" strategy with sequential deployment:

1. **Build**: Single .NET build and Docker image creation
2. **Terraform Discovery**: Queries Terraform state for environment-specific resource names
3. **Sequential Deployment**: Deploys to environments in order (dev → test → uat → prod) using discovered resources

### Required GitHub Secrets

```
AZURE_CREDENTIALS - Service Principal credentials (JSON)
TERRAFORM_BACKEND_STORAGE_ACCOUNT - Terraform state storage account
AZURE_SUBSCRIPTION_ID - Azure subscription ID
```

### Terraform Outputs

Your Terraform configuration must provide these outputs:

```terraform
output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "app_service_name" {
  value = azurerm_linux_web_app.main.name
}
```

### Environment States

Terraform maintains separate state files:

- `terraform-dev.tfstate` - Development environment
- `terraform-prod.tfstate` - Production environment
- `terraform-{env}.tfstate` - Additional environments

## Configuration

### App Settings

The application uses these configuration keys:

- `ConnectionStrings__DefaultConnection` - SQL Server connection string
- `UseDatabase` - Enable/disable database mode
- `ASPNETCORE_ENVIRONMENT` - Runtime environment
- `ASPNETCORE_URLS` - Binding URLs

### Health Checks

The `/health` endpoint provides basic application health status and is used by:

- Azure App Service health monitoring
- Load balancer health probes
- CI/CD pipeline validation

## Adding New Environments

1. **Create Terraform state**: Deploy infrastructure with environment-specific state file
2. **Update pipeline**: Add environment to the deployment matrix
3. **No secrets needed**: Resources are discovered automatically from Terraform
