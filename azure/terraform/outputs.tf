output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_kubernetes_cluster.aks.resource_group_name
}

output "location" {
  description = "Azure region where the cluster is deployed"
  value       = azurerm_kubernetes_cluster.aks.location
}

output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "kubernetes_version" {
  description = "Kubernetes version of the cluster"
  value       = azurerm_kubernetes_cluster.aks.kubernetes_version
}

output "node_os_sku" {
  description = "Operating system SKU for nodes"
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].os_sku
}

output "kube_config_commands" {
  description = "Commands to configure kubectl access"
  value = join("\n", [
    "",
    "Run the following commands to gain kubectl access to the cluster:",
    "",
    "az aks get-credentials --resource-group ${azurerm_kubernetes_cluster.aks.resource_group_name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing",
    "kubectl get nodes",
    ""
  ])
}
