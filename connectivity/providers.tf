terraform {
  required_version = "~> 1.14.5"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.47"
    }
  }

  ### DO NOT USE LOCAL TF STATE IN PRODUCTION ENVIRONMENTS!
  ### Uncomment the below block to enable remote state management with Azure Storage Account. 
  ### Use Entra ID Auth (use_azuread_auth) whenever possible to avoid hardcoding credentials.
  ### Make sure to replace the storage account name, container name, and key with your own values.

  /*
  backend "azurerm" {
    use_azuread_auth     = true
    storage_account_name = ""
    container_name       = ""
    key                  = "firewall-rules.tfstate"
  }
  */
}

provider "azurerm" {
  features {}
  #subscription_id = ""
}

provider "azapi" {
  #subscription_id = ""
}
