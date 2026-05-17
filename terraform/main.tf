# ── VPC ──────────────────────────────────────────────────────────────────────
resource "digitalocean_vpc" "main" {
  name     = "${var.cluster_name}-vpc"
  region   = var.region
  ip_range = "10.10.0.0/16"
}

# ── Kubernetes cluster (DOKS) ─────────────────────────────────────────────────
data "digitalocean_kubernetes_versions" "available" {}

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

# PostgreSQL runs inside the cluster (see k8s/postgres.yaml)
