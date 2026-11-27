# Production Design Only — Do NOT apply on a personal free-tier account.

resource "google_compute_network" "prod_vpc" {
  name                    = "plt-prod-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "prod_gke_subnet" {
  name                     = "plt-prod-gke-subnet"
  ip_cidr_range            = var.vpc_cidr
  region                   = var.region
  network                  = google_compute_network.prod_vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.21.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.22.0.0/20"
  }
}

# Regional Private GKE Cluster (3 zones, deletion protection enabled)
resource "google_container_cluster" "prod_gke" {
  name                     = "plt-prod-gke"
  location                 = var.region
  network                  = google_compute_network.prod_vpc.id
  subnetwork               = google_compute_subnetwork.prod_gke_subnet.id
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = true

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.10.0/28"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# On-Demand Regional Node Pool (1-2 nodes per zone = 3-6 total nodes across 3 zones)
resource "google_container_node_pool" "prod_nodes" {
  name     = "plt-prod-ondemand-pool"
  location = var.region
  cluster  = google_container_cluster.prod_gke.name

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = "e2-standard-2"
    spot         = false
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# Regional PostgreSQL HA with PITR & Deletion Protection
resource "google_sql_database_instance" "prod_postgres" {
  name                = "plt-prod-pg-ha"
  database_version    = "POSTGRES_15"
  region              = var.region
  deletion_protection = true

  settings {
    tier              = "db-custom-2-7680"
    availability_type = "REGIONAL"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
    }

    ip_configuration {
      ipv4_enabled = false
    }
  }
}
