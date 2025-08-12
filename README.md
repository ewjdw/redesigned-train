# TodoApp - REST API with Azure Deployment

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
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (optional)

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
