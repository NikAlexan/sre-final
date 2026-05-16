# ── VPC ──────────────────────────────────────────────────────────────────────
resource "digitalocean_vpc" "main" {
  name     = "${var.cluster_name}-vpc"
  region   = var.region
  ip_range = "10.10.0.0/16"
}

# ── Kubernetes cluster (DOKS) ─────────────────────────────────────────────────
data "digitalocean_kubernetes_versions" "available" {
  version_prefix = "${var.k8s_version}."
}

resource "digitalocean_kubernetes_cluster" "main" {
  name     = var.cluster_name
  region   = var.region
  version  = data.digitalocean_kubernetes_versions.available.latest_version
  vpc_uuid = digitalocean_vpc.main.id

  node_pool {
    name       = "${var.cluster_name}-workers"
    size       = var.node_size
    node_count = var.node_count

    labels = {
      env  = "production"
      role = "worker"
    }
  }

  tags = ["sre-capstone", "kubernetes"]
}

# ── Managed PostgreSQL ────────────────────────────────────────────────────────
resource "digitalocean_database_cluster" "postgres" {
  name       = "${var.cluster_name}-db"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1
  private_network_uuid = digitalocean_vpc.main.id

  tags = ["sre-capstone", "postgres"]
}

resource "digitalocean_database_db" "ecommerce" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = var.db_name
}

# Allow only cluster nodes to reach the database.
resource "digitalocean_database_firewall" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id

  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.main.id
  }
}
