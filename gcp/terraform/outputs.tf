output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "Location (region) of the GKE cluster"
  value       = google_container_cluster.primary.location
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "project_id" {
  description = "GCP Project ID"
  value       = data.external.environment.result["project_id"]
}

output "node_pool_name" {
  description = "Name of the managed node pool"
  value       = google_container_node_pool.primary_nodes.name
}

output "kubectl_connection_command" {
  description = "Command to configure kubectl access"
  value = join("\n", [
    "",
    "Run the following command to gain kubectl access to the cluster:",
    "",
    "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${data.external.environment.result["project_id"]}",
    "kubectl get nodes",
    ""
  ])
}
