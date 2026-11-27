variable "project_id" {
  description = "Dedicated GCP production project ID"
  type        = string
  default     = "plt-prod-core-example"
}

variable "region" {
  description = "GCP region for regional HA resources"
  type        = string
  default     = "us-central1"
}

variable "vpc_cidr" {
  description = "Primary subnet CIDR for production GKE nodes"
  type        = string
  default     = "10.20.0.0/20"
}
