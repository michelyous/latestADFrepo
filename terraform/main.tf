provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "adf_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_data_factory" "adf" {
  name                = var.adf_name
  resource_group_name = azurerm_resource_group.adf_rg.name
  location            = var.location
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "adf_name" {
  description = "ADF Name"
  type = string
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "source" {
  name            = "source-storage"
  data_factory_id = azurerm_data_factory.adf.id
  connection_string = data.azurerm_storage_account.example.primary_connection_string
}

data "azurerm_storage_account" "example" {
  name                = "mystorageaccountname"
  resource_group_name = azurerm_resource_group.adf_rg.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "destination" {
  name                = "destination-storage"
  data_factory_id = azurerm_data_factory.adf.id
  connection_string = data.azurerm_storage_account.example.primary_connection_string
}

resource "azurerm_data_factory_pipeline" "copy_data" {
  name                = "copy_data_pipeline"
  data_factory_id = azurerm_data_factory.adf.id

  activities_json = <<JSON
[
    {
        "name": "copy_data_activity",
        "type": "Copy",
        "inputs": [
          {
            "referenceName" = "input_blob",
            "type"           = "DatasetReference"
          }
        ],
        "outputs": [
          {
            "referenceName" = "output_blob",
            "type"           = "DatasetReference"
          }
        ],

        "typeProperties": [
          "source": {
            "type" = "BlobSource",
            "blobPathPrefix" = "inputcontainer/inputblob.csv"
          },
          "sink": {
             "type" = "BlobSink",
              "blobPathPrefix" = "outputcontainer/outputblob.csv"
          },
          "copyBehavior" = "PreserveHierarchy"
        ],

        "policy": [
          {
            "concurrency" = 1,
            "execution_order" = 0
          }
        ]
    }
]
  JSON
}