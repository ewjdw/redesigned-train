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

variable "object_id" {
  description = "The object ID of the Azure AD administrator for the SQL server"
  type        = string
  
}

variable "display_name" {
  description = "The display name of the Azure AD administrator for the SQL server"
  type        = string
  
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

variable "subnet_id" {
  description = "The ID of the subnet where the private endpoint will be created"
  type        = string
  
}

variable "dns_zone_id" {
  description = "The name of the private DNS zone ID for SQL"
  type        = string
  
}

variable "dns_zone_name" {
  description = "The name of the private DNS zone name for SQL"
  type        = string
  default     = "privatelink.database.windows.net"
  
}
