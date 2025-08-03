terraform {
    backend "azurerm" {
        resource_group_name  = "rg-tfstate-shared"
        storage_account_name = "#{backendStorageAccount}#"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }
}
