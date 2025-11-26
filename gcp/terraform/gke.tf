# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  # Remove default node pool immediately after cluster creation
  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false
  networking_mode     = "VPC_NATIVE"

  # IP allocation policy required for VPC_NATIVE
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }

  # Workload Identity (best practice for pod authentication)
  workload_identity_config {
    workload_pool = "${data.external.environment.result["project_id"]}.svc.id.goog"
  }
}

# Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    # OAuth scopes for node access to GCP services
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Workload Identity metadata
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded instance configuration for security
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  # Node pool management settings
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
