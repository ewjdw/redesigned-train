variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string  

}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  
}

variable "subscription_id" {
  description = "The Azure subscription ID to use for the deployment"
  type        = string
  
}

variable "workload" {
  description = "The workload type for the deployment (e.g., app)"
  type        = string
  
}

variable "acr_sku" {
  description = "The SKU for the Azure Container Registry"
  type        = string
  
}

variable "sql_config" {
  description = "Configuration for the SQL server and database"
  type = object({
    sql_admin_login    = string
    sql_admin_password = string
    database_sku_name  = string
  })
  
}
