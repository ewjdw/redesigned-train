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

variable "azure_tenant_id" {
  description = "The Azure tenant ID for the deployment"
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

variable "vnet_range" {
  description = "The CIDR range for the virtual network"
  type        = string
  
}

variable "spn" {
  description = "Service Principal details for the deployment"
  type = object({
    display_name = string
    object_id    = string
  })
  
}

variable "db_config" {
  description = "Configuration for SQL resources including database SKU and storage account type"
  type        = object({
    database_sku_name    = string
    storage_account_type = string
  })
  
}

variable "app_service_plan_sku_name" {
  description = "The SKU name for the App Service Plan"
  type        = string
  
}