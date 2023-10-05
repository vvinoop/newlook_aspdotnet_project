# output "aks_node_rg" {
#   value = azurerm_kubernetes_cluster.aks-cluster.node_resource_group
# }
# output "aks_fqdn" {
#   value = azurerm_kubernetes_cluster.aks-cluster.fqdn
# }
# output "aks_id" {
#   value = azurerm_kubernetes_cluster.aks-cluster.id
# }
# resource "local_file" "kubeconfig" {
#   depends_on   = [azurerm_kubernetes_cluster.aks-cluster]
#   filename     = "kubeconfig"
#   content      = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw
# }




