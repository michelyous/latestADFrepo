provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "adf_rg" {
  name     = "myResourceGroup"
  location = "francecentral"
}

resource "azurerm_data_factory" "adf" {
  name                = "myADF"
  resource_group_name = "myResourceGroup"
  location            = "francecentral"
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