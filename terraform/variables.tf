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

variable "sql_admin_password" {
  description = "The administrator password for the SQL server"
  type        = string
  sensitive   = true
  
}

variable "sql_admin_login" {
  description = "The administrator login for the SQL server"
  type        = string
  
}

variable "sql_config" {
  description = "Configuration for SQL resources including database SKU and storage account type"
  type        = object({
    database_sku_name    = string
    storage_account_type = string
  })
  
}
