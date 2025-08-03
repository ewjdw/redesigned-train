variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string
  
}

variable "workload" {
  description = "The workload type for the deployment (e.g., app)"
  type        = string
  
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  
}

variable "resource_group_name" {
  description = "The name of the resource group where resources will be deployed"
  type        = string
  
}

variable "sql_server_name" {
  description = "The name of the SQL server to be created"
  type        = string
  
}

variable "administrator_login" {
  description = "The administrator login for the SQL server"
  type        = string
  
}

variable "administrator_password" {
  description = "The administrator password for the SQL server"
  type        = string
  sensitive   = true
  
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
  
}

variable "database_sku_name" {
  description = "The SKU name for the SQL database"
  type        = string
  
}

variable "storage_account_type" {
  description = "The storage account type for the SQL database backup"
  type        = string
  
}
