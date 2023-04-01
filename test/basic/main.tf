terraform {
  required_version = "~> 1.1"
  backend "azurerm" {
    resource_group_name  = "statestorage"
    storage_account_name = "charlesstorage123"
    container_name       = "statefile"
    key                  = "charles.tfstate"

  }
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "~> 3.9"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.0"
    }

  }
}

provider "azurerm" {

  features {

  }
}

resource "azurerm_resource_group" "test" {
  location = "westus"
  name     = "test-basic"
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999

  keepers = {
    randomness = azurerm_resource_group.test.name
  }
}

module "storage_module" {
  source              = "../.."
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datalake = {
    name                   = lower(format("%spractice%s", "charles", random_integer.suffix.result))
    tier                   = "Standard"
    replication_type       = "LRS"
    data_retention_in_days = 7
    containers             = ["gcp", "google", "aws", "charles"]

  }
  depends_on = [
    azurerm_resource_group.test
  ]
}



