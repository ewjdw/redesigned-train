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

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
  
}

variable "sku_name" {
  description = "The SKU name for the App Service Plan"
  type        = string
  
}

variable "acr_login_server" {
  description = "The login server URL for the Azure Container Registry"
  type        = string
  
}

variable "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  type        = string
  
}

variable "sql_database_name" {
  description = "The name of the SQL database to be created"
  type        = string
  
}

variable "subnet_id" {
  description = "The ID of the subnet where the App Service will be deployed"
  type        = string
  
}

variable "dns_zone_name" {
  description = "The name of the private DNS zone for the App Service"
  type        = string
  default = "privatelink.azurewebsites.net"
  
}

variable "dns_zone_id" {
  description = "The ID of the private DNS zone for the App Service"
  type        = string
  
}
