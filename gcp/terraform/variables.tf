variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "demo-gke"
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
  default     = "us-west1"
}

variable "zone" {
  description = "GCP zone for the cluster"
  type        = string
  default     = "us-west1-a"
}

variable "node_count" {
  description = "Total number of nodes in the node pool"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for cluster nodes"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Disk size in GB for each node"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Disk type for each node"
  type        = string
  default     = "pd-standard"
}
