resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}

# Datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
  include_preview = false  
}
 # create Azure Container registry
 module "acr" {
  source = "./modules/acr"
  resource_group_name = var.resource_group_name
  location = var.location
  acr_name = var.acr_name
  acr_sku = var.acr_sku
  tags = var.tags
  
 }
# resource "azurerm_user_assigned_identity" "identity" {
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   name                = "identitynewlook"
# }
 resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = module.acr.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
  
  depends_on = [
    module.acr
  ]
}
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                  = "newlookapi-aks-cluster"
  location              = var.location
  resource_group_name   = var.resource_group_name
  dns_prefix            = "${var.resource_group_name}-cluster"           
  kubernetes_version    =  data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${var.resource_group_name}-nrg"
  
  default_node_pool {
    name       = "defaultpool"
    vm_size    = "Standard_DS2_v2"
    zones   = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type"    = "system"
      "environment"      = "dev"
      "nodepoolos"       = "linux"
     } 
   tags = {
      "nodepool-type"    = "system"
      "environment"      = "dev"
      "nodepoolos"       = "linux"
   } 
  }

  identity {
    type = "SystemAssigned"
  }
 
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
        key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
      network_plugin = "kubenet"
      load_balancer_sku = "standard"
  }

    
  }



# resource "azurerm_kubernetes_cluster" "newlook" {
#   name                = "newlook-aks1"
#   location            = azurerm_resource_group.newlook.location
#   resource_group_name = azurerm_resource_group.newlook.name
#   dns_prefix          = "newlookaks1"
#   sku_tier            = "Free"

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_D2_v2"
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   tags = {
#     Environment = "Dev"
#   }
# }

# output "client_certificate" {
#   value     = azurerm_kubernetes_cluster.newlook.kube_config.0.client_certificate
#   sensitive = true
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.newlook.kube_config_raw

#   sensitive = true
# }
