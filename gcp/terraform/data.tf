# External data source to read GCP credentials from environment
data "external" "environment" {
  program = ["${path.module}/environment.sh"]
}
